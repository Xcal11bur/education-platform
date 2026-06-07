<template>
  <div class="page-card">
    <div class="toolbar" style="justify-content: flex-end; margin-bottom: 18px;">
      <el-button type="primary" @click="handleAdd">新增分类</el-button>
    </div>

    <div class="table-card">
      <el-table
        v-loading="tableLoading"
        :data="treeData"
        row-key="id"
        default-expand-all
        :tree-props="{ children: 'children' }"
        :header-cell-style="{ background: '#fafbfc', color: '#5e6d82', fontWeight: '600' }"
      >
        <el-table-column label="分类名称" min-width="260">
          <template #default="{ row }">
            <span class="category-name" :style="{ paddingLeft: row.parentId ? '24px' : '0' }">
              <el-icon class="category-icon">
                <CaretRight v-if="row.parentId" />
                <FolderOpened v-else />
              </el-icon>
              {{ row.name }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="170" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row.id)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑分类' : '新增分类'"
      width="420px"
      top="8vh"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="84px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="父级分类">
          <el-select v-model="form.parentId" clearable placeholder="顶级分类" style="width: 100%">
            <el-option
              v-for="item in parentOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
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
        <el-button type="primary" :loading="saving" @click="submitForm">
          {{ editingId ? '保存' : '新增' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { CaretRight, FolderOpened } from '@element-plus/icons-vue'
import {
  createCategory,
  deleteCategory,
  getCategoryDetail,
  getCategoryTree,
  updateCategory
} from '@/api/category'

const treeData = ref([])
const flatList = ref([])
const tableLoading = ref(false)
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()

const defaultForm = () => ({
  name: '',
  parentId: null,
  status: 1
})

const form = reactive(defaultForm())

const rules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }]
}

const parentOptions = computed(() =>
  flatList.value.filter((item) => item.level === 1 && item.id !== editingId.value)
)

function flattenTree(nodes, result = []) {
  nodes.forEach((node) => {
    result.push({
      id: node.id,
      parentId: node.parentId,
      name: node.name,
      level: node.level,
      status: node.status
    })
    if (node.children?.length) {
      flattenTree(node.children, result)
    }
  })
  return result
}

async function fetchTree() {
  tableLoading.value = true
  try {
    const { data } = await getCategoryTree()
    treeData.value = data || []
    flatList.value = flattenTree(treeData.value, [])
  } finally {
    tableLoading.value = false
  }
}

function resetForm() {
  Object.assign(form, defaultForm())
  editingId.value = null
  formRef.value?.clearValidate()
}

function handleAdd() {
  resetForm()
  dialogVisible.value = true
}

async function handleEdit(id) {
  const { data } = await getCategoryDetail(id)
  editingId.value = id
  Object.assign(form, {
    name: data.name,
    parentId: data.parentId === 0 ? null : data.parentId,
    status: data.status ?? 1
  })
  dialogVisible.value = true
  await nextTick()
  formRef.value?.clearValidate()
}

async function submitForm() {
  await formRef.value.validate()
  const parentId = form.parentId ?? 0
  if (editingId.value && parentId === editingId.value) {
    ElMessage.error('父级分类不能选择自己')
    return
  }

  saving.value = true
  try {
    const payload = {
      name: form.name,
      parentId,
      level: parentId === 0 ? 1 : 2,
      status: form.status
    }

    if (editingId.value) {
      await updateCategory(editingId.value, payload)
      ElMessage.success('分类已更新')
    } else {
      await createCategory(payload)
      ElMessage.success('分类已创建')
    }
    dialogVisible.value = false
    await fetchTree()
  } finally {
    saving.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(
    `确定删除分类“${row.name}”吗？`,
    '删除分类',
    { type: 'warning' }
  )
  await deleteCategory(row.id)
  ElMessage.success('分类已删除')
  await fetchTree()
}

onMounted(fetchTree)
</script>

<style scoped>
.table-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

.category-name {
  display: inline-flex;
  align-items: center;
  font-weight: 600;
}

.category-icon {
  margin-right: 6px;
  color: #409eff;
}
</style>
