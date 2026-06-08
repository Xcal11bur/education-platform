<template>
  <div class="page-card">
    <div class="toolbar" style="justify-content: flex-end; margin-bottom: 18px;">
      <el-button type="primary" @click="openCreate">新增学员</el-button>
    </div>

    <div class="filter-bar">
      <el-input v-model="query.mobile" placeholder="学员手机号" clearable />
      <el-input v-model="query.nickname" placeholder="学员昵称" clearable />
      <el-select v-model="query.status" placeholder="状态" clearable>
        <el-option label="启用" :value="1" />
        <el-option label="停用" :value="0" />
      </el-select>
      <el-button type="primary" @click="fetchMembers">查询</el-button>
    </div>

    <el-table :data="members" border>
      <el-table-column label="ID" width="90">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column prop="nickname" label="昵称" min-width="140" />
      <el-table-column prop="mobile" label="手机号" min-width="140" />
      <el-table-column prop="realName" label="真实姓名" min-width="140" />
      <el-table-column label="性别" width="100">
        <template #default="{ row }">{{ genderText(row.gender) }}</template>
      </el-table-column>
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
        @current-change="fetchMembers"
        @size-change="fetchMembers"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑学员' : '新增学员'" width="620px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="手机号" prop="mobile">
          <el-input v-model="form.mobile" />
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="form.nickname" />
        </el-form-item>
        <el-form-item label="登录密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            :placeholder="editingId ? '留空表示不修改密码' : '请输入 6-20 位密码'"
          />
        </el-form-item>
        <el-form-item label="真实姓名">
          <el-input v-model="form.realName" />
        </el-form-item>
        <el-form-item label="头像地址">
          <el-input v-model="form.avatar" />
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="form.gender">
            <el-radio :value="0">未知</el-radio>
            <el-radio :value="1">男</el-radio>
            <el-radio :value="2">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="生日">
          <el-date-picker
            v-model="form.birthday"
            type="date"
            value-format="YYYY-MM-DD"
            placeholder="请选择生日"
            style="width: 100%;"
          />
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
import { ElMessage } from 'element-plus'
import {
  createMember,
  getMemberDetail,
  getMemberList,
  updateMember,
  updateMemberStatus
} from '@/api/adminMember'

const members = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  mobile: '',
  nickname: '',
  status: null
})

const defaultForm = () => ({
  mobile: '',
  nickname: '',
  password: '',
  realName: '',
  avatar: '',
  gender: 0,
  birthday: '',
  status: 1
})

const form = reactive(defaultForm())

const rules = {
  mobile: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  password: [
    {
      validator: (_rule, value, callback) => {
        if (!editingId.value && !value) {
          callback(new Error('请输入登录密码'))
          return
        }
        if (value && (value.length < 6 || value.length > 20)) {
          callback(new Error('密码长度为 6-20 位'))
          return
        }
        callback()
      },
      trigger: 'blur'
    }
  ]
}

async function fetchMembers() {
  const { data } = await getMemberList(query)
  members.value = data.list
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
  const { data } = await getMemberDetail(id)
  editingId.value = id
  resetForm()
  Object.assign(form, {
    ...data,
    password: '',
    birthday: data.birthday || ''
  })
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    const payload = {
      ...form,
      password: form.password || null
    }
    if (editingId.value) {
      await updateMember(editingId.value, payload)
      ElMessage.success('学员信息已更新')
    } else {
      await createMember(payload)
      ElMessage.success('学员已创建')
    }
    dialogVisible.value = false
    fetchMembers()
  } finally {
    saving.value = false
  }
}

async function toggleStatus(row) {
  const nextStatus = row.status === 1 ? 0 : 1
  await updateMemberStatus(row.id, { status: nextStatus })
  ElMessage.success(nextStatus === 1 ? '学员已启用' : '学员已停用')
  fetchMembers()
}

function rowIndex(index) {
  return (query.pageNum - 1) * query.pageSize + index + 1
}

function genderText(value) {
  return ({ 0: '未知', 1: '男', 2: '女' }[value] || '未知')
}

onMounted(fetchMembers)
</script>
