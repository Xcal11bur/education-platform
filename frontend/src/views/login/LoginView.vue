<template>
  <div class="login-shell">
    <div class="login-panel">
      <div class="login-copy">
        <div class="login-badge">Education Cloud Platform</div>
        <h1>教育云平台后台</h1>
      </div>

      <div class="login-card">
        <div class="login-card__title">管理员登录</div>
        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @keyup.enter="handleSubmit">
          <el-form-item label="账号" prop="username">
            <el-input v-model="form.username" placeholder="请输入管理员账号" />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
          </el-form-item>
          <el-button type="primary" class="login-submit" :loading="loading" @click="handleSubmit">
            登录后台
          </el-button>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const formRef = ref()
const loading = ref(false)

const form = reactive({
  username: 'admin',
  password: '123456'
})

const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleSubmit() {
  await formRef.value.validate()
  loading.value = true
  try {
    await authStore.login(form)
    ElMessage.success('登录成功')
    router.push('/dashboard')
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
    radial-gradient(circle at top left, rgba(64, 158, 255, 0.22), transparent 35%),
    radial-gradient(circle at bottom right, rgba(84, 112, 198, 0.18), transparent 28%),
    linear-gradient(135deg, #eef3fb 0%, #f8fbff 45%, #edf3f9 100%);
}

.login-panel {
  width: min(1060px, 100%);
  display: grid;
  grid-template-columns: 1.08fr 0.92fr;
  border-radius: 28px;
  overflow: hidden;
  box-shadow: 0 24px 70px rgba(31, 45, 61, 0.16);
  background: rgba(255, 255, 255, 0.92);
}

.login-copy {
  padding: 56px 54px;
  background: linear-gradient(160deg, #24364f 0%, #1f2a3d 55%, #243e73 100%);
  color: #fff;
}

.login-badge {
  display: inline-flex;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.12);
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.login-copy h1 {
  margin: 22px 0 12px;
  font-size: 40px;
  line-height: 1.15;
}

.login-card {
  padding: 56px 48px;
}

.login-card__title {
  font-size: 26px;
  font-weight: 700;
  margin-bottom: 26px;
}

.login-submit {
  width: 100%;
  margin-top: 8px;
}

@media (max-width: 900px) {
  .login-panel {
    grid-template-columns: 1fr;
  }

  .login-copy,
  .login-card {
    padding: 28px 24px;
  }

  .login-copy h1 {
    font-size: 28px;
  }
}
</style>
