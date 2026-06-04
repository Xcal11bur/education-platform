package com.education.platform.admin.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.admin.entity.AdminUser;
import com.education.platform.admin.mapper.AdminUserMapper;
import com.education.platform.admin.service.AdminUserService;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class AdminUserServiceImpl extends ServiceImpl<AdminUserMapper, AdminUser> implements AdminUserService {

    @Override
    public Optional<AdminUser> findByUsername(String username) {
        return lambdaQuery()
                .eq(AdminUser::getUsername, username)
                .oneOpt();
    }
}
