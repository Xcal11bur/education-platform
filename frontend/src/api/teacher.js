import request from '@/utils/request'

export function getTeacherList(params) {
  return request({
    url: '/admin/teachers',
    method: 'get',
    params
  })
}

export function getTeacherDetail(id) {
  return request({
    url: `/admin/teachers/${id}`,
    method: 'get'
  })
}

export function createTeacher(data) {
  return request({
    url: '/admin/teachers',
    method: 'post',
    data
  })
}

export function updateTeacher(id, data) {
  return request({
    url: `/admin/teachers/${id}`,
    method: 'put',
    data
  })
}

export function updateTeacherStatus(id, data) {
  return request({
    url: `/admin/teachers/${id}/status`,
    method: 'put',
    data
  })
}
