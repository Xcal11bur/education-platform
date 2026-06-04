<template>
  <div class="page-card">
    <div class="page-header">
      <div>
        <h2 class="page-title">课程资料</h2>
      </div>
      <div class="toolbar">
        <el-button @click="goBack">返回课程列表</el-button>
        <el-button type="primary" @click="openCreate">新增资料</el-button>
      </div>
    </div>

    <div v-if="courseInfo" class="page-card" style="margin-bottom:18px; padding:16px;">
      <div style="font-size:18px; font-weight:700;">{{ courseInfo.title }}</div>
      <div class="muted" style="margin-top:6px;">
        {{ courseInfo.teacher?.name || '-' }} / {{ courseInfo.categoryLevel1?.name || '-' }} / {{ courseInfo.categoryLevel2?.name || '-' }}
      </div>
    </div>

    <div class="filter-bar">
      <el-input v-model="query.materialName" placeholder="资料名称" clearable />
      <el-select v-model="query.materialType" placeholder="资料类型" clearable>
        <el-option label="文档" :value="1" />
        <el-option label="压缩包" :value="2" />
        <el-option label="图片" :value="3" />
        <el-option label="其他" :value="4" />
      </el-select>
      <el-button type="primary" @click="fetchMaterials">查询</el-button>
    </div>

    <el-table :data="materials" border>
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="materialName" label="资料名称" min-width="180" />
      <el-table-column label="资料类型" width="120">
        <template #default="{ row }">{{ materialTypeText(row.materialType) }}</template>
      </el-table-column>
      <el-table-column prop="fileUrl" label="文件地址" min-width="260" show-overflow-tooltip />
      <el-table-column prop="fileSize" label="大小(字节)" width="120" />
      <el-table-column label="下载权限" width="130">
        <template #default="{ row }">{{ downloadLimitText(row.downloadLimit) }}</template>
      </el-table-column>
      <el-table-column prop="sort" label="排序" width="90" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row.id)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="list-footer">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next, sizes"
        @current-change="fetchMaterials"
        @size-change="fetchMaterials"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑资料' : '新增资料'" width="680px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="资料名称" prop="materialName">
          <el-input v-model="form.materialName" />
        </el-form-item>
        <el-form-item label="资料类型" prop="materialType">
          <el-select v-model="form.materialType">
            <el-option label="文档" :value="1" />
            <el-option label="压缩包" :value="2" />
            <el-option label="图片" :value="3" />
            <el-option label="其他" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="文件地址" prop="fileUrl">
          <el-input v-model="form.fileUrl" />
        </el-form-item>
        <el-form-item label="上传文件">
          <el-upload
            :show-file-list="false"
            :http-request="handleUpload"
            :before-upload="beforeUpload"
          >
            <el-button type="primary" :loading="uploading">上传到 OSS</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item label="文件大小">
          <el-input-number v-model="form.fileSize" :min="0" />
        </el-form-item>
        <el-form-item label="下载权限">
          <el-radio-group v-model="form.downloadLimit">
            <el-radio :value="0">全部学员</el-radio>
            <el-radio :value="1">已报名学员</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sort" :min="0" />
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
import { onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCourseDetail } from '@/api/course'
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
const courseId = Number(route.params.id)

const courseInfo = ref(null)
const materials = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const editingId = ref(null)
const saving = ref(false)
const uploading = ref(false)
const formRef = ref()

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  courseId,
  materialName: '',
  materialType: null
})

const defaultForm = () => ({
  courseId,
  materialName: '',
  materialType: 1,
  fileUrl: '',
  fileSize: 0,
  downloadLimit: 1,
  sort: 0
})

const form = reactive(defaultForm())

const rules = {
  materialName: [{ required: true, message: '请输入资料名称', trigger: 'blur' }],
  materialType: [{ required: true, message: '请选择资料类型', trigger: 'change' }],
  fileUrl: [{ required: true, message: '请输入文件地址', trigger: 'blur' }]
}

function materialTypeText(value) {
  return ({ 1: '文档', 2: '压缩包', 3: '图片', 4: '其他' }[value] || '未知')
}

function downloadLimitText(value) {
  return ({ 0: '全部学员', 1: '已报名学员' }[value] || '未知')
}

async function fetchCourseInfo() {
  const { data } = await getCourseDetail(courseId)
  courseInfo.value = data
}

async function fetchMaterials() {
  const { data } = await getMaterialList(query)
  materials.value = data.list
  total.value = data.total
}

function resetForm() {
  Object.assign(form, defaultForm())
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
    fileSize: data.fileSize,
    downloadLimit: data.downloadLimit,
    sort: data.sort
  })
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    if (editingId.value) {
      await updateMaterial(editingId.value, form)
      ElMessage.success('资料已更新')
    } else {
      await createMaterial(form)
      ElMessage.success('资料已创建')
    }
    dialogVisible.value = false
    fetchMaterials()
  } finally {
    saving.value = false
  }
}

function beforeUpload(file) {
  const maxSize = 50 * 1024 * 1024
  if (file.size > maxSize) {
    ElMessage.error('单个文件大小不能超过 50MB')
    return false
  }
  return true
}

async function handleUpload(option) {
  uploading.value = true
  try {
    const { data } = await uploadMaterialFile(option.file)
    form.fileUrl = data.url
    form.fileSize = data.size
    if (!form.materialName) {
      form.materialName = data.originalFilename
    }
    ElMessage.success('文件已上传到 OSS')
    option.onSuccess?.(data)
  } catch (error) {
    option.onError?.(error)
  } finally {
    uploading.value = false
  }
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确认删除该课程资料？', '删除资料', { type: 'warning' })
  await deleteMaterial(id)
  ElMessage.success('资料已删除')
  fetchMaterials()
}

function goBack() {
  router.push('/courses')
}

onMounted(async () => {
  await fetchCourseInfo()
  await fetchMaterials()
})
</script>
