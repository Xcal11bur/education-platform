<template>
  <div class="section-page">
    <header class="section-topbar">
      <button class="back-link" type="button" @click="router.push(`/member/courses/${route.params.id}/learn`)">
        返回课程
      </button>
      <div class="topbar-title">章节详情</div>
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
    </header>

    <main class="section-shell" v-loading="loading">
      <section class="section-stage">
        <div class="section-stage-head">
          <div>
            <div class="section-kicker">{{ currentChapterTitle }}</div>
            <h1>{{ currentSectionTitle }}</h1>
          </div>
        </div>

        <div class="section-content-block">
          <div v-if="renderedContentItems.length" class="content-item-list">
            <section
              v-for="item in renderedContentItems"
              :key="item.id"
              class="content-item-card"
            >
              <div class="content-item-head">
                <h3>{{ item.title }}</h3>
                <span>{{ item.contentType }}</span>
              </div>

              <div v-if="item.contentType === 'VIDEO' && item.fileUrl" class="video-panel">
                <video class="section-video" :src="item.fileUrl" controls preload="metadata"></video>
              </div>

              <iframe
                v-else-if="item.contentType === 'PDF' && item.fileUrl"
                class="pdf-frame"
                :src="pdfPreviewUrls[item.id]"
                title="PDF 预览"
              ></iframe>

              <img
                v-else-if="item.contentType === 'IMAGE' && item.fileUrl"
                class="image-content"
                :src="item.fileUrl"
                :alt="item.title"
              />

              <div
                v-else-if="item.contentType === 'RICH_TEXT' && item.contentHtml"
                class="rich-content"
                v-html="item.contentHtml"
              ></div>

              <a
                v-else-if="item.fileUrl"
                class="material-card inline-file-card"
                :href="item.fileUrl"
                target="_blank"
                rel="noreferrer"
              >
                <div>
                  <div class="material-title">{{ item.title }}</div>
                  <div class="material-sub">{{ item.contentType }}</div>
                </div>
                <div class="material-size">{{ formatFileSize(item.fileSize) }}</div>
              </a>
            </section>
          </div>

          <el-empty
            v-else
            description="暂无内容"
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
                :class="{
                  'is-active': currentSection?.id === section.id,
                  'is-locked': !canAccessSection(section)
                }"
                type="button"
                :disabled="!canAccessSection(section)"
                @click="selectSection(section.id)"
              >
                <span class="directory-order">{{ chapterIndex + 1 }}.{{ sectionIndex + 1 }}</span>
                <span class="directory-title">{{ displaySectionTitle(section, chapterIndex, sectionIndex) }}</span>
                <el-icon v-if="!canAccessSection(section)" class="directory-lock"><Lock /></el-icon>
              </button>
            </div>
          </div>
        </div>
      </aside>
    </main>
  </div>
</template>

<script setup>
import { Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPortalCourseDetail } from '@/api/course'
import { getPortalSectionContentList, getPortalSectionContentPreview } from '@/api/sectionContent'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const course = ref({
  title: '',
  chapters: [],
  enrolled: false
})
const sectionContents = ref([])
const pdfPreviewUrls = ref({})

const chapters = computed(() => course.value.chapters || [])

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')

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

const accessibleSections = computed(() =>
  flattenedSections.value.filter((section) => canAccessSection(section))
)

const currentSectionId = computed(() => Number(route.params.sectionId) || null)

const currentSection = computed(
  () => flattenedSections.value.find((section) => section.id === currentSectionId.value) || null
)

const currentIndex = computed(() =>
  accessibleSections.value.findIndex((section) => section.id === currentSectionId.value)
)

const prevSection = computed(() =>
  currentIndex.value > 0 ? accessibleSections.value[currentIndex.value - 1] : null
)

const nextSection = computed(() =>
  currentIndex.value >= 0 && currentIndex.value < accessibleSections.value.length - 1
    ? accessibleSections.value[currentIndex.value + 1]
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

const renderedContentItems = computed(() => {
  if (sectionContents.value.length) {
    return sectionContents.value
  }
  return []
})

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
  const section = flattenedSections.value.find((item) => item.id === sectionId)
  if (!canAccessSection(section)) {
    ElMessage.warning('请先报名课程后再学习该章节')
    return
  }
  router.push(`/member/courses/${route.params.id}/learn/sections/${sectionId}`)
}

