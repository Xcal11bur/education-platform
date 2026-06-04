import request from '@/utils/request'

export function getMaterialList(params) {
  return request({
    url: '/admin/course-materials',
    method: 'get',
    params
  })
}

export function getMaterialDetail(id) {
  return request({
    url: `/admin/course-materials/${id}`,
    method: 'get'
  })
}

export function createMaterial(data) {
  return request({
    url: '/admin/course-materials',
    method: 'post',
    data
  })
}

export function updateMaterial(id, data) {
  return request({
    url: `/admin/course-materials/${id}`,
    method: 'put',
    data
  })
}

export function deleteMaterial(id) {
  return request({
    url: `/admin/course-materials/${id}`,
    method: 'delete'
  })
}

export function uploadMaterialFile(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/admin/uploads/materials',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
