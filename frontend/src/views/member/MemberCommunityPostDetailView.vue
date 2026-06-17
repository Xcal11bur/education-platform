<template>
  <div class="community-detail-page">
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

    <main class="detail-main">
      <div class="detail-layout">
        <section class="post-panel" v-loading="detailLoading">
          <button class="back-button" type="button" @click="handleBack">
            <el-icon><ArrowLeft /></el-icon>
            <span>返回</span>
          </button>

          <div class="post-head">
            <div class="author-block">
              <el-avatar :size="54" :src="postDetail.authorAvatar">
                {{ (postDetail.authorName || '学').slice(0, 1).toUpperCase() }}
              </el-avatar>
              <div class="author-copy">
                <strong>{{ postDetail.authorName || '学员' }}</strong>
                <span>{{ formatDateTime(postDetail.createdAt) }}</span>
              </div>
            </div>
          </div>

          <h1>{{ postDetail.title || '帖子详情' }}</h1>
          <div class="post-content" v-html="renderRichText(postDetail.content)"></div>

          <div v-if="postDetail.images?.length" class="image-list">
            <img
              v-for="(image, index) in postDetail.images"
              :key="`${postDetail.id}-${index}`"
              :src="image"
              :alt="`${postDetail.title} 配图 ${index + 1}`"
            />
          </div>
        </section>

        <aside class="comment-column">
          <div class="comment-sticky">
            <section ref="commentCardRef" class="comment-card">
              <div class="comment-head">
                <h2>全部评论 {{ postDetail.commentCount || 0 }}</h2>
              </div>

              <div class="comment-body" v-loading="commentLoading">
                <div v-if="commentPage.list.length" class="comment-list">
                  <article
                    v-for="comment in commentPage.list"
                    :key="comment.id"
                    class="comment-item"
                    @click="startReply(comment)"
                  >
                    <div class="comment-row">
                      <el-avatar :size="42" :src="comment.memberAvatar">
                        {{ (comment.memberName || '学').slice(0, 1).toUpperCase() }}
                      </el-avatar>
                      <div class="comment-main">
                        <div class="comment-main-head">
                          <strong>{{ comment.memberName || '学员' }}</strong>
                          <div class="comment-head-actions">
                            <button
                              v-if="currentUserId && currentUserId === comment.memberId"
                              class="delete-button"
                              type="button"
                              @click.stop="handleDeleteComment(comment)"
                            >
                              删除
                            </button>
                            <span>{{ formatDateTime(comment.createdAt) }}</span>
                          </div>
                        </div>
                        <div class="comment-content">{{ comment.content }}</div>

                        <div v-if="comment.children?.length" class="reply-list">
                          <article
                            v-for="reply in comment.children"
                            :key="reply.id"
                            class="reply-item"
                            @click.stop="startReply(reply, comment.id)"
                          >
                            <div class="reply-content">
                              <strong>{{ reply.memberName || '学员' }}：</strong>
                              <span>{{ reply.content }}</span>
                            </div>
                            <div class="reply-time">
                              <button
                                v-if="currentUserId && currentUserId === reply.memberId"
                                class="delete-button"
                                type="button"
                                @click.stop="handleDeleteComment(reply)"
                              >
                                删除
                              </button>
                              <span>{{ formatDateTime(reply.createdAt) }}</span>
                            </div>
                          </article>
                        </div>
                      </div>
                    </div>
                  </article>
                </div>

                <el-empty v-else-if="!commentLoading" description="还没有评论，来发第一条吧" :image-size="80" />

                <div v-if="commentPage.total > 0" class="comment-pagination">
                  <el-pagination
                    v-model:current-page="commentPageNum"
                    v-model:page-size="commentPageSize"
                    :total="commentPage.total"
                    layout="prev, pager, next"
                    background
                    small
                  />
                </div>
              </div>

              <div ref="commentFooterRef" class="comment-footer">
                <div v-if="replyTarget" class="reply-indicator">
                  <span>回复 {{ replyTarget.memberName }}</span>
                </div>

                <div class="footer-action-bar">
                  <div class="comment-entry-wrap" :class="{ 'is-expanded': composerExpanded }">
                    <el-input
                      ref="commentInputRef"
                      v-model="commentContent"
                      class="comment-entry-input"
                      type="textarea"
                      :rows="composerExpanded ? 3 : 1"
                      maxlength="1000"
                      :show-word-limit="composerExpanded"
                      resize="none"
                      placeholder="参与讨论"
                      @focus="focusCommentComposer"
                    />
                  </div>

                  <template v-if="composerExpanded">
                    <el-button @click="collapseComposer">取消</el-button>
                    <el-button type="primary" :loading="commentSubmitting" @click="submitComment">发送</el-button>
                  </template>

                  <template v-else>
                    <button class="action-button" :class="{ 'is-active': postDetail.liked }" type="button" @click="toggleLike">
                      <el-icon><Pointer /></el-icon>
                      <span>{{ postDetail.likeCount || 0 }}</span>
                    </button>

                    <button class="action-button" :class="{ 'is-active': postDetail.favorited }" type="button" @click="toggleFavorite">
                      <el-icon><Star /></el-icon>
                      <span>{{ postDetail.favoriteCount || 0 }}</span>
                    </button>

                    <button class="action-button" type="button" @click="focusCommentComposer">
                      <el-icon><ChatDotRound /></el-icon>
                      <span>{{ postDetail.commentCount || 0 }}</span>
                    </button>
                  </template>
                </div>
              </div>
            </section>
          </div>
        </aside>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ArrowLeft, ChatDotRound, Pointer, Star } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  createCommunityComment,
  deleteCommunityComment,
  favoriteCommunityPost,
  getCommunityCommentList,
  getCommunityPostDetail,
  likeCommunityPost,
  unfavoriteCommunityPost,
  unlikeCommunityPost
} from '@/api/community'
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

