# 交流社区页面规划

## 1. 目标

为会员端补齐“交流社区”能力，支持：

- 发帖
- 查看帖子列表
- 进入帖子详情
- 评论与回复
- 点赞
- 收藏

本期只规划会员端使用链路，不包含标签体系、推荐算法、审核后台复杂流程。帖子卡片底部只展示：

- 评论数
- 点赞数
- 发布时间

## 2. 参考现状

当前会员端顶部导航已经预留了“交流社区”入口，出现在：

- `frontend/src/views/member/MemberHomeView.vue`
- `frontend/src/views/member/MemberCourseListView.vue`
- `frontend/src/views/member/MemberTaskCenterView.vue`

现有前端技术栈和页面风格：

- Vue 3 `script setup`
- Vue Router
- Element Plus
- 会员端页面普遍采用“顶部导航 + 中心内容区”的结构

因此社区页面建议沿用同一套导航和视觉语言，避免做成另一套产品。

## 3. 页面范围

建议拆成 2 个会员端页面：

1. 社区列表页：`/member/community`
2. 帖子详情页：`/member/community/:postId`

可选补充：

3. 发帖弹窗或独立页：`/member/community/create`
4. 我的帖子/我的收藏：后续二期再补

## 4. 列表页方案

### 4.1 页面结构

参照图 1，列表页采用单列信息流：

- 顶部沿用会员端现有导航
- 主体区域宽度与课程页保持一致
- 顶部操作区
  - 页面标题“交流社区”
  - 发帖按钮
  - 搜索框
  - 排序切换：最新 / 最热
- 帖子列表区
  - 每条帖子为卡片
  - 左侧为作者信息、标题、正文摘要、图片
  - 底部为互动信息

### 4.2 帖子卡片字段

每张帖子卡片展示：

- 作者头像
- 作者昵称
- 帖子标题
- 帖子正文摘要
- 最多 1 张封面图或 3 宫格缩略图
- 发布时间
- 评论数
- 点赞数

本期不展示：

- 标签
- 转发
- 打赏
- 复杂话题分类

### 4.3 列表交互

- 点击帖子卡片主体进入详情页
- 点击点赞按钮直接切换点赞状态并更新数量
- 点击收藏按钮直接切换收藏状态
- 点击评论按钮进入详情页并自动聚焦评论输入框
- 点击发帖按钮打开发帖弹窗

### 4.4 排序建议

列表页先支持 2 种排序：

- 最新：按 `created_at desc`
- 最热：按 `like_count desc, comment_count desc, created_at desc`

## 5. 详情页方案

### 5.1 布局

参照图 2，采用左右双栏：

- 左侧：帖子正文
- 右侧：评论区

桌面端建议宽度：

- 左侧 `minmax(0, 1fr)`
- 右侧固定 `380px ~ 420px`

### 5.2 左侧帖子区

左侧展示完整帖子内容：

- 返回按钮
- 作者信息
- 帖子标题
- 发布时间
- 正文内容
- 图片列表
- 底部互动栏

底部互动栏只保留 3 个动作：

- 点赞
- 收藏
- 评论

其中“评论”按钮行为与点击评论输入框一致：

- 将页面定位到评论输入区域
- 自动聚焦输入框

### 5.3 右侧评论区

右侧评论区需要满足两个要求：

1. 可单独滚动
2. 页面滚动时保持跟随

建议实现：

- 外层使用 `position: sticky`
- `top` 对齐顶部导航下方，例如 `top: 80px`
- 右栏整体高度使用 `height: calc(100vh - 96px)`
- 评论列表容器使用 `overflow-y: auto`

结构建议：

- 评论标题：`全部评论 X`
- 评论输入区
- 评论列表
- 分页或“加载更多”

### 5.4 评论展示规则

每条评论展示：

- 评论人头像
- 评论人昵称
- 评论时间
- 评论内容
- 点赞数可先不做
- 回复按钮

建议支持 1 层回复：

- 一级评论
- 二级回复列表

这样能覆盖图 1 中“回复某人”的常见场景，但不会把数据结构做得太重。

### 5.5 移动端降级

移动端不建议保留双栏。改为单列：

- 上方帖子正文
- 下方评论区
- 底部固定操作条：点赞 / 收藏 / 评论

