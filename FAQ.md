# FAQ（OpenClaw 随身版 Windows）

## 1. 双击 `OpenClawManager.exe` 后提示找不到 OpenClaw / 未安装

通常是发布目录不完整。请检查以下路径是否存在：

- `env/node/node.exe`
- `openclaw_app/dist/entry.js`
- `openclaw_app/node_modules/`

如果缺失，重新解压完整发布包，不要只拷贝部分文件。

## 2. 为什么不能依赖系统 `C:\Program Files\nodejs`？

因为这是便携版，目标是“插上即用、到处可跑”。  
运行时应固定使用发布包内 `env/node`，避免不同电脑环境差异导致故障。

## 3. 首次启动应该配哪些信息？

至少需要可用的模型密钥（例如 `OPENAI_API_KEY`）。  
相关配置统一写入 `.env`，不要硬编码在 `openclaw.json` 中。

## 4. 升级后配置会丢吗？

按推荐流程不会：

1. 升级前备份旧 `.env` 与数据目录。
2. 解压新版本后迁移 `.env`。
3. 启动新版本验证。

## 5. 离线环境能运行吗？

可以。便携版包含运行时依赖。  
但如果你的业务本身需要联网调用云模型接口，实际推理仍需要网络。

## 6. 解压后被杀毒软件拦截怎么办？

- 先确认包来源可信并核对 SHA256。
- 将发布目录加入白名单（企业环境请走 IT 安全流程）。
- 不要从未知来源替换 `exe` 或脚本。

## 7. 如何确认当前 OpenClaw 核心版本？

在发布目录执行：

```powershell
.\env\node\node.exe .\openclaw_app\dist\entry.js --version
```

如果输出 `OpenClaw 2026.3.13`，说明核心版本正确。

## 8. 打包日志里出现 `skip missing: README.md / FAQ.md` 怎么办？

表示发布脚本尝试复制文档时，根目录没有这两个文件。  
把 `README.md` 和 `FAQ.md` 放到项目根目录后重新打包即可。
