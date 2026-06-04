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
