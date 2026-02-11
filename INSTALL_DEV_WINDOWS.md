# Windows 开发环境安装指南

在运行 SnapCon 前，需要安装下面三个软件。全部用**默认安装**即可，安装时注意记下 **PostgreSQL 的密码**。

---

## 1. 安装 Ruby 3.3.8

### 步骤

1. 打开：**https://rubyinstaller.org/downloads/**
2. 在 **Ruby+Devkit 3.3.x** 那一行，选 **x64** 的安装包下载（例如 `rubyinstaller-devkit-3.3.6-1-x64.exe`，版本号可能略不同，选 3.3.x 即可）。
3. 双击运行安装程序：
   - 勾选 **“Add Ruby executables to your PATH”**
   - 点击 **Install**，完成安装。
4. 安装结束时弹出一个**黑色命令行窗口**，会问你要装哪些组件：
   - 输入 **`3`** 回车（安装 MSYS2 的 base 工具，用于编译扩展）。
   - 等待安装完成，然后关掉该窗口。

### 验证

打开**新的** PowerShell 或 CMD，输入：

```powershell
ruby -v
```

应显示类似：`ruby 3.3.x`。

---

## 2. 安装 Node.js（建议 16 或 18 LTS）

### 步骤

1. 打开：**https://nodejs.org/**
2. 下载 **LTS** 版本（例如 18.x 或 20.x，均可；项目推荐 16，但 18/20 一般也兼容）。
3. 双击运行安装程序，一路 **Next**，默认选项即可。
4. 如有勾选 “Automatically install necessary tools”，可勾上（会装 Python 等，可选）。

### 验证

打开**新的** PowerShell，输入：

```powershell
node -v
npm -v
```

应分别显示版本号（如 `v18.x.x` 和 `10.x.x`）。

---

## 3. 安装 PostgreSQL

### 步骤

1. 打开：**https://www.postgresql.org/download/windows/**  
   或直接到：**https://www.enterprisedb.com/downloads/postgres-postgresql-downloads**
2. 选 **Windows x86-64**，下载**最新 15 或 16**（或 12+ 任一版本）的安装包。
3. 双击运行安装程序：
   - 安装路径可默认，直接 **Next**。
   - **Components**：保持默认（勾选 PostgreSQL Server、Command Line Tools 等），**Next**。
   - **Data Directory**：默认即可，**Next**。
   - **超级用户 (postgres) 密码**：**这里设置的密码务必记住**，后面运行 `.\start.ps1` 时要用。
   - **Port**：保持 **5432**，**Next**。
   - 其余默认，最后 **Finish** 完成安装。
4. 安装完成后，PostgreSQL 会作为服务运行；若安装时勾选了 “Launch Stack Builder”，可以关掉，不必配置。

### 验证

- 打开 **服务**（Win + R 输入 `services.msc`），在列表里找到 **postgresql-x64-xx**，状态应为 **正在运行**。
- 或在 PowerShell 里（若 PATH 里有 `psql`）执行：
  ```powershell
  psql -U postgres -c "SELECT 1"
  ```
  会提示输入刚才设的 postgres 密码，能执行成功即可。

---

## 全部装好后

1. **关掉所有旧的 PowerShell/CMD 窗口**，新开一个。
2. 进入项目目录：
   ```powershell
   cd c:\Users\31644\Desktop\snapcon
   ```
3. 运行一键启动脚本：
   ```powershell
   .\start.ps1
   ```
4. 首次会提示输入 **PostgreSQL 的 postgres 用户密码**，输入安装时设的密码即可。
5. 浏览器打开：**http://localhost:3000**。

若某一步报错，把完整报错信息贴出来即可继续排查。
