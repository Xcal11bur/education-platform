package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.course.vo.CourseDetailVO;
import com.education.platform.course.dto.CourseQueryDTO;
import com.education.platform.course.dto.CourseSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.vo.CourseVO;
import java.util.List;

public interface CourseService extends IService<Course> {

    PageResponse<CourseVO> pageAdminCourses(CourseQueryDTO queryDTO);

    CourseDetailVO getAdminCourseDetail(Long id);

    PageResponse<CourseVO> pageTeacherCourses(CourseQueryDTO queryDTO);

    CourseDetailVO getTeacherCourseDetail(Long id);

    void createCourse(CourseSaveDTO request);

    void updateCourse(Long id, CourseSaveDTO request);

    void updatePublishStatus(Long id, Integer publishStatus);

    void deleteCourse(Long id);

    void createTeacherCourse(CourseSaveDTO request);

    void updateTeacherCourse(Long id, CourseSaveDTO request);

    void updateTeacherPublishStatus(Long id, Integer publishStatus);

    void deleteTeacherCourse(Long id);

    PageResponse<CourseVO> pagePortalCourses(CourseQueryDTO queryDTO);

    CourseDetailVO getPortalCourseDetail(Long id);

    List<CourseVO> listCurrentMemberCourses();

    List<CourseVO> listCurrentMemberFavoriteCourses();
}
