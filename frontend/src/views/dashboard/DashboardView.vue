<template>
  <div class="dashboard-welcome">
    <section class="welcome-hero">
      <div class="welcome-copy">
        <span class="welcome-kicker">Admin Console</span>
        <h1>欢迎进入教育平台管理后台</h1>

        <div class="welcome-actions">
          <el-button type="primary" @click="router.push('/courses')">进入课程管理</el-button>
          <el-button @click="router.push('/teachers')">查看教师管理</el-button>
        </div>
      </div>

      <div class="welcome-panel">
        <div class="panel-item">
          <span>当前角色</span>
          <strong>{{ authStore.profile?.role || 'ADMIN' }}</strong>
        </div>
        <div class="panel-item">
          <span>登录账号</span>
          <strong>{{ authStore.profile?.displayName || '管理员' }}</strong>
        </div>
      </div>
    </section>

    <section class="quick-grid">
      <button
        v-for="item in quickEntries"
        :key="item.path"
        type="button"
        class="quick-card"
        @click="router.push(item.path)"
      >
        <strong>{{ item.title }}</strong>
      </button>
    </section>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const quickEntries = [
  {
    path: '/teachers',
    title: '教师管理'
  },
  {
    path: '/members',
    title: '学员管理'
  },
  {
    path: '/courses',
    title: '课程管理'
  },
  {
    path: '/course-reviews',
    title: '课程评价'
  }
]
</script>

<style scoped>
.dashboard-welcome {
  display: grid;
  gap: 22px;
}

.welcome-hero {
  display: grid;
  grid-template-columns: minmax(0, 1.7fr) minmax(260px, 0.9fr);
  gap: 20px;
  padding: 30px;
  border-radius: 22px;
  background:
    radial-gradient(circle at top right, rgba(255, 255, 255, 0.34), transparent 30%),
    linear-gradient(135deg, #1f4e79 0%, #2d6ea3 100%);
  color: #fff;
  box-shadow: 0 18px 40px rgba(31, 78, 121, 0.16);
}

.welcome-kicker {
  display: inline-flex;
  padding: 6px 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.welcome-copy h1 {
  margin: 14px 0 12px;
  font-size: 30px;
  line-height: 1.2;
}

.welcome-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
}

.welcome-panel {
  display: grid;
  gap: 14px;
}

.panel-item {
  padding: 18px 20px;
  border-radius: 18px;
  background: rgba(12, 28, 44, 0.18);
  border: 1px solid rgba(255, 255, 255, 0.14);
}

.panel-item span {
  display: block;
  color: rgba(255, 255, 255, 0.72);
  font-size: 13px;
}

.panel-item strong {
  display: block;
  margin-top: 10px;
  font-size: 24px;
  font-weight: 700;
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.quick-card {
  padding: 22px;
  border: 1px solid #dcdfe6;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.96);
  text-align: left;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.quick-card:hover {
  transform: translateY(-2px);
  border-color: #b8d2e8;
  box-shadow: 0 14px 30px rgba(45, 110, 163, 0.08);
}

.quick-card strong {
  display: block;
  color: #1f2d3d;
  font-size: 18px;
}

@media (max-width: 900px) {
  .welcome-hero,
  .quick-grid {
    grid-template-columns: 1fr;
  }

  .welcome-copy h1 {
    font-size: 26px;
  }
}
</style>