function canAccessSection(section) {
  if (!section) {
    return false
  }
  return course.value.enrolled === true || section.isFreeTrial === 1
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
    course.value = data || { title: '', chapters: [] }
    const targetSection = flattenedSections.value.find((section) => section.id === currentSectionId.value)
    if (!targetSection) {
      ElMessage.warning('当前章节不存在')
      router.replace(`/member/courses/${route.params.id}`)
      return false
    }
    if (!canAccessSection(targetSection)) {
      ElMessage.warning('请先报名课程后再学习该章节')
      router.replace(`/member/courses/${route.params.id}`)
      return false
    }
    return true
  } finally {
    loading.value = false
  }
}

async function fetchSectionContents() {
  if (!currentSectionId.value || !canAccessSection(currentSection.value)) {
    sectionContents.value = []
    revokePdfPreviewUrls()
    return
  }
  const { data } = await getPortalSectionContentList(currentSectionId.value)
  sectionContents.value = data || []
  await loadPdfPreviews(sectionContents.value)
}

function revokePdfPreviewUrls() {
  Object.values(pdfPreviewUrls.value).forEach((url) => {
    if (url) {
      URL.revokeObjectURL(url)
    }
  })
  pdfPreviewUrls.value = {}
}

async function loadPdfPreviews(items) {
  revokePdfPreviewUrls()
  const pdfItems = items.filter((item) => item.contentType === 'PDF' && item.fileUrl && item.id)
  const entries = await Promise.all(
    pdfItems.map(async (item) => {
      const blob = await getPortalSectionContentPreview(item.id)
      return [item.id, `${URL.createObjectURL(blob)}#toolbar=1&navpanes=0&view=FitH`]
    })
  )
  pdfPreviewUrls.value = Object.fromEntries(entries)
}

watch(
  () => route.params.sectionId,
  () => {
    fetchSectionContents()
  }
)

onMounted(async () => {
  const allowed = await fetchCourseDetail()
  if (allowed) {
    await fetchSectionContents()
  }
})

onBeforeUnmount(() => {
  revokePdfPreviewUrls()
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

.profile-entry {
  border: 1px solid rgba(255, 255, 255, 0.24);
  background: rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  padding: 5px 10px;
  display: flex;
  align-items: center;
  gap: 10px;
  color: #fff;
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
  color: #fff;
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

.section-video {
  width: 100%;
  max-height: 520px;
  border-radius: 12px;
  background: #111827;
}

.section-content-block {
  margin-top: 26px;
}

.content-item-list {
  margin-top: 16px;
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.content-item-card {
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  padding: 18px;
  background: #fff;
}

.content-item-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 14px;
}

.content-item-head h3 {
  margin: 0;
  color: #1f2d3d;
  font-size: 18px;
}

.content-item-head span {
  color: #909399;
  font-size: 12px;
  letter-spacing: 0.06em;
}

.pdf-frame {
  width: 100%;
  min-height: 560px;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  background: #fff;
}

.image-content {
  display: block;
  max-width: 100%;
  border-radius: 12px;
}

.rich-content {
  margin-top: 14px;
  color: #303133;
  line-height: 1.9;
}

.rich-content :deep(h1),
.rich-content :deep(h2),
.rich-content :deep(h3) {
  margin: 18px 0 10px;
  color: #1f2d3d;
}

.rich-content :deep(p) {
  margin: 10px 0;
}

.rich-content :deep(ul),
.rich-content :deep(ol) {
  margin: 10px 0;
  padding-left: 22px;
}

.rich-content :deep(blockquote) {
  margin: 14px 0;
  padding: 10px 14px;
  border-left: 4px solid #bfdbfe;
  background: #f8fbff;
  color: #475569;
}

.rich-content :deep(img) {
  max-width: 100%;
  border-radius: 10px;
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
  gap: 8px;
  max-height: calc(100vh - 120px);
  overflow: auto;
}

.directory-chapter {
  padding: 0 12px;
}

.directory-chapter-title {
  padding: 6px 10px;
  color: #303133;
  font-size: 15px;
  font-weight: 700;
}

.directory-section {
  width: 100%;
  padding: 8px 10px;
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

.directory-section.is-locked {
  color: #a8abb2;
  cursor: not-allowed;
}

.directory-section.is-locked:hover {
  background: transparent;
  color: #a8abb2;
}

.directory-order {
  min-width: 34px;
  font-size: 13px;
}

.directory-title {
  line-height: 1.55;
  flex: 1;
}

.directory-lock {
  margin-top: 2px;
  font-size: 13px;
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
