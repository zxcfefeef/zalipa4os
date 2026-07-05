-- Roblox Studio: sikweryyhack | Sakura Theme (No Title Bar)

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

local COLORS = {
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
}

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

local function addButtonAnimation(button, normalColor, hoverColor)
	local originalSize = button.Size

	addConnection(button.MouseEnter:Connect(function()
		if unloaded then return end
		tween(button, 0.12, {
			BackgroundColor3 = hoverColor,
			Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 2, originalSize.Y.Scale, originalSize.Y.Offset + 1),
		}):Play()
	end))

	addConnection(button.MouseLeave:Connect(function()
		if unloaded then return end
		tween(button, 0.12, {
			BackgroundColor3 = normalColor,
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
addStroke(frame, COLORS.stroke, 1.5)

local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 24, 0, 24)
hideButton.AnchorPoint = Vector2.new(1, 0)
hideButton.Position = UDim2.new(1, -8, 0, 8)
hideButton.BackgroundColor3 = Color3.fromRGB(255, 120, 170)
hideButton.TextColor3 = COLORS.white
hideButton.Text = "—"
hideButton.Font = Enum.Font.GothamBold
hideButton.TextSize = 16
hideButton.BorderSizePixel = 0
hideButton.AutoButtonColor = false
hideButton.ZIndex = 100
hideButton.Parent = frame

addCorner(hideButton, 12)
addStroke(hideButton, Color3.fromRGB(255, 170, 205), 1)

addConnection(hideButton.MouseEnter:Connect(function()
	if unloaded then return end
	tween(hideButton, 0.12, {
		BackgroundColor3 = Color3.fromRGB(255, 90, 150),
		Size = UDim2.new(0, 26, 0, 26)
	}):Play()
end))

addConnection(hideButton.MouseLeave:Connect(function()
	if unloaded then return end
	tween(hideButton, 0.12, {
		BackgroundColor3 = Color3.fromRGB(255, 120, 170),
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

local tabMain = Instance.new("TextButton")
tabMain.Size = UDim2.new(0, 90, 0, 32)
tabMain.Position = UDim2.new(0, 12, 0, 10)
tabMain.BackgroundColor3 = COLORS.enabled
tabMain.TextColor3 = COLORS.white
tabMain.Font = Enum.Font.GothamBold
tabMain.TextSize = 14
tabMain.Text = "Main"
tabMain.BorderSizePixel = 0
tabMain.Parent = content
addCorner(tabMain, 10)

local tabAbout = Instance.new("TextButton")
tabAbout.Size = UDim2.new(0, 90, 0, 32)
tabAbout.Position = UDim2.new(0, 108, 0, 10)
tabAbout.BackgroundColor3 = COLORS.button
tabAbout.TextColor3 = COLORS.text
tabAbout.Font = Enum.Font.GothamBold
tabAbout.TextSize = 14
tabAbout.Text = "About"
tabAbout.BorderSizePixel = 0
tabAbout.Parent = content
addCorner(tabAbout, 10)

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, -52)
mainPage.Position = UDim2.new(0, 0, 0, 52)
mainPage.BackgroundTransparency = 1
mainPage.Parent = content

local aboutPage = Instance.new("Frame")
aboutPage.Size = mainPage.Size
aboutPage.Position = mainPage.Position
aboutPage.BackgroundTransparency = 1
aboutPage.Visible = false
aboutPage.Parent = content

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
addStroke(speedBox, COLORS.stroke, 1)

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
addStroke(bindBox, COLORS.stroke, 1)

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

local madeBy = Instance.new("TextLabel")
madeBy.Size = UDim2.new(1, -24, 0, 80)
madeBy.Position = UDim2.new(0, 12, 0, 45)
madeBy.BackgroundTransparency = 1
madeBy.TextColor3 = COLORS.text
madeBy.Font = Enum.Font.GothamBold
madeBy.TextSize = 18
madeBy.TextWrapped = true
madeBy.Text = "made by sikweryy and tide"
madeBy.Parent = aboutPage

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 0, 0, 0)
openButton.Position = UDim2.new(0.5, -25, 0.5, -25)
openButton.BackgroundColor3 = COLORS.header
openButton.TextColor3 = COLORS.text
openButton.Text = "🌸"
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 25
openButton.Visible = false
openButton.BorderSizePixel = 0
openButton.Parent = gui
addCorner(openButton, 50)
addStroke(openButton, COLORS.stroke, 1.5)

addButtonAnimation(applyButton, COLORS.button, COLORS.buttonHover)
addButtonAnimation(noclipButton, COLORS.disabled, COLORS.button)
addButtonAnimation(autoStopButton, COLORS.enabled, COLORS.buttonHover)
addButtonAnimation(unloadButton, COLORS.unload, COLORS.unloadHover)

tween(frame, 0.35, {
	Size = UDim2.new(0, 250, 0, 330),
	BackgroundTransparency = 0,
}):Play()

local function updateNoclipButton()
	noclipButton.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
	noclipButton.BackgroundColor3 = noclipEnabled and COLORS.enabled or COLORS.disabled
	noclipButton.TextColor3 = noclipEnabled and COLORS.white or COLORS.text
end

local function updateAutoStopButton()
	autoStopButton.Text = autoStopEnabled and "AutoStop: ON" or "AutoStop: OFF"
	autoStopButton.BackgroundColor3 = autoStopEnabled and COLORS.enabled or COLORS.disabled
	autoStopButton.TextColor3 = autoStopEnabled and COLORS.white or COLORS.text
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

addConnection(tabMain.MouseButton1Click:Connect(function()
	mainPage.Visible = true
	aboutPage.Visible = false
	tabMain.BackgroundColor3 = COLORS.enabled
	tabMain.TextColor3 = COLORS.white
	tabAbout.BackgroundColor3 = COLORS.button
	tabAbout.TextColor3 = COLORS.text
end))

addConnection(tabAbout.MouseButton1Click:Connect(function()
	mainPage.Visible = false
	aboutPage.Visible = true
	tabAbout.BackgroundColor3 = COLORS.enabled
	tabAbout.TextColor3 = COLORS.white
	tabMain.BackgroundColor3 = COLORS.button
	tabMain.TextColor3 = COLORS.text
end))

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
