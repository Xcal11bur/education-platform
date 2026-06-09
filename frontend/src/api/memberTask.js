import request from '@/utils/request'

export function getMemberCourseTaskList(courseId) {
  return request({
    url: `/member/courses/${courseId}/tasks`,
    method: 'get'
  })
}

export function getMemberTaskDetail(taskId) {
  return request({
    url: `/member/course-tasks/${taskId}`,
    method: 'get'
  })
}

export function getMemberTaskSubmissions(taskId) {
  return request({
    url: `/member/course-tasks/${taskId}/my-submissions`,
    method: 'get'
  })
}

export function submitMemberTask(taskId, data) {
  return request({
    url: `/member/course-tasks/${taskId}/submissions`,
    method: 'post',
    data
  })
}
