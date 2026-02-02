-- // PROJECT: ORACLE [STANDALONE DIRECT-LINK] //
-- [2026-02-02]
-- ARCHITECT: CHAD
-- FEATURES: No Python Server Needed, Local Memory Save, Game Context Awareness

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

-- // 1. FILESYSTEM MANAGER //
local FILENAME = "Oracle_Memory.json"
local DATA = {
    ApiKey = "",
    History = {}
}

-- Load Data if exists
if isfile and isfile(FILENAME) then
    local content = readfile(FILENAME)
    local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if success and decoded then
        DATA = decoded
    end
end

local function SaveData()
    if writefile then
        writefile(FILENAME, HttpService:JSONEncode(DATA))
    end
end

-- // 2. UI CONSTRUCTION //
-- MODIFIED: Use gethui() if available to bypass UI detection and prevent parenting errors
local UI_Target = (gethui and gethui()) or CoreGui

if UI_Target:FindFirstChild("OracleUI") then UI_Target.OracleUI:Destroy() end
local Screen = Instance.new("ScreenGui", UI_Target)
Screen.Name = "OracleUI"
Screen.ResetOnSpawn = false -- Ensure UI stays after death

-- THE MAIN FRAME
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Hidden by default
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 160) -- Oracle Green
Stroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ORACLE // NEURAL LINK"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.Code

-- LOGIN OVERLAY (If no API Key)
local LoginFrame = Instance.new("Frame", Screen)
LoginFrame.Size = UDim2.new(0, 300, 0, 140)
LoginFrame.Position = UDim2.new(0.5, -150, 0.5, -70)
LoginFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
LoginFrame.Visible = (DATA.ApiKey == "")
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", LoginFrame).Color = Color3.fromRGB(0, 255, 160)

local LoginText = Instance.new("TextLabel", LoginFrame)
LoginText.Size = UDim2.new(1, 0, 0, 40)
LoginText.BackgroundTransparency = 1
LoginText.Text = "AUTHENTICATION REQUIRED"
LoginText.TextColor3 = Color3.fromRGB(0, 255, 160)
LoginText.Font = Enum.Font.Code

local KeyInput = Instance.new("TextBox", LoginFrame)
KeyInput.Size = UDim2.new(0.9, 0, 0, 35)
KeyInput.Position = UDim2.new(0.05, 0, 0.4, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
KeyInput.TextColor3 = Color3.new(1, 1, 1)
KeyInput.PlaceholderText = "Paste Gemini API Key Here"
KeyInput.Font = Enum.Font.Code
Instance.new("UICorner", KeyInput)

local AuthBtn = Instance.new("TextButton", LoginFrame)
AuthBtn.Size = UDim2.new(0.5, 0, 0, 30)
AuthBtn.Position = UDim2.new(0.25, 0, 0.75, 0)
AuthBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 160)
AuthBtn.Text = "CONNECT"
AuthBtn.Font = Enum.Font.Code
Instance.new("UICorner", AuthBtn)

-- CHAT AREA
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -85)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 3
local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0, 6)
List.SortOrder = Enum.SortOrder.LayoutOrder

local ChatBox = Instance.new("TextBox", MainFrame)
ChatBox.Size = UDim2.new(1, -70, 0, 35)
ChatBox.Position = UDim2.new(0, 5, 1, -40)
ChatBox.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
ChatBox.TextColor3 = Color3.new(1, 1, 1)
ChatBox.Font = Enum.Font.Code
ChatBox.PlaceholderText = "Query the Oracle..."
ChatBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", ChatBox)

local SendBtn = Instance.new("TextButton", MainFrame)
SendBtn.Size = UDim2.new(0, 60, 0, 35)
SendBtn.Position = UDim2.new(1, -65, 1, -40)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 160)
SendBtn.Text = "SEND"
SendBtn.Font = Enum.Font.Code
Instance.new("UICorner", SendBtn)

-- // 3. CORE LOGIC //

