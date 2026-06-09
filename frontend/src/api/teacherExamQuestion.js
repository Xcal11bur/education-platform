import request from '@/utils/request'

export function getTeacherExamQuestionList(examId) {
  return request({
    url: `/teacher/course-exams/${examId}/questions`,
    method: 'get'
  })
}

export function createTeacherExamQuestion(examId, data) {
  return request({
    url: `/teacher/course-exams/${examId}/questions`,
    method: 'post',
    data
  })
}

export function updateTeacherExamQuestion(id, data) {
  return request({
    url: `/teacher/exam-questions/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherExamQuestion(id) {
  return request({
    url: `/teacher/exam-questions/${id}`,
    method: 'delete'
  })
}
