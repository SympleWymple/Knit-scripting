local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)


local StatsController = Knit.CreateController({Name = "StatsController"})
StatsController.TokensChanged = Signal.new()
StatsController.RaisedChanged = Signal.new()
StatsController.InvestedChanged = Signal.new()

local tokens = 0
local raised = 0
local invested = 0


local function loadStats()
	local CurrencyService = Knit.GetService("CurrencyService")
	--> Tokens
	CurrencyService:GetTokens():andThen(function(amount: number)
		tokens = amount 
		StatsController.TokensChanged:Fire(amount)
	end)
	
	CurrencyService.TokensChanged:Connect(function(newAmount: number)
		tokens = newAmount
		StatsController.TokensChanged:Fire(newAmount)
	end)
	
	--> Raised
	CurrencyService:GetRaised():andThen(function(amount: number)
		raised = amount
		StatsController.RaisedChanged:Fire(amount)
	end)

	CurrencyService.RaisedChanged:Connect(function(newAmount: number)
		raised = newAmount
		StatsController.RaisedChanged:Fire(newAmount)
	end)
	
	--> Invested
	CurrencyService:GetInvested():andThen(function(amount: number)
		invested = amount
		StatsController.InvestedChanged:Fire(amount)
	end)

	CurrencyService.InvestedChanged:Connect(function(newAmount: number)
		invested = newAmount
		StatsController.InvestedChanged:Fire(newAmount)
	end)
end


function StatsController:KnitInit()
	loadStats()
end
function StatsController:GetTokens()
	return tokens
end
function StatsController:GetRaised()
	return raised
end
function StatsController:GetInvested()
	return invested
end
return StatsController
