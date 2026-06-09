<template>
  <div class="member-home">
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

    <main class="member-main">
      <section class="hero-section">
        <div ref="categoryMenuRef" class="category-nav">
          <div class="category-menu-shell">
            <div
              class="category-level1"
              :class="{ 'is-scrolling': categoryScrolling }"
              @scroll="handleCategoryScroll"
            >
              <button
                v-for="item in categoryTree"
                :key="item.id"
                class="category-item"
                :class="{ 'is-active': item.id === activeCategoryId }"
                type="button"
                @click.stop="handleCategorySelect(item.id)"
              >
                <span class="category-name">{{ item.name }}</span>
                <span class="category-arrow">›</span>
              </button>
            </div>

            <div
              v-if="activeSubcategories.length"
              class="category-level2-float"
              :style="activeSubmenuStyle"
              @click.stop
            >
              <div class="category-level2-card">
                <div class="category-level2-list">
                  <button
                    v-for="item in activeSubcategories"
                    :key="item.id"
                    class="subcategory-row"
                    :class="{ 'is-active': item.id === activeCourseCategoryId }"
                    type="button"
                    @click="handleSubcategorySelect(item.id)"
                  >
                    <span>{{ item.name }}</span>
                    <span class="subcategory-arrow">›</span>
                  </button>
                </div>

                <div
                  v-if="activeCategoryCourses.length"
                  class="category-level3-float"
                  :style="activeCourseMenuStyle"
                >
                  <div class="category-level3-card">
                    <div class="category-level3-list">
                      <button
                        v-for="course in activeCategoryCourses"
                        :key="course.id"
                        class="course-nav-row"
                        type="button"
                        @click="goCourseDetail(course.id)"
                      >
                        <span class="course-nav-name">{{ course.title }}</span>
                        <span class="course-nav-arrow">›</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="banner-panel">
          <div
            class="banner-surface"
            :style="bannerSurfaceStyle"
            @click="handleBannerClick"
            @mouseenter="stopBannerRotation"
            @mouseleave="startBannerRotation"
          >
            <div v-if="currentBanner" class="banner-layout">
              <div class="banner-track">
                <div class="banner-category">{{ currentBanner.category || '热门课程' }}</div>
                <div class="banner-main-copy">{{ currentBanner.title }}</div>
                <div class="banner-summary">{{ currentBanner.summary }}</div>
                <div class="banner-meta">
                  <span>{{ currentBanner.teacherName || '平台课程' }}</span>
                  <span>{{ currentBanner.learners }} 人报名</span>
                </div>
              </div>

              <button
                v-if="bannerCourses.length > 1"
                class="banner-nav-button is-prev"
                type="button"
                aria-label="上一张轮播图"
                @click.stop="goPrevBanner"
              >
                &#8249;
              </button>
              <button
                v-if="bannerCourses.length > 1"
                class="banner-nav-button is-next"
                type="button"
                aria-label="下一张轮播图"
                @click.stop="goNextBanner"
              >
                &#8250;
              </button>
            </div>

            <div v-if="bannerCourses.length > 1" class="banner-pagination">
              <button
                v-for="(item, index) in bannerCourses"
                :key="item.id"
                class="banner-page-dot"
                :class="{ 'is-active': index === activeBannerIndex }"
                type="button"
                :aria-label="`切换到第 ${index + 1} 张轮播图`"
                @click.stop="selectBanner(index)"
              >
                <span>{{ index + 1 }}</span>
              </button>
            </div>

            <div v-else class="banner-track">
              <div class="banner-main-copy">热门课程推荐</div>
              <div class="banner-subcopy">Banner</div>
            </div>
          </div>
        </div>
      </section>

      <section class="course-section">
        <div class="section-head">
          <div>
            <h2>热门课程</h2>
          </div>
          <el-button plain @click="router.push('/member/courses')">查看全部</el-button>
        </div>

        <div class="course-grid">
          <article
            v-for="(course, index) in hotCourses"
            :key="course.id"
            class="course-card"
            :class="[`is-rank-${Math.min(index + 1, 4)}`]"
            @click="goCourseDetail(course.id)"
          >
            <div class="course-cover" :style="buildCourseCoverStyle(course.coverUrl)">
              <div class="course-cover-overlay"></div>
              <div class="course-cover-top">
                <div class="course-rank-badge">TOP {{ String(index + 1).padStart(2, '0') }}</div>
              </div>
              <div class="course-cover-bottom">
                <div class="course-cover-meta">{{ course.learners }} 人报名</div>
              </div>
            </div>
            <div class="course-body">
              <div class="course-body-top">
                <div class="course-category">{{ course.category }}</div>
              </div>
              <h3>{{ course.title }}</h3>
              <p>{{ course.summary }}</p>
              <div class="course-meta-row">
                <span class="course-teacher">{{ course.teacherName || '平台课程' }}</span>
                <span class="course-learners">{{ course.learners }} 人报名</span>
              </div>
            </div>
          </article>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getPortalCategoryTree } from '@/api/category'
