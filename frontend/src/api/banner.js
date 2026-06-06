import request from '@/utils/request'

export function getCourseBannerList(params) {
  return request({
    url: '/admin/course-banners',
    method: 'get',
    params
  })
}

export function getCourseBannerDetail(id) {
  return request({
    url: `/admin/course-banners/${id}`,
    method: 'get'
  })
}

export function createCourseBanner(data) {
  return request({
    url: '/admin/course-banners',
    method: 'post',
    data
  })
}

export function updateCourseBanner(id, data) {
  return request({
    url: `/admin/course-banners/${id}`,
    method: 'put',
    data
  })
}

export function updateCourseBannerStatus(id, data) {
  return request({
    url: `/admin/course-banners/${id}/status`,
    method: 'put',
    data
  })
}

export function deleteCourseBanner(id) {
  return request({
    url: `/admin/course-banners/${id}`,
    method: 'delete'
  })
}
