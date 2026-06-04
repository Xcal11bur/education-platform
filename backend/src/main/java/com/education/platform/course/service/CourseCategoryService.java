package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.dto.CourseCategorySaveDTO;
import com.education.platform.course.entity.CourseCategory;
import com.education.platform.course.vo.CourseCategoryVO;
import java.util.List;

public interface CourseCategoryService extends IService<CourseCategory> {

    List<CourseCategoryVO> getCategoryTree(Boolean onlyEnabled);

    CourseCategoryVO getCategoryDetail(Long id);

    void createCategory(CourseCategorySaveDTO request);

    void updateCategory(Long id, CourseCategorySaveDTO request);

    void deleteCategory(Long id);
}
