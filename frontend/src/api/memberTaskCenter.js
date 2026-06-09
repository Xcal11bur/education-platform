import request from '@/utils/request'

export function getMemberTaskCenterList() {
  return request({
    url: '/member/tasks',
    method: 'get'
  })
}
