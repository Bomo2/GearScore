function GearScore_OnEvent(GS_Nil, GS_EventName, GS_Prefix, GS_AddonMessage, GS_Whisper, GS_Sender)
	if ( GS_EventName == "PLAYER_REGEN_ENABLED" ) then GS_PlayerIsInCombat = false; return; end
	if ( GS_EventName == "PLAYER_REGEN_DISABLED" ) then GS_PlayerIsInCombat = true; return; end
	if ( GS_EventName == "PLAYER_EQUIPMENT_CHANGED" ) then
	    local MyGearScore = GearScore_GetScore(UnitName("player"), "player");
		local Red, Blue, Green = GearScore_GetQuality(MyGearScore)
    	PersonalGearScore:SetText(MyGearScore); PersonalGearScore:SetTextColor(Red, Green, Blue, 1)
  	end
	if ( GS_EventName == "ADDON_LOADED" ) then
		if ( GS_Prefix == "GearScore" ) then
      		if not ( GS_Settings ) then	GS_Settings = GS_DefaultSettings end
  			for i, v in pairs(GS_DefaultSettings) do if not ( GS_Settings[i] ) then GS_Settings[i] = GS_DefaultSettings[i]; end; end
        end
	end
end


function GearScore_GetScore(Name, Target)
	if ( UnitIsPlayer(Target) ) then
	    local _, PlayerEnglishClass = UnitClass(Target)
		local GearScore = 0; local ItemCount = 0; local LevelTotal = 0; local TitanGrip = 1

		if ( GetInventoryItemLink(Target, 16) ) and ( GetInventoryItemLink(Target, 17) ) then
      		local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GetInventoryItemLink(Target, 16))
            if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) then TitanGrip = 0.5; end
		end

		if ( GetInventoryItemLink(Target, 17) ) then
			local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GetInventoryItemLink(Target, 17))
			if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) then TitanGrip = 0.5; end
			TempScore, ItemLevel = GearScore_GetItemScore(GetInventoryItemLink(Target, 17));
			if ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 0.3164; end
			GearScore = GearScore + TempScore * TitanGrip;	ItemCount = ItemCount + 1; LevelTotal = LevelTotal + ItemLevel
		end
		
		for i = 1, 18 do
			if ( i ~= 4 ) and ( i ~= 17 ) then
        		ItemLink = GetInventoryItemLink(Target, i)
				if ( ItemLink ) then
        			local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink)
     				TempScore = GearScore_GetItemScore(ItemLink);
					if ( i == 16 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 0.3164; end
					if ( i == 18 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 5.3224; end
					if ( i == 16 ) then TempScore = TempScore * TitanGrip; end
					GearScore = GearScore + TempScore;	ItemCount = ItemCount + 1; LevelTotal = LevelTotal + ItemLevel
				end
			end;
		end
		if ( GearScore <= 0 ) and ( Name ~= UnitName("player") ) then
			GearScore = 0; return 0,0;
		elseif ( Name == UnitName("player") ) and ( GearScore <= 0 ) then
		    GearScore = 0; end
	if ( ItemCount == 0 ) then LevelTotal = 0; end		    
	return floor(GearScore), floor(LevelTotal/ItemCount)
	end
end

				
function GearScore_GetItemScore(ItemLink)
	local QualityScale = 1; local GearScore = 0
	if not ( ItemLink ) then return 0, 0; end
	local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink); local Table = {}; local Scale = 1.8618
 	if ( ItemRarity == 5 ) then QualityScale = 1.3; ItemRarity = 4;
	elseif ( ItemRarity == 1 ) then QualityScale = 0.005;  ItemRarity = 2
	elseif ( ItemRarity == 0 ) then QualityScale = 0.005;  ItemRarity = 2 end
    if ( ItemRarity == 7 ) then ItemRarity = 3; ItemLevel = 187.05; end
    if ( GS_ItemTypes[ItemEquipLoc] ) then
        if ( ItemLevel > 120 ) then Table = GS_Formula["A"]; else Table = GS_Formula["B"]; end
		if ( ItemRarity >= 2 ) and ( ItemRarity <= 4 )then
            local Red, Green, Blue = GearScore_GetQuality((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * Scale)) * 11.25 )
            GearScore = floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * GS_ItemTypes[ItemEquipLoc].SlotMOD * Scale * QualityScale)
			if ( ItemLevel == 187.05 ) then ItemLevel = 0; end
			if ( GearScore < 0 ) then GearScore = 0;   Red, Green, Blue = GearScore_GetQuality(1); end
			GearScore = floor(GearScore)
			return GearScore, ItemLevel, GS_ItemTypes[ItemEquipLoc].ItemSlot, Red, Green, Blue, ItemEquipLoc
		end
  	end
  	return -1, ItemLevel, 50, 1, 1, 1, ItemEquipLoc
