import request from '@/utils/request'

export function getTeacherTaskQuestionList(taskId) {
  return request({
    url: `/teacher/course-tasks/${taskId}/questions`,
    method: 'get'
  })
}

export function createTeacherTaskQuestion(taskId, data) {
  return request({
    url: `/teacher/course-tasks/${taskId}/questions`,
    method: 'post',
    data
  })
}

export function updateTeacherTaskQuestion(id, data) {
  return request({
    url: `/teacher/task-questions/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherTaskQuestion(id) {
  return request({
    url: `/teacher/task-questions/${id}`,
    method: 'delete'
  })
}
