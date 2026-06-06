package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.course.dto.CourseBannerQueryDTO;
import com.education.platform.course.dto.CourseBannerSaveDTO;
import com.education.platform.course.entity.CourseBanner;
import com.education.platform.course.vo.CourseBannerPortalVO;
import com.education.platform.course.vo.CourseBannerVO;
import java.util.List;

public interface CourseBannerService extends IService<CourseBanner> {

    PageResponse<CourseBannerVO> pageBanners(CourseBannerQueryDTO queryDTO);

    CourseBannerVO getBannerDetail(Long id);

    void createBanner(CourseBannerSaveDTO request);

    void updateBanner(Long id, CourseBannerSaveDTO request);

    void updateBannerStatus(Long id, Integer status);

    void deleteBanner(Long id);

    List<CourseBannerPortalVO> listPortalBanners();
}
