<template>
  <div class="page-card">
    <div class="page-header">
      <div>
        <h2 class="page-title">课程分类</h2>
      </div>
      <div class="toolbar">
        <el-button type="primary" @click="openCreate(1)">新增一级分类</el-button>
        <el-button @click="fetchTree">刷新树</el-button>
      </div>
    </div>

    <div class="tree-column">
      <div class="tree-card">
        <el-tree
          :data="treeData"
          node-key="id"
          default-expand-all
          :expand-on-click-node="false"
          :props="{ label: 'name', children: 'children' }"
        >
          <template #default="{ data }">
            <div style="display:flex; align-items:center; justify-content:space-between; width:100%; gap:12px;">
              <div>
                <div style="font-weight:600;">{{ data.name }}</div>
                <div class="muted" style="font-size:12px;">
                  {{ data.level === 1 ? '一级分类' : '二级分类' }} / 排序 {{ data.sort || 0 }}
                </div>
              </div>
              <div>
                <el-button v-if="data.level === 1" link type="primary" @click.stop="openCreate(2, data)">新增子类</el-button>
                <el-button link type="primary" @click.stop="openEdit(data.id)">编辑</el-button>
                <el-button link type="danger" @click.stop="handleDelete(data.id)">删除</el-button>
              </div>
            </div>
          </template>
        </el-tree>
      </div>
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑分类' : '新增分类'" width="520px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="层级">
          <el-radio-group v-model="form.level">
            <el-radio :value="1">一级分类</el-radio>
            <el-radio :value="2">二级分类</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="父级ID">
          <el-input v-model="form.parentId" :disabled="true" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sort" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
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
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  createCategory,
  deleteCategory,
  getCategoryDetail,
  getCategoryTree,
  updateCategory
} from '@/api/category'

const treeData = ref([])
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()

const defaultForm = () => ({
  parentId: 0,
  name: '',
  level: 1,
  sort: 0,
  status: 1
})

const form = reactive(defaultForm())

const rules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }]
}

async function fetchTree() {
  const { data } = await getCategoryTree()
  treeData.value = data
}

function resetForm() {
  Object.assign(form, defaultForm())
}

function openCreate(level, parent = null) {
  editingId.value = null
  resetForm()
  form.level = level
  form.parentId = level === 1 ? 0 : parent.id
  dialogVisible.value = true
}

async function openEdit(id) {
  const { data } = await getCategoryDetail(id)
  editingId.value = id
  resetForm()
  Object.assign(form, data)
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    if (editingId.value) {
      await updateCategory(editingId.value, form)
      ElMessage.success('分类已更新')
    } else {
      await createCategory(form)
      ElMessage.success('分类已创建')
    }
    dialogVisible.value = false
    fetchTree()
  } finally {
    saving.value = false
  }
}

async function handleDelete(id) {
  await ElMessageBox.confirm('删除后不可恢复，确认继续？', '删除分类', { type: 'warning' })
  await deleteCategory(id)
  ElMessage.success('分类已删除')
  fetchTree()
}

onMounted(fetchTree)
</script>
