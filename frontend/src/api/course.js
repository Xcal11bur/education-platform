import request from '@/utils/request'

export function getCourseList(params) {
  return request({
    url: '/admin/courses',
    method: 'get',
    params
  })
}

export function getCourseDetail(id) {
  return request({
    url: `/admin/courses/${id}`,
    method: 'get'
  })
}

export function createCourse(data) {
  return request({
    url: '/admin/courses',
    method: 'post',
    data
  })
}

export function updateCourse(id, data) {
  return request({
    url: `/admin/courses/${id}`,
    method: 'put',
    data
  })
}

export function updateCoursePublishStatus(id, data) {
  return request({
    url: `/admin/courses/${id}/publish-status`,
    method: 'put',
    data
  })
}
