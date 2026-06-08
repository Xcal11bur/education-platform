<template>
  <div class="teacher-dashboard">
    <section class="hero-card">
      <div class="hero-copy">
        <span class="hero-kicker">Teacher Workspace</span>
        <h1>教师端骨架已经接入，后续课程与作业模块从这里展开。</h1>
        <p>
          当前先把登录、路由、布局和模块入口固定下来。后续会把管理员端现有课程表单、章节表单和资料管理能力逐步收敛到教师名下课程范围。
        </p>
      </div>
      <div class="hero-panel">
        <div class="hero-stat">
          <strong>4</strong>
          <span>已挂载入口</span>
        </div>
        <div class="hero-stat">
          <strong>TEACHER</strong>
          <span>当前角色</span>
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
        <p>{{ item.description }}</p>
      </button>
    </section>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const entries = [
  {
    path: '/teacher/courses',
    title: '我的课程',
    description: '教师课程列表、课程编辑入口和后续课程概览会落在这里。'
  },
  {
    path: '/teacher/course-management/chapters',
    title: '课程章节',
    description: '后续复用管理员章节管理能力，改成教师仅操作本人课程。'
  },
  {
    path: '/teacher/course-management/materials',
    title: '课程资料',
    description: '后续复用资料上传与维护表单，只保留教师课程范围。'
  },
  {
    path: '/teacher/course-management/tasks',
    title: '作业管理',
    description: '后续接入作业创建、题目维护、提交查看和批改。'
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
    radial-gradient(circle at top right, rgba(255, 255, 255, 0.35), transparent 28%),
    linear-gradient(135deg, #1c6b60 0%, #2d8f7f 100%);
  color: #fff;
  box-shadow: 0 18px 40px rgba(28, 107, 96, 0.18);
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

.hero-copy p {
  margin: 0;
  max-width: 720px;
  color: rgba(255, 255, 255, 0.84);
  line-height: 1.7;
}

.hero-panel {
  display: grid;
  gap: 14px;
}

.hero-stat {
  padding: 18px 20px;
  border-radius: 18px;
  background: rgba(13, 40, 36, 0.18);
  border: 1px solid rgba(255, 255, 255, 0.14);
}

.hero-stat strong {
  display: block;
  font-size: 28px;
  font-weight: 800;
}

.hero-stat span {
  display: block;
  margin-top: 8px;
  color: rgba(255, 255, 255, 0.76);
  font-size: 13px;
}

.entry-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.entry-card {
  padding: 22px;
  border: 1px solid #dce8e3;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.96);
  text-align: left;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.entry-card:hover {
  transform: translateY(-2px);
  border-color: #8fd0bf;
  box-shadow: 0 14px 30px rgba(27, 86, 78, 0.08);
}

.entry-card strong {
  display: block;
  color: #183f3a;
  font-size: 18px;
}

.entry-card p {
  margin: 10px 0 0;
  color: #61736e;
  line-height: 1.65;
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
