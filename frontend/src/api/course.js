import request from '@/utils/request'

export function getCourseList(params) {
  return request({
    url: '/admin/courses',
    method: 'get',
    params
  })
}

export function getPortalCourseList(params) {
  return request({
    url: '/portal/courses',
    method: 'get',
    params
  })
}

export function getPortalCourseBanners() {
  return request({
    url: '/portal/courses/banners',
    method: 'get'
  })
}

export function getPortalCourseDetail(id) {
  return request({
    url: `/portal/courses/${id}`,
    method: 'get'
  })
}

export function getPortalCourseMaterials(courseId) {
  return request({
    url: `/portal/courses/${courseId}/materials`,
    method: 'get'
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

export function uploadCourseCoverFile(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/admin/uploads/course-covers',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
