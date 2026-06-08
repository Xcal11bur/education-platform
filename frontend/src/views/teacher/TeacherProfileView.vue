<template>
  <div class="page-card profile-page">
    <div class="profile-head">
      <div>
        <h1>个人信息</h1>
        <p>维护教师账号的基础资料、联系方式与密码。</p>
      </div>
    </div>

    <el-form
      ref="profileFormRef"
      class="profile-form"
      :model="profileForm"
      :rules="profileRules"
      label-width="96px"
    >
      <el-form-item label="头像">
        <div class="avatar-editor">
          <el-avatar class="editable-avatar" :size="88" :src="profileForm.avatar || authStore.profile?.avatar">
            {{ profileForm.name.slice(0, 1).toUpperCase() || '师' }}
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

      <el-form-item label="登录账号">
        <el-input v-model="profileForm.loginName" disabled />
      </el-form-item>

      <el-form-item label="姓名" prop="name">
        <el-input v-model="profileForm.name" maxlength="30" />
      </el-form-item>

      <el-form-item label="手机号" prop="mobile">
        <el-input v-model="profileForm.mobile" maxlength="11" />
      </el-form-item>

      <el-form-item label="邮箱">
        <el-input v-model="profileForm.email" maxlength="100" />
      </el-form-item>

      <el-form-item label="职称">
        <el-input v-model="profileForm.title" maxlength="50" />
      </el-form-item>

      <el-form-item label="个人简介">
        <el-input v-model="profileForm.intro" type="textarea" :rows="5" maxlength="500" show-word-limit />
      </el-form-item>

      <el-form-item label="登录密码">
        <el-button plain @click="openPasswordDialog">修改密码</el-button>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" :loading="saving" @click="submitProfile">保存</el-button>
      </el-form-item>
    </el-form>

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
import { onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import {
  getTeacherProfile,
  updateTeacherPassword,
  updateTeacherProfile,
  uploadTeacherAvatar
} from '@/api/teacherProfile'

const authStore = useAuthStore()

const saving = ref(false)
const passwordSaving = ref(false)
const passwordDialogVisible = ref(false)
const avatarInputKey = ref(0)
const selectedAvatarFile = ref(null)
const avatarError = ref('')
const avatarPreviewUrl = ref('')
const profileFormRef = ref()
const passwordFormRef = ref()

const profileForm = reactive({
  loginName: '',
  name: '',
  mobile: '',
  email: '',
  title: '',
  intro: '',
  avatar: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const profileRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  mobile: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  email: [{ type: 'email', message: '邮箱格式不正确', trigger: 'blur' }]
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
  const { data } = await getTeacherProfile()
  Object.assign(profileForm, {
    loginName: data?.loginName || '',
    name: data?.name || '',
    mobile: data?.mobile || '',
    email: data?.email || '',
    title: data?.title || '',
    intro: data?.intro || '',
    avatar: data?.avatar || ''
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
      const { data } = await uploadTeacherAvatar(selectedAvatarFile.value)
      avatarUrl = data.url
    }
    await updateTeacherProfile({
      name: profileForm.name,
      mobile: profileForm.mobile,
      email: profileForm.email,
      title: profileForm.title,
      intro: profileForm.intro,
      avatar: avatarUrl
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
    await updateTeacherPassword(passwordForm)
    passwordDialogVisible.value = false
    ElMessage.success('密码已修改')
  } finally {
    passwordSaving.value = false
  }
}

function revokeAvatarPreview() {
  if (avatarPreviewUrl.value) {
    URL.revokeObjectURL(avatarPreviewUrl.value)
    avatarPreviewUrl.value = ''
  }
}

onMounted(fetchProfile)

onBeforeUnmount(() => {
  revokeAvatarPreview()
})
</script>

<style scoped>
.profile-page {
  max-width: 920px;
}

.profile-head {
  margin-bottom: 24px;
}

.profile-head h1 {
  margin: 0;
  font-size: 28px;
  color: #183f3a;
}

.profile-head p {
  margin: 8px 0 0;
  color: #6b7d78;
}

.profile-form {
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid #dce8e3;
  border-radius: 18px;
  padding: 26px 28px 8px;
  box-shadow: 0 14px 32px rgba(17, 52, 48, 0.05);
}

.avatar-editor {
  display: flex;
  align-items: center;
  gap: 20px;
}

.editable-avatar {
  background: #eef7f3;
  color: #2f8d73;
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
  background: rgba(47, 141, 115, 0.12);
  color: #2f8d73;
  padding: 6px 10px;
  cursor: pointer;
}

.form-error {
  font-size: 12px;
  color: var(--el-color-danger);
}

@media (max-width: 900px) {
  .profile-form {
    padding: 20px 18px 4px;
  }

  .avatar-editor {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
