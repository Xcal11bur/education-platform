<template>
  <div class="section-page">
    <header class="section-topbar">
      <button class="back-link" type="button" @click="router.push(`/member/courses/${route.params.id}/learn`)">
        返回课程
      </button>
      <div class="topbar-title">章节详情</div>
    </header>

    <main class="section-shell" v-loading="loading">
      <section class="section-stage">
        <div class="section-stage-head">
          <div>
            <div class="section-kicker">{{ currentChapterTitle }}</div>
            <h1>{{ currentSectionTitle }}</h1>
          </div>
          <div class="section-meta">
            <span>{{ sectionTypeText(currentSection?.sectionType) }}</span>
            <span>{{ formatDuration(currentSection?.duration) }}</span>
          </div>
        </div>

        <div v-if="currentSection?.videoUrl" class="video-panel">
          <video class="section-video" :src="currentSection.videoUrl" controls preload="metadata"></video>
        </div>
        <div v-else class="video-placeholder">
          <el-icon><VideoPlay /></el-icon>
          <span>当前小节暂无视频，以下为图文内容。</span>
        </div>

        <div class="section-content-block">
          <h2>小节内容</h2>
          <p>{{ currentSection?.content || '当前小节内容建设中。' }}</p>
        </div>

        <div class="section-content-block">
          <div class="block-head">
            <h2>小节资料</h2>
            <span>{{ sectionMaterials.length }} 个附件</span>
          </div>

          <div v-if="sectionMaterials.length" class="material-list">
            <a
              v-for="material in sectionMaterials"
              :key="material.id"
              class="material-card"
              :href="material.fileUrl"
              target="_blank"
              rel="noreferrer"
            >
              <div>
                <div class="material-title">{{ material.materialName }}</div>
                <div class="material-sub">{{ materialTypeText(material.materialType) }}</div>
              </div>
              <div class="material-size">{{ formatFileSize(material.fileSize) }}</div>
            </a>
          </div>

          <el-empty
            v-else
            description="当前小节暂无资料"
            :image-size="72"
          />
        </div>

        <div class="nav-row">
          <el-button :disabled="!prevSection" round @click="selectSection(prevSection?.id)">上一节</el-button>
          <el-button type="primary" :disabled="!nextSection" round @click="selectSection(nextSection?.id)">下一节</el-button>
        </div>
      </section>

      <aside class="right-directory">
        <div class="directory-card">
          <div class="directory-head">目录</div>
          <div class="directory-list">
            <div
              v-for="(chapter, chapterIndex) in chapters"
              :key="chapter.id"
              class="directory-chapter"
            >
              <div class="directory-chapter-title">
                {{ displayChapterTitle(chapter, chapterIndex) }}
              </div>
              <button
                v-for="(section, sectionIndex) in chapter.sections || []"
                :key="section.id"
                class="directory-section"
                :class="{ 'is-active': currentSection?.id === section.id }"
                type="button"
                @click="selectSection(section.id)"
              >
                <span class="directory-order">{{ chapterIndex + 1 }}.{{ sectionIndex + 1 }}</span>
                <span class="directory-title">{{ displaySectionTitle(section, chapterIndex, sectionIndex) }}</span>
              </button>
            </div>
          </div>
        </div>
      </aside>
    </main>
  </div>
</template>

<script setup>
import { VideoPlay } from '@element-plus/icons-vue'
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPortalCourseDetail } from '@/api/course'
import { getPortalSectionMaterialList } from '@/api/sectionMaterial'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const course = ref({
  title: '',
  chapters: []
})
const sectionMaterials = ref([])

const chapters = computed(() => course.value.chapters || [])

const flattenedSections = computed(() =>
  chapters.value.flatMap((chapter, chapterIndex) =>
    (chapter.sections || []).map((section, sectionIndex) => ({
      ...section,
      chapterTitle: chapter.title,
      chapterIndex,
      sectionIndex
    }))
  )
)

const currentSectionId = computed(() => Number(route.params.sectionId) || null)

const currentSection = computed(
  () => flattenedSections.value.find((section) => section.id === currentSectionId.value) || null
)

const currentIndex = computed(() =>
  flattenedSections.value.findIndex((section) => section.id === currentSectionId.value)
)

const prevSection = computed(() =>
  currentIndex.value > 0 ? flattenedSections.value[currentIndex.value - 1] : null
)

const nextSection = computed(() =>
  currentIndex.value >= 0 && currentIndex.value < flattenedSections.value.length - 1
    ? flattenedSections.value[currentIndex.value + 1]
    : null
)

const currentChapterTitle = computed(() => {
  if (!currentSection.value) {
    return course.value.title || '章节详情'
  }
  return displayChapterTitle(
    { title: currentSection.value.chapterTitle },
    currentSection.value.chapterIndex
  )
})

