<template>
  <div class="task-page">
    <header class="task-topbar">
      <button class="back-link" type="button" @click="goBack">
        返回课程
      </button>
      <div class="topbar-title">作业详情</div>
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
            <h1>{{ taskDetail?.title || '作业详情' }}</h1>
          </div>
          <div class="task-head-actions">
            <div
              v-if="taskDetail?.submitted && taskDetail?.latestSubmission && taskDetail?.latestSubmission?.reviewStatus === 1"
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
          <span>作答时间：{{ formatDateTime(taskDetail?.startTime) }} 至 {{ formatDateTime(taskDetail?.endTime) }}</span>
          <span>总分 {{ taskDetail?.totalScore ?? 0 }}</span>
          <span>及格分 {{ taskDetail?.passScore ?? 0 }}</span>
          <span>剩余次数 {{ taskDetail?.remainingAttempts ?? 0 }}</span>
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
                {{ index + 1 }}. <span class="question-type">({{ questionTypeText(question.questionType) }}，{{ question.score }}分)</span>{{ question.stem }}
              </div>
            </div>

            <div class="question-options">
              <template v-if="isAnswerMode && question.questionType !== 4">
                <el-radio-group v-model="answerMap[question.id]" class="question-radio-group">
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
              <div v-if="question.analysis" class="analysis-block">
                解析：{{ question.analysis }}
              </div>
            </template>
          </section>
        </div>

        <div v-if="isAnswerMode" class="submit-row">
          <el-button type="primary" size="large" :loading="submitting" @click="submitTask">
            提交作业
          </el-button>
        </div>
      </section>

      <aside class="task-sidebar">
        <div class="sidebar-card">
          <div
            v-for="group in questionGroups"
            :key="group.key"
            class="sidebar-group"
          >
            <div class="sidebar-title">{{ group.title }}（{{ group.totalScore }}分）</div>
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
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import RichTextEditor from '@/components/RichTextEditor.vue'
import { getMemberTaskDetail, submitMemberTask } from '@/api/memberTask'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const submitting = ref(false)
const taskDetail = ref(null)
const answerMap = reactive({})

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)
const avatarUrl = computed(() => authStore.profile?.avatar || '')
const isAnswerMode = computed(() => route.query.mode === 'answer' && taskDetail.value?.canSubmit === true)
const pageStatus = computed(() => {
  if (isAnswerMode.value) {
    return { label: '答题中', type: 'primary' }
  }
  if (taskDetail.value?.submitted && taskDetail.value?.latestSubmission?.reviewStatus === 0) {
    return { label: '待批改', type: 'warning' }
  }
  if (taskDetail.value?.submitted) {
    return { label: '已提交', type: 'success' }
  }
  if (taskDetail.value?.canSubmit) {
    return { label: '待作答', type: 'warning' }
  }
  return { label: '不可作答', type: 'info' }
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
  } catch (error) {
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
  } catch (error) {
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

function goBack() {
  router.push(`/member/courses/${route.params.id}/learn?tab=assignments`)
}

function goProfile() {
  router.push('/member/profile')
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
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
    const { data } = await getMemberTaskDetail(route.params.taskId)
    taskDetail.value = data
    initAnswerMap()
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

async function submitTask() {
  if (!validateBeforeSubmit()) {
    return
  }
  await ElMessageBox.confirm('确认提交当前作业吗？提交后将自动判分。', '提交作业', { type: 'warning' })
  submitting.value = true
  try {
    await submitMemberTask(route.params.taskId, {
      answersJson: JSON.stringify(buildAnswersPayload())
    })
    ElMessage.success('作业已提交')
    await fetchTaskDetail()
    router.replace(`/member/courses/${route.params.id}/learn/tasks/${route.params.taskId}?mode=review`)
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  await fetchTaskDetail()
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
