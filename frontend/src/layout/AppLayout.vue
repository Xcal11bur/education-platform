<template>
  <div class="layout-shell">
    <aside class="layout-sidebar">
      <div class="brand-block">
        <div class="brand-mark">E</div>
        <div>
          <div class="brand-title">教育云平台</div>
          <div class="brand-subtitle">Admin Console</div>
        </div>
      </div>

      <el-menu
        :default-active="activeMenu"
        :default-openeds="openMenus"
        class="side-menu"
        background-color="transparent"
        text-color="#bfcbd9"
        active-text-color="#ffffff"
        router
      >
        <el-menu-item index="/dashboard">
          <el-icon><Monitor /></el-icon>
          <span>工作台</span>
        </el-menu-item>
        <el-menu-item index="/teachers">
          <el-icon><UserFilled /></el-icon>
          <span>教师管理</span>
        </el-menu-item>
        <el-menu-item index="/members">
          <el-icon><Avatar /></el-icon>
          <span>学员管理</span>
        </el-menu-item>
        <el-menu-item index="/banners">
          <el-icon><Picture /></el-icon>
          <span>轮播图管理</span>
        </el-menu-item>
        <el-menu-item index="/categories">
          <el-icon><Grid /></el-icon>
          <span>课程分类</span>
        </el-menu-item>
        <el-sub-menu index="course-hub">
          <template #title>
            <el-icon><Reading /></el-icon>
            <span>课程管理</span>
          </template>
          <el-menu-item index="/courses">课程列表</el-menu-item>
          <el-menu-item index="/course-management/chapters">课程章节</el-menu-item>
          <el-menu-item index="/course-management/materials">课程资料</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </aside>

    <div class="layout-main">
      <header class="layout-header">
        <div>
          <div class="header-title">{{ currentTitle }}</div>
        </div>
        <div class="header-actions">
          <div class="user-panel">
            <span class="user-name">{{ authStore.profile?.displayName || '管理员' }}</span>
            <span class="user-role">{{ authStore.profile?.role || 'ADMIN' }}</span>
          </div>
          <el-button text @click="handleLogout">退出登录</el-button>
        </div>
      </header>

      <main class="layout-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const currentTitle = computed(() => route.meta?.title || '后台管理')
const activeMenu = computed(() => route.meta?.activeMenu || route.path)
const openMenus = computed(() => {
  const menus = []
  if (route.path.startsWith('/courses') || route.path.startsWith('/course-management/')) {
    menus.push('course-hub')
  }
  return menus
})

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.layout-shell {
  display: grid;
  grid-template-columns: 248px 1fr;
  min-height: 100vh;
}

.layout-sidebar {
  background: linear-gradient(180deg, #1f2a3d 0%, #1a2434 100%);
  color: #fff;
  padding: 18px 14px;
}

.brand-block {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 10px 24px;
}

.brand-mark {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: grid;
  place-items: center;
  font-size: 20px;
  font-weight: 700;
  background: linear-gradient(135deg, #409eff, #2f68ff);
}

.brand-title {
  font-size: 17px;
  font-weight: 700;
}

.brand-subtitle {
  margin-top: 4px;
  color: rgba(255, 255, 255, 0.65);
  font-size: 12px;
}

.side-menu {
  border-right: none;
}

:deep(.el-menu-item) {
  border-radius: 10px;
  margin-bottom: 8px;
}

:deep(.el-menu-item.is-active) {
  background: var(--bg-sidebar-active);
}

:deep(.el-menu-item:hover) {
  background: var(--bg-sidebar-hover);
}

.layout-main {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.layout-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 18px 28px;
  background: rgba(255, 255, 255, 0.78);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(220, 223, 230, 0.8);
}

.header-title {
  font-size: 20px;
  font-weight: 700;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 18px;
}

.user-panel {
  text-align: right;
}

.user-name {
  display: block;
  font-weight: 600;
}

.user-role {
  display: block;
  margin-top: 4px;
  color: var(--text-secondary);
  font-size: 12px;
}

.layout-content {
  padding: 24px 28px 28px;
}

@media (max-width: 1080px) {
  .layout-shell {
    grid-template-columns: 1fr;
  }

  .layout-sidebar {
    padding-bottom: 8px;
  }

  .layout-header,
  .layout-content {
    padding-left: 18px;
    padding-right: 18px;
  }
}
</style>
