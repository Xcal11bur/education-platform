<template>
  <div class="login-shell">
    <div class="login-window">
      <div class="login-topbar">
        <div class="login-badge">Education Platform</div>
        <el-radio-group v-model="panelMode" size="small">
          <el-radio-button label="登录" value="login" />
          <el-radio-button label="注册" value="register" />
        </el-radio-group>
      </div>

      <h1>{{ panelMode === 'login' ? loginTitle : '学员注册' }}</h1>

      <template v-if="panelMode === 'login'">
        <el-radio-group v-model="loginMode" class="login-mode">
          <el-radio-button label="管理员" value="admin" />
          <el-radio-button label="教师" value="teacher" />
          <el-radio-button label="学员" value="member" />
        </el-radio-group>

        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          :validate-on-rule-change="false"
          label-position="top"
          class="login-form"
          autocomplete="on"
          @keyup.enter="handleLogin"
        >
          <el-form-item :label="usernameLabel" prop="username">
            <el-input
              v-model="loginForm.username"
              :placeholder="usernamePlaceholder"
              name="login-username"
              autocomplete="username"
            />
          </el-form-item>

          <el-form-item label="密码" prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              show-password
              placeholder="请输入密码"
              name="login-password"
              autocomplete="current-password"
            />
          </el-form-item>

          <el-button
            type="primary"
            class="login-submit"
            :loading="submitting"
            @click="handleLogin"
          >
            {{ loginSubmitText }}
          </el-button>
        </el-form>
      </template>

      <template v-else>
        <el-form
          ref="registerFormRef"
          :model="registerForm"
          :rules="registerRules"
          label-position="top"
          class="login-form"
          autocomplete="off"
          @keyup.enter="handleRegister"
        >
          <el-form-item label="手机号" prop="mobile">
            <el-input
              v-model="registerForm.mobile"
              placeholder="请输入手机号"
              name="register-mobile"
              autocomplete="off"
            />
          </el-form-item>

          <el-form-item label="昵称" prop="nickname">
            <el-input
              v-model="registerForm.nickname"
              placeholder="请输入昵称"
              name="register-nickname"
              autocomplete="off"
            />
          </el-form-item>

          <el-form-item label="真实姓名" prop="realName">
            <el-input
              v-model="registerForm.realName"
              placeholder="选填"
              name="register-real-name"
              autocomplete="off"
            />
          </el-form-item>

          <el-form-item label="密码" prop="password">
            <el-input
              v-model="registerForm.password"
              type="password"
              show-password
              placeholder="请输入密码"
              name="register-password"
              autocomplete="new-password"
            />
          </el-form-item>

          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input
              v-model="registerForm.confirmPassword"
              type="password"
              show-password
              placeholder="请再次输入密码"
              name="register-confirm-password"
              autocomplete="new-password"
            />
          </el-form-item>

          <el-form-item label="验证码" prop="captchaCode">
            <div class="captcha-row">
              <el-input
                v-model="registerForm.captchaCode"
                placeholder="请输入验证码"
                maxlength="4"
                name="register-captcha"
                autocomplete="off"
              />
              <button type="button" class="captcha-image" @click="refreshCaptcha">
                <img v-if="captcha.imageBase64" :src="captcha.imageBase64" alt="captcha" />
              </button>
            </div>
          </el-form-item>

          <el-button
            type="primary"
            class="login-submit"
            :loading="submitting"
            @click="handleRegister"
          >
            注册
          </el-button>
        </el-form>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getCaptcha, registerMember } from '@/api/auth'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const loginFormRef = ref()
const registerFormRef = ref()
const submitting = ref(false)
const panelMode = ref('login')
const loginMode = ref('admin')

const captcha = reactive({
  captchaKey: '',
  imageBase64: ''
})

const defaults = {
  admin: {
    username: '',
    password: '',
    captchaCode: ''
  },
  teacher: {
    username: '',
    password: '',
    captchaCode: ''
  },
  member: {
    username: '',
    password: '',
    captchaCode: ''
  }
}

const loginForm = reactive({
  username: defaults.admin.username,
  password: defaults.admin.password,
  captchaCode: ''
})

const registerForm = reactive({
  mobile: '',
  nickname: '',
  realName: '',
  password: '',
  confirmPassword: '',
  captchaCode: ''
})

const loginModeLabels = {
  admin: {
    title: '管理员登录',
    usernameLabel: '账号',
    usernamePlaceholder: '请输入管理员账号',
    submitText: '登录后台'
  },
  teacher: {
    title: '教师登录',
    usernameLabel: '账号',
    usernamePlaceholder: '请输入教师账号',
    submitText: '进入教师端'
  },
  member: {
    title: '学员登录',
    usernameLabel: '手机号',
    usernamePlaceholder: '请输入学员手机号',
    submitText: '进入平台'
  }
}

