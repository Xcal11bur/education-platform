import request from '@/utils/request'

export function getMemberCourseExamList(courseId) {
  return request({
    url: `/member/courses/${courseId}/exams`,
    method: 'get'
  })
}

export function getMemberExamDetail(examId, params) {
  return request({
    url: `/member/course-exams/${examId}`,
    method: 'get',
    params
  })
}

export function getMemberExamSubmissions(examId) {
  return request({
    url: `/member/course-exams/${examId}/my-submissions`,
    method: 'get'
  })
}

export function submitMemberExam(examId, data) {
  return request({
    url: `/member/course-exams/${examId}/submissions`,
    method: 'post',
    data
  })
}
