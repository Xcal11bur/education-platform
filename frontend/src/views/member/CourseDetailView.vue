<template>
  <div class="course-detail-page">
    <div class="detail-shell">
      <div class="breadcrumb-row">
        <button type="button" class="breadcrumb-link" @click="router.push('/member-home')">
          首页
        </button>
        <span class="breadcrumb-separator">></span>
        <span>{{ course.categoryLevel1?.name || '课程详情' }}</span>
        <span class="breadcrumb-separator">></span>
        <span class="is-current">{{ course.title || '课程详情' }}</span>
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
            <el-button type="primary" size="large">立即学习</el-button>
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
                  <div class="chapter-head">
                    <h3>{{ displayChapterTitle(chapter, chapterIndex) }}</h3>
                  </div>

                  <div v-if="chapter.sections?.length" class="section-list">
                    <div
                      v-for="(section, sectionIndex) in chapter.sections"
                      :key="section.id"
                      class="section-row"
                    >
                      <div class="section-main">
                        <span class="section-order">{{ chapterIndex + 1 }}.{{ sectionIndex + 1 }}</span>
                        <span class="section-title">{{ displaySectionTitle(section, chapterIndex, sectionIndex) }}</span>
                        <el-tag v-if="section.isFreeTrial === 1" size="small" effect="plain">
                          试看
                        </el-tag>
                      </div>
                      <div class="section-side">
                        <span>{{ sectionTypeText(section.sectionType) }}</span>
                        <span>{{ formatDuration(section.duration) }}</span>
                      </div>
                    </div>
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
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPortalCourseDetail } from '@/api/course'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const activeTab = ref('chapters')
const course = ref({
  teacher: null,
  categoryLevel1: null,
  categoryLevel2: null,
  chapters: []
})

const chapters = computed(() => course.value.chapters || [])

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

function sectionTypeText(type) {
  return {
    1: '视频',
    2: '图文',
    3: '直播回放'
  }[type] || '课程内容'
}

function formatDuration(duration) {
  const total = Number(duration || 0)
  if (!total) {
    return '--'
  }
  const minutes = Math.floor(total / 60)
  const seconds = total % 60
  return `${minutes}分${String(seconds).padStart(2, '0')}秒`
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

.breadcrumb-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 18px;
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
  padding: 20px;
  background: #f8fafc;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  align-items: center;
}

.chapter-head h3 {
  margin: 0;
  font-size: 18px;
  color: #1f2d3d;
}

.section-list {
  display: flex;
  flex-direction: column;
}

.section-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 16px 20px;
  border-bottom: 1px solid #f1f4f8;
}

.section-row:last-child {
  border-bottom: 0;
}

.section-main {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.section-order {
  color: #909399;
  font-size: 13px;
}

.section-title {
  color: #303133;
  font-size: 15px;
  font-weight: 500;
}

.section-side {
  display: flex;
  align-items: center;
  gap: 16px;
  color: #909399;
  font-size: 13px;
  white-space: nowrap;
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

  .section-side {
    width: 100%;
    justify-content: space-between;
  }
}
</style>
