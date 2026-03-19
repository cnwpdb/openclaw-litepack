# OpenClaw MVP 发布清单（Release Manifest）

> 版本：MVP  
> 日期：2026-03-16  
> 入口策略：仅 `OpenClawManager.exe`

---

## 1. 发布包必须保留

以下文件/目录必须进入最终发布包：

- `OpenClawManager.exe`
- `env/`
- `openclaw_app/dist/`
- `openclaw_app/.browser_cache/`
- `openclaw_app/.npm-cache/`（若存在，建议保留）
- `openclaw_app/openclaw.json`（已移除硬编码敏感信息后）
- `openclaw_data/`（可选：若做空盘交付可不带用户数据）
- `.env`（仅在预置模板场景；严禁带测试密钥）
- `upgrade-safe.bat` / `upgrade-safe.ps1`
- `apply-webui-font-scale.bat` / `apply-webui-font-scale.ps1`
- `小白无损升级方案.md`
- `发布公告模板.md`
- `README.md`
- `FAQ.md`（或等价文档）

---

## 2. 发布包禁止包含

以下内容不得进入最终发布包：

- `start.bat`（历史兼容入口，发布包移除）
- `chrome-win64.zip`
- `openclaw-main.zip`
- 测试用 `.env`（如示例假数据 `123123213123`）
- `openclaw_app/src/`（开发源码）
- 开发配置文件：`tsconfig.json`、`vitest.*.config.ts` 等
- 调试日志：`error.log`、`error.txt`、临时构建日志

---

## 3. 开发镜像保留策略

为保证后续迭代能力，开发镜像必须单独保留，不随发布包分发：

- `openclaw-manager/` 全量源码
- `openclaw_app/` 全量源码（含 `src/`、测试、构建配置）
- 构建脚本与 CI 配置

建议：

- 开发镜像放在 Git 仓库或独立归档目录；
- 发布包目录只保留运行时文件；
- 每次发版前按本清单做一次人工复核。

---

## 4. 发布前检查（最小检查表）

- [ ] 入口为 `OpenClawManager.exe`，且可直接双击启动
- [ ] 发布包中不含 `start.bat`
- [ ] `openclaw.json` 无硬编码敏感 Token
- [ ] `.env` 不含测试密钥/无效假数据
- [ ] `upgrade-safe.bat` 可正常启动
- [ ] `apply-webui-font-scale.bat` 执行后出现 `[ OK ] WebUI font scale applied`
- [ ] 跨盘符启动验证通过
- [ ] 断网冷启动验证通过
- [ ] 小白流程走查通过
