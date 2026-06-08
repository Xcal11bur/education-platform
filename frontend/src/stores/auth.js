import { defineStore } from 'pinia'
import { getProfile, loginAdmin, loginMember, loginTeacher } from '@/api/auth'

const TOKEN_KEY = 'edu_platform_token'
const ROLE_KEY = 'edu_platform_role'

function resolveLoginRequest(mode) {
  return {
    admin: loginAdmin,
    teacher: loginTeacher,
    member: loginMember
  }[mode] || loginAdmin
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY) || '',
    role: localStorage.getItem(ROLE_KEY) || '',
    profile: null,
    profileLoaded: false
  }),
  actions: {
    async login(mode, form) {
      const request = resolveLoginRequest(mode)
      const { data } = await request(form)
      this.token = data.token
      this.role = data.role || ''
      localStorage.setItem(TOKEN_KEY, data.token)
      localStorage.setItem(ROLE_KEY, this.role)
      this.profileLoaded = false
      await this.fetchProfile()
      return data
    },
    async fetchProfile() {
      const { data } = await getProfile()
      this.profile = data
      this.role = data.role || this.role
      this.profileLoaded = true
      localStorage.setItem(ROLE_KEY, this.role)
      return data
    },
    getDefaultRoute() {
      if (this.role === 'MEMBER') {
        return '/member-home'
      }
      if (this.role === 'TEACHER') {
        return '/teacher/dashboard'
      }
      return '/dashboard'
    },
    logout() {
      this.token = ''
      this.role = ''
      this.profile = null
      this.profileLoaded = false
      localStorage.removeItem(TOKEN_KEY)
      localStorage.removeItem(ROLE_KEY)
    }
  }
})
