-- Auto-Give Overpowered Weapon (Press K to equip, Right-Click to scope zoom, Left-Click to shoot)
-- Place this single script inside ServerScriptService in any of your games!

local Players = game:GetService("Players")

local function createWeapon(player)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character
	if not backpack then return end
	
	if backpack:FindFirstChild("OverpoweredBlaster") or (character and character:FindFirstChild("OverpoweredBlaster")) then
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = "OverpoweredBlaster"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	local clientScript = Instance.new("LocalScript")
	clientScript.Name = "WeaponClient"
	clientScript.Source = [[
		local Players = game:GetService("Players")
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")
		local Camera = workspace.CurrentCamera

		local player = Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local playerGui = player:WaitForChild("PlayerGui")
		local mouse = player:GetMouse()

		local tool = script.Parent
		local isEquipped = false
		local isZoomed = false
		local defaultFOV = Camera.FieldOfView

		-- Create Cool Static Crosshair & Scope UI
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BlasterGui"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui

		-- Static Center Dot / Crosshair
		local crosshairContainer = Instance.new("Frame")
		crosshairContainer.Name = "CrosshairContainer"
		crosshairContainer.Size = UDim2.new(1, 0, 1, 0)
		crosshairContainer.BackgroundTransparency = 1
		crosshairContainer.Visible = false
		crosshairContainer.Parent = screenGui

		local function createDot(size, pos)
			local dot = Instance.new("Frame")
			dot.Size = size
			dot.Position = pos
			dot.BackgroundColor3 = Color3.fromRGB(0, 255, 128) -- Cyber green static style
			dot.BorderSizePixel = 0
			dot.Parent = crosshairContainer
			return dot
		end

		-- Clean static crosshair elements
		createDot(UDim2.new(0, 4, 0, 4), UDim2.new(0.5, -2, 0.5, -2)) -- Center pixel
		createDot(UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0.5, -15)) -- Top
		createDot(UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0.5, 5)) -- Bottom
		createDot(UDim2.new(0, 10, 0, 2), UDim2.new(0.5, -15, 0.5, -1)) -- Left
		createDot(UDim2.new(0, 10, 0, 2), UDim2.new(0.5, 5, 0.5, -1)) -- Right

		-- Scope Overlay when Right-Clicking
		local scopeOverlay = Instance.new("Frame")
		scopeOverlay.Name = "ScopeOverlay"
		scopeOverlay.Size = UDim2.new(1, 0, 1, 0)
		scopeOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		scopeOverlay.BackgroundTransparency = 1
		scopeOverlay.Visible = false
		scopeOverlay.Parent = screenGui

		-- Handle K key to equip/unequip anywhere
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == Enum.KeyCode.K then
				if character and character:FindFirstChild("Humanoid") then
					local humanoid = character.Humanoid
					if isEquipped then
						humanoid:UnequipTools()
					else
						humanoid:EquipTool(tool)
					end
				end
			end
		end)

		tool.Equipped:Connect(function()
			isEquipped = true
			crosshairContainer.Visible = true
		end)

		tool.Unequipped:Connect(function()
			isEquipped = false
			crosshairContainer.Visible = false
			scopeOverlay.Visible = false
			if isZoomed then
				Camera.FieldOfView = defaultFOV
				isZoomed = false
			end
		end)

		-- Mouse inputs for shooting and scope zooming
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not isEquipped then return end
			
			-- Right Click to Zoom Scope
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				isZoomed = true
				scopeOverlay.Visible = true
				Camera.FieldOfView = 20 -- Heavy sniper/blaster zoom
			end
			
			-- Left Click to Shoot Overpowered Blast
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if hrp then
					-- Create massive overpowered destruction/raycast projectile blast
					local origin = hrp.Position
					local direction = (mouse.Hit.Position - origin).Unit * 1000
					
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {character}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					
					local result = workspace:Raycast(origin, direction, raycastParams)
					
					if result and result.Instance then
						local hitPart = result.Instance
						-- Overpowered physics force or unanchor/launch effect
						if hitPart and not hitPart.Parent:FindFirstChild("Humanoid") then
							hitPart.Anchored = false
							hitPart.AssemblyLinearVelocity = (mouse.Hit.Position - origin).Unit * 500 + Vector3.new(0, 150, 0)
						elseif hitPart and hitPart.Parent:FindFirstChild("Humanoid") then
							-- Deal massive damage if it hits an enemy
							local enemyHumanoid = hitPart.Parent:FindFirstChild("Humanoid")
							enemyHumanoid.Health = 0
						end
					end
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 and isZoomed then
				isZoomed = false
				scopeOverlay.Visible = false
				Camera.FieldOfView = defaultFOV
			end
		end)
	]]

	clientScript.Parent = tool
	tool.Parent = player.Backpack
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(1)
		createWeapon(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		if player.Character then
			createWeapon(player)
		end
		player.CharacterAdded:Connect(function(character)
			task.wait(1)
			createWeapon(player)
		end)
	end)
end
