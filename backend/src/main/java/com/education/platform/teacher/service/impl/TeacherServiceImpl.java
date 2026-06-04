package com.education.platform.teacher.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.enums.StatusEnum;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.teacher.dto.TeacherQueryDTO;
import com.education.platform.teacher.dto.TeacherSaveDTO;
import com.education.platform.teacher.entity.Teacher;
import com.education.platform.teacher.mapper.TeacherMapper;
import com.education.platform.teacher.service.TeacherService;
import com.education.platform.teacher.vo.TeacherVO;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class TeacherServiceImpl extends ServiceImpl<TeacherMapper, Teacher> implements TeacherService {

    private final PasswordEncoder passwordEncoder;

    public TeacherServiceImpl(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Optional<Teacher> findByLoginName(String loginName) {
        return lambdaQuery()
                .eq(Teacher::getLoginName, loginName)
                .oneOpt();
    }

    @Override
    public PageResponse<TeacherVO> pageTeachers(TeacherQueryDTO queryDTO) {
        IPage<Teacher> page = lambdaQuery()
                .like(StringUtils.hasText(queryDTO.getName()), Teacher::getName, queryDTO.getName())
                .like(StringUtils.hasText(queryDTO.getMobile()), Teacher::getMobile, queryDTO.getMobile())
                .eq(queryDTO.getStatus() != null, Teacher::getStatus, queryDTO.getStatus())
                .orderByDesc(Teacher::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<TeacherVO> list = page.getRecords().stream()
                .map(this::toTeacherVO)
                .toList();
        return PageResponse.<TeacherVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public TeacherVO getTeacherDetail(Long id) {
        return toTeacherVO(getTeacherOrThrow(id));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createTeacher(TeacherSaveDTO request) {
        validateUniqueFields(request, null);
        if (!StringUtils.hasText(request.getPassword())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "password must not be blank");
        }
        Teacher teacher = new Teacher();
        BeanUtils.copyProperties(request, teacher);
        teacher.setPassword(passwordEncoder.encode(request.getPassword()));
        if (teacher.getStatus() == null) {
            teacher.setStatus(StatusEnum.ENABLED.getCode());
        }
        save(teacher);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacher(Long id, TeacherSaveDTO request) {
        Teacher teacher = getTeacherOrThrow(id);
        validateUniqueFields(request, id);
        teacher.setLoginName(request.getLoginName());
        teacher.setName(request.getName());
        teacher.setMobile(request.getMobile());
        teacher.setTitle(request.getTitle());
        teacher.setIntro(request.getIntro());
        teacher.setAvatar(request.getAvatar());
        teacher.setEmail(request.getEmail());
        teacher.setStatus(request.getStatus() == null ? teacher.getStatus() : request.getStatus());
        if (StringUtils.hasText(request.getPassword())) {
            teacher.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        updateById(teacher);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherStatus(Long id, Integer status) {
        Teacher teacher = getTeacherOrThrow(id);
        teacher.setStatus(status);
        updateById(teacher);
    }

    private Teacher getTeacherOrThrow(Long id) {
        Teacher teacher = getById(id);
        if (teacher == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "teacher not found");
        }
        return teacher;
    }

    private void validateUniqueFields(TeacherSaveDTO request, Long excludeId) {
        boolean loginNameExists = lambdaQuery()
                .eq(Teacher::getLoginName, request.getLoginName())
                .ne(excludeId != null, Teacher::getId, excludeId)
                .exists();
        if (loginNameExists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "loginName already exists");
        }

        boolean mobileExists = lambdaQuery()
                .eq(Teacher::getMobile, request.getMobile())
                .ne(excludeId != null, Teacher::getId, excludeId)
                .exists();
        if (mobileExists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "mobile already exists");
        }

        if (StringUtils.hasText(request.getEmail())) {
            boolean emailExists = lambdaQuery()
                    .eq(Teacher::getEmail, request.getEmail())
                    .ne(excludeId != null, Teacher::getId, excludeId)
                    .exists();
            if (emailExists) {
                throw new BusinessException(ResultCode.CONFLICT.getCode(), "email already exists");
            }
        }
    }

    private TeacherVO toTeacherVO(Teacher teacher) {
        TeacherVO teacherVO = new TeacherVO();
        BeanUtils.copyProperties(teacher, teacherVO);
        return teacherVO;
    }
}
