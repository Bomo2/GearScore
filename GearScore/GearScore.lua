------------------------------------------------------------
-- GearScore.lua (final, clean, Private namespace)
------------------------------------------------------------

local _, Private = ...

------------------------------------------------------------
-- Locals
------------------------------------------------------------

local GS_PlayerIsInCombat = false
local GS_TooltipState
local GS_DelayedFrame = CreateFrame("Frame")

local floor = math.floor

------------------------------------------------------------
-- GearScore core
------------------------------------------------------------

function GearScore_GetScore(name, unit)
	if not UnitIsPlayer(unit) then return 0, 0 end

	local _, class = UnitClass(unit)
	local gearScore = 0
	local itemCount = 0
	local levelTotal = 0
	local titanGrip = 1

	-- Titan Grip
	if GetInventoryItemLink(unit, 16) and GetInventoryItemLink(unit, 17) then
		local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(GetInventoryItemLink(unit, 16))
		if equipLoc == "INVTYPE_2HWEAPON" then
			titanGrip = 0.5
		end
	end

	-- Offhand first
	if GetInventoryItemLink(unit, 17) then
		local score, ilvl = GearScore_GetItemScore(GetInventoryItemLink(unit, 17))
		if class == "HUNTER" then score = score * 0.3164 end
		gearScore = gearScore + score * titanGrip
		itemCount = itemCount + 1
		levelTotal = levelTotal + ilvl
	end

	for slot = 1, 18 do
		if slot ~= 4 and slot ~= 17 then
			local link = GetInventoryItemLink(unit, slot)
			if link then
				local score, ilvl = GearScore_GetItemScore(link)

				if slot == 16 then
					if class == "HUNTER" then score = score * 0.3164 end
					score = score * titanGrip
				end

				if slot == 18 and class == "HUNTER" then
					score = score * 5.3224
				end

				gearScore = gearScore + score
				itemCount = itemCount + 1
				levelTotal = levelTotal + ilvl
			end
		end
	end

	if itemCount == 0 then return 0, 0 end
	return floor(gearScore), floor(levelTotal / itemCount)
end

------------------------------------------------------------
-- Item score
------------------------------------------------------------

function GearScore_GetItemScore(itemLink)
	if not itemLink then return 0, 0 end

	local _, _, ItemRarity, ItemLevel, _, _, _, _, ItemEquipLoc = GetItemInfo(itemLink)
	local slotData = Private.ITEM_TYPES[ItemEquipLoc]
	if not ItemRarity or not slotData then return 0, 0 end

	local QualityScale = 1
	if ItemRarity == 5 then QualityScale = 1.3; ItemRarity = 4 end
	if ItemRarity == 1 or ItemRarity == 0 then QualityScale = 0.005; ItemRarity = 2 end
	if ItemRarity == 7 then ItemRarity = 3; ItemLevel = 187.05 end

	local Table = (ItemLevel > 120) and Private.FORMULA.A or Private.FORMULA.B
	local Scale = 1.8618

	-- ?? EXACT GearScoreLite color math (NO SlotMOD, NO QualityScale)
	local ColorScore =
		floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * Scale) * 11.25

	local r, g, b = GearScore_GetQuality(ColorScore)

	-- ?? REAL GearScore (SEPARATE)
	local GearScore =
		floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B)
		* slotData.SlotMOD
		* Scale
		* QualityScale)

	if GearScore < 0 then
		GearScore = 0
		r, g, b = GearScore_GetQuality(1)
	end

	if ItemLevel == 187.05 then ItemLevel = 0 end

	return GearScore, ItemLevel, r, g, b
end

------------------------------------------------------------
-- Quality colors
------------------------------------------------------------

function GearScore_GetQuality(score)
	if not score then return 0.1, 0.1, 0.1 end
	if score > 5999 then score = 5999 end

	for i = 1, 6 do
		local threshold = i * 1000
		if score > (threshold - 1000) and score <= threshold then
			local q = Private.QUALITY[threshold]
			if not q then break end

			local r = q.Red.A   + ((score - q.Red.B)   * q.Red.C   * q.Red.D)
			local g = q.Green.A + ((score - q.Green.B) * q.Green.C * q.Green.D)
			local b = q.Blue.A  + ((score - q.Blue.B)  * q.Blue.C  * q.Blue.D)

			return r, g, b
		end
	end

	return 0.1, 0.1, 0.1
end


------------------------------------------------------------
-- Tooltip: unit
------------------------------------------------------------

local function ShowUnitGearScore(tooltip, unit)
	if not tooltip:IsShown() then return end
	if not UnitExists(unit) or not UnitIsPlayer(unit) then return end
	if Private.Settings.Player ~= 1 then return end

	local name = UnitName(unit)
	local gs, avg = GearScore_GetScore(name, unit)
	if gs <= 0 then return end

	local r, g, b = GearScore_GetQuality(gs)
	tooltip:AddLine(" ")

	if Private.Settings.Level == 1 then
		tooltip:AddDoubleLine("GearScore: "..gs, "(iLevel "..avg..")", r, g, b, r, g, b)
	else
		tooltip:AddLine("GearScore: "..gs, r, g, b)
	end

	tooltip:Show()
