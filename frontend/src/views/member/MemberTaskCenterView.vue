<template>
  <div class="task-center-page">
    <header class="topbar">
      <button class="brand-block" type="button" @click="router.push('/member-home')">
        <img class="brand-logo" :src="brandLogo" alt="教育云平台 logo" />
        <div class="brand-title">教育云平台</div>
      </button>

      <el-menu
        :default-active="activeNav"
        mode="horizontal"
        class="topnav"
        @select="handleNavSelect"
      >
        <el-menu-item
          v-for="item in navItems"
          :key="item.key"
          :index="item.key"
        >
          {{ item.label }}
        </el-menu-item>
      </el-menu>

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

    <main class="task-center-main">
      <section class="hero-panel">
        <div>
          <h1>我的任务</h1>
        </div>

        <div class="hero-stats">
          <article v-for="item in stats" :key="item.key" class="stat-card">
            <span>{{ item.label }}</span>
            <strong>{{ item.value }}</strong>
          </article>
        </div>
      </section>

      <section class="filter-panel">
        <el-select v-model="typeFilter" class="filter-select" placeholder="任务类型">
          <el-option label="全部类型" value="all" />
          <el-option label="作业" value="TASK" />
          <el-option label="考试" value="EXAM" />
        </el-select>
        <el-select v-model="statusFilter" class="filter-select" placeholder="任务状态">
          <el-option label="全部状态" value="all" />
          <el-option label="未开始" value="not_started" />
          <el-option label="待完成" value="pending" />
          <el-option label="进行中" value="in_progress" />
          <el-option label="待批改" value="reviewing" />
          <el-option label="已完成" value="completed" />
          <el-option label="已截止" value="expired" />
        </el-select>
        <el-select v-model="courseFilter" class="filter-select course-filter" placeholder="所属课程" clearable>
          <el-option label="全部课程" value="all" />
          <el-option
            v-for="course in courseOptions"
            :key="course.courseId"
            :label="course.courseTitle"
            :value="String(course.courseId)"
          />
        </el-select>
      </section>

      <section class="list-panel" v-loading="loading">
        <div class="panel-head">
          <div>
            <h2>任务列表</h2>
          </div>
        </div>

        <div v-if="filteredTasks.length" class="task-list">
          <article
            v-for="item in pagedTasks"
            :key="`${item.type}-${item.id}`"
            class="task-card"
          >
            <div class="task-card-main">
              <div class="task-type-badge" :class="item.type === 'EXAM' ? 'is-exam' : 'is-task'">
                {{ item.type === 'EXAM' ? '考试' : '作业' }}
              </div>

              <div class="task-copy">
                <div class="task-title-row">
                  <h3>{{ item.title }}</h3>
                  <el-tag :type="taskStateMeta(item).type" effect="plain">
                    {{ taskStateMeta(item).label }}
                  </el-tag>
                </div>

                <div class="task-course">{{ item.courseTitle || '未命名课程' }}</div>

                <div class="task-meta">
                  <span>开放时间 {{ formatDateTime(item.startTime) }}</span>
                  <span>截止时间 {{ formatDateTime(item.endTime) }}</span>
                  <span>{{ item.totalScore ?? 0 }} 分 / {{ item.questionCount ?? 0 }} 题</span>
                  <span v-if="item.type === 'EXAM'">总时长 {{ formatDurationMinutes(item.durationMinutes) }}</span>
                </div>

                <div class="task-actions">
                  <el-button
                    type="primary"
                    text
                    @click="openTask(item)"
                  >
                    {{ actionLabel(item) }}
                  </el-button>
                  <el-button
                    text
                    @click="router.push(`/member/courses/${item.courseId}`)"
                  >
                    查看课程
                  </el-button>
                </div>
              </div>
            </div>

            <div class="task-side">
              <div class="task-side-item">
                <span>得分</span>
                <strong>{{ formatTaskScore(item) }}</strong>
              </div>
              <div v-if="item.type !== 'EXAM'" class="task-side-item">
                <span>剩余次数</span>
                <strong>{{ item.remainingAttempts ?? 0 }}</strong>
              </div>
              <div class="task-side-item">
                <span>最近提交</span>
                <strong class="submitted-at">{{ formatCompactDateTime(item.latestSubmittedAt) }}</strong>
              </div>
            </div>
          </article>
        </div>

        <div v-if="filteredTasks.length" class="task-pagination">
          <el-pagination
            v-model:current-page="pageNum"
            v-model:page-size="pageSize"
            :total="filteredTasks.length"
            :page-sizes="[8, 12, 16, 24]"
            layout="total, sizes, prev, pager, next, jumper"
            background
            @size-change="handlePageSizeChange"
          />
        </div>

        <el-empty
          v-else-if="!loading"
          description="当前筛选条件下暂无任务"
          :image-size="90"
        />
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { getMemberTaskCenterList } from '@/api/memberTaskCenter'
import brandLogo from '@/assets/education-cloud-logo.jpg'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const taskItems = ref([])
const typeFilter = ref('all')
const statusFilter = ref('all')
const courseFilter = ref('all')
const pageNum = ref(1)
const pageSize = ref(8)

