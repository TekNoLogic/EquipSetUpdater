
----------------------
--      Locals      --
----------------------

local slotbutts = {CharacterHeadSlot, CharacterNeckSlot, CharacterShoulderSlot, CharacterShirtSlot, CharacterChestSlot, CharacterWaistSlot, CharacterLegsSlot,
	CharacterFeetSlot, CharacterWristSlot, CharacterHandsSlot, CharacterFinger0Slot, CharacterFinger1Slot, CharacterTrinket0Slot, CharacterTrinket1Slot,
	CharacterBackSlot, CharacterMainHandSlot, CharacterSecondaryHandSlot, CharacterRangedSlot, CharacterTabardSlot}


------------------------------
--      Util Functions      --
------------------------------

local function Print(...) print("|cFF33FF99EquipSetUpdater|r:", ...) end

local debugf = tekDebug and tekDebug:GetFrame("EquipSetUpdater")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end


-----------------------------
--      Event Handler      --
-----------------------------

local f = CreateFrame("frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")


function f:ADDON_LOADED(event, addon)
	if addon:lower() ~= "equipsetupdater" then return end

	GearManagerDialogSaveSet:SetWidth(80)
	GearManagerDialogDeleteSet:SetWidth(80)

	local butt = CreateFrame("Button", nil, GearManagerDialog)
	butt:SetPoint("TOPLEFT", GearManagerDialogDeleteSet, "TOPRIGHT", 1, 0)
	butt:SetPoint("BOTTOMRIGHT", GearManagerDialogSaveSet, "BOTTOMLEFT", -1, 0)

	butt:SetDisabledFontObject(GameFontDisable)
	butt:SetHighlightFontObject(GameFontHighlight)
	butt:SetNormalFontObject(GameFontNormal)

	butt:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	butt:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	butt:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	butt:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	butt:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetBlendMode("ADD")

	butt:SetText("Update")
	butt:Disable()
	self.butt = butt

	local temp = {}
	butt:SetScript("OnShow", butt.Disable)
	butt:SetScript("OnClick", self.UpdateSet)
	hooksecurefunc("GearSetButton_OnClick", function(self)
		if GearManagerDialog.selectedSet then
			butt:Enable()
			local ids = GetEquipmentSetItemIDs(GearManagerDialog.selectedSet.name, wipe(temp))
			for i=1,19 do
				local butt = slotbutts[i]
				if not ids[i] then
					if not butt.ignored then
						EquipmentManagerIgnoreSlotForSave(i)
						butt.ignored = true
						PaperDollItemSlotButton_Update(butt)
					end
				elseif butt.ignored then
					EquipmentManagerUnignoreSlotForSave(i)
					butt.ignored = nil
					PaperDollItemSlotButton_Update(butt)
				end
			end
		else butt:Disable() end
	end)

	self:RegisterEvent("EQUIPMENT_SETS_CHANGED")

	LibStub("tekKonfig-AboutPanel").new(nil, "EquipSetUpdater")

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end


function f:EQUIPMENT_SETS_CHANGED()
	self.butt:Disable()
end


local function GetTextureIndex(tex)
	tex = tex:lower()
	local numicons = GetNumMacroIcons()
	for i=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do if GetInventoryItemTexture("player", i) then numicons = numicons + 1 end end
	for i=1,numicons do
		local texture, index = GetEquipmentSetIconInfo(i)
		if texture:lower() == tex then return index end
	end
end


function f:UpdateSet()
	local set = GearManagerDialog.selectedSet
	if not set then return end

	local texi = GetTextureIndex(set.icon:GetTexture())
	if not texi then return Print("Error finding icon index, cannot save set.") end
	SaveEquipmentSet(set.name, texi)
end
