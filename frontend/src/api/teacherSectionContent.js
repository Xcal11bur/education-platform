import request from '@/utils/request'

export function getTeacherSectionContentList(sectionId) {
  return request({
    url: `/teacher/sections/${sectionId}/contents`,
    method: 'get'
  })
}

export function getTeacherSectionContentDetail(id) {
  return request({
    url: `/teacher/section-contents/${id}`,
    method: 'get'
  })
}

export function createTeacherSectionContent(sectionId, data) {
  return request({
    url: `/teacher/sections/${sectionId}/contents`,
    method: 'post',
    data
  })
}

export function updateTeacherSectionContent(id, data) {
  return request({
    url: `/teacher/section-contents/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherSectionContent(id) {
  return request({
    url: `/teacher/section-contents/${id}`,
    method: 'delete'
  })
}