end


function GearScore_GetQuality(ItemScore)
	if ( ItemScore > 5999 ) then ItemScore = 5999; end
   	if not ( ItemScore ) then return 0, 0, 0; end
	for i = 0,6 do
		if ( ItemScore > i * 1000 ) and ( ItemScore <= ( ( i + 1 ) * 1000 ) ) then
		    local Red = GS_Quality[( i + 1 ) * 1000].Red["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Red["B"])*GS_Quality[( i + 1 ) * 1000].Red["C"])*GS_Quality[( i + 1 ) * 1000].Red["D"])
            local Blue = GS_Quality[( i + 1 ) * 1000].Green["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Green["B"])*GS_Quality[( i + 1 ) * 1000].Green["C"])*GS_Quality[( i + 1 ) * 1000].Green["D"])
            local Green = GS_Quality[( i + 1 ) * 1000].Blue["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Blue["B"])*GS_Quality[( i + 1 ) * 1000].Blue["C"])*GS_Quality[( i + 1 ) * 1000].Blue["D"])
			--if not ( Red ) or not ( Blue ) or not ( Green ) then return 0.1, 0.1, 0.1, nil; end
			return Red, Green, Blue, GS_Quality[( i + 1 ) * 1000].Description
		end
	end
return 0.1, 0.1, 0.1
end


function GearScore_HookSetUnit(arg1, arg2)
	if ( GS_PlayerIsInCombat ) then return; end
	local Name = GameTooltip:GetUnit();local MouseOverGearScore, MouseOverAverage = 0,0
	local mouseoverunit="mouseover"
	local inspectStatus = CanInspect(mouseoverunit)
	local ifs = 0
	if (InspectFrame or false) then
		ifs = InspectFrame:IsShown() or 0
	end
	if (Examiner or false) then
		ifs = Examiner:IsShown() or 0
	end
	if (ElvUI or VuhDo) and inspectStatus == nil then
		local tf = GetMouseFocus()
		mouseoverunit = tf.unit or tf.raidid or "mouseover"
		inspectStatus = CanInspect(mouseoverunit or "mouseover")
	end
	if ( CanInspect(mouseoverunit) ) and ( UnitName(mouseoverunit) == Name ) and not ( GS_PlayerIsInCombat ) and ( ifs ~= 1 ) then 
		NotifyInspect(mouseoverunit); MouseOverGearScore, MouseOverAverage = GearScore_GetScore(Name, mouseoverunit); 
	end
 	if ( MouseOverGearScore ) and ( MouseOverGearScore > 0 ) and ( GS_Settings["Player"] == 1 ) then 
		local Red, Blue, Green = GearScore_GetQuality(MouseOverGearScore)
		if ( GS_Settings["Level"] == 1 ) then 
			GameTooltip:AddDoubleLine("GearScore: "..MouseOverGearScore, "(iLevel: "..MouseOverAverage..")", Red, Green, Blue, Red, Green, Blue)
		else
			GameTooltip:AddLine("GearScore: "..MouseOverGearScore, Red, Green, Blue)
		end
		if ( GS_Settings["Compare"] == 1 ) then
			local MyGearScore = GearScore_GetScore(UnitName("player"), "player");
			local TheirGearScore = MouseOverGearScore
			if ( MyGearScore  > TheirGearScore  ) then GameTooltip:AddDoubleLine("YourScore: "..MyGearScore  , "(+"..(MyGearScore - TheirGearScore  )..")", 0,1,0, 0,1,0); end
			if ( MyGearScore   < TheirGearScore   ) then GameTooltip:AddDoubleLine("YourScore: "..MyGearScore, "(-"..(TheirGearScore - MyGearScore  )..")", 1,0,0, 1,0,0); end	
			if ( MyGearScore   == TheirGearScore   ) then GameTooltip:AddDoubleLine("YourScore: "..MyGearScore  , "(+0)", 0,1,1,0,1,1); end	
		end
	end
end


function GearScore_HookSetItem() ItemName, ItemLink = GameTooltip:GetItem(); GearScore_HookItem(ItemName, ItemLink, GameTooltip); end
function GearScore_HookRefItem() ItemName, ItemLink = ItemRefTooltip:GetItem(); GearScore_HookItem(ItemName, ItemLink, ItemRefTooltip); end
function GearScore_HookCompareItem() ItemName, ItemLink = ShoppingTooltip1:GetItem(); GearScore_HookItem(ItemName, ItemLink, ShoppingTooltip1); end
function GearScore_HookCompareItem2() ItemName, ItemLink = ShoppingTooltip2:GetItem(); GearScore_HookItem(ItemName, ItemLink, ShoppingTooltip2); end
function GearScore_HookItem(ItemName, ItemLink, Tooltip)
	if ( GS_PlayerIsInCombat ) then return; end
	local _, PlayerEnglishClass = UnitClass("player")
	if not ( IsEquippableItem(ItemLink) ) then return; end
	local ItemScore, ItemLevel, _, Red, Green, Blue, ItemEquipLoc = GearScore_GetItemScore(ItemLink);
 	if ( ItemScore >= 0 ) then
		if ( GS_Settings["Item"] == 1 ) then
  			if ( ItemLevel ) and ( GS_Settings["Level"] == 1 ) then Tooltip:AddDoubleLine("GearScore: "..ItemScore, "(iLevel "..ItemLevel..")", Red, Blue, Green, Red, Blue, Green);
				if ( PlayerEnglishClass == "HUNTER" ) then
					if ( ItemEquipLoc == "INVTYPE_RANGEDRIGHT" ) or ( ItemEquipLoc == "INVTYPE_RANGED" ) then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 5.3224), Red, Blue, Green)
					end
					if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) or ( ItemEquipLoc == "INVTYPE_WEAPONMAINHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPONOFFHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPON" ) or ( ItemEquipLoc == "INVTYPE_HOLDABLE" )  then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 0.3164), Red, Blue, Green)
					end
				end
			else
				Tooltip:AddLine("GearScore: "..ItemScore, Red, Blue, Green)
				if ( PlayerEnglishClass == "HUNTER" ) then
					if ( ItemEquipLoc == "INVTYPE_RANGEDRIGHT" ) or ( ItemEquipLoc == "INVTYPE_RANGED" ) then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 5.3224), Red, Blue, Green)
					end
					if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) or ( ItemEquipLoc == "INVTYPE_WEAPONMAINHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPONOFFHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPON" ) or ( ItemEquipLoc == "INVTYPE_HOLDABLE" )  then
						Tooltip:AddLine("HunterScore: "..floor(ItemScore * 0.3164), Red, Blue, Green)
					end
				end
    		end
  		end
	else
	    if ( GS_Settings["Level"] == 1 ) and ( ItemLevel ) then
	        Tooltip:AddLine("iLevel "..ItemLevel)
		end
    end
