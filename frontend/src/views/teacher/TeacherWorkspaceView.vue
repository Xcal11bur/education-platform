<template>
  <div class="workspace-page">
    <section class="workspace-card">
      <div class="workspace-badge">{{ title }}</div>
      <h1>{{ title }}</h1>
      <p>{{ description }}</p>
    </section>

    <section class="next-card">
      <h2>后续接入方式</h2>
      <ul>
        <li>保留当前教师端菜单和路由，不再改登录流。</li>
        <li>优先复用管理员端已有表单与列表能力，补教师课程范围限制。</li>
        <li>新接口命名建议统一走 `/teacher/...`，避免和 `/admin/...` 混用。</li>
      </ul>
    </section>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const title = computed(() => route.meta?.title || '教师工作区')
const description = computed(
  () => route.meta?.description || '该模块入口已建立，后续会替换成真实业务页面。'
)
</script>

<style scoped>
.workspace-page {
  display: grid;
  gap: 18px;
}

.workspace-card,
.next-card {
  padding: 26px 28px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid #dce8e3;
  box-shadow: 0 14px 32px rgba(17, 52, 48, 0.05);
}

.workspace-badge {
  display: inline-flex;
  padding: 7px 12px;
  border-radius: 999px;
  background: #e8f5f1;
  color: #1c6b60;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.workspace-card h1,
.next-card h2 {
  margin: 16px 0 12px;
  color: #183f3a;
}

.workspace-card p,
.next-card li {
  color: #647772;
  line-height: 1.75;
}

.next-card ul {
  margin: 0;
  padding-left: 18px;
}
</style>
