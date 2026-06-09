import request from '@/utils/request'

export function getTeacherTaskSubmissionList(taskId) {
  return request({
    url: `/teacher/course-tasks/${taskId}/submissions`,
    method: 'get'
  })
}

export function getTeacherTaskSubmissionDetail(submissionId) {
  return request({
    url: `/teacher/task-submissions/${submissionId}`,
    method: 'get'
  })
}

export function reviewTeacherTaskSubmission(submissionId, data) {
  return request({
    url: `/teacher/task-submissions/${submissionId}/review`,
    method: 'put',
    data
  })
}
