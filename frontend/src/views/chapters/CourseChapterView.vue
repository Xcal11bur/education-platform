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
        <el-table-column label="排序" width="90" align="center" prop="sort" />
        <el-table-column label="操作" width="160" align="center">
          <template #default="{ row }">
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
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCourseList } from '@/api/course'
import {
  createChapter,
  createSection,
  deleteChapter,
  deleteSection,
  getChapterTree,
  updateChapter,
  updateSection
} from '@/api/chapter'

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

const chapterRules = {
  title: [{ required: true, message: '请输入章节标题', trigger: 'blur' }]
}

const sectionRules = {
  title: [{ required: true, message: '请输入小节标题', trigger: 'blur' }],
  sectionType: [{ required: true, message: '请选择小节类型', trigger: 'change' }]
}

const currentChapter = computed(() =>
  chapters.value.find((item) => item.id === activeChapterId.value) || null
)

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

function sectionTypeText(value) {
  return (
    {
      1: '视频',
      2: '图文',
      3: '直播回放'
    }[value] || '未知'
  )
}

async function fetchCourseOptions() {
  const { data } = await getCourseList({ pageNum: 1, pageSize: 100 })
  courseOptions.value = data.list || []
}

async function fetchChapterTree() {
  if (!courseId.value) {
    chapters.value = []
    activeChapterId.value = null
    return
  }
  chapterLoading.value = true
  try {
    const { data } = await getChapterTree(courseId.value)
    chapters.value = data || []
    if (chapters.value.some((item) => item.id === activeChapterId.value)) {
      return
    }
    activeChapterId.value = chapters.value[0]?.id ?? null
  } finally {
    chapterLoading.value = false
  }
}

async function handleCourseChange(value) {
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
</style>
