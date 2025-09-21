# Requirements Document

## Introduction

FEZ: Chronicle of the Players 是一款劇情導向的彈幕射擊遊戲，旨在透過高挑戰性的彈幕射擊玩法與沉浸式的群像劇故事，讓玩家重溫《Fantasy Earth Zero》世界中的戰爭歲月。遊戲採用人機協作開發模式，結合 AI 程式設計與手動創意工作，從原型開發到 Steam 正式版發布。

## Requirements

### Requirement 1: 核心戰鬥系統

**User Story:** 作為玩家，我希望能夠體驗流暢且具挑戰性的彈幕射擊戰鬥，以獲得緊張刺激的遊戲體驗。

#### Acceptance Criteria

1. WHEN 玩家按下移動鍵 THEN 角色 SHALL 進行八方向移動
2. WHEN 玩家點擊滑鼠 THEN 系統 SHALL 發射普通攻擊子彈
3. WHEN 玩家按下側跳鍵 THEN 角色 SHALL 執行閃避動作並獲得短暫無敵幀
4. WHEN 玩家被敵人攻擊命中 THEN 系統 SHALL 立即產生後仰硬直並中斷當前動作
5. WHEN 玩家施放技能 THEN 系統 SHALL 顯示施法前搖動畫且玩家無法移動或進行其他動作

### Requirement 2: 資源管理系統

**User Story:** 作為玩家，我希望能夠策略性地管理遊戲資源，以增加遊戲的策略深度。

#### Acceptance Criteria

1. WHEN 遊戲開始 THEN 系統 SHALL 初始化玩家的 HP、SP 和 Cost 數值
2. WHEN 玩家 HP 歸零 THEN 系統 SHALL 重置關卡進度並判定關卡挑戰失敗
3. WHEN 玩家使用技能 THEN 系統 SHALL 消耗對應的 SP 點數
4. WHEN 玩家使用道具 THEN 系統 SHALL 消耗對應的 Cost 點數
5. WHEN Cost 歸零 THEN 系統 SHALL 禁止玩家使用任何道具

### Requirement 3: 敵人 AI 與彈幕系統

**User Story:** 作為玩家，我希望面對智能且多樣化的敵人，以獲得豐富的戰鬥體驗。

#### Acceptance Criteria

1. WHEN 敵人生成 THEN 系統 SHALL 根據敵人類型執行對應的移動邏輯
2. WHEN 敵人偵測到玩家 THEN 敵人 SHALL 面向玩家並準備攻擊
3. WHEN 敵人攻擊時機到達 THEN 敵人 SHALL 發射彈幕攻擊玩家
4. WHEN 敵人被玩家攻擊命中 THEN 敵人 SHALL 執行受擊反應
5. WHEN 敵人被擊敗 THEN 系統 SHALL 掉落水晶道具

### Requirement 4: 召喚獸系統

**User Story:** 作為玩家，我希望能夠召喚強力的召喚獸來協助戰鬥，以獲得扭轉戰局的能力。

#### Acceptance Criteria

1. WHEN 玩家收集足夠水晶 THEN 系統 SHALL 允許玩家召喚召喚獸
2. WHEN 玩家召喚召喚獸 THEN 系統 SHALL 消耗所有水晶並生成召喚獸
3. WHEN 召喚獸存在於場上 THEN 召喚獸 SHALL 自動攻擊敵人
4. WHEN 召喚獸持續時間結束 THEN 系統 SHALL 移除召喚獸

### Requirement 5: 關卡與劇情系統

**User Story:** 作為玩家，我希望體驗豐富的劇情內容和多樣化的關卡挑戰，以獲得沉浸式的遊戲體驗。

#### Acceptance Criteria

1. WHEN 玩家選擇關卡 THEN 系統 SHALL 載入對應的劇情對話和戰鬥場景
2. WHEN 關卡目標達成 THEN 系統 SHALL 解鎖下一個關卡
3. WHEN 玩家完成主角章節 THEN 系統 SHALL 解鎖其他國家的主角
4. IF 關卡類型為攻擊模式 THEN 玩家 SHALL 推進至敵方據點
5. IF 關卡類型為防守模式 THEN 玩家 SHALL 在時限內守住我方據點
6. IF 關卡類型為護送模式 THEN 玩家 SHALL 保護奇美拉摧毀敵方據點

### Requirement 6: 技能與職業系統

**User Story:** 作為玩家，我希望能夠使用不同職業的經典技能，以體驗多樣化的戰鬥風格。

#### Acceptance Criteria

1. WHEN 玩家選擇職業 THEN 系統 SHALL 載入對應的技能組合
2. WHEN 玩家施放技能 THEN 系統 SHALL 根據 FEZ 原版設計執行技能效果
3. WHEN 技能包含 Ex 技能 THEN 系統 SHALL 重新詮釋經典 Bug 或操作技巧
4. WHEN 玩家升級 THEN 系統 SHALL 解鎖新的技能或強化現有技能

### Requirement 7: UI/UX 系統

**User Story:** 作為玩家，我希望擁有直觀易用的使用者介面，以便順暢地進行遊戲操作。

#### Acceptance Criteria

1. WHEN 遊戲啟動 THEN 系統 SHALL 顯示主選單介面
2. WHEN 戰鬥進行中 THEN 系統 SHALL 即時顯示 HP、SP、Cost 數值
3. WHEN 玩家進入設定 THEN 系統 SHALL 提供音效、畫質等調整選項
4. WHEN 玩家進入章節選擇 THEN 系統 SHALL 顯示可用的關卡和進度

### Requirement 8: 存檔與進度系統

**User Story:** 作為玩家，我希望能夠保存遊戲進度，以便隨時繼續遊戲。

#### Acceptance Criteria

1. WHEN 玩家完成關卡 THEN 系統 SHALL 自動保存遊戲進度
2. WHEN 玩家啟動遊戲 THEN 系統 SHALL 載入最新的存檔資料
3. WHEN 玩家獲得裝備或道具 THEN 系統 SHALL 保存至存檔中
4. WHEN 玩家解鎖新內容 THEN 系統 SHALL 更新存檔進度

### Requirement 9: 美術與音效系統

**User Story:** 作為玩家，我希望體驗精美的像素藝術風格和懷舊的音效，以獲得視聽享受。

#### Acceptance Criteria

1. WHEN 遊戲載入 THEN 系統 SHALL 顯示 2D 像素藝術風格的視覺效果
2. WHEN 角色執行動作 THEN 系統 SHALL 播放對應的動畫和音效
3. WHEN 背景音樂播放 THEN 系統 SHALL 使用改編後的 FEZ 原版 BGM
4. WHEN 戰鬥發生 THEN 系統 SHALL 播放符合彈幕射擊節奏的音效