local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AwardType = {
	Tokens = 1,
}

local TwitterCodes = {
	Test1 = {Code = "Test1", AwardType = AwardType.Tokens, Amount = 200, Active = true},
}

local successMessage = "Your code has been redeemed successfully. Thanks for the support!"
local emptyMessage = "The code field is empty."
local errorMessage = "Error code not found."
local alreadyUsedMessage = "Code has already been used."
local expiredMessage = "Code has expired!"

local TwitterService = Knit.CreateService({Name = "TwitterService", Client = {}})

function TwitterService.Client:RedeemCode(player: Player, code: string)
	local DataService = Knit.GetService("DataService")
	local CurrencyService = Knit.GetService("CurrencyService")
	
	local foundCode = nil
	
	if type(code) ~= "string" then return end
	local sucess, getReedmedCodes = DataService:Get(player, "RedeemCodes"):await()
	if sucess then
		for _, v in pairs(TwitterCodes) do
			if v.Code:lower() == code:lower() then
				foundCode = _ break
			end
		end
		
		local getCodeInfo = TwitterCodes[foundCode]
		if not foundCode then return false, errorMessage elseif getReedmedCodes[foundCode] then return false, alreadyUsedMessage 
			elseif getCodeInfo.Active == false then return false, expiredMessage end
		
		if getCodeInfo.AwardType == AwardType.Tokens then
			CurrencyService:AddTokens(player, getCodeInfo.Amount)
		end
		getReedmedCodes[foundCode] = true
		return true, successMessage
	end
	return false, errorMessage
end


return TwitterService
