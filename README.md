# FEZ Chronicle of Players

一個基於 FEZ 世界觀的彈幕射擊遊戲，使用 Godot Engine 4.x 開發。

## 專案概述

FEZ Chronicle of Players 是一款結合 FEZ 經典角色與彈幕射擊玩法的遊戲。玩家可以操控不同的角色，體驗獨特的戰鬥系統和豐富的劇情內容。

## 目前實現功能

### 核心移動系統
- ✅ 玩家八方向移動控制
- ✅ WASD 和方向鍵輸入支援
- ✅ 斜向移動速度正規化
- ✅ 流暢的物理移動系統

## 開發環境

- **引擎版本**: Godot Engine 4.4
- **目標平台**: PC (Windows, macOS, Linux)
- **程式語言**: GDScript

## 專案結構

```
new-game-project/
├── Scripts/
│   ├── PlayerController.gd    # 玩家控制器腳本
│   └── sprite_2d.gd          # 精靈圖像腳本
├── Player.tscn               # 玩家角色場景
├── main.tscn                 # 主場景
└── project.godot             # 專案配置檔案
```

## 控制說明

### 移動控制
- **W** / **↑**: 向上移動
- **S** / **↓**: 向下移動
- **A** / **←**: 向左移動
- **D** / **→**: 向右移動
- **組合鍵**: 支援八方向移動（如 W+D 為右上移動）

## 開發進度

根據 `.kiro/specs/fez-chronicle-players/tasks.md` 的實現計畫：

### Phase 1: 前期製作與原型驗證 (進行中)
- [x] **2.1** 玩家基礎控制器 - 完成八方向移動系統
- [ ] **2.2** 閃避系統實作
- [ ] **2.3** 測試場景建立
- [ ] **3.1** 攻擊系統實作
- [ ] **3.2** 基礎敵人系統

## 如何運行

1. 確保已安裝 Godot Engine 4.x
2. 開啟 Godot 編輯器
3. 導入專案檔案 `new-game-project/project.godot`
4. 點擊運行按鈕開始遊戲

## 開發團隊

此專案為個人開發，結合 AI 輔助工具協助程式開發。

---

*這是一個正在積極開發中的專案，更多功能將陸續實現。*