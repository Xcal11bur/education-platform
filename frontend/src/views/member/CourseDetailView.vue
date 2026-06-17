<template>
  <div class="course-detail-page">
    <div class="detail-shell">
      <div class="detail-topbar">
        <div class="breadcrumb-row">
          <button type="button" class="breadcrumb-link" @click="router.push('/member-home')">
            首页
          </button>
          <span class="breadcrumb-separator">></span>
          <button
            v-if="course.categoryLevel1?.id"
            type="button"
            class="breadcrumb-link is-category"
            @click="goCategoryCourses"
          >
            {{ course.categoryLevel1.name }}
          </button>
          <span v-else>{{ course.categoryLevel1?.name || '课程详情' }}</span>
          <span class="breadcrumb-separator">></span>
          <span class="is-current">{{ course.title || '课程详情' }}</span>
        </div>

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
      </div>

      <section class="hero-card" v-loading="loading">
        <div class="cover-panel">
          <img
            v-if="course.coverUrl"
            :src="course.coverUrl"
            :alt="course.title"
            class="course-cover"
          />
          <div v-else class="cover-placeholder">
            <span>{{ course.title || '课程封面' }}</span>
          </div>
        </div>

        <div class="summary-panel">
          <div class="summary-head">
            <div>
              <h1>{{ course.title || '课程详情' }}</h1>
              <p v-if="course.subTitle">{{ course.subTitle }}</p>
            </div>
          </div>

          <div class="meta-card">
            <div class="meta-grid">
              <div class="meta-item">
                <span class="meta-label">课程分类</span>
                <strong>{{ categoryText }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">授课讲师</span>
                <strong>{{ course.teacher?.name || '-' }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">课程难度</span>
                <strong>{{ difficultyText }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">学习人数</span>
                <strong>{{ course.studyCount || 0 }} 人</strong>
              </div>
            </div>

            <div v-if="course.description" class="course-intro">
              {{ course.description }}
            </div>
          </div>

          <div class="action-row">
            <el-button type="primary" size="large" :loading="purchasing" @click="handlePrimaryAction">
              {{ course.enrolled ? '进入学习' : '购买课程' }}
            </el-button>
            <el-button size="large" plain :loading="favoriting" @click="handleFavoriteAction">
              {{ course.favorited ? '取消收藏' : '收藏课程' }}
            </el-button>
          </div>
        </div>
      </section>

      <section class="content-grid">
        <div class="tab-panel">
          <el-tabs v-model="activeTab">
            <el-tab-pane label="课程章节" name="chapters">
              <div v-if="chapters.length" class="chapter-list">
                <article
                  v-for="(chapter, chapterIndex) in chapters"
                  :key="chapter.id"
                  class="chapter-card"
                >
                  <button
                    class="chapter-head"
                    type="button"
                    @click="toggleChapter(chapter.id)"
                  >
                    <div class="chapter-head-main">
                      <el-icon class="chapter-toggle" :class="{ 'is-collapsed': !isChapterExpanded(chapter.id) }">
                        <ArrowDown />
                      </el-icon>
                      <h3>{{ displayChapterTitle(chapter, chapterIndex) }}</h3>
                    </div>
                  </button>

                  <div v-if="isChapterExpanded(chapter.id) && chapter.sections?.length" class="section-list">
                    <div
                      v-for="(section, sectionIndex) in chapter.sections"
                      :key="section.id"
                      class="section-row"
                      :class="{ 'is-disabled': section.isFreeTrial !== 1 }"
                      @click="goPreviewSection(section)"
                    >
                      <div class="section-main">
                        <span class="section-order">{{ chapterIndex + 1 }}.{{ sectionIndex + 1 }}</span>
                        <span class="section-title">{{ displaySectionTitle(section, chapterIndex, sectionIndex) }}</span>
                        <el-tag v-if="section.isFreeTrial === 1" size="small" effect="plain">
                          试看
                        </el-tag>
                        <el-icon v-else class="section-lock"><Lock /></el-icon>
                      </div>
                    </div>
                  </div>

                  <el-empty
                    v-else-if="isChapterExpanded(chapter.id)"
                    description="暂无小节内容"
                    :image-size="60"
                  />
                </article>
              </div>

              <el-empty
                v-else-if="!loading"
                description="暂无课程章节"
                :image-size="80"
              />
            </el-tab-pane>

            <el-tab-pane label="课程评价" name="reviews">
              <div class="review-panel">
                <div class="review-summary-card">
                  <div class="review-score-main">
                    <el-rate
                      :model-value="Number(reviewSummary.avgScore || 0)"
                      disabled
                      allow-half
                      class="summary-score-stars"
                    />
                    <strong>{{ reviewSummary.avgScore?.toFixed?.(1) || '0.0' }}</strong>
                    <span>综合评分</span>
                  </div>
                  <div class="review-summary-meta">
                    <div class="summary-line">共 {{ reviewSummary.reviewCount || 0 }} 条已通过评价</div>
                    <div
                      v-for="score in [5, 4, 3, 2, 1]"
                      :key="score"
                      class="summary-bar-row"
                    >
                      <span>{{ score }} 分</span>
                      <el-progress
                        :percentage="distributionPercent(score)"
                        :show-text="false"
                        :stroke-width="10"
                        color="#409eff"
                      />
                      <strong>{{ reviewSummary.scoreDistribution?.[score] || 0 }}</strong>
                    </div>
                  </div>
                </div>

                <div v-if="reviewSummary.canReview" class="review-form-card">
                  <div class="review-form-head">
                    <h3>发表评价</h3>
                    <span>提交后需管理员审核</span>
                  </div>
                  <el-form ref="reviewFormRef" :model="reviewForm" :rules="reviewRules" label-width="78px">
                    <el-form-item label="评分" prop="score">
                      <el-rate v-model="reviewForm.score" />
                    </el-form-item>
                    <el-form-item label="评价内容">
                      <el-input
                        v-model="reviewForm.content"
                        type="textarea"
                        :rows="4"
                        maxlength="500"
                        show-word-limit
                        placeholder="分享你的学习体验"
                      />
                    </el-form-item>
                    <el-form-item label="匿名评价">
                      <el-switch v-model="reviewAnonymous" />
                    </el-form-item>
                    <el-form-item>
                      <el-button type="primary" :loading="reviewSubmitting" @click="submitReview">
                        提交评价
                      </el-button>
                    </el-form-item>
                  </el-form>
                </div>

                <div v-else-if="course.enrolled && reviewSummary.hasReviewed" class="review-tip-card">
                  <div class="review-tip-row">
                    <span>你已提交过评价，当前状态：{{ myReviewStatusText }}</span>
                    <el-button
                      link
                      type="danger"
                      :loading="reviewDeleting"
                      @click="deleteMyReview"
                    >
                      删除评价
                    </el-button>
                  </div>
                </div>

                <div v-else-if="!course.enrolled" class="review-tip-card">
                  购买课程后可发表评价。
                </div>

                <div class="review-list">
                  <article v-for="item in reviews" :key="item.id" class="review-item">
                    <div class="review-item-head">
                      <div class="review-author">
                        <div class="review-avatar" :class="{ 'is-fallback': !shouldShowReviewAvatarImage(item) }">
                          <img
                            v-if="shouldShowReviewAvatarImage(item)"
                            :src="resolvedReviewAvatar(item)"
                            :alt="`${item.memberDisplayName || '学员'}头像`"
                            @error="handleReviewAvatarError(item.id)"
                          />
                          <span v-else>{{ (item.memberDisplayName || '学').slice(0, 1).toUpperCase() }}</span>
                        </div>
                        <div class="review-author-copy">
                          <strong>{{ item.memberDisplayName || '学员' }}</strong>
                          <span>{{ formatDateTime(item.createdAt) }}</span>
                        </div>
                      </div>
                    </div>
                    <el-rate :model-value="item.score" disabled />
                    <p>{{ item.content || '该学员未填写文字评价。' }}</p>
                  </article>

                  <el-empty v-if="!reviews.length && !reviewLoading" description="暂无课程评价" :image-size="72" />
                </div>
              </div>
            </el-tab-pane>
          </el-tabs>
        </div>

        <aside class="side-panel">
          <div class="side-card">
            <h3>讲师信息</h3>
            <div class="teacher-name">{{ course.teacher?.name || '-' }}</div>
            <div class="teacher-title">{{ course.teacher?.title || '授课讲师' }}</div>
            <p class="teacher-intro">
              {{ course.teacher?.intro || '讲师简介暂未完善。' }}
            </p>
          </div>

          <div class="side-card">
            <h3>课程概览</h3>
            <div class="overview-row">
              <span>章节数</span>
              <strong>{{ chapters.length }}</strong>
            </div>
            <div class="overview-row">
              <span>小节数</span>
              <strong>{{ sectionCount }}</strong>
            </div>
            <div class="overview-row">
              <span>课程价格</span>
              <strong>{{ priceText }}</strong>
            </div>
          </div>
        </aside>
      </section>
    </div>

    <el-dialog v-model="purchaseDialogVisible" title="购买课程" width="420px">
      <div class="purchase-dialog-body">
        <div class="purchase-dialog-row">
          <span>课程价格</span>
          <strong>{{ priceText }}</strong>
        </div>
        <div class="purchase-dialog-row">
          <span>账户余额</span>
          <strong>{{ balanceText }}</strong>
        </div>
        <div v-if="!canAffordCourse" class="purchase-dialog-error">余额不足</div>
      </div>
      <template #footer>
        <el-button @click="purchaseDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!canAffordCourse" :loading="purchasing" @click="confirmPurchase">
          确认购买
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ArrowDown, Lock } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { favoriteCourse, getPortalCourseDetail, purchaseCourse, unfavoriteCourse } from '@/api/course'
import {
  deleteMemberCourseReview,
  getPortalCourseReviews,
  getPortalCourseReviewSummary,
  submitCourseReview
} from '@/api/courseReview'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const purchasing = ref(false)
const favoriting = ref(false)
const purchaseDialogVisible = ref(false)
const activeTab = ref('chapters')
const expandedChapterIds = ref([])
const reviewLoading = ref(false)
const reviewSubmitting = ref(false)
const reviewDeleting = ref(false)
const reviewFormRef = ref()
const reviews = ref([])
const reviewAnonymous = ref(false)
const reviewAvatarErrorMap = ref({})
const reviewSummary = ref({
  avgScore: 0,
  reviewCount: 0,
  scoreDistribution: {},
  canReview: false,
  hasReviewed: false,
  myReviewStatus: null
})
const course = ref({
  teacher: null,
  categoryLevel1: null,
  categoryLevel2: null,
  chapters: [],
  enrolled: false,
  favorited: false,
  lastStudySectionId: null
})
const reviewForm = ref({
  score: 5,
  content: ''
})

const chapters = computed(() => course.value.chapters || [])

const displayName = computed(
  () => authStore.profile?.displayName || authStore.profile?.username || '学员'
)

const avatarUrl = computed(() => authStore.profile?.avatar || '')
const balanceText = computed(() => `¥${Number(authStore.profile?.balance || 0).toFixed(2)}`)
const canAffordCourse = computed(() => Number(authStore.profile?.balance || 0) >= Number(course.value.price || 0))

const categoryText = computed(() =>
  [course.value.categoryLevel1?.name, course.value.categoryLevel2?.name].filter(Boolean).join(' / ') || '-'
)

const difficultyText = computed(() => {
  return {
    1: '初级',
    2: '中级',
    3: '高级'
  }[course.value.difficulty] || '未知'
})

const sectionCount = computed(() =>
  chapters.value.reduce((total, chapter) => total + (chapter.sections?.length || 0), 0)
)

const priceText = computed(() => {
  const price = Number(course.value.price || 0)
  return price > 0 ? `¥ ${price.toFixed(2)}` : '免费'
})

const myReviewStatusText = computed(() => {
  return (
    {
      0: '待审核',
      1: '已通过',
      2: '已拒绝'
    }[reviewSummary.value.myReviewStatus] || '未知'
  )
})

const reviewRules = {
  score: [{ required: true, message: '请选择评分', trigger: 'change' }]
}

function displayChapterTitle(chapter, chapterIndex) {
  const title = String(chapter?.title || '').trim()
  if (!title) {
    return `第${chapterIndex + 1}章`
  }
  return title.replace(/^\s*章节\s*\d+\s*[:：-]?\s*/i, '')
}

function displaySectionTitle(section, chapterIndex, sectionIndex) {
  const title = String(section?.title || '').trim()
  if (!title) {
    return `小节 ${chapterIndex + 1}.${sectionIndex + 1}`
  }

  const orderPatterns = [
    new RegExp(`^${chapterIndex + 1}\\.${sectionIndex + 1}\\s*`),
    new RegExp(`^${chapterIndex + 1}[-_.]${sectionIndex + 1}\\s*`),
    /^\d+\.\d+\s*/,
    /^第\s*\d+\s*节\s*[:：-]?\s*/
  ]

  return orderPatterns.reduce((value, pattern) => value.replace(pattern, '').trim(), title)
}

function expandAllChapters() {
  expandedChapterIds.value = chapters.value.map((chapter) => chapter.id)
}

function isChapterExpanded(chapterId) {
  return expandedChapterIds.value.includes(chapterId)
}

function toggleChapter(chapterId) {
  if (isChapterExpanded(chapterId)) {
    expandedChapterIds.value = expandedChapterIds.value.filter((id) => id !== chapterId)
    return
  }
  expandedChapterIds.value = [...expandedChapterIds.value, chapterId]
}

function goLearnPage(sectionId = null) {
  if (sectionId) {
    router.push(`/member/courses/${route.params.id}/learn/sections/${sectionId}`)
    return
  }
  if (course.value.lastStudySectionId) {
    router.push(`/member/courses/${route.params.id}/learn/sections/${course.value.lastStudySectionId}`)
    return
  }
  router.push(`/member/courses/${route.params.id}/learn`)
}

function goPreviewSection(section) {
  if (section?.isFreeTrial !== 1) {
    return
  }
  goLearnPage(section.id)
}

async function handlePrimaryAction() {
  if (course.value.enrolled) {
    goLearnPage()
    return
  }
  purchaseDialogVisible.value = true
}

async function confirmPurchase() {
  purchasing.value = true
  try {
    const { data } = await purchaseCourse(route.params.id)
    course.value.enrolled = true
    course.value.studyCount = Number(course.value.studyCount || 0) + (data ? 1 : 0)
    purchaseDialogVisible.value = false
    await Promise.all([authStore.fetchProfile(), fetchReviewData()])
    ElMessage.success(data ? '购买成功' : '您已购买该课程')
  } finally {
    purchasing.value = false
  }
}

async function handleFavoriteAction() {
  favoriting.value = true
  try {
    if (course.value.favorited) {
      await unfavoriteCourse(route.params.id)
      course.value.favorited = false
      ElMessage.success('已取消收藏')
    } else {
      await favoriteCourse(route.params.id)
      course.value.favorited = true
      ElMessage.success('课程已收藏')
    }
  } finally {
    favoriting.value = false
  }
}

function goCategoryCourses() {
  router.push({
    path: '/member/courses',
    query: { level1Id: course.value.categoryLevel1.id }
  })
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function goProfile() {
  router.push('/member/profile')
}

function distributionPercent(score) {
  const total = Number(reviewSummary.value.reviewCount || 0)
  if (!total) {
    return 0
  }
  const count = Number(reviewSummary.value.scoreDistribution?.[score] || 0)
  return Math.round((count / total) * 100)
}

function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  return String(value).replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '')
}

function normalizeAssetUrl(value) {
  const url = String(value || '').trim()
  if (!url) {
    return ''
  }
  if (/^(https?:)?\/\//i.test(url) || /^data:/i.test(url) || /^blob:/i.test(url)) {
    return url
  }
  if (url.startsWith('/')) {
    return url
  }
  return `/${url.replace(/^\/+/, '')}`
}

function resolvedReviewAvatar(item) {
  if (item?.id && item?.memberDisplayName !== '匿名用户') {
    return `/api/v1/portal/courses/reviews/${item.id}/avatar`
  }
  return normalizeAssetUrl(
    item?.memberAvatarProxy
      || item?.memberAvatar
      || item?.avatar
      || item?.member?.avatar
      || ''
  )
}

function shouldShowReviewAvatarImage(item) {
  const avatar = resolvedReviewAvatar(item)
  return Boolean(avatar) && !reviewAvatarErrorMap.value[item?.id]
}

function handleReviewAvatarError(reviewId) {
  if (!reviewId || reviewAvatarErrorMap.value[reviewId]) {
    return
  }
  reviewAvatarErrorMap.value = {
    ...reviewAvatarErrorMap.value,
    [reviewId]: true
  }
}

async function fetchReviewData() {
  reviewLoading.value = true
  try {
    const [{ data: summary }, { data: reviewPage }] = await Promise.all([
      getPortalCourseReviewSummary(route.params.id),
      getPortalCourseReviews(route.params.id, { pageNum: 1, pageSize: 10 })
    ])
    reviewSummary.value = summary || {
      avgScore: 0,
      reviewCount: 0,
      scoreDistribution: {}
    }
    reviews.value = reviewPage?.list || []
    reviewAvatarErrorMap.value = {}
  } finally {
    reviewLoading.value = false
  }
}

async function submitReview() {
  await reviewFormRef.value.validate()
  reviewSubmitting.value = true
  try {
    await submitCourseReview({
      courseId: course.value.id,
      score: reviewForm.value.score,
      content: reviewForm.value.content?.trim() || '',
      anonymousFlag: reviewAnonymous.value ? 1 : 0
    })
    ElMessage.success('评价已提交，待审核')
    reviewForm.value = { score: 5, content: '' }
    reviewAnonymous.value = false
    await fetchReviewData()
  } finally {
    reviewSubmitting.value = false
  }
}

async function deleteMyReview() {
  await ElMessageBox.confirm(
    '确认删除你当前课程的这条评价吗？删除后可重新提交。',
    '删除评价',
    {
      type: 'warning',
      confirmButtonText: '确认删除',
      cancelButtonText: '取消'
    }
  )
  reviewDeleting.value = true
  try {
    await deleteMemberCourseReview(course.value.id)
    ElMessage.success('评价已删除')
    await fetchReviewData()
  } finally {
    reviewDeleting.value = false
  }
}

async function fetchCourseDetail() {
  loading.value = true
  try {
    const { data } = await getPortalCourseDetail(route.params.id)
    course.value = data || {
      teacher: null,
      categoryLevel1: null,
      categoryLevel2: null,
      chapters: []
    }
    expandAllChapters()
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await fetchCourseDetail()
  await fetchReviewData()
})
</script>

<style scoped>
.course-detail-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(15, 23, 42, 0.04), transparent 26%),
    linear-gradient(180deg, #f7f8fa 0%, #f2f4f7 100%);
  padding: 28px 0 40px;
}

