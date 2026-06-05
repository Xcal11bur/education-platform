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
            <div class="category-level1">
              <el-button
                v-for="item in categoryTree"
                :key="item.id"
                class="category-item"
                :type="item.id === activeCategoryId ? 'primary' : 'default'"
                text
                bg
                @click="activeCategoryId = item.id"
              >
                <span>{{ item.name }}</span>
                <span class="category-arrow">›</span>
              </el-button>
            </div>

            <div class="category-level2">
              <div class="category-level2-head">二级分类</div>
              <div class="category-level2-list">
                <template v-if="activeSubcategories.length">
                  <el-button
                    v-for="item in activeSubcategories"
                    :key="item.id"
                    class="subcategory-chip"
                    plain
                  >
                    {{ item.name }}
                  </el-button>
                </template>
                <el-empty
                  v-else
                  class="subcategory-empty"
                  description="暂无二级分类"
                  :image-size="56"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="banner-panel">
          <div class="panel-title">轮播推荐</div>
          <div class="banner-copy">
            <h1>课程发现与学习入口</h1>
            <p>轮播图模块预留，后续接入后端配置和推荐内容。</p>
          </div>
          <div class="banner-stage">
            <div class="banner-placeholder">
              <el-icon class="banner-placeholder-icon"><PictureFilled /></el-icon>
              <span>轮播图区域</span>
            </div>
          </div>
        </div>
      </section>

      <section class="course-section">
        <div class="section-head">
          <div>
            <h2>热门课程</h2>
            <p>先完成首页结构，后续再接入真实推荐数据和点击逻辑。</p>
          </div>
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
import { PictureFilled } from '@element-plus/icons-vue'
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
const activeCategoryId = ref(categoryTree[0]?.id ?? null)

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const activeSubcategories = computed(() => {
  return categoryTree.find((item) => item.id === activeCategoryId.value)?.children || []
})

function handleNavSelect(key) {
  activeNav.value = key
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.member-home {
  min-height: 100vh;
  background: #f5f7fa;
  color: #303133;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 0 32px;
  height: 64px;
  background: #fff;
  border-bottom: 1px solid #dcdfe6;
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
  background: #fff;
  border-radius: 4px;
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
  background: #fff;
  border: 1px solid #dcdfe6;
}

.category-panel {
  padding: 16px;
}

.panel-title {
  font-size: 14px;
  font-weight: 600;
  color: #1f2d3d;
  margin-bottom: 16px;
}

.category-content {
  display: grid;
  grid-template-columns: 144px minmax(0, 1fr);
  gap: 16px;
}

.category-level1 {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.category-item {
  width: 100%;
  margin-left: 0;
  justify-content: space-between;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  color: #606266;
}

.category-arrow {
  font-size: 14px;
  color: #909399;
}

.category-level2 {
  min-height: 100%;
  padding: 16px;
  background: #f9fbff;
  border: 1px solid #ebeef5;
}

.category-level2-head {
  font-size: 14px;
  font-weight: 600;
  color: #409eff;
}

.category-level2-list {
  margin-top: 14px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: flex-start;
}

.subcategory-chip {
  margin-left: 0;
}

.subcategory-empty {
  padding: 12px 0 0;
  width: 100%;
}

.banner-panel {
  padding: 16px;
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 20px;
}

.banner-copy {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.banner-copy h1 {
  margin: 0 0 12px;
  font-size: 28px;
  line-height: 1.25;
  color: #1f2d3d;
}

.banner-copy p {
  margin: 0;
  color: #606266;
  line-height: 1.8;
}

.banner-stage {
  min-height: 240px;
}

.banner-placeholder {
  height: 100%;
  min-height: 240px;
  border: 1px dashed #c0c4cc;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #909399;
  background: #fafafa;
}

.banner-placeholder-icon {
  font-size: 28px;
}

.course-section {
  margin-top: 24px;
  padding: 20px;
}

.section-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 18px;
  padding-bottom: 16px;
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
  background: #fff;
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

  .category-content,
  .banner-panel {
    grid-template-columns: 1fr;
  }

  .banner-stage,
  .banner-placeholder {
    min-height: 200px;
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
