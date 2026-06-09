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
          @click="selectMenu(item.key)"
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
                <button class="chapter-head" type="button" @click="toggleChapter(chapter.id)">
                  <div class="chapter-head-main">
                    <el-icon class="chapter-toggle" :class="{ 'is-collapsed': !isChapterExpanded(chapter.id) }">
                      <ArrowDown />
                    </el-icon>
                    <h3>{{ displayChapterTitle(chapter, chapterIndex) }}</h3>
                  </div>
                </button>

                <div v-if="isChapterExpanded(chapter.id) && chapter.sections?.length" class="section-list">
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
                      <el-tag v-if="section.isFreeTrial === 1" size="small" effect="plain">试听</el-tag>
                    </div>
                  </button>
                </div>

                <el-empty
                  v-else-if="isChapterExpanded(chapter.id)"
                  description="暂无小节内容"
                  :image-size="60"
                />
              </article>
            </div>

            <el-empty v-else-if="!loading" description="暂无课程章节" :image-size="80" />
          </div>
        </template>

        <template v-else-if="activeMenu === 'assignments'">
          <div class="content-card">
            <div class="assignment-toolbar">
              <div class="assignment-filter">
                <span class="toolbar-label">筛选</span>
                <el-radio-group v-model="taskFilter" size="small">
                  <el-radio-button label="all">全部</el-radio-button>
                  <el-radio-button label="completed">已完成</el-radio-button>
                  <el-radio-button label="pending">未完成</el-radio-button>
                </el-radio-group>
              </div>
              <div class="assignment-progress">
                <el-progress
                  :percentage="taskProgressPercent"
                  :stroke-width="10"
                  :show-text="false"
                  color="#3b82f6"
                />
                <span>{{ completedAssignmentCount }}/{{ assignmentTasks.length }}</span>
              </div>
            </div>

            <div v-if="filteredAssignmentTasks.length" class="assignment-list">
              <article v-for="task in filteredAssignmentTasks" :key="task.id" class="assignment-card">
                <div class="assignment-main">
                  <div class="assignment-badge">作业</div>
                  <div class="assignment-copy">
                    <div class="assignment-title-row">
                      <h3>{{ task.title }}</h3>
                      <el-tag :type="taskStateMeta(task).type" effect="plain">
                        {{ taskStatusLabel(task) }}
                      </el-tag>
                    </div>
                    <div class="assignment-meta">
                      <span>开放时间 {{ formatDateTime(task.startTime) }}</span>
                      <span>截止时间 {{ formatDateTime(task.endTime) }}</span>
                      <span>{{ task.totalScore }} 分 / {{ task.questionCount }} 题</span>
                    </div>
                    <div class="assignment-actions">
                      <el-button type="primary" text @click="openTaskAnswer(task)">
                        {{ task.completed ? (task.canSubmit ? '再次作答' : '查看详情') : '开始答题' }}
                      </el-button>
                      <el-button v-if="task.completed" text @click="openTaskReview(task)">
                        解析分析
                      </el-button>
                    </div>
                  </div>
                </div>
                <div class="assignment-side">
                  <div class="assignment-side-item">
                    <span>得分</span>
                    <strong>{{ formatTaskScore(task) }}</strong>
                  </div>
                  <div class="assignment-side-item">
                    <span>已考次数</span>
                    <strong>{{ task.usedAttempts }}/1</strong>
                  </div>
                </div>
              </article>
            </div>

            <el-empty v-else description="当前筛选条件下暂无作业" :image-size="72" />
          </div>
        </template>

        <template v-else-if="activeMenu === 'exams'">
          <div class="content-card">
            <div class="assignment-toolbar">
              <div class="assignment-filter">
                <span class="toolbar-label">筛选</span>
                <el-radio-group v-model="taskFilter" size="small">
                  <el-radio-button label="all">全部</el-radio-button>
                  <el-radio-button label="completed">已完成</el-radio-button>
                  <el-radio-button label="pending">未完成</el-radio-button>
                </el-radio-group>
              </div>
              <div class="assignment-progress">
                <el-progress
                  :percentage="taskProgressPercent"
                  :stroke-width="10"
                  :show-text="false"
                  color="#3b82f6"
                />
                <span>{{ completedExamCount }}/{{ examTasks.length }}</span>
              </div>
            </div>

            <div v-if="filteredExamTasks.length" class="assignment-list">
              <article
                v-for="task in filteredExamTasks"
                :key="task.id"
                class="assignment-card"
              >
                <div class="assignment-main">
                  <div class="assignment-badge">考试</div>
                  <div class="assignment-copy">
                    <div class="assignment-title-row">
                      <h3>{{ task.title }}</h3>
                      <el-tag :type="taskStateMeta(task).type" effect="plain">
                        {{ taskStatusLabel(task) }}
                      </el-tag>
                    </div>
                    <div class="assignment-meta">
                      <span>开放时间 {{ formatDateTime(task.startTime) }}</span>
                      <span>截止时间 {{ formatDateTime(task.endTime) }}</span>
                      <span>总时长 {{ formatDurationMinutes(task.durationMinutes) }}</span>
                      <span>{{ task.totalScore }} 分 / {{ task.questionCount }} 题</span>
                    </div>
                    <div class="assignment-actions">
                      <el-button v-if="task.canSubmit" type="primary" text @click="openExamAnswer(task)">
                        {{ examActionLabel(task) }}
                      </el-button>
                      <el-button v-else text @click="openExamReview(task)">
                        查看详情
                      </el-button>
                    </div>
                  </div>
                </div>
                <div class="assignment-side">
                  <div class="assignment-side-item">
                    <span>得分</span>
                    <strong>{{ formatTaskScore(task) }}</strong>
                  </div>
                  <div class="assignment-side-item">
                    <span>剩余次数</span>
                    <strong>{{ task.remainingAttempts }}</strong>
                  </div>
                </div>
              </article>
            </div>

            <el-empty v-else description="当前筛选条件下暂无考试" :image-size="72" />
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

            <el-empty v-else description="当前课程暂无资料" :image-size="72" />
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
import { ArrowDown, Collection, Document, EditPen, Reading } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPortalCourseDetail, getPortalCourseMaterials } from '@/api/course'
import { getMemberCourseTaskList } from '@/api/memberTask'
import { getMemberCourseExamList } from '@/api/memberExam'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const activeMenu = ref('chapters')
const taskFilter = ref('all')
const expandedChapterIds = ref([])
const course = ref({
  title: '',
  coverUrl: '',
  chapters: []
})
const courseMaterials = ref([])
const memberTasks = ref([])
const memberExams = ref([])

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