import { getPortalCourseBanners, getPortalCourseList } from '@/api/course'
import brandLogo from '@/assets/education-cloud-logo.jpg'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const navItems = [
  { key: 'home', label: '首页' },
  { key: 'courses', label: '课程学习' },
  { key: 'certification', label: '我的任务' },
  { key: 'community', label: '交流社区' }
]

const categoryTree = ref([])
const portalCourses = ref([])
const bannerCourses = ref([])
const activeCategoryId = ref(null)
const activeCourseCategoryId = ref(null)
const activeBannerIndex = ref(0)
const categoryMenuRef = ref(null)
const categoryScrolling = ref(false)
let bannerTimer = null
let categoryScrollTimer = null

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')

const activeNav = computed(() => {
  if (route.path.startsWith('/member/courses')) {
    return 'courses'
  }
  return 'home'
})

const activeSubcategories = computed(() => {
  return categoryTree.value.find((item) => item.id === activeCategoryId.value)?.children || []
})

const activeCategoryCourses = computed(() => {
  if (!activeCourseCategoryId.value) {
    return []
  }
  return portalCourses.value.filter((course) => course.categoryLevel2Id === activeCourseCategoryId.value)
})

const hotCourses = computed(() => {
  return [...portalCourses.value]
    .sort((a, b) => {
      if ((b.learners || 0) !== (a.learners || 0)) {
        return (b.learners || 0) - (a.learners || 0)
      }
      return a.id - b.id
    })
    .slice(0, 8)
})

const currentBanner = computed(() => bannerCourses.value[activeBannerIndex.value] || null)

const bannerSurfaceStyle = computed(() => {
  if (!currentBanner.value?.coverUrl) {
    return {}
  }

  return {
    backgroundImage: `linear-gradient(90deg, rgba(7, 17, 34, 0.82) 0%, rgba(7, 17, 34, 0.48) 44%, rgba(7, 17, 34, 0.18) 100%), url(${currentBanner.value.coverUrl})`,
    backgroundSize: 'cover',
    backgroundPosition: 'center'
  }
})

const activeSubmenuStyle = computed(() => {
  const activeIndex = categoryTree.value.findIndex((item) => item.id === activeCategoryId.value)
  if (activeIndex < 0) {
    return {}
  }

  return {
    top: `${activeIndex * 64}px`
  }
})

const activeCourseMenuStyle = computed(() => {
  const activeIndex = activeSubcategories.value.findIndex((item) => item.id === activeCourseCategoryId.value)
  if (activeIndex < 0) {
    return {}
  }

  return {
    top: `${activeIndex * 54}px`
  }
})

function handleNavSelect(key) {
  const routeMap = {
    home: '/member-home',
    courses: '/member/courses'
  }
  if (routeMap[key]) {
    router.push(routeMap[key])
  }
}

function handleCategorySelect(id) {
  if (activeCategoryId.value === id) {
    activeCategoryId.value = null
    activeCourseCategoryId.value = null
    return
  }

  activeCategoryId.value = id
  activeCourseCategoryId.value = null
}

