PetMarket = LibStub ("AceAddon-3.0"):NewAddon ("PetMarket", "AceEvent-3.0", "AceTimer-3.0")

-- Pet lists
PetMarket.KnownPets = {}
PetMarket.PetItems = {
	[44822]=7561, 	-- Albino Snake
	[44984]=33205, 	-- Ammen Vale Lashling
	[11023]=7394, 	-- Ancona Chicken
	[63398]=48242, 	-- Armadillo Pup
	[34535]=7547, 	-- Azure Whelpling
	[10360]=7565, 	-- Black Kingsnake
	[8491]=7383, 	-- Black Tabby Cat
	[29958]=21056, 	-- Blue Dragonhawk Hatchling
	[29901]=21010, 	-- Blue Moth
	[8485]=7385, 	-- Bombay Cat
	[10394]=14421, 	-- Brown Prairie Dog
	[29364]=20472, 	-- Brown Rabbit
	[10361]=7562, 	-- Brown Snake
	[46398]=34364, 	-- Calico Cat
	[64372]=48609, 	-- Clockwork Gnome
	[39898]=32591, 	-- Cobra Hatchling
	[8496]=7390, 	-- Cockatiel
	[8486]=7384, 	-- Cornish Rex Cat
	[71076]=54128, 	-- Creepy Crate
	[10392]=7567, 	-- Crimson Snake
	[8499]=7544, 	-- Crimson Whelpling
	[10822]=7543, 	-- Dark Whelpling
	[91040]=67332, 	-- Darkmoon Eye
	[91003]=67319, 	-- Darkmoon Hatchling
	[48112]=35396, 	-- Darting Hatchling
	[60216]=43916, 	-- De-Weaponized Mechanical Companion
	[48114]=35395, 	-- Deviate Hatchling
	[20769]=15429, 	-- Disgusting Oozeling
	[44970]=33194, 	-- Dun Morogh Cub
	[44973]=33198, 	-- Durotar Scorpion
	[67282]=50722, 	-- Elementium Geode
	[44974]=33200, 	-- Elwyn Lamb
	[8498]=7545, 	-- Emerald Whelpling
	[44982]=33227, 	-- Enchanted Broom
	[67274]=46898, 	-- Enchanted Lantern
	[21305]=15698, 	-- Father Winter's Helper
	[70908]=53884, 	-- Feline Familiar
	[74611]=55574, 	-- Festival Lantern
	[29960]=21076, 	-- Firefly
	[29953]=21055, 	-- Golden Dragonhawk Hatchling
	[8500]=7553, 	-- Great Horned Owl
	[8492]=7387, 	-- Green Wing Macaw
	[72068]=53283, 	-- Guardian Cub
	[48116]=35400, 	-- Gundrak Hatchling
	[8501]=7555, 	-- Hawk Owl
	[8494]=7391, 	-- Hyacinth Macaw
	[82774]=61877, 	-- Jade Owl
	[48118]=35387, 	-- Leaping Hatching
	[15996]=12419, 	-- Lifelike Toad
	[11826]=9657, 	-- Lil' Smoky
	[74610]=55571, 	-- Lunar Lantern
	[67275]=50545, 	-- Magic Lamp
	[29363]=20408, 	-- Mana Wyrmling
	[10398]=8376, 	-- Mechanical Chicken
	[4401]=2671, 	-- Mechanical Squirrel
	[45002]=33274, 	-- Mechanopeep
	[44980]=33219, 	-- Mulgore Hatchling
	[48120]=35399, 	-- Obsidian Hatchling
	[8487]=7382, 	-- Orange Tabby Cat
	[22235]=16085, 	-- Peddlefeet
	[59597]=43800, 	-- Personal World Destroyer
	[11825]=9656, 	-- Pet Bombling
	[94903]=70082, 	-- Pierre
	[46707]=24753, 	-- Pint-Sized Pink Pachyderm
	[44721]=32592, 	-- Proto-Drake Whelp
	[69821]=53225, 	-- Pterrordax Hatchling
	[100905]=71693, -- Rascal-Bot
	[48122]=35397, 	-- Ravasaur Hatchling
	[48124]=35398, 	-- Razormaw Hatchling
	[48126]=35394, 	-- Razzashi Hatchling
	[85222]=63370, 	-- Red Cricket
	[29956]=21064, 	-- Red Dragonhawk Hatchling
	[29902]=21009, 	-- Red Moth
	[104317]=73741, -- Rotten Little Helper
	[45606]=33810, 	-- Sen'Jin Fetish
	[8495]=7389, 	-- Senegal
	[8490]=7380, 	-- Siamese Cat
	[29957]=21063, 	-- Silver Dragonhawk Hatchling
	[8488]=7381, 	-- Silver Tabby Cat
	[33154]=23909, 	-- Sinister Squashling
	[8497]=7560, 	-- Snowshoe Rabbit
	[23083]=16701, 	-- Spirit of Summer
	[44794]=32791, 	-- Spring Rabbit
	[44965]=33188, 	-- Teldrassil Sproutling
	[39896]=32589, 	-- Tickbird Hatchling
	[21309]=15710, 	-- Tiny Snowman
	[44971]=33197, 	-- Trisfal Batling
	[21277]=15699, 	-- Tranquil Mechanical Yeti
	[11026]=7549, 	-- Tree Frog
	[10393]=7395, 	-- Undercity Cockroach
	[8489]=7386, 	-- White Kitten
	[29904]=21018, 	-- White Moth
	[39899]=32590, 	-- White Tickbird Hatchling
	[21308]=15706, 	-- Winter Reindeer
	[21301]=15705, 	-- Winter's Little Helper
	[69239]=52831, 	-- Winterspring Cub
	[11027]=7550, 	-- Wood Frog
	[29903]=21008, 	-- Yellow Moth
	[89367]=66105,  -- Yu'lon Kite
	[89368]=66104, 	-- Chi-ji Kite
	[80008]=59358, 	-- Darkmoon Rabbit
	[87526]=64899, 	-- Mechanical Pandaren Dragonling
	[89587]=61086, 	-- Porcupette 
	[82775]=61883, 	-- Sapphire Cub
	[85220]=63365, 	-- Terrible Turnip
	[85447]=63559, 	-- Tiny Goldfish
	[90900]=67230, 	-- Imperial Moth
	[90902]=67233, 	-- Imperial Silkworm
	[94595]=70098, 	-- Spawn of G'nathus
	[94190]=69848, 	-- Spectral Porcupette
	[94933]=70258, 	-- Tiny Blue Carp
	[94934]=70259, 	-- Tiny Green Carp
	[94932]=70257, 	-- Tiny Red Carp
	[94935]=70260, 	-- Tiny White Carp
	[94573]=70154, 	-- Direhorn Runt
	[97959]=71199, 	-- Living Fluid
	[94574]=70083, 	-- Pygmy Direhorn
	[97960]=71200, 	-- Viscous Horror
	[101570]=72160, -- Moon Moon
	-- WoD
	[118675]=7546,  -- Bronze Whelpling
	[116804]=86067, -- Widget the Departed
	[111660]=77221,	-- Iron Starlette
	[116801]=86061,	-- Cursed Birman
	[111402]=79410, -- Mechanical Axebeak
	[112057]=80329, -- Lifelike Mechanical Frostboar
	[116064]=85527, -- Syd the Squid
	[116403]=85846, -- Bush Chicken
	[117404]=86445, -- Land Shark
	[117528]=86532, -- Lanticore Spawnling
	[118595]=83594, -- Nightshade Sproutling
	[118598]=83588, -- Sun Sproutling
	[118600]=83583, -- Forest Sproutling
	[118741]=88134, -- Mechanical Scorpid
	[118919]=85667, -- Ore Eater
	[118921]=88222, -- Everbloom Peachick
	[118923]=88225, -- Sentinel's Companion
	[116155]=85710, -- Lovebird Hatchling
	[116439]=85872, -- Blazing Cindercrawler
	[116756]=85994 -- Stout Alemental
}
local pets = {}