const assignmentTasks = computed(() => memberTasks.value)
const examTasks = computed(() => memberExams.value)

const filteredAssignmentTasks = computed(() => filterTasksByStatus(assignmentTasks.value))
const filteredExamTasks = computed(() => filterTasksByStatus(examTasks.value))

const completedAssignmentCount = computed(() =>
  assignmentTasks.value.filter((task) => task.completed).length
)

const completedExamCount = computed(() =>
  examTasks.value.filter((task) => task.completed).length
)

const activeTaskCollection = computed(() => (
  activeMenu.value === 'exams' ? examTasks.value : assignmentTasks.value
))

const activeCompletedTaskCount = computed(() => (
  activeMenu.value === 'exams' ? completedExamCount.value : completedAssignmentCount.value
))

const taskProgressPercent = computed(() => {
  if (!activeTaskCollection.value.length) {
    return 0
  }
  return Math.round((activeCompletedTaskCount.value / activeTaskCollection.value.length) * 100)
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

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value)
    .replace('T', ' ')
    .replace(/\.\d+$/, '')
    .replace(/Z$/, '')
}

function formatDurationMinutes(value) {
  const totalMinutes = Number(value || 0)
  if (!totalMinutes) {
    return '--'
  }
  const hours = Math.floor(totalMinutes / 60)
  const minutes = totalMinutes % 60
  if (hours && minutes) {
    return `${hours} 小时 ${minutes} 分钟`
  }
  if (hours) {
    return `${hours} 小时`
  }
  return `${minutes} 分钟`
}

function buildExamStorageKey(taskId) {
  return `member_exam_session_${taskId}`
}

function formatSessionDateTime(date = new Date()) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

function parseSessionDateTime(value) {
  if (!value) {
    return null
  }
  const normalized = String(value).replace(' ', 'T')
  const date = new Date(normalized)
  return Number.isNaN(date.getTime()) ? null : date
}

