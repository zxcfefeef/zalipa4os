local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local speed = 340

local humanoid
local character
local noclipEnabled = false
local autoStopEnabled = true
local autoStopBind = Enum.KeyCode.F
local unloaded = false
local menuHidden = false

local connections = {}

local function addConnection(connection)
    table.insert(connections, connection)
    return connection
end

local function disconnectAll()
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(connections)
end

-- База данных тем
local THEMES = {
    Sakura = {
        background = Color3.fromRGB(255, 235, 244),
        header = Color3.fromRGB(255, 174, 204),
        input = Color3.fromRGB(255, 224, 237),
        button = Color3.fromRGB(255, 191, 215),
        buttonHover = Color3.fromRGB(255, 156, 194),
        enabled = Color3.fromRGB(255, 132, 180),
        disabled = Color3.fromRGB(235, 191, 210),
        unload = Color3.fromRGB(218, 104, 137),
        unloadHover = Color3.fromRGB(190, 76, 112),
        text = Color3.fromRGB(105, 48, 73),
        white = Color3.fromRGB(255, 255, 255),
        stroke = Color3.fromRGB(255, 185, 211),
        closeBtn = Color3.fromRGB(255, 120, 170),
        closeBtnHover = Color3.fromRGB(255, 90, 150),
        icon = "🌸"
    },
    DarkOnyx = {
        background = Color3.fromRGB(30, 30, 35),
        header = Color3.fromRGB(45, 45, 50),
        input = Color3.fromRGB(40, 40, 45),
        button = Color3.fromRGB(55, 55, 65),
        buttonHover = Color3.fromRGB(70, 70, 85),
        enabled = Color3.fromRGB(80, 140, 255),
        disabled = Color3.fromRGB(50, 50, 55),
        unload = Color3.fromRGB(235, 80, 80),
        unloadHover = Color3.fromRGB(200, 50, 50),
        text = Color3.fromRGB(230, 230, 235),
        white = Color3.fromRGB(255, 255, 255),
        stroke = Color3.fromRGB(60, 60, 70),
        closeBtn = Color3.fromRGB(55, 55, 65),
        closeBtnHover = Color3.fromRGB(70, 70, 85),
        icon = "🕶️"
    },
    CyberNeon = {
        background = Color3.fromRGB(15, 10, 25),
        header = Color3.fromRGB(35, 20, 60),
        input = Color3.fromRGB(25, 15, 45),
        button = Color3.fromRGB(40, 20, 70),
        buttonHover = Color3.fromRGB(60, 30, 100),
        enabled = Color3.fromRGB(255, 0, 128),
        disabled = Color3.fromRGB(30, 20, 50),
        unload = Color3.fromRGB(200, 0, 0),
        unloadHover = Color3.fromRGB(150, 0, 0),
        text = Color3.fromRGB(0, 240, 255),
        white = Color3.fromRGB(255, 255, 255),
        stroke = Color3.fromRGB(255, 0, 128),
        closeBtn = Color3.fromRGB(35, 20, 60),
        closeBtnHover = Color3.fromRGB(255, 0, 128),
        icon = "⚡"
    },
    MintFresh = {
        background = Color3.fromRGB(230, 245, 235),
        header = Color3.fromRGB(165, 220, 185),
        input = Color3.fromRGB(210, 238, 220),
        button = Color3.fromRGB(185, 230, 200),
        buttonHover = Color3.fromRGB(145, 205, 165),
        enabled = Color3.fromRGB(75, 175, 120),
        disabled = Color3.fromRGB(200, 220, 208),
        unload = Color3.fromRGB(220, 100, 100),
        unloadHover = Color3.fromRGB(190, 70, 70),
        text = Color3.fromRGB(35, 75, 50),
        white = Color3.fromRGB(255, 255, 255),
        stroke = Color3.fromRGB(150, 210, 170),
        closeBtn = Color3.fromRGB(145, 205, 165),
        closeBtnHover = Color3.fromRGB(75, 175, 120),
        icon = "🍃"
    }
}

local currentTheme = THEMES.Sakura
local COLORS = currentTheme

local movingKeys = {
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.D] = false,
}

local function tween(object, duration, properties, direction)
    return TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = object
    return stroke
end

local function autoStop()
    if not autoStopEnabled or unloaded or not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function setSpeed(value)
    local newSpeed = tonumber(value)
    if newSpeed and newSpeed > 0 then
        speed = newSpeed
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end

