<template>
  <div class="member-course-page">
    <header class="topbar">
      <button class="brand-block" type="button" @click="router.push('/member-home')">
        <img class="brand-logo" :src="brandLogo" alt="教育云平台 logo" />
        <div class="brand-title">教育云平台</div>
      </button>

      <el-menu
        :default-active="activeNav"
        mode="horizontal"
        class="topnav"
        @select="handleNavSelect"
      >
        <el-menu-item
          v-for="item in navItems"
          :key="item.key"
          :index="item.key"
        >
          {{ item.label }}
        </el-menu-item>
      </el-menu>

      <el-dropdown trigger="click" placement="bottom-end">
        <button class="profile-entry" type="button">
          <el-avatar class="profile-avatar" :size="34" :src="avatarUrl">
            {{ displayName.slice(0, 1).toUpperCase() }}
          </el-avatar>
          <div class="profile-copy">
            <strong>{{ displayName }}</strong>
          </div>
        </button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="goProfile">个人中心</el-dropdown-item>
            <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </header>

    <main class="course-main">
      <section class="page-hero">
        <div>
          <div class="page-kicker">Course Library</div>
          <h1>课程学习</h1>
        </div>

        <div class="page-toolbar">
          <el-input
            v-model="keyword"
            class="toolbar-search"
            placeholder="搜索课程标题或简介"
            clearable
          />
          <el-select v-model="sortMode" class="toolbar-sort">
            <el-option label="热门优先" value="hot" />
            <el-option label="最新优先" value="latest" />
            <el-option label="标题排序" value="title" />
          </el-select>
        </div>
      </section>

      <section class="page-layout">
        <aside class="category-panel">
          <div class="panel-head">课程分类</div>

          <button
            class="category-all"
            :class="{ 'is-active': !selectedLevel1Id && !selectedLevel2Id }"
            type="button"
            @click="resetFilters"
          >
            全部课程
          </button>

          <div class="category-tree">
            <div
              v-for="item in categoryTree"
              :key="item.id"
              class="category-group"
            >
              <button
                class="category-level1"
                :class="{ 'is-active': selectedLevel1Id === item.id && !selectedLevel2Id }"
                type="button"
                @click="selectLevel1(item.id)"
              >
                <span>{{ item.name }}</span>
                <span class="group-count">{{ countCoursesByLevel1(item.id) }}</span>
              </button>

              <div class="category-level2-list">
                <button
                  v-for="child in item.children || []"
                  :key="child.id"
                  class="category-level2"
                  :class="{ 'is-active': selectedLevel2Id === child.id }"
                  type="button"
                  @click="selectLevel2(item.id, child.id)"
                >
                  <span>{{ child.name }}</span>
                  <span class="group-count">{{ countCoursesByLevel2(child.id) }}</span>
                </button>
              </div>
            </div>
          </div>
        </aside>

        <section class="course-panel" v-loading="loading">
          <div class="course-panel-head">
            <div>
              <h2>{{ currentPanelTitle }}</h2>
              <p>{{ filteredCourses.length }} 门课程</p>
            </div>
          </div>

          <div v-if="filteredCourses.length" class="course-grid">
            <article
              v-for="course in pagedCourses"
              :key="course.id"
              class="course-card"
              @click="goCourseDetail(course.id)"
            >
              <div class="course-cover" :style="buildCourseCoverStyle(course.coverUrl)">
                <div class="course-cover-overlay"></div>
                <div class="course-cover-top">
                </div>
              </div>
              <div class="course-body">
                <div class="course-category">{{ course.category }}</div>
                <h3>{{ course.title }}</h3>
                <p>{{ course.summary }}</p>
                <div class="course-meta">
                  <span>{{ course.teacherName || '平台课程' }}</span>
                  <span>{{ course.learners }} 人报名</span>
                </div>
              </div>
            </article>
          </div>

          <div v-if="filteredCourses.length" class="course-pagination">
            <el-pagination
              v-model:current-page="pageNum"
              v-model:page-size="pageSize"
              :total="filteredCourses.length"
              :page-sizes="[8, 12, 16, 24]"
              layout="total, sizes, prev, pager, next, jumper"
              background
              @size-change="handlePageSizeChange"
            />
          </div>

          <el-empty
            v-else-if="!loading"
            description="暂无匹配课程"
            :image-size="90"
          />
        </section>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getPortalCategoryTree } from '@/api/category'
