<template>
  <div class="task-page">
    <header class="task-topbar">
      <button class="back-link" type="button" @click="goBack">返回课程</button>
      <div class="topbar-title">{{ pageTitle }}</div>
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

    <main class="task-shell" v-loading="loading">
      <section class="task-stage">
        <div class="task-stage-head">
          <div>
            <div class="task-kicker">{{ taskDetail?.courseTitle || '--' }}</div>
            <h1>{{ taskDetail?.title || pageTitle }}</h1>
          </div>
          <div class="task-head-actions">
            <div
              v-if="taskDetail?.submitted && taskDetail?.latestSubmission?.reviewStatus === 1"
              class="task-score-panel"
              :class="scoreStatusClass"
            >
              <span class="task-score-label">{{ scoreStatusText }}</span>
              <strong class="task-score-value">
                {{ taskDetail.latestSubmission.score ?? 0 }} / {{ taskDetail.totalScore ?? 0 }}
              </strong>
            </div>
            <el-tag :type="pageStatus.type" effect="plain">
              {{ pageStatus.label }}
            </el-tag>
          </div>
        </div>

        <div class="task-meta-row">
          <span>{{ sceneLabel }}时间：{{ formatDateTime(taskDetail?.startTime) }} 至 {{ formatDateTime(taskDetail?.endTime) }}</span>
          <span>总分 {{ taskDetail?.totalScore ?? 0 }}</span>
          <span>及格 {{ taskDetail?.passScore ?? 0 }}</span>
          <span v-if="isExamScene">时长 {{ formatDurationMinutes(taskDetail?.durationMinutes) }}</span>
          <span v-else>剩余次数 {{ taskDetail?.remainingAttempts ?? 0 }}</span>
        </div>

        <div
          v-if="!isAnswerMode && taskDetail?.latestSubmission?.reviewComment"
          class="task-review-comment-card"
        >
          <div class="task-review-comment-title">教师评语</div>
          <div class="task-review-comment-content">{{ taskDetail.latestSubmission.reviewComment }}</div>
        </div>

        <div class="question-section">
          <section
            v-for="(question, index) in taskDetail?.questions || []"
            :id="`question-${question.id}`"
            :key="question.id"
            class="question-card"
          >
            <div class="question-head">
              <div class="question-title">
                {{ index + 1 }}.
                <span class="question-type">({{ questionTypeText(question.questionType) }}，{{ question.score }} 分)</span>
                {{ question.stem }}
              </div>
            </div>

            <div class="question-options">
              <template v-if="isAnswerMode && question.questionType !== 4">
                <el-radio-group
                  v-model="answerMap[question.id]"
                  class="question-radio-group"
                  :disabled="isAnswerLocked"
                >
                  <div
                    v-for="option in parseOptions(question.optionsJson)"
                    :key="option.label"
                    class="option-line"
                  >
                    <el-radio :value="option.label">
                      {{ option.label }}. {{ option.content }}
                    </el-radio>
                  </div>
                </el-radio-group>
              </template>
              <template v-else-if="isAnswerMode">
                <RichTextEditor
                  v-model="answerMap[question.id]"
                  placeholder="请输入你的作答内容"
                  :min-height="240"
                  :readonly="isAnswerLocked"
                />
              </template>
              <template v-else>
                <template v-if="question.questionType !== 4">
                  <div
                    v-for="option in parseOptions(question.optionsJson)"
                    :key="option.label"
                    class="option-line"
                  >
                    {{ option.label }}. {{ option.content }}
                  </div>
                </template>
                <template v-else>
                  <div class="subjective-review-card">
                    <div class="subjective-review-title">我的作答</div>
                    <div class="subjective-review-content" v-html="formatSubjectiveAnswer(question)"></div>
                  </div>
                </template>
              </template>
            </div>

            <template v-if="!isAnswerMode">
              <div class="answer-result-card">
                <div class="answer-copy">
                  <div>
                    {{ question.questionType === 4 ? '批改结果' : `我的答案：${formatMyAnswer(question)}` }}
                  </div>
                  <div v-if="showCorrectAnswer(question)" class="answer-correct">
                    正确答案：{{ formatCorrectAnswer(question) }}
                  </div>
                </div>
                <div class="answer-score">
                  {{ question.reviewPending ? '待批改' : `${question.earnedScore ?? 0} 分` }}
                </div>
              </div>
              <div v-if="question.analysis" class="analysis-block">解析：{{ question.analysis }}</div>
            </template>
          </section>
        </div>

        <div v-if="isAnswerMode" class="submit-row">
          <el-button
            type="primary"
            size="large"
            :loading="submitting || autoSubmitting"
            :disabled="isAnswerLocked"
            @click="submitTask()"
          >
            {{ submitButtonLabel }}
          </el-button>
        </div>
      </section>

      <aside class="task-sidebar">
        <div class="sidebar-card">
          <div v-if="showExamCountdown" class="countdown-panel">
            <div class="countdown-label">倒计时</div>
            <div class="countdown-value" :class="{ 'is-danger': examRemainingSeconds <= 300 }">
              {{ formattedExamCountdown }}
            </div>
            <div class="countdown-tip">时间结束后系统将自动提交</div>
          </div>

          <div v-for="group in questionGroups" :key="group.key" class="sidebar-group">
            <div class="sidebar-title">{{ group.title }}（{{ group.totalScore }} 分）</div>
            <div class="sidebar-grid">
              <button
                v-for="question in group.questions"
                :key="question.id"
                class="sidebar-index"
                :class="{
                  'is-answered': isQuestionAnswered(question.id),
                  'is-review': !isAnswerMode
                }"
                type="button"
                @click="scrollToQuestion(question.id)"
              >
                {{ findQuestionIndex(question.id) }}
              </button>
            </div>
          </div>
        </div>
      </aside>
    </main>
  </div>