local function setupCharacter(char)
    if unloaded then return end
    character = char
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speed
end

local dynamicButtons = {}
local function addButtonAnimation(button, themeKeyNormal, themeKeyHover)
    local originalSize = button.Size
    dynamicButtons[button] = { normal = themeKeyNormal, hover = themeKeyHover }

    addConnection(button.MouseEnter:Connect(function()
        if unloaded then return end
        tween(button, 0.12, {
            BackgroundColor3 = currentTheme[dynamicButtons[button].hover],
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 2, originalSize.Y.Scale, originalSize.Y.Offset + 1),
        }):Play()
    end))

    addConnection(button.MouseLeave:Connect(function()
        if unloaded then return end
        tween(button, 0.12, {
            BackgroundColor3 = currentTheme[dynamicButtons[button].normal],
            Size = originalSize,
        }):Play()
    end))

    addConnection(button.MouseButton1Down:Connect(function()
        if unloaded then return end
        tween(button, 0.08, {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 2, originalSize.Y.Scale, originalSize.Y.Offset - 1),
        }):Play()
    end))

    addConnection(button.MouseButton1Up:Connect(function()
        if unloaded then return end
        tween(button, 0.1, {
            Size = originalSize,
        }):Play()
    end))
end

local gui = Instance.new("ScreenGui")
gui.Name = "sikweryyhack"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = COLORS.background
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

addCorner(frame, 18)
local frameStroke = addStroke(frame, COLORS.stroke, 1.5)

local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 24, 0, 24)
hideButton.AnchorPoint = Vector2.new(1, 0)
hideButton.Position = UDim2.new(1, -8, 0, 8)
hideButton.BackgroundColor3 = COLORS.closeBtn
hideButton.TextColor3 = COLORS.white
hideButton.Text = "—"
hideButton.Font = Enum.Font.GothamBold
hideButton.TextSize = 16
hideButton.BorderSizePixel = 0
hideButton.AutoButtonColor = false
hideButton.ZIndex = 100
hideButton.Parent = frame

addCorner(hideButton, 12)
local hideStroke = addStroke(hideButton, COLORS.stroke, 1)

addConnection(hideButton.MouseEnter:Connect(function()
    if unloaded then return end
    tween(hideButton, 0.12, {
        BackgroundColor3 = currentTheme.closeBtnHover,
        Size = UDim2.new(0, 26, 0, 26)
    }):Play()
end))

addConnection(hideButton.MouseLeave:Connect(function()
    if unloaded then return end
    tween(hideButton, 0.12, {
        BackgroundColor3 = currentTheme.closeBtn,
        Size = UDim2.new(0, 24, 0, 24)
    }):Play()
end))

addConnection(hideButton.MouseButton1Down:Connect(function()
    if unloaded then return end
    tween(hideButton, 0.08, {
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
end))

addConnection(hideButton.MouseButton1Up:Connect(function()
    if unloaded then return end
    tween(hideButton, 0.1, {
        Size = UDim2.new(0, 24, 0, 24)
    }):Play()
end))

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, 0)
content.Position = UDim2.new(0, 0, 0, 0)
content.BackgroundTransparency = 1
content.ZIndex = 1
content.Parent = frame

-- Кнопки вкладок (Исправлен порядок: Main -> Themes -> About + уменьшена ширина чтоб не было наложения)
local tabMain = Instance.new("TextButton")
tabMain.Size = UDim2.new(0, 64, 0, 32)
tabMain.Position = UDim2.new(0, 12, 0, 10)
tabMain.BackgroundColor3 = COLORS.enabled
tabMain.TextColor3 = COLORS.white
tabMain.Font = Enum.Font.GothamBold
tabMain.TextSize = 13
tabMain.Text = "Main"
tabMain.BorderSizePixel = 0
tabMain.Parent = content
addCorner(tabMain, 10)

local tabThemes = Instance.new("TextButton")
tabThemes.Size = UDim2.new(0, 66, 0, 32)
tabThemes.Position = UDim2.new(0, 81, 0, 10)
tabThemes.BackgroundColor3 = COLORS.button
tabThemes.TextColor3 = COLORS.text
tabThemes.Font = Enum.Font.GothamBold
tabThemes.TextSize = 13
tabThemes.Text = "Themes"
tabThemes.BorderSizePixel = 0
tabThemes.Parent = content
addCorner(tabThemes, 10)

local tabAbout = Instance.new("TextButton")
tabAbout.Size = UDim2.new(0, 64, 0, 32)
tabAbout.Position = UDim2.new(0, 152, 0, 10)
tabAbout.BackgroundColor3 = COLORS.button
tabAbout.TextColor3 = COLORS.text
tabAbout.Font = Enum.Font.GothamBold
tabAbout.TextSize = 13
tabAbout.Text = "About"
tabAbout.BorderSizePixel = 0
tabAbout.Parent = content
addCorner(tabAbout, 10)

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, -52)
mainPage.Position = UDim2.new(0, 0, 0, 52)
mainPage.BackgroundTransparency = 1
mainPage.Parent = content

