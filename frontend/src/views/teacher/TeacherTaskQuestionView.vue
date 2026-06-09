<template>
  <div class="page-card">
    <div class="question-page-header">
      <div>
        <div class="page-title-row">
          <el-button link type="primary" @click="goBack">返回{{ entityName }}管理</el-button>
          <h2 class="page-title">{{ headerTitle }}</h2>
        </div>
      </div>
      <el-button type="primary" @click="openCreate">新增题目</el-button>
    </div>

    <div v-if="taskInfo" class="task-summary-grid">
      <div class="summary-item">
        <span class="summary-label">{{ entityName }}状态</span>
        <el-tag :type="taskInfo.status === 1 ? 'success' : 'info'">
          {{ taskInfo.status === 1 ? '已发布' : '草稿' }}
        </el-tag>
      </div>
      <div class="summary-item">
        <span class="summary-label">题目数量</span>
        <strong>{{ questions.length }}</strong>
      </div>
      <div class="summary-item">
        <span class="summary-label">当前总分</span>
        <strong>{{ totalScore }}</strong>
      </div>
      <div class="summary-item">
        <span class="summary-label">及格分</span>
        <strong>{{ taskInfo.passScore ?? 0 }}</strong>
      </div>
    </div>

    <el-table :data="questions" border>
      <el-table-column label="序号" width="90">
        <template #default="{ $index }">{{ $index + 1 }}</template>
      </el-table-column>
      <el-table-column label="题型" width="120">
        <template #default="{ row }">{{ questionTypeText(row.questionType) }}</template>
      </el-table-column>
      <el-table-column label="题干" min-width="260">
        <template #default="{ row }">
          <div class="stem-cell">{{ row.stem }}</div>
        </template>
      </el-table-column>
      <el-table-column label="答案" width="140">
        <template #default="{ row }">{{ formatAnswer(row) }}</template>
      </el-table-column>
      <el-table-column prop="score" label="分值" width="100" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-empty v-if="!questions.length" description="暂无题目" />

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑题目' : '新增题目'" width="820px">
      <el-form ref="formRef" :model="form" label-width="96px">
        <el-form-item label="题型">
          <el-radio-group v-model="form.questionType">
            <el-radio :value="1">单选题</el-radio>
            <el-radio :value="3">判断题</el-radio>
            <el-radio :value="4">主观题</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="题干">
          <el-input
            v-model="form.stem"
            type="textarea"
            :rows="4"
            maxlength="1000"
            show-word-limit
            placeholder="请输入题干"
          />
        </el-form-item>
        <template v-if="form.questionType === 1">
          <el-form-item label="选项">
            <div class="option-list">
              <div
                v-for="(option, index) in form.options"
                :key="option.label"
                class="option-item"
              >
                <span class="option-label">{{ option.label }}</span>
                <el-input
                  v-model="option.content"
                  :placeholder="`请输入选项 ${option.label}`"
                  maxlength="200"
                />
              </div>
            </div>
          </el-form-item>
          <el-form-item label="正确答案">
            <el-radio-group v-model="form.answer">
              <el-radio
                v-for="option in form.options"
                :key="option.label"
                :value="option.label"
              >
                {{ option.label }}
              </el-radio>
            </el-radio-group>
          </el-form-item>
        </template>
        <template v-else-if="form.questionType === 3">
          <el-form-item label="正确答案">
            <el-radio-group v-model="form.answer">
              <el-radio value="T">正确</el-radio>
              <el-radio value="F">错误</el-radio>
            </el-radio-group>
          </el-form-item>
        </template>
        <template v-else>
          <el-form-item label="参考答案">
            <RichTextEditor
              v-model="form.subjectiveAnswer"
              placeholder="可选，输入参考答案或评分要点"
              :min-height="180"
            />
          </el-form-item>
        </template>
        <el-form-item label="分值">
          <el-input-number v-model="form.score" :min="1" :max="100" />
        </el-form-item>
        <el-form-item label="解析">
          <el-input
            v-model="form.analysis"
            type="textarea"
            :rows="4"
            maxlength="1000"
            show-word-limit
            placeholder="请输入解析"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import RichTextEditor from '@/components/RichTextEditor.vue'
import { getTeacherTaskDetail } from '@/api/teacherTask'
import {
  createTeacherTaskQuestion,
  deleteTeacherTaskQuestion,
  getTeacherTaskQuestionList,
  updateTeacherTaskQuestion
} from '@/api/teacherTaskQuestion'
import { getTeacherExamDetail } from '@/api/teacherExam'
import {
  createTeacherExamQuestion,
  deleteTeacherExamQuestion,
  getTeacherExamQuestionList,
  updateTeacherExamQuestion
} from '@/api/teacherExamQuestion'

const route = useRoute()
const router = useRouter()
const isExamScene = computed(() => route.meta?.scene === 'exam')
const taskId = computed(() => Number(route.params.examId || route.params.taskId))
const entityName = computed(() => (isExamScene.value ? '考试' : '作业'))
const backPath = computed(() => (isExamScene.value ? '/teacher/course-management/exams' : '/teacher/course-management/tasks'))

const taskInfo = ref(null)
const questions = ref([])
const dialogVisible = ref(false)
const editingId = ref(null)
const saving = ref(false)
const formRef = ref()

const totalScore = computed(() => questions.value.reduce((sum, item) => sum + Number(item.score || 0), 0))
const headerTitle = computed(() => {
  const courseTitle = taskInfo.value?.courseTitle || '--'
  const taskTitle = taskInfo.value?.title || '题目管理'
  return `${courseTitle} / ${taskTitle}`
})

const optionLabels = ['A', 'B', 'C', 'D']

