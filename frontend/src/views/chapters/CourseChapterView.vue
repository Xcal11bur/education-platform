<template>
  <div class="page-card">
    <div class="page-header">
      <div>
        <h2 class="page-title">章节管理</h2>
      </div>
      <div class="toolbar">
        <el-button @click="goBack">返回课程列表</el-button>
        <el-button type="primary" @click="openChapterCreate">新增章节</el-button>
      </div>
    </div>

    <div v-if="courseInfo" class="page-card" style="margin-bottom:18px; padding:16px;">
      <div style="font-size:18px; font-weight:700;">{{ courseInfo.title }}</div>
      <div class="muted" style="margin-top:6px;">
        {{ courseInfo.teacher?.name || '-' }} / {{ courseInfo.categoryLevel1?.name || '-' }} / {{ courseInfo.categoryLevel2?.name || '-' }}
      </div>
    </div>

    <div class="chapter-shell">
      <div v-for="chapter in chapters" :key="chapter.id" class="chapter-item">
        <div class="chapter-head">
          <div>
            <div class="chapter-title">{{ chapter.title }}</div>
            <div class="muted">排序：{{ chapter.sort || 0 }}</div>
          </div>
          <div>
            <el-button link type="primary" @click="openSectionCreate(chapter)">新增小节</el-button>
            <el-button link type="primary" @click="openChapterEdit(chapter)">编辑</el-button>
            <el-button link type="danger" @click="handleDeleteChapter(chapter.id)">删除</el-button>
          </div>
        </div>
        <div class="section-list">
          <div v-if="!chapter.sections?.length" class="muted">当前章节还没有小节。</div>
          <div v-for="section in chapter.sections" :key="section.id" class="section-item">
            <div>
              <div class="section-name">{{ section.title }}</div>
              <div class="muted" style="margin-top:4px;">
                类型：{{ sectionTypeText(section.sectionType) }} / 时长：{{ section.duration || 0 }} 秒 / 排序：{{ section.sort || 0 }}
              </div>
            </div>
            <div>
              <el-button link type="primary" @click="openSectionEdit(section)">编辑</el-button>
              <el-button link type="danger" @click="handleDeleteSection(section.id)">删除</el-button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <el-dialog v-model="chapterDialogVisible" :title="editingChapterId ? '编辑章节' : '新增章节'" width="520px">
      <el-form ref="chapterFormRef" :model="chapterForm" :rules="chapterRules" label-width="90px">
        <el-form-item label="章节标题" prop="title">
          <el-input v-model="chapterForm.title" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="chapterForm.sort" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="chapterDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="chapterSaving" @click="submitChapter">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="sectionDialogVisible" :title="editingSectionId ? '编辑小节' : '新增小节'" width="680px">
      <el-form ref="sectionFormRef" :model="sectionForm" :rules="sectionRules" label-width="90px">
        <el-form-item label="小节标题" prop="title">
          <el-input v-model="sectionForm.title" />
        </el-form-item>
        <el-form-item label="小节类型" prop="sectionType">
          <el-select v-model="sectionForm.sectionType">
            <el-option label="视频" :value="1" />
            <el-option label="图文" :value="2" />
            <el-option label="直播回放" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="视频地址">
          <el-input v-model="sectionForm.videoUrl" />
        </el-form-item>
        <el-form-item label="时长(秒)">
          <el-input-number v-model="sectionForm.duration" :min="0" />
        </el-form-item>
        <el-form-item label="试看">
          <el-radio-group v-model="sectionForm.isFreeTrial">
            <el-radio :value="1">是</el-radio>
            <el-radio :value="0">否</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="sectionForm.sort" :min="0" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="sectionForm.content" type="textarea" :rows="4" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="sectionDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="sectionSaving" @click="submitSection">保存</el-button>
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
const courseId = Number(route.params.id)

const courseInfo = ref(null)
const chapters = ref([])
const currentChapterId = ref(null)

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

function resetChapterForm() {
  Object.assign(chapterForm, {
    title: '',
    sort: 0
  })
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

async function fetchCourseInfo() {
  const { data } = await getCourseDetail(courseId)
  courseInfo.value = data
}

async function fetchChapterTree() {
  const { data } = await getChapterTree(courseId)
  chapters.value = data
}

function openChapterCreate() {
  editingChapterId.value = null
  resetChapterForm()
  chapterDialogVisible.value = true
}

function openChapterEdit(chapter) {
  editingChapterId.value = chapter.id
  resetChapterForm()
  Object.assign(chapterForm, {
    title: chapter.title,
    sort: chapter.sort
  })
  chapterDialogVisible.value = true
}

function openSectionCreate(chapter) {
  currentChapterId.value = chapter.id
  editingSectionId.value = null
  resetSectionForm()
  sectionDialogVisible.value = true
}

function openSectionEdit(section) {
  currentChapterId.value = section.chapterId
  editingSectionId.value = section.id
  resetSectionForm()
  Object.assign(sectionForm, section)
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
      await createChapter(courseId, chapterForm)
      ElMessage.success('章节已创建')
    }
    chapterDialogVisible.value = false
    fetchChapterTree()
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
      await createSection(currentChapterId.value, sectionForm)
      ElMessage.success('小节已创建')
    }
    sectionDialogVisible.value = false
    fetchChapterTree()
  } finally {
    sectionSaving.value = false
  }
}

async function handleDeleteChapter(id) {
  await ElMessageBox.confirm('删除章节前请先清空其下所有小节，确认继续？', '删除章节', { type: 'warning' })
  await deleteChapter(id)
  ElMessage.success('章节已删除')
  fetchChapterTree()
}

async function handleDeleteSection(id) {
  await ElMessageBox.confirm('确认删除该小节？', '删除小节', { type: 'warning' })
  await deleteSection(id)
  ElMessage.success('小节已删除')
  fetchChapterTree()
}

function goBack() {
  router.push('/courses')
}

onMounted(async () => {
  await fetchCourseInfo()
  await fetchChapterTree()
})
</script>
