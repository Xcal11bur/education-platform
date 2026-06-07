<template>
  <div class="learn-page">
    <header class="learn-topbar">
      <button class="brand-button" type="button" @click="router.push('/member-home')">
        <div class="brand-mark">E</div>
        <div class="brand-copy">教育平台</div>
      </button>

      <div class="learn-topbar-right">
        <button class="topbar-link" type="button" @click="router.push(`/member/courses/${route.params.id}`)">
          返回课程详情
        </button>
        <el-dropdown trigger="click" placement="bottom-end">
          <button class="profile-entry" type="button">
            <el-avatar class="profile-avatar" :size="34" :src="avatarUrl">
              {{ displayName.slice(0, 1).toUpperCase() }}
            </el-avatar>
            <div class="profile-copy">
              <strong>{{ displayName }}</strong>
            </div>
          </button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="goProfile">个人中心</el-dropdown-item>
              <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <main class="learn-shell" v-loading="loading">
      <aside class="left-menu">
        <div class="course-hero">
          <div class="hero-cover" :style="courseCoverStyle"></div>
          <div class="hero-title">{{ course.title || '课程学习' }}</div>
        </div>

        <button
          v-for="item in menuItems"
          :key="item.key"
          class="menu-item"
          :class="{ 'is-active': activeMenu === item.key }"
          type="button"
          @click="activeMenu = item.key"
        >
          <el-icon class="menu-icon">
            <component :is="item.icon" />
          </el-icon>
          <span>{{ item.label }}</span>
        </button>
      </aside>

      <section class="learn-content">
        <template v-if="activeMenu === 'chapters'">
          <div class="content-card">
            <div class="block-head">
              <h2>目录</h2>
              <span>{{ chapters.length }} 个章节 / {{ sectionCount }} 个小节</span>
            </div>

            <div v-if="chapters.length" class="chapter-list">
              <article
                v-for="(chapter, chapterIndex) in chapters"
                :key="chapter.id"
                class="chapter-card"
              >
                <div class="chapter-head">
                  <h3>{{ displayChapterTitle(chapter, chapterIndex) }}</h3>
                </div>

                <div v-if="chapter.sections?.length" class="section-list">
                  <button
                    v-for="(section, sectionIndex) in chapter.sections"
                    :key="section.id"
                    class="section-row"
                    type="button"
                    @click="openSection(section.id)"
                  >
                    <div class="section-main">
                      <span class="section-order">{{ chapterIndex + 1 }}.{{ sectionIndex + 1 }}</span>
                      <span class="section-title">{{ displaySectionTitle(section, chapterIndex, sectionIndex) }}</span>
                      <el-tag v-if="section.isFreeTrial === 1" size="small" effect="plain">
                        试看
                      </el-tag>
                    </div>
                  </button>
                </div>

                <el-empty
                  v-else
                  description="暂无小节内容"
                  :image-size="60"
                />
              </article>
            </div>

            <el-empty
              v-else-if="!loading"
              description="暂无课程章节"
              :image-size="80"
            />
          </div>
        </template>

        <template v-else-if="activeMenu === 'materials'">
          <div class="content-card">
            <div class="block-head">
              <h2>课程资料</h2>
              <span>{{ courseMaterials.length }} 个附件</span>
            </div>

            <div v-if="courseMaterials.length" class="material-list">
              <a
                v-for="material in courseMaterials"
                :key="material.id"
                class="material-card"
                :href="material.fileUrl"
                target="_blank"
                rel="noreferrer"
              >
                <div>
                  <div class="material-title">{{ material.materialName }}</div>
                  <div class="material-sub">
                    <span>{{ materialTypeText(material.materialType) }}</span>
                    <span>上传时间 {{ formatUploadTime(material.createdAt) }}</span>
                  </div>
                </div>
                <div class="material-size">{{ formatFileSize(material.fileSize) }}</div>
              </a>
            </div>

            <el-empty
              v-else
              description="当前课程暂无资料"
              :image-size="72"
            />
          </div>
        </template>

        <template v-else>
          <div class="content-card placeholder-card">
            <h2>{{ activeMenuLabel }}</h2>
          </div>
        </template>
      </section>
    </main>
  </div>
