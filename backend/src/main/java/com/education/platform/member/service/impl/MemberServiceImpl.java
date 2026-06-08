package com.education.platform.member.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.enums.StatusEnum;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.member.dto.MemberMobileUpdateDTO;
import com.education.platform.member.dto.MemberPasswordUpdateDTO;
import com.education.platform.member.dto.MemberProfileUpdateDTO;
import com.education.platform.member.dto.MemberQueryDTO;
import com.education.platform.member.dto.MemberSaveDTO;
import com.education.platform.member.entity.Member;
import com.education.platform.member.mapper.MemberMapper;
import com.education.platform.member.service.MemberService;
import com.education.platform.member.vo.MemberProfileVO;
import com.education.platform.member.vo.MemberVO;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class MemberServiceImpl extends ServiceImpl<MemberMapper, Member> implements MemberService {

    private static final String ROLE_MEMBER = "MEMBER";

    private final PasswordEncoder passwordEncoder;

    public MemberServiceImpl(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Optional<Member> findByMobile(String mobile) {
        return lambdaQuery()
                .eq(Member::getMobile, mobile)
                .oneOpt();
    }

    @Override
    public PageResponse<MemberVO> pageMembers(MemberQueryDTO queryDTO) {
        IPage<Member> page = lambdaQuery()
                .like(StringUtils.hasText(queryDTO.getMobile()), Member::getMobile, queryDTO.getMobile())
                .like(StringUtils.hasText(queryDTO.getNickname()), Member::getNickname, queryDTO.getNickname())
                .eq(queryDTO.getStatus() != null, Member::getStatus, queryDTO.getStatus())
                .orderByDesc(Member::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<MemberVO> list = page.getRecords().stream()
                .map(this::toMemberVO)
                .toList();
        return PageResponse.<MemberVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public MemberVO getMemberDetail(Long id) {
        return toMemberVO(getMemberOrThrow(id));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createMember(MemberSaveDTO request) {
        validateUniqueMobile(request.getMobile(), null);
        if (!StringUtils.hasText(request.getPassword())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "password must not be blank");
        }

        Member member = new Member();
        member.setMobile(request.getMobile());
        member.setPassword(passwordEncoder.encode(request.getPassword()));
        member.setNickname(request.getNickname());
        member.setRealName(request.getRealName());
        member.setAvatar(request.getAvatar());
        member.setGender(request.getGender() == null ? 0 : request.getGender());
        member.setBirthday(request.getBirthday());
        member.setStatus(request.getStatus() == null ? StatusEnum.ENABLED.getCode() : request.getStatus());
        save(member);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMember(Long id, MemberSaveDTO request) {
        Member member = getMemberOrThrow(id);
        validateUniqueMobile(request.getMobile(), id);
        member.setMobile(request.getMobile());
        member.setNickname(request.getNickname());
        member.setRealName(request.getRealName());
        member.setAvatar(request.getAvatar());
        member.setGender(request.getGender() == null ? 0 : request.getGender());
        member.setBirthday(request.getBirthday());
        member.setStatus(request.getStatus() == null ? member.getStatus() : request.getStatus());
        if (StringUtils.hasText(request.getPassword())) {
            member.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        updateById(member);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMemberStatus(Long id, Integer status) {
        Member member = getMemberOrThrow(id);
        member.setStatus(status == null ? StatusEnum.DISABLED.getCode() : status);
        updateById(member);
    }

    @Override
    public MemberProfileVO getCurrentProfile() {
        Member member = getCurrentMember();
        return toProfileVO(member);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCurrentProfile(MemberProfileUpdateDTO request) {
        Member member = getCurrentMember();
        member.setNickname(request.getNickname());
        member.setRealName(request.getRealName());
        member.setAvatar(request.getAvatar());
        member.setGender(request.getGender());
        member.setBirthday(request.getBirthday());
        updateById(member);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCurrentMobile(MemberMobileUpdateDTO request) {
        Member member = getCurrentMember();
        if (request.getMobile().equals(member.getMobile())) {
            return;
        }
        boolean mobileExists = lambdaQuery()
                .eq(Member::getMobile, request.getMobile())
                .ne(Member::getId, member.getId())
                .exists();
        if (mobileExists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "mobile already exists");
        }
        member.setMobile(request.getMobile());
        updateById(member);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCurrentPassword(MemberPasswordUpdateDTO request) {
        Member member = getCurrentMember();
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "password confirmation does not match");
        }
        if (!passwordEncoder.matches(request.getOldPassword(), member.getPassword())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "old password is incorrect");
        }
        member.setPassword(passwordEncoder.encode(request.getNewPassword()));
        updateById(member);
    }

    private Member getMemberOrThrow(Long id) {
        Member member = getById(id);
        if (member == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "member not found");
        }
        return member;
    }

    private void validateUniqueMobile(String mobile, Long excludeId) {
        boolean mobileExists = lambdaQuery()
                .eq(Member::getMobile, mobile)
                .ne(excludeId != null, Member::getId, excludeId)
                .exists();
        if (mobileExists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "mobile already exists");
        }
    }

    private Member getCurrentMember() {
        LoginUser loginUser = SecurityUtils.getLoginUser()
                .orElseThrow(() -> new BusinessException(ResultCode.UNAUTHORIZED));
        if (!ROLE_MEMBER.equals(loginUser.getRole()) || loginUser.getUserId() == null) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }
        Member member = getById(loginUser.getUserId());
        if (member == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "member not found");
        }
        return member;
    }

    private MemberProfileVO toProfileVO(Member member) {
        MemberProfileVO vo = new MemberProfileVO();
        BeanUtils.copyProperties(member, vo);
        if (!StringUtils.hasText(vo.getNickname())) {
            vo.setNickname(member.getMobile());
        }
        return vo;
    }

    private MemberVO toMemberVO(Member member) {
        MemberVO vo = new MemberVO();
        BeanUtils.copyProperties(member, vo);
        if (!StringUtils.hasText(vo.getNickname())) {
            vo.setNickname(member.getMobile());
        }
        return vo;
    }
}
