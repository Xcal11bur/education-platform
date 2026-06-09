<template>
  <div class="layout-shell">
    <aside class="layout-sidebar">
      <button class="brand-block" type="button" @click="router.push('/teacher/dashboard')">
        <img class="brand-logo" :src="brandLogo" alt="教育云平台 logo" />
        <div>
          <div class="brand-title">教育云平台</div>
          <div class="brand-subtitle">Teacher Console</div>
        </div>
      </button>

      <el-menu
        :default-active="activeMenu"
        :default-openeds="openMenus"
        class="side-menu"
        background-color="transparent"
        text-color="#d5deea"
        active-text-color="#ffffff"
        router
      >
        <el-menu-item index="/teacher/dashboard">
          <el-icon><Monitor /></el-icon>
          <span>教师工作台</span>
        </el-menu-item>
        <el-menu-item index="/teacher/profile">
          <el-icon><User /></el-icon>
          <span>个人信息</span>
        </el-menu-item>
        <el-menu-item index="/teacher/courses">
          <el-icon><Reading /></el-icon>
          <span>我的课程</span>
        </el-menu-item>
        <el-sub-menu index="teacher-course-hub">
          <template #title>
            <el-icon><FolderOpened /></el-icon>
            <span>课程内容</span>
          </template>
          <el-menu-item index="/teacher/course-management/chapters">课程章节</el-menu-item>
          <el-menu-item index="/teacher/course-management/materials">课程资料</el-menu-item>
          <el-menu-item index="/teacher/course-management/tasks">作业管理</el-menu-item>
          <el-menu-item index="/teacher/course-management/exams">考试管理</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </aside>

    <div class="layout-main">
      <header class="layout-header">
        <div>
          <div class="header-title">{{ currentTitle }}</div>
        </div>
        <div class="header-actions">
          <el-dropdown trigger="click" placement="bottom-end">
            <button class="profile-entry" type="button">
              <el-avatar class="profile-avatar" :size="34" :src="authStore.profile?.avatar">
                {{ (authStore.profile?.displayName || '教师').slice(0, 1).toUpperCase() }}
              </el-avatar>
              <div class="profile-copy">
                <strong>{{ authStore.profile?.displayName || '教师' }}</strong>
                <span>{{ authStore.profile?.role || 'TEACHER' }}</span>
              </div>
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
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
import brandLogo from '@/assets/education-cloud-logo.jpg'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const currentTitle = computed(() => route.meta?.title || '教师端')
const activeMenu = computed(() => route.meta?.activeMenu || route.path)
const openMenus = computed(() => {
  const menus = []
  if (route.path.startsWith('/teacher/course-management/')) {
    menus.push('teacher-course-hub')
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
  width: 100%;
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
  text-align: left;
}

.brand-logo {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  object-fit: cover;
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
  min-height: 64px;
  padding: 10px 24px;
  background: rgba(255, 255, 255, 0.82);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(220, 223, 230, 0.8);
}

.header-title {
  font-size: 18px;
  font-weight: 700;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.profile-entry {
  border: 0;
  background: transparent;
  padding: 0;
  display: inline-flex;
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
  text-align: left;
}

.profile-copy strong {
  color: var(--text-primary);
  font-weight: 600;
}

.profile-copy span {
  display: block;
  margin-top: 2px;
  color: var(--text-secondary);
  font-size: 12px;
}

.layout-content {
  padding: 24px 28px 28px;
  min-height: calc(100vh - 73px);
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

  .profile-copy span {
    display: none;
  }
}
</style>
