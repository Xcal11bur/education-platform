import request from '@/utils/request'

export function getTeacherExamSubmissionList(examId) {
  return request({
    url: `/teacher/course-exams/${examId}/submissions`,
    method: 'get'
  })
}

export function getTeacherExamSubmissionDetail(submissionId) {
  return request({
    url: `/teacher/exam-submissions/${submissionId}`,
    method: 'get'
  })
}

export function reviewTeacherExamSubmission(submissionId, data) {
  return request({
    url: `/teacher/exam-submissions/${submissionId}/review`,
    method: 'put',
    data
  })
}