function readExamSession(taskId) {
  return localStorage.getItem(buildExamStorageKey(taskId)) || ''
}

function saveExamSession(taskId, startedAt) {
  localStorage.setItem(buildExamStorageKey(taskId), startedAt)
}

function clearExamSession(taskId) {
  localStorage.removeItem(buildExamStorageKey(taskId))
}

function isExamSessionActive(task) {
  const startedAt = parseSessionDateTime(readExamSession(task.id))
  if (!startedAt) {
    return false
  }
  const expiresAt = startedAt.getTime() + Number(task.durationMinutes || 0) * 60 * 1000
  return Date.now() < expiresAt
}

function cleanupExamSessions(tasks) {
  for (const task of tasks) {
    if (task.completed || !isExamSessionActive(task)) {
      clearExamSession(task.id)
    }
  }
}

function filterTasksByStatus(tasks) {
  if (taskFilter.value === 'completed') {
    return tasks.filter((task) => task.completed)
  }
  if (taskFilter.value === 'pending') {
    return tasks.filter((task) => !task.completed)
  }
  return tasks
}

function taskStateMeta(task) {
  if (task.completed && task.latestReviewStatus === 0) {
    return { label: '待批改', type: 'warning' }
  }
  if (task.completed && task.latestReviewStatus === 1) {
    return { label: '已完成', type: 'success' }
  }
  const now = Date.now()
  const startTime = task.startTime ? new Date(task.startTime).getTime() : null
  const endTime = task.endTime ? new Date(task.endTime).getTime() : null
  if (startTime && now < startTime) {
    return { label: '未开始', type: 'warning' }
  }
  if (endTime && now > endTime && !isExamSessionActive(task)) {
    return { label: '已截止', type: 'danger' }
  }
  if (!task.canSubmit && task.remainingAttempts <= 0) {
    return { label: '次数已用完', type: 'info' }
  }
  return { label: '待完成', type: 'info' }
}

function taskStatusLabel(task) {
  return task.completed ? taskStateMeta(task).label || '已完成' : taskStateMeta(task).label
}

function formatTaskScore(task) {
  if (!task.completed) {
    return '--'
  }
  if (task.latestReviewStatus === 0) {
    return '待批改'
  }
  return `${task.latestScore ?? 0} / ${task.totalScore}`
}

function examActionLabel(task) {
  if (!task.canSubmit) {
    return '查看详情'
  }
  if (isExamSessionActive(task)) {
    return '继续考试'
  }
  return '进入考试'
}

