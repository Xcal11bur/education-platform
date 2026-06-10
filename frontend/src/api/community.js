import request from '@/utils/request'

export function getCommunityPostList(params) {
  return request({
    url: '/portal/community/posts',
    method: 'get',
    params
  })
}

export function getCommunityPostDetail(postId) {
  return request({
    url: `/portal/community/posts/${postId}`,
    method: 'get'
  })
}

export function getCommunityCommentList(postId, params) {
  return request({
    url: `/portal/community/posts/${postId}/comments`,
    method: 'get',
    params
  })
}

export function createCommunityPost(data) {
  return request({
    url: '/member/community/posts',
    method: 'post',
    data
  })
}

export function createCommunityComment(postId, data) {
  return request({
    url: `/member/community/posts/${postId}/comments`,
    method: 'post',
    data
  })
}

export function likeCommunityPost(postId) {
  return request({
    url: `/member/community/posts/${postId}/like`,
    method: 'post'
  })
}

export function unlikeCommunityPost(postId) {
  return request({
    url: `/member/community/posts/${postId}/like`,
    method: 'delete'
  })
}

export function favoriteCommunityPost(postId) {
  return request({
    url: `/member/community/posts/${postId}/favorite`,
    method: 'post'
  })
}

export function unfavoriteCommunityPost(postId) {
  return request({
    url: `/member/community/posts/${postId}/favorite`,
    method: 'delete'
  })
}
