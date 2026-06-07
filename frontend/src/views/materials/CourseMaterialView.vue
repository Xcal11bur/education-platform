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
          <el-button type="primary" @click="openCreate" :disabled="!courseId">上传资料</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div v-if="courseInfo" class="material-toolbar">
      <div class="material-course-info">
        <div class="material-course-title">{{ courseInfo.title }}</div>
        <div class="muted" style="margin-top: 6px;">
          {{ courseInfo.teacher?.name || '-' }} / {{ courseInfo.categoryLevel1?.name || '-' }} / {{ courseInfo.categoryLevel2?.name || '-' }}
        </div>
      </div>
    </div>

    <div v-if="courseId" class="filter-bar">
      <el-input v-model="query.materialName" placeholder="资料名称" clearable />
      <el-select v-model="query.materialType" placeholder="资料类型" clearable>
        <el-option label="文档" :value="1" />
        <el-option label="压缩包" :value="2" />
        <el-option label="图片" :value="3" />
        <el-option label="其他" :value="4" />
      </el-select>
      <el-button type="primary" @click="fetchMaterials">查询</el-button>
    </div>

    <el-table v-if="courseId" :data="materials" border>
      <el-table-column label="ID" width="90">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column prop="materialName" label="资料名称" min-width="180" />
      <el-table-column label="资料类型" width="120">
        <template #default="{ row }">{{ materialTypeText(row.materialType) }}</template>
      </el-table-column>
      <el-table-column prop="fileUrl" label="文件地址" min-width="260" show-overflow-tooltip />
      <el-table-column label="大小(MB)" width="120">
        <template #default="{ row }">{{ formatFileSizeMb(row.fileSize) }}</template>
      </el-table-column>
      <el-table-column label="下载权限" width="130">
        <template #default="{ row }">{{ downloadLimitText(row.downloadLimit) }}</template>
      </el-table-column>
      <el-table-column label="上传时间" width="170">
        <template #default="{ row }">{{ formatUploadTime(row.createdAt) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row.id)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div v-if="courseId" class="list-footer">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next, sizes"
        @current-change="fetchMaterials"
        @size-change="fetchMaterials"
      />
    </div>

    <div v-if="!courseId" class="empty-state">
      <div class="empty-icon-box">↑</div>
      <p>请先选择一门课程</p>
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑资料' : '新增资料'" width="680px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="资料类型" prop="materialType">
          <el-select v-model="form.materialType">
            <el-option label="文档" :value="1" />
            <el-option label="压缩包" :value="2" />
            <el-option label="图片" :value="3" />
            <el-option label="其他" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="文件上传" prop="uploadFile">
          <div class="upload-field">
            <input
              :key="fileInputKey"
              type="file"
              class="upload-input"
              @change="handleFileChange"
            />
            <p class="upload-tip">
              {{ selectedFileName || existingFileName || '支持单个文件，大小不超过 100MB' }}
            </p>
            <p v-if="uploadError" class="upload-error">{{ uploadError }}</p>
          </div>
        </el-form-item>
        <el-form-item label="下载权限">
          <el-radio-group v-model="form.downloadLimit">
            <el-radio :value="0">全部学员</el-radio>
            <el-radio :value="1">已报名学员</el-radio>
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
import { getCourseDetail, getCourseList } from '@/api/course'
import {
  createMaterial,
  deleteMaterial,
  getMaterialDetail,
  getMaterialList,
  uploadMaterialFile,
  updateMaterial
} from '@/api/material'

const route = useRoute()
const router = useRouter()

const courseId = ref(null)
const courseOptions = ref([])
const courseInfo = ref(null)
const materials = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const editingId = ref(null)
const saving = ref(false)
const uploading = ref(false)
const formRef = ref()
const selectedUploadFile = ref(null)
const selectedFileName = ref('')
const uploadError = ref('')
const fileInputKey = ref(0)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  courseId: null,
  materialName: '',
  materialType: null
})

const defaultForm = () => ({
  courseId: courseId.value,
  materialName: '',
  materialType: 1,
  fileUrl: '',
  downloadLimit: 1
})

const form = reactive(defaultForm())

const existingFileName = computed(() => {
  if (!form.fileUrl) {
    return ''
  }
  const parts = form.fileUrl.split('/')
  return parts[parts.length - 1] || form.fileUrl
})

const rules = {
  materialType: [{ required: true, message: '请选择资料类型', trigger: 'change' }],
  uploadFile: [{
    validator: (_rule, _value, callback) => {
      if (form.fileUrl || selectedUploadFile.value) {
        callback()
        return
      }
      callback(new Error('请选择上传文件'))
    },
    trigger: 'change'
  }]
}

function materialTypeText(value) {
  return ({ 1: '文档', 2: '压缩包', 3: '图片', 4: '其他' }[value] || '未知')
}