local themesPage = Instance.new("Frame")
themesPage.Size = mainPage.Size
themesPage.Position = mainPage.Position
themesPage.BackgroundTransparency = 1
themesPage.Visible = false
themesPage.Parent = content

local aboutPage = Instance.new("Frame")
aboutPage.Size = mainPage.Size
aboutPage.Position = mainPage.Position
aboutPage.BackgroundTransparency = 1
aboutPage.Visible = false
aboutPage.Parent = content

-- Элементы Main страницы
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 135, 0, 36)
speedBox.Position = UDim2.new(0, 12, 0, 0)
speedBox.BackgroundColor3 = COLORS.input
speedBox.TextColor3 = COLORS.text
speedBox.PlaceholderColor3 = Color3.fromRGB(180, 110, 140)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 16
speedBox.Text = tostring(speed)
speedBox.PlaceholderText = "Speed"
speedBox.BorderSizePixel = 0
speedBox.Parent = mainPage
addCorner(speedBox, 10)
local speedStroke = addStroke(speedBox, COLORS.stroke, 1)

local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0, 80, 0, 36)
applyButton.Position = UDim2.new(0, 157, 0, 0)
applyButton.BackgroundColor3 = COLORS.button
applyButton.TextColor3 = COLORS.text
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 15
applyButton.Text = "Apply"
applyButton.BorderSizePixel = 0
applyButton.Parent = mainPage
addCorner(applyButton, 10)

local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1, -24, 0, 36)
noclipButton.Position = UDim2.new(0, 12, 0, 48)
noclipButton.BackgroundColor3 = COLORS.disabled
noclipButton.TextColor3 = COLORS.text
noclipButton.Font = Enum.Font.GothamBold
noclipButton.TextSize = 15
noclipButton.Text = "Noclip: OFF"
noclipButton.BorderSizePixel = 0
noclipButton.Parent = mainPage
addCorner(noclipButton, 10)

local autoStopButton = Instance.new("TextButton")
autoStopButton.Size = UDim2.new(1, -24, 0, 36)
autoStopButton.Position = UDim2.new(0, 12, 0, 96)
autoStopButton.BackgroundColor3 = COLORS.enabled
autoStopButton.TextColor3 = COLORS.white
autoStopButton.Font = Enum.Font.GothamBold
autoStopButton.TextSize = 15
autoStopButton.Text = "AutoStop: ON"
autoStopButton.BorderSizePixel = 0
autoStopButton.Parent = mainPage
addCorner(autoStopButton, 10)

local bindBox = Instance.new("TextBox")
bindBox.Size = UDim2.new(1, -24, 0, 36)
bindBox.Position = UDim2.new(0, 12, 0, 144)
bindBox.BackgroundColor3 = COLORS.input
bindBox.TextColor3 = COLORS.text
bindBox.PlaceholderColor3 = Color3.fromRGB(180, 110, 140)
bindBox.Font = Enum.Font.Gotham
bindBox.TextSize = 15
bindBox.Text = "Bind: F"
bindBox.PlaceholderText = "Bind key"
bindBox.BorderSizePixel = 0
bindBox.Parent = mainPage
addCorner(bindBox, 10)
local bindStroke = addStroke(bindBox, COLORS.stroke, 1)

local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(1, -24, 0, 36)
unloadButton.Position = UDim2.new(0, 12, 0, 192)
unloadButton.BackgroundColor3 = COLORS.unload
unloadButton.TextColor3 = COLORS.white
unloadButton.Font = Enum.Font.GothamBold
unloadButton.TextSize = 15
unloadButton.Text = "Unload"
unloadButton.BorderSizePixel = 0
unloadButton.Parent = mainPage
addCorner(unloadButton, 10)

