package com.education.platform.member.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.member.entity.Member;
import com.education.platform.member.mapper.MemberMapper;
import com.education.platform.member.service.MemberService;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class MemberServiceImpl extends ServiceImpl<MemberMapper, Member> implements MemberService {

    @Override
    public Optional<Member> findByMobile(String mobile) {
        return lambdaQuery()
                .eq(Member::getMobile, mobile)
                .oneOpt();
    }
}