-- State variables
local tab_index
local active_auction
local active_button
local lastPage = 0
local battle = true
local queryType = "NONE" -- NONE, SCAN, BID, BUYOUT

-- Initialization
-------------------------------------------------------------------------------
function PetMarket:OnInitialize ()
	self:RegisterEvent ("AUCTION_HOUSE_SHOW")
	self:RegisterEvent ("AUCTION_HOUSE_HIDE")
end

function PetMarket:UpdatePets ()
	for i=1, C_PetJournal.GetNumPets() do
		local petID, _, owned, _, _, _, _, _, _, _, npcID = C_PetJournal.GetPetInfoByIndex(i)
		if owned == true then
			PetMarket.KnownPets[npcID] = petID
		end
	end
end

function PetMarket:AUCTION_HOUSE_HIDE ()
	for _, child in pairs ({PetMarketScrollChild:GetChildren ()}) do child:Hide () end
end

-- Auction House tab
-------------------------------------------------------------------------------
function PetMarket:AUCTION_HOUSE_SHOW ()
	self:UpdatePets ()

	tab_index = AuctionFrame.numTabs+1
	local frame = CreateFrame ("Button", "AuctionFrameTab"..tab_index, AuctionFrame, "AuctionTabTemplate")
	frame:SetID (tab_index)
	frame:SetText ("PetMarket")