const detailLoading = ref(false)
const commentLoading = ref(false)
const commentSubmitting = ref(false)
const composerExpanded = ref(false)
const commentInputRef = ref()
const commentCardRef = ref()
const commentFooterRef = ref()
const commentContent = ref('')
const replyTarget = ref(null)
const commentPageNum = ref(1)
const commentPageSize = ref(10)
const postDetail = ref({
  liked: false,
  favorited: false,
  images: []
})
const commentPage = ref({
  total: 0,
  list: []
})

const displayName = computed(() => authStore.profile?.displayName || authStore.profile?.username || '学员')
const avatarUrl = computed(() => authStore.profile?.avatar || '')
const currentUserId = computed(() => authStore.profile?.userId || null)
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

function handleBack() {
  if (route.query.from === 'profile' && typeof route.query.tab === 'string') {
    router.push({
      path: '/member/profile',
      query: { tab: route.query.tab }
    })
    return
  }
  router.push('/member/community')
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '').slice(0, 16)
}

function renderRichText(value) {
  if (!value) {
    return ''
  }
  if (typeof window === 'undefined') {
    return String(value)
  }
  const parser = new DOMParser()
  const doc = parser.parseFromString(String(value), 'text/html')
  doc.querySelectorAll('script,style,iframe,object,embed').forEach((node) => node.remove())
  doc.body.querySelectorAll('*').forEach((element) => {
    Array.from(element.attributes).forEach((attr) => {
      const attrName = attr.name.toLowerCase()
      const attrValue = attr.value || ''
      if (attrName.startsWith('on')) {
        element.removeAttribute(attr.name)
        return
      }
      if ((attrName === 'href' || attrName === 'src') && /^javascript:/i.test(attrValue)) {
        element.removeAttribute(attr.name)
      }
    })
  })
  return doc.body.innerHTML
}

async function fetchPostDetail() {
  detailLoading.value = true
  try {
    const { data } = await getCommunityPostDetail(route.params.postId)
    postDetail.value = data || { liked: false, favorited: false, images: [] }
  } finally {
    detailLoading.value = false
  }
}

async function fetchComments() {
  commentLoading.value = true
  try {
    const { data } = await getCommunityCommentList(route.params.postId, {
      pageNum: commentPageNum.value,
      pageSize: commentPageSize.value
    })
    commentPage.value = data || { total: 0, list: [] }
  } finally {
    commentLoading.value = false
  }
}

function focusCommentComposer() {
  composerExpanded.value = true
  nextTick(() => {
    commentInputRef.value?.focus?.()
    commentInputRef.value?.textarea?.focus?.()
  })
}