const navItems = [
  { key: 'home', label: '首页' },
  { key: 'courses', label: '课程学习' },
  { key: 'tasks', label: '我的任务' },
  { key: 'community', label: '交流社区' }
]

const activeNav = computed(() => {
  if (route.path.startsWith('/member/tasks')) {
    return 'tasks'
  }
  if (route.path.startsWith('/member/courses')) {
    return 'courses'
  }
  return 'home'
})

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')

const stats = computed(() => {
  const items = taskItems.value
  return [
    { key: 'all', label: '全部任务', value: items.length },
    { key: 'pending', label: '待完成', value: items.filter((item) => taskStateKey(item) === 'pending').length },
    { key: 'reviewing', label: '待批改', value: items.filter((item) => taskStateKey(item) === 'reviewing').length },
    { key: 'completed', label: '已完成', value: items.filter((item) => taskStateKey(item) === 'completed').length },
    { key: 'dueSoon', label: '即将截止', value: items.filter(isDueSoon).length }
  ]
})

const courseOptions = computed(() => {
  const map = new Map()
  for (const item of taskItems.value) {
    if (!map.has(item.courseId)) {
      map.set(item.courseId, {
        courseId: item.courseId,
        courseTitle: item.courseTitle || '未命名课程'
      })
    }
  }
  return Array.from(map.values()).sort((a, b) => a.courseTitle.localeCompare(b.courseTitle, 'zh-CN'))
})

const filteredTasks = computed(() => {
  return taskItems.value.filter((item) => {
    if (typeFilter.value !== 'all' && item.type !== typeFilter.value) {
      return false
    }
    if (statusFilter.value !== 'all' && taskStateKey(item) !== statusFilter.value) {
      return false
    }
    if (courseFilter.value && courseFilter.value !== 'all' && String(item.courseId) !== courseFilter.value) {
      return false
    }
    return true
  })
})

const pagedTasks = computed(() => {
  const start = (pageNum.value - 1) * pageSize.value
  return filteredTasks.value.slice(start, start + pageSize.value)
})

function handleNavSelect(key) {
  const routeMap = {
    home: '/member-home',
    courses: '/member/courses',
    tasks: '/member/tasks'
  }
  if (routeMap[key]) {
    router.push(routeMap[key])
  }
}

function handlePageSizeChange() {
  pageNum.value = 1
}

function goProfile() {
  router.push('/member/profile')
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '')
}