import { getPortalCourseList } from '@/api/course'
import brandLogo from '@/assets/education-cloud-logo.jpg'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const navItems = [
  { key: 'home', label: '首页' },
  { key: 'courses', label: '课程学习' },
  { key: 'tasks', label: '我的任务' },
  { key: 'community', label: '交流社区' }
]

const loading = ref(false)
const categoryTree = ref([])
const portalCourses = ref([])
const selectedLevel1Id = ref(null)
const selectedLevel2Id = ref(null)
const keyword = ref('')
const sortMode = ref('hot')
const pageNum = ref(1)
const pageSize = ref(8)

const activeNav = computed(() => {
  if (route.path.startsWith('/member/tasks')) {
    return 'tasks'
  }
  return 'courses'
})

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')

const currentPanelTitle = computed(() => {
  if (selectedLevel2Id.value) {
    for (const item of categoryTree.value) {
      const target = item.children?.find((child) => child.id === selectedLevel2Id.value)
      if (target) {
        return target.name
      }
    }
  }

  if (selectedLevel1Id.value) {
    return categoryTree.value.find((item) => item.id === selectedLevel1Id.value)?.name || '课程学习'
  }

  return '全部课程'
})

const filteredCourses = computed(() => {
  let list = [...portalCourses.value]

  if (selectedLevel2Id.value) {
    list = list.filter((course) => course.categoryLevel2Id === selectedLevel2Id.value)
  } else if (selectedLevel1Id.value) {
    list = list.filter((course) => course.categoryLevel1Id === selectedLevel1Id.value)
  }

  const normalizedKeyword = keyword.value.trim().toLowerCase()
  if (normalizedKeyword) {
    list = list.filter((course) =>
      [course.title, course.summary, course.teacherName, course.category]
        .filter(Boolean)
        .some((field) => field.toLowerCase().includes(normalizedKeyword))
    )
  }

  if (sortMode.value === 'latest') {
    list.sort((a, b) => b.id - a.id)
  } else if (sortMode.value === 'title') {
    list.sort((a, b) => a.title.localeCompare(b.title, 'zh-CN'))
  } else {
    list.sort((a, b) => {
      if ((b.learners || 0) !== (a.learners || 0)) {
        return (b.learners || 0) - (a.learners || 0)
      }
      return a.id - b.id
    })
  }

  return list
})

const pagedCourses = computed(() => {
  const start = (pageNum.value - 1) * pageSize.value
  return filteredCourses.value.slice(start, start + pageSize.value)
})