function collapseComposer() {
  composerExpanded.value = false
  commentContent.value = ''
  replyTarget.value = null
}

function startReply(comment, parentId = comment.id) {
  replyTarget.value = {
    parentId,
    memberId: comment.memberId,
    memberName: comment.memberName
  }
  focusCommentComposer()
}

function clearReply() {
  replyTarget.value = null
}

function handleOutsideClick(event) {
  if (!composerExpanded.value) {
    return
  }
  if (commentCardRef.value?.contains(event.target)) {
    return
  }
  collapseComposer()
}

async function submitComment() {
  const content = commentContent.value.trim()
  if (!content) {
    ElMessage.warning('请输入评论内容')
    return
  }
  commentSubmitting.value = true
  try {
    await createCommunityComment(route.params.postId, {
      content,
      parentId: replyTarget.value?.parentId || 0,
      replyToMemberId: replyTarget.value?.memberId || null
    })
    ElMessage.success('评论已发布')
    commentContent.value = ''
    replyTarget.value = null
    composerExpanded.value = false
    commentPageNum.value = 1
    await Promise.all([fetchPostDetail(), fetchComments()])
  } finally {
    commentSubmitting.value = false
  }
}

async function handleDeleteComment(comment) {
  await ElMessageBox.confirm(
    '确认删除这条评论吗？',
    '删除评论',
    {
      type: 'warning',
      confirmButtonText: '确认删除',
      cancelButtonText: '取消'
    }
  )
  await deleteCommunityComment(comment.id)
  ElMessage.success('评论已删除')
  await Promise.all([fetchPostDetail(), fetchComments()])
}

async function toggleLike() {
  const request = postDetail.value.liked ? unlikeCommunityPost : likeCommunityPost
  const { data } = await request(route.params.postId)
  Object.assign(postDetail.value, data || {})
}

async function toggleFavorite() {
  const request = postDetail.value.favorited ? unfavoriteCommunityPost : favoriteCommunityPost
  const { data } = await request(route.params.postId)
  Object.assign(postDetail.value, data || {})
}

onMounted(async () => {
  document.addEventListener('click', handleOutsideClick)
  await Promise.all([authStore.fetchProfile(), fetchPostDetail(), fetchComments()])
  if (route.query.focusComment === '1') {
    focusCommentComposer()
  }
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleOutsideClick)
})

watch(
  () => route.params.postId,
  async () => {
    commentPageNum.value = 1
    commentContent.value = ''
    replyTarget.value = null
    composerExpanded.value = false
    await Promise.all([fetchPostDetail(), fetchComments()])
  }
)

watch([commentPageNum, commentPageSize], () => {
  fetchComments()
})
</script>

<style scoped>
.community-detail-page {
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

.detail-main {
  width: min(1380px, calc(100vw - 48px));
  margin: 0 auto;
  padding: 24px 0 40px;
}

.detail-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 470px;
  gap: 20px;
  align-items: start;
}

.comment-column {
  position: sticky;
  top: 80px;
  align-self: start;
}

