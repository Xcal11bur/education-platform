<template>
  <div class="community-page">
    <header class="topbar">
      <button class="brand-block" type="button" @click="router.push('/member-home')">
        <img class="brand-logo" :src="brandLogo" alt="教育云平台 logo" />
        <div class="brand-title">教育云平台</div>
      </button>

      <el-menu :default-active="activeNav" mode="horizontal" class="topnav" @select="handleNavSelect">
        <el-menu-item v-for="item in navItems" :key="item.key" :index="item.key">
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

    <main class="community-main">
      <section class="hero-panel">
        <div>
          <div class="hero-kicker">Community</div>
          <h1>交流社区</h1>
        </div>

        <div class="hero-actions">
          <el-input v-model="keyword" class="toolbar-search" placeholder="搜索帖子标题或正文" clearable />
          <el-select v-model="sortMode" class="toolbar-sort">
            <el-option label="最新发布" value="latest" />
            <el-option label="热门优先" value="hot" />
          </el-select>
          <el-button type="primary" @click="openCreateDialog">发布帖子</el-button>
        </div>
      </section>

      <section class="feed-panel" v-loading="loading">
        <div v-if="postPage.list.length" class="post-list">
          <article
            v-for="post in postPage.list"
            :key="post.id"
            class="post-card"
            @click="goPostDetail(post.id)"
          >
            <div class="post-card-layout">
              <div class="post-main-panel">
                <div class="post-head">
                  <div class="author-block">
                    <el-avatar :size="42" :src="post.authorAvatar">
                      {{ (post.authorName || '学').slice(0, 1).toUpperCase() }}
                    </el-avatar>
                    <div class="author-copy">
                      <strong>{{ post.authorName || '学员' }}</strong>
                      <span>{{ formatDateTime(post.createdAt) }}</span>
                    </div>
                  </div>
                </div>

                <h2>{{ post.title }}</h2>
                <p class="post-summary">{{ post.content }}</p>

                <div v-if="post.images?.length" class="post-image-grid" :class="`is-count-${Math.min(post.images.length, 3)}`">
                  <img
                    v-for="(image, index) in post.images.slice(0, 3)"
                    :key="`${post.id}-${index}`"
                    :src="image"
                    :alt="`${post.title} 配图 ${index + 1}`"
                  />
                </div>

                <div class="post-meta">
                  <span class="meta-item">{{ formatDateTime(post.createdAt) }}</span>
                  <span class="meta-item">评论 {{ post.commentCount || 0 }}</span>
                  <span class="meta-item">点赞 {{ post.likeCount || 0 }}</span>
                </div>
              </div>

              <div class="post-comment-panel" @click.stop="goPostDetail(post.id)">
                <div class="comment-preview-head">
                  <strong>评论 {{ post.commentCount || 0 }}</strong>
                </div>

                <div v-if="commentPreviewMap[post.id]?.length" class="comment-preview-list">
                  <article
                    v-for="comment in commentPreviewMap[post.id]"
                    :key="comment.id"
                    class="comment-preview-item"
                  >
                    <div class="comment-preview-author">
                      <el-avatar :size="28" :src="comment.memberAvatar">
                        {{ (comment.memberName || '学').slice(0, 1).toUpperCase() }}
                      </el-avatar>
                      <div class="comment-preview-copy">
                        <strong>{{ comment.memberName || '学员' }}</strong>
                        <p>{{ comment.content }}</p>
                      </div>
                    </div>

                    <div
                      v-if="comment.children?.length"
                      class="comment-preview-reply"
                    >
                      <strong>{{ comment.children[0].memberName || '学员' }}</strong>
                      <span>
                        <template v-if="comment.children[0].replyToMemberName">
                          回复 {{ comment.children[0].replyToMemberName }}：
                        </template>
                        {{ comment.children[0].content }}
                      </span>
                    </div>
                  </article>
                </div>

                <div v-else class="comment-preview-empty">
                  还没有评论，点击参与讨论
                </div>

                <button
                  v-if="post.commentCount > 0"
                  class="comment-preview-link"
                  type="button"
                  @click.stop="goPostDetail(post.id)"
                >
                  查看全部 {{ post.commentCount }} 条评论
                </button>
              </div>
            </div>
          </article>
        </div>

        <div v-if="postPage.total > 0" class="post-pagination">
          <el-pagination
            v-model:current-page="pageNum"
            v-model:page-size="pageSize"
            :total="postPage.total"
            :page-sizes="[5, 10, 15, 20]"
            layout="total, sizes, prev, pager, next"
            background
            @size-change="handlePageSizeChange"
          />
        </div>

        <el-empty v-else-if="!loading" description="还没有帖子，先发一条吧" :image-size="90" />
      </section>
    </main>

    <el-dialog v-model="createDialogVisible" title="发布帖子" width="640px" destroy-on-close>
      <el-form ref="createFormRef" :model="createForm" :rules="createRules" label-width="72px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="createForm.title" maxlength="80" show-word-limit placeholder="输入帖子标题" />
        </el-form-item>
        <el-form-item label="正文" prop="content">
          <el-input
            v-model="createForm.content"
            type="textarea"
            :rows="8"
            maxlength="5000"
            show-word-limit
            placeholder="写点什么，分享你的想法"
          />
        </el-form-item>
        <el-form-item label="图片">
          <el-input
            v-model="imageUrlText"
            type="textarea"
            :rows="4"
            placeholder="可选，每行一个图片 URL"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="createDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitting" @click="submitPost">发布</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { createCommunityPost, getCommunityCommentList, getCommunityPostList } from '@/api/community'