function formatCompactDateTime(value) {
  const normalized = formatDateTime(value)
  return normalized === '--' ? normalized : normalized.slice(0, 16)
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

function parseDate(value) {
  if (!value) {
    return null
  }
  const date = new Date(String(value).replace(' ', 'T'))
  return Number.isNaN(date.getTime()) ? null : date
}

function buildExamStorageKey(taskId) {
  return `member_exam_session_${taskId}`
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
  const date = new Date(String(value).replace(' ', 'T'))
  return Number.isNaN(date.getTime()) ? null : date
}

function isExamSessionActive(item) {
  if (item.type !== 'EXAM') {
    return false
  }
  const startedAt = parseSessionDateTime(readExamSession(item.id))
  if (!startedAt) {
    return false
  }
  const expiresAt = startedAt.getTime() + Number(item.durationMinutes || 0) * 60 * 1000
  return Date.now() < expiresAt
}

function taskStateKey(item) {
  if (item.completed && item.latestReviewStatus === 0) {
    return 'reviewing'
  }
  if (item.completed) {
    return 'completed'
  }

  const now = Date.now()
  const startTime = parseDate(item.startTime)?.getTime()
  const endTime = parseDate(item.endTime)?.getTime()

  if (startTime && now < startTime) {
    return 'not_started'
  }
  if (item.type === 'EXAM' && isExamSessionActive(item)) {
    return 'in_progress'
  }
  if (endTime && now > endTime && !(item.type === 'EXAM' && isExamSessionActive(item))) {
    return 'expired'
  }
  return 'pending'
}

function taskStateMeta(item) {
  return {
    not_started: { label: '未开始', type: 'warning' },
    pending: { label: '待完成', type: 'info' },
    in_progress: { label: '进行中', type: 'primary' },
    reviewing: { label: '待批改', type: 'warning' },
    completed: { label: '已完成', type: 'success' },
    expired: { label: '已截止', type: 'danger' }
  }[taskStateKey(item)] || { label: '待完成', type: 'info' }
}

function formatTaskScore(item) {
  if (!item.completed) {
    return '--'
  }
  if (item.latestReviewStatus === 0) {
    return '待批改'
  }
  return `${item.latestScore ?? 0} / ${item.totalScore ?? 0}`
}

function isDueSoon(item) {
  if (item.completed) {
    return false
  }
  const endTime = parseDate(item.endTime)
  if (!endTime) {
    return false
  }
  const diff = endTime.getTime() - Date.now()
  return diff > 0 && diff <= 24 * 60 * 60 * 1000
}

function actionLabel(item) {
  if (item.type === 'EXAM') {
    if (!item.canSubmit) {
      return '查看详情'
    }
    return isExamSessionActive(item) ? '继续考试' : '进入考试'
  }
  if (!item.canSubmit) {
    return '查看详情'
  }
  return item.completed ? '再次作答' : '开始答题'
}

function openTaskReview(item) {
  const path = item.type === 'EXAM'
    ? `/member/courses/${item.courseId}/learn/exams/${item.id}`
    : `/member/courses/${item.courseId}/learn/tasks/${item.id}`

  if (item.type === 'EXAM') {
    clearExamSession(item.id)
  }

  router.push({
    path,
    query: { mode: 'review' }
  })
}

async function openExamAnswer(item) {
  const existingStartedAt = isExamSessionActive(item) ? readExamSession(item.id) : ''
  const startedAt = existingStartedAt || formatSessionDateTime()

  await ElMessageBox.confirm(
    `确认进入考试吗？总时长 ${formatDurationMinutes(item.durationMinutes)}。${existingStartedAt ? '当前将继续上次计时。' : '进入后将立即开始计时。'}`,
    '进入考试',
    { type: 'warning' }
  )

  saveExamSession(item.id, startedAt)
  router.push({
    path: `/member/courses/${item.courseId}/learn/exams/${item.id}`,
    query: {
      mode: 'answer',
      startedAt
    }
  })
}

async function openTask(item) {
  if (item.type === 'EXAM') {
    if (!item.canSubmit) {
      openTaskReview(item)
      return
    }
    await openExamAnswer(item)
    return
  }

  router.push({
    path: `/member/courses/${item.courseId}/learn/tasks/${item.id}`,
    query: { mode: item.canSubmit ? 'answer' : 'review' }
  })
}

async function fetchTaskCenterList() {
  loading.value = true
  try {
    const { data } = await getMemberTaskCenterList()
    taskItems.value = data || []
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await Promise.all([authStore.fetchProfile(), fetchTaskCenterList()])
})

watch([typeFilter, statusFilter, courseFilter], () => {
  pageNum.value = 1
})

watch(filteredTasks, (items) => {
  const maxPage = Math.max(1, Math.ceil(items.length / pageSize.value))
  if (pageNum.value > maxPage) {
    pageNum.value = maxPage
  }
})
</script>

<style scoped>
.task-center-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(15, 23, 42, 0.04), transparent 26%),
    linear-gradient(180deg, #f7f8fa 0%, #f2f4f7 100%);
  color: #303133;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 0 32px;
  height: 64px;
  background: rgba(255, 255, 255, 0.88);
  border-bottom: 1px solid rgba(220, 223, 230, 0.9);
  backdrop-filter: blur(14px);
}