--	frame:SetNormalFontObject (_G["AtrFontOrange"])
	frame:SetPoint ("LEFT", _G["AuctionFrameTab"..tab_index-1], "RIGHT", -8, 0)
	PanelTemplates_SetNumTabs (AuctionFrame, tab_index)
	PanelTemplates_EnableTab  (AuctionFrame, tab_index)

	petmarket_orig_AuctionFrameTab_OnClick = AuctionFrameTab_OnClick
	AuctionFrameTab_OnClick = PetMarket_AuctionFrameTab_OnClick

	self:UnregisterEvent ("AUCTION_HOUSE_SHOW")
end

function PetMarket_AuctionFrameTab_OnClick (self, button, down, index)
	if self:GetID () == tab_index then
		AuctionFrameAuctions:Hide ()
		AuctionFrameBrowse:Hide ()
		AuctionFrameBid:Hide ()
		PlaySound ("igCharacterInfoTab")

		PanelTemplates_SetTab (AuctionFrame, tab_index)

		AuctionFrameTopLeft:SetTexture ("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
		AuctionFrameTop:SetTexture ("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top")
		AuctionFrameTopRight:SetTexture ("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight")
		AuctionFrameBotLeft:SetTexture ("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
		AuctionFrameBot:SetTexture ("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
		AuctionFrameBotRight:SetTexture ("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")

		PetMarket:ShowUi ()
	else
		PetMarket:HideUi ()
		petmarket_orig_AuctionFrameTab_OnClick (self, button, down, index)
	end
end

-- GUI management
-------------------------------------------------------------------------------
function PetMarket:CreateEntries (pets)
	for _, child in pairs ({PetMarketScrollChild:GetChildren ()}) do child:Hide () end
	for i, value in ipairs (pets) do
		if _G["PetMarketEntry"..i] == nil then
			local entry = CreateFrame ("CheckButton", "PetMarketEntry"..i, PetMarketScrollChild)
			entry:SetPoint ("LEFT", 0, 0)
			entry:SetPoint ("RIGHT", 0, 0)
			if i > 1 then
				entry:SetPoint ("TOP", "PetMarketEntry".. (i-1), "BOTTOM", 0, -2)
			else
				entry:SetPoint ("TOP", 0, 0)
			end
			entry:SetHeight (35)
			local click = function (self)
				entry:SetChecked (true)
				active_auction = value
				if active_button ~= nil then 
					active_button:SetChecked (false)
				end
				active_button = entry
				PetMarketBuyout:Enable ()
				PetMarketBid:Enable ()
				PetMarketShow:Enable ()
			end
			entry:SetScript ("OnClick", click)

			local highlight = entry:CreateTexture ()
			highlight:SetTexture ("Interface\\HelpFrame\\HelpFrameButton-Highlight")
			highlight:SetTexCoord (0.035, 0.04, 0.2, 0.25)
			highlight:SetAllPoints ()
			entry:SetHighlightTexture (highlight)
			local pushed = entry:CreateTexture ()
			pushed:SetTexture ("Interface\\HelpFrame\\HelpFrameButton-Highlight")
			pushed:SetTexCoord (0, 1, 0.0, 0.55)
			pushed:SetAllPoints ()
			entry:SetCheckedTexture (pushed)

			local link = CreateFrame ("Button", "PetMarketEntry"..i.."Link", entry)
			link:SetScript ("OnClick", click)

			local icon = link:CreateTexture ("PetMarketEntry"..i.."Icon")
			icon:SetPoint ("TOPLEFT", 0, 0)
			icon:SetPoint ("BOTTOM", 0, 0)
			icon:SetWidth (entry:GetHeight ())
			
			local text = link:CreateFontString ("PetMarketEntry"..i.."Text", "ARTWORK", "ChatFontNormal")
			text:SetPoint ("LEFT", icon, "RIGHT", 10, 0)

			
			link:SetPoint ("TOPLEFT", 0, 0)
			link:SetPoint ("BOTTOM", 0, 0)
			link:SetScript ("OnLeave", function ()
				entry:UnlockHighlight ()
				GameTooltip:Hide ()
				BattlePetTooltip:Hide ()
			end)

			local bid = CreateFrame ("Frame", "PetMarketEntry"..i.."Bid", entry, "SmallMoneyFrameTemplate")
			MoneyFrame_SetType (bid, "AUCTION")
			bid:SetPoint ("TOPRIGHT", 0, -5)

			local buyout = CreateFrame ("Frame", "PetMarketEntry"..i.."Buyout", entry, "SmallMoneyFrameTemplate")
			MoneyFrame_SetType (buyout, "AUCTION")
			buyout:SetPoint ("TOP", bid, "BOTTOM", 0, -2)

			local label = entry:CreateFontString (nil, "OVERLAY", "GameFontNormal")
			label:SetText ("Buyout")
			label:SetPoint ("BOTTOMRIGHT", -150, 5)
		end

		_G["PetMarketEntry"..i.."Icon"]:SetTexture (value["texture"])
		_G["PetMarketEntry"..i.."Text"]:SetText (value["link"]:gsub ("[%[%]]", ""))
		_G["PetMarketEntry"..i.."Link"]:SetWidth (_G["PetMarketEntry"..i.."Text"]:GetWidth ()+_G["PetMarketEntry"..i.."Icon"]:GetWidth ())
		_G["PetMarketEntry"..i.."Link"]:SetScript ("OnEnter", function ()
			_G["PetMarketEntry"..i]:LockHighlight ()
			GameTooltip:Show ()
			GameTooltip:SetOwner (_G["PetMarketEntry"..i.."Link"])
			if string.match (value["link"], "|Hbattlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit (":", value["link"])
				BattlePetToolTip_Show (tonumber (speciesID), tonumber (level), tonumber (breedQuality), tonumber (maxHealth), tonumber (power), tonumber (speed), nil)
			else
				GameTooltip:SetHyperlink (value["link"])
			end
		end)
		MoneyFrame_Update (_G["PetMarketEntry"..i.."Bid"], value["bid"])
		MoneyFrame_Update (_G["PetMarketEntry"..i.."Buyout"], value["buyout"])
		_G["PetMarketEntry"..i]:Show ()
	end
	PetMarketScrollChild:SetHeight (#pets*37)
	PetMarketStatus:SetText (#pets.." items found")
end

function PetMarket:ShowUi ()
	for _, child in pairs ({AuctionFrame:GetChildren ()}) do
		if child:GetName ():match ("AuctionFrameTab") == nil then
			child:Hide ()
		end
	end
	AuctionFrameCloseButton:Show ()
	AuctionFrameMoneyFrame:Show ()

	if PetMarketScan == nil then
		CreateFrame ("Button", "PetMarketScan", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketScan:SetPoint ("TOPLEFT", 100, -45)
		PetMarketScan:SetWidth (150)
		PetMarketScan:SetText ("Scan Action House")
		PetMarketScan:SetScript ("OnClick", function ()
			self:RegisterEvent ("AUCTION_ITEM_LIST_UPDATE")
			queryType = "SCAN"
			battle = true
			QueryAuctionItems ("", 0, 0, 0, 11, 0, 0, 0, 0, 0)
		end)
	end

	if PetMarketStatus == nil then
		AuctionFrame:CreateFontString ("PetMarketStatus", "ARTWORK", "ChatFontNormal")
		PetMarketStatus:SetPoint ("TOP", 0, -47)
	end

	if PetMarketScroll == nil then
		CreateFrame ("ScrollFrame", "PetMarketScroll", AuctionFrame, "UIPanelScrollFrameTemplate")
		CreateFrame ("Frame", "PetMarketScrollChild")

		PetMarketScroll:SetScrollChild (PetMarketScrollChild)
		PetMarketScroll:SetPoint ("TOPLEFT", 20, -80)
		PetMarketScroll:SetPoint ("BOTTOMRIGHT", -38, 45)
		PetMarketScrollChild:SetWidth (PetMarketScroll:GetWidth ())
	end

	if PetMarketBid == nil then
		CreateFrame ("Button", "PetMarketBid", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketBid:SetPoint ("BOTTOMRIGHT", -168, 14)
		PetMarketBid:SetSize (80, 22)
		PetMarketBid:SetText ("Bid")
		PetMarketBid:SetScript ("OnClick", function ()
			self:ShowConfirmDialog ("BID")
		end)
		PetMarketBid:Disable ()
	end

	if PetMarketBuyout == nil then
		CreateFrame ("Button", "PetMarketBuyout", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketBuyout:SetPoint ("BOTTOMRIGHT", -88, 14)
		PetMarketBuyout:SetSize (80, 22)
		PetMarketBuyout:SetText ("Buyout")
		PetMarketBuyout:SetScript ("OnClick", function ()
			self:ShowConfirmDialog ("BUYOUT")
		end)
		PetMarketBuyout:Disable ()
	end

	if PetMarketShow == nil then
		CreateFrame ("Button", "PetMarketShow", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketShow:SetPoint ("BOTTOMRIGHT", -8, 14)
		PetMarketShow:SetSize (80, 22)
		PetMarketShow:SetText ("Show")
		PetMarketShow:SetScript ("OnClick", function ()
			SortAuctionClearSort ("list")
			SortAuctionSetSort ("list", "buyout")
			SortAuctionApplySort ("list")
			QueryAuctionItems (active_auction["name"])

			self:HideUi ()
			PlaySound ("igCharacterInfoTab")
			PanelTemplates_SetTab (AuctionFrame, 1)
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");
			AuctionFrameBrowse:Show();
			AuctionFrame.type = "list";
			SetAuctionsTabShowing(false);
		end)
		PetMarketShow:Disable ()
	end

	PetMarketScroll:Show ()
	PetMarketStatus:Show ()
	PetMarketScan:Show ()
	PetMarketBid:Show ()
	PetMarketBuyout:Show ()
	PetMarketShow:Show ()
end

function PetMarket:HideUi ()
	if PetMarketScan == nil then return end
	
	PetMarketScroll:Hide ()
	PetMarketStatus:Hide ()
	PetMarketScan:Hide ()
	PetMarketBid:Hide ()
	PetMarketBuyout:Hide ()
	PetMarketShow:Hide ()
	if PetMarketConfirm ~= nil then
		PetMarketConfirm:Hide ()
	end
end

function PetMarket:ShowConfirmDialog (type)
	PetMarketScroll:Hide ()

	if PetMarketConfirm == nil then
		CreateFrame ("Frame", "PetMarketConfirm", AuctionFrame)
		PetMarketConfirm:SetSize (300, 200)
		PetMarketConfirm:SetPoint ("CENTER", 0, 0)
		local backdrop = {
		  bgFile = "Interface\\CharacterFrame\\UI-Party-Background", 
		  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		  tile = true, 
		  tileSize = 32, 
		  edgeSize = 32, 
		  insets = {
			left = 11, 
			right = 12, 
			top = 12, 
			bottom = 11
		  }
		}
		PetMarketConfirm:SetBackdrop (backdrop)

		PetMarketConfirm:CreateFontString ("PetMarketConfirmError", "ARTWORK", "GameFontNormal")
		PetMarketConfirmError:SetText ("Unable to find item.")
		PetMarketConfirmError:SetPoint ("CENTER", 0, 0)
		PetMarketConfirmError:Hide ()

		local link = CreateFrame ("Frame", "PetMarketConfirmLink", PetMarketConfirm)
		link:SetHeight (50)

		local icon = link:CreateTexture ("PetMarketConfirmLinkIcon")
		icon:SetPoint ("TOPLEFT", 0, 0)
		icon:SetPoint ("BOTTOM", 0, 0)
		icon:SetWidth (link:GetHeight ())
		
		local text = link:CreateFontString ("PetMarketConfirmLinkText", "ARTWORK", "ChatFontNormal")
		text:SetPoint ("LEFT", icon, "RIGHT", 10, 0)

		link:SetWidth (text:GetWidth ()+icon:GetWidth ())
		link:SetPoint ("TOP", 0, -25)
		link:SetScript ("OnLeave", function ()
			GameTooltip:Hide ()
			BattlePetTooltip:Hide ()
		end)

		local cancel = CreateFrame ("Button", nil, PetMarketConfirm, "UIPanelButtonTemplate")
		cancel:SetPoint ("BOTTOM", 50, 30)
		cancel:SetSize (80, 22)
		cancel:SetText ("Cancel")
		cancel:SetScript ("OnClick", function ()
			PetMarketConfirm:Hide ()
			PetMarketScroll:Show ()
		end)

		local confirm = CreateFrame ("Button", "PetMarketConfirmButton", PetMarketConfirm, "UIPanelButtonTemplate")
		confirm:SetPoint ("BOTTOM", -50, 30)
		confirm:SetSize (80, 22)
		confirm:SetText ("Confirm")
		confirm:SetScript ("OnClick", function ()
			PetMarketConfirm:Hide ()
			PetMarketScroll:Show ()
		end)

		PetMarketConfirm:CreateFontString ("PetMarketConfirmBuyoutText", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBuyoutText:SetText ("Buy this item for ")
		CreateFrame ("Frame", "PetMarketConfirmBuyoutMoney", PetMarketConfirm, "SmallMoneyFrameTemplate")
		MoneyFrame_SetType (PetMarketConfirmBuyoutMoney, "AUCTION")
		PetMarketConfirmBuyoutMoney:SetPoint ("LEFT", PetMarketConfirmBuyoutText, "RIGHT", 0, 0)
		PetMarketConfirm:CreateFontString ("PetMarketConfirmBuyoutQ", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBuyoutQ:SetText ("?")
		PetMarketConfirmBuyoutQ:SetPoint ("LEFT", PetMarketConfirmBuyoutMoney, "RIGHT", -12, 0)

		PetMarketConfirm:CreateFontString ("PetMarketConfirmBidText1", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBidText1:SetText ("Bid the minimum of")
		CreateFrame ("Frame", "PetMarketConfirmBidMoney", PetMarketConfirm, "SmallMoneyFrameTemplate")
		MoneyFrame_SetType (PetMarketConfirmBidMoney, "AUCTION")
		PetMarketConfirmBidMoney:SetPoint ("LEFT", PetMarketConfirmBidText1, "RIGHT", 0, 0)
		PetMarketConfirm:CreateFontString ("PetMarketConfirmBidText2", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBidText2:SetText ("on this item?")
		PetMarketConfirmBidText2:SetPoint ("TOPLEFT", PetMarketConfirmBidText1, "BOTTOMLEFT", 0, 2)	end

	SortAuctionClearSort ("list")

	if type == "BUYOUT" then
		PetMarketConfirmBidText1:Hide ()
		PetMarketConfirmBidText2:Hide ()
		PetMarketConfirmBidMoney:Hide ()

		PetMarketConfirmBuyoutText:Show ()
		PetMarketConfirmBuyoutMoney:Show ()
		PetMarketConfirmBuyoutQ:Show ()

		SortAuctionSetSort ("list", "buyout")
	elseif type == "BID" then
		PetMarketConfirmBuyoutText:Hide ()
		PetMarketConfirmBuyoutMoney:Hide ()
		PetMarketConfirmBuyoutQ:Hide ()

		PetMarketConfirmBidText1:Show ()
		PetMarketConfirmBidText2:Show ()
		PetMarketConfirmBidMoney:Show ()

		SortAuctionSetSort ("list", "bid")
	end

	SortAuctionApplySort ("list")
	self:RegisterEvent ("AUCTION_ITEM_LIST_UPDATE")
	queryType = type
	QueryAuctionItems (active_auction["name"])

	PetMarketConfirm:Show ()
end

-- Auction House queries
-------------------------------------------------------------------------------
function PetMarket:AUCTION_ITEM_LIST_UPDATE ()
	if queryType == "NONE" then return end

	if queryType == "SCAN" then
		queryType = "NONE"

		-- Much of the following code taken from MiniPetQ
		local cnt, total = GetNumAuctionItems ("list")

		for i=1, cnt do
			local itemLink = GetAuctionItemLink ("list", i)
			local npcID = nil
			local name, texture, _, _, _, _, _, minBid, _, buyoutPrice, _, _, _, _, _, _, itemId = GetAuctionItemInfo ("list", i)
			if itemLink ~= nil and string.match (itemLink, "|Hbattlepet:") then
				_, speciesID = strsplit (":", itemLink)
				_, _, _, npcID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
			else
				npcID = self.PetItems[itemId]
				if npcID == nil then
					print ("PetMarket: Unknown pet item: "..itemId.." "..name)
				end
			end
			if self.KnownPets[npcID] == nil then
				v1 = buyoutPrice < 1 and minBid or buyoutPrice
				v2 = pets[name] == nil and 0 or (pets[name]["buyout"] < 1 and pets[name]["bid"] or pets[name]["buyout"])
				if pets[name] == nil or v1 < v2 then
					pets[name] = {
						name = name, 
						texture = texture, 
						buyout = buyoutPrice, 
						bid = minBid, 
						link = itemLink, 
						id = itemId
					}
				end
			end
		end
		if 50 * lastPage > total then
			lastPage = 0
			if battle == true then
				battle = false
				PetMarket:ScheduleTimer ("AHQuery", .1)
			else
				strings = {}
				for key, value in pairs (pets) do
					table.insert (strings, value)
				end
				table.sort (strings, function (a, b)
					local av = a["buyout"] < 1 and a["bid"] or a["buyout"]
					local bv = b["buyout"] < 1 and b["bid"] or b["buyout"]
					return av < bv
				end)
				self:CreateEntries (strings)
				self:UnregisterEvent ("AUCTION_ITEM_LIST_UPDATE")
			end
		else
			lastPage = lastPage + 1
			PetMarketStatus:SetText ("Scanning "..(battle and "battle pets" or "items").." page "..lastPage.." of "..string.format ("%.0f", total/50+1))
			self:ScheduleTimer ("AHQuery", .1)
		end
	else
		self:UnregisterEvent ("AUCTION_ITEM_LIST_UPDATE")
		local link = GetAuctionItemLink ("list", 1)
		local name, texture, _, _, _, _, _, minBid, _, buyoutPrice, _, _, _, _, _, _, itemId = GetAuctionItemInfo ("list", 1)
		if name ~= active_auction["name"] or itemId ~= active_auction["id"] then
			PetMarketConfirmBidText:Hide ()
			PetMarketConfirmBidMoney:Hide ()
			PetMarketConfirmBuyoutText:Hide ()
			PetMarketConfirmBuyoutMoney:Hide ()
			PetMarketConfirmBuyoutQ:Hide ()
			PetMarketConfirmLink:Hide ()
			PetMarketConfirmError:Show ()
			queryType = "NONE"
			return
		end
		PetMarketConfirmLinkIcon:SetTexture (texture)
		PetMarketConfirmLinkText:SetText (link)
		PetMarketConfirmLink:SetWidth (PetMarketConfirmLinkText:GetWidth ()+PetMarketConfirmLinkIcon:GetWidth ())
		PetMarketConfirmLink:SetScript ("OnEnter", function ()
			GameTooltip:Show ()
			GameTooltip:SetOwner (PetMarketConfirmLink)
			if string.match (link, "|Hbattlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit (":", link)
				BattlePetToolTip_Show (tonumber (speciesID), tonumber (level), tonumber (breedQuality), tonumber (maxHealth), tonumber (power), tonumber (speed), nil)
			else
				GameTooltip:SetHyperlink (link)
			end
		end)

		if queryType == "BUYOUT" then
			MoneyFrame_Update (PetMarketConfirmBuyoutMoney, buyoutPrice)
			PetMarketConfirmBuyoutText:SetPoint ("TOP", PetMarketConfirmLink, "BOTTOM", -PetMarketConfirmBuyoutMoney:GetWidth ()/2, -20)
			PetMarketConfirmButton:SetScript ("OnClick", function ()
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemId = GetAuctionItemInfo ("list", 1)
				if name == active_auction["name"] and itemId == active_auction["id"] then
					PlaceAuctionBid ("list", 1, buyoutPrice)
				end
				PetMarketConfirm:Hide ()
				PetMarketScroll:Show ()
			end)
		elseif queryType == "BID" then
			MoneyFrame_Update (PetMarketConfirmBidMoney, minBid)
			PetMarketConfirmBidText1:SetPoint ("TOP", PetMarketConfirmLink, "BOTTOM", -PetMarketConfirmBidMoney:GetWidth ()/2, -20)
			PetMarketConfirmButton:SetScript ("OnClick", function ()
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemId = GetAuctionItemInfo ("list", 1)
				if name == active_auction["name"] and itemId == active_auction["id"] then
					PlaceAuctionBid ("list", 1, minBid)
				end
				PetMarketConfirm:Hide ()
				PetMarketScroll:Show ()
			end)
		end

		queryType = "NONE"

		return
	end
end

function PetMarket:AHQuery ()
	if AuctionFrame:IsVisible () ~= true then
		print ("PetMarket: Auction House is closed, can not scan.")
		self:UnregisterEvent ("AUCTION_ITEM_LIST_UPDATE")
		queryType = "NONE"
		return
	end
	local canQuery, canQueryAll = CanSendAuctionQuery ()
	if not canQuery then
		PetMarket:ScheduleTimer ("AHQuery", .1)
		return
	end

	queryType = "SCAN"
	if battle then
		QueryAuctionItems ("", 0, 0, 0, 11, 0, lastPage, 0, 0, 0)
	else
		QueryAuctionItems ("", 0, 0, 0, 9, 3, lastPage, true, 0, 0)
	end
end