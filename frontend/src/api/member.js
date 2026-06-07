import request from '@/utils/request'

export function getMemberProfile() {
  return request({
    url: '/member/profile',
    method: 'get'
  })
}

export function updateMemberProfile(data) {
  return request({
    url: '/member/profile',
    method: 'put',
    data
  })
}

export function updateMemberMobile(data) {
  return request({
    url: '/member/profile/mobile',
    method: 'put',
    data
  })
}

export function updateMemberPassword(data) {
  return request({
    url: '/member/profile/password',
    method: 'put',
    data
  })
}

export function uploadMemberAvatar(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/member/uploads/avatar',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
