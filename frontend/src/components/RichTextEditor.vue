<template>
  <div class="rich-editor">
    <div v-if="editor && !readonly" class="editor-toolbar">
      <el-button size="small" :type="editor.isActive('bold') ? 'primary' : 'default'" @click="editor.chain().focus().toggleBold().run()">B</el-button>
      <el-button size="small" :type="editor.isActive('italic') ? 'primary' : 'default'" @click="editor.chain().focus().toggleItalic().run()">I</el-button>
      <el-button size="small" :type="editor.isActive('bulletList') ? 'primary' : 'default'" @click="editor.chain().focus().toggleBulletList().run()">列表</el-button>
      <el-button size="small" :type="editor.isActive('orderedList') ? 'primary' : 'default'" @click="editor.chain().focus().toggleOrderedList().run()">编号</el-button>
      <el-button size="small" :type="editor.isActive('blockquote') ? 'primary' : 'default'" @click="editor.chain().focus().toggleBlockquote().run()">引用</el-button>
      <el-button size="small" @click="editor.chain().focus().unsetAllMarks().clearNodes().run()">清除</el-button>
    </div>
    <editor-content :editor="editor" class="editor-surface" />
  </div>
</template>

<script setup>
import Placeholder from '@tiptap/extension-placeholder'
import StarterKit from '@tiptap/starter-kit'
import { EditorContent, useEditor } from '@tiptap/vue-3'
import { computed, onBeforeUnmount, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: '请输入内容'
  },
  readonly: {
    type: Boolean,
    default: false
  },
  minHeight: {
    type: Number,
    default: 220
  }
})

const emit = defineEmits(['update:modelValue'])
const editorMinHeight = computed(() => `${props.minHeight}px`)

const editor = useEditor({
  extensions: [
    StarterKit,
    Placeholder.configure({
      placeholder: props.placeholder
    })
  ],
  content: props.modelValue || '',
  editable: !props.readonly,
  onUpdate: ({ editor: currentEditor }) => {
    emit('update:modelValue', currentEditor.getHTML())
  }
})

watch(
  () => props.modelValue,
  (value) => {
    if (!editor.value) {
      return
    }
    const currentHtml = editor.value.getHTML()
    const nextHtml = value || ''
    if (currentHtml === nextHtml) {
      return
    }
    editor.value.commands.setContent(nextHtml, false)
  }
)

watch(
  () => props.readonly,
  (value) => {
    editor.value?.setEditable(!value)
  },
  { immediate: true }
)

onBeforeUnmount(() => {
  editor.value?.destroy()
})
</script>

<style scoped>
.rich-editor {
  width: 100%;
  border: 1px solid var(--el-border-color);
  border-radius: 10px;
  overflow: hidden;
  background: #fff;
}

.editor-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 10px 12px;
  border-bottom: 1px solid #ebeef5;
  background: #f8fafc;
}

.editor-surface {
  min-height: v-bind(editorMinHeight);
}

.editor-surface :deep(.ProseMirror) {
  min-height: v-bind(editorMinHeight);
  padding: 14px 16px;
  outline: none;
  color: #303133;
  line-height: 1.8;
}

.editor-surface :deep(.ProseMirror p.is-editor-empty:first-child::before) {
  color: #a8abb2;
  content: attr(data-placeholder);
  float: left;
  height: 0;
  pointer-events: none;
}

.editor-surface :deep(.ProseMirror h1),
.editor-surface :deep(.ProseMirror h2),
.editor-surface :deep(.ProseMirror h3) {
  margin: 14px 0 8px;
}

.editor-surface :deep(.ProseMirror p) {
  margin: 8px 0;
}

.editor-surface :deep(.ProseMirror ul),
.editor-surface :deep(.ProseMirror ol) {
  margin: 8px 0;
  padding-left: 22px;
}

.editor-surface :deep(.ProseMirror blockquote) {
  margin: 12px 0;
  padding: 8px 12px;
  border-left: 4px solid #bfdbfe;
  background: #f8fbff;
  color: #475569;
}
</style>
