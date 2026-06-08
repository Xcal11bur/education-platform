import request from '@/utils/request'

export function getMemberList(params) {
  return request({
    url: '/admin/members',
    method: 'get',
    params
  })
}

export function createMember(data) {
  return request({
    url: '/admin/members',
    method: 'post',
    data
  })
}

export function getMemberDetail(id) {
  return request({
    url: `/admin/members/${id}`,
    method: 'get'
  })
}

export function updateMember(id, data) {
  return request({
    url: `/admin/members/${id}`,
    method: 'put',
    data
  })
}

export function updateMemberStatus(id, data) {
  return request({
    url: `/admin/members/${id}/status`,
    method: 'put',
    data
  })
}
