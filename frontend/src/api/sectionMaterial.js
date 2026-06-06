import request from '@/utils/request'

export function getSectionMaterialList(sectionId) {
  return request({
    url: `/admin/sections/${sectionId}/materials`,
    method: 'get'
  })
}

export function getPortalSectionMaterialList(sectionId) {
  return request({
    url: `/portal/sections/${sectionId}/materials`,
    method: 'get'
  })
}

export function getSectionMaterialDetail(id) {
  return request({
    url: `/admin/section-materials/${id}`,
    method: 'get'
  })
}

export function createSectionMaterial(sectionId, data) {
  return request({
    url: `/admin/sections/${sectionId}/materials`,
    method: 'post',
    data
  })
}

export function updateSectionMaterial(id, data) {
  return request({
    url: `/admin/section-materials/${id}`,
    method: 'put',
    data
  })
}

export function deleteSectionMaterial(id) {
  return request({
    url: `/admin/section-materials/${id}`,
    method: 'delete'
  })
}
