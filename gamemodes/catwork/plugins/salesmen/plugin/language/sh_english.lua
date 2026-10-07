--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable("en")

-- Salesman setup
lang["#Salesman_Name"] = "Name"
lang["#Salesman_NameRequest"] = "What will the salesman's name be?"
lang["#Salesman_NameEditRequest"] = "Would you like to change the salesman's name?"
lang["#Salesman_ShowChatBubble"] = "Show a chat bubble above the head."
lang["#Salesman_BuyInShipments"] = "Buy / sell items in bulk (5 pcs.)."
lang["#Salesman_PriceScale"] = "Price multiplier."
lang["#Salesman_Flags"] = "Access flags (put '-' before the flags to check ONLY them)."
lang["#Salesman_PhysDesc"] = "Salesman's description."
lang["#Salesman_BuyRate"] = "Selling price multiplier"
lang["#Salesman_BuyRateTip"] = "The number that prices will be multiplied by when selling."
lang["#Salesman_Stock"] = "Default item stock"
lang["#Salesman_StockTip"] = "The amount of items in stock (-1 for infinite)."
lang["#Salesman_Model"] = "Salesman's model."
lang["#Salesman_Cash"] = "Starting cash"
lang["#Salesman_CashTip"] = "The salesman's amount of cash (-1 for infinite)."
lang["#Salesman_Factions"] = "Factions"
lang["#Salesman_FactionsHelp"] = "Leave empty to allow all factions to trade with this salesman."
lang["#Salesman_ClassesHelp"] = "Leave empty to allow all classes to trade with this salesman."
lang["#Salesman_ItemsTip"] = "Items to trade."
lang["#Salesman_SettingsTip"] = "Salesman settings."
lang["#Salesman_SellPriceRequest"] = "How much will the salesman sell this item for?"
lang["#Salesman_BuyPriceRequest"] = "How much will the salesman buy this item for?"

-- Salesman responses
lang["#Salesman_Responses"] = "Responses"
lang["#Salesman_Response_Start"] = "When trading starts."
lang["#Salesman_Response_NoSale"] = "When the player cannot trade with the salesman."
lang["#Salesman_Response_NoStock"] = "When the items are out of stock."
lang["#Salesman_Response_NeedMore"] = "When purchasing an item."
lang["#Salesman_Response_CannotAfford"] = "When the salesman cannot afford an item."
lang["#Salesman_Response_DoneBusiness"] = "When a trade is successful."
lang["#Salesman_Response_Sound"] = "Sound."
lang["#Salesman_Response_HideName"] = "Hide the salesman's name."
lang["#Salesman_Default_Start"] = "How can I help you?"
lang["#Salesman_Default_NoSale"] = "I cannot trade with you!"
lang["#Salesman_Default_NoStock"] = "Everything is sold out!"
lang["#Salesman_Default_CannotAfford"] = "I cannot buy this!"
lang["#Salesman_Default_DoneBusiness"] = "Come again."
lang["#Salesman_Prefill_NoStock"] = "Out of stock!"
lang["#Salesman_Prefill_NeedMore"] = "You do not have enough money!"
lang["#Salesman_Prefill_CannotAfford"] = "I cannot afford that!"
lang["#Salesman_Prefill_DoneBusiness"] = "Thanks for your purchase, see you!"

-- Salesman menu
lang["#Salesman_SellsTip"] = "View items that #1 sells."
lang["#Salesman_BuysTip"] = "View items that #1 buys."
lang["#Salesman_CashInfo"] = "#1 has #2 to their name."

-- Notifications
lang["#Salesman_Says"] = "says"
lang["#Salesman_CannotCarry"] = "You cannot carry that."
lang["#Salesman_YouReceived"] = "You have received #1"
lang["#Salesman_From"] = "from"
lang["#Salesman_YouSold"] = "You have sold 1 x"
lang["#Salesman_To"] = "to"
lang["#Salesman_NotSalesman"] = "This entity is not a salesman!"
lang["#Salesman_LookAtValidEntity"] = "You must look at a valid entity!"
lang["#Salesman_Removed"] = "You have removed a salesman."

-- Commands
lang["#Command_Salesmanadd_Description"] = "Add a salesman at your target position."
lang["#Command_Salesmanadd_Syntax"] = "[number Animation]"
lang["#Command_Salesmanedit_Description"] = "Edit a salesman at your target position."
lang["#Command_Salesmanedit_Syntax"] = "[number Animation]"
lang["#Command_Salesmanremove_Description"] = "Remove a salesman at your target position."