const defaultForm = () => ({
  questionType: 1,
  stem: '',
  options: optionLabels.map((label) => ({ label, content: '' })),
  answer: 'A',
  subjectiveAnswer: '',
  score: 5,
  analysis: ''
})

const form = reactive(defaultForm())

function getDetailRequest() {
  return isExamScene.value ? getTeacherExamDetail : getTeacherTaskDetail
}

function getQuestionListRequest() {
  return isExamScene.value ? getTeacherExamQuestionList : getTeacherTaskQuestionList
}

function getQuestionCreateRequest() {
  return isExamScene.value ? createTeacherExamQuestion : createTeacherTaskQuestion
}

function getQuestionUpdateRequest() {
  return isExamScene.value ? updateTeacherExamQuestion : updateTeacherTaskQuestion
}

function getQuestionDeleteRequest() {
  return isExamScene.value ? deleteTeacherExamQuestion : deleteTeacherTaskQuestion
}

function resetForm() {
  Object.assign(form, defaultForm())
  formRef.value?.clearValidate?.()
}

function questionTypeText(value) {
  return value === 1 ? '单选题' : value === 3 ? '判断题' : value === 4 ? '主观题' : '未知'
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

function formatAnswer(row) {
  const answers = parseJsonArray(row.answerJson)
  const answer = answers[0]
  if (!answer) {
    return '--'
  }
  if (row.questionType === 3) {
    return answer === 'T' ? '正确' : '错误'
  }
  if (row.questionType === 4) {
    return answer ? '已设置参考答案' : '--'
  }
  const options = parseJsonArray(row.optionsJson)
  const selectedOption = options.find((item) => item.label === answer)
  return selectedOption ? `${answer}. ${selectedOption.content}` : answer
}

async function fetchTaskInfo() {
  const { data } = await getDetailRequest()(taskId.value)
  taskInfo.value = data
}

async function fetchQuestions() {
  const { data } = await getQuestionListRequest()(taskId.value)
  questions.value = data || []
}

async function reloadPageData() {
  await Promise.all([fetchTaskInfo(), fetchQuestions()])
}

function goBack() {
  router.push(backPath.value)
}

function openCreate() {
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

function openEdit(row) {
  editingId.value = row.id
  resetForm()
  const options = parseJsonArray(row.optionsJson)
  const answers = parseJsonArray(row.answerJson)
  const mappedOptions = optionLabels.map((label) => ({
    label,
    content: options.find((item) => item.label === label)?.content || ''
  }))
  Object.assign(form, {
    questionType: row.questionType,
    stem: row.stem || '',
    options: mappedOptions,
    answer: answers[0] || (row.questionType === 3 ? 'T' : 'A'),
    subjectiveAnswer: row.questionType === 4 ? (answers[0] || '') : '',
    score: row.score || 5,
    analysis: row.analysis || ''
  })
  dialogVisible.value = true
}

function validateForm() {
  if (!form.stem.trim()) {
    ElMessage.warning('请输入题干')
    return false
  }
  if (!form.score || Number(form.score) <= 0) {
    ElMessage.warning('题目分值必须大于 0')
    return false
  }
  if (form.questionType === 1) {
    const hasEmptyOption = form.options.some((item) => !item.content.trim())
    if (hasEmptyOption) {
      ElMessage.warning('请完整填写单选题的四个选项')
      return false
    }
    if (!form.answer) {
      ElMessage.warning('请选择正确答案')
      return false
    }
  }
  if (form.questionType === 3 && !['T', 'F'].includes(form.answer)) {
    ElMessage.warning('请选择判断题答案')
    return false
  }
  if (form.questionType === 4 && !stripHtml(form.subjectiveAnswer)) {
    ElMessage.warning('请输入主观题参考答案或评分要点')
    return false
  }
  return true
}

function buildPayload() {
  const payload = {
    questionType: form.questionType,
    stem: form.stem.trim(),
    analysis: form.analysis.trim(),
    score: Number(form.score)
  }

  if (form.questionType === 1) {
    payload.optionsJson = JSON.stringify(
      form.options.map((item) => ({
        label: item.label,
        content: item.content.trim()
      }))
    )
    payload.answerJson = JSON.stringify([form.answer])
    return payload
  }

  if (form.questionType === 4) {
    payload.optionsJson = null
    payload.answerJson = form.subjectiveAnswer.trim()
    return payload
  }

  payload.optionsJson = JSON.stringify([
    { label: 'T', content: '正确' },
    { label: 'F', content: '错误' }
  ])
  payload.answerJson = JSON.stringify([form.answer])
  return payload
}

function stripHtml(value) {
  return String(value || '').replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim()
}

async function submitForm() {
  if (!validateForm()) {
    return
  }
  saving.value = true
  try {
    const payload = buildPayload()
    if (editingId.value) {
      await getQuestionUpdateRequest()(editingId.value, payload)
      ElMessage.success('题目已更新')
    } else {
      await getQuestionCreateRequest()(taskId.value, payload)
      ElMessage.success('题目已创建')
    }
    dialogVisible.value = false
    await reloadPageData()
  } finally {
    saving.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除题目“${row.stem}”吗？`, '删除题目', { type: 'warning' })
  await getQuestionDeleteRequest()(row.id)
  ElMessage.success('题目已删除')
  await reloadPageData()
}

onMounted(async () => {
  await reloadPageData()
})
</script>

<style scoped>
.question-page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
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

.stem-cell {
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
}

.option-list {
  display: grid;
  gap: 12px;
  width: 100%;
}

.option-item {
  display: grid;
  grid-template-columns: 32px 1fr;
  align-items: center;
  gap: 12px;
}

.option-label {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: rgba(64, 158, 255, 0.12);
  color: #409eff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
}

@media (max-width: 900px) {
  .question-page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .task-summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>
