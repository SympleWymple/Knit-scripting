local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)

local CurrencyService = Knit.CreateService({Name = "CurrencyService", Client = {}})

CurrencyService.TokensChanged = Signal.new()
CurrencyService.Client.TokensChanged = Knit.CreateSignal()

CurrencyService.RaisedChanged = Signal.new()
CurrencyService.Client.RaisedChanged = Knit.CreateSignal()

CurrencyService.InvestedChanged = Signal.new()
CurrencyService.Client.InvestedChanged = Knit.CreateSignal()

--> Tokens
function CurrencyService:AddTokens(player: Player, amount: number)
	local DataService = Knit.GetService("DataService")

	amount = math.ceil(amount)
	DataService:Increment(player, "Tokens", amount)

	local NewTokenAmount = CurrencyService:GetTokens(player):expect()
	self.TokensChanged:Fire(player, NewTokenAmount)
	self.Client.TokensChanged:Fire(player, NewTokenAmount)
end


function CurrencyService:GetTokens(player: Player)
	return Promise.new(function(resolve, reject)
		local DataService = Knit.GetService("DataService")	
		local loaded, value = DataService:Get(player, "Tokens"):await()
		if loaded then
			resolve(value)
		else
			reject()
		end		
	end)
end

function CurrencyService.Client:GetTokens(...)
	return self.Server:GetTokens(...):expect()
end

--> Raised
function CurrencyService:AddRasied(player: Player, amount: number)
	local DataService = Knit.GetService("DataService")

	amount = math.ceil(amount)
	DataService:Increment(player, "Raised", amount)

	local NewTokenAmount = CurrencyService:GetTokens(player):expect()
	self.TokensChanged:Fire(player, NewTokenAmount)
	self.Client.TokensChanged:Fire(player, NewTokenAmount)
end


function CurrencyService:GetRasied(player: Player)
	return Promise.new(function(resolve, reject)
		local DataService = Knit.GetService("DataService")	
		local loaded, value = DataService:Get(player, "Raised"):await()
		if loaded then
			resolve(value)
		else
			reject()
		end		
	end)
end

function CurrencyService.Client:GetRaised(...)
	return self.Server:GetRasied(...):expect()
end

--> Invested
function CurrencyService:AddInvested(player: Player, amount: number)
	local DataService = Knit.GetService("DataService")

	amount = math.ceil(amount)
	DataService:Increment(player, "Invested", amount)

	local NewTokenAmount = CurrencyService:GetTokens(player):expect()
	self.TokensChanged:Fire(player, NewTokenAmount)
	self.Client.TokensChanged:Fire(player, NewTokenAmount)
end


function CurrencyService:GetInvested(player: Player)
	return Promise.new(function(resolve, reject)
		local DataService = Knit.GetService("DataService")	
		local loaded, value = DataService:Get(player, "Invested"):await()
		if loaded then
			resolve(value)
		else
			reject()
		end		
	end)
end

function CurrencyService.Client:GetInvested(...)
	return self.Server:GetInvested(...):expect()
end
return CurrencyService
