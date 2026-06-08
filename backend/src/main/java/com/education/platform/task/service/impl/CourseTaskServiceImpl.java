package com.education.platform.task.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.TeacherCourseAccessService;
import com.education.platform.task.dto.CourseTaskQueryDTO;
import com.education.platform.task.dto.CourseTaskSaveDTO;
import com.education.platform.task.entity.CourseTask;
import com.education.platform.task.entity.TaskQuestion;
import com.education.platform.task.mapper.CourseTaskMapper;
import com.education.platform.task.mapper.TaskQuestionMapper;
import com.education.platform.task.service.CourseTaskService;
import com.education.platform.task.vo.CourseTaskVO;
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
public class CourseTaskServiceImpl extends ServiceImpl<CourseTaskMapper, CourseTask> implements CourseTaskService {

    private static final Set<Integer> TASK_STATUS = Set.of(0, 1);

    private final CourseMapper courseMapper;
    private final TaskQuestionMapper taskQuestionMapper;
    private final TeacherCourseAccessService teacherCourseAccessService;

    public CourseTaskServiceImpl(
            CourseMapper courseMapper,
            TaskQuestionMapper taskQuestionMapper,
            TeacherCourseAccessService teacherCourseAccessService
    ) {
        this.courseMapper = courseMapper;
        this.taskQuestionMapper = taskQuestionMapper;
        this.teacherCourseAccessService = teacherCourseAccessService;
    }

    @Override
    public PageResponse<CourseTaskVO> pageTeacherTasks(CourseTaskQueryDTO queryDTO) {
        Long teacherId = teacherCourseAccessService.getCurrentTeacherId();
        if (queryDTO.getCourseId() != null) {
            teacherCourseAccessService.getCurrentTeacherCourse(queryDTO.getCourseId());
        }

        List<Long> teacherCourseIds = listTeacherCourseIds(teacherId);
        if (teacherCourseIds.isEmpty()) {
            return PageResponse.empty(queryDTO.getPageNum(), queryDTO.getPageSize());
        }

        IPage<CourseTask> page = lambdaQuery()
                .in(CourseTask::getCourseId, teacherCourseIds)
                .eq(queryDTO.getCourseId() != null, CourseTask::getCourseId, queryDTO.getCourseId())
                .like(StringUtils.hasText(queryDTO.getTitle()), CourseTask::getTitle, queryDTO.getTitle())
                .eq(queryDTO.getStatus() != null, CourseTask::getStatus, queryDTO.getStatus())
                .orderByDesc(CourseTask::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));

