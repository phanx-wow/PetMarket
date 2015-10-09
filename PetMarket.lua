--[[--------------------------------------------------------------------
	PetMarket
	Scans auction house for unowned pets.
	http://www.curse.com/addons/wow/petmarket
	http://wow.curseforge.com/addons/petmarket/

	Copyright(C) 2014 Timothy Johnson(RedHatter21)

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY without even the implied warranty of
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
local PET_MARKET, private = ...

-- Pet lists
PetMarket.PetItems = private.PetItemToSpecies
PetMarket.KnownPets = {}
local pets = {}

-- Constants
local AH_ITEMS_PER_PAGE = 50

-- State variables
local tab_index
local active_auction
local active_button
local lastPage = 0
local battle = true
local queryType = "NONE" -- NONE, SCAN, BID, BUYOUT

-- Debugging utility
PetMarket.DebugLog = {}
local function debug(...)
	tinsert(PetMarket.DebugLog, strjoin(" ", tostringall(...)))
end

-- Localization
local L = setmetatable(private.L or {}, {
	["PetMarket"] = PET_MARKET,
	["Bid"] = BID,
	["Buyout"] = BUYOUT,
	["Cancel"] = CANCEL,
	["Show"] = SHOW,
	__index = function(t, k)
		local v = tostring(k)
		rawset(t, k, v)
		return v
	end
})
if GetLocale() == "deDE" then
	L["%d pets found"] = "%d Kampfhaustiere gefunden"
	L["Auction House is closed, can not scan."] = "Auktionshaus ist verschlossen, kann nicht scannen."
	L["Bid the minimum of %s on this item?"] = "Biete auf Auktion für %s?"
	L["Buy this item for %s?"] = "Auktionskauf für %s?"
	L["Confirm"] = "Bestätigen"
	L["Scan Action House"] = "Auktionshaus scannen"
	L["Scanning battle pets page %d of %d..."] = "Kampfhaustiere-Seite %d von %d wird gescannt..."
	L["Scanning items page %d of %d..."] = "Gegenstände-Seite %d von %d wird gescannt..."
	L["Unable to find item."] = "Gegenstand nicht gefunden"
	L["Unknown pet item: %d %s"] = "Unbekanntes Gegenstand: %d %s"
end

-- Initialization
-------------------------------------------------------------------------------
function PetMarket:OnInitialize()
	self:RegisterEvent("AUCTION_HOUSE_SHOW")
	self:RegisterEvent("AUCTION_HOUSE_HIDE")
end

function PetMarket:UpdatePets()
	for _, petID in LibStub("LibPetJournal-2.0"):IteratePetIDs() do
		PetMarket.KnownPets[(C_PetJournal.GetPetInfoByPetID(petID))] = true
	end
end

function PetMarket:AUCTION_HOUSE_HIDE()
	-- TODO: can't we just hide the whole scrollFrame?
	--       .... half our stuff isn't even parented to the scrollChild?
	-- TODO: or just call :HideUI() ???
	for _, child in pairs({ PetMarket.scrollChild:GetChildren() }) do
		child:Hide()
	end
end

-- Auction House tab
-------------------------------------------------------------------------------
function PetMarket:AUCTION_HOUSE_SHOW()
	self:UpdatePets()
	LibStub("LibPetJournal-2.0").RegisterCallback(self, "PetListUpdated", "UpdatePets")

	tab_index = AuctionFrame.numTabs + 1
	local tab = CreateFrame("Button", "AuctionFrameTab"..tab_index, AuctionFrame, "AuctionTabTemplate")
	tab:SetID(tab_index)
	tab:SetText(L["PetMarket"])
	tab:SetPoint("LEFT", _G["AuctionFrameTab"..tab_index-1], "RIGHT", -8, 0)
	PanelTemplates_SetNumTabs(AuctionFrame, tab_index)
	PanelTemplates_EnableTab(AuctionFrame, tab_index)
	tab:GetScript("OnShow")(tab) -- force tab to resize to fit its text

	self.orig_AuctionFrameTab_OnClick = AuctionFrameTab_OnClick
	AuctionFrameTab_OnClick = self.AuctionFrameTab_OnClick

	self:UnregisterEvent("AUCTION_HOUSE_SHOW")
end

function PetMarket.AuctionFrameTab_OnClick(self, button, down, index)
	if self:GetID() == tab_index then
		AuctionFrameAuctions:Hide()
		AuctionFrameBrowse:Hide()
		AuctionFrameBid:Hide()
		PlaySound("igCharacterInfoTab")

		PanelTemplates_SetTab(AuctionFrame, tab_index)

		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top")
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight")
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")

		PetMarket:ShowUI()
	else
		PetMarket:HideUI()
		PetMarket.orig_AuctionFrameTab_OnClick(self, button, down, index)
	end
end

-- GUI management
-------------------------------------------------------------------------------
local ROW_HEIGHT, ROW_GAP = 35, 2
	
do
	local function row_OnClick(self)
		self:SetChecked(true)
		active_auction = value
		if active_button ~= nil then
			active_button:SetChecked(false)
		end
		active_button = self
		PetMarket.buyoutButton:Enable()
		PetMarket.bidButton:Enable()
		PetMarket.showButton:Enable()
	end

	local function row_OnEnter(self)
		self:LockHighlight()
		if string.find(self.pet.link, "|Hbattlepet:") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", self.pet.link)
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), nil)
		else
			GameTooltip:SetOwner(self)
			GameTooltip:SetHyperlink(self.pet.link)
		end
	end

	local function row_OnLeave(self)
		self:UnlockHighlight()
		GameTooltip:Hide()
		BattlePetTooltip:Hide()
	end

	PetMarket.rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("CheckButton", "PetMarketEntry"..i, PetMarket.scrollChild)
		row:SetHeight(ROW_HEIGHT)
		row:SetPoint("LEFT")
		row:SetPoint("RIGHT")
		if i > 1 then
			row:SetPoint("TOP", t[i-1], "BOTTOM", 0, -ROW_GAP)
		else
			row:SetPoint("TOP")
		end

		row:SetScript("OnClick", row_OnClick)
		row:SetScript("OnEnter", row_OnEnter)
		row:SetScript("OnLeave", row_OnLeave)

		local highlight = row:CreateTexture(nil, "BACKGROUND")
		highlight:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
		highlight:SetTexCoord(0.035, 0.04, 0.2, 0.25)
		highlight:SetAllPoints()
		row:SetHighlightTexture(highlight)

		local pushed = row:CreateTexture(nil, "BACKGROUND")
		pushed:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
		pushed:SetTexCoord(0, 1, 0.0, 0.55)
		pushed:SetAllPoints()
		row:SetCheckedTexture(pushed)

		local icon = row:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT")
		icon:SetPoint("BOTTOM")
		icon:SetWidth(ROW_HEIGHT)
		row.icon = icon

		local text = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
		text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
		row.text = text

		local bid = CreateFrame("Frame", "PetMarketEntry"..i.."Bid", row, "SmallMoneyFrameTemplate")
		bid:SetPoint("TOPRIGHT", 0, -5)
		MoneyFrame_SetType(bid, "AUCTION")
		row.bid = bid

		local buyout = CreateFrame("Frame", "PetMarketEntry"..i.."Buyout", row, "SmallMoneyFrameTemplate")
		buyout:SetPoint("TOP", bid, "BOTTOM", 0, -2)
		MoneyFrame_SetType(buyout, "AUCTION")
		row.buyout = buyout

		local label = buyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		label:SetText(L["Buyout"])
		label:SetPoint("BOTTOMRIGHT", buyout, "BOTTOMLEFT", -5, 0)
		buyout.label = label
		
		t[i] = row
		return row
	end })
