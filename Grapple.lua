local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local isFKeyPressed = false
local isGKeyPressed = false
local isGrappling = false
local grappleCooldown = 1.0
local lastGrappleTime = 0
local targetedPart = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbilityHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(0, 180, 0, 70)
hudFrame.Position = UDim2.new(0.05, 0, 0.8, 0)
hudFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
hudFrame.BorderSizePixel = 0
hudFrame.Active = true
hudFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = hudFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 22)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "CONTROLS"
titleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = hudFrame

local guideLabel = Instance.new("TextLabel")
guideLabel.Size = UDim2.new(1, 0, 0, 40)
guideLabel.Position = UDim2.new(0, 0, 0, 22)
guideLabel.BackgroundTransparency = 1
guideLabel.Text = "[F] + Click: Grapple\n[G] + Click: Pull Part"
guideLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
guideLabel.TextSize = 11
guideLabel.Font = Enum.Font.GothamSemibold
guideLabel.Parent = hudFrame

local dragging, dragInput, dragStart, startPos

hudFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = hudFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

hudFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        hudFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        isFKeyPressed = true
    elseif input.KeyCode == Enum.KeyCode.G then
        isGKeyPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        isFKeyPressed = false
    elseif input.KeyCode == Enum.KeyCode.G then
        isGKeyPressed = false
        targetedPart = nil
    end
end)

mouse.Button1Down:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local targetPosition = mouse.Hit.Position

    if isFKeyPressed and not isGrappling then
        if tick() - lastGrappleTime < grappleCooldown then return end
        lastGrappleTime = tick()
        
        if (targetPosition - hrp.Position).Magnitude > 250 then return end
        
        isGrappling = true
        humanoid.PlatformStand = true
        
        local beamPart = Instance.new("Part")
        beamPart.Size = Vector3.new(0.3, 0.3, 1)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Transparency = 0.2
        beamPart.Material = Enum.Material.Neon
        beamPart.BrickColor = BrickColor.new("Cyan")
        beamPart.Parent = workspace
        Debris:AddItem(beamPart, 0.5)
        
        local speed = 100
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not char or not hrp then
                if connection then connection:Disconnect() end
                return
            end
            
            local currentPos = hrp.Position
            local direction = (targetPosition - currentPos)
            
            if direction.Magnitude < 6 or not isGrappling then
                connection:Disconnect()
                isGrappling = false
                humanoid.PlatformStand = false
                hrp.AssemblyLinearVelocity = Vector3.new(0, 50, 0) + (direction.Unit * 35)
                if beamPart then beamPart:Destroy() end
            else
                hrp.AssemblyLinearVelocity = direction.Unit * speed
                if beamPart then
                    beamPart.CFrame = CFrame.new(currentPos:Lerp(targetPosition, 0.5), targetPosition)
                    beamPart.Size = Vector3.new(0.3, 0.3, direction.Magnitude)
                end
            end
        end)

    elseif isGKeyPressed then
        local target = mouse.Target
        if target and target:IsA("BasePart") and not target.Anchored then
            targetedPart = target
        else
            targetedPart = nil
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if isGKeyPressed and targetedPart and targetedPart.Parent and not targetedPart.Anchored then
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        pcall(function()
            local holdPosition = hrp.Position + (hrp.CFrame.LookVector * 6) + Vector3.new(0, 2, 0)
            targetedPart.AssemblyLinearVelocity = (holdPosition - targetedPart.Position) * 12
        end)
    else
        targetedPart = nil
    end
end)
