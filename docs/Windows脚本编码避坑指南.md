# Windows 脚本编码避坑指南

> 本部署系统实战踩过的全部编码坑（2026-08 一个月内 5 个），统一记录。
> **核心规律：Windows 各脚本引擎默认编码各不相同，写脚本前先确认目标引擎的解析方式。**

---

## 一、核心规律表（背下来）

| 脚本类型 | 引擎默认解析 | 正确做法 | 错误后果 |
|---------|-------------|---------|---------|
| `.cmd` / `.bat` | cmd.exe → **GBK/ANSI 代码页** | **纯 ASCII**（禁止中文注释）| UTF-8 中文被打碎成可执行垃圾，整批解析崩掉，命令不执行 |
| `.vbs` | WScript → **ANSI** | **纯 ASCII** | UTF-8 中文报语法错误（"缺少对象"）|
| `.ps1`（PowerShell 5.1）| **ANSI**（除非有 BOM）| **UTF-8 with BOM** | 无 BOM 的 UTF-8 中文被 ANSI 解析乱码截断字符串，语法报错 |
| `.ps1`（PowerShell 7+）| UTF-8 无 BOM | UTF-8 无 BOM 即可 | — |
| Node 进程输出 | **UTF-8** | 用 cmd /c 字节级重定向 | PowerShell 管道按 GBK 解码 → 日志乱码 |

**一句话规则**：
- `.cmd/.bat/.vbs` → **纯 ASCII**
- `.ps1`（给 5.1 跑）→ **UTF-8 with BOM**
- 日志/文件 → **Node 输出保持 UTF-8，用 cmd /c 重定向**

---

## 二、五个实战坑详情

### 坑 1：.cmd 中文注释打碎解析（最严重，2026-08-26）

**症状**：watcher 显示 "restart script executed"，但旧进程永远不被杀，新进程不启动。
**根因**：restart.cmd 含 UTF-8 中文注释 → cmd.exe 按 GBK 读取 → 中文被误解码，注释行打碎成可执行垃圾（如 `'de.exe`）→ **整批文件解析崩掉，kill 行从未执行**。
**修复**：.cmd 文件纯 ASCII。
**注意**：`chcp 65001` 无效——它要等文件解析后才生效，而解析已经崩了。

### 坑 2：.vbs 中文报语法错误（2026-08-14）

**症状**：双击报"第 2 行 23 字符语法错误"或"缺少对象 ws"。
**根因**：UTF-8 中文在 VBScript（ANSI 解析）下乱码截断。
**修复**：.vbs 纯 ASCII。
**附带**：vbs 字符串必须**双引号**（单引号是注释符）。

### 坑 3：.ps1 无 BOM 中文乱码（2026-08-14 多次）

**症状**：`powershell -File xxx.ps1` 报"字符串缺少终止符"、中文全乱。
**根因**：PowerShell 5.1 按 ANSI 读无 BOM 的 UTF-8 文件。
**修复**：文件存为 **UTF-8 with BOM**（PowerShell 一行转换）：
```powershell
$c = [System.IO.File]::ReadAllText('in.ps1', [System.Text.Encoding]::UTF8)
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText('out.ps1', $c, $utf8Bom)
```

### 坑 4：Node 日志中文乱码（2026-08-14）

**症状**：server.log 里"自动补单"变"鑷姩琛ュ崟"。
**根因**：Node 输出 UTF-8，PowerShell 管道（`| Out-File`）按 GBK 解码。
**修复**：用 cmd /c 字节级重定向（绕过 PowerShell 解码）：
```powershell
$cmdLine = '"' + $nodeCmd + '" server/index.js >> "' + $logFile + '" 2>&1'
cmd /c $cmdLine
```

### 坑 5：终端显示乱码 ≠ 文件内容错（区分判断）

**症状**：`cat` 中文显示乱码。
**判断**：先确认是"文件内容错"还是"终端显示错"——用 `Get-Content -Encoding UTF8` 读，或查 hex 字节。**很多"乱码"只是 Git Bash/终端按 GBK 显示 UTF-8 内容**，文件本身是好的。

---

## 三、检测命令

```bash
# 检查文件是否有非 ASCII 字节（含中文即报）
LC_ALL=C grep -nP "[^\x00-\x7F]" <文件> && echo "⚠️ 有非 ASCII" || echo "✅ 纯 ASCII"

# 检查 UTF-8 BOM（前 3 字节 EF BB BF）
head -c 3 <文件> | od -An -tx1

# PowerShell 检查 BOM
powershell -Command "$b=[System.IO.File]::ReadAllBytes('x.ps1')[0..2]; $b -join ','"
```

---

## 四、写脚本时的统一决策

| 场景 | 编码选择 |
|------|---------|
| 新建 .cmd / .bat | 纯 ASCII（英文注释）|
| 新建 .vbs | 纯 ASCII（英文注释）|
| 新建 .ps1（可能在 5.1 跑）| UTF-8 with BOM |
| 新建 .ps1（只给 pwsh 7 跑）| UTF-8 无 BOM |
| 日志重定向 | cmd /c 字节级，保持 UTF-8 |
| 配置/JSON | UTF-8 无 BOM（标准）|
