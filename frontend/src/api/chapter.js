import request from '@/utils/request'

export function getChapterTree(courseId) {
  return request({
    url: `/admin/courses/${courseId}/chapters/tree`,
    method: 'get'
  })
}

export function createChapter(courseId, data) {
  return request({
    url: `/admin/courses/${courseId}/chapters`,
    method: 'post',
    data
  })
}

export function updateChapter(id, data) {
  return request({
    url: `/admin/chapters/${id}`,
    method: 'put',
    data
  })
}

export function deleteChapter(id) {
  return request({
    url: `/admin/chapters/${id}`,
    method: 'delete'
  })
}

export function createSection(chapterId, data) {
  return request({
    url: `/admin/chapters/${chapterId}/sections`,
    method: 'post',
    data
  })
}

export function uploadSectionVideoFile(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/admin/uploads/section-videos',
    method: 'post',
    timeout: 10 * 60 * 1000,
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function uploadSectionContentFile(file, contentType = 'FILE') {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('contentType', contentType)
  return request({
    url: '/admin/uploads/section-contents',
    method: 'post',
    timeout: 10 * 60 * 1000,
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function updateSection(id, data) {
  return request({
    url: `/admin/sections/${id}`,
    method: 'put',
    data
  })
}

export function deleteSection(id) {
  return request({
    url: `/admin/sections/${id}`,
    method: 'delete'
  })
}
