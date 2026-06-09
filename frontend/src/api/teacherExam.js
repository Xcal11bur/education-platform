import request from '@/utils/request'

export function getTeacherExamList(params) {
  return request({
    url: '/teacher/course-exams',
    method: 'get',
    params
  })
}

export function getTeacherExamDetail(id) {
  return request({
    url: `/teacher/course-exams/${id}`,
    method: 'get'
  })
}

export function createTeacherExam(data) {
  return request({
    url: '/teacher/course-exams',
    method: 'post',
    data
  })
}

export function updateTeacherExam(id, data) {
  return request({
    url: `/teacher/course-exams/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherExam(id) {
  return request({
    url: `/teacher/course-exams/${id}`,
    method: 'delete'
  })
}