## 6. 发帖方案

### 6.1 交互形式

首版建议用弹窗，不单独开页面，开发成本更低。

弹窗字段：

- 标题
- 正文
- 配图上传，最多 9 张

编辑器建议：

- 标题：`el-input`
- 正文：先用普通多行输入框或现有 `RichTextEditor`

如果目标更偏“社区动态”而不是“长文帖子”，首版建议先不用富文本，直接用纯文本 + 图片，成本最低，内容展示也更稳定。

### 6.2 发布校验

- 标题必填，长度建议 `1-80`
- 正文必填，长度建议 `1-5000`
- 图片可选

## 7. 前端实现建议

## 7.1 路由

在 `frontend/src/router/index.js` 增加：

```js
{
  path: '/member/community',
  name: 'MemberCommunity',
  component: () => import('@/views/member/MemberCommunityView.vue'),
  meta: { title: '交流社区', roles: ['MEMBER'] }
},
{
  path: '/member/community/:postId',
  name: 'MemberCommunityPostDetail',
  component: () => import('@/views/member/MemberCommunityPostDetailView.vue'),
  meta: { title: '帖子详情', roles: ['MEMBER'] }
}
```

并把 3 个会员页面顶部导航中的 `community` 入口接到 `/member/community`。

## 7.2 视图文件建议

新增：

- `frontend/src/views/member/MemberCommunityView.vue`
- `frontend/src/views/member/MemberCommunityPostDetailView.vue`

可复用组件：

- `frontend/src/views/member/components/CommunityComposerDialog.vue`
- `frontend/src/views/member/components/CommunityPostCard.vue`
- `frontend/src/views/member/components/CommunityCommentPanel.vue`
- `frontend/src/views/member/components/CommunityCommentItem.vue`

## 7.3 API 文件建议

新增：

- `frontend/src/api/community.js`

建议封装：

```js
getCommunityPostList(params)
getCommunityPostDetail(id)
createCommunityPost(data)
createCommunityComment(postId, data)
toggleCommunityPostLike(postId)
toggleCommunityPostFavorite(postId)
getCommunityCommentList(postId, params)
```

## 7.4 前端状态建议

帖子对象建议返回这些字段，尽量一次满足列表和详情：

```json
{
  "id": 101,
  "authorId": 1,
  "authorName": "NORMET",
  "authorAvatar": "https://...",
  "authorLevel": 20,
  "title": "开罗游戏开发，《海贼王》IP 新游 2026 年 10 月发售",
  "content": "帖子正文",
  "images": ["https://..."],
  "commentCount": 72,
  "likeCount": 254,
  "favoriteCount": 12,
  "liked": true,
  "favorited": false,
  "createdAt": "2026-06-10 12:00:00"
}
```

评论对象建议：

```json
{
  "id": 1001,
  "postId": 101,
  "memberId": 8,
  "memberName": "用户名",
  "memberAvatar": "https://...",
  "content": "评论内容",
  "parentId": 0,
  "replyToMemberId": null,
  "replyToMemberName": null,
  "replyCount": 2,
  "createdAt": "2026-06-10 12:30:00",
  "children": []
}
```

## 8. 后端数据设计建议

## 8.1 表设计

建议新增 4 张核心表。

### `community_post`

字段建议：

- `id`
- `member_id`
- `title`
- `content`
- `status`
- `comment_count`
- `like_count`
- `favorite_count`
- `view_count`
- `created_at`
- `updated_at`
- `created_by`
- `updated_by`

说明：

- `status` 先支持 `0待审核 1已发布 2已删除`
- 计数字段做冗余，避免每次列表都实时聚合

### `community_post_image`

字段建议：

- `id`
- `post_id`
- `image_url`
- `sort`

说明：

- 用于多图帖子
- 与帖子正文拆表，后续扩展更稳定

### `community_comment`

字段建议：

- `id`
- `post_id`
- `member_id`
- `parent_id`
- `reply_to_member_id`
- `content`
- `status`
- `created_at`
- `updated_at`

说明：

- `parent_id = 0` 表示一级评论
- 二级回复直接挂到一级评论下

### `community_post_action`

字段建议：

- `id`
- `post_id`
- `member_id`
- `action_type`
- `created_at`

唯一索引建议：

- `(post_id, member_id, action_type)`

