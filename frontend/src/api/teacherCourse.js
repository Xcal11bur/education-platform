import request from '@/utils/request'

export function getTeacherCourseList(params) {
  return request({
    url: '/teacher/courses',
    method: 'get',
    params
  })
}

export function getTeacherCourseDetail(id) {
  return request({
    url: `/teacher/courses/${id}`,
    method: 'get'
  })
}

export function createTeacherCourse(data) {
  return request({
    url: '/teacher/courses',
    method: 'post',
    data
  })
}

export function updateTeacherCourse(id, data) {
  return request({
    url: `/teacher/courses/${id}`,
    method: 'put',
    data
  })
}

export function updateTeacherCoursePublishStatus(id, data) {
  return request({
    url: `/teacher/courses/${id}/publish-status`,
    method: 'put',
    data
  })
}

export function deleteTeacherCourse(id) {
  return request({
    url: `/teacher/courses/${id}`,
    method: 'delete'
  })
}

export function uploadTeacherCourseCoverFile(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/teacher/uploads/course-covers',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
