package com.education.platform.exam.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.course.service.TeacherCourseAccessService;
import com.education.platform.exam.entity.CourseExam;
import com.education.platform.exam.entity.ExamQuestion;
import com.education.platform.exam.entity.ExamSubmission;
import com.education.platform.exam.mapper.CourseExamMapper;
import com.education.platform.exam.mapper.ExamQuestionMapper;
import com.education.platform.exam.mapper.ExamSubmissionMapper;
import com.education.platform.exam.service.ExamSubmissionService;
import com.education.platform.exam.vo.CourseExamMemberDetailVO;
import com.education.platform.exam.vo.CourseExamMemberListVO;
import com.education.platform.member.entity.Member;
import com.education.platform.member.mapper.MemberMapper;
import com.education.platform.task.dto.TaskSubmissionReviewDTO;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import com.education.platform.task.vo.TaskQuestionMemberVO;
import com.education.platform.task.vo.TaskSubmissionVO;
import com.education.platform.task.vo.TaskSubmissionQuestionTeacherVO;
import com.education.platform.task.vo.TaskSubmissionTeacherDetailVO;
import com.education.platform.task.vo.TaskSubmissionTeacherVO;
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
public class ExamSubmissionServiceImpl extends ServiceImpl<ExamSubmissionMapper, ExamSubmission>
        implements ExamSubmissionService {

    private static final String ROLE_MEMBER = "MEMBER";
    private static final int EXAM_STATUS_PUBLISHED = 1;
    private static final int REVIEW_PENDING_STATUS = 0;
    private static final int REVIEWED_STATUS = 1;
    private static final Set<Integer> SUPPORTED_QUESTION_TYPES = Set.of(1, 3);
    private static final int QUESTION_TYPE_SUBJECTIVE = 4;

    private final ObjectMapper objectMapper;
    private final CourseMapper courseMapper;
    private final CourseExamMapper courseExamMapper;
    private final ExamQuestionMapper examQuestionMapper;
    private final CourseEnrollmentService courseEnrollmentService;
    private final TeacherCourseAccessService teacherCourseAccessService;
    private final MemberMapper memberMapper;

    @Override
    public List<CourseExamMemberListVO> listCurrentMemberCourseExams(Long courseId) {
        Long memberId = getCurrentMemberId();
        ensureCourseEnrolled(courseId);

        List<CourseExam> exams = courseExamMapper.selectList(
                Wrappers.<CourseExam>lambdaQuery()
                        .eq(CourseExam::getCourseId, courseId)
                        .eq(CourseExam::getStatus, EXAM_STATUS_PUBLISHED)
                        .orderByAsc(CourseExam::getEndTime)
                        .orderByDesc(CourseExam::getId)
        );
        if (exams.isEmpty()) {
            return List.of();
        }

        Map<Long, Integer> questionCountMap = buildQuestionCountMap(exams.stream().map(CourseExam::getId).toList());
        Map<Long, ExamSubmission> latestSubmissionMap = listLatestSubmissionMap(memberId, exams.stream().map(CourseExam::getId).toList());
        Map<Long, Integer> usedAttemptsMap = buildUsedAttemptsMap(memberId, exams.stream().map(CourseExam::getId).toList());
        String courseTitle = getCourseTitle(courseId);

        return exams.stream().map(exam -> {
            CourseExamMemberListVO vo = new CourseExamMemberListVO();
            BeanUtils.copyProperties(exam, vo);
            vo.setQuestionCount(questionCountMap.getOrDefault(exam.getId(), 0));
            vo.setCourseTitle(courseTitle);

            ExamSubmission latestSubmission = latestSubmissionMap.get(exam.getId());
            vo.setCompleted(latestSubmission != null);
            vo.setLatestReviewStatus(latestSubmission == null ? null : latestSubmission.getReviewStatus());
            vo.setLatestScore(latestSubmission == null || !Objects.equals(latestSubmission.getReviewStatus(), REVIEWED_STATUS)
                    ? null
                    : latestSubmission.getScore());
            vo.setLatestSubmittedAt(latestSubmission == null ? null : latestSubmission.getSubmittedAt());

            int usedAttempts = usedAttemptsMap.getOrDefault(exam.getId(), 0);
            int remainingAttempts = getRemainingAttempts(exam, usedAttempts);
            vo.setUsedAttempts(usedAttempts);
            vo.setRemainingAttempts(remainingAttempts);
            vo.setCanSubmit(canSubmitExam(exam, usedAttempts, vo.getQuestionCount(), null));
            return vo;
        }).toList();
    }

    @Override
    public CourseExamMemberDetailVO getCurrentMemberExamDetail(Long examId, LocalDateTime startedAt) {
        Long memberId = getCurrentMemberId();
        CourseExam exam = getPublishedExamOrThrow(examId);
        ensureCourseEnrolled(exam.getCourseId());

        List<ExamQuestion> questions = listExamQuestions(examId);
        ExamSubmission latestSubmission = getLatestSubmission(memberId, examId);
        int usedAttempts = countAttempts(memberId, examId);

        CourseExamMemberDetailVO vo = new CourseExamMemberDetailVO();
        BeanUtils.copyProperties(exam, vo);
        vo.setCourseTitle(getCourseTitle(exam.getCourseId()));
        vo.setQuestionCount(questions.size());
        vo.setSubmitted(latestSubmission != null);
        vo.setUsedAttempts(usedAttempts);
        vo.setRemainingAttempts(getRemainingAttempts(exam, usedAttempts));
        vo.setCanSubmit(canSubmitExam(exam, usedAttempts, questions.size(), startedAt));
        vo.setLatestSubmission(toSubmissionVO(latestSubmission));
        vo.setQuestions(buildMemberQuestionVOs(questions, latestSubmission));
        return vo;
    }

    @Override
    public List<TaskSubmissionVO> listCurrentMemberExamSubmissions(Long examId) {
        Long memberId = getCurrentMemberId();
        CourseExam exam = getPublishedExamOrThrow(examId);
        ensureCourseEnrolled(exam.getCourseId());
        return lambdaQuery()
                .eq(ExamSubmission::getTaskId, examId)
                .eq(ExamSubmission::getMemberId, memberId)
                .orderByDesc(ExamSubmission::getAttemptNo)
                .orderByDesc(ExamSubmission::getId)
                .list()
                .stream()
                .map(this::toSubmissionVO)
                .toList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitCurrentMemberExam(Long examId, TaskSubmissionSaveDTO request) {
        Long memberId = getCurrentMemberId();
        CourseExam exam = getPublishedExamOrThrow(examId);
        ensureCourseEnrolled(exam.getCourseId());

        List<ExamQuestion> questions = listExamQuestions(examId);
        if (questions.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "exam questions not found");
        }

        int usedAttempts = countAttempts(memberId, examId);
        if (!canSubmitExam(exam, usedAttempts, questions.size(), request.getStartedAt())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "exam can not be submitted now");
        }

        Map<Long, List<String>> answerMap = parseSubmissionAnswers(request.getAnswersJson());
        Map<Long, StoredAnswer> storedAnswerMap = buildSubmissionStoredAnswerMap(questions, answerMap);
        int objectiveScore = calculateObjectiveScore(questions, storedAnswerMap);
        boolean hasSubjectiveQuestion = questions.stream().anyMatch(question -> Objects.equals(question.getQuestionType(), QUESTION_TYPE_SUBJECTIVE));
        LocalDateTime now = LocalDateTime.now();

        ExamSubmission submission = new ExamSubmission();
        submission.setTaskId(examId);
        submission.setMemberId(memberId);
        submission.setAttemptNo(usedAttempts + 1);
        submission.setAnswersJson(buildStoredAnswersJson(storedAnswerMap));
        submission.setAttachmentUrl(normalizeText(request.getAttachmentUrl()));
        submission.setObjectiveScore(objectiveScore);
        submission.setSubjectiveScore(0);
        submission.setScore(objectiveScore);
        submission.setReviewStatus(hasSubjectiveQuestion ? REVIEW_PENDING_STATUS : REVIEWED_STATUS);
        submission.setSubmittedAt(now);
        submission.setReviewedAt(hasSubjectiveQuestion ? null : now);
        save(submission);
    }

    @Override
    public List<TaskSubmissionTeacherVO> listTeacherExamSubmissions(Long examId) {
        CourseExam exam = getExamOrThrow(examId);
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());

        List<ExamSubmission> submissions = lambdaQuery()
                .eq(ExamSubmission::getTaskId, examId)
                .orderByDesc(ExamSubmission::getSubmittedAt)
                .orderByDesc(ExamSubmission::getId)
                .list();
        if (submissions.isEmpty()) {
            return List.of();
        }

        Map<Long, Member> memberMap = listMembersByIds(submissions.stream()
                .map(ExamSubmission::getMemberId)
                .filter(Objects::nonNull)
                .toList());

        return submissions.stream().map(submission -> {
            TaskSubmissionTeacherVO vo = new TaskSubmissionTeacherVO();
            BeanUtils.copyProperties(submission, vo);
            vo.setTaskTitle(exam.getTitle());
            Member member = memberMap.get(submission.getMemberId());
            if (member != null) {
                vo.setMemberName(getMemberDisplayName(member));
                vo.setMemberMobile(member.getMobile());
            }
            return vo;
        }).toList();
    }

    @Override
    public TaskSubmissionTeacherDetailVO getTeacherExamSubmissionDetail(Long submissionId) {
        ExamSubmission submission = getSubmissionOrThrow(submissionId);
        CourseExam exam = getExamOrThrow(submission.getTaskId());
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());

        Member member = memberMapper.selectById(submission.getMemberId());
        List<ExamQuestion> questions = listExamQuestions(exam.getId());
        Map<Long, StoredAnswer> storedAnswerMap = parseStoredAnswers(submission.getAnswersJson());

        TaskSubmissionTeacherDetailVO vo = new TaskSubmissionTeacherDetailVO();
        BeanUtils.copyProperties(submission, vo);
        vo.setTaskTitle(exam.getTitle());
        vo.setCourseId(exam.getCourseId());
        vo.setCourseTitle(getCourseTitle(exam.getCourseId()));
        vo.setTotalScore(exam.getTotalScore());
        vo.setPassScore(exam.getPassScore());
        if (member != null) {
            vo.setMemberName(getMemberDisplayName(member));
            vo.setMemberMobile(member.getMobile());
        }
        vo.setQuestions(questions.stream().map(question -> {
            TaskSubmissionQuestionTeacherVO questionVO = new TaskSubmissionQuestionTeacherVO();
            questionVO.setQuestionId(question.getId());
            questionVO.setQuestionType(question.getQuestionType());
            questionVO.setStem(question.getStem());
            questionVO.setOptionsJson(question.getOptionsJson());
            questionVO.setAnswerJson(question.getAnswerJson());
            questionVO.setAnalysis(question.getAnalysis());
            questionVO.setScore(question.getScore());
            questionVO.setSort(question.getSort());
            StoredAnswer storedAnswer = storedAnswerMap.get(question.getId());
            if (storedAnswer != null) {
                questionVO.setMemberAnswerJson(writeJsonSilently(storedAnswer.answer()));
                questionVO.setEarnedScore(storedAnswer.earnedScore());
            }
            return questionVO;
        }).toList());
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reviewTeacherExamSubmission(Long submissionId, TaskSubmissionReviewDTO request) {
        ExamSubmission submission = getSubmissionOrThrow(submissionId);
        CourseExam exam = getExamOrThrow(submission.getTaskId());
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());

        List<ExamQuestion> questions = listExamQuestions(exam.getId());
        Map<Long, ExamQuestion> questionMap = questions.stream().collect(Collectors.toMap(ExamQuestion::getId, Function.identity()));
        Map<Long, StoredAnswer> storedAnswerMap = parseStoredAnswers(submission.getAnswersJson());
        List<TaskSubmissionReviewDTO.QuestionScoreDTO> questionScores = request.getQuestionScores() == null
                ? List.of()
                : request.getQuestionScores();
        Map<Long, Integer> reviewScoreMap = questionScores.stream().collect(Collectors.toMap(
                TaskSubmissionReviewDTO.QuestionScoreDTO::getQuestionId,
                TaskSubmissionReviewDTO.QuestionScoreDTO::getScore,
                (left, right) -> right
        ));

        int objectiveScore = 0;
        int subjectiveScore = 0;
        for (ExamQuestion question : questions) {
            StoredAnswer storedAnswer = storedAnswerMap.get(question.getId());
            if (storedAnswer == null) {
                continue;
            }
            if (SUPPORTED_QUESTION_TYPES.contains(question.getQuestionType())) {
                int earnedScore = storedAnswer.earnedScore() == null
                        ? (isCorrectAnswer(question, storedAnswer.answer()) ? (question.getScore() == null ? 0 : question.getScore()) : 0)
                        : storedAnswer.earnedScore();
                storedAnswerMap.put(question.getId(), new StoredAnswer(question.getId(), storedAnswer.answer(), earnedScore));
                objectiveScore += earnedScore;
                continue;
            }
            if (!Objects.equals(question.getQuestionType(), QUESTION_TYPE_SUBJECTIVE)) {
                continue;
            }
            Integer score = reviewScoreMap.get(question.getId());
            if (score == null) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "missing subjective question score");
            }
            validateSubjectiveScore(question, score);
            storedAnswerMap.put(question.getId(), new StoredAnswer(question.getId(), storedAnswer.answer(), score));
            subjectiveScore += score;
        }

        for (TaskSubmissionReviewDTO.QuestionScoreDTO item : questionScores) {
            ExamQuestion question = questionMap.get(item.getQuestionId());
            if (question == null) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "question not found in exam");
            }
            if (!Objects.equals(question.getQuestionType(), QUESTION_TYPE_SUBJECTIVE)) {
                continue;
            }
            validateSubjectiveScore(question, item.getScore());
        }

        submission.setAnswersJson(buildStoredAnswersJson(storedAnswerMap));
        submission.setObjectiveScore(objectiveScore);
        submission.setSubjectiveScore(subjectiveScore);
        submission.setScore(objectiveScore + subjectiveScore);
        submission.setReviewStatus(REVIEWED_STATUS);
        submission.setReviewComment(normalizeText(request.getReviewComment()));
        submission.setReviewedAt(LocalDateTime.now());
        updateById(submission);
    }

    private List<ExamQuestion> listExamQuestions(Long examId) {
        return examQuestionMapper.selectList(
                Wrappers.<ExamQuestion>lambdaQuery()
                        .eq(ExamQuestion::getTaskId, examId)
                        .orderByAsc(ExamQuestion::getSort)
                        .orderByAsc(ExamQuestion::getId)
        );
    }

    private List<TaskQuestionMemberVO> buildMemberQuestionVOs(List<ExamQuestion> questions, ExamSubmission latestSubmission) {
        Map<Long, StoredAnswer> submissionAnswerMap = latestSubmission == null
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
                StoredAnswer storedAnswer = submissionAnswerMap.get(question.getId());
                List<String> myAnswer = storedAnswer == null ? List.of() : storedAnswer.answer();
                vo.setMyAnswerJson(writeJsonSilently(myAnswer));
                vo.setEarnedScore(storedAnswer == null ? null : storedAnswer.earnedScore());
                boolean reviewPending = Objects.equals(question.getQuestionType(), QUESTION_TYPE_SUBJECTIVE)
                        && !Objects.equals(latestSubmission.getReviewStatus(), REVIEWED_STATUS);
                vo.setReviewPending(reviewPending);
                vo.setCorrectAnswerJson(reviewPending ? null : question.getAnswerJson());
                vo.setAnalysis(reviewPending ? null : question.getAnalysis());
            }
            return vo;
        }).toList();
    }

    private int calculateObjectiveScore(List<ExamQuestion> questions, Map<Long, StoredAnswer> answerMap) {
        int score = 0;
        for (ExamQuestion question : questions) {
            if (!SUPPORTED_QUESTION_TYPES.contains(question.getQuestionType())) {
                continue;
            }
            StoredAnswer storedAnswer = answerMap.get(question.getId());
            score += storedAnswer == null || storedAnswer.earnedScore() == null ? 0 : storedAnswer.earnedScore();
        }
        return score;
    }

    private boolean isCorrectAnswer(ExamQuestion question, List<String> answers) {
        List<String> standardAnswers = parseStringList(question.getAnswerJson());
        return Objects.equals(normalizeAnswerValues(answers), normalizeAnswerValues(standardAnswers));
    }

    private Map<Long, Integer> buildQuestionCountMap(Collection<Long> examIds) {
        if (examIds == null || examIds.isEmpty()) {
            return Map.of();
        }
        return examQuestionMapper.selectList(
                Wrappers.<ExamQuestion>lambdaQuery().in(ExamQuestion::getTaskId, examIds)
        ).stream().collect(Collectors.groupingBy(
                ExamQuestion::getTaskId,
                Collectors.collectingAndThen(Collectors.counting(), Math::toIntExact)
        ));
    }

    private Map<Long, ExamSubmission> listLatestSubmissionMap(Long memberId, Collection<Long> examIds) {
        if (examIds == null || examIds.isEmpty()) {
            return Map.of();
        }
        return lambdaQuery()
                .eq(ExamSubmission::getMemberId, memberId)
                .in(ExamSubmission::getTaskId, examIds)
                .orderByDesc(ExamSubmission::getAttemptNo)
                .orderByDesc(ExamSubmission::getId)
                .list()
                .stream()
                .collect(Collectors.toMap(
                        ExamSubmission::getTaskId,
                        Function.identity(),
                        (left, right) -> left
                ));
    }

    private Map<Long, Integer> buildUsedAttemptsMap(Long memberId, Collection<Long> examIds) {
        if (examIds == null || examIds.isEmpty()) {
            return Map.of();
        }
        return lambdaQuery()
                .eq(ExamSubmission::getMemberId, memberId)
                .in(ExamSubmission::getTaskId, examIds)
                .list()
                .stream()
                .collect(Collectors.groupingBy(
                        ExamSubmission::getTaskId,
                        Collectors.collectingAndThen(Collectors.counting(), Math::toIntExact)
                ));
    }

    private ExamSubmission getLatestSubmission(Long memberId, Long examId) {
        return lambdaQuery()
                .eq(ExamSubmission::getMemberId, memberId)
                .eq(ExamSubmission::getTaskId, examId)
                .orderByDesc(ExamSubmission::getAttemptNo)
                .orderByDesc(ExamSubmission::getId)
                .last("LIMIT 1")
                .one();
    }

    private int countAttempts(Long memberId, Long examId) {
        return Math.toIntExact(count(
                Wrappers.<ExamSubmission>lambdaQuery()
                        .eq(ExamSubmission::getMemberId, memberId)
                        .eq(ExamSubmission::getTaskId, examId)
        ));
    }

    private boolean canSubmitExam(CourseExam exam, int usedAttempts, int questionCount, LocalDateTime startedAt) {
        if (exam == null
                || !Objects.equals(exam.getStatus(), EXAM_STATUS_PUBLISHED)
                || questionCount <= 0
                || getRemainingAttempts(exam, usedAttempts) <= 0) {
            return false;
        }
        LocalDateTime now = LocalDateTime.now();
        if (exam.getStartTime() != null && now.isBefore(exam.getStartTime())) {
            return false;
        }
        if (isExamSessionActive(exam, startedAt, now)) {
            return true;
        }
        if (exam.getEndTime() != null && now.isAfter(exam.getEndTime())) {
            return false;
        }
        return true;
    }

    private boolean isExamSessionActive(CourseExam exam, LocalDateTime startedAt, LocalDateTime now) {
        if (startedAt == null) {
            return false;
        }
        if (exam.getStartTime() != null && startedAt.isBefore(exam.getStartTime())) {
            return false;
        }
        if (exam.getEndTime() != null && startedAt.isAfter(exam.getEndTime())) {
            return false;
        }
        if (startedAt.isAfter(now)) {
            return false;
        }
        LocalDateTime expiresAt = startedAt.plusMinutes(exam.getDurationMinutes());
        return now.isBefore(expiresAt);
    }

    private int getRemainingAttempts(CourseExam exam, int usedAttempts) {
        int totalAttempts = Math.max(1, (exam.getAllowRetakeCount() == null ? 0 : exam.getAllowRetakeCount()) + 1);
        return Math.max(0, totalAttempts - usedAttempts);
    }

    private void ensureCourseEnrolled(Long courseId) {
        if (!courseEnrollmentService.isCurrentMemberEnrolled(courseId)) {
            throw new BusinessException(ResultCode.FORBIDDEN.getCode(), "course enrollment required");
        }
    }

    private CourseExam getPublishedExamOrThrow(Long examId) {
        CourseExam exam = courseExamMapper.selectById(examId);
        if (exam == null || !Objects.equals(exam.getStatus(), EXAM_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course exam not found");
        }
        return exam;
    }

    private CourseExam getExamOrThrow(Long examId) {
        CourseExam exam = courseExamMapper.selectById(examId);
        if (exam == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course exam not found");
        }
        return exam;
    }

    private ExamSubmission getSubmissionOrThrow(Long submissionId) {
        ExamSubmission submission = getById(submissionId);
        if (submission == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "exam submission not found");
        }
        return submission;
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

    private Map<Long, StoredAnswer> parseStoredAnswers(String answersJson) {
        if (!StringUtils.hasText(answersJson)) {
            return Map.of();
        }
        try {
            List<StoredAnswer> storedAnswers = objectMapper.readValue(answersJson, new TypeReference<List<StoredAnswer>>() {
            });
            return storedAnswers.stream().collect(Collectors.toMap(
                    StoredAnswer::questionId,
                    item -> new StoredAnswer(item.questionId(), normalizeAnswerValues(item.answer()), item.earnedScore()),
                    (left, right) -> right
            ));
        } catch (JsonProcessingException ex) {
            return Map.of();
        }
    }

    private String buildStoredAnswersJson(Map<Long, StoredAnswer> answerMap) {
        List<StoredAnswer> storedAnswers = answerMap.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(Map.Entry::getValue)
                .toList();
        return writeJsonSilently(storedAnswers);
    }

    private Map<Long, StoredAnswer> buildSubmissionStoredAnswerMap(List<ExamQuestion> questions, Map<Long, List<String>> answerMap) {
        Map<Long, StoredAnswer> storedAnswerMap = new java.util.LinkedHashMap<>();
        for (ExamQuestion question : questions) {
            List<String> answers = answerMap.getOrDefault(question.getId(), List.of());
            Integer earnedScore = null;
            if (SUPPORTED_QUESTION_TYPES.contains(question.getQuestionType())) {
                earnedScore = isCorrectAnswer(question, answers) ? (question.getScore() == null ? 0 : question.getScore()) : 0;
            }
            storedAnswerMap.put(question.getId(), new StoredAnswer(question.getId(), answers, earnedScore));
        }
        return storedAnswerMap;
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

    private TaskSubmissionVO toSubmissionVO(ExamSubmission entity) {
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

    private Map<Long, Member> listMembersByIds(Collection<Long> memberIds) {
        if (memberIds == null || memberIds.isEmpty()) {
            return Map.of();
        }
        return memberMapper.selectList(
                Wrappers.<Member>lambdaQuery().in(Member::getId, memberIds)
        ).stream().collect(Collectors.toMap(Member::getId, Function.identity()));
    }

    private String getMemberDisplayName(Member member) {
        if (member == null) {
            return null;
        }
        if (StringUtils.hasText(member.getNickname())) {
            return member.getNickname().trim();
        }
        if (StringUtils.hasText(member.getRealName())) {
            return member.getRealName().trim();
        }
        return member.getMobile();
    }

    private void validateSubjectiveScore(ExamQuestion question, Integer score) {
        if (score == null || score < 0 || score > (question.getScore() == null ? 0 : question.getScore())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "subjective score is invalid");
        }
    }

    private record StoredAnswer(Long questionId, List<String> answer, Integer earnedScore) {
    }
}
