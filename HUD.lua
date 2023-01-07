local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local HeadUpDisplay = Knit.CreateController({Name = "HeadUpDisplayController"})

local StringManipulation = require(ReplicatedStorage.Utilities.StringManipulation)

local MainScreenGui = Knit.Player.PlayerGui:WaitForChild("Main")
local HUDFrame = MainScreenGui:WaitForChild("HUD")

local TokenHUDFrame = HUDFrame:WaitForChild("Tokens")
local RaisedHUDFrame = HUDFrame:WaitForChild("RaisedFrame")
local InvestedHUdFrame = HUDFrame:WaitForChild("InvestFrame")


function HeadUpDisplay:KnitStart()
	local StatsController = Knit.GetController("StatsController")
	--> Tokens
	StatsController.TokensChanged:Connect(function(amount: number)
		TokenHUDFrame.Value.Text = StringManipulation:FormatNumbers(amount)
	end)
	TokenHUDFrame.Value.Text = StringManipulation:FormatNumbers(StatsController:GetTokens())
	
	--> Raised
	StatsController.RaisedChanged:Connect(function(amount: number)
		RaisedHUDFrame.Value.Text = tostring(amount)
	end)
	RaisedHUDFrame.Value.Text = tostring(StatsController:GetRaised())
	
	--> Invested
	StatsController.InvestedChanged:Connect(function(amount: number)
		InvestedHUdFrame.Value.Text = tostring(amount)
	end)
	InvestedHUdFrame.Value.Text = tostring(StatsController:GetInvested())
end

return HeadUpDisplay
