package com.education.platform.exam.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.TeacherCourseAccessService;
import com.education.platform.exam.dto.CourseExamQueryDTO;
import com.education.platform.exam.dto.CourseExamSaveDTO;
import com.education.platform.exam.entity.CourseExam;
import com.education.platform.exam.entity.ExamQuestion;
import com.education.platform.exam.mapper.CourseExamMapper;
import com.education.platform.exam.mapper.ExamQuestionMapper;
import com.education.platform.exam.mapper.ExamSubmissionMapper;
import com.education.platform.exam.service.CourseExamService;
import com.education.platform.exam.vo.CourseExamVO;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class CourseExamServiceImpl extends ServiceImpl<CourseExamMapper, CourseExam> implements CourseExamService {

    private static final Set<Integer> EXAM_STATUS = Set.of(0, 1);

    private final CourseMapper courseMapper;
    private final ExamQuestionMapper examQuestionMapper;
    private final ExamSubmissionMapper examSubmissionMapper;
    private final TeacherCourseAccessService teacherCourseAccessService;

    public CourseExamServiceImpl(
            CourseMapper courseMapper,
            ExamQuestionMapper examQuestionMapper,
            ExamSubmissionMapper examSubmissionMapper,
            TeacherCourseAccessService teacherCourseAccessService
    ) {
        this.courseMapper = courseMapper;
        this.examQuestionMapper = examQuestionMapper;
        this.examSubmissionMapper = examSubmissionMapper;
        this.teacherCourseAccessService = teacherCourseAccessService;
    }

    @Override
    public PageResponse<CourseExamVO> pageTeacherExams(CourseExamQueryDTO queryDTO) {
        Long teacherId = teacherCourseAccessService.getCurrentTeacherId();
        if (queryDTO.getCourseId() != null) {
            teacherCourseAccessService.getCurrentTeacherCourse(queryDTO.getCourseId());
        }

        List<Long> teacherCourseIds = listTeacherCourseIds(teacherId);
        if (teacherCourseIds.isEmpty()) {
            return PageResponse.empty(queryDTO.getPageNum(), queryDTO.getPageSize());
        }

        IPage<CourseExam> page = lambdaQuery()
                .in(CourseExam::getCourseId, teacherCourseIds)
                .eq(queryDTO.getCourseId() != null, CourseExam::getCourseId, queryDTO.getCourseId())
                .like(StringUtils.hasText(queryDTO.getTitle()), CourseExam::getTitle, queryDTO.getTitle())
                .eq(queryDTO.getStatus() != null, CourseExam::getStatus, queryDTO.getStatus())
                .orderByDesc(CourseExam::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));

        List<CourseExamVO> list = fillExamVOs(page.getRecords());
        return PageResponse.<CourseExamVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseExamVO getTeacherExamDetail(Long id) {
        CourseExam exam = getExamOrThrow(id);
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());
        return fillExamVOs(List.of(exam)).stream()
                .findFirst()
                .orElseThrow(() -> new BusinessException(ResultCode.NOT_FOUND.getCode(), "course exam not found"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createTeacherExam(CourseExamSaveDTO request) {
        teacherCourseAccessService.getCurrentTeacherCourse(request.getCourseId());
        validateExamRequest(null, request);
        CourseExam exam = new CourseExam();
        BeanUtils.copyProperties(request, exam);
        fillDefaultFields(exam);
        save(exam);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherExam(Long id, CourseExamSaveDTO request) {
        CourseExam exam = getExamOrThrow(id);
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());
        teacherCourseAccessService.getCurrentTeacherCourse(request.getCourseId());
        validateExamRequest(id, request);
        BeanUtils.copyProperties(request, exam, "id");
        fillDefaultFields(exam);
        syncExamScoreFromQuestions(exam);
        updateById(exam);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTeacherExam(Long id) {
        CourseExam exam = getExamOrThrow(id);
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());
        examSubmissionMapper.hardDeleteByTaskId(id);
        examQuestionMapper.hardDeleteByTaskId(id);
        baseMapper.hardDeleteById(id);
    }

    private void validateExamRequest(Long examId, CourseExamSaveDTO request) {
        if (request.getStartTime() != null && request.getEndTime() != null
                && request.getEndTime().isBefore(request.getStartTime())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "endTime must be after startTime");
        }
        if (request.getTotalScore() != null && request.getTotalScore() < 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "totalScore must not be less than 0");
        }
        if (request.getPassScore() != null && request.getPassScore() < 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "passScore must not be less than 0");
        }
        if (request.getDurationMinutes() == null || request.getDurationMinutes() <= 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "durationMinutes must be greater than 0");
        }
        if (request.getStatus() != null && !EXAM_STATUS.contains(request.getStatus())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "status must be 0 or 1");
        }
        if (request.getStatus() != null && request.getStatus() == 1) {
            TaskQuestionStats stats = buildQuestionStats(List.of(examId == null ? -1L : examId)).get(examId);
            if (examId == null || stats == null || stats.getQuestionCount() <= 0 || stats.getTotalScore() <= 0) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "please add questions before publishing");
            }
            if (request.getPassScore() != null && request.getPassScore() > stats.getTotalScore()) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "passScore must not exceed total question score");
            }
        }
    }

    private void fillDefaultFields(CourseExam exam) {
        if (exam.getTotalScore() == null) {
            exam.setTotalScore(100);
        }
        if (exam.getPassScore() == null) {
            exam.setPassScore(60);
        }
        exam.setAllowRetakeCount(0);
        if (exam.getStatus() == null) {
            exam.setStatus(0);
        }
    }

    private void syncExamScoreFromQuestions(CourseExam exam) {
        if (exam == null || exam.getId() == null) {
            return;
        }
        TaskQuestionStats stats = buildQuestionStats(List.of(exam.getId())).get(exam.getId());
        if (stats == null) {
            return;
        }
        exam.setTotalScore(stats.getTotalScore());
    }

    private CourseExam getExamOrThrow(Long id) {
        CourseExam exam = getById(id);
        if (exam == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course exam not found");
        }
        return exam;
    }

    private List<Long> listTeacherCourseIds(Long teacherId) {
        return courseMapper.selectList(
                        com.baomidou.mybatisplus.core.toolkit.Wrappers.<Course>lambdaQuery()
                                .eq(Course::getTeacherId, teacherId)
                ).stream()
                .map(Course::getId)
                .filter(Objects::nonNull)
                .toList();
    }

    private List<CourseExamVO> fillExamVOs(List<CourseExam> exams) {
        if (exams.isEmpty()) {
            return List.of();
        }
        Map<Long, TaskQuestionStats> statsMap = buildQuestionStats(exams.stream()
                .map(CourseExam::getId)
                .filter(Objects::nonNull)
                .toList());
        Map<Long, Course> courseMap = listCoursesByIds(exams.stream()
                .map(CourseExam::getCourseId)
                .filter(Objects::nonNull)
                .toList());
        return exams.stream().map(exam -> {
            CourseExamVO vo = new CourseExamVO();
            BeanUtils.copyProperties(exam, vo);
            TaskQuestionStats stats = statsMap.get(exam.getId());
            if (stats != null) {
                vo.setQuestionCount(stats.getQuestionCount());
                vo.setTotalScore(stats.getTotalScore());
            } else {
                vo.setQuestionCount(0);
            }
            Course course = courseMap.get(exam.getCourseId());
            if (course != null) {
                vo.setCourseTitle(course.getTitle());
            }
            return vo;
        }).toList();
    }

    private Map<Long, TaskQuestionStats> buildQuestionStats(Collection<Long> examIds) {
        if (examIds.isEmpty()) {
            return Map.of();
        }
        return examQuestionMapper.selectList(
                        com.baomidou.mybatisplus.core.toolkit.Wrappers.<ExamQuestion>lambdaQuery()
                                .in(ExamQuestion::getTaskId, examIds)
                ).stream()
                .collect(Collectors.groupingBy(
                        ExamQuestion::getTaskId,
                        Collectors.collectingAndThen(Collectors.toList(), this::toTaskQuestionStats)
                ));
    }

    private TaskQuestionStats toTaskQuestionStats(List<ExamQuestion> questions) {
        int totalScore = questions.stream()
                .map(ExamQuestion::getScore)
                .filter(Objects::nonNull)
                .mapToInt(Integer::intValue)
                .sum();
        return new TaskQuestionStats(questions.size(), totalScore);
    }

    private Map<Long, Course> listCoursesByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseMapper.selectList(
                        com.baomidou.mybatisplus.core.toolkit.Wrappers.<Course>lambdaQuery().in(Course::getId, ids)
                ).stream()
                .collect(Collectors.toMap(Course::getId, Function.identity()));
    }

    private static final class TaskQuestionStats {

        private final int questionCount;
        private final int totalScore;

        private TaskQuestionStats(int questionCount, int totalScore) {
            this.questionCount = questionCount;
            this.totalScore = totalScore;
        }

        public int getQuestionCount() {
            return questionCount;
        }

        public int getTotalScore() {
            return totalScore;
        }
    }
}
