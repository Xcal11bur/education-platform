import request from '@/utils/request'

export function getTeacherProfile() {
  return request({
    url: '/teacher/profile',
    method: 'get'
  })
}

export function updateTeacherProfile(data) {
  return request({
    url: '/teacher/profile',
    method: 'put',
    data
  })
}

export function updateTeacherPassword(data) {
  return request({
    url: '/teacher/profile/password',
    method: 'put',
    data
  })
}

export function uploadTeacherAvatar(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/teacher/uploads/avatar',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
