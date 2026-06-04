package com.education.platform.member.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.member.entity.Member;
import java.util.Optional;

public interface MemberService extends IService<Member> {

    Optional<Member> findByMobile(String mobile);
}
