<template>
  <div class="member-home">
    <header class="topbar">
      <div class="brand-block">
        <div class="brand-title">教育平台</div>
      </div>

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
          <el-avatar class="profile-avatar" :size="34">
            {{ displayName.slice(0, 1).toUpperCase() }}
          </el-avatar>
          <div class="profile-copy">
            <strong>{{ displayName }}</strong>
            <span>学员端</span>
          </div>
        </button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item>个人中心</el-dropdown-item>
            <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </header>

    <main class="member-main">
      <section class="hero-section">
        <div class="category-panel">
          <div class="panel-title">课程分类</div>

          <div class="category-content">
            <div class="category-menu-shell">
              <div class="category-level1">
                <button
                  v-for="(item, index) in categoryTree"
                  :key="item.id"
                  class="category-item"
                  :class="{ 'is-active': item.id === activeCategoryId }"
                  type="button"
                  @click="handleCategorySelect(item.id)"
                >
                  <span>{{ item.name }}</span>
                  <span class="category-arrow">›</span>
                </button>
              </div>

              <div
                v-if="activeSubcategories.length"
                class="category-level2-float"
                :style="activeSubmenuStyle"
              >
                <div class="category-level2-list">
                  <button
                    v-for="item in activeSubcategories"
                    :key="item.id"
                    class="subcategory-row"
                    type="button"
                  >
                    <span>{{ item.name }}</span>
                    <span class="subcategory-arrow">›</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="banner-panel">
          <div class="banner-surface">
            <div class="banner-badge">轮播推荐</div>
            <div class="banner-track">
              <div class="banner-main-copy">课程轮播区域</div>
              <div class="banner-subcopy">Banner</div>
            </div>
          </div>
        </div>
      </section>

      <section class="course-section">
        <div class="section-head">
          <h2>热门课程</h2>
          <el-button plain>查看全部</el-button>
        </div>

        <div class="course-grid">
          <article
            v-for="course in hotCourses"
            :key="course.id"
            class="course-card"
          >
            <div class="course-cover">
              <el-tag size="small" effect="plain">{{ course.badge }}</el-tag>
              <div class="course-index">{{ course.code }}</div>
            </div>
            <div class="course-body">
              <div class="course-category">{{ course.category }}</div>
              <h3>{{ course.title }}</h3>
              <p>{{ course.summary }}</p>
              <div class="course-meta">
                <span>{{ course.lessons }} 节内容</span>
                <span>{{ course.learners }} 人学习</span>
              </div>
            </div>
          </article>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const navItems = [
  { key: 'home', label: '首页' },
  { key: 'courses', label: '课程学习' },
  { key: 'practice', label: '在线实训' },
  { key: 'certification', label: '能力认证' },
  { key: 'community', label: '交流社区' }
]

const categoryTree = [
  {
    id: 1,
    name: '企业文化',
    children: [
      { id: 11, name: '企业价值观' },
      { id: 12, name: '组织协同' },
      { id: 13, name: '职业素养' }
    ]
  },
  {
    id: 2,
    name: '锐道云',
    children: [
      { id: 21, name: '云原生基础' },
      { id: 22, name: '平台实战' },
      { id: 23, name: '运维规范' }
    ]
  },
  {
    id: 3,
    name: '云计算&大数据',
    children: [
      { id: 31, name: '数据分析' },
      { id: 32, name: '分布式计算' },
      { id: 33, name: '数据治理' }
    ]
  },
  {
    id: 4,
    name: '人力资源管理',
    children: [
      { id: 41, name: '入职培养' },
      { id: 42, name: '绩效提升' },
      { id: 43, name: '管理进阶' }
    ]
  }
]

const hotCourses = [
  {
    id: 1,
    code: 'C-001',
    badge: '热门推荐',
    category: '企业文化 / 职业素养',
    title: '新员工融入与职业协作',
    summary: '围绕企业协作场景搭建学习路径，适合作为学员端首页推荐入口。',
    lessons: 18,
    learners: 1240
  },
  {
    id: 2,
    code: 'C-002',
    badge: '进阶课程',
    category: '锐道云 / 平台实战',
    title: '云平台交付流程实训',
    summary: '聚焦真实项目流程，展示课程卡片在首页列表中的基础承载方式。',
    lessons: 24,
    learners: 986
  },
  {
    id: 3,
    code: 'C-003',
    badge: '能力提升',
    category: '云计算&大数据 / 数据分析',
    title: '数据分析项目训练营',
    summary: '面向用户端的热门课程展示模块，当前先固定卡片内容和布局。',
    lessons: 16,
    learners: 1528
  },
  {
    id: 4,
    code: 'C-004',
    badge: '管理专题',
    category: '人力资源管理 / 管理进阶',
    title: '团队管理与绩效辅导',
    summary: '保留后续接入真实课程数据的空间，当前以静态结构完善页面框架。',
    lessons: 12,
    learners: 768
  }
]

const activeNav = ref('home')
const activeCategoryId = ref(null)

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const activeSubcategories = computed(() => {
  return categoryTree.find((item) => item.id === activeCategoryId.value)?.children || []
})

const activeSubmenuStyle = computed(() => {
  const activeIndex = categoryTree.findIndex((item) => item.id === activeCategoryId.value)
  if (activeIndex < 0) {
    return {}
  }

  return {
    top: `${activeIndex * 52}px`
  }
})