function handleNavSelect(key) {
  const routeMap = {
    home: '/member-home',
    courses: '/member/courses',
    tasks: '/member/tasks'
  }
  if (routeMap[key]) {
    router.push(routeMap[key])
  }
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function goProfile() {
  router.push('/member/profile')
}

function goCourseDetail(id) {
  router.push(`/member/courses/${id}`)
}

function mapPortalCourse(course) {
  return {
    id: course.id,
    categoryLevel1Id: course.categoryLevel1Id,
    categoryLevel2Id: course.categoryLevel2Id,
    category: [course.categoryLevel1Name, course.categoryLevel2Name].filter(Boolean).join(' / '),
    title: course.title,
    summary: course.subTitle || course.description || '课程内容建设中',
    teacherName: course.teacherName || '',
    learners: course.studyCount || 0,
    coverUrl: course.coverUrl || ''
  }
}

function buildCourseCoverStyle(coverUrl) {
  if (!coverUrl) {
    return {}
  }
  return {
    backgroundImage: `url(${coverUrl})`,
    backgroundSize: 'cover',
    backgroundPosition: 'center'
  }
}

function selectLevel1(id) {
  selectedLevel1Id.value = selectedLevel1Id.value === id ? null : id
  selectedLevel2Id.value = null
  syncCategoryQuery()
}

function selectLevel2(level1Id, level2Id) {
  selectedLevel1Id.value = level1Id
  selectedLevel2Id.value = selectedLevel2Id.value === level2Id ? null : level2Id
  syncCategoryQuery()
}

function resetFilters() {
  selectedLevel1Id.value = null
  selectedLevel2Id.value = null
  keyword.value = ''
  syncCategoryQuery()
}

function handlePageSizeChange() {
  pageNum.value = 1
}

function countCoursesByLevel1(level1Id) {
  return portalCourses.value.filter((course) => course.categoryLevel1Id === level1Id).length
}

function countCoursesByLevel2(level2Id) {
  return portalCourses.value.filter((course) => course.categoryLevel2Id === level2Id).length
}

async function fetchPortalCategories() {
  const { data } = await getPortalCategoryTree()
  categoryTree.value = data || []
}

async function fetchPortalCourses() {
  loading.value = true
  try {
    const { data } = await getPortalCourseList({
      pageNum: 1,
      pageSize: 100
    })

    portalCourses.value = (data?.list || []).map((course) => mapPortalCourse(course))
  } finally {
    loading.value = false
  }
}

function applyCategoryQuery() {
  const level1Id = Number(route.query.level1Id)
  const level2Id = Number(route.query.level2Id)
  selectedLevel1Id.value = Number.isFinite(level1Id) && level1Id > 0 ? level1Id : null
  selectedLevel2Id.value = Number.isFinite(level2Id) && level2Id > 0 ? level2Id : null
}

function syncCategoryQuery() {
  router.replace({
    path: '/member/courses',
    query: {
      ...(selectedLevel1Id.value ? { level1Id: selectedLevel1Id.value } : {}),
      ...(selectedLevel2Id.value ? { level2Id: selectedLevel2Id.value } : {})
    }
  })
}

onMounted(async () => {
  await Promise.all([fetchPortalCategories(), fetchPortalCourses()])
  applyCategoryQuery()
})

watch(
  () => [route.query.level1Id, route.query.level2Id],
  () => {
    applyCategoryQuery()
  }
)

watch([selectedLevel1Id, selectedLevel2Id, keyword, sortMode], () => {
  pageNum.value = 1
})

watch(filteredCourses, (courses) => {
  const maxPage = Math.max(1, Math.ceil(courses.length / pageSize.value))
  if (pageNum.value > maxPage) {
    pageNum.value = maxPage
  }
})
</script>

<style scoped>
.member-course-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(15, 23, 42, 0.04), transparent 26%),
    linear-gradient(180deg, #f7f8fa 0%, #f2f4f7 100%);
  color: #303133;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 0 32px;
  height: 64px;
  background: rgba(255, 255, 255, 0.88);
  border-bottom: 1px solid rgba(220, 223, 230, 0.9);
  backdrop-filter: blur(14px);
}

.brand-block {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
  border: 0;
  background: transparent;
  cursor: pointer;
  padding: 0;
}

.brand-logo {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  object-fit: cover;
}

.brand-title {
  font-size: 20px;
  font-weight: 700;
  color: #1f2d3d;
}

.topnav {
  flex: 1;
  border-bottom: 0;
  justify-content: center;
  min-width: 0;
}

