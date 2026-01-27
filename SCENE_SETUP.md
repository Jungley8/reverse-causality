# 场景文件创建指南

由于场景文件（.tscn）需要在 Godot 编辑器中创建，请按照以下步骤创建所需的场景：

## 1. 主菜单场景 (scenes/ui/MainMenu.tscn)

创建 Control 节点作为根节点，添加以下子节点：

```
MainMenu (Control)
 ├─ Background (ColorRect) - 设置背景色为深色 (#0E1117)
 ├─ TitleContainer (VBoxContainer)
 │   ├─ GameTitle (Label) - 文本："逆果溯因"
 │   └─ Subtitle (Label) - 文本："REVERSE CAUSALITY"
 ├─ MenuButtons (VBoxContainer)
 │   ├─ StartButton (Button) - 文本："开始游戏"
 │   ├─ ContinueButton (Button) - 文本："继续游戏"
 │   └─ ArchiveButton (Button) - 文本："因果图鉴"
 └─ VersionLabel (Label) - 文本："v0.1.0"
```

将脚本 `scripts/ui/MainMenu.gd` 附加到 MainMenu 节点，并连接按钮信号。

## 2. 关卡选择场景 (scenes/ui/LevelSelect.tscn)

```
LevelSelect (Control)
 ├─ Background (ColorRect)
 ├─ Header (HBoxContainer)
 │   ├─ BackButton (Button) - 文本："← 返回"
 │   └─ Title (Label) - 文本："选择关卡"
 ├─ LevelGrid (GridContainer) - 列数：3
 └─ LevelDescription (Panel) - 可选
```

将脚本 `scripts/ui/LevelSelect.gd` 附加到 LevelSelect 节点。

## 3. 关卡卡片组件 (scenes/components/LevelCard.tscn)

```
LevelCard (PanelContainer)
 └─ VBox (VBoxContainer)
     ├─ LevelIdLabel (Label)
     ├─ StatusIcon (Label)
     ├─ GradeLabel (Label)
     └─ TitleLabel (Label)
```

将脚本 `scripts/components/LevelCard.gd` 附加到 LevelCard 节点。

## 4. 因果卡片组件 (scenes/components/CauseCard.tscn)

```
CauseCard (PanelContainer)
 └─ MarginContainer (MarginContainer)
     └─ Label (Label)
```

将脚本 `scripts/components/CauseCard.gd` 附加到 CauseCard 节点。

## 5. 因果链槽位组件 (scenes/components/ChainSlot.tscn)

```
ChainSlot (PanelContainer)
 ├─ CardContainer (Control)
 └─ PlaceholderLabel (Label) - 文本："?"
```

将脚本 `scripts/components/ChainSlot.gd` 附加到 ChainSlot 节点。

## 6. 游戏主界面 (scenes/game/GameMain.tscn)

```
GameMain (Control)
 ├─ Header (HBoxContainer)
 │   ├─ LevelLabel (Label)
 │   └─ SettingsButton (Button) - 可选
 ├─ ResultCardContainer (MarginContainer)
 │   └─ ResultCard (Label)
 ├─ StrengthBar (ProgressBar)
 │   └─ StrengthLabel (Label)
 ├─ ChainArea (Panel)
 │   └─ ChainSlots (HBoxContainer)
 ├─ CandidateArea (Panel)
 │   └─ CandidateGrid (GridContainer) - 列数：4
 ├─ ActionButtons (HBoxContainer)
 │   ├─ ValidateButton (Button) - 文本："验证"
 │   └─ ClearButton (Button) - 文本："清空"
 └─ ResultPanel (Panel) - 初始隐藏
```

将脚本 `scripts/game/GameMain.gd` 附加到 GameMain 节点。

## 7. 结果面板 (scenes/ui/ResultPanel.tscn)

```
ResultPanel (Panel) - 初始 visible = false
 └─ VBox (VBoxContainer)
     ├─ GradeLabel (Label)
     ├─ CompletenessBar (ProgressBar)
     ├─ StrengthBar (ProgressBar)
     ├─ CleanlinessBar (ProgressBar)
     ├─ CommentLabel (Label)
     ├─ UnlockLabel (Label) - 可选
     └─ Buttons (HBoxContainer)
         ├─ NextButton (Button) - 文本："下一关"
         └─ RetryButton (Button) - 文本："重新挑战"
```

将脚本 `scripts/ui/ResultPanel.gd` 附加到 ResultPanel 节点。

## 生成关卡数据

在 Godot 编辑器中：
1. 打开 `scripts/tools/CreateLevelData.gd`
2. 在编辑器中运行此脚本（工具 > 运行脚本）
3. 这将生成三个关卡数据文件到 `data/levels/` 目录

## 设置主场景

在项目设置中，将主场景设置为 `scenes/ui/MainMenu.tscn`（已在 project.godot 中配置）。