function handleNavSelect(key) {
  activeNav.value = key
}

function handleCategorySelect(id) {
  activeCategoryId.value = activeCategoryId.value === id ? null : id
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.member-home {
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(64, 158, 255, 0.14), transparent 26%),
    radial-gradient(circle at top right, rgba(31, 45, 61, 0.08), transparent 24%),
    linear-gradient(180deg, #f6f8fc 0%, #eef3f9 100%);
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
  min-width: 0;
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
  flex-direction: column;
  align-items: flex-start;
  line-height: 1.2;
}

.profile-copy strong {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #303133;
  font-size: 14px;
}

.profile-copy span {
  color: #909399;
  font-size: 12px;
}

.member-main {
  width: min(1280px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 24px 0 40px;
}

.hero-section {
  display: grid;
  grid-template-columns: 320px minmax(0, 1fr);
  gap: 16px;
  align-items: stretch;
}

.category-panel,
.banner-panel,
.course-section {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(220, 223, 230, 0.95);
  border-radius: 14px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.category-panel {
  padding: 16px;
  min-height: 260px;
  position: relative;
  overflow: visible;
  z-index: 3;
}

.panel-title {
  font-size: 14px;
  font-weight: 600;
  color: #1f2d3d;
  margin-bottom: 14px;
}

.category-content {
  min-height: 208px;
}

.category-menu-shell {
  width: 180px;
  position: relative;
}

.category-level1 {
  display: flex;
  flex-direction: column;
  background: linear-gradient(180deg, #eef4ff 0%, #e7effc 100%);
  border: 1px solid #d6e2f2;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 10px 26px rgba(71, 104, 151, 0.12);
}

.category-item {
  width: 100%;
  padding: 0 18px;
  min-height: 52px;
  border: 0;
  border-bottom: 1px solid #d9e5f5;
  background: transparent;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: #4c5e78;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.category-item:last-child {
  border-bottom: 0;
}

.category-item:hover,
.category-item.is-active {
  background: rgba(255, 255, 255, 0.42);
  color: #1f2d3d;
}

.category-arrow {
  font-size: 14px;
  color: #7f92ad;
}

.category-level2-float {
  position: absolute;
  left: calc(100% + 12px);
  width: 190px;
  padding: 0;
  background: linear-gradient(180deg, #eef4ff 0%, #e7effc 100%);
  border: 1px solid #d6e2f2;
  border-radius: 14px;
  box-shadow: 0 14px 30px rgba(71, 104, 151, 0.18);
  overflow: hidden;
}

.category-level2-list {
  display: flex;
  flex-direction: column;
}

.subcategory-row {
  width: 100%;
  min-height: 52px;
  border: 0;
  border-bottom: 1px solid #d9e5f5;
  background: transparent;
  color: #4c5e78;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 18px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.subcategory-row:last-child {
  border-bottom: 0;
}

.subcategory-row:hover {
  background: rgba(255, 255, 255, 0.42);
  color: #1f2d3d;
}

.subcategory-arrow {
  color: #7f92ad;
}

.banner-panel {
  min-height: 260px;
  padding: 0;
  overflow: hidden;
}

.banner-surface {
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 18px 22px;
  background:
    linear-gradient(135deg, rgba(18, 86, 170, 0.92) 0%, rgba(54, 126, 214, 0.88) 52%, rgba(110, 170, 234, 0.78) 100%),
    radial-gradient(circle at top right, rgba(255, 255, 255, 0.3), transparent 26%);
  position: relative;
}

.banner-surface::before {
  content: '';
  position: absolute;
  inset: 0;
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

.banner-badge {
  display: inline-flex;
  align-items: center;
  width: fit-content;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  border: 1px solid rgba(255, 255, 255, 0.24);
  color: #fff;
  font-size: 13px;
  letter-spacing: 0.08em;
}

.banner-track {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: flex-start;
}

.banner-main-copy {
  font-size: clamp(30px, 4vw, 46px);
  font-weight: 700;
  line-height: 1.1;
  color: #fff;
}

.banner-subcopy {
  margin-top: 10px;
  color: rgba(255, 255, 255, 0.74);
  font-size: 14px;
  letter-spacing: 0.22em;
  text-transform: uppercase;
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
  border-radius: 12px;
  overflow: hidden;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.course-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 26px rgba(31, 45, 61, 0.08);
}

.course-cover {
  height: 68px;
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #f8fbff;
  border-bottom: 1px solid #ebeef5;
}

.course-index {
  font-size: 12px;
  color: #909399;
}

.course-body {
  padding: 18px;
}

.course-category {
  color: #409eff;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
}

.course-body h3 {
  margin: 10px 0 10px;
  font-size: 18px;
  line-height: 1.3;
  color: #303133;
}

.course-body p {
  margin: 0;
  color: #606266;
  line-height: 1.7;
  min-height: 72px;
}

.course-meta {
  margin-top: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: #909399;
  font-size: 13px;
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

  .category-content {
    min-height: auto;
  }

  .category-menu-shell {
    width: 100%;
  }

  .category-level2-float {
    position: static;
    width: 100%;
    margin-top: 10px;
  }

  .category-panel,
  .banner-panel {
    min-height: auto;
  }

  .banner-surface {
    min-height: 220px;
  }
}

@media (max-width: 640px) {
  .category-panel {
    padding: 14px;
  }

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
}
</style>