.detail-shell {
  width: min(1500px, calc(100vw - 48px));
  margin: 0 auto;
}

.detail-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 18px;
}

.breadcrumb-row {
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  color: #606266;
}

.breadcrumb-link {
  border: 0;
  padding: 0;
  background: transparent;
  color: #303133;
  cursor: pointer;
}

.breadcrumb-separator {
  color: #c0c4cc;
}

.breadcrumb-row .is-current {
  color: #409eff;
}

.breadcrumb-link.is-category {
  color: #409eff;
}

.breadcrumb-link.is-category:hover {
  text-decoration: underline;
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

.hero-card,
.tab-panel,
.side-card {
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(220, 223, 230, 0.92);
  border-radius: 18px;
  box-shadow: 0 14px 32px rgba(31, 45, 61, 0.06);
}

.hero-card {
  display: grid;
  grid-template-columns: 640px minmax(0, 1fr);
  gap: 34px;
  padding: 24px;
}

.cover-panel {
  min-width: 0;
}

.course-cover,
.cover-placeholder {
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: 16px;
}

.course-cover {
  object-fit: cover;
  display: block;
  background: #eef2f7;
}

.cover-placeholder {
  display: grid;
  place-items: center;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  color: #1d4ed8;
  font-size: 28px;
  font-weight: 700;
}

.summary-panel {
  display: flex;
  flex-direction: column;
}

.summary-head h1 {
  margin: 0;
  font-size: 28px;
  line-height: 1.35;
  color: #1f2d3d;
}

.summary-head p {
  margin: 12px 0 0;
  color: #606266;
  font-size: 15px;
  line-height: 1.75;
}

.meta-card {
  margin-top: 20px;
  padding: 20px;
  border-radius: 16px;
  background: #f8fafc;
  border: 1px solid #ebeef5;
}

.meta-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-label {
  color: #909399;
  font-size: 13px;
}

.meta-item strong {
  color: #303133;
  font-size: 16px;
}

.course-intro {
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px solid #e5eaf3;
  color: #606266;
  line-height: 1.85;
  white-space: pre-wrap;
}

.action-row {
  margin-top: 28px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.purchase-dialog-body {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.purchase-dialog-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  color: #4b5563;
}

.purchase-dialog-row strong {
  color: #111827;
  font-size: 18px;
}

.purchase-dialog-error {
  color: #ef4444;
  font-size: 13px;
}

.content-grid {
  margin-top: 24px;
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 20px;
  align-items: start;
}

.tab-panel {
  padding: 0 24px 24px;
}

.review-panel {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.review-summary-card,
.review-form-card,
.review-tip-card,
.review-item {
  border: 1px solid #ebeef5;
  border-radius: 16px;
  background: #fff;
}

.review-summary-card {
  display: grid;
  grid-template-columns: 200px minmax(0, 1fr);
  gap: 20px;
  padding: 20px;
}

.review-score-main {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: #f8fafc;
  border-radius: 14px;
  padding: 18px;
}

.summary-score-stars {
  margin-bottom: 12px;
}

.review-score-main strong {
  font-size: 42px;
  color: #1f2d3d;
  line-height: 1;
}

.review-score-main span {
  margin-top: 10px;
  color: #909399;
  font-size: 13px;
}

.review-summary-meta {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.summary-line {
  color: #606266;
  font-size: 14px;
}

.summary-bar-row {
  display: grid;
  grid-template-columns: 40px minmax(0, 1fr) 36px;
  align-items: center;
  gap: 12px;
}

.summary-bar-row span,
.summary-bar-row strong {
  color: #606266;
  font-size: 13px;
}

.review-form-card {
  padding: 20px;
}

.review-form-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.review-form-head h3 {
  margin: 0;
  font-size: 18px;
  color: #1f2d3d;
}

.review-form-head span,
.review-tip-card {
  color: #909399;
  font-size: 13px;
}

.review-tip-card {
  padding: 16px 18px;
}

.review-tip-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.review-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.review-item {
  padding: 18px 20px;
}

.review-item-head {
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
  gap: 12px;
  margin-bottom: 8px;
}

.review-author {
  display: flex;
  align-items: center;
  gap: 12px;
}

.review-avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  overflow: hidden;
  flex: 0 0 42px;
  border: 1px solid #e5e7eb;
  background: #f8fafc;
  display: grid;
  place-items: center;
}

.review-avatar.is-fallback {
  background: #d1d5db;
  color: #fff;
  font-size: 18px;
  font-weight: 700;
}

.review-avatar img {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: cover;
}

.review-author-copy {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.review-author-copy strong {
  color: #1f2d3d;
}

.review-author-copy span {
  color: #909399;
  font-size: 12px;
}

.review-item p {
  margin: 10px 0 0;
  color: #606266;
  line-height: 1.8;
  white-space: pre-wrap;
}

.chapter-list {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.chapter-card {
  border: 1px solid #ebeef5;
  border-radius: 16px;
  overflow: hidden;
  background: #fff;
}

.chapter-head {
  width: 100%;
  padding: 14px 16px;
  border: 0;
  background: #f8fafc;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  cursor: pointer;
}

.chapter-head-main {
  display: flex;
  align-items: center;
  gap: 10px;
}

.chapter-toggle {
  color: #94a3b8;
  font-size: 16px;
  transition: transform 0.2s ease;
}

.chapter-toggle.is-collapsed {
  transform: rotate(-90deg);
}

.chapter-head h3 {
  margin: 0;
  font-size: 17px;
  color: #1f2d3d;
}

.section-list {
  display: flex;
  flex-direction: column;
}

.section-row {
  display: flex;
  align-items: center;
  padding: 10px 14px;
  border-bottom: 1px solid #f1f4f8;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.section-row:last-child {
  border-bottom: 0;
}

.section-row:hover {
  background: #fafcff;
}

.section-row.is-disabled {
  cursor: default;
}

.section-row.is-disabled:hover {
  background: #fff;
}

.section-main {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.section-order {
  color: #909399;
  font-size: 12px;
}

.section-title {
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.section-lock {
  color: #c0c4cc;
  font-size: 14px;
}

.side-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.side-card {
  padding: 22px;
}

.side-card h3 {
  margin: 0 0 18px;
  font-size: 20px;
  color: #1f2d3d;
}

.teacher-name {
  font-size: 18px;
  font-weight: 700;
  color: #303133;
}

.teacher-title {
  margin-top: 8px;
  color: #409eff;
  font-size: 14px;
}

.teacher-intro {
  margin: 14px 0 0;
  color: #606266;
  line-height: 1.85;
}

.overview-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px solid #f1f4f8;
  color: #606266;
}

.overview-row:last-child {
  border-bottom: 0;
}

.overview-row strong {
  color: #303133;
}

@media (max-width: 1200px) {
  .hero-card {
    grid-template-columns: 1fr;
  }

  .content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .detail-shell {
    width: min(100vw - 24px, 1500px);
  }

  .hero-card {
    padding: 16px;
    gap: 20px;
  }

  .summary-head h1 {
    font-size: 24px;
  }

  .meta-grid {
    grid-template-columns: 1fr;
  }

  .review-summary-card {
    grid-template-columns: 1fr;
  }

  .tab-panel {
    padding: 0 16px 16px;
  }

  .section-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .chapter-head {
    padding: 12px 14px;
  }

}
</style>
