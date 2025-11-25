-- LocalScript in StarterGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerControlGUI"
ScreenGui.ResetOnSpawn = false

-- メインフレーム（ドラッグ可能）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- 黒背景
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(1, 1, 1)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- タイトルバー
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Title.BorderSizePixel = 0
Title.Text = "Player Control Panel - Drag Me"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- プレイヤーリスト用のScrollingFrame
local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Name = "PlayerScrollFrame"
PlayerScrollFrame.Size = UDim2.new(1, -10, 0, 250)
PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 40)
PlayerScrollFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 8
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = MainFrame

-- 選択中のプレイヤー表示
local SelectedPlayerLabel = Instance.new("TextLabel")
SelectedPlayerLabel.Name = "SelectedPlayerLabel"
SelectedPlayerLabel.Size = UDim2.new(1, -10, 0, 30)
SelectedPlayerLabel.Position = UDim2.new(0, 5, 0, 300)
SelectedPlayerLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SelectedPlayerLabel.BorderSizePixel = 0
SelectedPlayerLabel.Text = "Selected: None"
SelectedPlayerLabel.TextColor3 = Color3.new(1, 1, 1)
SelectedPlayerLabel.TextSize = 14
SelectedPlayerLabel.Parent = MainFrame

-- ボタンフレーム
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "ButtonFrame"
ButtonFrame.Size = UDim2.new(1, -10, 0, 50)
ButtonFrame.Position = UDim2.new(0, 5, 0, 340)
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Parent = MainFrame

-- Killボタン
local KillButton = Instance.new("TextButton")
KillButton.Name = "KillButton"
KillButton.Size = UDim2.new(0.48, 0, 1, 0)
KillButton.Position = UDim2.new(0, 0, 0, 0)
KillButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2) -- 赤色
KillButton.BorderSizePixel = 0
KillButton.Text = "KILL"
KillButton.TextColor3 = Color3.new(1, 1, 1)
KillButton.TextSize = 14
KillButton.Font = Enum.Font.GothamBold
KillButton.Parent = ButtonFrame

-- LoopKillボタン
local LoopKillButton = Instance.new("TextButton")
LoopKillButton.Name = "LoopKillButton"
LoopKillButton.Size = UDim2.new(0.48, 0, 1, 0)
LoopKillButton.Position = UDim2.new(0.52, 0, 0, 0)
LoopKillButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8) -- 青色（非アクティブ）
LoopKillButton.BorderSizePixel = 0
LoopKillButton.Text = "LOOP KILL: OFF"
LoopKillButton.TextColor3 = Color3.new(1, 1, 1)
LoopKillButton.TextSize = 12
LoopKillButton.Font = Enum.Font.GothamBold
LoopKillButton.Parent = ButtonFrame

-- 変数
local selectedPlayer = nil
local loopKillActive = false
local playerButtons = {}
local loopKillConnection = nil

-- テキスト入力ボックス作成関数
local function createTextInput(placeholder, positionY, size)
    local textBox = Instance.new("TextBox")
    textBox.Size = size or UDim2.new(0.8, 0, 0, 25)
    textBox.Position = UDim2.new(0.1, 0, 0, positionY)
    textBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    textBox.BorderSizePixel = 0
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.PlaceholderColor3 = Color3.new(0.5, 0.5, 0.5)
    textBox.PlaceholderText = placeholder
    textBox.Text = ""
    textBox.TextSize = 12
    textBox.ClearTextOnFocus = false
    return textBox
end

-- プレイヤーリストを更新する関数
local function updatePlayerList()
    -- 既存のボタンをクリア
    for _, button in pairs(playerButtons) do
        button:Destroy()
    end
    playerButtons = {}
    
    local players = Players:GetPlayers()
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 35)
    
    for i, player in ipairs(players) do
        if player ~= LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Name = player.Name
            playerButton.Size = UDim2.new(1, -10, 0, 30)
            playerButton.Position = UDim2.new(0, 5, 0, (i-1) * 35)
            playerButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            playerButton.BorderSizePixel = 0
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.new(1, 1, 1)
            playerButton.TextSize = 12
            playerButton.Parent = PlayerScrollFrame
            
            playerButton.MouseButton1Click:Connect(function()
                -- 選択状態を更新
                selectedPlayer = player
                SelectedPlayerLabel.Text = "Selected: " .. player.Name
                
                -- すべてのボタンの色をリセット
                for _, btn in pairs(playerButtons) do
                    btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
                end
                
                -- 選択されたボタンの色を変更
                playerButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.8)
            end)
            
            table.insert(playerButtons, playerButton)
        end
    end
end

-- リモートイベントを作成
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local killEvent = Instance.new("RemoteEvent")
killEvent.Name = "KillPlayerEvent"
killEvent.Parent = ReplicatedStorage

-- Killボタンの機能
KillButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        -- サーバーにキルリクエストを送信
        killEvent:FireServer(selectedPlayer, false) -- false = 単発キル
        print("Killed: " .. selectedPlayer.Name)
    else
        print("No player selected!")
    end
end)

-- LoopKillボタンの機能
LoopKillButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        loopKillActive = not loopKillActive
        
        if loopKillActive then
            -- ループキルを開始
            LoopKillButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2) -- 赤色（アクティブ）
            LoopKillButton.Text = "LOOP KILL: ON"
            killEvent:FireServer(selectedPlayer, true) -- true = ループキル開始
            print("Loop Kill STARTED for: " .. selectedPlayer.Name)
        else
            -- ループキルを停止
            LoopKillButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8) -- 青色（非アクティブ）
            LoopKillButton.Text = "LOOP KILL: OFF"
            killEvent:FireServer(selectedPlayer, false) -- false = ループキル停止
            print("Loop Kill STOPPED for: " .. selectedPlayer.Name)
        end
    else
        print("No player selected for Loop Kill!")
    end
end)

-- プレイヤー接続/切断時の更新
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- 選択されたプレイヤーが退出した場合の処理
Players.PlayerRemoving:Connect(function(player)
    if player == selectedPlayer then
        selectedPlayer = nil
        SelectedPlayerLabel.Text = "Selected: None"
        if loopKillActive then
            loopKillActive = false
            LoopKillButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
            LoopKillButton.Text = "LOOP KILL: OFF"
        end
    end
end)

-- 初期リスト作成
updatePlayerList()

-- GUIをプレイヤーに追加
ScreenGui.Parent = PlayerGui

print("Player Control GUI loaded! Drag the title bar to move the window.")
