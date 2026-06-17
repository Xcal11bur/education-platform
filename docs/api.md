# 教育云平台接口文档

## 1. 基本说明

- 基础前缀：`/api/v1`
- 后端默认端口：`8080`
- 认证方式：`Authorization: Bearer <token>`
- 数据格式：`application/json`
- 文件上传：`multipart/form-data`
- 分页默认值：`pageNum=1`，`pageSize=10`
- 分页上限：`pageSize <= 100`
- 时间格式：`yyyy-MM-dd HH:mm:ss`
- 日期格式：`yyyy-MM-dd`

## 2. 通用返回结构

除文件流接口外，系统统一返回：

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "traceId": null
}
```

### 2.1 返回码

| code | 含义 |
| --- | --- |
| 0 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未登录或 token 无效 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 业务冲突 |
| 500 | 服务器内部错误 |

### 2.2 分页返回结构

```json
{
  "pageNum": 1,
  "pageSize": 10,
  "total": 100,
  "list": []
}
```

## 3. 权限约定

| 角色 | 说明 |
| --- | --- |
| `ADMIN` | 管理端 |
| `TEACHER` | 教师端 |
| `MEMBER` | 学员端 |
| `PORTAL` | 公共访问，无需登录 |

## 4. 认证与用户

### 4.1 获取验证码

- 接口：`GET /auth/captcha`
- 权限：`PORTAL`
- 说明：登录/注册前获取验证码

返回 `data` 示例：

```json
{
  "captchaKey": "8b6d7d3d-xxxx",
  "imageBase64": "data:image/png;base64,...",
  "expiresIn": 300
}
```

### 4.2 管理员登录

- 接口：`POST /auth/admin/login`
- 权限：`PORTAL`

请求体：

```json
{
  "username": "admin",
  "password": "123456",
  "captchaKey": "xxx",
  "captchaCode": "abcd"
}
```

### 4.3 教师登录

- 接口：`POST /auth/teacher/login`
- 权限：`PORTAL`
- 请求体同上

### 4.4 学员登录

- 接口：`POST /auth/member/login`
- 权限：`PORTAL`
- 请求体同上

### 4.5 学员注册

- 接口：`POST /auth/member/register`
- 权限：`PORTAL`

请求体：

```json
{
  "mobile": "13800138000",
  "nickname": "张三",
  "realName": "张三",
  "password": "123456",
  "confirmPassword": "123456",
  "captchaKey": "xxx",
  "captchaCode": "abcd"
}
```

### 4.6 获取当前登录用户信息

- 接口：`GET /auth/profile`
- 权限：已登录

返回 `data` 示例：

```json
{
  "userId": 1,
  "username": "admin",
  "role": "ADMIN",
  "displayName": "系统管理员",
  "avatar": "https://...",
  "balance": 0
}
```

### 4.7 健康检查

- 接口：`GET /health`
- 权限：`PORTAL`

## 5. 管理端接口

### 5.1 教师管理

#### 5.1.1 教师分页列表

- `GET /admin/teachers`
- 参数：`pageNum` `pageSize` `name` `mobile` `status`

#### 5.1.2 教师详情

- `GET /admin/teachers/{id}`

#### 5.1.3 新增教师

- `POST /admin/teachers`

请求体：

```json
{
  "loginName": "teacher01",
  "name": "李老师",
  "mobile": "13800138000",
  "password": "123456",
  "title": "高级讲师",
  "intro": "主讲 Java",
  "avatar": "https://...",
  "email": "teacher@test.com",
  "status": 1
}
```

#### 5.1.4 更新教师

- `PUT /admin/teachers/{id}`
- 请求体同新增

#### 5.1.5 修改教师状态

- `PUT /admin/teachers/{id}/status`

```json
{
  "status": 1
}
```

### 5.2 学员管理

#### 5.2.1 学员分页列表

- `GET /admin/members`
- 参数：`pageNum` `pageSize` `mobile` `nickname` `status`

#### 5.2.2 学员详情

- `GET /admin/members/{id}`

#### 5.2.3 新增学员

- `POST /admin/members`

```json
{
  "mobile": "13800138000",
  "nickname": "小王",
  "password": "123456",
  "realName": "王同学",
  "avatar": "https://...",
  "gender": 1,
  "birthday": "2000-01-01",
  "status": 1
}
```

#### 5.2.4 更新学员

- `PUT /admin/members/{id}`
- 请求体同新增

#### 5.2.5 修改学员状态

- `PUT /admin/members/{id}/status`

```json
{
  "status": 1
}
```

### 5.3 课程分类管理

#### 5.3.1 分类树

- `GET /admin/course-categories/tree`

#### 5.3.2 分类详情

- `GET /admin/course-categories/{id}`

#### 5.3.3 新增分类

- `POST /admin/course-categories`

```json
{
  "parentId": 0,
  "name": "后端开发",
  "level": 1,
  "status": 1
}
```

#### 5.3.4 更新分类

- `PUT /admin/course-categories/{id}`

#### 5.3.5 删除分类

- `DELETE /admin/course-categories/{id}`

### 5.4 课程管理

#### 5.4.1 课程分页列表

- `GET /admin/courses`
- 参数：`pageNum` `pageSize` `title` `teacherId` `categoryLevel2Id` `publishStatus`

#### 5.4.2 课程详情

- `GET /admin/courses/{id}`

#### 5.4.3 新增课程

- `POST /admin/courses`

```json
{
  "title": "Spring Boot 实战",
  "subTitle": "从入门到项目",
  "teacherId": 1,
  "categoryLevel1Id": 10,
  "categoryLevel2Id": 11,
  "coverUrl": "https://...",
  "description": "课程简介",
  "difficulty": 2,
  "price": 199.00,
  "publishStatus": 0
}
```

#### 5.4.4 更新课程

- `PUT /admin/courses/{id}`

#### 5.4.5 修改课程发布状态

- `PUT /admin/courses/{id}/publish-status`

```json
{
  "publishStatus": 1
}
```

#### 5.4.6 删除课程

- `DELETE /admin/courses/{id}`

### 5.5 课程 Banner 管理

#### 5.5.1 Banner 分页列表

- `GET /admin/course-banners`
- 参数：`pageNum` `pageSize` `courseId` `status`

#### 5.5.2 Banner 详情

- `GET /admin/course-banners/{id}`

#### 5.5.3 新增 Banner

- `POST /admin/course-banners`

```json
{
  "courseId": 1,
  "title": "首页推荐",
  "subTitle": "热门课程",
  "status": 1
}
```

#### 5.5.4 更新 Banner

- `PUT /admin/course-banners/{id}`

#### 5.5.5 修改 Banner 状态

- `PUT /admin/course-banners/{id}/status`

```json
{
  "status": 1
}
```

#### 5.5.6 删除 Banner

- `DELETE /admin/course-banners/{id}`

### 5.6 课程章节与小节管理

#### 5.6.1 获取课程章节树

- `GET /admin/courses/{courseId}/chapters/tree`

#### 5.6.2 新增章节

- `POST /admin/courses/{courseId}/chapters`

```json
{
  "title": "第一章 课程导学"
}
```

#### 5.6.3 更新章节

- `PUT /admin/chapters/{id}`

#### 5.6.4 删除章节

- `DELETE /admin/chapters/{id}`

#### 5.6.5 新增小节

- `POST /admin/chapters/{chapterId}/sections`

```json
{
  "title": "1.1 开发环境",
  "isFreeTrial": 1
}
```

#### 5.6.6 更新小节

- `PUT /admin/sections/{id}`

#### 5.6.7 删除小节

- `DELETE /admin/sections/{id}`

### 5.7 小节内容管理

#### 5.7.1 小节内容列表

- `GET /admin/sections/{sectionId}/contents`

#### 5.7.2 小节内容详情

- `GET /admin/section-contents/{id}`

#### 5.7.3 新增小节内容

- `POST /admin/sections/{sectionId}/contents`

```json
{
  "title": "课件 PDF",
  "contentType": "PDF",
  "contentHtml": "",
  "contentJson": "",
  "fileUrl": "https://...",
  "objectKey": "education-platform/materials/xxx.pdf",
  "fileName": "lesson1.pdf",
  "mimeType": "application/pdf",
  "fileSize": 102400,
  "duration": 0,
  "status": 1
}
```

#### 5.7.4 更新小节内容

- `PUT /admin/section-contents/{id}`

#### 5.7.5 删除小节内容

- `DELETE /admin/section-contents/{id}`

### 5.8 课程资料管理

#### 5.8.1 资料分页列表

- `GET /admin/course-materials`
- 参数：`pageNum` `pageSize` `courseId` `materialName` `materialType`

#### 5.8.2 资料详情

- `GET /admin/course-materials/{id}`

#### 5.8.3 新增资料

- `POST /admin/course-materials`

```json
{
  "courseId": 1,
  "materialName": "课程讲义",
  "materialType": 1,
  "fileUrl": "https://...",
  "fileSize": 123456,
  "downloadLimit": 10
}
```

#### 5.8.4 更新资料

- `PUT /admin/course-materials/{id}`

#### 5.8.5 删除资料

- `DELETE /admin/course-materials/{id}`

### 5.9 课程评价管理

#### 5.9.1 评价分页列表

- `GET /admin/course-reviews`
- 参数：`pageNum` `pageSize` `courseId` `status` `score` `keyword`

#### 5.9.2 修改评价状态

- `PUT /admin/course-reviews/{id}/status`

```json
{
  "status": 1
}
```

#### 5.9.3 删除评价

- `DELETE /admin/course-reviews/{id}`

### 5.10 上传接口

上传成功返回 `UploadResult`：

```json
{
  "objectKey": "education-platform/materials/xxx.pdf",
  "url": "https://...",
  "originalFilename": "lesson.pdf",
  "size": 123456,
  "contentType": "application/pdf"
}
```

#### 5.10.1 上传课程资料

- `POST /admin/uploads/materials`
- 表单字段：`file`

#### 5.10.2 上传课程封面

- `POST /admin/uploads/course-covers`
- 表单字段：`file`

#### 5.10.3 上传视频

- `POST /admin/uploads/section-videos`
- 表单字段：`file`

#### 5.10.4 上传小节内容文件

- `POST /admin/uploads/section-contents`
- 表单字段：`file`
- 可选字段：`contentType`

### 5.11 管理端作业接口

#### 5.11.1 作业列表

- `GET /admin/course-tasks`
- 当前实现：占位接口，返回字符串 `course task list placeholder`

#### 5.11.2 新增作业

- `POST /admin/course-tasks`
- 当前控制器仅保留接口入口，具体业务未在该控制器中展开

## 6. 教师端接口

### 6.1 教师个人信息

#### 6.1.1 获取个人资料

- `GET /teacher/profile`

#### 6.1.2 更新个人资料

- `PUT /teacher/profile`

```json
{
  "name": "李老师",
  "mobile": "13800138000",
  "title": "高级讲师",
  "intro": "主讲 Java",
  "avatar": "https://...",
  "email": "teacher@test.com"
}
```

#### 6.1.3 修改密码

- `PUT /teacher/profile/password`

```json
{
  "oldPassword": "123456",
  "newPassword": "654321",
  "confirmPassword": "654321"
}
```

#### 6.1.4 上传头像

- `POST /teacher/uploads/avatar`
- 表单字段：`file`

### 6.2 教师课程管理

#### 6.2.1 课程分页列表

- `GET /teacher/courses`
- 参数：`pageNum` `pageSize` `title` `teacherId` `categoryLevel2Id` `publishStatus`

#### 6.2.2 课程详情

- `GET /teacher/courses/{id}`

#### 6.2.3 新增课程

- `POST /teacher/courses`
- 请求体同管理端课程新增

#### 6.2.4 更新课程

- `PUT /teacher/courses/{id}`

#### 6.2.5 修改发布状态

- `PUT /teacher/courses/{id}/publish-status`

#### 6.2.6 删除课程

- `DELETE /teacher/courses/{id}`

### 6.3 教师章节、小节、小节内容

#### 6.3.1 获取课程章节树

- `GET /teacher/courses/{courseId}/chapters/tree`

#### 6.3.2 新增章节

- `POST /teacher/courses/{courseId}/chapters`

#### 6.3.3 更新章节

- `PUT /teacher/chapters/{id}`

#### 6.3.4 删除章节

- `DELETE /teacher/chapters/{id}`

#### 6.3.5 新增小节

- `POST /teacher/chapters/{chapterId}/sections`

#### 6.3.6 更新小节

- `PUT /teacher/sections/{id}`

#### 6.3.7 删除小节

- `DELETE /teacher/sections/{id}`

#### 6.3.8 小节内容列表

- `GET /teacher/sections/{sectionId}/contents`

#### 6.3.9 小节内容详情

- `GET /teacher/section-contents/{id}`

#### 6.3.10 新增小节内容

- `POST /teacher/sections/{sectionId}/contents`

#### 6.3.11 更新小节内容

- `PUT /teacher/section-contents/{id}`

#### 6.3.12 删除小节内容

- `DELETE /teacher/section-contents/{id}`

### 6.4 教师资料管理

#### 6.4.1 资料分页列表

- `GET /teacher/course-materials`
- 参数：`pageNum` `pageSize` `courseId` `materialName` `materialType`

#### 6.4.2 资料详情

- `GET /teacher/course-materials/{id}`

#### 6.4.3 新增资料

- `POST /teacher/course-materials`
- 请求体同管理端资料新增

#### 6.4.4 更新资料

- `PUT /teacher/course-materials/{id}`

#### 6.4.5 删除资料

- `DELETE /teacher/course-materials/{id}`

### 6.5 教师作业管理

#### 6.5.1 作业分页列表

- `GET /teacher/course-tasks`
- 参数：`pageNum` `pageSize` `courseId` `title` `status`

#### 6.5.2 作业详情

- `GET /teacher/course-tasks/{id}`

#### 6.5.3 新增作业

- `POST /teacher/course-tasks`

```json
{
  "courseId": 1,
  "title": "第一周作业",
  "totalScore": 100,
  "passScore": 60,
  "startTime": "2026-06-17 09:00:00",
  "endTime": "2026-06-30 23:59:59",
  "allowRetakeCount": 3,
  "status": 1
}
```

#### 6.5.4 更新作业

- `PUT /teacher/course-tasks/{id}`

#### 6.5.5 删除作业

- `DELETE /teacher/course-tasks/{id}`

#### 6.5.6 作业题目列表

- `GET /teacher/course-tasks/{taskId}/questions`

#### 6.5.7 新增作业题目

- `POST /teacher/course-tasks/{taskId}/questions`

```json
{
  "questionType": 1,
  "stem": "什么是 Spring Boot？",
  "optionsJson": "[\"A\",\"B\",\"C\",\"D\"]",
  "answerJson": "[\"A\"]",
  "analysis": "解析内容",
  "score": 10,
  "sort": 1
}
```

#### 6.5.8 更新作业题目

- `PUT /teacher/task-questions/{id}`

#### 6.5.9 删除作业题目

- `DELETE /teacher/task-questions/{id}`

#### 6.5.10 作业提交列表

- `GET /teacher/course-tasks/{taskId}/submissions`

#### 6.5.11 作业提交详情

- `GET /teacher/task-submissions/{submissionId}`

#### 6.5.12 批改作业

- `PUT /teacher/task-submissions/{submissionId}/review`

```json
{
  "reviewComment": "总体完成较好",
  "questionScores": [
    {
      "questionId": 1,
      "score": 10
    }
  ]
}
```

### 6.6 教师考试管理

#### 6.6.1 考试分页列表

- `GET /teacher/course-exams`
- 参数：`pageNum` `pageSize` `courseId` `title` `status`

#### 6.6.2 考试详情

- `GET /teacher/course-exams/{id}`

#### 6.6.3 新增考试

- `POST /teacher/course-exams`

```json
{
  "courseId": 1,
  "title": "期末考试",
  "totalScore": 100,
  "passScore": 60,
  "startTime": "2026-06-20 09:00:00",
  "endTime": "2026-06-20 11:00:00",
  "durationMinutes": 120,
  "status": 1
}
```

#### 6.6.4 更新考试

- `PUT /teacher/course-exams/{id}`

#### 6.6.5 删除考试

- `DELETE /teacher/course-exams/{id}`

#### 6.6.6 考试题目列表

- `GET /teacher/course-exams/{examId}/questions`

#### 6.6.7 新增考试题目

- `POST /teacher/course-exams/{examId}/questions`
- 请求体同作业题目

#### 6.6.8 更新考试题目

- `PUT /teacher/exam-questions/{id}`

#### 6.6.9 删除考试题目

- `DELETE /teacher/exam-questions/{id}`

#### 6.6.10 考试提交列表

- `GET /teacher/course-exams/{examId}/submissions`

#### 6.6.11 考试提交详情

- `GET /teacher/exam-submissions/{submissionId}`

#### 6.6.12 批改考试

- `PUT /teacher/exam-submissions/{submissionId}/review`
- 请求体同作业批改

### 6.7 教师上传接口

#### 6.7.1 上传课程资料

- `POST /teacher/uploads/materials`
- 表单字段：`file`

#### 6.7.2 上传课程封面

- `POST /teacher/uploads/course-covers`
- 表单字段：`file`

#### 6.7.3 上传小节内容文件

- `POST /teacher/uploads/section-contents`
- 表单字段：`file`
- 可选字段：`contentType`

## 7. 学员端接口

### 7.1 学员个人中心

#### 7.1.1 获取个人资料

- `GET /member/profile`

#### 7.1.2 更新个人资料

- `PUT /member/profile`

```json
{
  "nickname": "小王",
  "realName": "王同学",
  "avatar": "https://...",
  "gender": 1,
  "birthday": "2000-01-01"
}
```

#### 7.1.3 修改手机号

- `PUT /member/profile/mobile`

```json
{
  "mobile": "13800138000"
}
```

#### 7.1.4 修改密码

- `PUT /member/profile/password`

```json
{
  "oldPassword": "123456",
  "newPassword": "654321",
  "confirmPassword": "654321"
}
```

#### 7.1.5 上传头像

- `POST /member/uploads/avatar`
- 表单字段：`file`

#### 7.1.6 上传社区图片

- `POST /member/uploads/community-images`
- 表单字段：`file`

### 7.2 我的课程

#### 7.2.1 已购课程列表

- `GET /member/courses`

#### 7.2.2 收藏课程列表

- `GET /member/courses/favorites`

#### 7.2.3 购买课程

- `POST /member/courses/{courseId}/purchase`

#### 7.2.4 退课

- `DELETE /member/courses/{courseId}/enroll`

#### 7.2.5 收藏课程

- `POST /member/courses/{courseId}/favorite`

#### 7.2.6 取消收藏课程

- `DELETE /member/courses/{courseId}/favorite`

### 7.3 学员作业

#### 7.3.1 课程作业列表

- `GET /member/courses/{courseId}/tasks`

#### 7.3.2 作业详情

- `GET /member/course-tasks/{taskId}`
- 可选参数：`startedAt`

#### 7.3.3 我的作业提交记录

- `GET /member/course-tasks/{taskId}/my-submissions`

#### 7.3.4 提交作业

- `POST /member/course-tasks/{taskId}/submissions`

```json
{
  "answersJson": "{\"1\":\"A\"}",
  "attachmentUrl": "https://...",
  "startedAt": "2026-06-17 10:00:00"
}
```

#### 7.3.5 任务中心列表

- `GET /member/tasks`

### 7.4 学员考试

#### 7.4.1 课程考试列表

- `GET /member/courses/{courseId}/exams`

#### 7.4.2 考试详情

- `GET /member/course-exams/{examId}`
- 可选参数：`startedAt`

#### 7.4.3 我的考试提交记录

- `GET /member/course-exams/{examId}/my-submissions`

#### 7.4.4 提交考试

- `POST /member/course-exams/{examId}/submissions`
- 请求体同作业提交

### 7.5 学员课程评价

#### 7.5.1 提交课程评价

- `POST /member/course-reviews`

```json
{
  "courseId": 1,
  "score": 5,
  "content": "课程很不错",
  "anonymousFlag": 0
}
```

#### 7.5.2 删除自己的课程评价

- `DELETE /member/course-reviews/{courseId}`

#### 7.5.3 获取我的课程评价摘要

- `GET /member/course-reviews/my-summary?courseId=1`

### 7.6 学员社区

#### 7.6.1 我的帖子分页

- `GET /member/community/posts/mine`
- 参数：`pageNum` `pageSize` `keyword` `sortMode`

#### 7.6.2 我的收藏帖子分页

- `GET /member/community/posts/favorites`
- 参数：`pageNum` `pageSize` `keyword` `sortMode`

#### 7.6.3 发布帖子

- `POST /member/community/posts`

```json
{
  "title": "学习心得",
  "content": "今天学完了第一章",
  "imageUrls": [
    "https://..."
  ]
}
```

#### 7.6.4 评论帖子

- `POST /member/community/posts/{postId}/comments`

```json
{
  "parentId": null,
  "replyToMemberId": null,
  "content": "写得很好"
}
```

#### 7.6.5 删除帖子

- `DELETE /member/community/posts/{postId}`

#### 7.6.6 删除评论

- `DELETE /member/community/posts/comments/{commentId}`

#### 7.6.7 点赞帖子

- `POST /member/community/posts/{postId}/like`

#### 7.6.8 取消点赞

- `DELETE /member/community/posts/{postId}/like`

#### 7.6.9 收藏帖子

- `POST /member/community/posts/{postId}/favorite`

#### 7.6.10 取消收藏帖子

- `DELETE /member/community/posts/{postId}/favorite`

## 8. 门户端接口

### 8.1 课程与分类

#### 8.1.1 门户课程分页列表

- `GET /portal/courses`
- 参数：`pageNum` `pageSize` `title` `teacherId` `categoryLevel2Id` `publishStatus`

#### 8.1.2 门户 Banner 列表

- `GET /portal/courses/banners`

#### 8.1.3 门户课程详情

- `GET /portal/courses/{id}`

#### 8.1.4 门户课程分类树

- `GET /portal/course-categories/tree`

#### 8.1.5 门户课程章节树

- `GET /portal/courses/{courseId}/chapters/tree`

#### 8.1.6 门户课程资料列表

- `GET /portal/courses/{courseId}/materials`

### 8.2 小节内容预览

#### 8.2.1 小节内容列表

- `GET /portal/sections/{sectionId}/contents`

#### 8.2.2 PDF 预览

- `GET /portal/sections/contents/{id}/preview`
- 返回：`application/pdf` 二进制流
- 说明：仅 `contentType=PDF` 时可预览

### 8.3 课程评价展示

#### 8.3.1 课程评价分页

- `GET /portal/courses/{courseId}/reviews`
- 参数：`pageNum` `pageSize` `status` `score` `keyword`

#### 8.3.2 课程评价摘要

- `GET /portal/courses/{courseId}/review-summary`

#### 8.3.3 评价头像代理

- `GET /portal/courses/reviews/{reviewId}/avatar`
- 返回：图片二进制流
- 说明：该接口不是 `Result` 包装，直接返回图片内容

### 8.4 社区门户

#### 8.4.1 社区帖子分页

- `GET /portal/community/posts`
- 参数：`pageNum` `pageSize` `keyword` `sortMode`

#### 8.4.2 帖子详情

- `GET /portal/community/posts/{postId}`

#### 8.4.3 帖子评论分页

- `GET /portal/community/posts/{postId}/comments`
- 参数：`pageNum` `pageSize`

## 9. 前端调用补充说明

- 前端 Axios 基础地址为：`/api/v1`
- 前端在请求头中自动附带：`Authorization: Bearer <token>`
- 当前前端约定：当返回 `code != 0` 时统一视为失败
- 当接口返回 `401/403` 时，前端会自动清空登录状态并跳转到登录页
