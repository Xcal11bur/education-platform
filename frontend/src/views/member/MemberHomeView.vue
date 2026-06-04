<template>
  <div class="member-home">
    <div class="member-card">
      <div class="member-badge">Member Portal</div>
      <h1>教育平台首页</h1>
      <p>学员端首页尚未实现，当前已完成登录分流，学员登录后会先进入这里。</p>

      <div class="member-meta">
        <span>当前用户</span>
        <strong>{{ authStore.profile?.displayName || authStore.profile?.username || '学员' }}</strong>
      </div>

      <el-button type="primary" @click="handleLogout">退出登录</el-button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.member-home {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 24px;
  background:
    radial-gradient(circle at top right, rgba(64, 158, 255, 0.16), transparent 30%),
    linear-gradient(180deg, #f6f9fd 0%, #edf3fb 100%);
}

.member-card {
  width: min(720px, 100%);
  padding: 40px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(214, 224, 237, 0.72);
  box-shadow: 0 20px 56px rgba(31, 45, 61, 0.12);
}

.member-badge {
  display: inline-flex;
  padding: 8px 14px;
  border-radius: 999px;
  background: #edf4ff;
  color: #2c5ea8;
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.member-card h1 {
  margin: 18px 0 10px;
  font-size: 42px;
  line-height: 1.08;
  color: #1f2a3d;
}

.member-card p {
  margin: 0;
  max-width: 44ch;
  color: #607086;
  line-height: 1.7;
}

.member-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 28px 0 22px;
  color: #6d7b8c;
}

.member-meta strong {
  color: #1f2a3d;
}

@media (max-width: 640px) {
  .member-home {
    padding: 16px;
  }

  .member-card {
    padding: 28px 22px;
    border-radius: 20px;
  }

  .member-card h1 {
    font-size: 30px;
  }

  .member-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
  }
}
</style>
