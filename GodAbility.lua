local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

-- 1. Speed & God Mode
humanoid.WalkSpeed = 120
humanoid.JumpPower = 300
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge

for _, part in ipairs(character:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(150, 0, 255)
	end
end

-- 2. Hover Flight (Hold Spacebar)
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = rootPart

local isSpacePressed = false
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space then isSpacePressed = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then isSpacePressed = false end
end)

task.spawn(function()
	while character and character.Parent do
		task.wait(0.05)
		if isSpacePressed and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
			bodyVelocity.Velocity = Vector3.new(0, 30, 0)
		else
			bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
		end
	end
end)

-- 3. God Hand (Left-Click to strike lightning)
mouse.Button1Down:Connect(function()
	local targetPos = mouse.Hit.Position
	local explosion = Instance.new("Explosion")
	explosion.Position = targetPos
	explosion.BlastRadius = 35
	explosion.BlastPressure = 2000000
	explosion.Parent = workspace
	
	local beam = Instance.new("Part")
	beam.Size = Vector3.new(3, 400, 3)
	beam.Position = targetPos + Vector3.new(0, 200, 0)
	beam.Material = Enum.Material.Neon
	beam.Color = Color3.fromRGB(0, 255, 255)
	beam.Anchored = true
	beam.CanCollide = false
	beam.Parent = workspace
	Debris:AddItem(beam, 0.15)
end)

-- 4. Black Hole (Press E)
mouse.KeyDown:Connect(function(key)
	if key:lower() == "e" then
		local bhPos = mouse.Hit.Position + Vector3.new(0, 5, 0)
		local blackHole = Instance.new("Part")
		blackHole.Size = Vector3.new(5, 5, 5)
		blackHole.Shape = Enum.PartType.Ball
		blackHole.Material = Enum.Material.Glass
		blackHole.Color = Color3.fromRGB(0, 0, 0)
		blackHole.Position = bhPos
		blackHole.Anchored = true
		blackHole.CanCollide = false
		blackHole.Parent = workspace
		
		task.spawn(function()
			for i = 1, 30 do
				task.wait(0.1)
				if not blackHole.Parent then break end
				for _, obj in ipairs(workspace:GetChildren()) do
					if obj:IsA("Model") and obj ~= character then
						local p = obj:FindFirstChild("HumanoidRootPart")
						if p then p.Velocity = (bhPos - p.Position).Unit * 100 end
					elseif obj:IsA("BasePart") and not obj.Anchored and obj ~= blackHole then
						obj.Velocity = (bhPos - obj.Position).Unit * 150
					end
				end
			end
			local finalExplosion = Instance.new("Explosion")
			finalExplosion.Position = bhPos
			finalExplosion.BlastRadius = 50
			finalExplosion.BlastPressure = 5000000
			finalExplosion.Parent = workspace
			blackHole:Destroy()
		end)
	end
end)
print("Overpowered God Mode Activated via Command Bar!")