end

function PetMarket:CreateEntries(pets)
	for i = 1, #pets do
		local pet = pets[i]
		local row = self.rows[i]
		row.pet = pet
		row.icon:SetTexture(pet.texture)
		row.text:SetText(gsub(pet.link, "[%[%]]", ""))
		MoneyFrame_Update(row.bid, pet.bid)
		MoneyFrame_Update(row.buyout, pet.buyout)
		row:Show()
	end
	for i = #pets + 1, #self.rows do
		row:Hide()
	end
	PetMarket.scrollChild:SetHeight(#pets * (ROW_HEIGHT + ROW_GAP))
	PetMarket.statusText:SetFormattedText(L["%d pets found"], #pets)
end

function PetMarket:ShowUI()
	-- TODO: this is kind of an awkward way to hide stuff...
	for i = 1, AuctionFrame:GetNumChildren() do
		local child = select(i, AuctionFrame:GetChildren())
		local name = child:GetName()
		if not name or not name:find("AuctionFrameTab") then
			child:Hide()
		end
	end
	AuctionFrameCloseButton:Show()
	AuctionFrameMoneyFrame:Show()

	if not PetMarket.scanButton then -- TODO: can we parent everything to the scrollFrame?
		local scanButton = CreateFrame("Button", "PetMarketScanButton", AuctionFrame, "UIPanelButtonTemplate")
		scanButton:SetPoint("TOPLEFT", 100, -45)
		scanButton:SetText(L["Scan Action House"])
		scanButton:SetWidth(max(150, scanButton:GetFontString():GetStringWidth() + 24))
		scanButton:SetScript("OnClick", function()
			self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
			queryType = "SCAN"
			battle = true
			QueryAuctionItems("", 0, 0, 0, 11, 0, 0, 0, 0, 0)
		end)
		PetMarket.scanButton = scanButton

		local statusText = AuctionFrame:CreateFontString("PetMarketStatusText", "ARTWORK", "GameFontHighlight")
		statusText:SetPoint("LEFT", PetMarket.scanButton, "RIGHT", 10, 1)
		PetMarket.statusText = statusText

		local scrollFrame = CreateFrame("ScrollFrame", "PetMarketScrollFrame", AuctionFrame, "UIPanelScrollFrameTemplate")
		local scrollChild = CreateFrame("Frame")
		scrollFrame:SetPoint("TOPLEFT", 20, -80)
		scrollFrame:SetPoint("BOTTOMRIGHT", -38, 45)
		scrollFrame:SetScrollChild(scrollChild)
		scrollChild:SetWidth(scrollFrame:GetWidth())
		PetMarket.scrollFrame = scrollFrame
		PetMarket.scrollChild = scrollChild

		local bidButton = CreateFrame("Button", "PetMarketBidButton", AuctionFrame, "UIPanelButtonTemplate")
		bidButton:SetPoint("BOTTOMRIGHT", -168, 14)
		bidButton:SetSize(80, 22)
		bidButton:SetText(L["Bid"])
		bidButton:SetScript("OnClick", function()
			self:ShowConfirmDialog("BID")
		end)
		bidButton:Disable()
		PetMarket.bidButton = bidButton

		local buyoutButton = CreateFrame("Button", "PetMarketBuyoutButton", AuctionFrame, "UIPanelButtonTemplate")
		buyoutButton:SetPoint("BOTTOMRIGHT", -88, 14)
		buyoutButton:SetSize(80, 22)
		buyoutButton:SetText(L["Buyout"])
		buyoutButton:SetScript("OnClick", function()
			self:ShowConfirmDialog("BUYOUT")
		end)
		buyoutButton:Disable()
		PetMarket.buyoutButton = buyoutButton

		local showButton = CreateFrame("Button", "PetMarketShowButton", AuctionFrame, "UIPanelButtonTemplate")
		showButton:SetPoint("BOTTOMRIGHT", -8, 14)
		showButton:SetSize(80, 22)
		showButton:SetText(L["Show"])
		showButton:SetScript("OnClick", function()
			SortAuctionClearSort("list")
			SortAuctionSetSort("list", "buyout")
			SortAuctionApplySort("list")
			QueryAuctionItems(active_auction["name"])

			self:HideUI()
			PlaySound("igCharacterInfoTab")
			PanelTemplates_SetTab(AuctionFrame, 1)
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft")
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top")
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight")
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft")
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")
			AuctionFrameBrowse:Show()
			AuctionFrame.type = "list"
			SetAuctionsTabShowing(false)
		end)
		showButton:Disable()
		PetMarket.showButton = showButton
	end

	PetMarket.scrollFrame:Show()
	PetMarket.statusText:Show()
	PetMarket.scanButton:Show()
	PetMarket.bidButton:Show()
	PetMarket.buyoutButton:Show()
	PetMarket.showButton:Show()
end

function PetMarket:HideUI()
	if not PetMarket.scanButton then return end

	PetMarket.scrollFrame:Hide()
	PetMarket.statusText:Hide()
	PetMarket.scanButton:Hide()
	PetMarket.bidButton:Hide()
	PetMarket.buyoutButton:Hide()
	PetMarket.showButton:Hide()
	if PetMarket.confirmDialog then
		PetMarket.confirmDialog:Hide()
	end
end

function PetMarket:ShowConfirmDialog(type)
	PetMarket.scrollFrame:Hide()

	local dialog = PetMarket.confirmDialog
	if not dialog then
		dialog = CreateFrame("Frame", "PetMarketConfirmDialog", AuctionFrame)
		dialog:SetSize(300, 200)
		dialog:SetPoint("CENTER")
		dialog:SetBackdrop({
		  bgFile = "Interface\\CharacterFrame\\UI-Party-Background", tile = true, tileSize = 32,
		  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 32,
		  insets = { left = 11, right = 12, top = 12, bottom = 11 }
		})
		PetMarket.confirmDialog = dialog

		local err = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		err:SetText(L["Unable to find item."])
		err:SetPoint("CENTER")
		err:Hide()
		dialog.errorText = err

		local link = CreateFrame("Frame", nil, dialog)
		link:SetPoint("TOPLEFT")
		link:SetPoint("TOPRIGHT")
		link:SetHeight(50)
		dialog.link = link

		local icon = link:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("LEFT")
		icon:SetSize(50, 50)
		dialog.linkIcon = icon

		local text = link:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
		text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
		dialog.linkText = text

		link:SetWidth(text:GetWidth() + icon:GetWidth())
		link:SetPoint("TOP", 0, -25)
		link:SetScript("OnLeave", function()
			GameTooltip:Hide()
			BattlePetTooltip:Hide()
		end)

		local cancel = CreateFrame("Button", "PetMarketConfirmCancelButton", dialog, "UIPanelButtonTemplate")
		cancel:SetPoint("BOTTOM", 50, 30)
		cancel:SetSize(80, 22)
		cancel:SetText(L["Cancel"])
		cancel:SetScript("OnClick", function()
			dialog:Hide()
			PetMarket.scrollFrame:Show()
		end)
		dialog.cancelButton = cancel

		local confirm = CreateFrame("Button", "PetMarketConfirmButton", dialog, "UIPanelButtonTemplate")
		confirm:SetPoint("BOTTOM", -50, 30)
		confirm:SetSize(80, 22)
		confirm:SetText(L["Confirm"])
		confirm:SetScript("OnClick", function()
			dialog:Hide()
			PetMarket.scrollFrame:Show()
		end)
		dialog.confirmButton = confirm

		local buyoutText = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		buyoutText.textPattern = L["Buy this item for %s?"]
		dialog.buyoutText = buyoutText

		local bidText = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		bidText.textPattern = L["Bid the minimum of %s on this item?"]
		dialog.bidText = bidText
	end

	SortAuctionClearSort("list")

	if type == "BUYOUT" then
		dialog.bidText:Hide()
		dialog.buyoutText:Show()
		SortAuctionSetSort("list", "buyout")
	elseif type == "BID" then
		dialog.buyoutText:Hide()
		dialog.bidText:Show()
		SortAuctionSetSort("list", "bid")
	end

	SortAuctionApplySort("list")
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	queryType = type
	QueryAuctionItems(active_auction["name"])

	PetMarket.confirmDialog:Show()
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

		local count, total = GetNumAuctionItems("list")
		if lastPage > 0 then
			if battle then
				self.statusText:SetFormattedText(L["Scanning battle pets page %d of %d..."], lastPage, floor(total / AH_ITEMS_PER_PAGE + 0.5))
			else
				self.statusText:SetFormattedText(L["Scanning items page %d of %d..."], lastPage, floor(total / AH_ITEMS_PER_PAGE + 0.5))
			end
		end

		-- Much of the following code taken from MiniPetQ
		for i = 1, count do
			local itemLink = GetAuctionItemLink("list", i)
			local speciesID
			local name, texture, _, _, _, _, _, minBid, _, buyoutPrice, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", i)
			if itemLink and string.find(itemLink, "|Hbattlepet:") then
				_, speciesID = strsplit(":", itemLink)
				speciesID = tonumber(speciesID)
			else
				speciesID = self.PetItems[itemID]
				if not speciesID then
					print("|cffff8000PetMarket:|r", format(L["Unknown pet item: %d %s"], itemID, name))
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
		if AH_ITEMS_PER_PAGE * lastPage > total then
			lastPage = 0
			if battle == true then
				battle = false
				PetMarket:ScheduleTimer("AHQuery", .1)
			else
				local strings = {}
				for key, value in pairs(pets) do
					table.insert(strings, value)
				end
				table.sort(strings, sortEntryStrings)
				self:CreateEntries(strings)
				self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			end
		else
			lastPage = lastPage + 1
			self:ScheduleTimer("AHQuery", .1)
		end
	else
		self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		local link = GetAuctionItemLink("list", 1)
		local name, texture, _, _, _, _, _, minBid, _, buyoutPrice, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", 1)
		if name ~= active_auction["name"] or itemID ~= active_auction["id"] then
			PetMarket.confirmDialog.link:Hide()
			PetMarket.confirmDialog.bidText:Hide()
			PetMarket.confirmDialog.buyoutText:Hide()
			PetMarket.confirmDialog.errorText:Show()
			queryType = "NONE"
			return
		end
		PetMarket.confirmDialog.linkIcon:SetTexture(texture)
		PetMarket.confirmDialog.linkText:SetText(link)
		PetMarket.confirmDialog.link:SetWidth(PetMarket.confirmDialog.linkText:GetWidth() + PetMarket.confirmDialog.linkIcon:GetWidth())
		PetMarket.confirmDialog.link:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self)
			if string.match(link, "|Hbattlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", link)
				BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), nil)
			else
				GameTooltip:SetHyperlink(link)
			end
		end)

		if queryType == "BUYOUT" then
			PetMarket.confirmDialog.buyoutText:SetFormattedText(PetMarket.confirmDialog.buyoutText.textPattern, GetCoinTextureString(buyoutPrice))
			PetMarket.confirmDialog.buyoutText:SetPoint("TOP", PetMarket.confirmDialog.link, "BOTTOM", 0, -20)
			PetMarket.confirmDialog.confirmButton:SetScript("OnClick", function() -- TODO: factor out
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", 1)
				if name == active_auction["name"] and itemID == active_auction["id"] then
					PlaceAuctionBid("list", 1, buyoutPrice)
				end
				PetMarket.confirmDialog:Hide()
				PetMarket.scrollFrame:Show()
			end)
		elseif queryType == "BID" then
			PetMarket.confirmDialog.bidText:SetFormattedText(PetMarket.confirmDialog.bidText.textPattern, GetCoinTextureString(minBid))
			PetMarket.confirmDialog.bidText:SetPoint("TOP", PetMarket.confirmDialog.link, "BOTTOM", 0, -20)
			PetMarket.confirmDialog.confirmButton:SetScript("OnClick", function() -- TODO: factor out
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, itemID = GetAuctionItemInfo("list", 1)
				if name == active_auction["name"] and itemID == active_auction["id"] then
					PlaceAuctionBid("list", 1, minBid)
				end
				PetMarket.confirmDialog:Hide()
				PetMarket.scrollFrame:Show()
			end)
		end
		queryType = "NONE"
	end
end

function PetMarket:AHQuery()
	if AuctionFrame:IsVisible() ~= true then
		print("|cffff8000PetMarket:|r", L["Auction House is closed, can not scan."])
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
	if battle then
		QueryAuctionItems("", 0, 0, 0, 11, 0, lastPage, 0, 0, 0)
	else
		QueryAuctionItems("", 0, 0, 0, 9, 3, lastPage, true, 0, 0)
	end
end