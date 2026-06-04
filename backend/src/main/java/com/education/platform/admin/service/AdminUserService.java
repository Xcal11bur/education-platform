package com.education.platform.admin.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.admin.entity.AdminUser;
import java.util.Optional;

public interface AdminUserService extends IService<AdminUser> {

    Optional<AdminUser> findByUsername(String username);
}
