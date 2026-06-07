package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.dto.CourseSectionContentSaveDTO;
import com.education.platform.course.entity.CourseSectionContent;
import com.education.platform.course.vo.CourseSectionContentVO;
import java.util.List;

public interface CourseSectionContentService extends IService<CourseSectionContent> {

    List<CourseSectionContentVO> listAdminContents(Long sectionId);

    CourseSectionContentVO getContentDetail(Long id);

    void createContent(Long sectionId, CourseSectionContentSaveDTO request);

    void updateContent(Long id, CourseSectionContentSaveDTO request);

    void deleteContent(Long id);

    List<CourseSectionContentVO> listPortalContents(Long sectionId);

    CourseSectionContent getPortalPreviewContent(Long id);
}
