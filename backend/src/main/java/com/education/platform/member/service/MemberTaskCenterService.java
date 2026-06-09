package com.education.platform.member.service;

import com.education.platform.member.vo.MemberTaskCenterItemVO;
import java.util.List;

public interface MemberTaskCenterService {

    List<MemberTaskCenterItemVO> listCurrentMemberTasks();
}
