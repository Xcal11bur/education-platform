<template>
  <div class="page-card">
    <div class="page-header">
      <div>
        <div class="page-title-row">
          <el-button link type="primary" @click="goBack">返回作业管理</el-button>
          <h2 class="page-title">{{ headerTitle }}</h2>
        </div>
      </div>
    </div>

    <div v-if="taskInfo" class="task-summary-grid">
      <div class="summary-item">
        <span class="summary-label">作业状态</span>
        <el-tag :type="taskInfo.status === 1 ? 'success' : 'info'">
          {{ taskInfo.status === 1 ? '已发布' : '草稿' }}
        </el-tag>
      </div>
      <div class="summary-item">
        <span class="summary-label">题目数量</span>
        <strong>{{ taskInfo.questionCount || 0 }}</strong>
      </div>
      <div class="summary-item">
        <span class="summary-label">总分</span>
        <strong>{{ taskInfo.totalScore || 0 }}</strong>
      </div>
      <div class="summary-item">
        <span class="summary-label">提交次数</span>
        <strong>{{ submissions.length }}</strong>
      </div>
    </div>

    <el-table :data="submissions" border>
      <el-table-column label="序号" width="90">
        <template #default="{ $index }">{{ $index + 1 }}</template>
      </el-table-column>
      <el-table-column prop="memberName" label="学员" min-width="140" />
      <el-table-column prop="memberMobile" label="手机号" min-width="140" />
      <el-table-column prop="attemptNo" label="第几次提交" width="110" />
      <el-table-column label="客观/主观" width="130">
        <template #default="{ row }">{{ row.objectiveScore }}/{{ row.subjectiveScore }}</template>
      </el-table-column>
      <el-table-column label="总分" width="100">
        <template #default="{ row }">
          {{ row.reviewStatus === 1 ? row.score : '--' }}
        </template>
      </el-table-column>
      <el-table-column label="状态" width="110">
        <template #default="{ row }">
          <el-tag :type="row.reviewStatus === 1 ? 'success' : 'warning'">
            {{ row.reviewStatus === 1 ? '已批改' : '待批改' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="提交时间" min-width="170">
        <template #default="{ row }">{{ formatDateTime(row.submittedAt) }}</template>
      </el-table-column>
      <el-table-column label="批改时间" min-width="170">
        <template #default="{ row }">{{ formatDateTime(row.reviewedAt) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="140" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openSubmission(row)">
            {{ hasSubjective(row) ? '批改/查看' : '查看' }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-empty v-if="!submissions.length" description="暂无提交记录" />

    <el-drawer
      v-model="drawerVisible"
      :title="drawerTitle"
      size="55%"
      destroy-on-close
    >
      <div v-if="submissionDetail" class="review-drawer">
        <div class="review-meta-grid">
          <div class="meta-card">
            <span>学员</span>
            <strong>{{ submissionDetail.memberName || '--' }}</strong>
          </div>
          <div class="meta-card">
            <span>提交次数</span>
            <strong>第 {{ submissionDetail.attemptNo }} 次</strong>
          </div>
          <div class="meta-card">
            <span>客观得分</span>
            <strong>{{ submissionDetail.objectiveScore || 0 }}</strong>
          </div>
          <div class="meta-card">
            <span>当前总分</span>
            <strong>{{ submissionDetail.reviewStatus === 1 ? submissionDetail.score : '--' }}</strong>
          </div>
        </div>

        <div
          v-for="(question, index) in submissionDetail.questions || []"
          :key="question.questionId"
          class="review-question-card"
        >
          <div class="review-question-head">
            <div class="review-question-title">
              {{ index + 1 }}. {{ questionTypeText(question.questionType) }}（{{ question.score }}分）{{ question.stem }}
            </div>
          </div>

          <div v-if="question.questionType !== 4" class="question-answer-block">
            <div
              v-for="option in parseOptions(question.optionsJson)"
              :key="option.label"
              class="option-line"
            >
              {{ option.label }}. {{ option.content }}
            </div>
            <div class="answer-meta">
              学员答案：{{ formatMemberAnswer(question) }}
            </div>
            <div class="answer-meta">
              标准答案：{{ formatStandardAnswer(question) }}
            </div>
            <div class="answer-score-line">
              得分：{{ question.earnedScore ?? 0 }}
            </div>
          </div>

          <div v-else class="subjective-block">
            <div class="rich-preview">
              <div class="preview-title">学员作答</div>
              <div class="preview-content" v-html="getSubjectiveHtml(question.memberAnswerJson)"></div>
            </div>
            <div v-if="getSubjectiveHtml(question.answerJson)" class="rich-preview">
              <div class="preview-title">参考答案</div>
              <div class="preview-content" v-html="getSubjectiveHtml(question.answerJson)"></div>
            </div>
            <div class="score-editor-row">
              <div class="score-editor-item">
                <span class="score-editor-label">主观得分</span>
                <el-input-number
                  v-model="reviewScores[question.questionId]"
                  :min="0"
                  :max="question.score"
                />
              </div>
            </div>
          </div>

          <div v-if="question.analysis" class="analysis-text">
            解析：{{ question.analysis }}
          </div>
        </div>

        <el-form label-width="90px" class="review-form">
          <el-form-item label="评语">
            <el-input v-model="reviewComment" type="textarea" :rows="4" maxlength="500" show-word-limit />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <div class="drawer-footer">
          <el-button @click="drawerVisible = false">关闭</el-button>
          <el-button
            type="primary"
            :loading="saving"
            @click="submitReview"
          >
            {{ hasSubjectiveQuestions ? '保存批改' : '保存评语' }}
          </el-button>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getTeacherTaskDetail } from '@/api/teacherTask'
import {
  getTeacherTaskSubmissionDetail,
  getTeacherTaskSubmissionList,
  reviewTeacherTaskSubmission
} from '@/api/teacherTaskSubmission'

const route = useRoute()
const router = useRouter()
const taskId = Number(route.params.taskId)

const taskInfo = ref(null)
const submissions = ref([])
const drawerVisible = ref(false)
const submissionDetail = ref(null)
const saving = ref(false)
const reviewComment = ref('')
const reviewScores = reactive({})

const headerTitle = computed(() => {
  const courseTitle = taskInfo.value?.courseTitle || '--'
  const taskTitle = taskInfo.value?.title || '提交记录'
  return `${courseTitle} / ${taskTitle}`
})

const drawerTitle = computed(() => {
  if (!submissionDetail.value) {
    return '提交详情'
  }
  return `${submissionDetail.value.memberName || '学员'} · 第 ${submissionDetail.value.attemptNo} 次提交`
})

const hasSubjectiveQuestions = computed(() =>
  (submissionDetail.value?.questions || []).some((item) => item.questionType === 4)
)

function questionTypeText(value) {
  return value === 1 ? '单选题' : value === 3 ? '判断题' : value === 4 ? '主观题' : '题目'
}

function parseJsonArray(value) {
  if (!value) return []
  try {
    const parsed = JSON.parse(value)
    return Array.isArray(parsed) ? parsed : []
  } catch (error) {
    return []
  }
}

function parseOptions(value) {
  return parseJsonArray(value)
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '')
}

function hasSubjective(row) {
  return Number(row.subjectiveScore || 0) > 0 || row.reviewStatus === 0
}

function formatMemberAnswer(question) {
  const answer = parseJsonArray(question.memberAnswerJson)[0]
  if (!answer) {
    return '--'
  }
  if (question.questionType === 3) {
    return answer === 'T' ? '正确' : '错误'
  }
  const option = parseOptions(question.optionsJson).find((item) => item.label === answer)
  return option ? `${answer}. ${option.content}` : answer
}

function formatStandardAnswer(question) {
  const answer = parseJsonArray(question.answerJson)[0]
  if (!answer) {
    return '--'
  }
  if (question.questionType === 3) {
    return answer === 'T' ? '正确' : '错误'
  }
  const option = parseOptions(question.optionsJson).find((item) => item.label === answer)
  return option ? `${answer}. ${option.content}` : answer
}

function getSubjectiveHtml(value) {
  return parseJsonArray(value)[0] || ''
}

function resetReviewState() {
  submissionDetail.value = null
  reviewComment.value = ''
  for (const key of Object.keys(reviewScores)) {
    delete reviewScores[key]
  }
}

async function fetchTaskInfo() {
  const { data } = await getTeacherTaskDetail(taskId)
  taskInfo.value = data
}

async function fetchSubmissions() {
  const { data } = await getTeacherTaskSubmissionList(taskId)
  submissions.value = data || []
}

async function openSubmission(row) {
  resetReviewState()
  const { data } = await getTeacherTaskSubmissionDetail(row.id)
  submissionDetail.value = data
  reviewComment.value = data.reviewComment || ''
  for (const question of data.questions || []) {
    if (question.questionType === 4) {
      reviewScores[question.questionId] = question.earnedScore ?? 0
    }
  }
  drawerVisible.value = true
}

async function submitReview() {
  if (!submissionDetail.value) {
    return
  }
  const subjectiveQuestions = (submissionDetail.value.questions || []).filter((item) => item.questionType === 4)
  const payload = {
    reviewComment: reviewComment.value.trim(),
    questionScores: subjectiveQuestions.map((item) => ({
      questionId: item.questionId,
      score: Number(reviewScores[item.questionId] ?? 0)
    }))
  }
  saving.value = true
  try {
    await reviewTeacherTaskSubmission(submissionDetail.value.id, payload)
    ElMessage.success('批改已保存')
    drawerVisible.value = false
    await fetchSubmissions()
  } finally {
    saving.value = false
  }
}

function goBack() {
  router.push('/teacher/course-management/tasks')
}

onMounted(async () => {
  await Promise.all([fetchTaskInfo(), fetchSubmissions()])
})
</script>

<style scoped>
.page-header {
  margin-bottom: 18px;
}

.page-title-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
}

