package com.education.platform.member.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.member.dto.MemberMobileUpdateDTO;
import com.education.platform.member.dto.MemberPasswordUpdateDTO;
import com.education.platform.member.dto.MemberProfileUpdateDTO;
import com.education.platform.member.dto.MemberQueryDTO;
import com.education.platform.member.dto.MemberSaveDTO;
import com.education.platform.member.entity.Member;
import com.education.platform.member.vo.MemberProfileVO;
import com.education.platform.member.vo.MemberVO;
import java.util.Optional;

public interface MemberService extends IService<Member> {

    Optional<Member> findByMobile(String mobile);

    PageResponse<MemberVO> pageMembers(MemberQueryDTO queryDTO);

    MemberVO getMemberDetail(Long id);

    void createMember(MemberSaveDTO request);

    void updateMember(Long id, MemberSaveDTO request);

    void updateMemberStatus(Long id, Integer status);

    MemberProfileVO getCurrentProfile();

    void updateCurrentProfile(MemberProfileUpdateDTO request);

    void updateCurrentMobile(MemberMobileUpdateDTO request);

    void updateCurrentPassword(MemberPasswordUpdateDTO request);
}
