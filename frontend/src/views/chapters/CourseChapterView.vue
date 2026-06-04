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
              :label="`${item.title} (ID:${item.id})`"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="openChapterCreate" :disabled="!courseId">新增章节</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="table-card">
      <el-table
        v-if="courseId"
        v-loading="chapterLoading"
        :data="chapters"
        :header-cell-style="{ background: '#fafbfc', color: '#5e6d82', fontWeight: '600' }"
        row-class-name="table-row"
      >
        <el-table-column type="index" label="#" width="56" align="center" />
        <el-table-column label="章节标题" min-width="280" prop="title" />
        <el-table-column label="排序" width="90" align="center" prop="sort" />
        <el-table-column label="小节数" width="90" align="center">
          <template #default="{ row }">
            {{ row.sections?.length || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleManageSections(row)">小节</el-button>
            <el-button link type="primary" @click="openChapterEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDeleteChapter(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="!courseId" class="empty-state">
        <div class="empty-icon-box">↑</div>
        <p>请先选择一门课程</p>
      </div>

      <div v-else-if="!chapterLoading && chapters.length === 0" class="empty-state">
        <div class="empty-icon-box">+</div>
        <p>该课程暂无章节</p>
      </div>
    </div>

    <div v-if="courseId" class="table-card section-card">
      <div class="section-toolbar">
        <div class="section-title">
          {{ currentChapter ? `${currentChapter.title} / 小节` : '小节管理' }}
        </div>
        <el-button
          type="primary"
          @click="openSectionCreate"
          :disabled="!currentChapter"
        >
          新增小节
        </el-button>
      </div>

        <el-table
        v-if="currentChapter"
        :data="currentChapter.sections || []"
        :header-cell-style="{ background: '#fafbfc', color: '#5e6d82', fontWeight: '600' }"
        row-class-name="table-row"
      >
        <el-table-column type="index" label="#" width="56" align="center" />
        <el-table-column label="小节标题" min-width="220" prop="title" />
        <el-table-column label="类型" width="110" align="center">
          <template #default="{ row }">
            {{ sectionTypeText(row.sectionType) }}
          </template>
        </el-table-column>
        <el-table-column label="时长" width="100" align="center">
          <template #default="{ row }">
            {{ row.duration || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="试看" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isFreeTrial === 1 ? 'success' : 'info'">
              {{ row.isFreeTrial === 1 ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="资料数" width="90" align="center">
          <template #default="{ row }">
            {{ row.materialCount || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="排序" width="90" align="center" prop="sort" />
        <el-table-column label="操作" width="220" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openSectionMaterials(row)">资料</el-button>
            <el-button link type="primary" @click="openSectionEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDeleteSection(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div v-else class="empty-state compact">
        <div class="empty-icon-box">#</div>
        <p>请选择一个章节</p>
      </div>
    </div>

    <el-dialog
      v-model="chapterDialogVisible"
      :title="editingChapterId ? '编辑章节' : '新增章节'"
      width="440px"
      top="8vh"
      @closed="resetChapterForm"
    >
      <el-form ref="chapterFormRef" :model="chapterForm" :rules="chapterRules" label-width="70px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="chapterForm.title" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="chapterForm.sort" :min="0" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="chapterDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="chapterSaving" @click="submitChapter">
          {{ editingChapterId ? '保存' : '新增' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="sectionDialogVisible"
      :title="editingSectionId ? '编辑小节' : '新增小节'"
      width="560px"
      top="8vh"
      @closed="resetSectionForm"
    >
      <el-form ref="sectionFormRef" :model="sectionForm" :rules="sectionRules" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="sectionForm.title" />
        </el-form-item>
        <el-form-item label="类型" prop="sectionType">
          <el-select v-model="sectionForm.sectionType" style="width: 100%">
            <el-option label="视频" :value="1" />
            <el-option label="图文" :value="2" />
            <el-option label="直播回放" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="视频地址">
          <el-input v-model="sectionForm.videoUrl" />
        </el-form-item>
        <el-form-item label="时长">
          <el-input-number v-model="sectionForm.duration" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="试看">
          <el-radio-group v-model="sectionForm.isFreeTrial">
            <el-radio :value="1">是</el-radio>
            <el-radio :value="0">否</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="sectionForm.sort" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="sectionForm.content" type="textarea" :rows="4" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="sectionDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="sectionSaving" @click="submitSection">
          {{ editingSectionId ? '保存' : '新增' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="sectionMaterialDialogVisible"
      title="小节资料"
      width="980px"
      top="6vh"
      @closed="handleSectionMaterialDialogClosed"
    >
      <div v-if="currentMaterialSection" class="section-material-toolbar">
        <div class="section-material-context">
          <div class="section-material-title">{{ currentMaterialSection.title }}</div>
          <div class="section-material-meta">
            {{ currentMaterialChapter?.title || '-' }}
          </div>
        </div>
        <el-button type="primary" @click="openMaterialCreate">上传资料</el-button>
      </div>

      <el-table
        v-loading="sectionMaterialLoading"
        :data="sectionMaterials"
        :header-cell-style="{ background: '#fafbfc', color: '#5e6d82', fontWeight: '600' }"
        row-class-name="table-row"
      >
        <el-table-column type="index" label="#" width="56" align="center" />
        <el-table-column label="资料名称" min-width="180" prop="materialName" />
        <el-table-column label="资料类型" width="110" align="center">
          <template #default="{ row }">
            {{ materialTypeText(row.materialType) }}
          </template>
        </el-table-column>
        <el-table-column label="文件地址" min-width="240" prop="fileUrl" show-overflow-tooltip />
        <el-table-column label="大小(MB)" width="110" align="center">
          <template #default="{ row }">
            {{ formatFileSizeMb(row.fileSize) }}
          </template>
        </el-table-column>
        <el-table-column label="下载权限" width="120" align="center">
          <template #default="{ row }">
            {{ downloadLimitText(row.downloadLimit) }}
          </template>
        </el-table-column>
        <el-table-column label="排序" width="90" align="center" prop="sort" />
        <el-table-column label="操作" width="150" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openMaterialEdit(row.id)">编辑</el-button>
            <el-button link type="danger" @click="handleDeleteMaterial(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog
      v-model="materialDialogVisible"
      :title="editingMaterialId ? '编辑资料' : '上传资料'"
      width="680px"
      top="8vh"
      @closed="resetMaterialForm"
    >
      <el-form ref="materialFormRef" :model="materialForm" :rules="materialRules" label-width="100px">
        <el-form-item label="资料名称" prop="materialName">
          <el-input v-model="materialForm.materialName" />
        </el-form-item>
        <el-form-item label="资料类型" prop="materialType">
          <el-select v-model="materialForm.materialType">
            <el-option label="文档" :value="1" />
            <el-option label="压缩包" :value="2" />
            <el-option label="图片" :value="3" />
            <el-option label="其他" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="文件上传" prop="uploadFile">
          <div class="upload-field">
            <input
              :key="materialFileInputKey"
              type="file"
              class="upload-input"
              @change="handleMaterialFileChange"
            />
            <p class="upload-tip">
              {{ selectedMaterialFileName || existingMaterialFileName || '支持单个文件，大小不超过 100MB' }}
            </p>
            <p v-if="materialUploadError" class="upload-error">{{ materialUploadError }}</p>
          </div>
        </el-form-item>
        <el-form-item label="下载权限">
          <el-radio-group v-model="materialForm.downloadLimit">
            <el-radio :value="0">全部学员</el-radio>
            <el-radio :value="1">已报名学员</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="materialForm.sort" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="materialDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="materialSaving" @click="submitMaterialForm">
          保存
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCourseList } from '@/api/course'
import { uploadMaterialFile } from '@/api/material'
import {
  createChapter,
  createSection,
  deleteChapter,
  deleteSection,
  getChapterTree,
  updateChapter,
  updateSection
} from '@/api/chapter'
import {
  createSectionMaterial,
  deleteSectionMaterial,
  getSectionMaterialDetail,
  getSectionMaterialList,
  updateSectionMaterial
} from '@/api/sectionMaterial'

const route = useRoute()
const router = useRouter()

const courseId = ref(null)
const courseOptions = ref([])
const chapters = ref([])
const activeChapterId = ref(null)
const chapterLoading = ref(false)

const chapterDialogVisible = ref(false)
const chapterSaving = ref(false)
const editingChapterId = ref(null)
const chapterFormRef = ref()
const chapterForm = reactive({
  title: '',
  sort: 0
})

const sectionDialogVisible = ref(false)
const sectionSaving = ref(false)
const editingSectionId = ref(null)
const sectionFormRef = ref()
const sectionForm = reactive({
  title: '',
  sectionType: 1,
  content: '',
  videoUrl: '',
  duration: 0,
  isFreeTrial: 0,
  sort: 0
})

const sectionMaterialDialogVisible = ref(false)
const sectionMaterialLoading = ref(false)
const currentMaterialSection = ref(null)
const currentMaterialChapter = ref(null)
const sectionMaterials = ref([])

const materialDialogVisible = ref(false)
const materialSaving = ref(false)
const editingMaterialId = ref(null)
const materialFormRef = ref()
const selectedMaterialUploadFile = ref(null)
const selectedMaterialFileName = ref('')
const materialUploadError = ref('')
const materialFileInputKey = ref(0)
const materialForm = reactive({
  materialName: '',
  materialType: 1,
  fileUrl: '',
  fileSize: 0,
  downloadLimit: 1,
  sort: 0
})

const chapterRules = {
  title: [{ required: true, message: '请输入章节标题', trigger: 'blur' }]
}

const sectionRules = {
  title: [{ required: true, message: '请输入小节标题', trigger: 'blur' }],
  sectionType: [{ required: true, message: '请选择小节类型', trigger: 'change' }]
}

const materialRules = {
  materialName: [{ required: true, message: '请输入资料名称', trigger: 'blur' }],
  materialType: [{ required: true, message: '请选择资料类型', trigger: 'change' }],
  uploadFile: [{
    validator: (_rule, _value, callback) => {
      if (materialForm.fileUrl || selectedMaterialUploadFile.value) {
        callback()
        return
      }
      callback(new Error('请选择上传文件'))
    },
    trigger: 'change'
  }]
}

const currentChapter = computed(() =>
  chapters.value.find((item) => item.id === activeChapterId.value) || null
)

const existingMaterialFileName = computed(() => {
  if (!materialForm.fileUrl) {
    return ''
  }
  const parts = materialForm.fileUrl.split('/')
  return parts[parts.length - 1] || materialForm.fileUrl
})

function resetChapterForm() {
  Object.assign(chapterForm, {
    title: '',
    sort: 0
  })
  editingChapterId.value = null
  chapterFormRef.value?.clearValidate()
}

function resetSectionForm() {
  Object.assign(sectionForm, {
    title: '',
    sectionType: 1,
    content: '',
    videoUrl: '',
    duration: 0,
    isFreeTrial: 0,
    sort: 0
  })
  editingSectionId.value = null
  sectionFormRef.value?.clearValidate()
}

function resetMaterialForm() {
  Object.assign(materialForm, {
    materialName: '',
    materialType: 1,
    fileUrl: '',
    fileSize: 0,
    downloadLimit: 1,
    sort: 0
  })
  editingMaterialId.value = null
  selectedMaterialUploadFile.value = null
  selectedMaterialFileName.value = ''
  materialUploadError.value = ''
  materialFileInputKey.value += 1
  materialFormRef.value?.clearValidate()
}

function sectionTypeText(value) {
  return (
    {
      1: '视频',
      2: '图文',
      3: '直播回放'
    }[value] || '未知'
  )
}

function materialTypeText(value) {
  return (
    {
      1: '文档',
      2: '压缩包',
      3: '图片',
      4: '其他'
    }[value] || '未知'
  )
}

function downloadLimitText(value) {
  return (
    {
      0: '全部学员',
      1: '已报名学员'
    }[value] || '未知'
  )
}

function formatFileSizeMb(value) {
  const size = Number(value || 0)
  return `${(size / 1024 / 1024).toFixed(2)} MB`
}

async function fetchCourseOptions() {
  const { data } = await getCourseList({ pageNum: 1, pageSize: 100 })
  courseOptions.value = data.list || []
}

async function fetchChapterTree() {
  if (!courseId.value) {
    chapters.value = []
    activeChapterId.value = null
    syncCurrentMaterialSection()
    return
  }
  chapterLoading.value = true
  try {
    const { data } = await getChapterTree(courseId.value)
    chapters.value = data || []
    if (!chapters.value.some((item) => item.id === activeChapterId.value)) {
      activeChapterId.value = chapters.value[0]?.id ?? null
    }
  } finally {
    chapterLoading.value = false
  }
  syncCurrentMaterialSection()
}

async function handleCourseChange(value) {
  sectionMaterialDialogVisible.value = false
  materialDialogVisible.value = false
  router.replace({
    path: '/course-management/chapters',
    query: { courseId: value }
  })
  activeChapterId.value = null
  await fetchChapterTree()
}

function openChapterCreate() {
  resetChapterForm()
  chapterForm.sort = chapters.value.length + 1
  chapterDialogVisible.value = true
}

function openChapterEdit(chapter) {
  editingChapterId.value = chapter.id
  Object.assign(chapterForm, {
    title: chapter.title,
    sort: chapter.sort ?? 0
  })
  chapterDialogVisible.value = true
}

function handleManageSections(chapter) {
  activeChapterId.value = chapter.id
}

function openSectionCreate() {
  if (!currentChapter.value) {
    return
  }
  resetSectionForm()
  sectionForm.sort = (currentChapter.value.sections?.length || 0) + 1
  sectionDialogVisible.value = true
}

function openSectionEdit(section) {
  editingSectionId.value = section.id
  Object.assign(sectionForm, {
    title: section.title,
    sectionType: section.sectionType,
    content: section.content,
    videoUrl: section.videoUrl,
    duration: section.duration,
    isFreeTrial: section.isFreeTrial,
    sort: section.sort
  })
  sectionDialogVisible.value = true
}

async function openSectionMaterials(section) {
  currentMaterialSection.value = section
  currentMaterialChapter.value = currentChapter.value
  sectionMaterialDialogVisible.value = true
  await fetchSectionMaterials(section.id)
}

function openMaterialCreate() {
  if (!currentMaterialSection.value) {
    return
  }
  resetMaterialForm()
  materialForm.sort = (sectionMaterials.value.length || 0) + 1
  materialDialogVisible.value = true
}

async function openMaterialEdit(id) {
  const { data } = await getSectionMaterialDetail(id)
  resetMaterialForm()
  editingMaterialId.value = id
  Object.assign(materialForm, {
    materialName: data.materialName,
    materialType: data.materialType,
    fileUrl: data.fileUrl,
    fileSize: data.fileSize,
    downloadLimit: data.downloadLimit,
    sort: data.sort
  })
  materialDialogVisible.value = true
}

async function submitChapter() {
  await chapterFormRef.value.validate()
  chapterSaving.value = true
  try {
    if (editingChapterId.value) {
      await updateChapter(editingChapterId.value, chapterForm)
      ElMessage.success('章节已更新')
    } else {
      await createChapter(courseId.value, chapterForm)
      ElMessage.success('章节已创建')
    }
    chapterDialogVisible.value = false
    await fetchChapterTree()
  } finally {
    chapterSaving.value = false
  }
}

async function submitSection() {
  await sectionFormRef.value.validate()
  sectionSaving.value = true
  try {
    if (editingSectionId.value) {
      await updateSection(editingSectionId.value, sectionForm)
      ElMessage.success('小节已更新')
    } else {
      await createSection(activeChapterId.value, sectionForm)
      ElMessage.success('小节已创建')
    }
    sectionDialogVisible.value = false
    await fetchChapterTree()
  } finally {
    sectionSaving.value = false
  }
}

async function fetchSectionMaterials(sectionId = currentMaterialSection.value?.id) {
  if (!sectionId) {
    sectionMaterials.value = []
    return
  }
  sectionMaterialLoading.value = true
  try {
    const { data } = await getSectionMaterialList(sectionId)
    sectionMaterials.value = data || []
  } finally {
    sectionMaterialLoading.value = false
  }
}

async function submitMaterialForm() {
  if (!currentMaterialSection.value) {
    return
  }
  await materialFormRef.value.validate()
  materialSaving.value = true
  try {
    const payload = {
      ...materialForm
    }

    if (selectedMaterialUploadFile.value) {
      const { data } = await uploadMaterialFile(selectedMaterialUploadFile.value)
      payload.fileUrl = data.url
      payload.fileSize = data.size
      materialUploadError.value = ''
    }

    if (editingMaterialId.value) {
      await updateSectionMaterial(editingMaterialId.value, payload)
      ElMessage.success('资料已更新')
    } else {
      await createSectionMaterial(currentMaterialSection.value.id, payload)
      ElMessage.success('资料已上传')
    }

    materialDialogVisible.value = false
    await refreshSectionMaterialsState()
  } finally {
    materialSaving.value = false
  }
}

async function handleDeleteChapter(chapter) {
  await ElMessageBox.confirm(`确定删除章节“${chapter.title}”吗？`, '删除章节', { type: 'warning' })
  await deleteChapter(chapter.id)
  ElMessage.success('章节已删除')
  if (activeChapterId.value === chapter.id) {
    activeChapterId.value = null
  }
  await fetchChapterTree()
}

async function handleDeleteSection(section) {
  await ElMessageBox.confirm(`确定删除小节“${section.title}”吗？`, '删除小节', { type: 'warning' })
  await deleteSection(section.id)
  ElMessage.success('小节已删除')
  await fetchChapterTree()
}

async function handleDeleteMaterial(id) {
  await ElMessageBox.confirm('确定删除该小节资料吗？', '删除资料', { type: 'warning' })
  await deleteSectionMaterial(id)
  ElMessage.success('资料已删除')
  await refreshSectionMaterialsState()
}

function validateMaterialFile(file) {
  const maxSize = 100 * 1024 * 1024
  if (file.size > maxSize) {
    materialUploadError.value = '单个文件大小不能超过 100MB'
    return false
  }
  return true
}

function handleMaterialFileChange(event) {
  const target = event.target
  const file = target.files?.[0]

  materialUploadError.value = ''

  if (!file) {
    selectedMaterialUploadFile.value = null
    selectedMaterialFileName.value = ''
    materialFormRef.value?.validateField('uploadFile')
    return
  }

  if (!validateMaterialFile(file)) {
    selectedMaterialUploadFile.value = null
    selectedMaterialFileName.value = ''
    materialFileInputKey.value += 1
    materialFormRef.value?.validateField('uploadFile')
    return
  }

  selectedMaterialUploadFile.value = file
  selectedMaterialFileName.value = file.name
  if (!materialForm.materialName) {
    materialForm.materialName = file.name
  }
  materialFormRef.value?.validateField('uploadFile')
}

function syncCurrentMaterialSection() {
  if (!currentMaterialSection.value) {
    currentMaterialChapter.value = currentChapter.value
    return
  }

  for (const chapter of chapters.value) {
    const section = chapter.sections?.find((item) => item.id === currentMaterialSection.value.id)
    if (section) {
      currentMaterialSection.value = section
      currentMaterialChapter.value = chapter
      return
    }
  }

  currentMaterialSection.value = null
  currentMaterialChapter.value = null
  sectionMaterials.value = []
  sectionMaterialDialogVisible.value = false
  materialDialogVisible.value = false
}

async function refreshSectionMaterialsState() {
  const sectionId = currentMaterialSection.value?.id
  await fetchChapterTree()
  if (sectionId && currentMaterialSection.value) {
    await fetchSectionMaterials(sectionId)
  }
}

function handleSectionMaterialDialogClosed() {
  currentMaterialSection.value = null
  currentMaterialChapter.value = null
  sectionMaterials.value = []
  materialDialogVisible.value = false
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
        path: '/course-management/chapters',
        query: { courseId: courseId.value }
      })
    }
  }
  await fetchChapterTree()
})

watch(
  () => route.query.courseId,
  async (value) => {
    const nextId = Number(value)
    if (!Number.isFinite(nextId) || nextId <= 0 || nextId === courseId.value) {
      return
    }
    courseId.value = nextId
    activeChapterId.value = null
    sectionMaterialDialogVisible.value = false
    materialDialogVisible.value = false
    await fetchChapterTree()
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

.table-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
  padding-bottom: 20px;
}

.table-card + .table-card {
  margin-top: 14px;
}

.table-card :deep(.table-row:hover) {
  background: #f6f9ff !important;
}

.section-card {
  overflow: hidden;
}

.section-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px 10px;
}

.section-title {
  font-size: 16px;
  font-weight: 700;
}

.section-material-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}

.section-material-context {
  min-width: 0;
}

.section-material-title {
  font-size: 16px;
  font-weight: 700;
}

.section-material-meta {
  margin-top: 6px;
  color: #909399;
  font-size: 13px;
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
  color: #909399;
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

.empty-state.compact {
  padding: 48px 0 36px;
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
  .section-material-toolbar {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