</template>

<script setup>
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import RichTextEditor from '@/components/RichTextEditor.vue'
import { getMemberTaskDetail, submitMemberTask } from '@/api/memberTask'
import { getMemberExamDetail, submitMemberExam } from '@/api/memberExam'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const submitting = ref(false)
const autoSubmitting = ref(false)
const taskDetail = ref(null)
const answerMap = reactive({})
const examStartedAt = ref('')
const examRemainingSeconds = ref(0)

let examTimer = null

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)
const avatarUrl = computed(() => authStore.profile?.avatar || '')
const isExamScene = computed(() => route.meta?.scene === 'exam' || route.query.scene === 'exam')
const currentEntityId = computed(() => Number(route.params.examId || route.params.taskId))
const sceneLabel = computed(() => (isExamScene.value ? '考试' : '作业'))
const pageTitle = computed(() => `${sceneLabel.value}详情`)
const isAnswerMode = computed(() => route.query.mode === 'answer' && taskDetail.value?.canSubmit === true)
const showExamCountdown = computed(
  () => isExamScene.value && isAnswerMode.value && Number(taskDetail.value?.durationMinutes || 0) > 0
)
const isAnswerLocked = computed(
  () => submitting.value || autoSubmitting.value || (showExamCountdown.value && examRemainingSeconds.value <= 0)
)
const submitButtonLabel = computed(() => (isExamScene.value ? '提交考试' : '提交作业'))

const formattedExamCountdown = computed(() => {
  const totalSeconds = Math.max(0, Number(examRemainingSeconds.value || 0))
  const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0')
  const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0')
  const seconds = String(totalSeconds % 60).padStart(2, '0')
  return `${hours}:${minutes}:${seconds}`
})

const pageStatus = computed(() => {
  if (isAnswerMode.value) {
    return { label: isExamScene.value ? '考试中' : '答题中', type: 'primary' }
  }
  if (taskDetail.value?.submitted && taskDetail.value?.latestSubmission?.reviewStatus === 0) {
    return { label: '待批改', type: 'warning' }
  }
  if (taskDetail.value?.submitted) {
    return { label: isExamScene.value ? '已交卷' : '已提交', type: 'success' }
  }
  if (taskDetail.value?.canSubmit) {
    return { label: isExamScene.value ? '待考试' : '待作答', type: 'warning' }
  }
  return { label: isExamScene.value ? '不可考试' : '不可作答', type: 'info' }
})

