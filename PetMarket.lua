--[[--------------------------------------------------------------------
	PetMarket
	Scans auction house for unowned pets.
	https://mods.curse.com/addons/wow/petmarket
	https://wow.curseforge.com/addons/petmarket/

	Copyright (C) 2014 Timothy Johnson (RedHatter21)

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	-----
	Forked version with fixes and updates by Phanx:
	https://github.com/Phanx/PetMarket
----------------------------------------------------------------------]]

PetMarket = LibStub("AceAddon-3.0"):NewAddon("PetMarket", "AceEvent-3.0", "AceTimer-3.0")
local PetMarket = PetMarket

-- Pet lists
PetMarket.KnownPets = {}
PetMarket.PetItems = select(2, ...).PetItemToSpecies
local pets = {}

-- State variables
local tab_index
local active_auction
local active_button
local lastPage = 0
local queryType = "NONE" -- NONE, SCAN, BID, BUYOUT

-- Initialization
-------------------------------------------------------------------------------
function PetMarket:OnInitialize()
	self:RegisterEvent("AUCTION_HOUSE_SHOW")
	self:RegisterEvent("AUCTION_HOUSE_CLOSED")
end

function PetMarket:UpdatePets()
	for _, petID in LibStub("LibPetJournal-2.0"):IteratePetIDs() do
		table.insert(PetMarket.KnownPets, C_PetJournal.GetPetInfoByPetID(petID), true);
	end
end

function PetMarket:AUCTION_HOUSE_CLOSED()
	for _, child in pairs({PetMarketScrollChild:GetChildren()}) do child:Hide() end
end

-- Auction House tab
-------------------------------------------------------------------------------
function PetMarket:AUCTION_HOUSE_SHOW()
	self:UpdatePets()
	LibStub("LibPetJournal-2.0").RegisterCallback(self, "PetListUpdated", "UpdatePets")

	tab_index = AuctionFrame.numTabs + 1
	local frame = CreateFrame("Button", "AuctionFrameTab"..tab_index, AuctionFrame, "AuctionTabTemplate")
	frame:SetID(tab_index)
	frame:SetText("PetMarket")
--	frame:SetNormalFontObject(_G["AtrFontOrange"])
	frame:SetPoint("LEFT", _G["AuctionFrameTab"..tab_index - 1], "RIGHT", -8, 0)
	PanelTemplates_SetNumTabs(AuctionFrame, tab_index)
	PanelTemplates_EnableTab(AuctionFrame, tab_index)
	frame:GetScript("OnShow")(frame) -- force it to resize to fit its text

	self.orig_AuctionFrameTab_OnClick = AuctionFrameTab_OnClick
	AuctionFrameTab_OnClick = self.AuctionFrameTab_OnClick

	self:UnregisterEvent("AUCTION_HOUSE_SHOW")
end

function PetMarket.AuctionFrameTab_OnClick(self, button, down, index)
	if self:GetID() == tab_index then
		AuctionFrameAuctions:Hide()
		AuctionFrameBrowse:Hide()
		AuctionFrameBid:Hide()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)

		PanelTemplates_SetTab(AuctionFrame, tab_index)

		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top")
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight")
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")

		PetMarket:ShowUi()
	else
		PetMarket:HideUi()
		PetMarket.orig_AuctionFrameTab_OnClick(self, button, down, index)
	end
end

