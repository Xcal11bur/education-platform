import { defineStore } from 'pinia'
import { getProfile, loginAdmin } from '@/api/auth'

const TOKEN_KEY = 'edu_admin_token'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY) || '',
    profile: null,
    profileLoaded: false
  }),
  actions: {
    async login(form) {
      const { data } = await loginAdmin(form)
      this.token = data.token
      localStorage.setItem(TOKEN_KEY, data.token)
      this.profileLoaded = false
      await this.fetchProfile()
      return data
    },
    async fetchProfile() {
      const { data } = await getProfile()
      this.profile = data
      this.profileLoaded = true
      return data
    },
    logout() {
      this.token = ''
      this.profile = null
      this.profileLoaded = false
      localStorage.removeItem(TOKEN_KEY)
    }
  }
})
