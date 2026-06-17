<template>
  <div class="teacher-dashboard">
    <section class="hero-card">
      <div class="hero-copy">
        <span class="hero-kicker">Teacher Console</span>
        <h1>欢迎回来，开始今天的教学管理</h1>

        <div class="hero-actions">
          <el-button type="primary" @click="router.push('/teacher/courses')">查看我的课程</el-button>
          <el-button @click="router.push('/teacher/profile')">进入个人信息</el-button>
        </div>
      </div>

      <div class="hero-panel">
        <div class="hero-stat">
          <span>当前角色</span>
          <strong>{{ authStore.profile?.role || 'TEACHER' }}</strong>
        </div>
        <div class="hero-stat">
          <span>欢迎使用</span>
          <strong>{{ authStore.profile?.displayName || '教师' }}</strong>
        </div>
      </div>
    </section>

    <section class="entry-grid">
      <button
        v-for="item in entries"
        :key="item.path"
        type="button"
        class="entry-card"
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

const entries = [
  {
    path: '/teacher/courses',
    title: '我的课程'
  },
  {
    path: '/teacher/course-management/chapters',
    title: '课程章节'
  },
  {
    path: '/teacher/course-management/tasks',
    title: '作业管理'
  },
  {
    path: '/teacher/course-management/exams',
    title: '考试管理'
  }
]
</script>

<style scoped>
.teacher-dashboard {
  display: grid;
  gap: 22px;
}

.hero-card {
  display: grid;
  grid-template-columns: minmax(0, 1.7fr) minmax(260px, 0.9fr);
  gap: 20px;
  padding: 28px;
  border-radius: 22px;
  background:
    radial-gradient(circle at top right, rgba(255, 255, 255, 0.34), transparent 30%),
    linear-gradient(135deg, #1f4e79 0%, #2d6ea3 100%);
  color: #fff;
  box-shadow: 0 18px 40px rgba(31, 78, 121, 0.16);
}

.hero-kicker {
  display: inline-flex;
  padding: 6px 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  font-size: 12px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.hero-copy h1 {
  margin: 14px 0 12px;
  font-size: 30px;
  line-height: 1.2;
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
}

.hero-panel {
  display: grid;
  gap: 14px;
}

.hero-stat {
  padding: 18px 20px;
  border-radius: 18px;
  background: rgba(12, 28, 44, 0.18);
  border: 1px solid rgba(255, 255, 255, 0.14);
}

.hero-stat span {
  display: block;
  color: rgba(255, 255, 255, 0.72);
  font-size: 13px;
}

.hero-stat strong {
  display: block;
  margin-top: 10px;
  font-size: 24px;
  font-weight: 700;
}

.entry-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.entry-card {
  padding: 22px;
  border: 1px solid #dcdfe6;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.96);
  text-align: left;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.entry-card:hover {
  transform: translateY(-2px);
  border-color: #b8d2e8;
  box-shadow: 0 14px 30px rgba(45, 110, 163, 0.08);
}

.entry-card strong {
  display: block;
  color: #1f2d3d;
  font-size: 18px;
}

@media (max-width: 900px) {
  .hero-card,
  .entry-grid {
    grid-template-columns: 1fr;
  }

  .hero-copy h1 {
    font-size: 26px;
  }
}
</style>
