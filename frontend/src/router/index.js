import { createRouter, createWebHistory } from 'vue-router'
import NProgress from 'nprogress'
import { useAuthStore } from '@/stores/auth'

function hasRouteAccess(route, role) {
  const roles = route.meta?.roles
  if (!roles || roles.length === 0) {
    return true
  }
  return roles.includes(role)
}

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/login/LoginView.vue'),
      meta: { public: true }
    },
    {
      path: '/member-home',
      name: 'MemberHome',
      component: () => import('@/views/member/MemberHomeView.vue'),
      meta: { title: '教育平台首页', roles: ['MEMBER'] }
    },
    {
      path: '/member/courses',
      name: 'MemberCourseList',
      component: () => import('@/views/member/MemberCourseListView.vue'),
      meta: { title: '课程学习', roles: ['MEMBER'] }
    },
    {
      path: '/member/courses/:id/learn',
      name: 'MemberCourseLearn',
      component: () => import('@/views/member/MemberCourseLearnView.vue'),
      meta: { title: '课程学习', roles: ['MEMBER'] }
    },
    {
      path: '/member/courses/:id/learn/sections/:sectionId',
      name: 'MemberCourseSectionLearn',
      component: () => import('@/views/member/MemberCourseSectionLearnView.vue'),
      meta: { title: '章节详情', roles: ['MEMBER'] }
    },
    {
      path: '/member/courses/:id',
      name: 'MemberCourseDetail',
      component: () => import('@/views/member/CourseDetailView.vue'),
      meta: { title: '课程详情', roles: ['MEMBER'] }
    },
    {
      path: '/member/profile',
      name: 'MemberProfile',
      component: () => import('@/views/member/MemberProfileView.vue'),
      meta: { title: '个人中心', roles: ['MEMBER'] }
    },
    {
      path: '/',
      component: () => import('@/layout/AppLayout.vue'),
      redirect: '/dashboard',
      meta: { roles: ['ADMIN'] },
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/dashboard/DashboardView.vue'),
          meta: { title: '工作台', roles: ['ADMIN'] }
        },
        {
          path: 'teachers',
          name: 'Teachers',
          component: () => import('@/views/teachers/TeacherListView.vue'),
          meta: { title: '教师管理', roles: ['ADMIN'] }
        },
        {
          path: 'banners',
          name: 'CourseBanners',
          component: () => import('@/views/banners/CourseBannerView.vue'),
          meta: { title: '轮播图管理', roles: ['ADMIN'] }
        },
        {
          path: 'categories',
          name: 'Categories',
          component: () => import('@/views/categories/CategoryListView.vue'),
          meta: { title: '课程分类', roles: ['ADMIN'] }
        },
        {
          path: 'courses',
          name: 'Courses',
          component: () => import('@/views/courses/CourseListView.vue'),
          meta: { title: '课程列表', activeMenu: '/courses', roles: ['ADMIN'] }
        },
        {
          path: 'course-management/chapters',
          name: 'CourseChapters',
          component: () => import('@/views/chapters/CourseChapterView.vue'),
          meta: { title: '课程章节', activeMenu: '/course-management/chapters', roles: ['ADMIN'] }
        },
        {
          path: 'course-management/materials',
          name: 'CourseMaterials',
          component: () => import('@/views/materials/CourseMaterialView.vue'),
          meta: { title: '课程资料', activeMenu: '/course-management/materials', roles: ['ADMIN'] }
        },
        {
          path: 'courses/:id/chapters',
          redirect: (to) => ({
            path: '/course-management/chapters',
            query: { courseId: to.params.id }
          }),
          meta: { roles: ['ADMIN'] }
        },
        {
          path: 'courses/:id/materials',
          redirect: (to) => ({
            path: '/course-management/materials',
            query: { courseId: to.params.id }
          }),
          meta: { roles: ['ADMIN'] }
        }
      ]
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  NProgress.start()
  const authStore = useAuthStore()

  if (to.meta.public) {
    if (to.path === '/login' && authStore.token) {
      next(authStore.getDefaultRoute())
      return
    }
    next()
    return
  }

  if (!authStore.token) {
    next('/login')
    return
  }

  if (!authStore.profileLoaded) {
    try {
      await authStore.fetchProfile()
    } catch (error) {
      authStore.logout()
      next('/login')
      return
    }
  }

  if (!hasRouteAccess(to, authStore.role)) {
    next(authStore.getDefaultRoute())
    return
  }

  next()
})

router.afterEach(() => {
  NProgress.done()
})

export default router
