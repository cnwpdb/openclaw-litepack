# OpenClaw USB Portable (Windows)

一个面向 Windows 的 OpenClaw 便携版项目。目标是做到：  
解压即用、双击启动、可复现打包。

## 项目定位

- 本仓库用于维护便携版的打包流程、管理器和文档。
- 最终分发包通过 GitHub Releases 提供，不建议把大体积 zip 直接提交到仓库历史。

## 推荐发布方式

1. 仓库提交源码与脚本（可审计、可协作）。
2. 发布包（`.zip`）上传到 GitHub Releases 的附件。
3. 在 Release 页面附上 SHA256 校验值和变更说明。

## 快速开始（用户）

1. 从 GitHub Releases 下载最新 zip。
2. 解压到任意目录（可放 U 盘）。
3. 双击 `OpenClawManager.exe`。
4. 首次配置 `.env` 中的必要参数（如 API Key）。
5. 首发版暂不提供升级脚本，升级方案将在第二版发布。

## 目录说明（发布包）

```text
OpenClaw-xxx/
├── OpenClawManager.exe
├── .env
├── env/
│   ├── node/
│   └── python/
└── openclaw_app/
    ├── dist/
    ├── extensions/
    ├── skills/
    └── openclaw.json
```

## 本地打包（维护者）

```powershell
# 1) 生成发布目录
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\prepare-release.ps1 -Version "openclaw-2026.3.13-build-2026.03.15-skillhub"

# 2) 压缩为分发包
Compress-Archive -Path .\release\OpenClaw-openclaw-2026.3.13-build-2026.03.15-skillhub\* -DestinationPath .\OpenClaw-openclaw-2026.3.13-build-2026.03.15-skillhub.zip -CompressionLevel Optimal
```

## 安全规则（非常重要）

- 严禁提交真实 `.env`、`openclaw.json` 敏感字段、日志中的密钥。
- 发布前必须执行一次敏感信息检查与人工复核。
- 若密钥曾进入仓库或打包产物，必须立刻旋转（更换）该密钥。

## 文档

- [FAQ.md](./FAQ.md)
- [release-manifest.md](./release-manifest.md)
- [打包命令.md](./打包命令.md)

## 许可证

本仓库建议明确添加 `LICENSE`（例如 MIT）后再公开。