const currentSectionTitle = computed(() => {
  if (!currentSection.value) {
    return '请选择小节'
  }
  return displaySectionTitle(
    currentSection.value,
    currentSection.value.chapterIndex,
    currentSection.value.sectionIndex
  )
})

function sectionTypeText(type) {
  return {
    1: '视频',
    2: '图文',
    3: '直播回放'
  }[type] || '课程内容'
}

function materialTypeText(type) {
  return {
    1: '文档',
    2: '压缩包',
    3: '图片',
    4: '其他'
  }[type] || '资料'
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

function selectSection(sectionId) {
  if (!sectionId) {
    return
  }
  router.push(`/member/courses/${route.params.id}/learn/sections/${sectionId}`)
}

async function fetchCourseDetail() {
  loading.value = true
  try {
    const { data } = await getPortalCourseDetail(route.params.id)
    course.value = data || { title: '', chapters: [] }
  } finally {
    loading.value = false
  }
}

async function fetchSectionMaterials() {
  if (!currentSectionId.value) {
    sectionMaterials.value = []
    return
  }
  const { data } = await getPortalSectionMaterialList(currentSectionId.value)
  sectionMaterials.value = data || []
}

watch(
  () => route.params.sectionId,
  () => {
    fetchSectionMaterials()
  }
)

onMounted(async () => {
  await fetchCourseDetail()
  await fetchSectionMaterials()
})
</script>

<style scoped>
.section-page {
  min-height: 100vh;
  background: #f5f7fb;
}

.section-topbar {
  height: 44px;
  padding: 0 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #3d5373;
  color: rgba(255, 255, 255, 0.9);
}

.back-link {
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font-size: 14px;
}

.topbar-title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 14px;
}

.section-shell {
  min-height: calc(100vh - 44px);
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 0;
}

.section-stage {
  padding: 28px 40px 22px;
  background: #fff;
}

.section-stage-head,
.block-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
}

.section-kicker {
  color: #409eff;
  font-size: 13px;
  font-weight: 700;
}

.section-stage-head h1,
.block-head h2 {
  margin: 8px 0 0;
  color: #1f2d3d;
}

.section-stage-head h1 {
  font-size: 24px;
}

.section-meta {
  display: flex;
  align-items: center;
  gap: 14px;
  color: #909399;
  font-size: 13px;
  white-space: nowrap;
}

.video-panel {
  margin-top: 26px;
}

.section-video {
  width: 100%;
  max-height: 520px;
  border-radius: 12px;
  background: #111827;
}

.video-placeholder {
  margin-top: 26px;
  min-height: 280px;
  border-radius: 12px;
  background: #fafafa;
  border: 1px dashed #e5e7eb;
  color: #909399;
  display: grid;
  place-items: center;
  text-align: center;
}

.video-placeholder .el-icon {
  font-size: 40px;
  margin-bottom: 10px;
}

.section-content-block {
  margin-top: 26px;
}

.section-content-block p {
  margin: 14px 0 0;
  color: #606266;
  line-height: 1.85;
  white-space: pre-wrap;
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
}

.material-title {
  color: #1f2d3d;
  font-size: 15px;
  font-weight: 700;
}

.material-sub,
.material-size {
  color: #909399;
  font-size: 13px;
}

.nav-row {
  margin-top: 34px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.right-directory {
  background: #fff;
  border-left: 1px solid #e5e7eb;
}

.directory-card {
  height: 100%;
  padding: 20px 0;
}

.directory-head {
  padding: 0 22px 16px;
  color: #1f2d3d;
  font-size: 20px;
  font-weight: 700;
}

.directory-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: calc(100vh - 120px);
  overflow: auto;
}

.directory-chapter {
  padding: 0 12px;
}

.directory-chapter-title {
  padding: 8px 10px;
  color: #303133;
  font-size: 15px;
  font-weight: 700;
}

.directory-section {
  width: 100%;
  padding: 10px 12px;
  border: 0;
  border-radius: 10px;
  background: transparent;
  display: flex;
  align-items: flex-start;
  gap: 10px;
  text-align: left;
  color: #606266;
  cursor: pointer;
}

.directory-section:hover,
.directory-section.is-active {
  background: #eef4ff;
  color: #1d4ed8;
}

.directory-order {
  min-width: 34px;
  font-size: 13px;
}

.directory-title {
  line-height: 1.55;
}

@media (max-width: 1080px) {
  .section-shell {
    grid-template-columns: 1fr;
  }

  .right-directory {
    border-left: 0;
    border-top: 1px solid #e5e7eb;
  }
}

@media (max-width: 640px) {
  .section-stage {
    padding: 18px 16px;
  }

  .section-stage-head,
  .block-head {
    flex-direction: column;
  }

  .nav-row {
    justify-content: stretch;
  }
}
</style>
