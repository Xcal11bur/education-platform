<template>
  <div class="page-card">
    <div class="page-header">
      <div>
        <h2 class="page-title">教师管理</h2>
      </div>
      <el-button type="primary" @click="openCreate">新增教师</el-button>
    </div>

    <div class="filter-bar">
      <el-input v-model="query.name" placeholder="教师姓名" clearable />
      <el-input v-model="query.mobile" placeholder="手机号" clearable />
      <el-select v-model="query.status" placeholder="状态" clearable>
        <el-option label="启用" :value="1" />
        <el-option label="停用" :value="0" />
      </el-select>
      <el-button type="primary" @click="fetchTeachers">查询</el-button>
    </div>

    <el-table :data="teachers" border>
      <el-table-column prop="id" label="ID" width="90" />
      <el-table-column prop="name" label="姓名" min-width="140" />
      <el-table-column prop="loginName" label="登录账号" min-width="150" />
      <el-table-column prop="title" label="职称" min-width="140" />
      <el-table-column prop="mobile" label="手机号" min-width="140" />
      <el-table-column prop="email" label="邮箱" min-width="200" />
      <el-table-column label="状态" width="110">
        <template #default="{ row }">
          <span class="status-dot" :class="{ 'is-disabled': row.status !== 1 }">
            {{ row.status === 1 ? '启用' : '停用' }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row.id)">编辑</el-button>
          <el-button link :type="row.status === 1 ? 'warning' : 'success'" @click="toggleStatus(row)">
            {{ row.status === 1 ? '停用' : '启用' }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="list-footer">
      <el-pagination
        v-model:current-page="query.pageNum"
        v-model:page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next, sizes"
        @current-change="fetchTeachers"
        @size-change="fetchTeachers"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑教师' : '新增教师'" width="620px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="登录账号" prop="loginName">
          <el-input v-model="form.loginName" />
        </el-form-item>
        <el-form-item label="教师姓名" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="手机号" prop="mobile">
          <el-input v-model="form.mobile" />
        </el-form-item>
        <el-form-item label="登录密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="编辑时留空表示不修改" />
        </el-form-item>
        <el-form-item label="职称">
          <el-input v-model="form.title" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="头像地址">
          <el-input v-model="form.avatar" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="form.intro" type="textarea" :rows="4" />
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
import { ElMessage } from 'element-plus'
import {
  createTeacher,
  getTeacherDetail,
  getTeacherList,
  updateTeacher,
  updateTeacherStatus
} from '@/api/teacher'

const teachers = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  name: '',
  mobile: '',
  status: null
})

const defaultForm = () => ({
  loginName: '',
  name: '',
  mobile: '',
  password: '',
  title: '',
  intro: '',
  avatar: '',
  email: '',
  status: 1
})

const form = reactive(defaultForm())

const rules = {
  loginName: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
  name: [{ required: true, message: '请输入教师姓名', trigger: 'blur' }],
  mobile: [{ required: true, message: '请输入手机号', trigger: 'blur' }]
}

async function fetchTeachers() {
  const { data } = await getTeacherList(query)
  teachers.value = data.list
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
  const { data } = await getTeacherDetail(id)
  editingId.value = id
  resetForm()
  Object.assign(form, data, { password: '' })
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    if (editingId.value) {
      await updateTeacher(editingId.value, form)
      ElMessage.success('教师信息已更新')
    } else {
      await createTeacher(form)
      ElMessage.success('教师已创建')
    }
    dialogVisible.value = false
    fetchTeachers()
  } finally {
    saving.value = false
  }
}

async function toggleStatus(row) {
  const nextStatus = row.status === 1 ? 0 : 1
  await updateTeacherStatus(row.id, { status: nextStatus })
  ElMessage.success(nextStatus === 1 ? '教师已启用' : '教师已停用')
  fetchTeachers()
}

onMounted(fetchTeachers)
</script>
