<template>
  <div class="page-card">
    <div class="toolbar" style="justify-content: flex-end; margin-bottom: 18px;">
      <el-button type="primary" @click="openCreate">新增课程</el-button>
    </div>

    <div class="filter-bar">
      <el-input v-model="query.title" placeholder="课程标题" clearable />
      <el-select v-model="query.teacherId" placeholder="教师" clearable>
        <el-option v-for="item in teacherOptions" :key="item.id" :label="item.name" :value="item.id" />
      </el-select>
      <el-select v-model="query.categoryLevel2Id" placeholder="二级分类" clearable>
        <el-option
          v-for="item in level2CategoryOptions"
          :key="item.id"
          :label="`${item.parentName} / ${item.name}`"
          :value="item.id"
        />
      </el-select>
      <el-select v-model="query.publishStatus" placeholder="发布状态" clearable>
        <el-option label="草稿" :value="0" />
        <el-option label="已上架" :value="1" />
        <el-option label="已下架" :value="2" />
      </el-select>
      <el-button type="primary" @click="fetchCourses">查询</el-button>
    </div>

    <el-table :data="courses" border>
      <el-table-column label="ID" width="90">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column prop="title" label="课程标题" min-width="200" />
      <el-table-column prop="teacherName" label="教师" min-width="120" />
      <el-table-column label="分类" min-width="180">
        <template #default="{ row }">
          {{ row.categoryLevel1Name }} / {{ row.categoryLevel2Name }}
        </template>
      </el-table-column>
      <el-table-column prop="price" label="价格" width="100" />
      <el-table-column label="状态" width="120">
        <template #default="{ row }">
          <el-tag :type="publishStatusTag(row.publishStatus)">{{ publishStatusText(row.publishStatus) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="studyCount" label="学习人数" width="110" />
      <el-table-column label="操作" width="390" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row.id)">编辑</el-button>
          <el-button link type="primary" @click="goChapters(row.id)">章节</el-button>
          <el-button link type="primary" @click="goMaterials(row.id)">资料</el-button>
          <el-button
            link
            :type="row.publishStatus === 1 ? 'warning' : 'success'"
            @click="togglePublish(row)"
          >
            {{ row.publishStatus === 1 ? '下架' : '上架' }}
          </el-button>
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
        @current-change="fetchCourses"
        @size-change="fetchCourses"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑课程' : '新增课程'" width="760px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="课程标题" prop="title">
          <el-input v-model="form.title" />
        </el-form-item>
        <el-form-item label="副标题">
          <el-input v-model="form.subTitle" />
        </el-form-item>
        <el-form-item label="教师" prop="teacherId">
          <el-select v-model="form.teacherId" placeholder="请选择教师">
            <el-option v-for="item in teacherOptions" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="一级分类" prop="categoryLevel1Id">
          <el-select v-model="form.categoryLevel1Id" placeholder="请选择一级分类" @change="handleLevel1Change">
            <el-option v-for="item in level1Categories" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="二级分类" prop="categoryLevel2Id">
          <el-select v-model="form.categoryLevel2Id" placeholder="请选择二级分类">
            <el-option v-for="item in currentLevel2Options" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="form.difficulty">
            <el-option label="初级" :value="1" />
            <el-option label="中级" :value="2" />
            <el-option label="高级" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="价格">
          <el-input-number v-model="form.price" :min="0" :precision="2" />
        </el-form-item>
        <el-form-item label="课程封面" prop="coverUpload">
          <div class="upload-field">
            <input
              :key="coverFileInputKey"
              type="file"
              class="upload-input"
              accept="image/*"
              @change="handleCoverFileChange"
            />
            <p class="upload-tip">
              {{ selectedCoverFileName || existingCoverFileName || '仅支持图片文件，保存时自动上传到 OSS' }}
            </p>
            <p v-if="coverUploadError" class="upload-error">{{ coverUploadError }}</p>
          </div>
        </el-form-item>
        <el-form-item label="发布状态">
          <el-radio-group v-model="form.publishStatus">
            <el-radio :value="0">草稿</el-radio>
            <el-radio :value="1">已上架</el-radio>
            <el-radio :value="2">已下架</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="课程详情">
          <el-input v-model="form.description" type="textarea" :rows="5" />
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
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getTeacherList } from '@/api/teacher'
import { getCategoryTree } from '@/api/category'
import {
  createCourse,
  deleteCourse,
  getCourseDetail,
  getCourseList,
  uploadCourseCoverFile,
  updateCourse,
  updateCoursePublishStatus
} from '@/api/course'

const router = useRouter()
const courses = ref([])
const total = ref(0)
const teacherOptions = ref([])
const categoryTree = ref([])
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()
const selectedCoverFile = ref(null)
const selectedCoverFileName = ref('')
const coverUploadError = ref('')
const coverFileInputKey = ref(0)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  title: '',
  teacherId: null,
  categoryLevel2Id: null,
  publishStatus: null
})

const defaultForm = () => ({
  title: '',
  subTitle: '',
  teacherId: null,
  categoryLevel1Id: null,
  categoryLevel2Id: null,
  coverUrl: '',
  description: '',
  difficulty: 1,
  price: 0,
  publishStatus: 0
})

const form = reactive(defaultForm())