function handleDocumentClick(event) {
  if (!categoryMenuRef.value?.contains(event.target)) {
    activeCategoryId.value = null
    activeCourseCategoryId.value = null
  }
}

function goCourseDetail(id) {
  router.push(`/member/courses/${id}`)
}

function mapPortalCourse(course) {
  const resolvedId = course.courseId || course.id
  return {
    id: resolvedId,
    categoryLevel2Id: course.categoryLevel2Id,
    category: [course.categoryLevel1Name, course.categoryLevel2Name].filter(Boolean).join(' / '),
    title: course.title,
    summary: course.subTitle || course.description || '课程内容建设中',
    teacherName: course.teacherName || '',
    learners: course.studyCount || 0,
    coverUrl: course.coverUrl || ''
  }
}

function stopBannerRotation() {
  if (bannerTimer) {
    clearInterval(bannerTimer)
    bannerTimer = null
  }
}

function stopCategoryScrollTimer() {
  if (categoryScrollTimer) {
    clearTimeout(categoryScrollTimer)
    categoryScrollTimer = null
  }
}

function handleCategoryScroll() {
  categoryScrolling.value = true
  stopCategoryScrollTimer()
  categoryScrollTimer = window.setTimeout(() => {
    categoryScrolling.value = false
    categoryScrollTimer = null
  }, 800)
}

function startBannerRotation() {
  stopBannerRotation()
  if (bannerCourses.value.length <= 1) {
    return
  }
  bannerTimer = window.setInterval(() => {
    activeBannerIndex.value = (activeBannerIndex.value + 1) % bannerCourses.value.length
  }, 5000)
}

function selectBanner(index) {
  activeBannerIndex.value = index
  startBannerRotation()
}

function goPrevBanner() {
  if (bannerCourses.value.length <= 1) {
    return
  }
  activeBannerIndex.value = (activeBannerIndex.value - 1 + bannerCourses.value.length) % bannerCourses.value.length
  startBannerRotation()
}

function goNextBanner() {
  if (bannerCourses.value.length <= 1) {
    return
  }
  activeBannerIndex.value = (activeBannerIndex.value + 1) % bannerCourses.value.length
  startBannerRotation()
}

