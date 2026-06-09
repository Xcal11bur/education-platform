<template>
  <div class="page-card">
    <div class="filter-bar">
      <el-select
        v-model="query.courseId"
        class="course-select"
        placeholder="选择课程"
        filterable
        @change="handleCourseChange"
      >
        <el-option
          v-for="item in courseOptions"
          :key="item.id"
          :label="item.title"
          :value="item.id"
        />
      </el-select>
      <el-select v-model="query.status" class="compact-select" placeholder="状态" clearable>
        <el-option label="待审核" :value="0" />
        <el-option label="已通过" :value="1" />
        <el-option label="已拒绝" :value="2" />
      </el-select>
      <el-select v-model="query.score" class="compact-select" placeholder="评分" clearable>
        <el-option v-for="score in [5, 4, 3, 2, 1]" :key="score" :label="`${score} 分`" :value="score" />
      </el-select>
      <el-button type="primary" @click="fetchReviews">查询</el-button>
    </div>

    <el-table v-if="query.courseId" :data="reviews" border>
      <el-table-column label="ID" width="80">
        <template #default="{ $index }">{{ rowIndex($index) }}</template>
      </el-table-column>
      <el-table-column prop="courseTitle" label="课程" min-width="180" />
      <el-table-column label="学员" min-width="160">
        <template #default="{ row }">
          <div>{{ row.memberNickname || '-' }}</div>
          <div class="muted">{{ row.memberMobile || '-' }}</div>
        </template>
      </el-table-column>
      <el-table-column label="评分" width="120">
        <template #default="{ row }">
          <el-rate :model-value="row.score" disabled show-score text-color="#f59e0b" />
        </template>
      </el-table-column>
      <el-table-column prop="content" label="评价内容" min-width="260" show-overflow-tooltip>
        <template #default="{ row }">
          {{ row.content || '未填写评价内容' }}
        </template>
      </el-table-column>
      <el-table-column label="匿名" width="90">
        <template #default="{ row }">
          {{ row.anonymousFlag === 1 ? '是' : '否' }}
        </template>
      </el-table-column>
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="reviewStatusTag(row.status)">{{ reviewStatusText(row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="提交时间" width="180">
        <template #default="{ row }">{{ formatDateTime(row.createdAt) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.status !== 1"
            link
            type="success"
            @click="updateStatus(row, 1)"
          >
            通过
          </el-button>
          <el-button
            v-if="row.status !== 2"
            link
            type="danger"
            @click="updateStatus(row, 2)"
          >
            拒绝
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
        @current-change="fetchReviews"
        @size-change="fetchReviews"
      />
    </div>

    <div v-if="!query.courseId" class="empty-state">
      <div class="empty-icon-box">↑</div>
      <p>请先选择一门课程</p>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { getCourseList } from '@/api/course'
import { getCourseReviewList, updateCourseReviewStatus } from '@/api/courseReview'

const reviews = ref([])
const total = ref(0)
const courseOptions = ref([])

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  courseId: null,
  status: null,
  score: null
})

function reviewStatusText(value) {
  return (
    {
      0: '待审核',
      1: '已通过',
      2: '已拒绝'
    }[value] || '未知'
  )
}

function reviewStatusTag(value) {
  return (
    {
      0: 'warning',
      1: 'success',
      2: 'danger'
    }[value] || 'info'
  )
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '')
}

function rowIndex(index) {
  return (query.pageNum - 1) * query.pageSize + index + 1
}

function handleCourseChange() {
  query.pageNum = 1
  fetchReviews()
}

async function fetchCourses() {
  const { data } = await getCourseList({ pageNum: 1, pageSize: 100, publishStatus: 1 })
  courseOptions.value = data?.list || []
  if (!query.courseId && courseOptions.value.length) {
    query.courseId = courseOptions.value[0].id
  }
}

async function fetchReviews() {
  if (!query.courseId) {
    reviews.value = []
    total.value = 0
    return
  }
  const { data } = await getCourseReviewList(query)
  reviews.value = data?.list || []
  total.value = data?.total || 0
}

async function updateStatus(row, status) {
  await updateCourseReviewStatus(row.id, { status })
  ElMessage.success(status === 1 ? '评价已通过' : '评价已拒绝')
  fetchReviews()
}

onMounted(async () => {
  await fetchCourses()
  await fetchReviews()
})
</script>

<style scoped>
.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
}

.course-select {
  width: 320px;
  flex: 0 1 320px;
}

.compact-select {
  width: 160px;
  flex: 0 0 160px;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
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

@media (max-width: 1400px) {
  .course-select {
    width: 280px;
    flex-basis: 280px;
  }
}
</style>
