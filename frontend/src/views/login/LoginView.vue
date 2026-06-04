<template>
  <div class="login-shell">
    <div class="login-window">
      <div class="login-head">
        <div class="login-badge">Education Platform</div>
        <h1>{{ isAdminMode ? '管理员登录' : '学员登录' }}</h1>
        <p>{{ isAdminMode ? '进入后台管理系统' : '进入教育平台首页' }}</p>
      </div>

      <el-radio-group v-model="loginMode" class="login-mode">
        <el-radio-button label="管理员登录" value="admin" />
        <el-radio-button label="学员登录" value="member" />
      </el-radio-group>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        class="login-form"
        @keyup.enter="handleSubmit"
      >
        <el-form-item :label="isAdminMode ? '账号' : '手机号'" prop="username">
          <el-input
            v-model="form.username"
            :placeholder="isAdminMode ? '请输入管理员账号' : '请输入学员手机号'"
          />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            placeholder="请输入登录密码"
          />
        </el-form-item>

        <el-button
          type="primary"
          class="login-submit"
          :loading="loading"
          @click="handleSubmit"
        >
          {{ isAdminMode ? '登录后台' : '进入平台' }}
        </el-button>
      </el-form>

      <p class="login-hint">
        {{ isAdminMode ? '管理员登录后进入后台管理系统' : '学员登录后进入教育平台首页，当前首页为占位页' }}
      </p>
    </div>
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const formRef = ref()
const loading = ref(false)
const loginMode = ref('admin')

const defaults = {
  admin: {
    username: 'admin',
    password: '123456'
  },
  member: {
    username: '',
    password: '123456'
  }
}

const form = reactive({
  username: defaults.admin.username,
  password: defaults.admin.password
})

const isAdminMode = computed(() => loginMode.value === 'admin')

const rules = computed(() => ({
  username: [
    {
      required: true,
      message: isAdminMode.value ? '请输入管理员账号' : '请输入学员手机号',
      trigger: 'blur'
    }
  ],
  password: [
    {
      required: true,
      message: '请输入登录密码',
      trigger: 'blur'
    }
  ]
}))

watch(loginMode, (mode) => {
  Object.assign(form, defaults[mode])
  formRef.value?.clearValidate()
})

async function handleSubmit() {
  await formRef.value.validate()
  loading.value = true
  try {
    await authStore.login(loginMode.value, form)
    ElMessage.success('登录成功')
    router.push(authStore.getDefaultRoute())
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-shell {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 24px;
  background:
    radial-gradient(circle at top, rgba(64, 158, 255, 0.16), transparent 34%),
    linear-gradient(180deg, #f6f9fd 0%, #edf3fb 100%);
}

.login-window {
  width: min(440px, 100%);
  padding: 40px 36px 30px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(214, 224, 237, 0.72);
  box-shadow: 0 20px 56px rgba(31, 45, 61, 0.12);
}

.login-head {
  margin-bottom: 24px;
}

.login-badge {
  display: inline-flex;
  padding: 8px 14px;
  border-radius: 999px;
  background: #edf4ff;
  color: #2c5ea8;
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.login-head h1 {
  margin: 18px 0 8px;
  font-size: 38px;
  line-height: 1.08;
  color: #1f2a3d;
  text-wrap: balance;
}

.login-head p {
  margin: 0;
  color: #607086;
  font-size: 14px;
}

.login-mode {
  display: flex;
  width: 100%;
  margin-bottom: 22px;
}

.login-mode :deep(.el-radio-button) {
  flex: 1;
}

.login-mode :deep(.el-radio-button__inner) {
  width: 100%;
}

.login-form :deep(.el-form-item__label) {
  color: #314256;
  font-weight: 600;
}

.login-submit {
  width: 100%;
  height: 44px;
  margin-top: 6px;
  border-radius: 12px;
  font-weight: 700;
}

.login-hint {
  margin: 16px 0 0;
  color: #7b8898;
  font-size: 13px;
  line-height: 1.6;
}

@media (max-width: 640px) {
  .login-shell {
    padding: 16px;
  }

  .login-window {
    padding: 28px 22px 24px;
    border-radius: 20px;
  }

  .login-head h1 {
    font-size: 30px;
  }
}
</style>
