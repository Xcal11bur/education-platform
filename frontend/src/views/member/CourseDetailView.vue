<template>
  <div class="course-detail-page">
    <div class="detail-shell">
      <div class="detail-topbar">
        <div class="breadcrumb-row">
          <button type="button" class="breadcrumb-link" @click="router.push('/member-home')">
            首页
          </button>
          <span class="breadcrumb-separator">></span>
          <button
            v-if="course.categoryLevel1?.id"
            type="button"
            class="breadcrumb-link is-category"
            @click="goCategoryCourses"
          >
            {{ course.categoryLevel1.name }}
          </button>
          <span v-else>{{ course.categoryLevel1?.name || '课程详情' }}</span>
          <span class="breadcrumb-separator">></span>
          <span class="is-current">{{ course.title || '课程详情' }}</span>
        </div>

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

      <section class="hero-card" v-loading="loading">
        <div class="cover-panel">
          <img
            v-if="course.coverUrl"
            :src="course.coverUrl"
            :alt="course.title"
            class="course-cover"
          />
          <div v-else class="cover-placeholder">
            <span>{{ course.title || '课程封面' }}</span>
          </div>
        </div>

        <div class="summary-panel">
          <div class="summary-head">
            <div>
              <h1>{{ course.title || '课程详情' }}</h1>
              <p v-if="course.subTitle">{{ course.subTitle }}</p>
            </div>
          </div>

          <div class="meta-card">
            <div class="meta-grid">
              <div class="meta-item">
                <span class="meta-label">课程分类</span>
                <strong>{{ categoryText }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">授课讲师</span>
                <strong>{{ course.teacher?.name || '-' }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">课程难度</span>
                <strong>{{ difficultyText }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">学习人数</span>
                <strong>{{ course.studyCount || 0 }} 人</strong>
              </div>
            </div>

            <div v-if="course.description" class="course-intro">
              {{ course.description }}
            </div>
          </div>

          <div class="action-row">
            <el-button type="primary" size="large" :loading="enrolling" @click="handlePrimaryAction">
              {{ course.enrolled ? '进入学习' : '报名课程' }}
            </el-button>
          </div>
        </div>
      </section>

      <section class="content-grid">
        <div class="tab-panel">
          <el-tabs v-model="activeTab">
            <el-tab-pane label="课程章节" name="chapters">
              <div v-if="chapters.length" class="chapter-list">
                <article
                  v-for="(chapter, chapterIndex) in chapters"
                  :key="chapter.id"
                  class="chapter-card"
                >
                  <button
                    class="chapter-head"
                    type="button"
                    @click="toggleChapter(chapter.id)"
                  >
                    <div class="chapter-head-main">
                      <el-icon class="chapter-toggle" :class="{ 'is-collapsed': !isChapterExpanded(chapter.id) }">
                        <ArrowDown />
                      </el-icon>
                      <h3>{{ displayChapterTitle(chapter, chapterIndex) }}</h3>
                    </div>
                  </button>

                  <div v-if="isChapterExpanded(chapter.id) && chapter.sections?.length" class="section-list">
                    <div
                      v-for="(section, sectionIndex) in chapter.sections"
                      :key="section.id"
                      class="section-row"
                      :class="{ 'is-disabled': section.isFreeTrial !== 1 }"
                      @click="goPreviewSection(section)"
                    >
                      <div class="section-main">
                        <span class="section-order">{{ chapterIndex + 1 }}.{{ sectionIndex + 1 }}</span>
                        <span class="section-title">{{ displaySectionTitle(section, chapterIndex, sectionIndex) }}</span>
                        <el-tag v-if="section.isFreeTrial === 1" size="small" effect="plain">
                          试看
                        </el-tag>
                        <el-icon v-else class="section-lock"><Lock /></el-icon>
                      </div>
                    </div>
                  </div>

                  <el-empty
                    v-else-if="isChapterExpanded(chapter.id)"
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
            </el-tab-pane>

            <el-tab-pane label="课程评价" name="reviews">
              <el-empty description="课程评价功能开发中" :image-size="80" />
            </el-tab-pane>
          </el-tabs>
        </div>

        <aside class="side-panel">
          <div class="side-card">
            <h3>讲师信息</h3>
            <div class="teacher-name">{{ course.teacher?.name || '-' }}</div>
            <div class="teacher-title">{{ course.teacher?.title || '授课讲师' }}</div>
            <p class="teacher-intro">
              {{ course.teacher?.intro || '讲师简介暂未完善。' }}
            </p>
          </div>

          <div class="side-card">
            <h3>课程概览</h3>
            <div class="overview-row">
              <span>章节数</span>
              <strong>{{ chapters.length }}</strong>
            </div>
            <div class="overview-row">
              <span>小节数</span>
              <strong>{{ sectionCount }}</strong>
            </div>
            <div class="overview-row">
              <span>课程价格</span>
              <strong>{{ priceText }}</strong>
            </div>
          </div>
        </aside>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ArrowDown, Lock } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { enrollCourse, getPortalCourseDetail } from '@/api/course'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const enrolling = ref(false)
const activeTab = ref('chapters')
const expandedChapterIds = ref([])
const course = ref({
  teacher: null,
  categoryLevel1: null,
  categoryLevel2: null,
  chapters: [],
  enrolled: false,
  lastStudySectionId: null
})

const chapters = computed(() => course.value.chapters || [])

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')

const categoryText = computed(() =>
  [course.value.categoryLevel1?.name, course.value.categoryLevel2?.name].filter(Boolean).join(' / ') || '-'
)

const difficultyText = computed(() => {
  return {
    1: '初级',
    2: '中级',
    3: '高级'
  }[course.value.difficulty] || '未知'
})

const sectionCount = computed(() =>
  chapters.value.reduce((total, chapter) => total + (chapter.sections?.length || 0), 0)
)

const priceText = computed(() => {
  const price = Number(course.value.price || 0)
  return price > 0 ? `¥ ${price.toFixed(2)}` : '免费'
})

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

function expandAllChapters() {
  expandedChapterIds.value = chapters.value.map((chapter) => chapter.id)
}

function isChapterExpanded(chapterId) {
  return expandedChapterIds.value.includes(chapterId)
}

function toggleChapter(chapterId) {
  if (isChapterExpanded(chapterId)) {
    expandedChapterIds.value = expandedChapterIds.value.filter((id) => id !== chapterId)
    return
  }
  expandedChapterIds.value = [...expandedChapterIds.value, chapterId]
}

function goLearnPage(sectionId = null) {
  if (sectionId) {
    router.push(`/member/courses/${route.params.id}/learn/sections/${sectionId}`)
    return
  }
  if (course.value.lastStudySectionId) {
    router.push(`/member/courses/${route.params.id}/learn/sections/${course.value.lastStudySectionId}`)
    return
  }
  router.push(`/member/courses/${route.params.id}/learn`)
}

function goPreviewSection(section) {
  if (section?.isFreeTrial !== 1) {
    return
  }
  goLearnPage(section.id)
}

async function handlePrimaryAction() {
  if (course.value.enrolled) {
    goLearnPage()
    return
  }
  await ElMessageBox.confirm(
    `确认报名《${course.value.title || '当前课程'}》吗？`,
    '报名确认',
    {
      type: 'warning',
      confirmButtonText: '确认报名',
      cancelButtonText: '取消'
    }
  )
  enrolling.value = true
  try {
    const { data } = await enrollCourse(route.params.id)
    course.value.enrolled = true
    course.value.studyCount = Number(course.value.studyCount || 0) + (data ? 1 : 0)
    ElMessage.success(data ? '报名成功' : '您已报名该课程')
  } finally {
    enrolling.value = false
  }
}

function goCategoryCourses() {
  router.push({
    path: '/member/courses',
    query: { level1Id: course.value.categoryLevel1.id }
  })
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function goProfile() {
  router.push('/member/profile')
}

async function fetchCourseDetail() {
  loading.value = true
  try {
    const { data } = await getPortalCourseDetail(route.params.id)
    course.value = data || {
      teacher: null,
      categoryLevel1: null,
      categoryLevel2: null,
      chapters: []
    }
    expandAllChapters()
  } finally {
    loading.value = false
  }
}

onMounted(fetchCourseDetail)
</script>

<style scoped>
.course-detail-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(15, 23, 42, 0.04), transparent 26%),
    linear-gradient(180deg, #f7f8fa 0%, #f2f4f7 100%);
  padding: 28px 0 40px;
}

.detail-shell {
  width: min(1500px, calc(100vw - 48px));
  margin: 0 auto;
}

.detail-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 18px;
}

.breadcrumb-row {
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  color: #606266;
}

.breadcrumb-link {
  border: 0;
  padding: 0;
  background: transparent;
  color: #303133;
  cursor: pointer;
}

.breadcrumb-separator {
  color: #c0c4cc;
}

.breadcrumb-row .is-current {
  color: #409eff;
}

.breadcrumb-link.is-category {
  color: #409eff;
}

.breadcrumb-link.is-category:hover {
  text-decoration: underline;
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

.hero-card,
.tab-panel,
.side-card {
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(220, 223, 230, 0.92);
  border-radius: 18px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.hero-card {
  display: grid;
  grid-template-columns: 640px minmax(0, 1fr);
  gap: 34px;
  padding: 24px;
}

.cover-panel {
  min-width: 0;
}

.course-cover,
.cover-placeholder {
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: 16px;
}

.course-cover {
  object-fit: cover;
  display: block;
  background: #eef2f7;
}

.cover-placeholder {
  display: grid;
  place-items: center;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  color: #1d4ed8;
  font-size: 28px;
  font-weight: 700;
}

.summary-panel {
  display: flex;
  flex-direction: column;
}

.summary-head h1 {
  margin: 0;
  font-size: 28px;
  line-height: 1.35;
  color: #1f2d3d;
}

.summary-head p {
  margin: 12px 0 0;
  color: #606266;
  font-size: 15px;
  line-height: 1.75;
}

.meta-card {
  margin-top: 20px;
  padding: 20px;
  border-radius: 16px;
  background: #f8fafc;
  border: 1px solid #ebeef5;
}

.meta-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-label {
  color: #909399;
  font-size: 13px;
}

.meta-item strong {
  color: #303133;
  font-size: 16px;
}

.course-intro {
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px solid #e5eaf3;
  color: #606266;
  line-height: 1.85;
  white-space: pre-wrap;
}

.action-row {
  margin-top: 28px;
}

.content-grid {
  margin-top: 24px;
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 20px;
  align-items: start;
}

.tab-panel {
  padding: 0 24px 24px;
}

.chapter-list {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.chapter-card {
  border: 1px solid #ebeef5;
  border-radius: 16px;
  overflow: hidden;
  background: #fff;
}

.chapter-head {
  width: 100%;
  padding: 14px 16px;
  border: 0;
  background: #f8fafc;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  cursor: pointer;
}

.chapter-head-main {
  display: flex;
  align-items: center;
  gap: 10px;
}

.chapter-toggle {
  color: #94a3b8;
  font-size: 16px;
  transition: transform 0.2s ease;
}

.chapter-toggle.is-collapsed {
  transform: rotate(-90deg);
}

.chapter-head h3 {
  margin: 0;
  font-size: 17px;
  color: #1f2d3d;
}

.section-list {
  display: flex;
  flex-direction: column;
}

.section-row {
  display: flex;
  align-items: center;
  padding: 10px 14px;
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

.section-row.is-disabled {
  cursor: default;
}

.section-row.is-disabled:hover {
  background: #fff;
}

.section-main {
  display: flex;
  align-items: center;
  gap: 12px;
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

.section-lock {
  color: #c0c4cc;
  font-size: 14px;
}

.side-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.side-card {
  padding: 22px;
}

.side-card h3 {
  margin: 0 0 18px;
  font-size: 20px;
  color: #1f2d3d;
}

.teacher-name {
  font-size: 18px;
  font-weight: 700;
  color: #303133;
}

.teacher-title {
  margin-top: 8px;
  color: #409eff;
  font-size: 14px;
}

.teacher-intro {
  margin: 14px 0 0;
  color: #606266;
  line-height: 1.85;
}

.overview-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px solid #f1f4f8;
  color: #606266;
}

.overview-row:last-child {
  border-bottom: 0;
}

.overview-row strong {
  color: #303133;
}

@media (max-width: 1200px) {
  .hero-card {
    grid-template-columns: 1fr;
  }

  .content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .detail-shell {
    width: min(100vw - 24px, 1500px);
  }

  .hero-card {
    padding: 16px;
    gap: 20px;
  }

  .summary-head h1 {
    font-size: 24px;
  }

  .meta-grid {
    grid-template-columns: 1fr;
  }

  .tab-panel {
    padding: 0 16px 16px;
  }

  .section-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .chapter-head {
    padding: 12px 14px;
  }

}
</style>