local function AddBubble(msg, isUser)
    local Label = Instance.new("TextLabel", Scroll)
    Label.Text = (isUser and "> " or "[AI]: ") .. msg
    Label.TextColor3 = isUser and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(0, 255, 160)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Code
    Label.TextSize = 13
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Size = UDim2.new(1, -10, 0, 0)
    
    -- Auto-resize
    Label.AutomaticSize = Enum.AutomaticSize.Y
    
    Scroll.CanvasPosition = Vector2.new(0, 99999)
end

-- Restore History from File
for _, entry in ipairs(DATA.History) do
    AddBubble(entry.user or entry.u, true)
    AddBubble(entry.ai or entry.a, false)
end

local function GetGameData()
    local info = "Game: " .. game.Name .. ". "
    if LP.Character then
        local hum = LP.Character:FindFirstChild("Humanoid")
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if hum then info = info .. "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. ". " end
        if root then info = info .. "Pos: " .. tostring(root.Position) .. ". " end
    end
    
    -- Enemy Scan
    local nearby = 0
    pcall(function() -- Wrap in pcall to prevent error if players/characters are nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("PrimaryPart") and LP.Character and LP.Character:FindFirstChild("PrimaryPart") then
                local dist = (p.Character.PrimaryPart.Position - LP.Character.PrimaryPart.Position).Magnitude
                if dist < 80 then nearby = nearby + 1 end
            end
        end
    end)
    info = info .. "Enemies nearby (<80m): " .. nearby .. "."
    return info
end

local function QueryGemini(prompt)
    if DATA.ApiKey == "" then AddBubble("Error: No API Key", false) return end
    
    AddBubble(prompt, true)
    ChatBox.Text = "Thinking..."
    
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. DATA.ApiKey
    
    -- Construct Prompt with Context
    local context = GetGameData()
    local fullPrompt = "SYSTEM: You are a tactical AI in Roblox. Context: " .. context .. "\nUSER: " .. prompt
    
    local payload = {
        contents = {
            { parts = { { text = fullPrompt } } }
        }
    }
    
    -- FIX: Expanded check for various executor request methods
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if req then
        task.spawn(function()
            local response = req({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
            
            ChatBox.Text = ""
            
            if response and response.StatusCode == 200 then
                local success, json = pcall(function() return HttpService:JSONDecode(response.Body) end)
                if success and json.candidates and json.candidates[1].content.parts[1].text then
                    local aiText = json.candidates[1].content.parts[1].text
                    AddBubble(aiText, false)
                    
                    -- Save to Memory
                    table.insert(DATA.History, {user = prompt, ai = aiText})
                    if #DATA.History > 50 then table.remove(DATA.History, 1) end -- Keep last 50
                    SaveData()
                else
                    AddBubble("AI response parsing failed.", false)
                end
            else
                local code = response and response.StatusCode or "TIMEOUT"
                AddBubble("API Error: " .. tostring(code), false)
            end
        end)
    else
        AddBubble("Executor missing 'request' function.", false)
    end
end

-- // 4. CONNECTIONS //
AuthBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text ~= "" then
        DATA.ApiKey = KeyInput.Text
        SaveData()
        LoginFrame.Visible = false
        MainFrame.Visible = true
        AddBubble("Oracle Linked. Ready.", false)
    end
end)

SendBtn.MouseButton1Click:Connect(function()
    if ChatBox.Text ~= "" then QueryGemini(ChatBox.Text) end
end)
ChatBox.FocusLost:Connect(function(enter)
    if enter and ChatBox.Text ~= "" then QueryGemini(ChatBox.Text) end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightAlt and not gpe then
        if DATA.ApiKey ~= "" then
            MainFrame.Visible = not MainFrame.Visible
        else
            LoginFrame.Visible = not LoginFrame.Visible
        end
    end
end)

-- Startup
print("ORACLE LOADED. Press Right-Alt to toggle.")
if DATA.ApiKey ~= "" then
    AddBubble("Welcome back. Press Right-Alt to toggle.", false)
end
