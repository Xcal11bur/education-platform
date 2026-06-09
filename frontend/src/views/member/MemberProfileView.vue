<template>
  <div class="profile-page">
    <header class="profile-header">
      <button class="brand-button" type="button" @click="router.push('/member-home')">
        <img class="brand-logo" :src="brandLogo" alt="教育云平台 logo" />
        <span>教育云平台</span>
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
          <div v-loading="courseLoading">
            <div v-if="memberCourses.length" class="my-course-grid">
              <article
                v-for="course in memberCourses"
                :key="course.id"
                class="my-course-card"
                @click="goMyCourse(course)"
              >
                <div class="my-course-cover" :style="buildCourseCoverStyle(course.coverUrl)">
                  <div class="my-course-overlay"></div>
                  <span class="my-course-category">{{ course.category }}</span>
                  <el-button
                    class="unenroll-button"
                    type="danger"
                    size="small"
                    plain
                    @click.stop="handleUnenroll(course)"
                  >
                    退课
                  </el-button>
                </div>
                <div class="my-course-body">
                  <h3>{{ course.title }}</h3>
                  <p>{{ course.summary }}</p>
                  <div class="my-course-meta">
                    <span>{{ course.teacherName || '平台课程' }}</span>
                    <span>{{ course.learners }} 人学习</span>
                  </div>
                </div>
              </article>
            </div>

            <el-empty
              v-else
              description="暂无已报名课程"
              :image-size="90"
            />
          </div>
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

          <el-form-item label="生日">
            <el-date-picker
              v-model="profileForm.birthday"
              type="date"
              value-format="YYYY-MM-DD"
              placeholder="请选择生日"
              style="width: 100%;"
            />
          </el-form-item>

          <el-form-item>
            <el-button type="primary" :loading="saving" @click="submitProfile">保存</el-button>
          </el-form-item>
        </el-form>

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
import { Collection, User } from '@element-plus/icons-vue'
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { getMemberCourseList, unenrollCourse } from '@/api/course'
import brandLogo from '@/assets/education-cloud-logo.jpg'
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
const courseLoading = ref(false)
const memberCourses = ref([])
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
  gender: 1,
  birthday: ''
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
  { key: 'info', label: '个人信息', icon: User }
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
    gender: data?.gender ?? 1,
    birthday: data?.birthday || ''
  })
}

function mapMemberCourse(course) {
  return {
    id: course.id,
    category: [course.categoryLevel1Name, course.categoryLevel2Name].filter(Boolean).join(' / '),
    title: course.title,
    summary: course.subTitle || course.description || '课程内容建设中',
    teacherName: course.teacherName || '',
    learners: course.studyCount || 0,
    coverUrl: course.coverUrl || '',
    lastStudySectionId: course.lastStudySectionId
  }
}

async function fetchMemberCourses() {
  courseLoading.value = true
  try {
    const { data } = await getMemberCourseList()
    memberCourses.value = (data || []).map(mapMemberCourse)
  } finally {
    courseLoading.value = false
  }
}

async function handleUnenroll(course) {
  await ElMessageBox.confirm(
    `确认退出《${course.title || '当前课程'}》吗？`,
    '退课确认',
    {
      type: 'warning',
      confirmButtonText: '确认退课',
      cancelButtonText: '取消'
    }
  )
  const { data } = await unenrollCourse(course.id)
  memberCourses.value = memberCourses.value.filter((item) => item.id !== course.id)
  ElMessage.success(data ? '已退课' : '课程已不在您的学习列表中')
}

function buildCourseCoverStyle(coverUrl) {
  if (!coverUrl) {
    return {}
  }
  return {
    backgroundImage: `url(${coverUrl})`,
    backgroundSize: 'cover',
    backgroundPosition: 'center'
  }
}

function goMyCourse(course) {
  if (course.lastStudySectionId) {
    router.push(`/member/courses/${course.id}/learn/sections/${course.lastStudySectionId}`)
    return
  }
  router.push(`/member/courses/${course.id}/learn`)
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
      gender: profileForm.gender,
      birthday: profileForm.birthday || null
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

onMounted(async () => {
  await Promise.all([fetchProfile(), fetchMemberCourses()])
})

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
  background:
    radial-gradient(circle at top, rgba(64, 158, 255, 0.16), transparent 34%),
    linear-gradient(180deg, #f6f9fd 0%, #edf3fb 100%);
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
  display: inline-flex;
  align-items: center;
  gap: 12px;
  font-size: 20px;
  font-weight: 800;
}

.brand-logo {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  object-fit: cover;
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
  padding: 28px 0 0;
}

.my-course-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.my-course-card {
  position: relative;
  overflow: hidden;
  border: 1px solid #dcdfe6;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.98);
  box-shadow: 0 10px 24px rgba(31, 45, 61, 0.05);
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.my-course-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 26px rgba(31, 45, 61, 0.08);
}

.my-course-cover {
  position: relative;
  height: 128px;
  padding: 12px;
  display: flex;
  align-items: flex-start;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
}

.my-course-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(15, 23, 42, 0.05) 0%, rgba(15, 23, 42, 0.42) 100%);
}

.my-course-category {
  position: relative;
  z-index: 1;
  display: inline-flex;
  padding: 5px 10px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.88);
  color: #1d4ed8;
  font-size: 12px;
  font-weight: 700;
}

.unenroll-button {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 2;
  opacity: 0;
  pointer-events: none;
  transform: translateY(-4px);
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.my-course-card:hover .unenroll-button {
  opacity: 1;
  pointer-events: auto;
  transform: translateY(0);
}

.my-course-body {
  padding: 14px;
}

.my-course-body h3 {
  margin: 0;
  color: #1f2d3d;
  font-size: 16px;
  line-height: 1.3;
}

.my-course-body p {
  margin: 8px 0 0;
  min-height: 42px;
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
}

.my-course-meta {
  margin-top: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: #909399;
  font-size: 12px;
}

.my-course-body .el-button {
  margin-top: 14px;
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

  .my-course-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 640px) {
  .my-course-grid {
    grid-template-columns: 1fr;
  }
}
</style>
