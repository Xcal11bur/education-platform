import { createRouter, createWebHistory } from 'vue-router'
import NProgress from 'nprogress'
import { useAuthStore } from '@/stores/auth'

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
      path: '/',
      component: () => import('@/layout/AppLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/dashboard/DashboardView.vue'),
          meta: { title: '工作台' }
        },
        {
          path: 'teachers',
          name: 'Teachers',
          component: () => import('@/views/teachers/TeacherListView.vue'),
          meta: { title: '教师管理' }
        },
        {
          path: 'categories',
          name: 'Categories',
          component: () => import('@/views/categories/CategoryListView.vue'),
          meta: { title: '课程分类' }
        },
        {
          path: 'courses',
          name: 'Courses',
          component: () => import('@/views/courses/CourseListView.vue'),
          meta: { title: '课程管理' }
        },
        {
          path: 'courses/:id/chapters',
          name: 'CourseChapters',
          component: () => import('@/views/chapters/CourseChapterView.vue'),
          meta: { title: '章节管理' }
        },
        {
          path: 'courses/:id/materials',
          name: 'CourseMaterials',
          component: () => import('@/views/materials/CourseMaterialView.vue'),
          meta: { title: '课程资料' }
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
      next('/')
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
  next()
})

router.afterEach(() => {
  NProgress.done()
})

export default router
