<template>
  <div class="page-card">
    <div class="search-card">
      <el-form :inline="true">
        <el-form-item label="选择课程">
          <el-select
            v-model="courseId"
            placeholder="请选择课程"
            filterable
            style="width: 280px"
            @change="handleCourseChange"
          >
            <el-option
              v-for="item in courseOptions"
              :key="item.id"
              :label="item.title"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="openCreate" :disabled="!courseId">新增{{ entityName }}</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div v-if="courseInfo" class="task-toolbar">
      <div class="task-course-info">
        <div class="task-course-title">{{ courseInfo.title }}</div>
        <div class="muted" style="margin-top: 6px;">
          {{ courseInfo.teacher?.name || '-' }} / {{ courseInfo.categoryLevel1?.name || '-' }} / {{ courseInfo.categoryLevel2?.name || '-' }}
        </div>
      </div>
    </div>

    <el-table v-if="courseId" v-loading="listLoading" :data="tasks" border>
      <el-table-column label="ID" width="90">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column :label="`${entityName}标题`" prop="title" min-width="220" />
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

    <div v-if="courseId" class="list-footer">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next, sizes"
        @current-change="fetchTasks"
        @size-change="handlePageSizeChange"
      />
    </div>

    <div v-if="!courseId" class="empty-state">
      <div class="empty-icon-box">↑</div>
      <p>请先选择一门课程</p>
    </div>

    <div v-else-if="!listLoading && tasks.length === 0" class="empty-state">
      <div class="empty-icon-box">{{ isExamScene ? 'E' : 'T' }}</div>
      <p>该课程暂无{{ entityName }}</p>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="760px" @closed="resetForm">
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
import { getTeacherCourseDetail, getTeacherCourseList } from '@/api/teacherCourse'
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

const courseId = ref(null)
const courseOptions = ref([])
const courseInfo = ref(null)
const tasks = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const saving = ref(false)
const listLoading = ref(false)
const editingId = ref(null)
const formRef = ref()
const initialized = ref(false)

const isExamScene = computed(() => route.meta?.scene === 'exam')
const entityName = computed(() => (isExamScene.value ? '考试' : '作业'))
const entityPluralPath = computed(() => (isExamScene.value ? 'exams' : 'tasks'))
const dialogTitle = computed(() => `${editingId.value ? '编辑' : '新增'}${entityName.value}`)
const routeBasePath = computed(() => `/teacher/course-management/${entityPluralPath.value}`)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  courseId: null
})

const defaultForm = () => ({
  courseId: courseId.value,
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

async function fetchCourseInfo() {
  if (!courseId.value) {
    courseInfo.value = null
    return
  }
  const { data } = await getTeacherCourseDetail(courseId.value)
  courseInfo.value = data
}

async function fetchTasks() {
  if (!courseId.value) {
    tasks.value = []
    total.value = 0
    return
  }
  query.courseId = courseId.value
  listLoading.value = true
  try {
    const { data } = await getListRequest()(query)
    tasks.value = data.list || []
    total.value = data.total || 0
  } finally {
    listLoading.value = false
  }
}

function resetForm() {
  Object.assign(form, defaultForm())
  formRef.value?.clearValidate()
}

async function syncCourseContext() {
  await Promise.all([fetchCourseInfo(), fetchTasks()])
}

async function initializeCourseContext() {
  await fetchCourseOptions()
  const routeCourseId = Number(route.query.courseId)
  const hasRouteCourse = Number.isFinite(routeCourseId) && routeCourseId > 0
  const matchedCourse = hasRouteCourse
    ? courseOptions.value.find((item) => item.id === routeCourseId)
    : null

  if (matchedCourse) {
    courseId.value = matchedCourse.id
  } else {
    courseId.value = courseOptions.value[0]?.id ?? null
    if (courseId.value) {
      router.replace({ path: routeBasePath.value, query: { courseId: courseId.value } })
    }
  }

  query.pageNum = 1
  query.courseId = courseId.value
  await syncCourseContext()
}

async function handleCourseChange(value) {
  query.pageNum = 1
  query.courseId = value
  router.replace({ path: routeBasePath.value, query: value ? { courseId: value } : {} })
  await syncCourseContext()
}

async function handlePageSizeChange() {
  query.pageNum = 1
  await fetchTasks()
}

function openCreate() {
  editingId.value = null
  resetForm()
  form.courseId = courseId.value
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
    allowRetakeCount: data.allowRetakeCount ?? 1,
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
      ...(!isExamScene.value ? { allowRetakeCount: form.allowRetakeCount } : {}),
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
  if (tasks.value.length === 1 && query.pageNum > 1) {
    query.pageNum -= 1
  }
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
  await initializeCourseContext()
  initialized.value = true
})

watch(
  () => route.query.courseId,
  async (value) => {
    if (!initialized.value) {
      return
    }
    const nextId = Number(value)
    if (!Number.isFinite(nextId) || nextId <= 0 || nextId === courseId.value) {
      return
    }
    courseId.value = nextId
    query.pageNum = 1
    query.courseId = nextId
    await syncCourseContext()
  }
)

watch(
  () => isExamScene.value,
  async () => {
    if (!initialized.value) {
      return
    }
    dialogVisible.value = false
    editingId.value = null
    await fetchTasks()
  }
)
</script>

<style scoped>
.search-card {
  background: #fff;
  border-radius: 10px;
  padding: 16px 20px 4px;
  margin-bottom: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
}

.search-card :deep(.el-form-item) {
  margin-bottom: 12px;
}

.task-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 18px;
}

.task-course-info {
  min-width: 0;
}

.task-course-title {
  font-size: 18px;
  font-weight: 700;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
}

.empty-icon-box {
  width: 72px;
  height: 72px;
  margin: 0 auto 16px;
  border-radius: 50%;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #c0c4cc;
}

.empty-state p {
  color: #909399;
  font-size: 14px;
}

@media (max-width: 900px) {
  .task-toolbar {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
