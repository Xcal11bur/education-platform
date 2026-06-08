import request from '@/utils/request'

export function getTeacherTaskList(params) {
  return request({
    url: '/teacher/course-tasks',
    method: 'get',
    params
  })
}

export function getTeacherTaskDetail(id) {
  return request({
    url: `/teacher/course-tasks/${id}`,
    method: 'get'
  })
}

export function createTeacherTask(data) {
  return request({
    url: '/teacher/course-tasks',
    method: 'post',
    data
  })
}

export function updateTeacherTask(id, data) {
  return request({
    url: `/teacher/course-tasks/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherTask(id) {
  return request({
    url: `/teacher/course-tasks/${id}`,
    method: 'delete'
  })
}