.post-panel,
.comment-card {
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(220, 223, 230, 0.92);
  border-radius: 18px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.post-panel {
  padding: 24px 26px 28px;
}

.back-button {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border: 0;
  padding: 10px 14px;
  border-radius: 10px;
  background: #f5f7fa;
  color: #303133;
  cursor: pointer;
}

.post-head {
  margin-top: 22px;
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
  font-size: 18px;
  color: #1f2d3d;
}

.author-copy span {
  font-size: 13px;
  color: #909399;
}

.post-panel h1 {
  margin: 20px 0 18px;
  font-size: clamp(28px, 3.2vw, 36px);
  line-height: 1.28;
  color: #111827;
}

.post-content {
  color: #303133;
  font-size: 16px;
  line-height: 1.8;
  overflow-wrap: anywhere;
  word-break: break-word;
}

.post-content :deep(p) {
  margin: 0 0 12px;
}

.post-content :deep(p:last-child) {
  margin-bottom: 0;
}

.post-content :deep(ul),
.post-content :deep(ol) {
  margin: 0 0 12px;
  padding-left: 22px;
}

.post-content :deep(blockquote) {
  margin: 12px 0;
  padding: 8px 12px;
  border-left: 4px solid #bfdbfe;
  background: #f8fbff;
  color: #475569;
}

.post-content :deep(img) {
  max-width: 100%;
  border-radius: 12px;
}

.image-list {
  margin-top: 22px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.image-list img {
  width: 100%;
  height: 260px;
  object-fit: cover;
  border-radius: 16px;
  background: #f3f4f6;
}

.comment-card {
  height: calc(100vh - 104px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.comment-head {
  padding: 20px 20px 16px;
  border-bottom: 1px solid #eef2f7;
}

.comment-head h2 {
  margin: 0;
  font-size: 28px;
  color: #111827;
}

.comment-body {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: 18px 18px 10px;
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.comment-item {
  padding: 16px;
  border-radius: 16px;
  background: #fff;
  border: 1px solid #eef2f7;
  cursor: pointer;
  transition: border-color 0.2s ease, background-color 0.2s ease;
}

.comment-item:hover {
  border-color: #dbeafe;
  background: #fcfdff;
}

.comment-row {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.comment-main {
  flex: 1;
  min-width: 0;
}

.comment-main-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.comment-main-head strong {
  color: #1f2d3d;
}

.comment-head-actions,
.reply-time {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.comment-main-head span {
  color: #909399;
  font-size: 12px;
}

.comment-content,
.reply-content {
  margin-top: 8px;
  color: #303133;
  line-height: 1.7;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  word-break: break-word;
}

.reply-content strong {
  color: #374151;
}

.reply-content span {
  color: #303133;
}

.reply-list {
  margin-top: 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 12px;
  border-radius: 14px;
  background: #f8fafc;
}

.reply-item {
  padding-bottom: 10px;
  border-bottom: 1px solid #e5eaf3;
  cursor: pointer;
}

.reply-item:last-child {
  padding-bottom: 0;
  border-bottom: 0;
}

.reply-time {
  margin-top: 6px;
  color: #9ca3af;
  font-size: 12px;
}

.delete-button {
  border: 0;
  padding: 0;
  background: transparent;
  color: #ef4444;
  cursor: pointer;
  font-size: 12px;
}

.comment-pagination {
  margin-top: 16px;
  display: flex;
  justify-content: center;
}

.comment-footer {
  padding: 14px 16px 16px;
  border-top: 1px solid #eef2f7;
  background: #fff;
}

.reply-indicator {
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  color: #409eff;
  font-size: 13px;
}

.comment-entry-wrap {
  flex: 1;
  min-width: 0;
}

.comment-entry-wrap :deep(.el-textarea__inner) {
  min-height: 44px !important;
  border-radius: 10px;
  background: #f5f7fa;
  border-color: transparent;
  box-shadow: none;
  padding: 11px 16px;
}

.comment-entry-wrap :deep(.el-textarea__inner:focus) {
  background: #fff;
  border-color: #c7d2fe;
  box-shadow: 0 0 0 1px rgba(59, 130, 246, 0.18);
}

.comment-entry-wrap.is-expanded :deep(.el-textarea__inner) {
  min-height: 92px !important;
  background: #fff;
}

.comment-entry-wrap :deep(.el-input__count) {
  background: transparent;
  color: #9ca3af;
}

.footer-action-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
}

.action-button {
  border: 0;
  background: transparent;
  color: #6b7280;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  padding: 8px 10px;
  border-radius: 10px;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.action-button:hover {
  background: #f3f4f6;
}

.action-button.is-active {
  color: #2563eb;
  background: #eff6ff;
}

@media (max-width: 1100px) {
  .detail-layout {
    grid-template-columns: 1fr;
  }

  .comment-column {
    position: static;
  }

  .comment-card {
    height: auto;
    min-height: 680px;
  }
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

  .detail-main {
    width: min(100vw - 24px, 1380px);
    padding-top: 18px;
  }
}

@media (max-width: 640px) {
  .post-panel {
    padding: 18px 16px 22px;
  }

  .post-panel h1 {
    font-size: 24px;
  }

  .post-content {
    font-size: 15px;
  }

  .image-list {
    grid-template-columns: 1fr;
  }

  .image-list img {
    height: 220px;
  }

  .comment-head h2 {
    font-size: 22px;
  }

  .footer-action-bar {
    flex-wrap: wrap;
  }

  .comment-entry-wrap {
    width: 100%;
    flex-basis: 100%;
  }
}
</style>
