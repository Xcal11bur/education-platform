package com.education.platform.member.service.impl;

import com.education.platform.course.entity.CourseEnrollment;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.exam.service.ExamSubmissionService;
import com.education.platform.exam.vo.CourseExamMemberListVO;
import com.education.platform.member.service.MemberTaskCenterService;
import com.education.platform.member.vo.MemberTaskCenterItemVO;
import com.education.platform.task.service.TaskSubmissionService;
import com.education.platform.task.vo.CourseTaskMemberListVO;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberTaskCenterServiceImpl implements MemberTaskCenterService {

    private static final String TYPE_TASK = "TASK";
    private static final String TYPE_EXAM = "EXAM";

    private final CourseEnrollmentService courseEnrollmentService;
    private final TaskSubmissionService taskSubmissionService;
    private final ExamSubmissionService examSubmissionService;

    @Override
    public List<MemberTaskCenterItemVO> listCurrentMemberTasks() {
        List<CourseEnrollment> enrollments = courseEnrollmentService.listCurrentMemberActiveEnrollments();
        if (enrollments.isEmpty()) {
            return List.of();
        }

        List<MemberTaskCenterItemVO> items = new ArrayList<>();
        for (CourseEnrollment enrollment : enrollments) {
            Long courseId = enrollment.getCourseId();
            if (courseId == null) {
                continue;
            }
            items.addAll(taskSubmissionService.listCurrentMemberCourseTasks(courseId).stream()
                    .map(this::fromTask)
                    .toList());
            items.addAll(examSubmissionService.listCurrentMemberCourseExams(courseId).stream()
                    .map(this::fromExam)
                    .toList());
        }

        return items.stream()
                .sorted(Comparator
                        .comparing(MemberTaskCenterItemVO::getEndTime, Comparator.nullsLast(LocalDateTime::compareTo))
                        .thenComparing(MemberTaskCenterItemVO::getStartTime, Comparator.nullsLast(LocalDateTime::compareTo))
                        .thenComparing(MemberTaskCenterItemVO::getCourseTitle, Comparator.nullsLast(String::compareTo))
                        .thenComparing(MemberTaskCenterItemVO::getId, Comparator.nullsLast(Long::compareTo)))
                .toList();
    }

    private MemberTaskCenterItemVO fromTask(CourseTaskMemberListVO task) {
        MemberTaskCenterItemVO item = new MemberTaskCenterItemVO();
        item.setId(task.getId());
        item.setType(TYPE_TASK);
        item.setCourseId(task.getCourseId());
        item.setCourseTitle(task.getCourseTitle());
        item.setTitle(task.getTitle());
        item.setTotalScore(task.getTotalScore());
        item.setPassScore(task.getPassScore());
        item.setStartTime(task.getStartTime());
        item.setEndTime(task.getEndTime());
        item.setDurationMinutes(null);
        item.setQuestionCount(task.getQuestionCount());
        item.setCompleted(task.getCompleted());
        item.setLatestScore(task.getLatestScore());
        item.setLatestReviewStatus(task.getLatestReviewStatus());
        item.setLatestSubmittedAt(task.getLatestSubmittedAt());
        item.setUsedAttempts(task.getUsedAttempts());
        item.setRemainingAttempts(task.getRemainingAttempts());
        item.setCanSubmit(task.getCanSubmit());
        return item;
    }

    private MemberTaskCenterItemVO fromExam(CourseExamMemberListVO exam) {
        MemberTaskCenterItemVO item = new MemberTaskCenterItemVO();
        item.setId(exam.getId());
        item.setType(TYPE_EXAM);
        item.setCourseId(exam.getCourseId());
        item.setCourseTitle(exam.getCourseTitle());
        item.setTitle(exam.getTitle());
        item.setTotalScore(exam.getTotalScore());
        item.setPassScore(exam.getPassScore());
        item.setStartTime(exam.getStartTime());
        item.setEndTime(exam.getEndTime());
        item.setDurationMinutes(exam.getDurationMinutes());
        item.setQuestionCount(exam.getQuestionCount());
        item.setCompleted(exam.getCompleted());
        item.setLatestScore(exam.getLatestScore());
        item.setLatestReviewStatus(exam.getLatestReviewStatus());
        item.setLatestSubmittedAt(exam.getLatestSubmittedAt());
        item.setUsedAttempts(exam.getUsedAttempts());
        item.setRemainingAttempts(exam.getRemainingAttempts());
        item.setCanSubmit(exam.getCanSubmit());
        return item;
    }
}
