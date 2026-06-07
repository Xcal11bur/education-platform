package com.education.platform.member.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.member.dto.MemberMobileUpdateDTO;
import com.education.platform.member.dto.MemberPasswordUpdateDTO;
import com.education.platform.member.dto.MemberProfileUpdateDTO;
import com.education.platform.member.entity.Member;
import com.education.platform.member.vo.MemberProfileVO;
import java.util.Optional;

public interface MemberService extends IService<Member> {

    Optional<Member> findByMobile(String mobile);

    MemberProfileVO getCurrentProfile();

    void updateCurrentProfile(MemberProfileUpdateDTO request);

    void updateCurrentMobile(MemberMobileUpdateDTO request);

    void updateCurrentPassword(MemberPasswordUpdateDTO request);
}
