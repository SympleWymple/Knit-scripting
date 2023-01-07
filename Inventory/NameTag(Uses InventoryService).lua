local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Packages.Knit)
local NametagInfo = require(ReplicatedStorage.SharedModules.Data.Nametags.NametagInfo)
local NametagList = require(ReplicatedStorage.SharedModules.Data.Nametags.NametagList)

type AnimationInfo = {
	Colors: {Color3},
	Gradient: UIGradient,
}

local NametagController = Knit.CreateController({Name = 'NametagController'})

local nametagsFolder = workspace:WaitForChild('Nametags')
local storedTextAnimations: AnimationInfo = {}


function NametagController:UnbindAnimation(target: TextLabel | TextBox | TextButton)
	if storedTextAnimations[target] then
		target.TextColor3 = Color3.fromRGB(255, 255, 255)
		storedTextAnimations[target].Gradient:Destroy()
		storedTextAnimations[target] = nil
	end
end


function NametagController:BindAnimation(target: TextLabel | TextBox | TextButton, colors: {Color3}, animationInfoOverride: AnimationInfo?)
	local animationInfo: AnimationInfo = animationInfoOverride or {}
	
	local FoundExtraGradient = target:FindFirstChildOfClass'UIGradient'
	if FoundExtraGradient then
		FoundExtraGradient:Destroy()
	end
	
	local gradient = Instance.new('UIGradient')
	gradient.Parent = target
	animationInfo.Gradient = gradient

	if (#colors <= 0) then
		animationInfo.Colors = {Color3.new(1, 1, 1)}
	else
		animationInfo.Colors = colors
	end
	
	storedTextAnimations[target] = animationInfo
end


function NametagController:BindAnimationFromKey(target: TextLabel | TextBox | TextButton, key: number)
	self:UnbindAnimation(target)	
	local animationInfo: AnimationInfo = {}
	local tagInfo = NametagInfo[key]
	self:BindAnimation(target, tagInfo.Colors, animationInfo)
end


local function setNametagAnimation(nametag: BillboardGui, animation: string?)
	for _, v in pairs(nametag:GetChildren()) do
		if v:IsA('TextLabel') then
			if animation then
				NametagController:BindAnimationFromKey(v, animation)
			else
				NametagController:UnbindAnimation(v)
			end
		end
	end
end


local function checkNametagAttribute(nametag: BillboardGui)
	local effect = nametag:GetAttribute('NametagEffect')
	local info = NametagInfo[effect]
	if effect == "None" then
		nametag:WaitForChild("Rank").Text = ""
	else
		nametag:WaitForChild("Rank").Text = effect
	end
	if info then
		setNametagAnimation(nametag, effect)
	else
		setNametagAnimation(nametag)
	end
end


local function nametagAdded(nametag: BillboardGui)
	if not nametag:IsA('BillboardGui') then
		return
	end
	
	checkNametagAttribute(nametag)
	nametag:GetAttributeChangedSignal('NametagEffect'):Connect(function()
		checkNametagAttribute(nametag)
	end)
end


function NametagController:KnitStart()
	for _, v in pairs(nametagsFolder:GetChildren()) do
		nametagAdded(v)
	end
		
	nametagsFolder.ChildAdded:Connect(nametagAdded)
	RunService.Heartbeat:Connect(function()

		for label, info in pairs(storedTextAnimations) do
			
			if #info.Colors == 1 then -- It's useless to play a slightly expensive gradient animation if a nametag uses only one color.
				label.TextColor3 = info.Colors[1]
				continue
			else
				label.TextColor3 = Color3.fromRGB(255, 255, 255) -- This is to ensure the gradient color is not messed up.
			end
			
			local progress = (os.clock() % 3 / 3)
			local wrap = false
			local newColors = {}

			for i = 1, #info.Colors + 1 do
				local chosenColor = info.Colors[i] or info.Colors[i - #info.Colors]
				local position = progress + (i - 1)/#info.Colors

				if position > 1 then 
					position -= 1 
				end
				
				if position == 0 or position == 1 then 
					wrap = true 
				end

				table.insert(newColors, ColorSequenceKeypoint.new(math.clamp(position, 0, 1), chosenColor))
			end

			if not wrap then
				local colorLength = 1 / #info.Colors
				local indexProgress = ((1 - progress) / colorLength) + 1
				local col1 = info.Colors[math.floor(indexProgress)]
				local col2 = info.Colors[math.ceil(indexProgress)] or info.Colors[1]
				local finalCol = col1:Lerp(col2, indexProgress % 1) -- find the color between these two cols
				table.insert(newColors, ColorSequenceKeypoint.new(0, finalCol))
				table.insert(newColors, ColorSequenceKeypoint.new(1, finalCol))
			end

			table.sort(newColors, function(a, b)
				return a.Time < b.Time
			end)
			

			info.Gradient.Color = ColorSequence.new(newColors)
		end

	end)	
end


return NametagController