-- GUI management
-------------------------------------------------------------------------------
function PetMarket:CreateEntries(pets)
	for _, child in pairs({PetMarketScrollChild:GetChildren()}) do child:Hide() end
	for i, value in ipairs(pets) do
		if _G["PetMarketEntry"..i] == nil then
			local entry = CreateFrame("CheckButton", "PetMarketEntry"..i, PetMarketScrollChild)
			entry:SetPoint("LEFT", 0, 0)
			entry:SetPoint("RIGHT", 0, 0)
			if i > 1 then
				entry:SetPoint("TOP", "PetMarketEntry"..(i - 1), "BOTTOM", 0, -2)
			else
				entry:SetPoint("TOP", 0, 0)
			end
			entry:SetHeight(35)
			local click = function(self)
				entry:SetChecked(true)
				active_auction = value
				if active_button ~= nil then
					active_button:SetChecked(false)
				end
				active_button = entry
				PetMarketBuyout:Enable()
				PetMarketBid:Enable()
				PetMarketShow:Enable()
			end
			entry:SetScript("OnClick", click)

			local highlight = entry:CreateTexture()
			highlight:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
			highlight:SetTexCoord(0.035, 0.04, 0.2, 0.25)
			highlight:SetAllPoints()
			entry:SetHighlightTexture(highlight)
			local pushed = entry:CreateTexture()
			pushed:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
			pushed:SetTexCoord(0, 1, 0.0, 0.55)
			pushed:SetAllPoints()
			entry:SetCheckedTexture(pushed)

			local link = CreateFrame("Button", "PetMarketEntry"..i.."Link", entry)
			link:SetScript("OnClick", click)

			local icon = link:CreateTexture("PetMarketEntry"..i.."Icon")
			icon:SetPoint("TOPLEFT", 0, 0)
			icon:SetPoint("BOTTOM", 0, 0)
			icon:SetWidth(entry:GetHeight())

			local text = link:CreateFontString("PetMarketEntry"..i.."Text", "ARTWORK", "ChatFontNormal")
			text:SetPoint("LEFT", icon, "RIGHT", 10, 0)


			link:SetPoint("TOPLEFT", 0, 0)
			link:SetPoint("BOTTOM", 0, 0)
			link:SetScript("OnLeave", function()
				entry:UnlockHighlight()
				GameTooltip:Hide()
				BattlePetTooltip:Hide()
			end)

			local bid = CreateFrame("Frame", "PetMarketEntry"..i.."Bid", entry, "SmallMoneyFrameTemplate")
			MoneyFrame_SetType(bid, "AUCTION")
			bid:SetPoint("TOPRIGHT", 0, -5)

			local buyout = CreateFrame("Frame", "PetMarketEntry"..i.."Buyout", entry, "SmallMoneyFrameTemplate")
			MoneyFrame_SetType(buyout, "AUCTION")
			buyout:SetPoint("TOP", bid, "BOTTOM", 0, -2)

			local label = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetText("Buyout")
			label:SetPoint("BOTTOMRIGHT", -150, 5)
		end

		_G["PetMarketEntry"..i.."Icon"]:SetTexture(value["texture"])
		_G["PetMarketEntry"..i.."Text"]:SetText(value["link"]:gsub("[%[%]]", ""))
		_G["PetMarketEntry"..i.."Link"]:SetWidth(_G["PetMarketEntry"..i.."Text"]:GetWidth() + _G["PetMarketEntry"..i.."Icon"]:GetWidth())
		_G["PetMarketEntry"..i.."Link"]:SetScript("OnEnter", function()
			_G["PetMarketEntry"..i]:LockHighlight()
			GameTooltip:Show()
			GameTooltip:SetOwner(_G["PetMarketEntry"..i.."Link"])
			if string.match(value["link"], "|Hbattlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", value["link"])
				BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), nil)
			else
				GameTooltip:SetHyperlink(value["link"])
			end
		end)
		MoneyFrame_Update(_G["PetMarketEntry"..i.."Bid"], value["bid"])
		MoneyFrame_Update(_G["PetMarketEntry"..i.."Buyout"], value["buyout"])
		_G["PetMarketEntry"..i]:Show()
	end
	PetMarketScrollChild:SetHeight(#pets * 37)
	PetMarketStatus:SetText(#pets.." items found")
end

function PetMarket:ShowUi()
	for _, child in pairs({AuctionFrame:GetChildren()}) do
		local name = child:GetName()
		if not name or not name:find("AuctionFrameTab") then
			child:Hide()
		end
	end
	AuctionFrameCloseButton:Show()
	AuctionFrameMoneyFrame:Show()

	if PetMarketScan == nil then
		CreateFrame("Button", "PetMarketScan", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketScan:SetPoint("TOPLEFT", 100, -45)
		PetMarketScan:SetWidth(150)
		PetMarketScan:SetText("Scan Action House")
		PetMarketScan:SetScript("OnClick", function()
			self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
			lastPage = 0
			self:AHQuery()
		end)
	end

	if PetMarketStatus == nil then
		AuctionFrame:CreateFontString("PetMarketStatus", "ARTWORK", "ChatFontNormal")
		PetMarketStatus:SetPoint("TOP", 0, -47)
	end

	if PetMarketScroll == nil then
		CreateFrame("ScrollFrame", "PetMarketScroll", AuctionFrame, "UIPanelScrollFrameTemplate")
		CreateFrame("Frame", "PetMarketScrollChild")

		PetMarketScroll:SetScrollChild(PetMarketScrollChild)
		PetMarketScroll:SetPoint("TOPLEFT", 20, -80)
		PetMarketScroll:SetPoint("BOTTOMRIGHT", -38, 45)
		PetMarketScrollChild:SetWidth(PetMarketScroll:GetWidth())
	end

	if PetMarketBid == nil then
		CreateFrame("Button", "PetMarketBid", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketBid:SetPoint("BOTTOMRIGHT", -168, 14)
		PetMarketBid:SetSize(80, 22)
		PetMarketBid:SetText("Bid")
		PetMarketBid:SetScript("OnClick", function()
			self:ShowConfirmDialog("BID")
		end)
		PetMarketBid:Disable()
	end

	if PetMarketBuyout == nil then
		CreateFrame("Button", "PetMarketBuyout", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketBuyout:SetPoint("BOTTOMRIGHT", -88, 14)
		PetMarketBuyout:SetSize(80, 22)
		PetMarketBuyout:SetText("Buyout")
		PetMarketBuyout:SetScript("OnClick", function()
			self:ShowConfirmDialog("BUYOUT")
		end)
		PetMarketBuyout:Disable()
	end

	if PetMarketShow == nil then
		CreateFrame("Button", "PetMarketShow", AuctionFrame, "UIPanelButtonTemplate")
		PetMarketShow:SetPoint("BOTTOMRIGHT", -8, 14)
		PetMarketShow:SetSize(80, 22)
		PetMarketShow:SetText("Show")
		PetMarketShow:SetScript("OnClick", function()
			SortAuctionClearSort("list")
			SortAuctionSetSort("list", "buyout")
			SortAuctionApplySort("list")
			QueryAuctionItems(active_auction["name"])

			self:HideUi()
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			PanelTemplates_SetTab(AuctionFrame, 1)
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
		PetMarketShow:Disable()
	end

	PetMarketScroll:Show()
	PetMarketStatus:Show()
	PetMarketScan:Show()
	PetMarketBid:Show()
	PetMarketBuyout:Show()
	PetMarketShow:Show()
end

function PetMarket:HideUi()
	if PetMarketScan == nil then return end

	PetMarketScroll:Hide()
	PetMarketStatus:Hide()
	PetMarketScan:Hide()
	PetMarketBid:Hide()
	PetMarketBuyout:Hide()
	PetMarketShow:Hide()
	if PetMarketConfirm ~= nil then
		PetMarketConfirm:Hide()
	end
end

function PetMarket:ShowConfirmDialog(type)
	PetMarketScroll:Hide()

	if PetMarketConfirm == nil then
		CreateFrame("Frame", "PetMarketConfirm", AuctionFrame)
		PetMarketConfirm:SetSize(300, 200)
		PetMarketConfirm:SetPoint("CENTER", 0, 0)
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
		PetMarketConfirm:SetBackdrop(backdrop)

		PetMarketConfirm:CreateFontString("PetMarketConfirmError", "ARTWORK", "GameFontNormal")
		PetMarketConfirmError:SetText("Unable to find item.")
		PetMarketConfirmError:SetPoint("CENTER", 0, 0)
		PetMarketConfirmError:Hide()

		local link = CreateFrame("Frame", "PetMarketConfirmLink", PetMarketConfirm)
		link:SetHeight(50)

		local icon = link:CreateTexture("PetMarketConfirmLinkIcon")
		icon:SetPoint("TOPLEFT", 0, 0)
		icon:SetPoint("BOTTOM", 0, 0)
		icon:SetWidth(link:GetHeight())

		local text = link:CreateFontString("PetMarketConfirmLinkText", "ARTWORK", "ChatFontNormal")
		text:SetPoint("LEFT", icon, "RIGHT", 10, 0)

		link:SetWidth(text:GetWidth() + icon:GetWidth())
		link:SetPoint("TOP", 0, -25)
		link:SetScript("OnLeave", function()
			GameTooltip:Hide()
			BattlePetTooltip:Hide()
		end)

		local cancel = CreateFrame("Button", nil, PetMarketConfirm, "UIPanelButtonTemplate")
		cancel:SetPoint("BOTTOM", 50, 30)
		cancel:SetSize(80, 22)
		cancel:SetText("Cancel")
		cancel:SetScript("OnClick", function()
			PetMarketConfirm:Hide()
			PetMarketScroll:Show()
		end)

		local confirm = CreateFrame("Button", "PetMarketConfirmButton", PetMarketConfirm, "UIPanelButtonTemplate")
		confirm:SetPoint("BOTTOM", -50, 30)
		confirm:SetSize(80, 22)
		confirm:SetText("Confirm")
		confirm:SetScript("OnClick", function()
			PetMarketConfirm:Hide()
			PetMarketScroll:Show()
		end)

		PetMarketConfirm:CreateFontString("PetMarketConfirmBuyoutText", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBuyoutText:SetText("Buy this item for ")
		CreateFrame("Frame", "PetMarketConfirmBuyoutMoney", PetMarketConfirm, "SmallMoneyFrameTemplate")
		MoneyFrame_SetType(PetMarketConfirmBuyoutMoney, "AUCTION")
		PetMarketConfirmBuyoutMoney:SetPoint("LEFT", PetMarketConfirmBuyoutText, "RIGHT", 0, 0)
		PetMarketConfirm:CreateFontString("PetMarketConfirmBuyoutQ", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBuyoutQ:SetText("?")
		PetMarketConfirmBuyoutQ:SetPoint("LEFT", PetMarketConfirmBuyoutMoney, "RIGHT", -12, 0)

		PetMarketConfirm:CreateFontString("PetMarketConfirmBidText1", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBidText1:SetText("Bid the minimum of")
		CreateFrame("Frame", "PetMarketConfirmBidMoney", PetMarketConfirm, "SmallMoneyFrameTemplate")
		MoneyFrame_SetType(PetMarketConfirmBidMoney, "AUCTION")
		PetMarketConfirmBidMoney:SetPoint("LEFT", PetMarketConfirmBidText1, "RIGHT", 0, 0)
		PetMarketConfirm:CreateFontString("PetMarketConfirmBidText2", "ARTWORK", "GameFontNormal")
		PetMarketConfirmBidText2:SetText("on this item?")
		PetMarketConfirmBidText2:SetPoint("TOPLEFT", PetMarketConfirmBidText1, "BOTTOMLEFT", 0, 2)	end

	SortAuctionClearSort("list")

	if type == "BUYOUT" then
		PetMarketConfirmBidText1:Hide()
		PetMarketConfirmBidText2:Hide()
		PetMarketConfirmBidMoney:Hide()

		PetMarketConfirmBuyoutText:Show()
		PetMarketConfirmBuyoutMoney:Show()
		PetMarketConfirmBuyoutQ:Show()

		SortAuctionSetSort("list", "buyout")
	elseif type == "BID" then
		PetMarketConfirmBuyoutText:Hide()
		PetMarketConfirmBuyoutMoney:Hide()
		PetMarketConfirmBuyoutQ:Hide()

		PetMarketConfirmBidText1:Show()
		PetMarketConfirmBidText2:Show()
		PetMarketConfirmBidMoney:Show()

		SortAuctionSetSort("list", "bid")
	end

	SortAuctionApplySort("list")
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	queryType = type
	QueryAuctionItems(active_auction["name"])

	PetMarketConfirm:Show()
end

-- Auction House queries
-------------------------------------------------------------------------------
local function sortEntryStrings(a, b)
	local  av = a.buyout < 1 and a.bid or a.buyout
	local  bv = b.buyout < 1 and b.bid or b.buyout
	return av < bv
end

function PetMarket:AUCTION_ITEM_LIST_UPDATE()
	if queryType == "NONE" then return end

	if queryType == "SCAN" then
		queryType = "NONE"

		-- Much of the following code taken from MiniPetQ
		local cnt, total = GetNumAuctionItems("list")

		for i=1, cnt do
			local itemLink = GetAuctionItemLink("list", i)
			local speciesID
			local name, texture, _, _, _, _, _, minBid, _, buyoutPrice, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", i)
			if itemLink and string.find(itemLink, "|Hbattlepet:") then
				_, speciesID = strsplit(":", itemLink)
				speciesID = tonumber(speciesID)
			else
				speciesID = self.PetItems[itemID]
				if not speciesID then
					print("PetMarket: Unknown pet item: "..itemID.." "..name)
				end
			end
			if speciesID and not self.KnownPets[speciesID] then
				local v1 = buyoutPrice < 1 and minBid or buyoutPrice
				local v2 = pets[name] == nil and 0 or(pets[name]["buyout"] < 1 and pets[name]["bid"] or pets[name]["buyout"])
				if pets[name] == nil or v1 < v2 then
					pets[name] = {
						name = name,
						texture = texture,
						buyout = buyoutPrice,
						bid = minBid,
						link = itemLink,
						id = itemID
					}
				end
			end
		end
		PetMarketStatus:SetText(string.format("Scanning battle pets, page %d of %d", lastPage, math.ceil(total / 50)))
		if 50 * lastPage > total then
			lastPage = 0
			local strings = {}
			for key, value in pairs(pets) do
				table.insert(strings, value)
			end
			table.sort(strings, sortEntryStrings)
			self:CreateEntries(strings)
			self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		else
			lastPage = lastPage + 1
			self:ScheduleTimer("AHQuery", .1)
		end
	else
		self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		local link = GetAuctionItemLink("list", 1)
		local name, texture, _, _, _, _, _, minBid, _, buyoutPrice, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", 1)
		if name ~= active_auction["name"] or itemID ~= active_auction["id"] then
			PetMarketConfirmBidText:Hide()
			PetMarketConfirmBidMoney:Hide()
			PetMarketConfirmBuyoutText:Hide()
			PetMarketConfirmBuyoutMoney:Hide()
			PetMarketConfirmBuyoutQ:Hide()
			PetMarketConfirmLink:Hide()
			PetMarketConfirmError:Show()
			queryType = "NONE"
			return
		end
		PetMarketConfirmLinkIcon:SetTexture(texture)
		PetMarketConfirmLinkText:SetText(link)
		PetMarketConfirmLink:SetWidth(PetMarketConfirmLinkText:GetWidth() + PetMarketConfirmLinkIcon:GetWidth())
		PetMarketConfirmLink:SetScript("OnEnter", function()
			GameTooltip:Show()
			GameTooltip:SetOwner(PetMarketConfirmLink)
			if string.match(link, "|Hbattlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", link)
				BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), nil)
			else
				GameTooltip:SetHyperlink(link)
			end
		end)

		if queryType == "BUYOUT" then
			MoneyFrame_Update(PetMarketConfirmBuyoutMoney, buyoutPrice)
			PetMarketConfirmBuyoutText:SetPoint("TOP", PetMarketConfirmLink, "BOTTOM", -PetMarketConfirmBuyoutMoney:GetWidth() / 2, -20)
			PetMarketConfirmButton:SetScript("OnClick", function()
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", 1)
				if name == active_auction["name"] and itemID == active_auction["id"] then
					PlaceAuctionBid("list", 1, buyoutPrice)
				end
				PetMarketConfirm:Hide()
				PetMarketScroll:Show()
			end)
		elseif queryType == "BID" then
			MoneyFrame_Update(PetMarketConfirmBidMoney, minBid)
			PetMarketConfirmBidText1:SetPoint("TOP", PetMarketConfirmLink, "BOTTOM", -PetMarketConfirmBidMoney:GetWidth() / 2, -20)
			PetMarketConfirmButton:SetScript("OnClick", function()
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", 1)
				if name == active_auction["name"] and itemID == active_auction["id"] then
					PlaceAuctionBid("list", 1, minBid)
				end
				PetMarketConfirm:Hide()
				PetMarketScroll:Show()
			end)
		end

		queryType = "NONE"

		return
	end
end

function PetMarket:AHQuery()
	if AuctionFrame:IsVisible() ~= true then
		print("PetMarket: Auction House is closed, can not scan.")
		self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		queryType = "NONE"
		return
	end
	local canQuery, canQueryAll = CanSendAuctionQuery()
	if not canQuery then
		PetMarket:ScheduleTimer("AHQuery", .1)
		return
	end

	queryType = "SCAN"
	local filterData = AuctionCategories[10].filters
	QueryAuctionItems("", 0, 0, lastPage, false, -1, false, false, filterData)
end
