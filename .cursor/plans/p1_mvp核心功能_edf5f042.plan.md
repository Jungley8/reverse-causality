---
name: P1 MVP核心功能
overview: 实现游戏的核心可玩功能，包括数据结构、拖拽系统、验证逻辑、基础UI和3个关卡，确保玩家可以完成完整的游戏循环。
todos:
  - id: p1-data-structures
    content: 创建数据结构类：CauseNode.gd, CausalRule.gd, LevelData.gd
    status: pending
  - id: p1-validator
    content: 实现 CausalValidator.gd 核心验证逻辑
    status: pending
  - id: p1-drag-drop
    content: 实现拖拽系统：CauseCard.gd 和 ChainSlot.gd
    status: pending
  - id: p1-game-main
    content: 创建游戏主界面 GameMain.tscn 和 GameMain.gd
    status: pending
  - id: p1-result-panel
    content: 实现结果反馈面板 ResultPanel
    status: pending
  - id: p1-menu-levelselect
    content: 实现主菜单和关卡选择界面
    status: pending
  - id: p1-save-system
    content: 实现 SaveGame.gd 数据持久化系统
    status: pending
  - id: p1-level-data
    content: 创建3个关卡的 LevelData 资源文件
    status: pending
  - id: p1-scoring
    content: 实现评分计算系统
    status: pending
  - id: p1-web-export
    content: 配置 Web 导出设置并测试
    status: pending
isProject: false
---

# P1: MVP 核心功能开发计划

## 目标

实现游戏的核心可玩功能，让玩家能够完成从主菜单到关卡完成的完整游戏循环。

## 开发周期

第 1-2 周

## 核心任务

### 1. 数据结构与资源系统

**文件路径**：

- `scripts/data/CauseNode.gd` - 因果节点资源类
- `scripts/data/CausalRule.gd` - 因果规则资源类
- `scripts/data/LevelData.gd` - 关卡数据资源类

**实现要点**：

- 继承 `Resource` 类，使用 `@export` 标记可序列化属性
- CauseNode 包含：id, label, tags, time_stage
- CausalRule 包含：from_id, to_id, strength
- LevelData 包含：result_id, required_strength, max_steps, candidates, rules

**参考代码位置**：`reverse_causality_dev_guide.md` 第 2.1 节

### 2. 核心验证系统

**文件路径**：

- `scripts/core/CausalValidator.gd` - 因果链验证器

**核心功能**：

- `validate_chain(chain: Array[String], level: LevelData) -> Dictionary`
- 检查因果链是否连续（每个相邻节点是否有规则）
- 计算总因果强度
- 验证是否达到 required_strength 阈值
- 处理边界情况：空链、单节点、超长链、重复节点

**参考代码位置**：`reverse_causality_dev_guide.md` 第 2.3 节

### 3. 拖拽系统实现

**文件路径**：

- `scenes/components/CauseCard.tscn` + `scripts/components/CauseCard.gd`
- `scenes/components/ChainSlot.tscn` + `scripts/components/ChainSlot.gd`
- `scripts/core/DragDropManager.gd`（可选）

**实现方案**：

- 使用 Godot 内置 `_get_drag_data()` 和 `_drop_data()` API
- CauseCard 实现拖拽开始/结束信号
- ChainSlot 实现放置检测和卡片管理
- 视觉反馈：拖拽时半透明、悬停时高亮

**参考代码位置**：`reverse_causality_dev_guide.md` 第 1.4 节

### 4. 游戏主界面

**文件路径**：

- `scenes/game/GameMain.tscn` + `scripts/game/GameMain.gd`

**UI 结构**：

```
GameMain (Control)
 ├─ Header (显示关卡信息)
 ├─ ResultCard (显示结果节点)
 ├─ StrengthBar (实时显示因果强度)
 ├─ ChainArea/ChainSlots (因果链构建区)
 ├─ CandidateArea/CandidateGrid (候选节点区)
 └─ ActionButtons (验证/清空按钮)
```

**核心逻辑**：

