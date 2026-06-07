<template>
  <div class="profile-page">
    <header class="profile-header">
      <button class="brand-button" type="button" @click="router.push('/member-home')">
        教育平台
      </button>

      <div class="header-right">
        <button class="header-link" type="button" @click="router.push('/member-home')">返回首页</button>
        <el-avatar class="header-avatar" :size="34" :src="profileForm.avatar || authStore.profile?.avatar">
          {{ displayName.slice(0, 1).toUpperCase() }}
        </el-avatar>
        <strong>{{ displayName }}</strong>
      </div>
    </header>

    <main class="profile-shell">
      <aside class="profile-sidebar">
        <div class="profile-card">
          <el-avatar class="profile-avatar" :size="64" :src="profileForm.avatar || authStore.profile?.avatar">
            {{ displayName.slice(0, 1).toUpperCase() }}
          </el-avatar>
          <div class="profile-name">{{ displayName }}</div>
          <div class="profile-role">学生</div>
        </div>

        <nav class="profile-menu">
          <button
            v-for="item in menuItems"
            :key="item.key"
            class="profile-menu-item"
            :class="{ 'is-active': activeMenu === item.key }"
            type="button"
            @click="activeMenu = item.key"
          >
            <el-icon><component :is="item.icon" /></el-icon>
            <span>{{ item.label }}</span>
          </button>
        </nav>
      </aside>

      <section class="profile-content">
        <div class="content-head">
          <h1>{{ activeMenuLabel }}</h1>
        </div>

        <div v-if="activeMenu === 'courses'" class="placeholder-panel">
          <el-empty description="我的课程内容后续完善" :image-size="90" />
        </div>

        <el-form
          v-else-if="activeMenu === 'info'"
          ref="profileFormRef"
          class="profile-form"
          :model="profileForm"
          :rules="profileRules"
          label-width="96px"
        >
          <el-form-item label="头像">
            <div class="avatar-editor">
              <el-avatar class="editable-avatar" :size="96" :src="profileForm.avatar">
                {{ profileForm.nickname.slice(0, 1).toUpperCase() || '学' }}
              </el-avatar>
              <div class="avatar-actions">
                <input
                  :key="avatarInputKey"
                  type="file"
                  class="avatar-input"
                  accept="image/*"
                  @change="handleAvatarChange"
                />
                <div v-if="avatarError" class="form-error">{{ avatarError }}</div>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="昵称" prop="nickname">
            <el-input v-model="profileForm.nickname" maxlength="30" />
          </el-form-item>

          <el-form-item label="手机号">
            <div class="inline-value">
              <span>{{ profileForm.mobile || '-' }}</span>
              <el-button link type="primary" @click="openMobileDialog">更换手机</el-button>
            </div>
          </el-form-item>

          <el-form-item label="登录密码">
            <el-button plain @click="openPasswordDialog">修改密码</el-button>
          </el-form-item>

          <el-form-item label="真实姓名">
            <el-input v-model="profileForm.realName" maxlength="30" />
          </el-form-item>

          <el-form-item label="性别">
            <el-radio-group v-model="profileForm.gender">
              <el-radio :value="1">男</el-radio>
              <el-radio :value="2">女</el-radio>
              <el-radio :value="0">其他</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" :loading="saving" @click="submitProfile">保存</el-button>
          </el-form-item>
        </el-form>

        <div v-else class="placeholder-panel">
          <el-empty description="收件箱内容后续完善" :image-size="90" />
        </div>
      </section>
    </main>

    <el-dialog v-model="mobileDialogVisible" title="更换手机" width="420px">
      <el-form ref="mobileFormRef" :model="mobileForm" :rules="mobileRules" label-width="84px">
        <el-form-item label="手机号" prop="mobile">
          <el-input v-model="mobileForm.mobile" maxlength="11" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="mobileDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="mobileSaving" @click="submitMobile">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="passwordDialogVisible" title="修改密码" width="460px">
      <el-form ref="passwordFormRef" :model="passwordForm" :rules="passwordRules" label-width="96px">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" show-password />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="passwordSaving" @click="submitPassword">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { Collection, Message, User } from '@element-plus/icons-vue'
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import {
  getMemberProfile,
  updateMemberMobile,
  updateMemberPassword,
  updateMemberProfile,
  uploadMemberAvatar
} from '@/api/member'

