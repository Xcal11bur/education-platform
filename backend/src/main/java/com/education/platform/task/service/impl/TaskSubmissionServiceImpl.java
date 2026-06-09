package com.education.platform.task.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import com.education.platform.task.entity.CourseTask;
import com.education.platform.task.entity.TaskQuestion;
import com.education.platform.task.entity.TaskSubmission;
import com.education.platform.task.mapper.CourseTaskMapper;
import com.education.platform.task.mapper.TaskQuestionMapper;
import com.education.platform.task.mapper.TaskSubmissionMapper;
import com.education.platform.task.service.TaskSubmissionService;
import com.education.platform.task.vo.CourseTaskMemberDetailVO;
import com.education.platform.task.vo.CourseTaskMemberListVO;
import com.education.platform.task.vo.TaskQuestionMemberVO;
import com.education.platform.task.vo.TaskSubmissionVO;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class TaskSubmissionServiceImpl extends ServiceImpl<TaskSubmissionMapper, TaskSubmission>
        implements TaskSubmissionService {

    private static final String ROLE_MEMBER = "MEMBER";
    private static final int TASK_STATUS_PUBLISHED = 1;
    private static final int REVIEWED_STATUS = 1;
    private static final Set<Integer> SUPPORTED_QUESTION_TYPES = Set.of(1, 3);

    private final ObjectMapper objectMapper;
    private final CourseMapper courseMapper;
    private final CourseTaskMapper courseTaskMapper;
    private final TaskQuestionMapper taskQuestionMapper;
    private final CourseEnrollmentService courseEnrollmentService;

    @Override
    public List<CourseTaskMemberListVO> listCurrentMemberCourseTasks(Long courseId) {
        Long memberId = getCurrentMemberId();
        ensureCourseEnrolled(courseId);

        List<CourseTask> tasks = courseTaskMapper.selectList(
                Wrappers.<CourseTask>lambdaQuery()
                        .eq(CourseTask::getCourseId, courseId)
                        .eq(CourseTask::getStatus, TASK_STATUS_PUBLISHED)
                        .orderByAsc(CourseTask::getEndTime)
                        .orderByDesc(CourseTask::getId)
        );
        if (tasks.isEmpty()) {
            return List.of();
        }

        Map<Long, Integer> questionCountMap = buildQuestionCountMap(tasks.stream().map(CourseTask::getId).toList());
        Map<Long, TaskSubmission> latestSubmissionMap = listLatestSubmissionMap(memberId, tasks.stream().map(CourseTask::getId).toList());
        Map<Long, Integer> usedAttemptsMap = buildUsedAttemptsMap(memberId, tasks.stream().map(CourseTask::getId).toList());
        String courseTitle = getCourseTitle(courseId);

        return tasks.stream().map(task -> {
            CourseTaskMemberListVO vo = new CourseTaskMemberListVO();
            BeanUtils.copyProperties(task, vo);
            vo.setQuestionCount(questionCountMap.getOrDefault(task.getId(), 0));
            vo.setCourseTitle(courseTitle);

            TaskSubmission latestSubmission = latestSubmissionMap.get(task.getId());
            vo.setCompleted(latestSubmission != null);
            vo.setLatestScore(latestSubmission == null ? null : latestSubmission.getScore());
            vo.setLatestSubmittedAt(latestSubmission == null ? null : latestSubmission.getSubmittedAt());

            int usedAttempts = usedAttemptsMap.getOrDefault(task.getId(), 0);
            int remainingAttempts = getRemainingAttempts(task, usedAttempts);
            vo.setUsedAttempts(usedAttempts);
            vo.setRemainingAttempts(remainingAttempts);
            vo.setCanSubmit(canSubmitTask(task, usedAttempts, vo.getQuestionCount()));
            return vo;
        }).toList();
    }

    @Override
    public CourseTaskMemberDetailVO getCurrentMemberTaskDetail(Long taskId) {
        Long memberId = getCurrentMemberId();
        CourseTask task = getPublishedTaskOrThrow(taskId);
        ensureCourseEnrolled(task.getCourseId());

        List<TaskQuestion> questions = listTaskQuestions(taskId);
        TaskSubmission latestSubmission = getLatestSubmission(memberId, taskId);
        int usedAttempts = countAttempts(memberId, taskId);

        CourseTaskMemberDetailVO vo = new CourseTaskMemberDetailVO();
        BeanUtils.copyProperties(task, vo);
        vo.setCourseTitle(getCourseTitle(task.getCourseId()));
        vo.setQuestionCount(questions.size());
        vo.setSubmitted(latestSubmission != null);
        vo.setUsedAttempts(usedAttempts);
        vo.setRemainingAttempts(getRemainingAttempts(task, usedAttempts));
        vo.setCanSubmit(canSubmitTask(task, usedAttempts, questions.size()));
        vo.setLatestSubmission(toSubmissionVO(latestSubmission));
        vo.setQuestions(buildMemberQuestionVOs(questions, latestSubmission));
        return vo;
    }

    @Override
    public List<TaskSubmissionVO> listCurrentMemberTaskSubmissions(Long taskId) {
        Long memberId = getCurrentMemberId();
        CourseTask task = getPublishedTaskOrThrow(taskId);
        ensureCourseEnrolled(task.getCourseId());
        return lambdaQuery()
                .eq(TaskSubmission::getTaskId, taskId)
                .eq(TaskSubmission::getMemberId, memberId)
                .orderByDesc(TaskSubmission::getAttemptNo)
                .orderByDesc(TaskSubmission::getId)
                .list()
                .stream()
                .map(this::toSubmissionVO)
                .toList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitCurrentMemberTask(Long taskId, TaskSubmissionSaveDTO request) {
        Long memberId = getCurrentMemberId();
        CourseTask task = getPublishedTaskOrThrow(taskId);
        ensureCourseEnrolled(task.getCourseId());

        List<TaskQuestion> questions = listTaskQuestions(taskId);
        if (questions.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "task questions not found");
        }

        int usedAttempts = countAttempts(memberId, taskId);
        if (!canSubmitTask(task, usedAttempts, questions.size())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "task can not be submitted now");
        }

        Map<Long, List<String>> answerMap = parseSubmissionAnswers(request.getAnswersJson());
        int objectiveScore = calculateObjectiveScore(questions, answerMap);
        LocalDateTime now = LocalDateTime.now();

        TaskSubmission submission = new TaskSubmission();
        submission.setTaskId(taskId);
        submission.setMemberId(memberId);
        submission.setAttemptNo(usedAttempts + 1);
        submission.setAnswersJson(buildStoredAnswersJson(answerMap));
        submission.setAttachmentUrl(normalizeText(request.getAttachmentUrl()));
        submission.setObjectiveScore(objectiveScore);
        submission.setSubjectiveScore(0);
        submission.setScore(objectiveScore);
        submission.setReviewStatus(REVIEWED_STATUS);
        submission.setSubmittedAt(now);
        submission.setReviewedAt(now);
        save(submission);
    }

    private List<TaskQuestion> listTaskQuestions(Long taskId) {
        return taskQuestionMapper.selectList(
                Wrappers.<TaskQuestion>lambdaQuery()
                        .eq(TaskQuestion::getTaskId, taskId)
                        .orderByAsc(TaskQuestion::getSort)
                        .orderByAsc(TaskQuestion::getId)
        );
    }

    private List<TaskQuestionMemberVO> buildMemberQuestionVOs(List<TaskQuestion> questions, TaskSubmission latestSubmission) {
        Map<Long, List<String>> submissionAnswerMap = latestSubmission == null
                ? Map.of()
                : parseStoredAnswers(latestSubmission.getAnswersJson());

        return questions.stream().map(question -> {
            TaskQuestionMemberVO vo = new TaskQuestionMemberVO();
            vo.setId(question.getId());
            vo.setQuestionType(question.getQuestionType());
            vo.setStem(question.getStem());
            vo.setOptionsJson(question.getOptionsJson());
            vo.setScore(question.getScore());
            vo.setSort(question.getSort());
            if (latestSubmission != null) {
                List<String> myAnswer = submissionAnswerMap.getOrDefault(question.getId(), List.of());
                vo.setMyAnswerJson(writeJsonSilently(myAnswer));
                vo.setEarnedScore(isCorrectAnswer(question, myAnswer) ? question.getScore() : 0);
                vo.setAnalysis(question.getAnalysis());
            }
            return vo;
        }).toList();
    }

    private int calculateObjectiveScore(List<TaskQuestion> questions, Map<Long, List<String>> answerMap) {
        int score = 0;
        for (TaskQuestion question : questions) {
            if (!SUPPORTED_QUESTION_TYPES.contains(question.getQuestionType())) {
                continue;
            }
            List<String> answers = answerMap.getOrDefault(question.getId(), List.of());
            if (isCorrectAnswer(question, answers)) {
                score += question.getScore() == null ? 0 : question.getScore();
            }
        }
        return score;
    }

    private boolean isCorrectAnswer(TaskQuestion question, List<String> answers) {
        List<String> standardAnswers = parseStringList(question.getAnswerJson());
        return Objects.equals(normalizeAnswerValues(answers), normalizeAnswerValues(standardAnswers));
    }

    private Map<Long, Integer> buildQuestionCountMap(Collection<Long> taskIds) {
        if (taskIds == null || taskIds.isEmpty()) {
            return Map.of();
        }
        return taskQuestionMapper.selectList(
                Wrappers.<TaskQuestion>lambdaQuery().in(TaskQuestion::getTaskId, taskIds)
        ).stream().collect(Collectors.groupingBy(
                TaskQuestion::getTaskId,
                Collectors.collectingAndThen(Collectors.counting(), Math::toIntExact)
        ));
    }

    private Map<Long, TaskSubmission> listLatestSubmissionMap(Long memberId, Collection<Long> taskIds) {
        if (taskIds == null || taskIds.isEmpty()) {
            return Map.of();
        }
        return lambdaQuery()
                .eq(TaskSubmission::getMemberId, memberId)
                .in(TaskSubmission::getTaskId, taskIds)
                .orderByDesc(TaskSubmission::getAttemptNo)
                .orderByDesc(TaskSubmission::getId)
                .list()
                .stream()
                .collect(Collectors.toMap(
                        TaskSubmission::getTaskId,
                        Function.identity(),
                        (left, right) -> left
                ));
    }

    private Map<Long, Integer> buildUsedAttemptsMap(Long memberId, Collection<Long> taskIds) {
        if (taskIds == null || taskIds.isEmpty()) {
            return Map.of();
        }
        return lambdaQuery()
                .eq(TaskSubmission::getMemberId, memberId)
                .in(TaskSubmission::getTaskId, taskIds)
                .list()
                .stream()
                .collect(Collectors.groupingBy(
                        TaskSubmission::getTaskId,
                        Collectors.collectingAndThen(Collectors.counting(), Math::toIntExact)
                ));
    }

    private TaskSubmission getLatestSubmission(Long memberId, Long taskId) {
        return lambdaQuery()
                .eq(TaskSubmission::getMemberId, memberId)
                .eq(TaskSubmission::getTaskId, taskId)
                .orderByDesc(TaskSubmission::getAttemptNo)
                .orderByDesc(TaskSubmission::getId)
                .last("LIMIT 1")
                .one();
    }

    private int countAttempts(Long memberId, Long taskId) {
        return Math.toIntExact(count(
                Wrappers.<TaskSubmission>lambdaQuery()
                        .eq(TaskSubmission::getMemberId, memberId)
                        .eq(TaskSubmission::getTaskId, taskId)
        ));
    }

    private boolean canSubmitTask(CourseTask task, int usedAttempts, int questionCount) {
        if (task == null || !Objects.equals(task.getStatus(), TASK_STATUS_PUBLISHED) || questionCount <= 0) {
            return false;
        }
        LocalDateTime now = LocalDateTime.now();
        if (task.getStartTime() != null && now.isBefore(task.getStartTime())) {
            return false;
        }
        if (task.getEndTime() != null && now.isAfter(task.getEndTime())) {
            return false;
        }
        return getRemainingAttempts(task, usedAttempts) > 0;
    }

    private int getRemainingAttempts(CourseTask task, int usedAttempts) {
        int totalAttempts = Math.max(1, (task.getAllowRetakeCount() == null ? 0 : task.getAllowRetakeCount()) + 1);
        return Math.max(0, totalAttempts - usedAttempts);
    }

    private void ensureCourseEnrolled(Long courseId) {
        if (!courseEnrollmentService.isCurrentMemberEnrolled(courseId)) {
            throw new BusinessException(ResultCode.FORBIDDEN.getCode(), "course enrollment required");
        }
    }

    private CourseTask getPublishedTaskOrThrow(Long taskId) {
        CourseTask task = courseTaskMapper.selectById(taskId);
        if (task == null || !Objects.equals(task.getStatus(), TASK_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course task not found");
        }
        return task;
    }

    private String getCourseTitle(Long courseId) {
        if (courseId == null) {
            return null;
        }
        Course course = courseMapper.selectById(courseId);
        return course == null ? null : course.getTitle();
    }

    private Long getCurrentMemberId() {
        LoginUser loginUser = SecurityUtils.getLoginUser()
                .orElseThrow(() -> new BusinessException(ResultCode.FORBIDDEN.getCode(), "member login required"));
        if (!ROLE_MEMBER.equals(loginUser.getRole()) || loginUser.getUserId() == null) {
            throw new BusinessException(ResultCode.FORBIDDEN.getCode(), "member login required");
        }
        return loginUser.getUserId();
    }

    private Map<Long, List<String>> parseSubmissionAnswers(String answersJson) {
        if (!StringUtils.hasText(answersJson)) {
            return Map.of();
        }
        try {
            JsonNode root = objectMapper.readTree(answersJson);
            if (!root.isArray()) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "answersJson must be an array");
            }
            Map<Long, List<String>> answerMap = new java.util.LinkedHashMap<>();
            for (JsonNode item : root) {
                JsonNode questionIdNode = item.get("questionId");
                if (questionIdNode == null || !questionIdNode.canConvertToLong()) {
                    throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "questionId is invalid");
                }
                answerMap.put(questionIdNode.asLong(), normalizeAnswerNode(item.get("answer")));
            }
            return answerMap;
        } catch (JsonProcessingException ex) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "answersJson is invalid");
        }
    }

    private Map<Long, List<String>> parseStoredAnswers(String answersJson) {
        if (!StringUtils.hasText(answersJson)) {
            return Map.of();
        }
        try {
            List<StoredAnswer> storedAnswers = objectMapper.readValue(answersJson, new TypeReference<List<StoredAnswer>>() {
            });
            return storedAnswers.stream().collect(Collectors.toMap(
                    StoredAnswer::questionId,
                    item -> normalizeAnswerValues(item.answer()),
                    (left, right) -> right
            ));
        } catch (JsonProcessingException ex) {
            return Map.of();
        }
    }

    private String buildStoredAnswersJson(Map<Long, List<String>> answerMap) {
        List<StoredAnswer> storedAnswers = answerMap.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry -> new StoredAnswer(entry.getKey(), normalizeAnswerValues(entry.getValue())))
                .toList();
        return writeJsonSilently(storedAnswers);
    }

    private List<String> normalizeAnswerNode(JsonNode answerNode) {
        if (answerNode == null || answerNode.isNull()) {
            return List.of();
        }
        if (answerNode.isArray()) {
            List<String> values = new java.util.ArrayList<>();
            for (JsonNode item : answerNode) {
                if (item == null || item.isNull()) {
                    continue;
                }
                String value = normalizeText(item.asText());
                if (value != null) {
                    values.add(value);
                }
            }
            return normalizeAnswerValues(values);
        }
        String value = normalizeText(answerNode.asText());
        return value == null ? List.of() : List.of(value);
    }

    private List<String> parseStringList(String json) {
        if (!StringUtils.hasText(json)) {
            return List.of();
        }
        try {
            List<String> values = objectMapper.readValue(json, new TypeReference<List<String>>() {
            });
            return normalizeAnswerValues(values);
        } catch (JsonProcessingException ex) {
            return List.of();
        }
    }

    private List<String> normalizeAnswerValues(List<String> answers) {
        return answers == null ? List.of() : answers.stream()
                .map(this::normalizeText)
                .filter(Objects::nonNull)
                .sorted(Comparator.naturalOrder())
                .toList();
    }

    private TaskSubmissionVO toSubmissionVO(TaskSubmission entity) {
        if (entity == null) {
            return null;
        }
        TaskSubmissionVO vo = new TaskSubmissionVO();
        BeanUtils.copyProperties(entity, vo);
        return vo;
    }

    private String normalizeText(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return value.trim();
    }

    private String writeJsonSilently(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException ex) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "json serialization failed");
        }
    }

    private record StoredAnswer(Long questionId, List<String> answer) {
    }
}