.task-summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 18px;
}

.summary-item {
  background: #f7f9fc;
  border: 1px solid #e8eef7;
  border-radius: 12px;
  padding: 16px 18px;
}

.summary-label {
  display: block;
  margin-bottom: 10px;
  color: var(--text-secondary);
  font-size: 13px;
}

.summary-item strong {
  font-size: 22px;
}

.review-drawer {
  padding-right: 6px;
}

.review-meta-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.meta-card {
  padding: 14px 16px;
  border: 1px solid #e8eef7;
  border-radius: 12px;
  background: #f8fafc;
}

.meta-card span {
  display: block;
  color: var(--text-secondary);
  font-size: 12px;
}

.meta-card strong {
  display: block;
  margin-top: 8px;
  font-size: 18px;
}

.review-question-card {
  padding: 18px;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  background: #fff;
}

.review-question-card + .review-question-card {
  margin-top: 14px;
}

.review-question-title {
  color: #1f2d3d;
  font-weight: 700;
  line-height: 1.8;
}

.question-answer-block,
.subjective-block {
  margin-top: 14px;
}

.option-line,
.answer-meta,
.answer-score-line {
  color: #475569;
  line-height: 1.9;
}

.answer-score-line {
  margin-top: 8px;
  font-weight: 700;
}

.rich-preview {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 14px 16px;
  background: #fff;
}

.rich-preview + .rich-preview {
  margin-top: 12px;
}

.preview-title {
  margin-bottom: 10px;
  color: #64748b;
  font-size: 12px;
  font-weight: 700;
}

.preview-content {
  color: #1f2937;
  line-height: 1.8;
}

.preview-content :deep(p) {
  margin: 8px 0;
}

.preview-content :deep(ul),
.preview-content :deep(ol) {
  padding-left: 22px;
}

.score-editor-row {
  margin-top: 14px;
}

.score-editor-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.score-editor-label {
  color: #475569;
  font-size: 14px;
}

.analysis-text {
  margin-top: 12px;
  color: #64748b;
  line-height: 1.8;
}

.review-form {
  margin-top: 18px;
}

.drawer-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

@media (max-width: 900px) {
  .task-summary-grid,
  .review-meta-grid {
    grid-template-columns: 1fr;
  }
}
</style>
