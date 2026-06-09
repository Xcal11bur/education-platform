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
        <el-table-column label="试看" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isFreeTrial === 1 ? 'success' : 'info'">
              {{ row.isFreeTrial === 1 ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openSectionContents(row)">内容</el-button>
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
      </el-form>
      <template #footer>
        <el-button @click="chapterDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="chapterSaving" @click="submitChapter">
          {{ editingChapterId ? '保存' : '新增' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="sectionContentDialogVisible"
      title="小节内容项"
      width="1080px"
      top="6vh"
      @closed="handleSectionContentDialogClosed"
    >
      <div v-if="currentContentSection" class="section-material-toolbar">
        <div class="section-material-context">
          <div class="section-material-title">{{ currentContentSection.title }}</div>
          <div class="section-material-meta">
            {{ currentContentChapter?.title || '-' }}
          </div>
        </div>
        <el-button type="primary" @click="openContentCreate">新增内容项</el-button>
      </div>

      <el-table
        v-loading="sectionContentLoading"
        :data="sectionContents"
        :header-cell-style="{ background: '#fafbfc', color: '#5e6d82', fontWeight: '600' }"
        row-class-name="table-row"
      >
        <el-table-column type="index" label="#" width="56" align="center" />
        <el-table-column label="内容标题" min-width="180" prop="title" />
        <el-table-column label="类型" width="120" align="center">
          <template #default="{ row }">
            {{ sectionContentTypeText(row.contentType) }}
          </template>
        </el-table-column>
        <el-table-column label="时长" width="100" align="center">
          <template #default="{ row }">
            {{ formatSectionDuration(row.duration) }}
          </template>
        </el-table-column>
        <el-table-column label="文件名称" min-width="180" prop="fileName" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.fileName || row.fileUrl || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openContentEdit(row.id)">编辑</el-button>
            <el-button link type="danger" @click="handleDeleteContent(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog
      v-model="contentDialogVisible"
      :title="editingContentId ? '编辑内容项' : '新增内容项'"
      width="820px"
      top="6vh"
      @closed="resetContentForm"
    >
      <el-form ref="contentFormRef" :model="contentForm" :rules="contentRules" label-width="92px">
        <el-form-item label="内容标题" prop="title">
          <el-input v-model="contentForm.title" />
        </el-form-item>
        <el-form-item label="内容类型" prop="contentType">
          <el-select v-model="contentForm.contentType" style="width: 100%" @change="handleContentTypeChange">
            <el-option label="富文本" value="RICH_TEXT" />
            <el-option label="视频" value="VIDEO" />
            <el-option label="图片" value="IMAGE" />
            <el-option label="PDF" value="PDF" />
            <el-option label="PPT" value="PPT" />
            <el-option label="附件" value="FILE" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="supportsContentFile" label="文件上传">
          <div class="upload-field">
            <input
              :key="contentFileInputKey"
              type="file"
              class="upload-input"
              :accept="contentFileAccept"
              @change="handleContentFileChange"
            />
            <p class="upload-tip">
              {{ selectedContentFileName || existingContentFileName || contentUploadTip }}
            </p>
            <p v-if="contentUploadError" class="upload-error">{{ contentUploadError }}</p>
          </div>
        </el-form-item>
        <el-form-item v-if="supportsContentFile" label="文件地址">
          <el-input v-model="contentForm.fileUrl" />
        </el-form-item>
        <el-form-item v-if="contentForm.contentType === 'VIDEO'" label="时长">
          <div class="readonly-field">
            <span>{{ formatSectionDuration(contentForm.duration) }}</span>
          </div>
        </el-form-item>
        <el-form-item v-if="contentForm.contentType === 'RICH_TEXT'" label="正文内容">
          <div class="tiptap-editor">
            <div v-if="editor" class="tiptap-toolbar">
              <el-button size="small" :type="editor.isActive('bold') ? 'primary' : 'default'" @click="editor.chain().focus().toggleBold().run()">B</el-button>
              <el-button size="small" :type="editor.isActive('italic') ? 'primary' : 'default'" @click="editor.chain().focus().toggleItalic().run()">I</el-button>
              <el-button size="small" :type="editor.isActive('heading', { level: 2 }) ? 'primary' : 'default'" @click="editor.chain().focus().toggleHeading({ level: 2 }).run()">H2</el-button>
              <el-button size="small" :type="editor.isActive('bulletList') ? 'primary' : 'default'" @click="editor.chain().focus().toggleBulletList().run()">列表</el-button>
              <el-button size="small" :type="editor.isActive('orderedList') ? 'primary' : 'default'" @click="editor.chain().focus().toggleOrderedList().run()">编号</el-button>
              <el-button size="small" :type="editor.isActive('blockquote') ? 'primary' : 'default'" @click="editor.chain().focus().toggleBlockquote().run()">引用</el-button>
              <el-button size="small" @click="setEditorLink">链接</el-button>
              <el-button size="small" @click="insertEditorImage">图片</el-button>
              <el-button size="small" @click="editor.chain().focus().unsetAllMarks().clearNodes().run()">清除</el-button>
            </div>
            <editor-content :editor="editor" class="tiptap-surface" />
          </div>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="contentForm.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="contentDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="contentSaving" @click="submitContentForm">
          保存
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
        <el-form-item label="试看">
          <el-radio-group v-model="sectionForm.isFreeTrial">
            <el-radio :value="1">是</el-radio>
            <el-radio :value="0">否</el-radio>
          </el-radio-group>
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
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { EditorContent, useEditor } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Link from '@tiptap/extension-link'
import Image from '@tiptap/extension-image'
import Placeholder from '@tiptap/extension-placeholder'
import { getCourseList } from '@/api/course'
import {
  createChapter,
  createSection,
  deleteChapter,
  deleteSection,
  getChapterTree,
  uploadSectionContentFile,
  updateChapter,
  updateSection
} from '@/api/chapter'
import {
  createSectionContent,
  deleteSectionContent,
  getSectionContentDetail,
  getSectionContentList,
  updateSectionContent
} from '@/api/sectionContent'

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
  title: ''
})

const sectionDialogVisible = ref(false)
const sectionSaving = ref(false)
const editingSectionId = ref(null)
const sectionFormRef = ref()
const sectionForm = reactive({
  title: '',
  isFreeTrial: 0
})

const sectionContentDialogVisible = ref(false)
const sectionContentLoading = ref(false)
const currentContentSection = ref(null)
const currentContentChapter = ref(null)
const sectionContents = ref([])

const contentDialogVisible = ref(false)
const contentSaving = ref(false)
const editingContentId = ref(null)
const contentFormRef = ref()
const selectedContentUploadFile = ref(null)
const selectedContentFileName = ref('')
const contentUploadError = ref('')
const contentFileInputKey = ref(0)
const pendingEditorImages = ref([])
const contentForm = reactive({
  title: '',
  contentType: 'RICH_TEXT',
  contentHtml: '',
  contentJson: '',
  fileUrl: '',
  objectKey: '',
  fileName: '',
  mimeType: '',
  fileSize: 0,
  duration: 0,
  status: 1
})

const editor = useEditor({
  content: '',
  extensions: [
    StarterKit,
    Link.configure({
      openOnClick: false,
      autolink: true,
      defaultProtocol: 'https'
    }),
    Image.configure({
      allowBase64: false
    }),
    Placeholder.configure({
      placeholder: '输入正文内容，可插入图片、链接、标题、列表等'
    })
  ],
  editorProps: {
    handlePaste(_view, event) {
      const files = Array.from(event.clipboardData?.files || [])
      const imageFiles = files.filter((file) => file.type.startsWith('image/'))
      if (!imageFiles.length) {
        return false
      }
      event.preventDefault()
      imageFiles.forEach((file) => insertPendingEditorImage(file))
      return true
    },
    handleDrop(_view, event) {
      const files = Array.from(event.dataTransfer?.files || [])
      const imageFiles = files.filter((file) => file.type.startsWith('image/'))
      if (!imageFiles.length) {
        return false
      }
      event.preventDefault()
      imageFiles.forEach((file) => insertPendingEditorImage(file))
      return true
    }
  },
  onUpdate: ({ editor }) => {
    syncEditorContent(editor)
  }
})

const chapterRules = {
  title: [{ required: true, message: '请输入章节标题', trigger: 'blur' }]
}

const sectionRules = {
  title: [{ required: true, message: '请输入小节标题', trigger: 'blur' }]
}

const contentRules = {
  title: [{ required: true, message: '请输入内容标题', trigger: 'blur' }],
  contentType: [{ required: true, message: '请选择内容类型', trigger: 'change' }]
}

const currentChapter = computed(() =>
  chapters.value.find((item) => item.id === activeChapterId.value) || null
)

const supportsContentFile = computed(() => ['VIDEO', 'PDF', 'IMAGE', 'PPT', 'FILE'].includes(contentForm.contentType))

const existingContentFileName = computed(() => {
  if (!contentForm.fileUrl) {
    return ''
  }
  const parts = contentForm.fileUrl.split('/')
  return parts[parts.length - 1] || contentForm.fileUrl
})

const contentFileAccept = computed(() => {
  if (contentForm.contentType === 'VIDEO') {
    return 'video/*,.mp4,.mov,.m4v,.webm,.avi,.mkv'
  }
  if (contentForm.contentType === 'IMAGE') {
    return 'image/*,.jpg,.jpeg,.png,.gif,.webp,.bmp,.svg'
  }
  if (contentForm.contentType === 'PDF') {
    return '.pdf,application/pdf'
  }
  if (contentForm.contentType === 'PPT') {
    return '.ppt,.pptx,application/vnd.ms-powerpoint,application/vnd.openxmlformats-officedocument.presentationml.presentation'
  }
  return '*'
})

const contentUploadTip = computed(() => {
  if (contentForm.contentType === 'VIDEO') {
    return '支持 mp4/mov/webm/avi/mkv，大小不超过 500MB'
  }
  if (contentForm.contentType === 'PDF') {
    return '支持 PDF 文件'
  }
  if (contentForm.contentType === 'IMAGE') {
    return '支持 jpg/png/webp/gif 等图片文件'
  }
  if (contentForm.contentType === 'PPT') {
    return '支持 PPT/PPTX 文件'
  }
  return '支持上传单个附件文件'
})

function resetChapterForm() {
  Object.assign(chapterForm, {
    title: ''
  })
  editingChapterId.value = null
  chapterFormRef.value?.clearValidate()
}

function resetSectionForm() {
  Object.assign(sectionForm, {
    title: '',
    isFreeTrial: 0
  })
  editingSectionId.value = null
  sectionFormRef.value?.clearValidate()
}

function resetContentForm() {
  Object.assign(contentForm, {
    title: '',
    contentType: 'RICH_TEXT',
    contentHtml: '',
    contentJson: '',
    fileUrl: '',
    objectKey: '',
    fileName: '',
    mimeType: '',
    fileSize: 0,
    duration: 0,
    status: 1
  })
  editingContentId.value = null
  selectedContentUploadFile.value = null
  selectedContentFileName.value = ''
  contentUploadError.value = ''
  contentFileInputKey.value += 1
  clearPendingEditorImages()
  editor.value?.commands.setContent('')
  contentFormRef.value?.clearValidate()
}

function sectionContentTypeText(value) {
  return (
    {
      VIDEO: '视频',
      RICH_TEXT: '富文本',
      IMAGE: '图片',
      PDF: 'PDF',
      PPT: 'PPT',
      FILE: '附件'
    }[value] || '未知'
  )
}

function formatSectionDuration(value) {
  const total = Number(value || 0)
  if (!total) {
    return '--'
  }
  const minutes = Math.floor(total / 60)
  const seconds = total % 60
  return `${minutes}分${String(seconds).padStart(2, '0')}秒`
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
    if (!chapters.value.some((item) => item.id === activeChapterId.value)) {
      activeChapterId.value = chapters.value[0]?.id ?? null
    }
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
  chapterDialogVisible.value = true
}

function openChapterEdit(chapter) {
  editingChapterId.value = chapter.id
  Object.assign(chapterForm, {
    title: chapter.title
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
  sectionDialogVisible.value = true
}

function openSectionEdit(section) {
  resetSectionForm()
  editingSectionId.value = section.id
  Object.assign(sectionForm, {
    title: section.title,
    isFreeTrial: section.isFreeTrial
  })
  sectionDialogVisible.value = true
}

async function openSectionContents(section) {
  currentContentSection.value = section
  currentContentChapter.value = currentChapter.value
  sectionContentDialogVisible.value = true
  await fetchSectionContents(section.id)
}

function openContentCreate() {
  if (!currentContentSection.value) {
    return
  }
  resetContentForm()
  contentDialogVisible.value = true
}

async function openContentEdit(id) {
  const { data } = await getSectionContentDetail(id)
  resetContentForm()
  editingContentId.value = id
  Object.assign(contentForm, {
    title: data.title,
    contentType: data.contentType,
    contentHtml: data.contentHtml || '',
    contentJson: data.contentJson || '',
    fileUrl: data.fileUrl || '',
    objectKey: data.objectKey || '',
    fileName: data.fileName || '',
    mimeType: data.mimeType || '',
    fileSize: data.fileSize || 0,
    duration: data.duration || 0,
    status: data.status ?? 1
  })
  contentDialogVisible.value = true
  await nextTick()
  setEditorContentFromForm()
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
    const payload = {
      title: sectionForm.title,
      isFreeTrial: sectionForm.isFreeTrial
    }

    if (editingSectionId.value) {
      await updateSection(editingSectionId.value, payload)
      ElMessage.success('小节已更新')
    } else {
      await createSection(activeChapterId.value, payload)
      ElMessage.success('小节已创建')
    }
    sectionDialogVisible.value = false
    await fetchChapterTree()
  } finally {
    sectionSaving.value = false
  }
}

async function fetchSectionContents(sectionId = currentContentSection.value?.id) {
  if (!sectionId) {
    sectionContents.value = []
    return
  }
  sectionContentLoading.value = true
  try {
    const { data } = await getSectionContentList(sectionId)
    sectionContents.value = data || []
  } finally {
    sectionContentLoading.value = false
  }
}

async function submitContentForm() {
  if (!currentContentSection.value) {
    return
  }
  await contentFormRef.value.validate()
  contentSaving.value = true
  try {
    if (contentForm.contentType === 'RICH_TEXT') {
      await uploadPendingEditorImages()
      syncEditorContent()
    }

    const payload = {
      ...contentForm,
      contentHtml: contentForm.contentType === 'RICH_TEXT' ? contentForm.contentHtml : '',
      contentJson: contentForm.contentType === 'RICH_TEXT' ? contentForm.contentJson : ''
    }

    if (selectedContentUploadFile.value) {
      const { data } = await uploadSectionContentFile(selectedContentUploadFile.value, contentForm.contentType)
      payload.fileUrl = data.url
      payload.objectKey = data.objectKey
      payload.fileName = data.originalFilename
      payload.mimeType = data.contentType
      payload.fileSize = data.size
      contentUploadError.value = ''
    }

    if (editingContentId.value) {
      await updateSectionContent(editingContentId.value, payload)
      ElMessage.success('内容项已更新')
    } else {
      await createSectionContent(currentContentSection.value.id, payload)
      ElMessage.success('内容项已创建')
    }

    contentDialogVisible.value = false
    await fetchSectionContents(currentContentSection.value.id)
  } finally {
    contentSaving.value = false
  }
}

async function handleDeleteChapter(chapter) {
  await ElMessageBox.confirm(
    `确定删除章节“${chapter.title}”吗？其下所有小节和内容项会一并删除，且不可恢复。`,
    '删除章节',
    {
      type: 'warning',
      confirmButtonText: '确认删除',
      cancelButtonText: '取消'
    }
  )
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

async function handleDeleteContent(id) {
  await ElMessageBox.confirm('确定删除该内容项吗？', '删除内容项', { type: 'warning' })
  await deleteSectionContent(id)
  ElMessage.success('内容项已删除')
  await fetchSectionContents(currentContentSection.value?.id)
}

function readVideoDuration(file) {
  return new Promise((resolve, reject) => {
    const video = document.createElement('video')
    const objectUrl = URL.createObjectURL(file)

    const cleanup = () => {
      URL.revokeObjectURL(objectUrl)
      video.removeAttribute('src')
      video.load()
    }

    video.preload = 'metadata'
    video.onloadedmetadata = () => {
      const duration = Number.isFinite(video.duration) ? Math.round(video.duration) : 0
      cleanup()
      resolve(duration)
    }
    video.onerror = () => {
      cleanup()
      reject(new Error('failed to read video metadata'))
    }
    video.src = objectUrl
  })
}

function validateSectionVideoFile(file) {
  const maxSize = 500 * 1024 * 1024
  const isVideo = typeof file.type === 'string' && file.type.startsWith('video/')
  const lowerName = file.name?.toLowerCase() || ''
  const allowedExtensions = ['.mp4', '.mov', '.m4v', '.webm', '.avi', '.mkv']
  const hasValidExtension = allowedExtensions.some((extension) => lowerName.endsWith(extension))

  if (!isVideo && !hasValidExtension) {
    contentUploadError.value = '仅支持上传常见视频格式文件'
    return false
  }

  if (file.size > maxSize) {
    contentUploadError.value = '视频文件大小不能超过 500MB'
    return false
  }

  return true
}

function handleContentTypeChange() {
  selectedContentUploadFile.value = null
  selectedContentFileName.value = ''
  contentUploadError.value = ''
  contentFileInputKey.value += 1
  contentForm.fileUrl = ''
  contentForm.objectKey = ''
  contentForm.fileName = ''
  contentForm.mimeType = ''
  contentForm.fileSize = 0
  contentForm.duration = 0
  if (contentForm.contentType !== 'RICH_TEXT') {
    contentForm.contentHtml = ''
    contentForm.contentJson = ''
    clearPendingEditorImages()
    editor.value?.commands.setContent('')
  }
}

function syncEditorContent(currentEditor = editor.value) {
  if (!currentEditor || contentForm.contentType !== 'RICH_TEXT') {
    return
  }
  contentForm.contentHtml = currentEditor.getHTML()
  contentForm.contentJson = JSON.stringify(currentEditor.getJSON())
}

function setEditorContentFromForm() {
  if (!editor.value) {
    return
  }
  if (contentForm.contentJson) {
    try {
      editor.value.commands.setContent(JSON.parse(contentForm.contentJson))
      syncEditorContent()
      return
    } catch (_error) {
      // Fall back to HTML for legacy rich text content.
    }
  }
  editor.value.commands.setContent(contentForm.contentHtml || '')
  syncEditorContent()
}

function setEditorLink() {
  if (!editor.value) {
    return
  }
  const previousUrl = editor.value.getAttributes('link').href || ''
  const url = window.prompt('请输入链接地址', previousUrl)
  if (url === null) {
    return
  }
  if (!url) {
    editor.value.chain().focus().extendMarkRange('link').unsetLink().run()
    return
  }
  editor.value.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
}

function insertEditorImage() {
  if (!editor.value) {
    return
  }
  const url = window.prompt('请输入图片地址')
  if (!url) {
    return
  }
  editor.value.chain().focus().setImage({ src: url }).run()
}

function insertPendingEditorImage(file) {
  if (!editor.value) {
    return
  }
  const objectUrl = URL.createObjectURL(file)
  pendingEditorImages.value.push({
    file,
    objectUrl
  })
  editor.value.chain().focus().setImage({
    src: objectUrl,
    alt: file.name || ''
  }).run()
}

async function uploadPendingEditorImages() {
  if (!editor.value || !pendingEditorImages.value.length) {
    return
  }

  for (const item of pendingEditorImages.value) {
    const { data } = await uploadSectionContentFile(item.file, 'IMAGE')
    replaceEditorImageSrc(item.objectUrl, data.url)
    URL.revokeObjectURL(item.objectUrl)
  }
  pendingEditorImages.value = []
}

function replaceEditorImageSrc(sourceUrl, targetUrl) {
  const escapedSource = escapeRegExp(sourceUrl)
  contentForm.contentHtml = (editor.value.getHTML() || '').replaceAll(sourceUrl, targetUrl)
  contentForm.contentJson = JSON.stringify(editor.value.getJSON()).replace(
    new RegExp(escapedSource, 'g'),
    () => targetUrl
  )
  if (contentForm.contentJson) {
    editor.value.commands.setContent(JSON.parse(contentForm.contentJson))
  } else {
    editor.value.commands.setContent(contentForm.contentHtml || '')
  }
}

function clearPendingEditorImages() {
  pendingEditorImages.value.forEach((item) => URL.revokeObjectURL(item.objectUrl))
  pendingEditorImages.value = []
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

function validateContentFile(file) {
  if (contentForm.contentType === 'VIDEO') {
    return validateSectionVideoFile(file)
  }
  if (contentForm.contentType === 'PDF') {
    const isPdf = file.type === 'application/pdf' || file.name?.toLowerCase().endsWith('.pdf')
    if (!isPdf) {
      contentUploadError.value = '仅支持上传 PDF 文件'
      return false
    }
  }
  if (contentForm.contentType === 'IMAGE') {
    const isImage = typeof file.type === 'string' && file.type.startsWith('image/')
    if (!isImage) {
      contentUploadError.value = '仅支持上传图片文件'
      return false
    }
  }
  if (contentForm.contentType === 'PPT') {
    const lowerName = file.name?.toLowerCase() || ''
    if (!lowerName.endsWith('.ppt') && !lowerName.endsWith('.pptx')) {
      contentUploadError.value = '仅支持上传 PPT/PPTX 文件'
      return false
    }
  }
  const maxSize = 100 * 1024 * 1024
  if (contentForm.contentType !== 'VIDEO' && file.size > maxSize) {
    contentUploadError.value = '单个文件大小不能超过 100MB'
    return false
  }
  return true
}

function handleContentFileChange(event) {
  const target = event.target
  const file = target.files?.[0]

  contentUploadError.value = ''

  if (!file) {
    selectedContentUploadFile.value = null
    selectedContentFileName.value = ''
    return
  }

  if (!validateContentFile(file)) {
    selectedContentUploadFile.value = null
    selectedContentFileName.value = ''
    contentFileInputKey.value += 1
    return
  }

  selectedContentUploadFile.value = file
  selectedContentFileName.value = file.name
  contentForm.fileUrl = ''
  contentForm.objectKey = ''
  contentForm.fileName = file.name
  contentForm.mimeType = file.type || ''

  if (contentForm.contentType === 'VIDEO') {
    readVideoDuration(file)
      .then((duration) => {
        contentForm.duration = duration
      })
      .catch(() => {
        contentForm.duration = 0
      })
  } else {
    contentForm.fileSize = file.size
  }
}

onBeforeUnmount(() => {
  clearPendingEditorImages()
  editor.value?.destroy()
})

function handleSectionContentDialogClosed() {
  clearPendingEditorImages()
  currentContentSection.value = null
  currentContentChapter.value = null
  sectionContents.value = []
  contentDialogVisible.value = false
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

.readonly-field {
  width: 100%;
  min-height: 40px;
  padding: 10px 12px;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  background: #f8fafc;
  box-sizing: border-box;
  color: #303133;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.tiptap-editor {
  width: 100%;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  overflow: hidden;
  background: #fff;
}

.tiptap-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 10px 12px;
  border-bottom: 1px solid #ebeef5;
  background: #f8fafc;
}

.tiptap-surface {
  min-height: 220px;
}

.tiptap-surface :deep(.ProseMirror) {
  min-height: 220px;
  padding: 14px 16px;
  outline: none;
  color: #303133;
  line-height: 1.8;
}

.tiptap-surface :deep(.ProseMirror p.is-editor-empty:first-child::before) {
  color: #a8abb2;
  content: attr(data-placeholder);
  float: left;
  height: 0;
  pointer-events: none;
}

.tiptap-surface :deep(.ProseMirror h1),
.tiptap-surface :deep(.ProseMirror h2),
.tiptap-surface :deep(.ProseMirror h3) {
  margin: 14px 0 8px;
}

.tiptap-surface :deep(.ProseMirror p) {
  margin: 8px 0;
}

.tiptap-surface :deep(.ProseMirror ul),
.tiptap-surface :deep(.ProseMirror ol) {
  margin: 8px 0;
  padding-left: 22px;
}

.tiptap-surface :deep(.ProseMirror blockquote) {
  margin: 12px 0;
  padding: 8px 12px;
  border-left: 4px solid #bfdbfe;
  background: #f8fbff;
  color: #475569;
}

.tiptap-surface :deep(.ProseMirror img) {
  max-width: 100%;
  border-radius: 6px;
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