const currentLoginMode = computed(() => loginModeLabels[loginMode.value] || loginModeLabels.admin)
const loginTitle = computed(() => currentLoginMode.value.title)
const usernameLabel = computed(() => currentLoginMode.value.usernameLabel)
const usernamePlaceholder = computed(() => currentLoginMode.value.usernamePlaceholder)
const loginSubmitText = computed(() => currentLoginMode.value.submitText)

const loginRules = computed(() => ({
  username: [
    {
      required: true,
      message: currentLoginMode.value.usernamePlaceholder,
      trigger: 'blur'
    }
  ],
  password: [
    {
      required: true,
      message: '请输入密码',
      trigger: 'blur'
    }
  ]
}))

const registerRules = {
  mobile: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度需为 6-20 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (_rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
          return
        }
        callback()
      },
      trigger: 'blur'
    }
  ],
  captchaCode: [
    { required: true, message: '请输入验证码', trigger: 'blur' }
  ]
}

watch(loginMode, async (mode) => {
  Object.assign(loginForm, defaults[mode])
  await nextTick()
  loginFormRef.value?.clearValidate()
})

watch(panelMode, async () => {
  loginForm.captchaCode = ''
  Object.assign(registerForm, {
    mobile: '',
    nickname: '',
    realName: '',
    password: '',
    confirmPassword: '',
    captchaCode: ''
  })
  await nextTick()
  loginFormRef.value?.clearValidate()
  registerFormRef.value?.clearValidate()
  if (panelMode.value === 'register') {
    refreshCaptcha()
  }
})

async function refreshCaptcha() {
  const { data } = await getCaptcha()
  captcha.captchaKey = data.captchaKey
  captcha.imageBase64 = data.imageBase64
}

async function handleLogin() {
  await loginFormRef.value.validate()
  submitting.value = true
  try {
    await authStore.login(loginMode.value, {
      username: loginForm.username,
      password: loginForm.password
    })
    ElMessage.success('登录成功')
    router.push(authStore.getDefaultRoute())
  } finally {
    submitting.value = false
    loginForm.captchaCode = ''
  }
}

async function handleRegister() {
  await registerFormRef.value.validate()
  submitting.value = true
  try {
    await registerMember({
      mobile: registerForm.mobile,
      nickname: registerForm.nickname,
      realName: registerForm.realName,
      password: registerForm.password,
      confirmPassword: registerForm.confirmPassword,
      captchaKey: captcha.captchaKey,
      captchaCode: registerForm.captchaCode
    })
    ElMessage.success('注册成功，请登录')
    panelMode.value = 'login'
    loginMode.value = 'member'
    Object.assign(loginForm, {
      username: registerForm.mobile,
      password: registerForm.password,
      captchaCode: ''
    })
    Object.assign(registerForm, {
      mobile: '',
      nickname: '',
      realName: '',
      password: '',
      confirmPassword: '',
      captchaCode: ''
    })
  } finally {
    submitting.value = false
    await refreshCaptcha()
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
  padding: 28px 28px 26px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid rgba(214, 224, 237, 0.72);
  box-shadow: 0 20px 56px rgba(31, 45, 61, 0.12);
}

.login-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
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

.login-window h1 {
  margin: 0 0 18px;
  font-size: 34px;
  line-height: 1.08;
  color: #1f2a3d;
}

.login-mode {
  display: flex;
  width: 100%;
  margin-bottom: 20px;
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

.captcha-row {
  display: grid;
  grid-template-columns: 1fr 132px;
  gap: 10px;
  width: 100%;
}

.captcha-image {
  border: 1px solid var(--border-color);
  border-radius: 12px;
  background: #f8fbff;
  padding: 0;
  overflow: hidden;
  cursor: pointer;
}

.captcha-image img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.login-submit {
  width: 100%;
  height: 44px;
  margin-top: 6px;
  border-radius: 12px;
  font-weight: 700;
}

@media (max-width: 640px) {
  .login-shell {
    padding: 16px;
  }

  .login-window {
    padding: 22px 18px 20px;
    border-radius: 20px;
  }

  .login-topbar {
    align-items: stretch;
    flex-direction: column;
  }

  .login-window h1 {
    font-size: 28px;
  }

  .captcha-row {
    grid-template-columns: 1fr;
  }

  .captcha-image {
    height: 52px;
  }
}
</style>