        List<CourseTaskVO> list = fillTaskVOs(page.getRecords());
        return PageResponse.<CourseTaskVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseTaskVO getTeacherTaskDetail(Long id) {
        CourseTask task = getTaskOrThrow(id);
        teacherCourseAccessService.getCurrentTeacherCourse(task.getCourseId());
        return fillTaskVOs(List.of(task)).stream()
                .findFirst()
                .orElseThrow(() -> new BusinessException(ResultCode.NOT_FOUND.getCode(), "course task not found"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createTeacherTask(CourseTaskSaveDTO request) {
        teacherCourseAccessService.getCurrentTeacherCourse(request.getCourseId());
        validateTaskRequest(null, request);
        CourseTask task = new CourseTask();
        BeanUtils.copyProperties(request, task);
        fillDefaultFields(task);
        save(task);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherTask(Long id, CourseTaskSaveDTO request) {
        CourseTask task = getTaskOrThrow(id);
        teacherCourseAccessService.getCurrentTeacherCourse(task.getCourseId());
        teacherCourseAccessService.getCurrentTeacherCourse(request.getCourseId());
        validateTaskRequest(id, request);
        BeanUtils.copyProperties(request, task, "id");
        fillDefaultFields(task);
        syncTaskScoreFromQuestions(task);
        updateById(task);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTeacherTask(Long id) {
        CourseTask task = getTaskOrThrow(id);
        teacherCourseAccessService.getCurrentTeacherCourse(task.getCourseId());
        removeById(id);
    }

    private void validateTaskRequest(Long taskId, CourseTaskSaveDTO request) {
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
        if (request.getDurationMinutes() != null && request.getDurationMinutes() <= 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "durationMinutes must be greater than 0");
        }
        if (request.getAllowRetakeCount() != null && request.getAllowRetakeCount() < 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "allowRetakeCount must not be less than 0");
        }
        if (request.getStatus() != null && !TASK_STATUS.contains(request.getStatus())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "status must be 0 or 1");
        }
        if (request.getStatus() != null && request.getStatus() == 1) {
            TaskQuestionStats stats = buildQuestionStats(List.of(taskId == null ? -1L : taskId)).get(taskId);
            if (taskId == null || stats == null || stats.getQuestionCount() <= 0 || stats.getTotalScore() <= 0) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "please add questions before publishing");
            }
            if (request.getPassScore() != null && request.getPassScore() > stats.getTotalScore()) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "passScore must not exceed total question score");
            }
        }
    }

    private void fillDefaultFields(CourseTask task) {
        if (task.getTotalScore() == null) {
            task.setTotalScore(100);
        }
        if (task.getPassScore() == null) {
            task.setPassScore(60);
        }
        if (task.getAllowRetakeCount() == null) {
            task.setAllowRetakeCount(1);
        }
        if (task.getStatus() == null) {
            task.setStatus(0);
        }
    }

    private void syncTaskScoreFromQuestions(CourseTask task) {
        if (task == null || task.getId() == null) {
            return;
        }
        TaskQuestionStats stats = buildQuestionStats(List.of(task.getId())).get(task.getId());
        if (stats == null) {
            return;
        }
        task.setTotalScore(stats.getTotalScore());
    }

    private CourseTask getTaskOrThrow(Long id) {
        CourseTask task = getById(id);
        if (task == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course task not found");
        }
        return task;
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

    private List<CourseTaskVO> fillTaskVOs(List<CourseTask> tasks) {
        if (tasks.isEmpty()) {
            return List.of();
        }
        Map<Long, TaskQuestionStats> statsMap = buildQuestionStats(tasks.stream()
                .map(CourseTask::getId)
                .filter(Objects::nonNull)
                .toList());
        Map<Long, Course> courseMap = listCoursesByIds(tasks.stream()
                .map(CourseTask::getCourseId)
                .filter(Objects::nonNull)
                .toList());
        return tasks.stream().map(task -> {
            CourseTaskVO vo = new CourseTaskVO();
            BeanUtils.copyProperties(task, vo);
            TaskQuestionStats stats = statsMap.get(task.getId());
            if (stats != null) {
                vo.setQuestionCount(stats.getQuestionCount());
                vo.setTotalScore(stats.getTotalScore());
            } else {
                vo.setQuestionCount(0);
            }
            Course course = courseMap.get(task.getCourseId());
            if (course != null) {
                vo.setCourseTitle(course.getTitle());
            }
            return vo;
        }).toList();
    }

    private Map<Long, TaskQuestionStats> buildQuestionStats(Collection<Long> taskIds) {
        if (taskIds.isEmpty()) {
            return Map.of();
        }
        return taskQuestionMapper.selectList(
                        com.baomidou.mybatisplus.core.toolkit.Wrappers.<TaskQuestion>lambdaQuery()
                                .in(TaskQuestion::getTaskId, taskIds)
                ).stream()
                .collect(Collectors.groupingBy(
                        TaskQuestion::getTaskId,
                        Collectors.collectingAndThen(Collectors.toList(), this::toTaskQuestionStats)
                ));
    }

    private TaskQuestionStats toTaskQuestionStats(List<TaskQuestion> questions) {
        int totalScore = questions.stream()
                .map(TaskQuestion::getScore)
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