function downloadLimitText(value) {
  return ({ 0: '全部学员', 1: '已报名学员' }[value] || '未知')
}

function formatFileSizeMb(value) {
  const size = Number(value || 0)
  return `${(size / 1024 / 1024).toFixed(2)} MB`
}

function rowIndex(index) {
  return (query.pageNum - 1) * query.pageSize + index + 1
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

async function fetchCourseOptions() {
  const { data } = await getCourseList({ pageNum: 1, pageSize: 100 })
  courseOptions.value = data.list || []
}

async function fetchCourseInfo() {
  if (!courseId.value) {
    courseInfo.value = null
    return
  }
  const { data } = await getCourseDetail(courseId.value)
  courseInfo.value = data
}

async function fetchMaterials() {
  if (!courseId.value) {
    materials.value = []
    total.value = 0
    return
  }
  query.courseId = courseId.value
  const { data } = await getMaterialList(query)
  materials.value = data.list
  total.value = data.total
}

function resetForm() {
  Object.assign(form, defaultForm())
  selectedUploadFile.value = null
  selectedFileName.value = ''
  uploadError.value = ''
  fileInputKey.value += 1
}

function openCreate() {
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

async function openEdit(id) {
  const { data } = await getMaterialDetail(id)
  editingId.value = id
  resetForm()
  Object.assign(form, {
    courseId: data.courseId,
    materialName: data.materialName,
    materialType: data.materialType,
    fileUrl: data.fileUrl,
    downloadLimit: data.downloadLimit
  })
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = {
      ...form,
      courseId: courseId.value
    }

    if (selectedUploadFile.value) {
      uploading.value = true
      try {
        const { data } = await uploadMaterialFile(selectedUploadFile.value)
        payload.fileUrl = data.url
        payload.fileSize = data.size
        payload.materialName = data.originalFilename || selectedUploadFile.value.name
        uploadError.value = ''
      } finally {
        uploading.value = false
      }
    }

    if (editingId.value) {
      await updateMaterial(editingId.value, payload)
      ElMessage.success('资料已更新')
    } else {
      await createMaterial(payload)
      ElMessage.success('资料已创建')
    }
    dialogVisible.value = false
    await fetchMaterials()
  } finally {
    saving.value = false
  }
}

function validateFile(file) {
  const maxSize = 100 * 1024 * 1024
  if (file.size > maxSize) {
    uploadError.value = '单个文件大小不能超过 100MB'
    return false
  }
  return true
}

function handleFileChange(event) {
  const target = event.target
  const file = target.files?.[0]

  uploadError.value = ''

  if (!file) {
    selectedUploadFile.value = null
    selectedFileName.value = ''
    formRef.value?.validateField('uploadFile')
    return
  }

  if (!validateFile(file)) {
    selectedUploadFile.value = null
    selectedFileName.value = ''
    fileInputKey.value += 1
    formRef.value?.validateField('uploadFile')
    return
  }

  selectedUploadFile.value = file
  selectedFileName.value = file.name
  form.materialName = file.name
  formRef.value?.validateField('uploadFile')
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确认删除该课程资料？', '删除资料', { type: 'warning' })
  await deleteMaterial(id)
  ElMessage.success('资料已删除')
  await fetchMaterials()
}

async function syncCourseContext() {
  await Promise.all([fetchCourseInfo(), fetchMaterials()])
}

async function handleCourseChange(value) {
  query.pageNum = 1
  query.materialName = ''
  query.materialType = null
  router.replace({
    path: '/course-management/materials',
    query: { courseId: value }
  })
  await syncCourseContext()
}

onMounted(async () => {
  await fetchCourseOptions()
  const routeCourseId = Number(route.query.courseId)
  if (Number.isFinite(routeCourseId) && routeCourseId > 0) {
    courseId.value = routeCourseId
  } else {
    courseId.value = courseOptions.value[0]?.id ?? null
    if (courseId.value) {
      router.replace({
        path: '/course-management/materials',
        query: { courseId: courseId.value }
      })
    }
  }
  query.courseId = courseId.value
  await syncCourseContext()
})

watch(
  () => route.query.courseId,
  async (value) => {
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

.material-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 18px;
}

.material-course-info {
  min-width: 0;
}

.material-course-title {
  font-size: 18px;
  font-weight: 700;
}

.upload-field {
  width: 100%;
}

.upload-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  background: #fff;
  box-sizing: border-box;
}

.upload-input::file-selector-button {
  margin-right: 12px;
  border: 0;
  border-radius: 6px;
  background: rgba(64, 158, 255, 0.12);
  color: #409eff;
  padding: 8px 12px;
  cursor: pointer;
}

.upload-tip {
  margin-top: 8px;
  font-size: 12px;
  color: var(--text-secondary);
}

.upload-error {
  margin-top: 4px;
  font-size: 12px;
  color: var(--el-color-danger);
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
  .material-toolbar {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
