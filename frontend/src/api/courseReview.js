import request from '@/utils/request'

export function submitCourseReview(data) {
  return request({
    url: '/member/course-reviews',
    method: 'post',
    data
  })
}

export function deleteMemberCourseReview(courseId) {
  return request({
    url: `/member/course-reviews/${courseId}`,
    method: 'delete'
  })
}

export function getPortalCourseReviews(courseId, params) {
  return request({
    url: `/portal/courses/${courseId}/reviews`,
    method: 'get',
    params
  })
}

export function getPortalCourseReviewSummary(courseId) {
  return request({
    url: `/portal/courses/${courseId}/review-summary`,
    method: 'get'
  })
}

export function getCourseReviewList(params) {
  return request({
    url: '/admin/course-reviews',
    method: 'get',
    params
  })
}

export function updateCourseReviewStatus(id, data) {
  return request({
    url: `/admin/course-reviews/${id}/status`,
    method: 'put',
    data
  })
}

export function deleteCourseReview(id) {
  return request({
    url: `/admin/course-reviews/${id}`,
    method: 'delete'
  })
}