const router = useRouter()
const authStore = useAuthStore()

const activeMenu = ref('courses')
const saving = ref(false)
const avatarInputKey = ref(0)
const selectedAvatarFile = ref(null)
const avatarError = ref('')
const avatarPreviewUrl = ref('')
const mobileDialogVisible = ref(false)
const passwordDialogVisible = ref(false)
const mobileSaving = ref(false)
const passwordSaving = ref(false)
const profileFormRef = ref()
const mobileFormRef = ref()
const passwordFormRef = ref()

const profileForm = reactive({
  mobile: '',
  nickname: '',
  realName: '',
  avatar: '',
  gender: 1
})

const mobileForm = reactive({
  mobile: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const menuItems = [
  { key: 'courses', label: '我的课程', icon: Collection },
  { key: 'info', label: '个人信息', icon: User },
  { key: 'inbox', label: '收件箱', icon: Message }
]

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const activeMenuItem = computed(() =>
  menuItems.find((item) => item.key === activeMenu.value) || menuItems[0]
)

const activeMenuLabel = computed(() => activeMenuItem.value.label)

const profileRules = {
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }]
}

const mobileRules = {
  mobile: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ]
}

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为 6-20 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (_rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
          return
        }
        callback()
      },
      trigger: 'blur'
    }
  ]
}

async function fetchProfile() {
  const { data } = await getMemberProfile()
  Object.assign(profileForm, {
    mobile: data?.mobile || '',
    nickname: data?.nickname || '',
    realName: data?.realName || '',
    avatar: data?.avatar || '',
    gender: data?.gender ?? 1
  })
}

function validateAvatar(file) {
  const maxSize = 5 * 1024 * 1024
  const isImage = typeof file.type === 'string' && file.type.startsWith('image/')
  if (!isImage) {
    avatarError.value = '仅支持上传图片文件'
    return false
  }
  if (file.size > maxSize) {
    avatarError.value = '头像图片不能超过 5MB'
    return false
  }
  return true
}

function handleAvatarChange(event) {
  const file = event.target.files?.[0]
  avatarError.value = ''
  if (!file) {
    selectedAvatarFile.value = null
    return
  }
  if (!validateAvatar(file)) {
    selectedAvatarFile.value = null
    avatarInputKey.value += 1
    return
  }
  selectedAvatarFile.value = file
  revokeAvatarPreview()
  avatarPreviewUrl.value = URL.createObjectURL(file)
  profileForm.avatar = avatarPreviewUrl.value
}

async function submitProfile() {
  await profileFormRef.value.validate()
  saving.value = true
  try {
    let avatarUrl = profileForm.avatar
    if (selectedAvatarFile.value) {
      const { data } = await uploadMemberAvatar(selectedAvatarFile.value)
      avatarUrl = data.url
    }
    await updateMemberProfile({
      nickname: profileForm.nickname,
      realName: profileForm.realName,
      avatar: avatarUrl,
      gender: profileForm.gender
    })
    profileForm.avatar = avatarUrl
    selectedAvatarFile.value = null
    revokeAvatarPreview()
    avatarInputKey.value += 1
    await authStore.fetchProfile()
    ElMessage.success('个人信息已保存')
  } finally {
    saving.value = false
  }
}

function openMobileDialog() {
  mobileForm.mobile = profileForm.mobile
  mobileDialogVisible.value = true
}

async function submitMobile() {
  await mobileFormRef.value.validate()
  mobileSaving.value = true
  try {
    await updateMemberMobile({ mobile: mobileForm.mobile })
    profileForm.mobile = mobileForm.mobile
    await authStore.fetchProfile()
    mobileDialogVisible.value = false
    ElMessage.success('手机号已更新')
  } finally {
    mobileSaving.value = false
  }
}

