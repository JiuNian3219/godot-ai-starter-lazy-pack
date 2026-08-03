# 懒人包安装提示词

开新项目时，把下面这段提示词给当前 AI agent。

```text
你的任务不是手写 AGENTS.md、CLAUDE.md、Qoder rules、skills、MCP 配置或 Godot 场景。这些内容已经在 GodotAIStarterLazyPack.zip 里。

请按下面流程做：

1. 确认本机硬依赖版本：
   ```powershell
   git --version
   git lfs version
   node --version
   npm --version
   npx --version
   ```

2. 检查可选 AI 工具入口。缺少其中某个不应该阻塞安装：
   ```powershell
   claude --version
   qodercn --version
   qoderclicn --version
   qoder --version
   qodercli --version
   ```
   如果命令不存在，只要报告“未安装/未在 PATH”，不要把它当成失败。

3. 找到懒人包 zip：
   ```text
   GodotAIStarterLazyPack.zip
   ```

4. 解压懒人包到临时目录，例如：
   ```powershell
   Expand-Archive -LiteralPath "C:\path\to\GodotAIStarterLazyPack.zip" -DestinationPath "C:\path\to\GodotAIStarterLazyPack" -Force
   ```

5. 主动查找本机可用的 Godot 4.6.x stable，不要一开始要求我手填路径：
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\GodotAIStarterLazyPack\template\scripts\find_godot_candidates.ps1"
   ```
   - 先报告找到的候选项及版本。
   - 无论只找到一个还是多个候选项，都向我确认要使用哪一个；不要静默选择。
   - 找不到兼容版本时，再说明搜索范围并请我提供路径。

6. 收到我的确认后，运行懒人包里的安装脚本。把确认过的绝对路径传给 `-GodotBin`：
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\GodotAIStarterLazyPack\install.ps1" -TargetPath "C:\path\to\new-game" -ProjectName "New Game" -GodotBin "C:\confirmed\path\to\Godot_v4.6.x-stable_win64_console.exe"
   ```
   安装脚本会将该路径保存到新项目被 Git 忽略的 `tools\godot-bin.path`；之后的新终端不依赖临时环境变量。

7. 安装脚本成功后，进入新项目目录，运行：
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
   ```

8. 检查新项目里这些 AI 工具适配文件是否存在：
   - `.mcp.json`
   - `.claude/skills/godot-feature/SKILL.md`
   - `.claude/skills/godot-test/SKILL.md`
   - `.claude/skills/godot-review/SKILL.md`
   - `.claude/skills/godot-memory/SKILL.md`
   - `.qoder/rules/00-project-rules.md`
   - `.qoder/rules/10-godot-engineering.md`
   - `.qoder/rules/20-game-dev.md`
   - `.qoder/skills/godot-feature/SKILL.md`
   - `.qoder/skills/godot-test/SKILL.md`
   - `.qoder/skills/godot-review/SKILL.md`
   - `.qoder/skills/godot-memory/SKILL.md`

9. 检查新项目里这些通用文件是否存在：
   - `AGENTS.md`
   - `CLAUDE.md`
   - `docs/prompts.md`
   - `docs/template_manifest.md`
   - `docs/engineering_rules.md`
   - `docs/game_development_rules.md`
   - `docs/architecture_rules.md`
   - `addons/godot_mcp/plugin.cfg`
   - `scripts/verify.ps1`

最终输出：
- 硬依赖版本检查结果。
- 可选 AI 工具入口检查结果。
- 用户确认的 Godot 路径，以及 `tools\godot-bin.path` 是否存在。
- 新项目路径。
- `verify.ps1` 是否通过。
- MCP、skills、rules 适配文件是否存在。
- 仍需要我人工处理的事情。

硬性约束：
- 不要重新生成模板内容。
- 不要下载或安装未知 skill 包。
- 不要使用 Codex CLI。
- 不要默认使用 `--dangerously-skip-permissions`。
- 如果硬依赖缺失，先报告缺什么，不要绕过验证。
- 没有经过用户确认的 Godot 路径时，不要开始安装或用 `-SkipVerify` 伪造成功。
```

## 安装后

安装通过后，在新项目里使用：

- `docs/prompts.md`：通用任务提示词。
- `.claude/skills/`：Claude Code 可识别的项目技能。
- `.qoder/rules/` 与 `.qoder/skills/`：QoderCN / Qoder 可识别的项目规则和技能。
- `AGENTS.md` 与 `docs/`：所有 AI agent 的共享规则。
