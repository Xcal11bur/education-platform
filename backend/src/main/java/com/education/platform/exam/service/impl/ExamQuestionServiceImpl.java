package com.education.platform.exam.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.service.TeacherCourseAccessService;
import com.education.platform.exam.entity.CourseExam;
import com.education.platform.exam.entity.ExamQuestion;
import com.education.platform.exam.mapper.CourseExamMapper;
import com.education.platform.exam.mapper.ExamQuestionMapper;
import com.education.platform.exam.service.ExamQuestionService;
import com.education.platform.task.dto.TaskQuestionSaveDTO;
import com.education.platform.task.vo.TaskQuestionVO;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class ExamQuestionServiceImpl extends ServiceImpl<ExamQuestionMapper, ExamQuestion>
        implements ExamQuestionService {

    private static final int QUESTION_TYPE_SINGLE = 1;
    private static final int QUESTION_TYPE_JUDGE = 3;
    private static final int QUESTION_TYPE_SUBJECTIVE = 4;
    private static final String JUDGE_TRUE = "T";
    private static final String JUDGE_FALSE = "F";

    private final ObjectMapper objectMapper;
    private final CourseExamMapper courseExamMapper;
    private final TeacherCourseAccessService teacherCourseAccessService;

    @Override
    public List<TaskQuestionVO> listTeacherQuestions(Long examId) {
        CourseExam exam = getExamOrThrow(examId);
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());
        return lambdaQuery()
                .eq(ExamQuestion::getTaskId, examId)
                .orderByAsc(ExamQuestion::getSort)
                .orderByAsc(ExamQuestion::getId)
                .list()
                .stream()
                .map(this::toVO)
                .toList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createTeacherQuestion(Long examId, TaskQuestionSaveDTO request) {
        CourseExam exam = getExamOrThrow(examId);
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());

        NormalizedQuestion normalized = normalizeRequest(request);
        long questionCount = count(
                Wrappers.<ExamQuestion>lambdaQuery().eq(ExamQuestion::getTaskId, examId)
        );
        int nextSort = Math.toIntExact(questionCount + 1);
        ExamQuestion question = new ExamQuestion();
        question.setTaskId(examId);
        question.setQuestionType(request.getQuestionType());
        question.setStem(request.getStem().trim());
        question.setOptionsJson(normalized.optionsJson());
        question.setAnswerJson(normalized.answerJson());
        question.setAnalysis(normalizeText(request.getAnalysis()));
        question.setScore(request.getScore());
        question.setSort(nextSort);
        save(question);

        refreshExamAfterQuestionChange(examId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherQuestion(Long id, TaskQuestionSaveDTO request) {
        ExamQuestion question = getQuestionOrThrow(id);
        CourseExam exam = getExamOrThrow(question.getTaskId());
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());

        NormalizedQuestion normalized = normalizeRequest(request);
        question.setQuestionType(request.getQuestionType());
        question.setStem(request.getStem().trim());
        question.setOptionsJson(normalized.optionsJson());
        question.setAnswerJson(normalized.answerJson());
        question.setAnalysis(normalizeText(request.getAnalysis()));
        question.setScore(request.getScore());
        updateById(question);

        refreshExamAfterQuestionChange(question.getTaskId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTeacherQuestion(Long id) {
        ExamQuestion question = getQuestionOrThrow(id);
        CourseExam exam = getExamOrThrow(question.getTaskId());
        teacherCourseAccessService.getCurrentTeacherCourse(exam.getCourseId());
        removeById(id);

        refreshExamAfterQuestionChange(question.getTaskId());
    }

    private TaskQuestionVO toVO(ExamQuestion entity) {
        TaskQuestionVO vo = new TaskQuestionVO();
        BeanUtils.copyProperties(entity, vo);
        return vo;
    }

    private NormalizedQuestion normalizeRequest(TaskQuestionSaveDTO request) {
        validateBasicRequest(request);
        try {
            if (request.getQuestionType() == QUESTION_TYPE_SINGLE) {
                return normalizeSingleChoice(request);
            }
            if (request.getQuestionType() == QUESTION_TYPE_SUBJECTIVE) {
                return normalizeSubjective(request);
            }
            return normalizeJudge(request);
        } catch (JsonProcessingException ex) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "question payload is invalid");
        }
    }

    private void validateBasicRequest(TaskQuestionSaveDTO request) {
        if (request.getQuestionType() == null
                || (request.getQuestionType() != QUESTION_TYPE_SINGLE
                && request.getQuestionType() != QUESTION_TYPE_JUDGE
                && request.getQuestionType() != QUESTION_TYPE_SUBJECTIVE)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "questionType must be single, judge or subjective");
        }
        if (request.getScore() == null || request.getScore() <= 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "score must be greater than 0");
        }
        if (request.getSort() != null && request.getSort() < 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "sort must not be less than 0");
        }
    }

    private NormalizedQuestion normalizeSingleChoice(TaskQuestionSaveDTO request) throws JsonProcessingException {
        if (!StringUtils.hasText(request.getOptionsJson()) || !StringUtils.hasText(request.getAnswerJson())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "single choice question requires options and answer");
        }

        List<QuestionOption> options = objectMapper.readValue(request.getOptionsJson(), new TypeReference<List<QuestionOption>>() {
        });
        if (options.size() < 2) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "single choice question requires at least 2 options");
        }

        for (int index = 0; index < options.size(); index++) {
            QuestionOption option = options.get(index);
            String expectedLabel = String.valueOf((char) ('A' + index));
            if (!expectedLabel.equals(option.label()) || !StringUtils.hasText(option.content())) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "single choice options must use continuous labels from A");
            }
        }

        List<String> answers = objectMapper.readValue(request.getAnswerJson(), new TypeReference<List<String>>() {
        });
        if (answers.size() != 1) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "single choice question requires exactly one answer");
        }
        String answer = answers.get(0);
        boolean matched = options.stream().anyMatch(option -> Objects.equals(option.label(), answer));
        if (!matched) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "single choice answer must match one option");
        }

        List<QuestionOption> normalizedOptions = options.stream()
                .map(option -> new QuestionOption(option.label(), option.content().trim()))
                .toList();
        return new NormalizedQuestion(
                objectMapper.writeValueAsString(normalizedOptions),
                objectMapper.writeValueAsString(List.of(answer))
        );
    }

    private NormalizedQuestion normalizeJudge(TaskQuestionSaveDTO request) throws JsonProcessingException {
        if (!StringUtils.hasText(request.getAnswerJson())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "judge question requires answer");
        }
        List<String> answers = objectMapper.readValue(request.getAnswerJson(), new TypeReference<List<String>>() {
        });
        if (answers.size() != 1) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "judge question requires exactly one answer");
        }
        String answer = answers.get(0);
        if (!JUDGE_TRUE.equals(answer) && !JUDGE_FALSE.equals(answer)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "judge answer must be T or F");
        }

        List<QuestionOption> options = List.of(
                new QuestionOption(JUDGE_TRUE, "正确"),
                new QuestionOption(JUDGE_FALSE, "错误")
        );
        return new NormalizedQuestion(
                objectMapper.writeValueAsString(options),
                objectMapper.writeValueAsString(List.of(answer))
        );
    }

    private NormalizedQuestion normalizeSubjective(TaskQuestionSaveDTO request) throws JsonProcessingException {
        String referenceAnswer = normalizeText(request.getAnswerJson());
        if (referenceAnswer == null) {
            return new NormalizedQuestion(null, null);
        }
        return new NormalizedQuestion(null, objectMapper.writeValueAsString(List.of(referenceAnswer)));
    }

    private void refreshExamAfterQuestionChange(Long examId) {
        CourseExam exam = getExamOrThrow(examId);
        List<ExamQuestion> questions = baseMapper.selectList(
                Wrappers.<ExamQuestion>lambdaQuery()
                        .eq(ExamQuestion::getTaskId, examId)
                        .orderByAsc(ExamQuestion::getSort)
                        .orderByAsc(ExamQuestion::getId)
        );
        resetQuestionSorts(questions);
        int totalScore = questions.stream()
                .map(ExamQuestion::getScore)
                .filter(Objects::nonNull)
                .mapToInt(Integer::intValue)
                .sum();
        exam.setTotalScore(totalScore);
        if (exam.getStatus() != null && exam.getStatus() == 1
                && (questions.isEmpty() || (exam.getPassScore() != null && exam.getPassScore() > totalScore))) {
            exam.setStatus(0);
        }
        courseExamMapper.updateById(exam);
    }

    private CourseExam getExamOrThrow(Long examId) {
        CourseExam exam = courseExamMapper.selectById(examId);
        if (exam == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course exam not found");
        }
        return exam;
    }

    private ExamQuestion getQuestionOrThrow(Long id) {
        ExamQuestion question = getById(id);
        if (question == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "exam question not found");
        }
        return question;
    }

    private void resetQuestionSorts(List<ExamQuestion> questions) {
        for (int index = 0; index < questions.size(); index++) {
            ExamQuestion question = questions.get(index);
            int nextSort = index + 1;
            if (Objects.equals(question.getSort(), nextSort)) {
                continue;
            }
            question.setSort(nextSort);
            updateById(question);
        }
    }

    private String normalizeText(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return value.trim();
    }

    private record NormalizedQuestion(String optionsJson, String answerJson) {
    }

    private record QuestionOption(String label, String content) {
    }
}