end
function GearScore_OnEnter(Name, ItemSlot, Argument)
	if ( UnitName("target") ) then NotifyInspect("target"); GS_LastNotified = UnitName("target"); end
	local OriginalOnEnter = GearScore_Original_SetInventoryItem(Name, ItemSlot, Argument); return OriginalOnEnter
end
function MyPaperDoll()
	if ( GS_PlayerIsInCombat ) then return; end
	local MyGearScore = GearScore_GetScore(UnitName("player"), "player");
	local Red, Blue, Green = GearScore_GetQuality(MyGearScore)
    PersonalGearScore:SetText(MyGearScore); PersonalGearScore:SetTextColor(Red, Green, Blue, 1)
end


local f = CreateFrame("Frame", "GearScore", UIParent);
f:SetScript("OnEvent", GearScore_OnEvent);
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
GameTooltip:HookScript("OnTooltipSetUnit", GearScore_HookSetUnit)
GameTooltip:HookScript("OnTooltipSetItem", GearScore_HookSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", GearScore_HookCompareItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", GearScore_HookCompareItem2)
ItemRefTooltip:HookScript("OnTooltipSetItem", GearScore_HookRefItem)
PaperDollFrame:HookScript("OnShow", MyPaperDoll)
PaperDollFrame:CreateFontString("PersonalGearScore")

PersonalGearScore:SetFont("Fonts\\FRIZQT__.TTF", 10)
PersonalGearScore:SetText("GS: 0")
PersonalGearScore:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",72,-253)
PersonalGearScore:Show()
PaperDollFrame:CreateFontString("GearScore2")
GearScore2:SetFont("Fonts\\FRIZQT__.TTF", 10)
GearScore2:SetText("GearScore")
GearScore2:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",72,-265)
GearScore2:Show()
GearScore_Original_SetInventoryItem = GameTooltip.SetInventoryItem
GameTooltip.SetInventoryItem = GearScore_OnEnter