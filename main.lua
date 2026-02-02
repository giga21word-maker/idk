-- // PROJECT: ORACLE [STANDALONE DIRECT-LINK] //
-- [2026-02-02]
-- ARCHITECT: CHAD
-- VERIFIED SYNTAX: STABLE

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- // 1. FILESYSTEM MANAGER //
local FILENAME = "Oracle_Memory.json"
local DATA = { ApiKey = "", History = {} }

local function SaveData()
    if writefile then
        pcall(function()
            writefile(FILENAME, HttpService:JSONEncode(DATA))
        end)
    end
end

if isfile and isfile(FILENAME) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILENAME)) end)
    if success and decoded then DATA = decoded end
end

-- // 2. UI CONSTRUCTION //
local UI_Target = (gethui and gethui()) or CoreGui
if UI_Target:FindFirstChild("OracleUI") then UI_Target.OracleUI:Destroy() end

local Screen = Instance.new("ScreenGui", UI_Target)
Screen.Name = "OracleUI"
Screen.ResetOnSpawn = false
Screen.DisplayOrder = 999

-- MAIN FRAME
local MainFrame = Instance.new("Frame", Screen)
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 160)
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

-- LOGIN OVERLAY
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
    Label.Text = (isUser and "> " or "[AI]: ") .. tostring(msg)
    Label.TextColor3 = isUser and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(0, 255, 160)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Code
    Label.TextSize = 13
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Size = UDim2.new(1, -10, 0, 0)
    Label.AutomaticSize = Enum.AutomaticSize.Y
    Scroll.CanvasPosition = Vector2.new(0, 99999)
end

for _, entry in ipairs(DATA.History) do
    if entry.user then AddBubble(entry.user, true) end
    if entry.ai then AddBubble(entry.ai, false) end
end

local function GetGameData()
    local info = "Game: " .. game.Name .. ". "
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            local hum = LP.Character.Humanoid
            info = info .. "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. ". "
        end
    end)
    return info
end

local function QueryGemini(prompt)
    if DATA.ApiKey == "" then return end
    AddBubble(prompt, true)
    ChatBox.Text = "Thinking..."
    
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. DATA.ApiKey
    local fullPrompt = "Context: " .. GetGameData() .. "\nUser Question: " .. prompt
    
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if requestFunc then
        task.spawn(function()
            local response = requestFunc({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ contents = {{ parts = {{ text = fullPrompt }} }} })
            })
            ChatBox.Text = ""
            if response and response.StatusCode == 200 then
                local json = HttpService:JSONDecode(response.Body)
                local aiText = json.candidates[1].content.parts[1].text
                AddBubble(aiText, false)
                table.insert(DATA.History, {user = prompt, ai = aiText})
                if #DATA.History > 20 then table.remove(DATA.History, 1) end
                SaveData()
            else
                AddBubble("Error: " .. tostring(response.StatusCode), false)
            end
        end)
    end
end

-- // 4. CONNECTIONS //
AuthBtn.MouseButton1Click:Connect(function()
    local cleanKey = KeyInput.Text:gsub("key=", ""):gsub(" ", "")
    if cleanKey ~= "" then
        DATA.ApiKey = cleanKey
        SaveData()
        LoginFrame.Visible = false
        MainFrame.Visible = true
        AddBubble("Oracle Online.", false)
    end
end)

SendBtn.MouseButton1Click:Connect(function()
    if ChatBox.Text ~= "" and ChatBox.Text ~= "Thinking..." then QueryGemini(ChatBox.Text) end
end)

ChatBox.FocusLost:Connect(function(enter)
    if enter and ChatBox.Text ~= "" and ChatBox.Text ~= "Thinking..." then QueryGemini(ChatBox.Text) end
end)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightAlt and not gpe then
        if DATA.ApiKey ~= "" then MainFrame.Visible = not MainFrame.Visible else LoginFrame.Visible = not LoginFrame.Visible end
    end
end)

print("ORACLE LOADED.")
