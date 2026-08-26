# deploy-agent · 通用自动化部署系统

多项目共用的一套部署基础设施：**本机开发 → GitHub 版本管理 → 服务器自动化部署**。

## 架构

```
【本机】deploy.ps1（每项目一份，templates/deploy.ps1.example 复制）
  ① git commit + push
  ② 构建
  ③ robocopy 同步到服务器（正斜杠 UNC）
  ④ 写 .deploy-flag

【服务器】C:\deploy-agent\（装一次，永久共用）
  ├── scripts/watcher.ps1     单实例（恒定 ~20MB），每 3 秒轮询所有项目标志
  ├── scripts/daily-check.ps1 每日 02:00 兜底（标志残留 + watcher 自愈）
  └── projects.config         项目清单（新项目 = 加一行）

【计划任务】<PROJECT>-watcher（AtStartup+SYSTEM）+ DeployAgentDaily（每日 02:00）
```

## 目录

```
scripts/              服务器核心脚本（部署到 C:\deploy-agent\）
templates/            新项目接入模板
docs/                 完整文档
projects.config.example  项目配置示例
```

## 新项目接入

> 先看 **docs/接入决策指南.md** 判断用哪套通道（局域网 SMB / 云 Windows / 云 Linux），再按对应方案接入。

### 常规接入（局域网，5 分钟）

1. 服务器：`projects.config` 加一行
2. 服务器：项目目录放 `restart.cmd`（templates 复制）
3. 本机：`deploy.ps1`（templates 复制，改 3 处配置）
4. 服务器：管理员运行 `templates/register-agent.bat`（替换 <PROJECT>）
5. 本机：`powershell -File deploy.ps1` 一键部署

详见 `docs/通用自动化部署系统.md`。

## 常见坑（必读）

- ⚠️ **UNC 路径必须正斜杠**（//服务器/共享/路径）。反斜杠（服务器...）会被转义成本地路径，部署静默写错机器。模板已内置校验，填错会直接报错。
- ⚠️ **确认连的是部署服务器**（装有 C:deploy-agent 的机器），局域网多机时勿连错。

## License

MIT License. 适用范围：内网/局域网 Windows 服务器。云服务器请直接用 GitHub Actions。