const isPassed = computed(() => {
  const score = Number(taskDetail.value?.latestSubmission?.score ?? -1)
  const passScore = Number(taskDetail.value?.passScore ?? 0)
  return score >= 0 && score >= passScore
})

const scoreStatusText = computed(() => (isPassed.value ? '已及格' : '未及格'))
const scoreStatusClass = computed(() => (isPassed.value ? 'is-passed' : 'is-failed'))

const questionGroups = computed(() => {
  const groupMap = new Map()
  for (const question of taskDetail.value?.questions || []) {
    const key = question.questionType
    if (!groupMap.has(key)) {
      groupMap.set(key, {
        key,
        title: questionTypeText(key),
        totalScore: 0,
        questions: []
      })
    }
    const group = groupMap.get(key)
    group.questions.push(question)
    group.totalScore += Number(question.score || 0)
  }
  return Array.from(groupMap.values())
})

function questionTypeText(value) {
  return value === 1 ? '单选题' : value === 3 ? '判断题' : value === 4 ? '主观题' : '题目'
}

function parseOptions(value) {
  if (!value) {
    return []
  }
  try {
    const parsed = JSON.parse(value)
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

function parseAnswer(value) {
  if (!value) {
    return []
  }
  try {
    const parsed = JSON.parse(value)
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
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
  if (hours > 0 && minutes > 0) {
    return `${hours} 小时 ${minutes} 分钟`
  }
  if (hours > 0) {
    return `${hours} 小时`
  }
  return `${minutes} 分钟`
}

function goBack() {
  const tab = isExamScene.value ? 'exams' : 'assignments'
  router.push(`/member/courses/${route.params.id}/learn?tab=${tab}`)
}

function goProfile() {
  router.push('/member/profile')
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function buildExamSessionStorageKey() {
  return `member_exam_started_at_${currentEntityId.value}`
}

function readExamSession() {
  return localStorage.getItem(buildExamSessionStorageKey()) || ''
}

function writeExamSession(value) {
  localStorage.setItem(buildExamSessionStorageKey(), value)
}

function clearExamSession() {
  localStorage.removeItem(buildExamSessionStorageKey())
}

function formatStartedAt(date = new Date()) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

function parseStartedAt(value) {
  if (!value) {
    return null
  }
  const date = new Date(String(value).replace(' ', 'T'))
  return Number.isNaN(date.getTime()) ? null : date
}

function ensureExamStartedAt() {
  if (!isExamScene.value || route.query.mode !== 'answer') {
    examStartedAt.value = ''
    return
  }
  const fromQuery = typeof route.query.startedAt === 'string' ? route.query.startedAt : ''
  const fromStorage = readExamSession()
  examStartedAt.value = fromQuery || fromStorage || formatStartedAt()
  writeExamSession(examStartedAt.value)
}

function stopExamCountdown() {
  if (examTimer) {
    clearInterval(examTimer)
    examTimer = null
  }
}

function updateExamRemainingSeconds() {
  if (!showExamCountdown.value) {
    examRemainingSeconds.value = 0
    return
  }
  const startedAt = parseStartedAt(examStartedAt.value)
  const durationMinutes = Number(taskDetail.value?.durationMinutes || 0)
  if (!startedAt || !durationMinutes) {
    examRemainingSeconds.value = 0
    return
  }
  const expiresAt = startedAt.getTime() + durationMinutes * 60 * 1000
  examRemainingSeconds.value = Math.max(0, Math.floor((expiresAt - Date.now()) / 1000))
}

async function handleExamTimeout() {
  if (!showExamCountdown.value || autoSubmitting.value || submitting.value || !isAnswerMode.value) {
    return
  }
  autoSubmitting.value = true
  ElMessage.warning('考试时间已到，系统正在自动提交')
  await submitTask({ auto: true })
}

function startExamCountdown() {
  stopExamCountdown()
  updateExamRemainingSeconds()
  if (!showExamCountdown.value) {
    return
  }
  if (examRemainingSeconds.value <= 0) {
    handleExamTimeout()
    return
  }
  examTimer = window.setInterval(async () => {
    updateExamRemainingSeconds()
    if (examRemainingSeconds.value <= 0) {
      stopExamCountdown()
      await handleExamTimeout()
    }
  }, 1000)
}

function findQuestionIndex(questionId) {
  const questions = taskDetail.value?.questions || []
  const index = questions.findIndex((item) => item.id === questionId)
  return index >= 0 ? index + 1 : '-'
}

function isQuestionAnswered(questionId) {
  if (isAnswerMode.value) {
    const question = (taskDetail.value?.questions || []).find((item) => item.id === questionId)
    if (question?.questionType === 4) {
      return isRichTextFilled(answerMap[questionId])
    }
    return Boolean(answerMap[questionId])
  }
  const question = (taskDetail.value?.questions || []).find((item) => item.id === questionId)
  return parseAnswer(question?.myAnswerJson).length > 0
}

function scrollToQuestion(questionId) {
  const element = document.getElementById(`question-${questionId}`)
  if (!element) {
    return
  }
  element.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

function formatMyAnswer(question) {
  const answers = parseAnswer(question.myAnswerJson)
  const answer = answers[0]
  if (!answer) {
    return '--'
  }
  if (question.questionType === 4) {
    return stripHtml(answer) || '--'
  }
  if (question.questionType === 3) {
    return answer === 'T' ? '正确' : '错误'
  }
  const options = parseOptions(question.optionsJson)
  const selectedOption = options.find((item) => item.label === answer)
  return selectedOption ? `${answer}. ${selectedOption.content}` : answer
}

function formatCorrectAnswer(question) {
  const answers = parseAnswer(question.correctAnswerJson)
  const answer = answers[0]
  if (!answer) {
    return '--'
  }
  if (question.questionType === 4) {
    return stripHtml(answer) || '--'
  }
  if (question.questionType === 3) {
    return answer === 'T' ? '正确' : '错误'
  }
  const options = parseOptions(question.optionsJson)
  const selectedOption = options.find((item) => item.label === answer)
  return selectedOption ? `${answer}. ${selectedOption.content}` : answer
}

function showCorrectAnswer(question) {
  return !question.reviewPending && parseAnswer(question.correctAnswerJson).length > 0
}

function formatSubjectiveAnswer(question) {
  const answer = parseAnswer(question.myAnswerJson)[0]
  return answer || '<p>暂无作答内容</p>'
}

function stripHtml(value) {
  return String(value || '').replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim()
}

function isRichTextFilled(value) {
  return stripHtml(value).length > 0
}

function initAnswerMap() {
  const nextAnswers = {}
  for (const question of taskDetail.value?.questions || []) {
    const previousAnswers = parseAnswer(question.myAnswerJson)
    nextAnswers[question.id] = previousAnswers[0] || ''
  }
  for (const key of Object.keys(answerMap)) {
    delete answerMap[key]
  }
  Object.assign(answerMap, nextAnswers)
}

async function fetchTaskDetail() {
  loading.value = true
  try {
    const params = examStartedAt.value ? { startedAt: examStartedAt.value } : undefined
    const request = isExamScene.value ? getMemberExamDetail : getMemberTaskDetail
    const { data } = await request(currentEntityId.value, params)
    taskDetail.value = data
    initAnswerMap()

    if (taskDetail.value?.submitted) {
      clearExamSession()
    }

    if (showExamCountdown.value) {
      startExamCountdown()
    } else {
      stopExamCountdown()
    }
  } finally {
    loading.value = false
  }
}

function buildAnswersPayload() {
  return (taskDetail.value?.questions || []).map((question) => ({
    questionId: question.id,
    answer: answerMap[question.id] ? [answerMap[question.id]] : []
  }))
}

function validateBeforeSubmit() {
  const unanswered = (taskDetail.value?.questions || []).find((question) => {
    if (question.questionType === 4) {
      return !isRichTextFilled(answerMap[question.id])
    }
    return !answerMap[question.id]
  })
  if (unanswered) {
    ElMessage.warning('请先完成全部题目')
    scrollToQuestion(unanswered.id)
    return false
  }
  return true
}

async function submitTask(options = {}) {
  const auto = Boolean(options.auto)
  if (!auto && !validateBeforeSubmit()) {
    return
  }

  if (!auto) {
    await ElMessageBox.confirm(
      isExamScene.value ? '确认提交当前考试吗？提交后将结束本次考试。' : '确认提交当前作业吗？提交后将自动判分。',
      submitButtonLabel.value,
      { type: 'warning' }
    )
  }

  if (auto) {
    autoSubmitting.value = true
  } else {
    submitting.value = true
  }

  try {
    const request = isExamScene.value ? submitMemberExam : submitMemberTask
    await request(currentEntityId.value, {
      answersJson: JSON.stringify(buildAnswersPayload()),
      startedAt: examStartedAt.value || null
    })
    clearExamSession()
    stopExamCountdown()
    ElMessage.success(isExamScene.value ? '考试已提交' : '作业已提交')
    await fetchTaskDetail()
    await router.replace({
      path: isExamScene.value
        ? `/member/courses/${route.params.id}/learn/exams/${currentEntityId.value}`
        : `/member/courses/${route.params.id}/learn/tasks/${currentEntityId.value}`,
      query: { mode: 'review' }
    })
  } finally {
    submitting.value = false
    autoSubmitting.value = false
  }
}

onMounted(async () => {
  ensureExamStartedAt()
  await fetchTaskDetail()
})

onBeforeUnmount(() => {
  stopExamCountdown()
})
</script>

<style scoped>
.task-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top, rgba(64, 158, 255, 0.12), transparent 34%),
    linear-gradient(180deg, #f6f9fd 0%, #edf3fb 100%);
}

.task-topbar {
  height: 44px;
  padding: 0 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #3d5373;
  color: rgba(255, 255, 255, 0.92);
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

.task-shell {
  min-height: calc(100vh - 44px);
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
}

.task-stage {
  padding: 28px 40px 24px;
  background: rgba(255, 255, 255, 0.96);
}

.task-stage-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
}

.task-head-actions {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.task-score-panel {
  min-width: 180px;
  padding: 14px 16px;
  border-radius: 14px;
  border: 1px solid transparent;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 6px;
}

.task-score-panel.is-passed {
  background: #f0fdf4;
  border-color: #bbf7d0;
}

.task-score-panel.is-failed {
  background: #fef2f2;
  border-color: #fecaca;
}

.task-score-label {
  font-size: 13px;
  font-weight: 700;
}

.task-score-panel.is-passed .task-score-label,
.task-score-panel.is-passed .task-score-value {
  color: #15803d;
}

.task-score-panel.is-failed .task-score-label,
.task-score-panel.is-failed .task-score-value {
  color: #dc2626;
}

.task-score-value {
  font-size: 24px;
  line-height: 1;
  font-weight: 800;
}

.task-kicker {
  color: #409eff;
  font-size: 13px;
  font-weight: 700;
}

.task-stage-head h1 {
  margin: 8px 0 0;
  color: #1f2d3d;
  font-size: 28px;
}

.task-meta-row {
  margin-top: 18px;
  padding: 16px 0 18px;
  border-top: 1px solid #eef2f7;
  border-bottom: 1px solid #eef2f7;
  display: flex;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
  color: #94a3b8;
  font-size: 14px;
}

.task-review-comment-card {
  margin-top: 18px;
  padding: 16px 18px;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  background: #fff;
}

.task-review-comment-title {
  margin-bottom: 10px;
  color: #64748b;
  font-size: 12px;
  font-weight: 700;
}

.task-review-comment-content {
  color: #1f2937;
  line-height: 1.8;
  white-space: pre-wrap;
}

.question-section {
  margin-top: 28px;
  display: flex;
  flex-direction: column;
  gap: 34px;
}

.question-card {
  scroll-margin-top: 18px;
}

.question-title {
  color: #111827;
  font-size: 17px;
  line-height: 1.9;
  font-weight: 600;
}

.question-type {
  color: #94a3b8;
  font-weight: 400;
}

.question-options {
  margin-top: 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.question-radio-group {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: 10px;
}

.option-line {
  color: #1f2937;
  font-size: 16px;
  line-height: 1.8;
}

.question-radio-group .option-line {
  display: block;
}

.question-radio-group .option-line :deep(.el-radio) {
  display: flex;
  align-items: flex-start;
  margin-right: 0;
  white-space: normal;
}

.question-radio-group .option-line :deep(.el-radio__label) {
  white-space: normal;
  line-height: 1.8;
  padding-left: 10px;
}

.answer-result-card {
  margin-top: 18px;
  padding: 18px 22px;
  border: 1px solid #e5e7eb;
  border-left: 6px solid #dbe4f0;
  border-radius: 12px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.answer-copy {
  display: flex;
  flex-direction: column;
  gap: 8px;
  color: #111827;
  font-size: 16px;
  font-weight: 700;
}

.answer-correct {
  color: #15803d;
}

.answer-score {
  color: #0f172a;
  font-size: 22px;
  font-weight: 800;
}

.subjective-review-card {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px 18px;
  background: #fff;
}

.subjective-review-title {
  margin-bottom: 10px;
  color: #64748b;
  font-size: 12px;
  font-weight: 700;
}

.subjective-review-content {
  color: #1f2937;
  line-height: 1.8;
}

.subjective-review-content :deep(p) {
  margin: 8px 0;
}

.subjective-review-content :deep(ul),
.subjective-review-content :deep(ol) {
  padding-left: 22px;
}

.analysis-block {
  margin-top: 12px;
  padding: 14px 16px;
  border-radius: 12px;
  background: #f8fbff;
  color: #475569;
  line-height: 1.8;
}

.submit-row {
  margin-top: 36px;
  display: flex;
  justify-content: center;
}

.task-sidebar {
  padding: 36px 24px;
  align-self: start;
  position: sticky;
  top: 20px;
}

.sidebar-card {
  padding: 20px 20px 24px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid #e5e7eb;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.05);
}

.countdown-panel {
  margin-bottom: 22px;
  padding: 18px 16px;
  border-radius: 14px;
  background: linear-gradient(180deg, #fff7ed 0%, #fff1f2 100%);
  border: 1px solid #fed7aa;
}

.countdown-label {
  color: #9a3412;
  font-size: 12px;
  font-weight: 700;
}

.countdown-value {
  margin-top: 8px;
  color: #c2410c;
  font-size: 28px;
  line-height: 1;
  font-weight: 800;
}

.countdown-value.is-danger {
  color: #dc2626;
}

.countdown-tip {
  margin-top: 8px;
  color: #9a3412;
  font-size: 12px;
  line-height: 1.6;
}

.sidebar-group + .sidebar-group {
  margin-top: 28px;
}

.sidebar-title {
  color: #1f2d3d;
  font-size: 14px;
  font-weight: 700;
}

.sidebar-grid {
  margin-top: 14px;
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 14px;
}

.sidebar-index {
  height: 38px;
  border: 1px solid #3b82f6;
  border-radius: 8px;
  background: rgba(59, 130, 246, 0.08);
  color: #3b82f6;
  cursor: pointer;
}

.sidebar-index.is-answered,
.sidebar-index.is-review {
  background: #3b82f6;
  color: #fff;
}

@media (max-width: 1080px) {
  .task-shell {
    grid-template-columns: 1fr;
  }

  .task-sidebar {
    padding-top: 0;
    position: static;
  }
}

@media (max-width: 640px) {
  .task-stage {
    padding: 18px 16px;
  }

  .task-stage-head {
    flex-direction: column;
  }

  .task-head-actions {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }

  .task-meta-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .answer-result-card {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
