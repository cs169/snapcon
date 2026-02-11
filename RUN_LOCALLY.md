# SnapCon 本地运行指南

本仓库是一个 **Ruby on Rails** 网页应用（SnapCon/OSEM），使用 **PostgreSQL** 数据库。

---

## 最快方式：一键启动（推荐）

**先安装好**：Ruby 3.3.8、Node.js 16+、PostgreSQL，并确保 PostgreSQL 服务已启动。

在项目根目录打开 **PowerShell**，执行：

```powershell
.\start.ps1
```

首次运行会安装依赖、提示输入一次 PostgreSQL 密码并初始化数据库，然后自动启动网页；之后再次运行会直接启动。浏览器打开 **http://localhost:3000** 即可。

若提示“无法加载，因为在此系统上禁止运行脚本”，先执行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

然后再运行 `.\start.ps1`。

---

## 一、需要提前安装的软件

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| **Ruby** | 3.3.8 | 建议用 [RubyInstaller](https://rubyinstaller.org/)（Windows）或 rbenv/RVM（Mac/Linux） |
| **Node.js** | 16.x（建议 16.20.2） | 从 [nodejs.org](https://nodejs.org/) 安装 LTS 版本 |
| **PostgreSQL** | 12+ | [PostgreSQL 下载](https://www.postgresql.org/download/)；Windows 可用 [EnterpriseDB 安装包](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads) |
| **Git** | 任意较新版本 | 已 clone 则无需再装 |

### Windows 用户

- **Ruby**：安装 [Ruby+Devkit 3.3.x](https://rubyinstaller.org/downloads/)，安装时勾选 “MSYS2” 以便编译原生扩展。
- **PostgreSQL**：安装时记住你设置的 **postgres 用户密码**，后面 `.env` 里要用。
- 建议在 **PowerShell** 或 **CMD** 中执行下面所有命令（或使用 WSL2）。

---

## 二、命令行步骤（在项目根目录执行）

### 1. 进入项目目录

```powershell
cd c:\Users\31644\Desktop\snapcon
```

### 2. 安装 Node 依赖

```powershell
npm install
```

### 3. 配置 Bundler（只装开发/测试用的 gem）

```powershell
bundle config set --local without production
bundle config set --local path vendor/bundle
```

### 4. 安装 Ruby 依赖

```powershell
bundle install
```

如遇编译错误，确保已安装 RubyInstaller 的 Devkit 并执行过 `ridk enable`。

### 5. 配置环境变量

项目已提供 `.env` 模板。若没有 `.env`，请复制一份：

```powershell
copy dotenv.example .env
```

**必须修改**：用记事本或 VS Code 打开 `.env`，至少设置数据库相关变量（把下面的值改成你本机 PostgreSQL 的用户名和密码）：

```env
OSEM_DB_HOST=localhost
OSEM_DB_PORT=5432
OSEM_DB_USER=postgres
OSEM_DB_PASSWORD=你的PostgreSQL密码
OSEM_DB_NAME=osem_development
SECRET_KEY_BASE=请用下一步的命令生成
```

生成 `SECRET_KEY_BASE`：

```powershell
bundle exec rake secret
```

把输出的一长串字符复制到 `.env` 的 `SECRET_KEY_BASE=` 后面并保存。

### 6. 创建并初始化数据库

```powershell
bundle exec rake db:create
bundle exec rake db:setup
```

若 `db:create` 报错 “role/postgres 不存在”，请在 PostgreSQL 里先建好对应用户和数据库，或把 `.env` 里的 `OSEM_DB_USER` / `OSEM_DB_PASSWORD` 改成你实际使用的账号。

### 7. （可选）生成演示数据

```powershell
bundle exec rake data:demo
```

### 8. 启动网页服务

只启动网站（不跑后台任务）：

```powershell
bundle exec rails server
```

或指定端口（例如 3000）：

```powershell
bundle exec rails server -p 3000
```

在浏览器打开：**http://localhost:3000**。

若要同时跑后台任务（发邮件、定时任务等），需要先安装 [Foreman](https://github.com/ddollar/foreman) 或 [Overmind](https://github.com/DarthSim/overmind)，然后：

```powershell
bundle exec foreman start -f Procfile
```

---

## 三、用 Docker 跑（可选）

若本机已安装 **Docker Desktop**，可以用 Docker 避免单独装 Ruby/PostgreSQL：

1. 在项目根目录创建 `.env`（同上，至少设置 `OSEM_DB_PASSWORD` 和 `SECRET_KEY_BASE`）。
2. 使用 docker-compose 时，数据库主机名是服务名，在 `.env` 里设置：
   - `OSEM_DB_HOST=database`
   - `OSEM_DB_USER=postgres`
   - `OSEM_DB_PASSWORD=你设置的密码`
   - `OSEM_DB_NAME=postgres`（或与镜像内一致）
3. 构建并启动：
   ```powershell
   docker-compose up --build
   ```
4. 首次需要初始化数据库（在另一个终端）：
   ```powershell
   docker-compose run --rm osem bundle exec rake db:bootstrap
   ```
5. 浏览器访问：**http://localhost:3000**。

---

## 四、常见问题

- **`bundle install` 报错**：确认 Ruby 版本为 3.3.8（`ruby -v`），并已安装 Devkit（Windows）。
- **数据库连接失败**：检查 PostgreSQL 是否已启动，`.env` 中 `OSEM_DB_*` 是否与本地 postgres 用户/密码一致。
- **端口被占用**：换端口，例如 `rails server -p 3001`。
- **没有 `.env`**：执行 `copy dotenv.example .env` 后按上面说明修改。

按上述步骤完成后，应能在本机通过浏览器访问 SnapCon 网页。
