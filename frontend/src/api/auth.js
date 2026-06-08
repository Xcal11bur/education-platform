import request from '@/utils/request'

export function getCaptcha() {
  return request({
    url: '/auth/captcha',
    method: 'get'
  })
}

export function loginAdmin(data) {
  return request({
    url: '/auth/admin/login',
    method: 'post',
    data
  })
}

export function loginTeacher(data) {
  return request({
    url: '/auth/teacher/login',
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

export function registerMember(data) {
  return request({
    url: '/auth/member/register',
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