function handleBannerClick() {
  if (currentBanner.value?.id) {
    goCourseDetail(currentBanner.value.id)
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

async function fetchPortalCategories() {
  const { data } = await getPortalCategoryTree()
  categoryTree.value = data || []
}

async function fetchPortalCourses() {
  const { data } = await getPortalCourseList({
    pageNum: 1,
    pageSize: 100
  })

  portalCourses.value = (data?.list || []).map((course) => mapPortalCourse(course))
}

async function fetchBannerCourses() {
  const { data } = await getPortalCourseBanners()
  bannerCourses.value = (data || []).map((course) => mapPortalCourse(course))
  activeBannerIndex.value = 0
  startBannerRotation()
}

function handleSubcategorySelect(id) {
  activeCourseCategoryId.value = activeCourseCategoryId.value === id ? null : id
}

async function initPortalHome() {
  await Promise.all([
    authStore.fetchProfile(),
    fetchPortalCategories(),
    fetchPortalCourses(),
    fetchBannerCourses()
  ])
  if (!bannerCourses.value.length) {
    bannerCourses.value = hotCourses.value.slice(0, 4)
    activeBannerIndex.value = 0
    startBannerRotation()
  }
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function goProfile() {
  router.push('/member/profile')
}

onMounted(() => {
  document.addEventListener('click', handleDocumentClick)
  initPortalHome()
})

onBeforeUnmount(() => {
  stopBannerRotation()
  stopCategoryScrollTimer()
  document.removeEventListener('click', handleDocumentClick)
})
</script>

<style scoped>
.member-home {
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

.member-main {
  width: min(1280px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 24px 0 40px;
}

.hero-section {
  display: grid;
  grid-template-columns: 244px minmax(0, 1fr);
  gap: 20px;
  align-items: start;
  overflow: visible;
  position: relative;
}

.banner-panel,
.course-section {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(220, 223, 230, 0.95);
  border-radius: 14px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.category-nav {
  position: relative;
  z-index: 3;
}

.category-menu-shell {
  width: 100%;
  position: relative;
  overflow: visible;
}

.category-level1 {
  display: flex;
  flex-direction: column;
  height: 258px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  overflow-y: auto;
  overflow-x: hidden;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.05);
  scrollbar-width: thin;
  scrollbar-color: transparent transparent;
}

.category-level1:hover,
.category-level1.is-scrolling {
  scrollbar-color: #cbd5e1 transparent;
}

.category-item {
  width: 100%;
  padding: 0 20px;
  min-height: 64px;
  border: 0;
  border-bottom: 1px solid #eef0f3;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s ease, color 0.2s ease, padding-left 0.2s ease;
}

.category-item:last-child {
  border-bottom: 0;
}

.category-level1::-webkit-scrollbar {
  width: 6px;
}

.category-level1::-webkit-scrollbar-thumb {
  background: transparent;
  border-radius: 999px;
}

.category-level1:hover::-webkit-scrollbar-thumb,
.category-level1.is-scrolling::-webkit-scrollbar-thumb {
  background: #cbd5e1;
}

.category-level1::-webkit-scrollbar-track {
  background: transparent;
}

.category-item:hover,
.category-item.is-active {
  background: #fafafa;
  color: #111827;
  padding-left: 24px;
}

.category-name {
  line-height: 1.4;
}

.category-arrow {
  font-size: 18px;
  color: #9ca3af;
}

.category-level2-float {
  position: absolute;
  left: calc(100% + 16px);
  width: 252px;
  z-index: 8;
}

.category-level2-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  box-shadow: 0 18px 44px rgba(15, 23, 42, 0.12);
  overflow: hidden;
}

.category-level2-list {
  display: flex;
  flex-direction: column;
}

.subcategory-row {
  width: 100%;
  min-height: 54px;
  border: 0;
  border-bottom: 1px solid #eef0f3;
  background: #ffffff;
  color: #4b5563;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.subcategory-row:last-child {
  border-bottom: 0;
}

.subcategory-row:hover {
  background: #fafafa;
  color: #111827;
}

.subcategory-row.is-active {
  background: #f3f7ff;
  color: #1d4ed8;
}

.subcategory-arrow {
  color: #9ca3af;
}

.category-level3-float {
  position: absolute;
  left: calc(100% + 16px);
  width: 268px;
  z-index: 9;
}

.category-level3-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  box-shadow: 0 18px 44px rgba(15, 23, 42, 0.12);
  overflow: hidden;
}

.category-level3-list {
  display: flex;
  flex-direction: column;
}

.course-nav-row {
  width: 100%;
  min-height: 54px;
  border: 0;
  border-bottom: 1px solid #eef0f3;
  background: #ffffff;
  color: #4b5563;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 0 20px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.course-nav-row:last-child {
  border-bottom: 0;
}

.course-nav-row:hover {
  background: #fafafa;
  color: #111827;
}

.course-nav-name {
  flex: 1;
  text-align: left;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.course-nav-arrow {
  color: #9ca3af;
}

.banner-panel {
  height: 258px;
  min-height: 258px;
  padding: 0;
  overflow: hidden;
}

.banner-surface {
  height: 100%;
  min-height: 100%;
  width: 100%;
  display: flex;
  flex: 1;
  flex-direction: column;
  justify-content: space-between;
  padding: 18px 22px;
  background:
    linear-gradient(135deg, rgba(18, 86, 170, 0.92) 0%, rgba(54, 126, 214, 0.88) 52%, rgba(110, 170, 234, 0.78) 100%),
    radial-gradient(circle at top right, rgba(255, 255, 255, 0.3), transparent 26%);
  position: relative;
  isolation: isolate;
  cursor: pointer;
  overflow: hidden;
}

.banner-surface::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 0;
  background:
    linear-gradient(120deg, rgba(255, 255, 255, 0.08) 14%, transparent 14%, transparent 50%, rgba(255, 255, 255, 0.08) 50%, rgba(255, 255, 255, 0.08) 52%, transparent 52%),
    linear-gradient(0deg, rgba(7, 34, 73, 0.12), rgba(7, 34, 73, 0.12));
  pointer-events: none;
}

.banner-badge,
.banner-track {
  position: relative;
  z-index: 1;
}

.banner-track {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: flex-start;
  max-width: min(620px, calc(100% - 120px));
}

.banner-layout {
  position: relative;
  z-index: 2;
  display: flex;
  flex: 1;
  align-items: flex-end;
  justify-content: flex-start;
  gap: 20px;
}

.banner-category {
  display: inline-flex;
  align-items: center;
  margin-bottom: 12px;
  padding: 6px 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  color: rgba(255, 255, 255, 0.9);
  font-size: 12px;
  letter-spacing: 0.04em;
}

.banner-main-copy {
  font-size: clamp(30px, 4vw, 46px);
  font-weight: 700;
  line-height: 1.08;
  color: #fff;
  text-shadow: 0 6px 18px rgba(7, 17, 34, 0.38);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.banner-summary {
  margin-top: 12px;
  color: rgba(255, 255, 255, 0.82);
  font-size: 14px;
  line-height: 1.7;
  text-shadow: 0 4px 12px rgba(7, 17, 34, 0.32);
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.banner-meta {
  margin-top: 18px;
  display: flex;
  align-items: center;
  gap: 18px;
  color: rgba(255, 255, 255, 0.86);
  font-size: 13px;
  text-shadow: 0 4px 12px rgba(7, 17, 34, 0.28);
}

.banner-subcopy {
  margin-top: 10px;
  color: rgba(255, 255, 255, 0.74);
  font-size: 14px;
  letter-spacing: 0.22em;
  text-transform: uppercase;
}

.banner-nav-button {
  position: absolute;
  top: 50%;
  z-index: 3;
  width: 48px;
  height: 48px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 999px;
  background: rgba(12, 21, 36, 0.18);
  color: rgba(255, 255, 255, 0.56);
  display: grid;
  place-items: center;
  cursor: pointer;
  transform: translateY(-50%);
  backdrop-filter: blur(8px);
  box-shadow: 0 12px 30px rgba(7, 17, 34, 0.1);
  opacity: 0.62;
  transition: background-color 0.2s ease, transform 0.2s ease, border-color 0.2s ease, color 0.2s ease, opacity 0.2s ease, box-shadow 0.2s ease;
  font-size: 36px;
  line-height: 1;
}

.banner-nav-button:hover {
  background: rgba(12, 21, 36, 0.52);
  border-color: rgba(255, 255, 255, 0.38);
  color: rgba(255, 255, 255, 0.96);
  opacity: 1;
  box-shadow: 0 16px 36px rgba(7, 17, 34, 0.22);
}

.banner-nav-button.is-prev {
  left: 18px;
}

.banner-nav-button.is-next {
  right: 18px;
}

.banner-pagination {
  position: absolute;
  left: 50%;
  bottom: 16px;
  z-index: 3;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(7, 17, 34, 0.26);
  backdrop-filter: blur(10px);
}

.banner-page-dot {
  width: 22px;
  height: 22px;
  border: 0;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.28);
  color: rgba(255, 255, 255, 0.9);
  display: grid;
  place-items: center;
  font-size: 11px;
  font-weight: 700;
  cursor: pointer;
  transition: transform 0.2s ease, background-color 0.2s ease, color 0.2s ease;
}

.banner-page-dot:hover,
.banner-page-dot.is-active {
  background: #ffffff;
  color: #1d4ed8;
  transform: scale(1.08);
}

.course-section {
  margin-top: 24px;
  padding: 20px;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding-bottom: 14px;
  border-bottom: 1px solid #ebeef5;
}

.section-head h2 {
  margin: 0;
  font-size: 24px;
  color: #1f2d3d;
}

.section-head p {
  margin: 8px 0 0;
  color: #909399;
  font-size: 13px;
}

.course-grid {
  margin-top: 22px;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.course-card {
  border: 1px solid #dcdfe6;
  background: rgba(255, 255, 255, 0.98);
  border-radius: 18px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.24s ease, box-shadow 0.24s ease, border-color 0.24s ease;
}

.course-card:hover {
  transform: translateY(-4px);
  border-color: #bfdbfe;
  box-shadow: 0 16px 32px rgba(31, 45, 61, 0.1);
}

.course-card.is-rank-1 {
  border-color: rgba(59, 130, 246, 0.28);
}

.course-cover {
  position: relative;
  height: 168px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  background:
    linear-gradient(135deg, #eaf2ff 0%, #d9e8ff 100%);
  border-bottom: 1px solid #ebeef5;
}

.course-cover-overlay {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(15, 23, 42, 0.08) 0%, rgba(15, 23, 42, 0.48) 100%);
}

.course-cover-top {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
  gap: 12px;
}

.course-cover-bottom {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: flex-end;
  justify-content: flex-end;
  gap: 12px;
}

.course-rank-badge {
  position: relative;
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  font-size: 12px;
  color: rgba(255, 255, 255, 0.94);
  font-weight: 800;
  letter-spacing: 0.04em;
}

.course-cover-meta {
  color: rgba(255, 255, 255, 0.9);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.course-body {
  padding: 16px 18px;
}

.course-body-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.course-category {
  color: #409eff;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
  line-height: 1.4;
}

.course-body h3 {
  margin: 10px 0 8px;
  font-size: 17px;
  line-height: 1.35;
  color: #303133;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 0;
}

.course-body p {
  margin: 0;
  color: #606266;
  line-height: 1.6;
  min-height: 48px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.course-meta-row {
  margin-top: 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: #909399;
  font-size: 13px;
}

.course-teacher,
.course-learners {
  white-space: nowrap;
}

@media (max-width: 1180px) {
  .hero-section {
    grid-template-columns: 1fr;
  }

  .course-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 840px) {
  .topbar {
    flex-wrap: wrap;
    height: auto;
    padding: 10px 18px;
  }

  .topnav {
    width: 100%;
  }

  .member-main {
    width: min(100vw - 24px, 1280px);
    padding-top: 18px;
  }

  .hero-section {
    grid-template-columns: 1fr;
  }

  .category-menu-shell {
    width: 100%;
  }

  .category-level2-float {
    position: static;
    width: 100%;
    margin-top: 12px;
  }

  .category-level3-float {
    position: static;
    width: 100%;
    margin-top: 12px;
  }

  .banner-panel {
    height: auto;
    min-height: auto;
  }

  .banner-surface {
    min-height: 220px;
  }

  .banner-layout {
    align-items: flex-end;
  }

  .banner-track {
    max-width: min(100%, calc(100% - 96px));
  }

  .banner-nav-button {
    width: 42px;
    height: 42px;
    font-size: 32px;
  }

  .banner-nav-button.is-prev {
    left: 14px;
  }

  .banner-nav-button.is-next {
    right: 14px;
  }
}

@media (max-width: 640px) {
  .course-section {
    padding: 18px;
  }

  .section-head {
    flex-direction: column;
    align-items: flex-start;
  }

  .course-grid {
    grid-template-columns: 1fr;
  }

  .course-body p {
    min-height: 0;
  }

  .course-body h3 {
    min-height: 0;
  }

  .banner-main-copy {
    font-size: 28px;
  }

  .banner-summary {
    -webkit-line-clamp: 2;
  }

  .banner-track {
    max-width: calc(100% - 88px);
  }

  .banner-pagination {
    bottom: 12px;
    gap: 8px;
    padding: 6px 12px;
  }

  .banner-page-dot {
    width: 20px;
    height: 20px;
    font-size: 10px;
  }
}
</style>
