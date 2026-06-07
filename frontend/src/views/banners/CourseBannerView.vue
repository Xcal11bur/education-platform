<template>
  <div class="page-card">
    <div class="toolbar" style="justify-content: flex-end; margin-bottom: 18px;">
      <el-button type="primary" @click="openCreate">新增轮播图</el-button>
    </div>

    <div class="filter-bar">
      <el-select v-model="query.courseId" placeholder="关联课程" clearable filterable>
        <el-option
          v-for="item in courseOptions"
          :key="item.id"
          :label="item.title"
          :value="item.id"
        />
      </el-select>
      <el-select v-model="query.status" placeholder="状态" clearable>
        <el-option label="启用" :value="1" />
        <el-option label="停用" :value="0" />
      </el-select>
      <el-button type="primary" @click="fetchBanners">查询</el-button>
    </div>

    <el-table :data="banners" border>
      <el-table-column label="ID" width="80">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column label="封面" width="150">
        <template #default="{ row }">
          <img v-if="row.coverUrl" :src="row.coverUrl" alt="cover" class="banner-cover-preview" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="courseTitle" label="关联课程" min-width="180" />
      <el-table-column prop="title" label="轮播标题" min-width="180">
        <template #default="{ row }">
          {{ row.title || row.courseTitle }}
        </template>
      </el-table-column>
      <el-table-column prop="subTitle" label="副标题" min-width="220">
        <template #default="{ row }">
          {{ row.subTitle || row.courseSubTitle || '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="teacherName" label="讲师" min-width="120" />
      <el-table-column prop="studyCount" label="学习人数" width="110" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <span class="status-dot" :class="{ 'is-disabled': row.status !== 1 }">
            {{ row.status === 1 ? '启用' : '停用' }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="260" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row.id)">编辑</el-button>
          <el-button link :type="row.status === 1 ? 'warning' : 'success'" @click="toggleStatus(row)">
            {{ row.status === 1 ? '停用' : '启用' }}
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
        @current-change="fetchBanners"
        @size-change="fetchBanners"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑轮播图' : '新增轮播图'" width="680px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="关联课程" prop="courseId">
          <el-select v-model="form.courseId" placeholder="请选择课程" filterable style="width: 100%">
            <el-option
              v-for="item in courseOptions"
              :key="item.id"
              :label="item.title"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="轮播标题">
          <el-input v-model="form.title" placeholder="留空则默认使用课程标题" />
        </el-form-item>
        <el-form-item label="副标题">
          <el-input v-model="form.subTitle" placeholder="留空则默认使用课程副标题" />
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
import { getCourseList } from '@/api/course'
import {
  createCourseBanner,
  deleteCourseBanner,
  getCourseBannerDetail,
  getCourseBannerList,
  updateCourseBanner,
  updateCourseBannerStatus
} from '@/api/banner'

const banners = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const formRef = ref()
const courseOptions = ref([])

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  courseId: null,
  status: null
})

const defaultForm = () => ({
  courseId: null,
  title: '',
  subTitle: '',
  status: 1
})

const form = reactive(defaultForm())

const rules = {
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }]
}

async function fetchCourses() {
  const { data } = await getCourseList({
    pageNum: 1,
    pageSize: 100,
    publishStatus: 1
  })
  courseOptions.value = data?.list || []
}

async function fetchBanners() {
  const { data } = await getCourseBannerList(query)
  banners.value = data?.list || []
  total.value = data?.total || 0
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
  const { data } = await getCourseBannerDetail(id)
  editingId.value = id
  resetForm()
  Object.assign(form, {
    courseId: data.courseId,
    title: data.title || '',
    subTitle: data.subTitle || '',
    status: data.status ?? 1
  })
  dialogVisible.value = true
}

async function submitForm() {
  await formRef.value.validate()
  saving.value = true
  try {
    if (editingId.value) {
      await updateCourseBanner(editingId.value, form)
      ElMessage.success('轮播图已更新')
    } else {
      await createCourseBanner(form)
      ElMessage.success('轮播图已创建')
    }
    dialogVisible.value = false
    fetchBanners()
  } finally {
    saving.value = false
  }
}

function rowIndex(index) {
  return (query.pageNum - 1) * query.pageSize + index + 1
}

async function toggleStatus(row) {
  const nextStatus = row.status === 1 ? 0 : 1
  await updateCourseBannerStatus(row.id, { status: nextStatus })
  ElMessage.success(nextStatus === 1 ? '轮播图已启用' : '轮播图已停用')
  fetchBanners()
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除轮播图“${row.title || row.courseTitle}”吗？`, '删除轮播图', {
    type: 'warning'
  })
  await deleteCourseBanner(row.id)
  ElMessage.success('轮播图已删除')
  fetchBanners()
}

onMounted(async () => {
  await Promise.all([fetchCourses(), fetchBanners()])
})
</script>

<style scoped>
.banner-cover-preview {
  width: 110px;
  height: 62px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}
</style>