function displayChapterTitle(chapter, chapterIndex) {
  const title = String(chapter?.title || '').trim()
  if (!title) {
    return `第 ${chapterIndex + 1} 章`
  }
  return title.replace(/^\s*章节\s*\d+\s*[:：]?\s*/i, '')
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
    /^第\s*\d+\s*节\s*[:：]?\s*/
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

function openSection(sectionId) {
  router.push(`/member/courses/${route.params.id}/learn/sections/${sectionId}`)
}

function selectMenu(key) {
  activeMenu.value = key
  router.replace({
    path: `/member/courses/${route.params.id}/learn`,
    query: { ...route.query, tab: key }
  })
}

function openTaskAnswer(task) {
  const query = task.canSubmit ? { mode: 'answer' } : { mode: 'review' }
  router.push({
    path: `/member/courses/${route.params.id}/learn/tasks/${task.id}`,
    query
  })
}

function openTaskReview(task) {
  router.push({
    path: `/member/courses/${route.params.id}/learn/tasks/${task.id}`,
    query: { mode: 'review' }
  })
}

async function openExamAnswer(task) {
  if (!task.canSubmit) {
    openExamReview(task)
    return
  }

  const existingStartedAt = isExamSessionActive(task) ? readExamSession(task.id) : ''
  const startedAt = existingStartedAt || formatSessionDateTime()

  await ElMessageBox.confirm(
    `确认进入考试吗？总时长 ${formatDurationMinutes(task.durationMinutes)}。${existingStartedAt ? '当前将继续上次计时。' : '进入后将立即开始计时。'}`,
    '进入考试',
    { type: 'warning' }
  )

  saveExamSession(task.id, startedAt)
  router.push({
    path: `/member/courses/${route.params.id}/learn/exams/${task.id}`,
    query: {
      mode: 'answer',
      startedAt
    }
  })
}

function openExamReview(task) {
  clearExamSession(task.id)
  router.push({
    path: `/member/courses/${route.params.id}/learn/exams/${task.id}`,
    query: { mode: 'review' }
  })
}

async function fetchCourseDetail() {
  loading.value = true
  try {
    const { data } = await getPortalCourseDetail(route.params.id)
    course.value = data || { title: '', coverUrl: '', chapters: [] }
    expandAllChapters()
    if (!course.value.enrolled) {
      ElMessage.warning('请先报名课程后再开始学习')
      router.replace(`/member/courses/${route.params.id}`)
      return false
    }
    return true
  } finally {
    loading.value = false
  }
}

async function fetchCourseMaterials() {
  const { data } = await getPortalCourseMaterials(route.params.id)
  courseMaterials.value = data || []
}

async function fetchMemberTasks() {
  const { data } = await getMemberCourseTaskList(route.params.id)
  memberTasks.value = data || []
}

async function fetchMemberExams() {
  const { data } = await getMemberCourseExamList(route.params.id)
  memberExams.value = data || []
  cleanupExamSessions(memberExams.value)
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function goProfile() {
  router.push('/member/profile')
}

watch(
  () => route.query.tab,
  (value) => {
    const menuKey = String(value || 'chapters')
    activeMenu.value = menuItems.some((item) => item.key === menuKey) ? menuKey : 'chapters'
  },
  { immediate: true }
)

onMounted(async () => {
  const allowed = await fetchCourseDetail()
  if (allowed) {
    await Promise.all([fetchCourseMaterials(), fetchMemberTasks(), fetchMemberExams()])
  }
})
</script>

<style scoped>
.learn-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top, rgba(64, 158, 255, 0.16), transparent 34%),
    linear-gradient(180deg, #f6f9fd 0%, #edf3fb 100%);
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
  width: 100%;
  border: 0;
  padding: 14px 16px;
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

.assignment-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.assignment-filter {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.toolbar-label {
  color: #909399;
  font-size: 13px;
}

.assignment-progress {
  width: min(340px, 100%);
  display: flex;
  align-items: center;
  gap: 12px;
}

.assignment-progress span {
  color: #606266;
  font-size: 14px;
  white-space: nowrap;
}

.assignment-list {
  margin-top: 14px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.assignment-card {
  padding: 14px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
}

.assignment-main {
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 14px;
}

.assignment-badge {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  background: #e5e7eb;
  color: #6b7280;
  display: grid;
  place-items: center;
  font-size: 12px;
  font-weight: 700;
  flex-shrink: 0;
}

.assignment-copy {
  min-width: 0;
}

.assignment-title-row {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.assignment-title-row h3 {
  margin: 0;
  color: #1f2d3d;
  font-size: 16px;
}

.assignment-meta {
  margin-top: 6px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  color: #909399;
  font-size: 12px;
}

.assignment-actions {
  margin-top: 6px;
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.assignment-side {
  min-width: 132px;
  padding-left: 16px;
  border-left: 1px solid #eef2f7;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 12px;
}

.assignment-side-item span {
  display: block;
  color: #909399;
  font-size: 12px;
}

.assignment-side-item strong {
  display: block;
  margin-top: 6px;
  color: #1f2d3d;
  font-size: 18px;
  line-height: 1;
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

@media (max-width: 1100px) {
  .assignment-card {
    flex-direction: column;
    align-items: stretch;
  }

  .assignment-side {
    min-width: 0;
    padding-left: 0;
    padding-top: 12px;
    border-left: 0;
    border-top: 1px solid #eef2f7;
    flex-direction: row;
    justify-content: flex-start;
    gap: 20px;
  }
}

@media (max-width: 960px) {
  .learn-shell {
    grid-template-columns: 1fr;
  }

  .left-menu {
    position: static;
  }

  .block-head,
  .assignment-toolbar {
    flex-direction: column;
    align-items: stretch;
  }

  .assignment-progress {
    width: 100%;
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

  .chapter-head {
    padding: 12px 14px;
  }

  .assignment-card {
    padding: 14px;
  }

  .assignment-main {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
}
</style>
