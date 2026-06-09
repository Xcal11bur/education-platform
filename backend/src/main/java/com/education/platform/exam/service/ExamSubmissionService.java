package com.education.platform.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.exam.entity.ExamSubmission;
import com.education.platform.exam.vo.CourseExamMemberDetailVO;
import com.education.platform.exam.vo.CourseExamMemberListVO;
import com.education.platform.task.dto.TaskSubmissionReviewDTO;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import com.education.platform.task.vo.TaskSubmissionTeacherDetailVO;
import com.education.platform.task.vo.TaskSubmissionTeacherVO;
import com.education.platform.task.vo.TaskSubmissionVO;
import java.time.LocalDateTime;
import java.util.List;

public interface ExamSubmissionService extends IService<ExamSubmission> {

    List<CourseExamMemberListVO> listCurrentMemberCourseExams(Long courseId);

    CourseExamMemberDetailVO getCurrentMemberExamDetail(Long examId, LocalDateTime startedAt);

    List<TaskSubmissionVO> listCurrentMemberExamSubmissions(Long examId);

    void submitCurrentMemberExam(Long examId, TaskSubmissionSaveDTO request);

    List<TaskSubmissionTeacherVO> listTeacherExamSubmissions(Long examId);

    TaskSubmissionTeacherDetailVO getTeacherExamSubmissionDetail(Long submissionId);

    void reviewTeacherExamSubmission(Long submissionId, TaskSubmissionReviewDTO request);
}
