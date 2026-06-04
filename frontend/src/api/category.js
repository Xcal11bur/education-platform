import request from '@/utils/request'

export function getCategoryTree() {
  return request({
    url: '/admin/course-categories/tree',
    method: 'get'
  })
}

export function getCategoryDetail(id) {
  return request({
    url: `/admin/course-categories/${id}`,
    method: 'get'
  })
}

export function createCategory(data) {
  return request({
    url: '/admin/course-categories',
    method: 'post',
    data
  })
}

export function updateCategory(id, data) {
  return request({
    url: `/admin/course-categories/${id}`,
    method: 'put',
    data
  })
}

export function deleteCategory(id) {
  return request({
    url: `/admin/course-categories/${id}`,
    method: 'delete'
  })
}