.brand-block {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
  border: 0;
  background: transparent;
  cursor: pointer;
  padding: 0;
}

.brand-logo {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  object-fit: cover;
}

.brand-title {
  font-size: 20px;
  font-weight: 700;
  color: #1f2d3d;
}

.topnav {
  flex: 1;
  border-bottom: 0;
  justify-content: center;
  min-width: 0;
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

.task-center-main {
  width: min(1320px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 28px 0 40px;
}

.hero-panel,
.filter-panel,
.list-panel {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(220, 223, 230, 0.92);
  border-radius: 18px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.hero-panel {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
  padding: 22px 28px;
}

.hero-panel h1 {
  margin: 0;
  font-size: clamp(28px, 4vw, 38px);
  color: #1f2d3d;
}

.hero-stats {
  display: grid;
  grid-template-columns: repeat(5, minmax(110px, 1fr));
  gap: 12px;
  min-width: min(100%, 640px);
}

.stat-card {
  padding: 14px 16px;
  border-radius: 16px;
  background: linear-gradient(180deg, #f8fbff 0%, #eef5ff 100%);
  border: 1px solid #dbeafe;
}

.stat-card span {
  display: block;
  color: #64748b;
  font-size: 12px;
}

.stat-card strong {
  display: block;
  margin-top: 6px;
  color: #1d4ed8;
  font-size: 24px;
  line-height: 1;
}

.filter-panel {
  margin-top: 18px;
  padding: 18px 22px;
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
}

.filter-select {
  width: 160px;
}

.course-filter {
  width: 280px;
}

.list-panel {
  margin-top: 18px;
  padding: 22px;
}

.panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding-bottom: 14px;
  border-bottom: 1px solid #ebeef5;
}

.panel-head h2 {
  margin: 0;
  font-size: 24px;
  color: #1f2d3d;
}

.task-list {
  margin-top: 18px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.task-card {
  padding: 14px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.task-card-main {
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 14px;
}

.task-type-badge {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: grid;
  place-items: center;
  font-size: 12px;
  font-weight: 700;
  flex-shrink: 0;
}

.task-type-badge.is-task {
  background: #eff6ff;
  color: #1d4ed8;
}

.task-type-badge.is-exam {
  background: #fff7ed;
  color: #c2410c;
}

.task-copy {
  min-width: 0;
}

.task-title-row {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.task-title-row h3 {
  margin: 0;
  color: #1f2d3d;
  font-size: 17px;
}

.task-course {
  margin-top: 6px;
  color: #409eff;
  font-size: 13px;
  font-weight: 600;
}

.task-meta {
  margin-top: 6px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  color: #909399;
  font-size: 12px;
}

.task-actions {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.task-side {
  min-width: 170px;
  padding-left: 16px;
  border-left: 1px solid #eef2f7;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.task-side-item span {
  display: block;
  color: #909399;
  font-size: 12px;
}

.task-side-item strong {
  display: block;
  margin-top: 4px;
  color: #1f2d3d;
  font-size: 16px;
  line-height: 1.2;
}

.task-side-item .submitted-at {
  font-size: 13px;
}

.task-pagination {
  margin-top: 18px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 1180px) {
  .hero-panel {
    flex-direction: column;
  }

  .hero-stats {
    width: 100%;
    min-width: 0;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .task-card {
    flex-direction: column;
    align-items: stretch;
  }

  .task-side {
    min-width: 0;
    padding-left: 0;
    padding-top: 14px;
    border-left: 0;
    border-top: 1px solid #eef2f7;
    flex-direction: row;
    justify-content: flex-start;
    flex-wrap: wrap;
    gap: 20px;
  }
}

@media (max-width: 900px) {
  .topbar {
    flex-wrap: wrap;
    height: auto;
    padding: 10px 18px;
  }

  .topnav {
    width: 100%;
  }

  .task-center-main {
    width: min(100vw - 24px, 1320px);
    padding-top: 18px;
  }
}

@media (max-width: 640px) {
  .hero-panel,
  .list-panel {
    padding: 18px 16px;
  }

  .filter-panel {
    padding: 16px;
  }

  .filter-select,
  .course-filter {
    width: 100%;
  }

  .hero-stats {
    grid-template-columns: 1fr;
  }

  .task-card {
    padding: 14px;
  }

  .task-card-main {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
