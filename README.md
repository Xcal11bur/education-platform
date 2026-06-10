# Education Platform

一个前后端分离的在线教育平台示例项目，包含课程展示、后台管理、教师端、学员端、作业考试、课程资料、社区互动等模块。

仓库当前采用：

- `frontend/`：Vue 3 + Vite 前端
- `backend/`：Spring Boot 3 + MyBatis-Plus 后端

## 功能概览

- 管理端：课程、章节、小节、资料、分类、教师、学员、评论、Banner 管理
- 教师端：课程维护、章节内容维护、作业与考试管理、资料上传、个人信息维护
- 学员端：注册登录、选课、学习任务、考试提交、评论、社区互动、个人中心
- 公共端：课程列表、课程详情、分类树、章节预览、评论展示

## 技术栈

### Frontend

- Vue 3
- Vite
- Vue Router
- Pinia
- Element Plus
- Axios
- Tiptap

### Backend

- Java 17
- Spring Boot 3.3
- Spring Security
- MyBatis-Plus
- MySQL 8
- JWT
- Springdoc OpenAPI
- 阿里云 OSS
- Kaptcha

## 目录结构

```text
education-plateform/
├─ backend/                    # Spring Boot 后端
│  ├─ db/
│  │  └─ education_platform.sql
│  ├─ src/main/java/
│  ├─ src/main/resources/
│  │  └─ application.yml
│  └─ pom.xml
├─ frontend/                   # Vue 前端
│  ├─ src/
│  ├─ public/
│  ├─ package.json
│  └─ vite.config.js
└─ README.md
```

## 运行要求

- Node.js 18+
- npm 9+
- Java 17
- Maven 3.9+
- MySQL 8.0

## 快速开始

### 1. 导入数据库

项目提供了数据库结构和示例数据脚本：

- [backend/db/education_platform.sql](/D:/Files/myCode/education-plateform/backend/db/education_platform.sql)

先在 MySQL 中创建数据库：

```sql
CREATE DATABASE education_platform
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
```

然后导入脚本。

说明：

- 脚本内包含示例数据。
- 如果你准备将项目对外部署，导入后请自行重置示例账号密码，不要直接使用库内默认演示数据。

### 2. 配置环境变量

至少需要配置：

- `DB_PASSWORD`：数据库密码，必填
- `JWT_SECRET`：JWT 密钥，必填，建议 32 位以上随机字符串

常用可选变量如下：

| 变量名 | 是否必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `DB_URL` | 否 | `jdbc:mysql://localhost:3306/education_platform?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai` | MySQL 连接串 |
| `DB_USERNAME` | 否 | `root` | 数据库用户名 |
| `DB_PASSWORD` | 是 | 无 | 数据库密码 |
| `JWT_SECRET` | 是 | 无 | JWT 密钥，长度至少 32 |
| `LOGIN_CAPTCHA_ENABLED` | 否 | `true` | 是否启用登录验证码 |
| `SPRINGDOC_ENABLED` | 否 | `false` | 是否启用 Swagger / OpenAPI |
| `OSS_ENDPOINT` | 否 | `oss-cn-beijing.aliyuncs.com` | OSS Endpoint |
| `OSS_BUCKET_NAME` | 否 | `education-platform-333` | OSS Bucket 名称 |
| `OSS_ACCESS_KEY_ID` | 否 | 空 | OSS Access Key ID |
| `OSS_ACCESS_KEY_SECRET` | 否 | 空 | OSS Access Key Secret |
| `OSS_PUBLIC_BASE_URL` | 否 | `https://education-platform-333.oss-cn-beijing.aliyuncs.com` | OSS 公网访问前缀 |
| `OSS_BASE_PATH` | 否 | `education-platform/materials` | OSS 存储基础路径 |

Windows PowerShell 示例：

```powershell
[Environment]::SetEnvironmentVariable("DB_PASSWORD", "your-db-password", "User")
[Environment]::SetEnvironmentVariable("JWT_SECRET", "replace-with-a-random-string-at-least-32-chars", "User")
```

如果还需要显式设置用户名：

```powershell
[Environment]::SetEnvironmentVariable("DB_USERNAME", "root", "User")
```

设置完成后请重启终端或 IDE，再启动后端。

### 3. 启动后端

进入后端目录：

```powershell
cd backend
```

运行：

```powershell
mvn spring-boot:run
```

默认端口：

- `8080`

### 4. 启动前端

进入前端目录：

```powershell
cd frontend
```

安装依赖：

```powershell
npm install
```

启动开发环境：

```powershell
npm run dev
```

默认端口：

- `5173`

开发代理已配置在 [frontend/vite.config.js](/D:/Files/myCode/education-plateform/frontend/vite.config.js)，`/api` 会代理到 `http://localhost:8080`。

## 构建

### 前端构建

```powershell
cd frontend
npm run build
```

### 后端测试

```powershell
cd backend
mvn test
```

## 接口文档

Swagger / OpenAPI 默认关闭。

如果本地需要启用，请设置：

```powershell
[Environment]::SetEnvironmentVariable("SPRINGDOC_ENABLED", "true", "User")
```

然后重启后端，访问：

- `http://localhost:8080/swagger-ui.html`
- `http://localhost:8080/v3/api-docs`

## 安全说明

开源或部署前建议注意以下事项：

- 不要把数据库密码、JWT 密钥、OSS 密钥写入 Git。
- `JWT_SECRET` 现在是必填项，且应使用高强度随机字符串。
- 登录验证码默认开启，避免公开环境下被低成本爆破。
- Swagger 默认关闭，生产环境不要随意对外开放。
- 如果导入了示例 SQL，请及时重置示例账号密码。
- 如果使用 OSS 公网读，请评估文件类型白名单和访问策略。

## 常见问题

### 1. 环境变量已经配置，但后端仍然读取不到

常见原因是环境变量配置后，启动后端的终端或 IDE 没有重启。

处理方式：

- 关闭当前终端
- 重启 IDEA / VS Code
- 重新启动后端

### 2. 后端启动时报 `JWT_SECRET` 相关错误

原因通常是：

- 没有设置 `JWT_SECRET`
- `JWT_SECRET` 长度不足 32

请重新设置后重启。

### 3. 登录接口提示验证码错误

默认情况下登录验证码已开启。请先调用验证码接口获取 `captchaKey` 和图片，再带上验证码登录。

### 4. 上传接口返回 OSS 配置不完整

这是因为未配置以下变量中的一个或多个：

- `OSS_ACCESS_KEY_ID`
- `OSS_ACCESS_KEY_SECRET`
- `OSS_BUCKET_NAME`
- `OSS_ENDPOINT`

## 当前仓库状态说明

本仓库当前更适合作为学习、演示或二次开发基础项目使用。

如果你准备继续完善，建议优先补充：

- 更完整的初始化文档
- 角色权限回归测试
- 数据初始化脚本说明
- Docker / Compose 部署方案
- CI 配置

## License

当前仓库尚未声明许可证。