-- Элементы About страницы
local madeBy = Instance.new("TextLabel")
madeBy.Size = UDim2.new(1, -24, 0, 80)
madeBy.Position = UDim2.new(0, 12, 0, 45)
madeBy.BackgroundTransparency = 1
madeBy.TextColor3 = COLORS.text
madeBy.Font = Enum.Font.GothamBold
madeBy.TextSize = 18
madeBy.TextWrapped = true
madeBy.Text = "made by sikweryy and tide\nInsert = open / close menu"
madeBy.Parent = aboutPage

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 0, 0, 0)
openButton.Position = UDim2.new(0.5, -25, 0.5, -25)
openButton.BackgroundColor3 = COLORS.header
openButton.TextColor3 = COLORS.text
openButton.Text = COLORS.icon
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 25
openButton.Visible = false
openButton.BorderSizePixel = 0
openButton.Parent = gui
addCorner(openButton, 50)
local openStroke = addStroke(openButton, COLORS.stroke, 1.5)

-- Функция динамического обновления темы (включая свернутую кнопку)
local function updateTheme(themeName)
    currentTheme = THEMES[themeName]
    
    local tTime = 0.25
    tween(frame, tTime, {BackgroundColor3 = currentTheme.background}):Play()
    tween(frameStroke, tTime, {Color = currentTheme.stroke}):Play()
    
    tween(hideButton, tTime, {BackgroundColor3 = currentTheme.closeBtn, TextColor3 = currentTheme.white}):Play()
    tween(hideStroke, tTime, {Color = currentTheme.stroke}):Play()
    
    tween(speedBox, tTime, {BackgroundColor3 = currentTheme.input, TextColor3 = currentTheme.text}):Play()
    tween(speedStroke, tTime, {Color = currentTheme.stroke}):Play()
    tween(bindBox, tTime, {BackgroundColor3 = currentTheme.input, TextColor3 = currentTheme.text}):Play()
    tween(bindStroke, tTime, {Color = currentTheme.stroke}):Play()
    
    tween(madeBy, tTime, {TextColor3 = currentTheme.text}):Play()
    
    tween(applyButton, tTime, {BackgroundColor3 = currentTheme.button, TextColor3 = currentTheme.text}):Play()
    tween(unloadButton, tTime, {BackgroundColor3 = currentTheme.unload, TextColor3 = currentTheme.white}):Play()
    
    noclipButton.BackgroundColor3 = noclipEnabled and currentTheme.enabled or currentTheme.disabled
    noclipButton.TextColor3 = noclipEnabled and currentTheme.white or currentTheme.text
    
    autoStopButton.BackgroundColor3 = autoStopEnabled and currentTheme.enabled or currentTheme.disabled
    autoStopButton.TextColor3 = autoStopEnabled and currentTheme.white or currentTheme.text

    -- Обновление навигационных вкладок
    tabMain.BackgroundColor3 = mainPage.Visible and currentTheme.enabled or currentTheme.button
    tabMain.TextColor3 = mainPage.Visible and currentTheme.white or currentTheme.text
    tabThemes.BackgroundColor3 = themesPage.Visible and currentTheme.enabled or currentTheme.button
    tabThemes.TextColor3 = themesPage.Visible and currentTheme.white or currentTheme.text
    tabAbout.BackgroundColor3 = aboutPage.Visible and currentTheme.enabled or currentTheme.button
    tabAbout.TextColor3 = aboutPage.Visible and currentTheme.white or currentTheme.text
    
    -- ОБНОВЛЕНИЕ СВЕРНУТОЙ МЕНЮШКИ ПОД ТЕМУ
    openButton.Text = currentTheme.icon
    tween(openButton, tTime, {BackgroundColor3 = currentTheme.header, TextColor3 = (themeName == "DarkOnyx" or themeName == "CyberNeon") and currentTheme.white or currentTheme.text}):Play()
    tween(openStroke, tTime, {Color = currentTheme.stroke}):Play()
end

