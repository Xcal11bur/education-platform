import request from '@/utils/request'

export function loginAdmin(data) {
  return request({
    url: '/auth/admin/login',
    method: 'post',
    data
  })
}

export function loginMember(data) {
  return request({
    url: '/auth/member/login',
    method: 'post',
    data
  })
}

export function getProfile() {
  return request({
    url: '/auth/profile',
    method: 'get'
  })
}