.profile-entry {
  border: 1px solid #dcdfe6;
  background: rgba(255, 255, 255, 0.96);
  border-radius: 10px;
  padding: 6px 10px;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.profile-avatar {
  background: #409eff;
  color: #fff;
}

.profile-copy {
  display: flex;
  align-items: center;
  line-height: 1;
}

.profile-copy strong {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #303133;
  font-size: 14px;
}

.course-main {
  width: min(1320px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 28px 0 40px;
}

.page-hero {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 24px;
  padding: 28px 32px;
  border-radius: 22px;
  background:
    linear-gradient(135deg, rgba(17, 24, 39, 0.96) 0%, rgba(30, 64, 175, 0.92) 54%, rgba(59, 130, 246, 0.82) 100%);
  box-shadow: 0 18px 44px rgba(15, 23, 42, 0.14);
}

.page-kicker {
  color: rgba(255, 255, 255, 0.7);
  font-size: 12px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.page-hero h1 {
  margin: 10px 0 0;
  font-size: clamp(32px, 5vw, 44px);
  color: #fff;
}

.page-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toolbar-search {
  width: 280px;
}

.toolbar-sort {
  width: 140px;
}

.page-layout {
  margin-top: 24px;
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 22px;
  align-items: start;
}

.category-panel,
.course-panel {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(220, 223, 230, 0.92);
  border-radius: 18px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.category-panel {
  padding: 22px 18px 18px;
}

.panel-head {
  margin-bottom: 14px;
  font-size: 20px;
  font-weight: 700;
  color: #1f2d3d;
}

.category-all,
.category-level1,
.category-level2 {
  width: 100%;
  border: 0;
  background: transparent;
  text-align: left;
  cursor: pointer;
}

.category-all {
  padding: 12px 14px;
  border-radius: 12px;
  color: #303133;
  font-size: 14px;
  font-weight: 600;
}

.category-all.is-active,
.category-all:hover {
  background: #eff6ff;
  color: #1d4ed8;
}

.category-tree {
  margin-top: 10px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.category-group {
  padding: 8px 0 0;
  border-top: 1px solid #eef2f7;
}

.category-group:first-child {
  border-top: 0;
}

.category-level1,
.category-level2 {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.category-level1 {
  padding: 10px 14px;
  border-radius: 12px;
  color: #111827;
  font-size: 15px;
  font-weight: 700;
}

.category-level1.is-active,
.category-level1:hover {
  background: #f8fafc;
}

.category-level2-list {
  margin-top: 4px;
  padding-left: 10px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.category-level2 {
  padding: 10px 14px;
  border-radius: 10px;
  color: #606266;
  font-size: 14px;
}

.category-level2.is-active,
.category-level2:hover {
  background: #eff6ff;
  color: #1d4ed8;
}

.group-count {
  color: #9ca3af;
  font-size: 12px;
  font-weight: 600;
}

.course-panel {
  padding: 22px;
}

.course-panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding-bottom: 14px;
  border-bottom: 1px solid #ebeef5;
}

.course-panel-head h2 {
  margin: 0;
  font-size: 24px;
  color: #1f2d3d;
}

.course-panel-head p {
  margin: 8px 0 0;
  color: #909399;
  font-size: 13px;
}

.course-grid {
  margin-top: 18px;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.course-card {
  border: 1px solid #dcdfe6;
  background: rgba(255, 255, 255, 0.98);
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.course-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 26px rgba(31, 45, 61, 0.08);
}

.course-cover {
  position: relative;
  height: 128px;
  padding: 12px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  background: linear-gradient(135deg, #eaf2ff 0%, #d9e8ff 100%);
  border-bottom: 1px solid #ebeef5;
}

.course-cover-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(15, 23, 42, 0.08) 0%, rgba(15, 23, 42, 0.48) 100%);
}

.course-cover-top {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
  gap: 12px;
}

.course-body {
  padding: 14px;
}

.course-category {
  color: #409eff;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
}

.course-body h3 {
  margin: 8px 0;
  font-size: 16px;
  line-height: 1.3;
  color: #303133;
}

.course-body p {
  margin: 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
  min-height: 42px;
}

.course-meta {
  margin-top: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: #909399;
  font-size: 12px;
}

.course-pagination {
  margin-top: 22px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 1180px) {
  .page-layout {
    grid-template-columns: 1fr;
  }

  .course-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .course-cover {
    height: 150px;
  }
}

@media (max-width: 900px) {
  .topbar {
    flex-wrap: wrap;
    height: auto;
    padding: 10px 18px;
  }

  .topnav {
    width: 100%;
  }

  .course-main {
    width: min(100vw - 24px, 1320px);
    padding-top: 18px;
  }

  .page-hero {
    flex-direction: column;
    align-items: flex-start;
    padding: 22px;
  }

  .page-toolbar {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar-search,
  .toolbar-sort {
    width: 100%;
  }
}

@media (max-width: 640px) {
  .course-panel,
  .category-panel {
    padding: 18px 16px;
  }

  .course-grid {
    grid-template-columns: 1fr;
  }

  .course-body p {
    min-height: 0;
  }

  .course-pagination {
    justify-content: center;
    overflow-x: auto;
    padding-bottom: 2px;
  }
}
</style>