-- Создание индивидуально стилизованных кнопок выбора тем
local themeConfig = {
    {name = "Sakura", label = "🌸 Sakura", bg = Color3.fromRGB(255, 191, 215), txt = Color3.fromRGB(105, 48, 73)},
    {name = "DarkOnyx", label = "🕶️ Dark Onyx", bg = Color3.fromRGB(55, 55, 65), txt = Color3.fromRGB(230, 230, 235)},
    {name = "CyberNeon", label = "⚡ Cyber Neon", bg = Color3.fromRGB(0, 240, 255), txt = Color3.fromRGB(15, 10, 25)},
    {name = "MintFresh", label = "🍃 Mint Fresh", bg = Color3.fromRGB(185, 230, 200), txt = Color3.fromRGB(35, 75, 50)}
}

for i, config in ipairs(themeConfig) do
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(1, -24, 0, 36)
    tBtn.Position = UDim2.new(0, 12, 0, (i-1) * 45)
    tBtn.BackgroundColor3 = config.bg
    tBtn.TextColor3 = config.txt
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 14
    tBtn.Text = config.label
    tBtn.BorderSizePixel = 0
    tBtn.Parent = themesPage
    addCorner(tBtn, 10)
    
    -- Кастомная анимация ховера для каждой кнопки темы
    addConnection(tBtn.MouseEnter:Connect(function()
        if unloaded then return end
        tween(tBtn, 0.12, {BackgroundColor3 = config.bg:Lerp(Color3.new(1,1,1), 0.25)}):Play()
    end))
    addConnection(tBtn.MouseLeave:Connect(function()
        if unloaded then return end
        tween(tBtn, 0.12, {BackgroundColor3 = config.bg}):Play()
    end))
    
    addConnection(tBtn.MouseButton1Click:Connect(function()
        updateTheme(config.name)
    end))
end

addButtonAnimation(applyButton, "button", "buttonHover")
addButtonAnimation(noclipButton, "disabled", "button")
addButtonAnimation(autoStopButton, "enabled", "buttonHover")
addButtonAnimation(unloadButton, "unload", "unloadHover")

tween(frame, 0.35, {
    Size = UDim2.new(0, 250, 0, 330),
    BackgroundTransparency = 0,
}):Play()

local function updateNoclipButton()
    noclipButton.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
    noclipButton.BackgroundColor3 = noclipEnabled and currentTheme.enabled or currentTheme.disabled
    noclipButton.TextColor3 = noclipEnabled and currentTheme.white or currentTheme.text
end

local function updateAutoStopButton()
    autoStopButton.Text = autoStopEnabled and "AutoStop: ON" or "AutoStop: OFF"
    autoStopButton.BackgroundColor3 = autoStopEnabled and currentTheme.enabled or currentTheme.disabled
    autoStopButton.TextColor3 = autoStopEnabled and currentTheme.white or currentTheme.text
end

local function openMenu()
    if not menuHidden or unloaded then return end
    menuHidden = false

    local shrinkTween = tween(openButton, 0.18, {
        Size = UDim2.new(0, 0, 0, 0),
    }, Enum.EasingDirection.In)

    shrinkTween:Play()
    shrinkTween.Completed:Wait()

    openButton.Visible = false
    frame.Visible = true

    tween(frame, 0.3, {
        Size = UDim2.new(0, 250, 0, 330),
        BackgroundTransparency = 0,
    }):Play()
end

local function closeMenu()
    if menuHidden or unloaded then return end
    menuHidden = true

    local closeTween = tween(frame, 0.25, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, Enum.EasingDirection.In)

    closeTween:Play()
    closeTween.Completed:Wait()

    openButton.Position = UDim2.new(
        frame.Position.X.Scale,
        frame.Position.X.Offset + 100,
        frame.Position.Y.Scale,
        frame.Position.Y.Offset + 140
    )

    frame.Visible = false
    openButton.Visible = true

    tween(openButton, 0.25, {
        Size = UDim2.new(0, 50, 0, 50),
    }):Play()
end

addConnection(applyButton.MouseButton1Click:Connect(function()
    setSpeed(speedBox.Text)
end))

addConnection(speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        setSpeed(speedBox.Text)
    end
end))

addConnection(noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    updateNoclipButton()
end))

addConnection(autoStopButton.MouseButton1Click:Connect(function()
    autoStopEnabled = not autoStopEnabled
    updateAutoStopButton()
end))