function openPasswordDialog() {
  Object.assign(passwordForm, {
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
  passwordDialogVisible.value = true
}

async function submitPassword() {
  await passwordFormRef.value.validate()
  passwordSaving.value = true
  try {
    await updateMemberPassword(passwordForm)
    passwordDialogVisible.value = false
    ElMessage.success('密码已修改')
  } finally {
    passwordSaving.value = false
  }
}

onMounted(fetchProfile)

onBeforeUnmount(() => {
  revokeAvatarPreview()
})

function revokeAvatarPreview() {
  if (avatarPreviewUrl.value) {
    URL.revokeObjectURL(avatarPreviewUrl.value)
    avatarPreviewUrl.value = ''
  }
}
</script>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: #f4f6fb;
  color: #1f2d3d;
}

.profile-header {
  height: 72px;
  padding: 0 30px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background:
    radial-gradient(circle at 20% 0, rgba(255, 255, 255, 0.18), transparent 28%),
    linear-gradient(135deg, #4f5fd5 0%, #6377c5 100%);
  color: #fff;
}

.brand-button,
.header-link {
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
}

.brand-button {
  font-size: 20px;
  font-weight: 800;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 14px;
}

.header-avatar,
.profile-avatar {
  background: #409eff;
  color: #fff;
}

.profile-shell {
  width: min(1480px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 24px 0 40px;
  display: grid;
  grid-template-columns: 250px minmax(0, 1fr);
  gap: 24px;
}

.profile-sidebar,
.profile-content {
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  box-shadow: 0 12px 28px rgba(31, 45, 61, 0.06);
}

.profile-sidebar {
  overflow: hidden;
  align-self: start;
}

.profile-card {
  min-height: 210px;
  padding: 30px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #4f5fbd;
  color: #fff;
}

.profile-name {
  margin-top: 16px;
  font-size: 18px;
  font-weight: 700;
}

.profile-role {
  margin-top: 6px;
  color: rgba(255, 255, 255, 0.72);
  font-size: 13px;
}

.profile-menu {
  display: flex;
  flex-direction: column;
  padding: 10px 0;
  background: #5362bd;
}

.profile-menu-item {
  min-height: 58px;
  padding: 0 24px;
  border: 0;
  background: transparent;
  color: rgba(255, 255, 255, 0.92);
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 15px;
  cursor: pointer;
  text-align: left;
}

.profile-menu-item:hover,
.profile-menu-item.is-active {
  background: rgba(29, 38, 115, 0.18);
  color: #fff;
}

.profile-content {
  min-height: 560px;
  padding: 28px 32px;
}

.content-head {
  padding-bottom: 20px;
  border-bottom: 1px solid #e5e7eb;
}

.content-head h1 {
  margin: 0;
  font-size: 24px;
}

.placeholder-panel {
  padding: 80px 0;
}

.profile-form {
  margin-top: 28px;
  max-width: 700px;
}

.avatar-editor {
  display: flex;
  align-items: center;
  gap: 20px;
}

.editable-avatar {
  background: #eef2f7;
  color: #409eff;
  font-size: 28px;
}

.avatar-input {
  width: 260px;
  padding: 8px 10px;
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  background: #fff;
  box-sizing: border-box;
}

.avatar-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.avatar-input::file-selector-button {
  margin-right: 10px;
  border: 0;
  border-radius: 6px;
  background: rgba(64, 158, 255, 0.12);
  color: #409eff;
  padding: 6px 10px;
  cursor: pointer;
}

.form-error {
  font-size: 12px;
}

.form-error {
  color: var(--el-color-danger);
}

.inline-value {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 14px;
}

@media (max-width: 900px) {
  .profile-shell {
    width: min(100vw - 24px, 1480px);
    grid-template-columns: 1fr;
  }

  .profile-header {
    padding: 0 18px;
  }

  .avatar-editor {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
