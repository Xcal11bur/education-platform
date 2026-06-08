import request from '@/utils/request'

export function getTeacherChapterTree(courseId) {
  return request({
    url: `/teacher/courses/${courseId}/chapters/tree`,
    method: 'get'
  })
}

export function createTeacherChapter(courseId, data) {
  return request({
    url: `/teacher/courses/${courseId}/chapters`,
    method: 'post',
    data
  })
}

export function updateTeacherChapter(id, data) {
  return request({
    url: `/teacher/chapters/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherChapter(id) {
  return request({
    url: `/teacher/chapters/${id}`,
    method: 'delete'
  })
}

export function createTeacherSection(chapterId, data) {
  return request({
    url: `/teacher/chapters/${chapterId}/sections`,
    method: 'post',
    data
  })
}

export function updateTeacherSection(id, data) {
  return request({
    url: `/teacher/sections/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherSection(id) {
  return request({
    url: `/teacher/sections/${id}`,
    method: 'delete'
  })
}

export function uploadTeacherSectionContentFile(file, contentType = 'FILE') {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('contentType', contentType)
  return request({
    url: '/teacher/uploads/section-contents',
    method: 'post',
    timeout: 10 * 60 * 1000,
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