-- Переключение вкладок
local function switchTab(showPage)
    mainPage.Visible = (showPage == mainPage)
    themesPage.Visible = (showPage == themesPage)
    aboutPage.Visible = (showPage == aboutPage)
    
    tabMain.BackgroundColor3 = mainPage.Visible and currentTheme.enabled or currentTheme.button
    tabMain.TextColor3 = mainPage.Visible and currentTheme.white or currentTheme.text
    
    tabThemes.BackgroundColor3 = themesPage.Visible and currentTheme.enabled or currentTheme.button
    tabThemes.TextColor3 = themesPage.Visible and currentTheme.white or currentTheme.text
    
    tabAbout.BackgroundColor3 = aboutPage.Visible and currentTheme.enabled or currentTheme.button
    tabAbout.TextColor3 = aboutPage.Visible and currentTheme.white or currentTheme.text
end

addConnection(tabMain.MouseButton1Click:Connect(function() switchTab(mainPage) end))
addConnection(tabThemes.MouseButton1Click:Connect(function() switchTab(themesPage) end))
addConnection(tabAbout.MouseButton1Click:Connect(function() switchTab(aboutPage) end))

addConnection(bindBox.FocusLost:Connect(function()
    local keyName = bindBox.Text:gsub("Bind:", ""):gsub("%s+", ""):upper()
    local keyCode = Enum.KeyCode[keyName]

    if keyCode then
        autoStopBind = keyCode
        bindBox.Text = "Bind: " .. keyName
    else
        bindBox.Text = "Bind: " .. autoStopBind.Name
    end
end))

addConnection(hideButton.MouseButton1Click:Connect(function()
    closeMenu()
end))

local dragging = false
local dragTarget = nil
local dragStart = nil
local startPos = nil
local draggedOpenButton = false
local DRAG_THRESHOLD = 8

local function startDragging(target, input)
    dragging = true
    dragTarget = target
    dragStart = input.Position
    startPos = target.Position

    if target == openButton then
        draggedOpenButton = false
    end
end

local function stopDragging()
    dragging = false
    dragTarget = nil
    dragStart = nil
    startPos = nil
end

addConnection(frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDragging(frame, input)
    end
end))

addConnection(openButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDragging(openButton, input)
    end
end))

addConnection(UserInputService.InputChanged:Connect(function(input)
    if not dragging or unloaded or not dragTarget or not dragStart or not startPos then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart

        if dragTarget == openButton and delta.Magnitude >= DRAG_THRESHOLD then
            draggedOpenButton = true
        end

        dragTarget.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end))

addConnection(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local wasDraggingOpenButton = dragTarget == openButton
    local wasDragged = draggedOpenButton

    stopDragging()

    if wasDraggingOpenButton and not wasDragged and menuHidden and not unloaded then
        openMenu()
    end
end))

addConnection(UserInputService.JumpRequest:Connect(function()
    if humanoid and not unloaded then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if unloaded or gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        if menuHidden then
            openMenu()
        else
            closeMenu()
        end
        return
    end

    if input.KeyCode == autoStopBind then
        autoStopEnabled = not autoStopEnabled
        updateAutoStopButton()
    end

    if movingKeys[input.KeyCode] ~= nil then
        movingKeys[input.KeyCode] = true
    end
end))

addConnection(UserInputService.InputEnded:Connect(function(input)
    if unloaded then return end

    if movingKeys[input.KeyCode] ~= nil then
        movingKeys[input.KeyCode] = false

        local isMoving = false
        for _, pressed in pairs(movingKeys) do
            if pressed then
                isMoving = true
                break
            end
        end

        if not isMoving then
            autoStop()
        end
    end
end))

addConnection(RunService.Stepped:Connect(function()
    if unloaded or not character then return end

    if humanoid and humanoid.WalkSpeed ~= speed then
        humanoid.WalkSpeed = speed
    end

    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

addConnection(player.CharacterAdded:Connect(setupCharacter))

if player.Character then
    setupCharacter(player.Character)
end

addConnection(unloadButton.MouseButton1Click:Connect(function()
    if unloaded then return end

    unloaded = true
    noclipEnabled = false
    autoStopEnabled = false
    openButton.Visible = false
    frame.Visible = true

    if humanoid then
        humanoid.WalkSpeed = 16
    end

    local closeTween = tween(frame, 0.25, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, Enum.EasingDirection.In)

    closeTween:Play()
    closeTween.Completed:Wait()

    disconnectAll()

    if gui then
        gui:Destroy()
    end
end))
