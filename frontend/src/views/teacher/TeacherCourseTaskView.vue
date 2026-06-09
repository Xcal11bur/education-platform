<template>
  <div class="page-card">
    <div class="page-header">
      <h2 class="page-title">{{ pageTitle }}</h2>
      <el-button type="primary" @click="openCreate">新增{{ entityName }}</el-button>
    </div>

    <el-alert
      :title="pageAlertText"
      type="info"
      :closable="false"
      show-icon
      class="page-alert"
    />

    <div class="filter-bar">
      <el-select v-model="query.courseId" placeholder="课程" clearable filterable>
        <el-option
          v-for="item in courseOptions"
          :key="item.id"
          :label="item.title"
          :value="item.id"
        />
      </el-select>
      <el-input v-model="query.title" :placeholder="`${entityName}标题`" clearable />
      <el-select v-model="query.status" placeholder="状态" clearable>
        <el-option label="草稿" :value="0" />
        <el-option label="已发布" :value="1" />
      </el-select>
      <el-button type="primary" @click="fetchTasks">查询</el-button>
    </div>

    <el-table :data="tasks" border>
      <el-table-column label="ID" width="90">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column prop="courseTitle" label="所属课程" min-width="180" />
      <el-table-column :label="`${entityName}标题`" prop="title" min-width="180" />
      <el-table-column prop="questionCount" label="题目数" width="100" />
      <el-table-column label="总分/及格" width="120">
        <template #default="{ row }">{{ row.totalScore }}/{{ row.passScore }}</template>
      </el-table-column>
      <el-table-column label="开放时间" min-width="170">
        <template #default="{ row }">{{ formatDateTime(row.startTime) }}</template>
      </el-table-column>
      <el-table-column label="截止时间" min-width="170">
        <template #default="{ row }">{{ formatDateTime(row.endTime) }}</template>
      </el-table-column>
      <el-table-column v-if="isExamScene" label="时长(分钟)" width="120">
        <template #default="{ row }">{{ row.durationMinutes ?? '--' }}</template>
      </el-table-column>
      <el-table-column label="状态" width="110">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'info'">
            {{ row.status === 1 ? '已发布' : '草稿' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="300" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openQuestions(row.id)">题目管理</el-button>
          <el-button link type="primary" @click="openSubmissions(row.id)">提交记录</el-button>
          <el-button link type="primary" @click="openEdit(row.id)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="list-footer">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next, sizes"
        @current-change="fetchTasks"
        @size-change="fetchTasks"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="760px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="所属课程" prop="courseId">
          <el-select v-model="form.courseId" placeholder="请选择课程" filterable style="width: 100%">
            <el-option
              v-for="item in courseOptions"
              :key="item.id"
              :label="item.title"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item :label="`${entityName}标题`" prop="title">
          <el-input v-model="form.title" maxlength="100" />
        </el-form-item>
        <el-form-item label="总分">
          <el-input-number v-model="form.totalScore" :min="0" :max="1000" />
          <span class="field-tip">添加题目后自动按题目分值汇总</span>
        </el-form-item>
        <el-form-item label="及格分">
          <el-input-number v-model="form.passScore" :min="0" :max="1000" />
        </el-form-item>
        <el-form-item label="开放时间">
          <el-date-picker
            v-model="form.startTime"
            type="datetime"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="请选择开放时间"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="截止时间">
          <el-date-picker
            v-model="form.endTime"
            type="datetime"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="请选择截止时间"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item v-if="isExamScene" label="限时(分钟)">
          <el-input-number v-model="form.durationMinutes" :min="1" :max="1440" />
        </el-form-item>
        <el-form-item v-if="!isExamScene" label="可补交次数">
          <el-input-number v-model="form.allowRetakeCount" :min="0" :max="20" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="0">草稿</el-radio>
            <el-radio :value="1">发布</el-radio>
          </el-radio-group>
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
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getTeacherCourseList } from '@/api/teacherCourse'
import {
  createTeacherTask,
  deleteTeacherTask,
  getTeacherTaskDetail,
  getTeacherTaskList,
  updateTeacherTask
} from '@/api/teacherTask'
import {
  createTeacherExam,
  deleteTeacherExam,
  getTeacherExamDetail,
  getTeacherExamList,
  updateTeacherExam
} from '@/api/teacherExam'

const route = useRoute()
const router = useRouter()
const tasks = ref([])
const total = ref(0)
const courseOptions = ref([])
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()
const initialized = ref(false)

const isExamScene = computed(() => route.meta?.scene === 'exam')
const entityName = computed(() => (isExamScene.value ? '考试' : '作业'))
const entityPluralPath = computed(() => (isExamScene.value ? 'exams' : 'tasks'))
const pageTitle = computed(() => `${entityName.value}管理`)
const dialogTitle = computed(() => `${editingId.value ? '编辑' : '新增'}${entityName.value}`)
const pageAlertText = computed(() => (
  isExamScene.value
    ? '考试创建后可继续维护题目，题目分值会自动汇总回总分。发布前至少需要配置一道题，并设置考试时长。'
    : '作业创建后可继续维护题目，题目分值会自动汇总回总分。发布前至少需要配置一道题。'
))

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  courseId: null,
  title: '',
  status: null
})

