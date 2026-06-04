package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.course.vo.CourseDetailVO;
import com.education.platform.course.dto.CourseQueryDTO;
import com.education.platform.course.dto.CourseSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.vo.CourseVO;

public interface CourseService extends IService<Course> {

    PageResponse<CourseVO> pageAdminCourses(CourseQueryDTO queryDTO);

    CourseDetailVO getAdminCourseDetail(Long id);

    void createCourse(CourseSaveDTO request);

    void updateCourse(Long id, CourseSaveDTO request);

    void updatePublishStatus(Long id, Integer publishStatus);

    PageResponse<CourseVO> pagePortalCourses(CourseQueryDTO queryDTO);

    CourseDetailVO getPortalCourseDetail(Long id);
}