说明：

- `action_type`: `LIKE` / `FAVORITE`
- 用一张行为表即可覆盖点赞和收藏，避免重复建表

## 8.2 索引建议

### `community_post`

- 索引：`(status, created_at)`
- 索引：`(status, like_count, comment_count, created_at)`
- 索引：`(member_id, created_at)`

### `community_comment`

- 索引：`(post_id, parent_id, created_at)`
- 索引：`(member_id, created_at)`

### `community_post_action`

- 唯一索引：`(post_id, member_id, action_type)`
- 索引：`(member_id, action_type, created_at)`

## 9. 后端接口建议

建议放在新模块 `community` 下，接口风格延续现有 `member / portal` 分层。

### 9.1 门户帖子接口

- `GET /api/v1/portal/community/posts`
- `GET /api/v1/portal/community/posts/{id}`
- `GET /api/v1/portal/community/posts/{id}/comments`

### 9.2 会员交互接口

- `POST /api/v1/member/community/posts`
- `POST /api/v1/member/community/posts/{id}/comments`
- `POST /api/v1/member/community/posts/{id}/like`
- `DELETE /api/v1/member/community/posts/{id}/like`
- `POST /api/v1/member/community/posts/{id}/favorite`
- `DELETE /api/v1/member/community/posts/{id}/favorite`

### 9.3 详情返回建议

帖子详情接口直接补充：

- `liked`
- `favorited`
- `commentCount`
- `likeCount`
- `favoriteCount`

这样前端不用再额外查状态接口。

## 10. 关键交互细节

### 10.1 点赞和收藏

建议用“显式新增 / 显式取消”，不要做单个 toggle 接口。

原因：

- 语义更清楚
- 幂等更好处理
- 更适合后端统计

### 10.2 评论按钮行为

无论是：

- 点击帖子底部评论按钮
- 点击详情页底部评论按钮
- 点击右侧输入框

都统一触发：

- 打开评论输入区
- 聚焦输入框
- 如在详情页则滚动到评论输入框附近

### 10.3 评论区跟随

桌面端建议：

- 页面整体滚动
- 右栏 `sticky`
- 评论列表内部滚动

不要让整页和评论列表同时承担内容高度，否则滚动体验会很乱。

### 10.4 计数一致性

发布评论、点赞、取消点赞、收藏、取消收藏时，需要同步维护帖子计数：

- `comment_count`
- `like_count`
- `favorite_count`

建议后端在事务里更新，前端只做乐观更新。

## 11. 实施顺序

建议按下面顺序推进。

### 第一阶段：最小可用版

- 社区列表页
- 帖子详情页
- 发帖
- 评论
- 点赞
- 收藏

### 第二阶段：体验补强

- 评论回复
- 图片宫格
- 发帖草稿
- 我的帖子 / 我的收藏

### 第三阶段：治理能力

- 审核状态
- 删除/屏蔽
- 举报
- 敏感词

## 12. 风险与取舍

### 12.1 首版不建议上富文本

原因：

- XSS 和内容清洗成本高
- 样式兼容更复杂
- 评论区和列表摘要也更难统一

首版用纯文本 + 图片，能更快落地。

### 12.2 评论层级不要做太深

建议只做一级评论 + 一级回复。

原因：

- UI 更稳定
- SQL 更简单
- 更符合当前项目复杂度

### 12.3 热门排序不要过度设计

首版直接按：

- 点赞数
- 评论数
- 发布时间

即可，不需要引入复杂热度公式。

## 13. 推荐落地结论

如果按当前项目节奏，我建议这样定版：

1. 会员端新增 `/member/community` 和 `/member/community/:postId`
2. 列表页采用单列信息流，卡片底部只放评论数、点赞数、发布时间
3. 详情页采用“左帖子 + 右评论”的双栏布局
4. 右侧评论区使用 `sticky + 独立滚动`
5. 动作按钮只保留点赞、收藏、评论
6. 评论按钮与输入框点击统一聚焦评论框
7. 后端使用 `community_post / community_post_image / community_comment / community_post_action` 四表方案
8. 首版只做纯文本 + 图片，不做标签、不做复杂富文本

这个方案和你给的参考图接近，同时能和当前项目的 Vue + Element Plus 结构顺滑接上。