</template>

<script setup>
import { Collection, Document, EditPen, Reading } from '@element-plus/icons-vue'
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getPortalCourseDetail, getPortalCourseMaterials } from '@/api/course'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const activeMenu = ref('chapters')
const course = ref({
  title: '',
  coverUrl: '',
  chapters: []
})
const courseMaterials = ref([])

const menuItems = [
  { key: 'chapters', label: '章节', icon: Reading },
  { key: 'assignments', label: '作业', icon: EditPen },
  { key: 'exams', label: '考试', icon: Collection },
  { key: 'materials', label: '课程资料', icon: Document }
]

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')

const chapters = computed(() => course.value.chapters || [])

const sectionCount = computed(() =>
  chapters.value.reduce((total, chapter) => total + (chapter.sections?.length || 0), 0)
)

const activeMenuLabel = computed(
  () => menuItems.find((item) => item.key === activeMenu.value)?.label || '功能'
)

const courseCoverStyle = computed(() => {
  if (!course.value.coverUrl) {
    return {}
  }
  return {
    backgroundImage: `linear-gradient(180deg, rgba(15, 23, 42, 0.08), rgba(15, 23, 42, 0.42)), url(${course.value.coverUrl})`,
    backgroundSize: 'cover',
    backgroundPosition: 'center'
  }
})

function materialTypeText(type) {
  return {
    1: '文档',
    2: '压缩包',
    3: '图片',
    4: '其他'
  }[type] || '资料'
}

function formatFileSize(size) {
  const total = Number(size || 0)
  if (!total) {
    return '--'
  }
  if (total >= 1024 * 1024) {
    return `${(total / (1024 * 1024)).toFixed(1)} MB`
  }
  if (total >= 1024) {
    return `${(total / 1024).toFixed(1)} KB`
  }
  return `${total} B`
}

function formatUploadTime(value) {
  if (!value) {
    return '--'
  }
  const normalized = String(value)
    .replace('T', ' ')
    .replace(/\.\d+$/, '')
    .replace(/Z$/, '')
  return normalized.length > 16 ? normalized.slice(0, 16) : normalized
}

function displayChapterTitle(chapter, chapterIndex) {
  const title = String(chapter?.title || '').trim()
  if (!title) {
    return `第${chapterIndex + 1}章`
  }
  return title.replace(/^\s*章节\s*\d+\s*[:：-]?\s*/i, '')
}

function displaySectionTitle(section, chapterIndex, sectionIndex) {
  const title = String(section?.title || '').trim()
  if (!title) {
    return `小节 ${chapterIndex + 1}.${sectionIndex + 1}`
  }

  const orderPatterns = [
    new RegExp(`^${chapterIndex + 1}\\.${sectionIndex + 1}\\s*`),
    new RegExp(`^${chapterIndex + 1}[-_.]${sectionIndex + 1}\\s*`),
    /^\d+\.\d+\s*/,
    /^第\s*\d+\s*节\s*[:：-]?\s*/
  ]

  return orderPatterns.reduce((value, pattern) => value.replace(pattern, '').trim(), title)
}

function openSection(sectionId) {
  router.push(`/member/courses/${route.params.id}/learn/sections/${sectionId}`)
}

async function fetchCourseDetail() {
  loading.value = true
  try {
    const { data } = await getPortalCourseDetail(route.params.id)
    course.value = data || { title: '', coverUrl: '', chapters: [] }
  } finally {
    loading.value = false
  }
}

