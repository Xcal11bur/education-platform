import request from '@/utils/request'

export function getTeacherMaterialList(params) {
  return request({
    url: '/teacher/course-materials',
    method: 'get',
    params
  })
}

export function getTeacherMaterialDetail(id) {
  return request({
    url: `/teacher/course-materials/${id}`,
    method: 'get'
  })
}

export function createTeacherMaterial(data) {
  return request({
    url: '/teacher/course-materials',
    method: 'post',
    data
  })
}

export function updateTeacherMaterial(id, data) {
  return request({
    url: `/teacher/course-materials/${id}`,
    method: 'put',
    data
  })
}

export function deleteTeacherMaterial(id) {
  return request({
    url: `/teacher/course-materials/${id}`,
    method: 'delete'
  })
}

export function uploadTeacherMaterialFile(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/teacher/uploads/materials',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
