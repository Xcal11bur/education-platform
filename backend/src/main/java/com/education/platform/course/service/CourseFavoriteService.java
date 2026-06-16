package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.entity.CourseFavorite;
import java.util.Collection;
import java.util.List;
import java.util.Map;

public interface CourseFavoriteService extends IService<CourseFavorite> {

    boolean favoriteCurrentMemberCourse(Long courseId);

    boolean unfavoriteCurrentMemberCourse(Long courseId);

    boolean isCurrentMemberFavorited(Long courseId);

    Map<Long, CourseFavorite> getCurrentMemberFavoriteMap(Collection<Long> courseIds);

    List<CourseFavorite> listCurrentMemberFavorites();
}