import { useAuthStore } from '@/stores/auth'
import brandLogo from '@/assets/education-cloud-logo.jpg'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const navItems = [
  { key: 'home', label: '首页' },
  { key: 'courses', label: '课程学习' },
  { key: 'tasks', label: '我的任务' },
  { key: 'community', label: '交流社区' }
]

const loading = ref(false)
const submitting = ref(false)
const keyword = ref('')
const sortMode = ref('latest')
const pageNum = ref(1)
const pageSize = ref(10)
const postPage = ref({
  total: 0,
  list: []
})
const commentPreviewMap = ref({})
const createDialogVisible = ref(false)
const createFormRef = ref()
const createForm = ref({
  title: '',
  content: ''
})
const imageUrlText = ref('')

const createRules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入正文', trigger: 'blur' }]
}

const displayName = computed(() => authStore.profile?.displayName || authStore.profile?.username || '学员')
const avatarUrl = computed(() => authStore.profile?.avatar || '')
const activeNav = computed(() => (route.path.startsWith('/member/community') ? 'community' : 'home'))

function handleNavSelect(key) {
  const routeMap = {
    home: '/member-home',
    courses: '/member/courses',
    tasks: '/member/tasks',
    community: '/member/community'
  }
  if (routeMap[key]) {
    router.push(routeMap[key])
  }
}

function goProfile() {
  router.push('/member/profile')
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '').slice(0, 16)
}

function goPostDetail(postId) {
  router.push(`/member/community/${postId}`)
}

function openCreateDialog() {
  createDialogVisible.value = true
}

function handlePageSizeChange() {
  pageNum.value = 1
}

function resolveImageUrls() {
  return imageUrlText.value
    .split(/\r?\n/)
    .map((item) => item.trim())
    .filter(Boolean)
}

async function fetchPosts() {
  loading.value = true
  try {
    const { data } = await getCommunityPostList({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: keyword.value.trim(),
      sortMode: sortMode.value
    })
    postPage.value = data || { total: 0, list: [] }
    await fetchCommentPreviews()
  } finally {
    loading.value = false
  }
}

async function fetchCommentPreviews() {
  const posts = postPage.value.list || []
  if (!posts.length) {
    commentPreviewMap.value = {}
    return
  }

  const entries = await Promise.all(
    posts.map(async (post) => {
      if (!post.commentCount) {
        return [post.id, []]
      }
      const { data } = await getCommunityCommentList(post.id, {
        pageNum: 1,
        pageSize: 2
      })
      return [post.id, data?.list || []]
    })
  )

  commentPreviewMap.value = Object.fromEntries(entries)
}

async function submitPost() {
  await createFormRef.value.validate()
  submitting.value = true
  try {
    await createCommunityPost({
      title: createForm.value.title.trim(),
      content: createForm.value.content.trim(),
      imageUrls: resolveImageUrls()
    })
    ElMessage.success('帖子已发布')
    createDialogVisible.value = false
    createForm.value = { title: '', content: '' }
    imageUrlText.value = ''
    pageNum.value = 1
    await fetchPosts()
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  await Promise.all([authStore.fetchProfile(), fetchPosts()])
})

watch([keyword, sortMode], () => {
  pageNum.value = 1
  fetchPosts()
})

watch([pageNum, pageSize], () => {
  fetchPosts()
})
</script>

