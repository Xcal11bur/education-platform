package com.education.platform.course.service;

import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseMaterial;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.CourseSectionContent;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseMaterialMapper;
import com.education.platform.course.mapper.CourseSectionContentMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TeacherCourseAccessService {

    private static final String ROLE_TEACHER = "TEACHER";

    private final CourseMapper courseMapper;
    private final CourseChapterMapper courseChapterMapper;
    private final CourseSectionMapper courseSectionMapper;
    private final CourseMaterialMapper courseMaterialMapper;
    private final CourseSectionContentMapper courseSectionContentMapper;

    public Long getCurrentTeacherId() {
        LoginUser loginUser = SecurityUtils.getLoginUser()
                .orElseThrow(() -> new BusinessException(ResultCode.UNAUTHORIZED));
        if (!ROLE_TEACHER.equals(loginUser.getRole()) || loginUser.getUserId() == null) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }
        return loginUser.getUserId();
    }

    public Course getCurrentTeacherCourse(Long courseId) {
        Course course = courseMapper.selectById(courseId);
        if (course == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        assertOwnedByCurrentTeacher(course.getTeacherId());
        return course;
    }

    public CourseChapter getCurrentTeacherChapter(Long chapterId) {
        CourseChapter chapter = courseChapterMapper.selectById(chapterId);
        if (chapter == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "chapter not found");
        }
        getCurrentTeacherCourse(chapter.getCourseId());
        return chapter;
    }

    public CourseSection getCurrentTeacherSection(Long sectionId) {
        CourseSection section = courseSectionMapper.selectById(sectionId);
        if (section == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section not found");
        }
        getCurrentTeacherCourse(section.getCourseId());
        return section;
    }

    public CourseMaterial getCurrentTeacherMaterial(Long materialId) {
        CourseMaterial material = courseMaterialMapper.selectById(materialId);
        if (material == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course material not found");
        }
        getCurrentTeacherCourse(material.getCourseId());
        return material;
    }

    public CourseSectionContent getCurrentTeacherContent(Long contentId) {
        CourseSectionContent content = courseSectionContentMapper.selectById(contentId);
        if (content == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section content not found");
        }
        getCurrentTeacherCourse(content.getCourseId());
        return content;
    }

    private void assertOwnedByCurrentTeacher(Long teacherId) {
        if (!getCurrentTeacherId().equals(teacherId)) {
            throw new BusinessException(ResultCode.NOT_FOUND);
        }
    }
}