const defaultForm = () => ({
  courseId: null,
  title: '',
  totalScore: 100,
  passScore: 60,
  startTime: '',
  endTime: '',
  durationMinutes: null,
  allowRetakeCount: 1,
  status: 0
})

const form = reactive(defaultForm())

const rules = {
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }]
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '')
}

function getListRequest() {
  return isExamScene.value ? getTeacherExamList : getTeacherTaskList
}

function getDetailRequest() {
  return isExamScene.value ? getTeacherExamDetail : getTeacherTaskDetail
}

function getCreateRequest() {
  return isExamScene.value ? createTeacherExam : createTeacherTask
}

function getUpdateRequest() {
  return isExamScene.value ? updateTeacherExam : updateTeacherTask
}

function getDeleteRequest() {
  return isExamScene.value ? deleteTeacherExam : deleteTeacherTask
}

async function fetchCourseOptions() {
  const { data } = await getTeacherCourseList({ pageNum: 1, pageSize: 100 })
  courseOptions.value = data.list || []
}

async function fetchTasks() {
  const { data } = await getListRequest()(query)
  tasks.value = data.list || []
  total.value = data.total || 0
}

function resetQuery() {
  query.pageNum = 1
  query.pageSize = 10
  query.courseId = null
  query.title = ''
  query.status = null
}

function resetForm() {
  Object.assign(form, defaultForm())
  formRef.value?.clearValidate()
}

async function syncSceneData() {
  dialogVisible.value = false
  editingId.value = null
  tasks.value = []
  total.value = 0
  resetQuery()
  resetForm()
  await fetchTasks()
}

function openCreate() {
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

async function openEdit(id) {
  const { data } = await getDetailRequest()(id)
  editingId.value = id
  resetForm()
  Object.assign(form, {
    courseId: data.courseId,
    title: data.title,
    totalScore: data.totalScore ?? 100,
    passScore: data.passScore ?? 60,
    startTime: data.startTime || '',
    endTime: data.endTime || '',
    durationMinutes: data.durationMinutes ?? null,
    allowRetakeCount: data.allowRetakeCount ?? (isExamScene.value ? 0 : 1),
    status: data.status ?? 0
  })
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = {
      courseId: form.courseId,
      title: form.title,
      totalScore: form.totalScore,
      passScore: form.passScore,
      startTime: form.startTime || null,
      endTime: form.endTime || null,
      allowRetakeCount: isExamScene.value ? 0 : form.allowRetakeCount,
      status: form.status,
      ...(isExamScene.value ? { durationMinutes: form.durationMinutes || null } : {})
    }
    if (editingId.value) {
      await getUpdateRequest()(editingId.value, payload)
      ElMessage.success(`${entityName.value}已更新`)
    } else {
      await getCreateRequest()(payload)
      ElMessage.success(`${entityName.value}已创建`)
    }
    dialogVisible.value = false
    await fetchTasks()
  } finally {
    saving.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除${entityName.value}“${row.title}”吗？`, `删除${entityName.value}`, { type: 'warning' })
  await getDeleteRequest()(row.id)
  ElMessage.success(`${entityName.value}已删除`)
  await fetchTasks()
}

function openQuestions(id) {
  router.push(`/teacher/course-management/${entityPluralPath.value}/${id}/questions`)
}

function openSubmissions(id) {
  router.push(`/teacher/course-management/${entityPluralPath.value}/${id}/submissions`)
}

function rowIndex(index) {
  return (query.pageNum - 1) * query.pageSize + index + 1
}

onMounted(async () => {
  await fetchCourseOptions()
  initialized.value = true
  await syncSceneData()
})

watch(
  () => route.fullPath,
  async () => {
    if (!initialized.value) {
      return
    }
    await syncSceneData()
  }
)
</script>

<style scoped>
.page-alert {
  margin-bottom: 16px;
}

.field-tip {
  margin-left: 12px;
  color: var(--text-secondary);
  font-size: 12px;
}
</style>
