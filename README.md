# 逆果溯因 (Reverse Causality)

> 一款认知型推理游戏，通过构建因果链来理解复杂系统的运行逻辑

[![Godot](https://img.shields.io/badge/Godot-4.6-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🎮 游戏简介

《逆果溯因》是一款基于因果推理的益智游戏。玩家需要从给定的结果出发，逆向构建完整的因果链，理解事件之间的逻辑关系。

### 核心玩法

- **逆向推理**：从结果出发，寻找导致该结果的原因链
- **因果验证**：系统会评估你构建的因果链的逻辑强度和合理性
- **多解路径**：每个关卡可能存在多种合理的因果解释
- **干扰识别**：需要识别并避开伪因果、反向因果等陷阱

## ✨ 特色功能

- 🧩 **因果链构建**：通过拖拽节点构建完整的因果链
- 📊 **强度可视化**：实时显示当前因果链的逻辑强度
- 🎯 **多解系统**：支持主流叙事、隐藏路径和黑天鹅链等多种解法
- 📖 **世界线日志**：每完成一关，生成独特的世界历史片段
- 🏆 **评分系统**：根据因果强度、步数和路径类型进行评分

## 🚀 快速开始

### 环境要求

- Godot 4.6 或更高版本
- 支持 Web 导出（HTML5）

### 运行项目

1. 克隆仓库
```bash
git clone https://github.com/YOUR_USERNAME/reverse-causality.git
cd reverse-causality
```

2. 使用 Godot 打开项目
   - 打开 Godot 编辑器
   - 选择 "导入项目"
   - 选择项目目录中的 `project.godot` 文件

3. 运行游戏
   - 在编辑器中按 `F5` 或点击运行按钮
   - 或使用场景菜单运行主场景

### Web 导出

1. 在 Godot 编辑器中，选择 `项目` → `导出`
2. 添加 Web 导出模板
3. 配置导出设置
4. 导出为 HTML5 文件

## 📁 项目结构

```
reverse-causality/
├── scenes/              # 游戏场景
│   ├── ui/             # UI 界面
│   ├── game/           # 游戏主场景
│   ├── tutorial/       # 教程场景
│   └── components/     # UI 组件
├── scripts/            # 游戏脚本
│   ├── core/          # 核心系统
│   ├── data/          # 数据模型
│   ├── components/    # 组件脚本
│   └── narrative/     # 叙事系统
├── data/              # 游戏数据
│   └── levels/        # 关卡数据
└── export_templates/  # 导出模板
```

## 🎯 开发状态

当前版本：**v0.1.0** (MVP)

### 已完成功能
- ✅ 基础因果链构建系统
- ✅ 因果验证逻辑
- ✅ 关卡系统
- ✅ UI 界面
- ✅ 存档系统

### 计划功能
- 🔄 因果共振系统
- 🔄 多解路径检测
- 🔄 世界线日志生成
- 🔄 因果图鉴系统
- 🔄 Web 性能优化

## 📚 文档

- [开发指南](reverse_causality_dev_guide.md) - 完整的技术实现文档
- [游戏设计文档](m2.md) - MDA 框架分析与优化方案

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 使用 [Godot Engine](https://godotengine.org/) 开发
- 字体：[Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC)

---

**逆果溯因** - 理解因果，洞察未来
