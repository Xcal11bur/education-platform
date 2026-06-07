import request from '@/utils/request'

export function getSectionContentList(sectionId) {
  return request({
    url: `/admin/sections/${sectionId}/contents`,
    method: 'get'
  })
}

export function getPortalSectionContentList(sectionId) {
  return request({
    url: `/portal/sections/${sectionId}/contents`,
    method: 'get'
  })
}

export function getPortalSectionContentPreview(id) {
  return request({
    url: `/portal/sections/contents/${id}/preview`,
    method: 'get',
    responseType: 'blob',
    timeout: 60 * 1000
  })
}

export function getSectionContentDetail(id) {
  return request({
    url: `/admin/section-contents/${id}`,
    method: 'get'
  })
}

export function createSectionContent(sectionId, data) {
  return request({
    url: `/admin/sections/${sectionId}/contents`,
    method: 'post',
    data
  })
}

export function updateSectionContent(id, data) {
  return request({
    url: `/admin/section-contents/${id}`,
    method: 'put',
    data
  })
}

export function deleteSectionContent(id) {
  return request({
    url: `/admin/section-contents/${id}`,
    method: 'delete'
  })
}