<style scoped>
.community-page {
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

.community-main {
  width: min(1320px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 24px 0 40px;
}

.hero-panel,
.feed-panel {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(220, 223, 230, 0.92);
  border-radius: 18px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.hero-panel {
  padding: 16px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.hero-kicker {
  color: #909399;
  font-size: 12px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.hero-panel h1 {
  margin: 8px 0 0;
  font-size: clamp(28px, 3.8vw, 36px);
  color: #1f2d3d;
}

.hero-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toolbar-search {
  width: 320px;
}

.toolbar-sort {
  width: 140px;
}

.feed-panel {
  margin-top: 20px;
  padding: 22px;
}

.post-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.post-card {
  padding: 18px 20px;
  border: 1px solid #e5e7eb;
  border-radius: 18px;
  background: #fff;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.post-card:hover {
  transform: translateY(-2px);
  border-color: #c7ddff;
  box-shadow: 0 12px 26px rgba(31, 45, 61, 0.08);
}

.post-card-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 20px;
  align-items: stretch;
}

.post-main-panel {
  min-width: 0;
}

.post-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.author-block {
  display: flex;
  align-items: center;
  gap: 12px;
}

.author-copy {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.author-copy strong {
  color: #1f2d3d;
  font-size: 15px;
}

.author-copy span {
  color: #909399;
  font-size: 12px;
}

.post-card h2 {
  margin: 14px 0 10px;
  font-size: 22px;
  line-height: 1.3;
  color: #111827;
}

.post-summary {
  margin: 0;
  color: #303133;
  font-size: 15px;
  line-height: 1.72;
  white-space: pre-wrap;
  display: -webkit-box;
  -webkit-line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-image-grid {
  margin-top: 18px;
  display: grid;
  gap: 10px;
}

.post-image-grid.is-count-1 {
  grid-template-columns: 1fr;
}

.post-image-grid.is-count-2,
.post-image-grid.is-count-3 {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.post-image-grid img {
  width: 100%;
  height: 200px;
  object-fit: cover;
  border-radius: 14px;
  background: #f3f4f6;
}

.post-meta {
  margin-top: 16px;
  display: flex;
  align-items: center;
  gap: 20px;
  color: #909399;
  font-size: 13px;
}

.meta-item {
  white-space: nowrap;
}

.post-comment-panel {
  min-width: 0;
  border-left: 1px solid #eef2f7;
  padding-left: 18px;
  display: flex;
  flex-direction: column;
}

.comment-preview-head {
  padding-bottom: 12px;
  border-bottom: 1px solid #eef2f7;
}

.comment-preview-head strong {
  color: #374151;
  font-size: 15px;
}

.comment-preview-list {
  margin-top: 12px;
  display: flex;
  flex-direction: column;
  gap: 14px;
  max-height: 320px;
  overflow-y: auto;
}

.comment-preview-item {
  padding-bottom: 12px;
  border-bottom: 1px solid #f3f4f6;
}

.comment-preview-item:last-child {
  padding-bottom: 0;
  border-bottom: 0;
}

.comment-preview-author {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.comment-preview-copy {
  min-width: 0;
  flex: 1;
}

.comment-preview-copy strong,
.comment-preview-reply strong {
  color: #1f2d3d;
  font-size: 13px;
}

.comment-preview-copy p {
  margin: 6px 0 0;
  color: #4b5563;
  font-size: 13px;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.comment-preview-reply {
  margin-top: 10px;
  margin-left: 38px;
  padding: 10px 12px;
  border-radius: 12px;
  background: #f8fafc;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.comment-preview-reply span {
  color: #6b7280;
  font-size: 12px;
  line-height: 1.55;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.comment-preview-empty {
  margin-top: 14px;
  color: #9ca3af;
  font-size: 13px;
  line-height: 1.6;
}

.comment-preview-link {
  margin-top: auto;
  padding-top: 14px;
  border: 0;
  background: transparent;
  color: #409eff;
  text-align: left;
  cursor: pointer;
}

.post-pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

@media (max-width: 900px) {
  .topbar {
    flex-wrap: wrap;
    height: auto;
    padding: 10px 18px;
  }

  .topnav {
    width: 100%;
  }

  .community-main {
    width: min(100vw - 24px, 1080px);
    padding-top: 18px;
  }

  .hero-panel {
    flex-direction: column;
    align-items: stretch;
  }

  .post-card-layout {
    grid-template-columns: 1fr;
  }

  .post-comment-panel {
    border-left: 0;
    border-top: 1px solid #eef2f7;
    padding-left: 0;
    padding-top: 16px;
  }

  .hero-actions {
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar-search,
  .toolbar-sort {
    width: 100%;
  }

  .post-card h2 {
    font-size: 20px;
  }

  .post-summary {
    font-size: 15px;
  }
}

@media (max-width: 640px) {
  .feed-panel,
  .hero-panel {
    padding: 18px 16px;
  }

  .post-card {
    padding: 16px;
  }

  .post-image-grid.is-count-2,
  .post-image-grid.is-count-3 {
    grid-template-columns: 1fr;
  }

  .post-image-grid img {
    height: 180px;
  }

  .post-meta {
    flex-wrap: wrap;
    gap: 10px 16px;
  }
}
</style>
