local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TwitterController = Knit.CreateController({Name = "TwitterController"})

local CodesUI = Knit.Player.PlayerGui:WaitForChild("Main"):WaitForChild("TwitterCode")
local twitterContainer = CodesUI.Container
local twitterRedeemButton = twitterContainer.Claim
local twitterCodeSection = twitterContainer:WaitForChild("CodeSection")
local twitterCodeSectionTextBox = twitterCodeSection:WaitForChild("TextBox")
local twitterCodeSectionTextBoxTextLabel = twitterCodeSectionTextBox.TextLabel

local successMessage = "Your code has been redeemed successfully. Thanks for the support!"
local emptyMessage = "The code field is empty."
local errorMessage = "Error code not found."
local alreadyUsedMessage = "Code has already been used."
local expiredMessage = "Code has expired!"

--// Main Code 

local value = twitterCodeSectionTextBox.Text
twitterCodeSectionTextBox:GetPropertyChangedSignal("Text"):Connect(function(newText)
	value = tostring(twitterCodeSectionTextBox.Text)
	if value ~= "" then
		twitterCodeSectionTextBoxTextLabel.Visible = false
	else
		twitterCodeSectionTextBoxTextLabel.Visible = true
	end
end)

function TwitterController:KnitStart()
	local TwitterService = Knit.GetService("TwitterService")
	twitterRedeemButton.Trigger.MouseButton1Click:Connect(function()
		local codeToSubmit = twitterCodeSectionTextBox.Text
		twitterCodeSectionTextBox:ReleaseFocus()
		
		if codeToSubmit == "" then
			twitterCodeSectionTextBox.Text = emptyMessage
			twitterCodeSectionTextBox.TextEditable = false
			twitterCodeSectionTextBoxTextLabel.Visible = false
			task.wait(1.3)
			twitterCodeSectionTextBox.Text = ""
			twitterCodeSectionTextBox.TextEditable = true
			twitterCodeSectionTextBoxTextLabel.Visible = true
			return false
		end
		
		local success, message = TwitterService:RedeemCode(codeToSubmit):expect()
		twitterCodeSectionTextBox.Text = message
		twitterCodeSectionTextBox.TextEditable = false
		twitterCodeSectionTextBoxTextLabel.Visible = false
		task.wait(1.3)
		twitterCodeSectionTextBox.Text = ""
		twitterCodeSectionTextBox.TextEditable = true
		twitterCodeSectionTextBoxTextLabel.Visible = true
		return success
	end)
end

return TwitterController