end

------------------------------------------------------------
-- Tooltip: items (ORIGINAL GearScore behavior)
------------------------------------------------------------

local function ShowItemGearScore(tooltip, link)
	if GS_PlayerIsInCombat then return end
	if not IsEquippableItem(link) then return end
	if Private.Settings.Item ~= 1 then return end

	local score, ilvl, r, b, g = GearScore_GetItemScore(link)
	if score <= 0 then return end

	if Private.Settings.Level == 1 then
		tooltip:AddDoubleLine(
			"GearScore: "..score,
			"(iLevel "..ilvl..")",
			r, g, b,
			r, g, b
		)
	else
		tooltip:AddLine("GearScore: "..score, r, b, g)
	end
end


------------------------------------------------------------
-- Delayed tooltip logic
------------------------------------------------------------

local function OnDelayedTooltipUpdate(self)
	if not self.tooltip:IsShown() or not UnitExists(self.unit) then
		GS_TooltipState = nil
		self:SetScript("OnUpdate", nil)
		self:Hide()
		return
	end

	if GetTime() - self.startTime >= self.delay then
		self:SetScript("OnUpdate", nil)
		self:Hide()
		ShowUnitGearScore(self.tooltip, self.unit)
		GS_TooltipState = nil
	end
end

------------------------------------------------------------
-- Tooltip hooks
------------------------------------------------------------

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	if GS_PlayerIsInCombat or GS_TooltipState then return end

	local _, unit = self:GetUnit()
	if not unit or not UnitIsPlayer(unit) then return end

	GS_TooltipState = self
	NotifyInspect(unit)

	GS_DelayedFrame.startTime = GetTime()
	GS_DelayedFrame.delay = 0.4
	GS_DelayedFrame.unit = unit
	GS_DelayedFrame.tooltip = self
	GS_DelayedFrame:SetScript("OnUpdate", OnDelayedTooltipUpdate)
	GS_DelayedFrame:Show()
end)

GameTooltip:HookScript("OnHide", function(self)
	if GS_TooltipState == self then
		GS_TooltipState = nil
		GS_DelayedFrame:SetScript("OnUpdate", nil)
		GS_DelayedFrame:Hide()
	end
end)

GameTooltip:HookScript("OnTooltipSetItem", function(self)
	local _, link = self:GetItem()
	if link then ShowItemGearScore(self, link) end
end)

ItemRefTooltip:HookScript("OnTooltipSetItem", function(self)
	local _, link = self:GetItem()
	if link then ShowItemGearScore(self, link) end
end)

ShoppingTooltip1:HookScript("OnTooltipSetItem", function(self)
	local _, link = self:GetItem()
	if link then ShowItemGearScore(self, link) end
end)

ShoppingTooltip2:HookScript("OnTooltipSetItem", function(self)
	local _, link = self:GetItem()
	if link then ShowItemGearScore(self, link) end
end)

------------------------------------------------------------
-- PaperDoll
------------------------------------------------------------

local function UpdatePaperDoll()
	if GS_PlayerIsInCombat then return end
	if not PersonalGearScore then return end

	local gs = GearScore_GetScore(UnitName("player"), "player")
	local r, b, g = GearScore_GetQuality(gs)

	PersonalGearScore:SetText(gs)
	PersonalGearScore:SetTextColor(r, g, b, 1)
end

------------------------------------------------------------
-- Init
------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

f:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "GearScore" then
		Private.Settings = Private.Settings or CopyTable(Private.DEFAULT_SETTINGS)

		-- === GS VALUE ===
		if not PersonalGearScore then
			PaperDollFrame:CreateFontString("PersonalGearScore", "OVERLAY")
			PersonalGearScore:SetFont("Fonts\\FRIZQT__.TTF", 10)
			PersonalGearScore:SetText("0")
			PersonalGearScore:SetPoint("BOTTOMLEFT", PaperDollFrame, "TOPLEFT", 72, -253)
			PersonalGearScore:Show()
		end

		-- === GS LABEL ===
		if not GearScoreLabel then
			PaperDollFrame:CreateFontString("GearScoreLabel", "OVERLAY")
			GearScoreLabel:SetFont("Fonts\\FRIZQT__.TTF", 10)
			GearScoreLabel:SetText("GearScore")
			GearScoreLabel:SetTextColor(1, 1, 1, 1)
			GearScoreLabel:SetPoint("BOTTOMLEFT", PaperDollFrame, "TOPLEFT", 72, -265)
			GearScoreLabel:Show()
		end

	elseif event == "PLAYER_REGEN_ENABLED" then
		GS_PlayerIsInCombat = false

	elseif event == "PLAYER_REGEN_DISABLED" then
		GS_PlayerIsInCombat = true

	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		UpdatePaperDoll()
	end
end)

PaperDollFrame:HookScript("OnShow", UpdatePaperDoll)