- 加载关卡数据
- 生成候选节点卡片
- 管理拖拽流程
- 实时更新强度条
- 验证按钮触发验证逻辑

**参考代码位置**：`reverse_causality_dev_guide.md` 第 1.3 节

### 5. 结果反馈面板

**文件路径**：

- `scenes/ui/ResultPanel.tscn` + `scripts/ui/ResultPanel.gd`

**功能**：

- 显示评分等级（S/A/B/FAIL）
- 显示三项指标：完整度、强度、洁净度
- 显示评语文案
- 提供"下一关"和"重新挑战"按钮

**参考代码位置**：`reverse_causality_dev_guide.md` 第 1.6 节

### 6. 主菜单与关卡选择

**文件路径**：

- `scenes/ui/MainMenu.tscn` + `scripts/ui/MainMenu.gd`
- `scenes/ui/LevelSelect.tscn` + `scripts/ui/LevelSelect.gd`
- `scenes/components/LevelCard.tscn` + `scripts/components/LevelCard.gd`

**功能**：

- 主菜单：开始游戏、继续游戏、因果图鉴入口
- 关卡选择：卡片式布局，显示关卡状态（完成/锁定）
- 关卡解锁：关卡1默认解锁，后续需要前一关B级以上

**参考代码位置**：`reverse_causality_dev_guide.md` 第 1.1、1.2 节

### 7. 数据持久化系统

**文件路径**：

- `scripts/core/SaveGame.gd`（全局自动加载）

**功能**：

- 保存关卡进度（grade, score, best_chain）
- 加载游戏状态
- 检查是否有存档
- 重置进度功能

**数据结构**：

```gdscript
{
  "version": "0.1.0",
  "level_progress": { level_id: { grade, score, best_chain } },
  "settings": { sound_volume, music_volume }
}
```

**参考代码位置**：`reverse_causality_dev_guide.md` 第 2.2 节

### 8. 三个关卡数据

**文件路径**：

- `data/levels/level_01.tres`
- `data/levels/level_02.tres`
- `data/levels/level_03.tres`

**关卡内容**（参考 m1.md）：

- 关卡1：城市系统性崩溃（8个候选节点）
- 关卡2：全面禁止通用AI（8个候选节点）
- 关卡3：AI被赋予有限法律人格（8个候选节点）

**每个关卡需要**：

- 定义所有候选 CauseNode
- 定义所有 CausalRule（from → to + strength）
- 设置 required_strength 和 max_steps

### 9. 评分系统

**文件路径**：

- `scripts/core/CausalValidator.gd` 中的 `calculate_grade()` 方法

**评分逻辑**：

- 基础：strength_score (60%) + step_score (40%)
- S级：> 0.85
- A级：> 0.7
- B级：> 0.6
- FAIL：未通过验证

**参考代码位置**：`reverse_causality_dev_guide.md` 第 2.3 节

### 10. Web 导出基础配置

**文件路径**：

- `export_presets.cfg`（已存在，需要检查配置）

**配置要点**：

- HTML文件名：index.html
- 关闭线程支持（Web兼容性）
- 设置基础分辨率：1280x720

**参考代码位置**：`reverse_causality_dev_guide.md` 第 2.4 节

## 开发顺序建议

1. **Day 1-2**：数据结构（CauseNode, CausalRule, LevelData）
2. **Day 3-4**：验证系统（CausalValidator）
3. **Day 5-6**：拖拽系统（CauseCard, ChainSlot）
4. **Day 7-8**：游戏主界面（GameMain）
5. **Day 9-10**：关卡数据创建（3个关卡）
6. **Day 11-12**：主菜单和关卡选择
7. **Day 13-14**：结果面板 + 保存系统 + 测试

## 验收标准

- 可以从主菜单进入关卡选择
- 可以拖拽节点到槽位
- 可以验证因果链并获得评分
- 可以完成3个关卡
- 进度可以保存和加载
- Web导出可以正常运行

## 技术债务记录

- 暂不实现撤销/重做（P2）
- 暂不实现干扰节点（P2）
- 暂不实现因果共振（P3）
- 暂不实现多解路径（P3）