async function fetchCourseMaterials() {
  const { data } = await getPortalCourseMaterials(route.params.id)
  courseMaterials.value = data || []
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function goProfile() {
  router.push('/member/profile')
}

onMounted(async () => {
  await Promise.all([fetchCourseDetail(), fetchCourseMaterials()])
})
</script>

<style scoped>
.learn-page {
  min-height: 100vh;
  background: #f5f7fb;
}

.learn-topbar {
  height: 66px;
  padding: 0 22px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  background: rgba(255, 255, 255, 0.96);
  border-bottom: 1px solid #e5e7eb;
}

.brand-button {
  display: flex;
  align-items: center;
  gap: 12px;
  border: 0;
  background: transparent;
  cursor: pointer;
}

.brand-mark {
  width: 38px;
  height: 38px;
  display: grid;
  place-items: center;
  border-radius: 12px;
  background: linear-gradient(135deg, #ef4444, #f97316);
  color: #fff;
  font-size: 18px;
  font-weight: 800;
}

.brand-copy {
  font-size: 20px;
  font-weight: 700;
  color: #1f2d3d;
}

.learn-topbar-right {
  display: flex;
  align-items: center;
  gap: 14px;
}

.topbar-link {
  border: 0;
  background: transparent;
  color: #409eff;
  font-size: 14px;
  cursor: pointer;
}

.profile-entry {
  border: 1px solid #dcdfe6;
  background: rgba(255, 255, 255, 0.96);
  border-radius: 10px;
  padding: 6px 10px;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.profile-avatar {
  background: #409eff;
  color: #fff;
}

.profile-copy {
  display: flex;
  align-items: center;
  line-height: 1;
}

.profile-copy strong {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #303133;
  font-size: 14px;
}

.learn-shell {
  min-height: calc(100vh - 66px);
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr);
  gap: 20px;
  padding: 20px;
}

.left-menu,
.content-card {
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid #e5e7eb;
  border-radius: 18px;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.05);
}

.left-menu {
  padding: 18px 0;
  align-self: start;
  position: sticky;
  top: 20px;
}

.course-hero {
  margin: 0 16px 18px;
}

.hero-cover {
  height: 98px;
  border-radius: 14px;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
}

.hero-title {
  margin-top: 12px;
  color: #1f2d3d;
  font-size: 15px;
  line-height: 1.55;
  font-weight: 700;
}

.menu-item {
  width: 100%;
  padding: 14px 18px;
  border: 0;
  background: transparent;
  color: #606266;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.menu-item.is-active,
.menu-item:hover {
  background: #eef4ff;
  color: #1d4ed8;
}

.menu-icon {
  font-size: 18px;
}

.content-card {
  padding: 22px;
}

.block-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
}

.block-head h2,
.placeholder-card h2 {
  margin: 0;
  color: #1f2d3d;
}

.block-head span {
  color: #909399;
  font-size: 13px;
}

.chapter-list {
  margin-top: 14px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chapter-card {
  border: 1px solid #ebeef5;
  border-radius: 14px;
  overflow: hidden;
  background: #fff;
}

.chapter-head {
  padding: 14px 16px;
  background: #f8fafc;
  border-bottom: 1px solid #ebeef5;
}

.chapter-head h3 {
  margin: 0;
  font-size: 16px;
  color: #1f2d3d;
}

.section-list {
  display: flex;
  flex-direction: column;
}

.section-row {
  width: 100%;
  border: 0;
  background: #fff;
  display: flex;
  align-items: center;
  padding: 11px 16px;
  border-bottom: 1px solid #f1f4f8;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.section-row:last-child {
  border-bottom: 0;
}

.section-row:hover {
  background: #fafcff;
}

.section-main {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.section-order {
  color: #909399;
  font-size: 12px;
}

.section-title {
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.material-list {
  margin-top: 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.material-card {
  padding: 16px 18px;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  text-decoration: none;
  transition: border-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
}

.material-card:hover {
  transform: translateY(-1px);
  border-color: #bfdbfe;
  box-shadow: 0 10px 20px rgba(59, 130, 246, 0.08);
}

.material-title {
  color: #1f2d3d;
  font-size: 15px;
  font-weight: 700;
}

.material-sub {
  margin-top: 4px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.material-sub,
.material-size,
.placeholder-card p {
  color: #909399;
  font-size: 13px;
}

@media (max-width: 960px) {
  .learn-shell {
    grid-template-columns: 1fr;
  }

  .left-menu {
    position: static;
  }

  .block-head {
    flex-direction: column;
  }
}

@media (max-width: 640px) {
  .learn-topbar {
    height: auto;
    padding: 12px 16px;
    flex-wrap: wrap;
  }

  .learn-shell {
    padding: 14px;
  }

  .content-card {
    padding: 18px 16px;
  }

  .section-row {
    flex-direction: column;
    align-items: flex-start;
    padding: 10px 14px;
  }
}
</style>