const rules = {
  title: [{ required: true, message: '请输入课程标题', trigger: 'blur' }],
  teacherId: [{ required: true, message: '请选择教师', trigger: 'change' }],
  categoryLevel1Id: [{ required: true, message: '请选择一级分类', trigger: 'change' }],
  categoryLevel2Id: [{ required: true, message: '请选择二级分类', trigger: 'change' }],
  coverUpload: [{
    validator: (_rule, _value, callback) => {
      if (form.coverUrl || selectedCoverFile.value) {
        callback()
        return
      }
      callback(new Error('请选择课程封面'))
    },
    trigger: 'change'
  }]
}

const level1Categories = computed(() => categoryTree.value)

const level2CategoryOptions = computed(() =>
  categoryTree.value.flatMap((parent) =>
    (parent.children || []).map((child) => ({
      ...child,
      parentName: parent.name
    }))
  )
)

const currentLevel2Options = computed(() => {
  const parent = categoryTree.value.find((item) => item.id === form.categoryLevel1Id)
  return parent?.children || []
})

const existingCoverFileName = computed(() => {
  if (!form.coverUrl) {
    return ''
  }
  const parts = form.coverUrl.split('/')
  return parts[parts.length - 1] || form.coverUrl
})

function publishStatusText(value) {
  return (
    {
      0: '草稿',
      1: '已上架',
      2: '已下架'
    }[value] || '未知'
  )
}

function publishStatusTag(value) {
  return (
    {
      0: 'info',
      1: 'success',
      2: 'warning'
    }[value] || ''
  )
}

async function fetchCourses() {
  const { data } = await getCourseList(query)
  courses.value = data.list
  total.value = data.total
}

async function fetchTeacherOptions() {
  const { data } = await getTeacherList({ pageNum: 1, pageSize: 100 })
  teacherOptions.value = data.list
}

async function fetchCategories() {
  const { data } = await getCategoryTree()
  categoryTree.value = data
}

function resetForm() {
  Object.assign(form, defaultForm())
  selectedCoverFile.value = null
  selectedCoverFileName.value = ''
  coverUploadError.value = ''
  coverFileInputKey.value += 1
  formRef.value?.clearValidate()
}

function openCreate() {
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

async function openEdit(id) {
  const { data } = await getCourseDetail(id)
  editingId.value = id
  resetForm()
  Object.assign(form, {
    title: data.title,
    subTitle: data.subTitle,
    teacherId: data.teacherId,
    categoryLevel1Id: data.categoryLevel1Id,
    categoryLevel2Id: data.categoryLevel2Id,
    coverUrl: data.coverUrl,
    description: data.description,
    difficulty: data.difficulty,
    price: Number(data.price || 0),
    publishStatus: data.publishStatus
  })
  dialogVisible.value = true
}

function handleLevel1Change() {
  form.categoryLevel2Id = null
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = {
      ...form,
      price: Number(form.price || 0)
    }

    if (selectedCoverFile.value) {
      const { data } = await uploadCourseCoverFile(selectedCoverFile.value)
      payload.coverUrl = data.url
      coverUploadError.value = ''
    }

    if (editingId.value) {
      await updateCourse(editingId.value, payload)
      ElMessage.success('课程已更新')
    } else {
      await createCourse(payload)
      ElMessage.success('课程已创建')
    }
    dialogVisible.value = false
    fetchCourses()
  } finally {
    saving.value = false
  }
}

function validateCoverFile(file) {
  const maxSize = 10 * 1024 * 1024
  const isImage = typeof file.type === 'string' && file.type.startsWith('image/')

  if (!isImage) {
    coverUploadError.value = '仅支持上传图片格式的封面文件'
    return false
  }

  if (file.size > maxSize) {
    coverUploadError.value = '课程封面大小不能超过 10MB'
    return false
  }

  return true
}

function handleCoverFileChange(event) {
  const target = event.target
  const file = target.files?.[0]

  coverUploadError.value = ''

  if (!file) {
    selectedCoverFile.value = null
    selectedCoverFileName.value = ''
    formRef.value?.validateField('coverUpload')
    return
  }

  if (!validateCoverFile(file)) {
    selectedCoverFile.value = null
    selectedCoverFileName.value = ''
    coverFileInputKey.value += 1
    formRef.value?.validateField('coverUpload')
    return
  }

  selectedCoverFile.value = file
  selectedCoverFileName.value = file.name
  formRef.value?.validateField('coverUpload')
}

async function togglePublish(row) {
  const publishStatus = row.publishStatus === 1 ? 2 : 1
  await updateCoursePublishStatus(row.id, { publishStatus })
  ElMessage.success(publishStatus === 1 ? '课程已上架' : '课程已下架')
  fetchCourses()
}

async function handleDelete(row) {
  await ElMessageBox.confirm(
    `确定删除课程“${row.title}”吗？删除后不可恢复。`,
    '删除课程',
    {
      type: 'warning',
      confirmButtonText: '确认删除',
      cancelButtonText: '取消'
    }
  )
  await deleteCourse(row.id)
  ElMessage.success('课程已删除')
  fetchCourses()
}

function rowIndex(index) {
  return (query.pageNum - 1) * query.pageSize + index + 1
}

function goChapters(id) {
  router.push({
    path: '/course-management/chapters',
    query: { courseId: id }
  })
}

function goMaterials(id) {
  router.push({
    path: '/course-management/materials',
    query: { courseId: id }
  })
}

onMounted(async () => {
  await Promise.all([fetchTeacherOptions(), fetchCategories()])
  await fetchCourses()
})
</script>

<style scoped>
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
</style>
