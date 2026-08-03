# 架构与依赖规范

这个项目从一开始就要控制依赖方向和资源归属。目标不是“文件夹好看”，而是避免后期分包、裁剪、DLC、平台差异、资源包拆分时发现小包被无关依赖拖得很大。

## 核心原则

1. 依赖只能从具体层指向更通用层。
2. 通用层不能依赖具体玩法、场景、UI 或资源包。
3. 功能模块之间默认不能直接互相引用。
4. 大资源必须归属到明确模块或共享资源目录。
5. 跨模块通信优先用信号、接口式组件、事件、数据资源或上层协调者。
6. 不为了方便写深层 NodePath 或直接 preload 另一个功能模块。

## 推荐目录

```text
scripts/
  core/          # 最通用代码：数学、事件、存档接口、工具函数，不依赖 gameplay/ui
  components/    # 可复用组件：HealthComponent、Hitbox、StateMachine
  gameplay/      # 具体玩法逻辑
  ui/            # UI 逻辑
  tools/         # editor/tool scripts

scenes/
  gameplay/
  ui/
  levels/
  prototypes/

resources/
  shared/        # 多模块共享的小数据资源
  gameplay/
  ui/

assets/
  shared/        # 真正共享的贴图、音效、字体
  gameplay/
  ui/
  levels/
```

## 依赖方向

允许：

- `scripts/gameplay` -> `scripts/components`
- `scripts/gameplay` -> `scripts/core`
- `scripts/ui` -> `scripts/core`
- `scenes/levels` -> `scenes/gameplay`
- `scenes/levels` -> `scenes/ui`
- 具体模块 -> `assets/shared`

谨慎：

- `scripts/ui` -> `scripts/gameplay`
- `scripts/gameplay` -> `scripts/ui`
- `resources/shared` -> 具体模块资源

禁止：

- `scripts/core` -> `scripts/gameplay`
- `scripts/core` -> `scripts/ui`
- `scripts/components` -> 具体 gameplay 场景
- 一个功能模块直接 preload 另一个功能模块的大场景或大资源
- 为了访问一个值而引用整棵场景或整包资源

## 分包/资源包敏感规则

如果未来要做分包、DLC、按关卡打包、按平台裁剪，必须从现在开始遵守：

1. 大资源不要放在 `shared`，除非所有包都确实需要。
2. 场景不要 preload 不属于自己包的大资源。
3. 自动加载单例不要持有具体包资源引用。
4. UI 公共组件不要引用具体关卡、敌人、武器、角色资源。
5. 关卡包可以依赖共享组件，但共享组件不能反向依赖关卡包。

## AI 写代码前必须检查

中大型功能开始前，AI 需要回答：

1. 新文件属于哪个模块？
2. 它允许依赖哪些目录？
3. 是否引入了跨模块 preload/load？
4. 是否把大资源放进 shared？
5. 是否会影响未来分包或资源裁剪？

## 审计

每次改动后运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

其中会调用 `scripts/audit_dependencies.ps1` 做轻量依赖扫描。

