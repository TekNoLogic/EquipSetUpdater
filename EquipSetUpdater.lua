
----------------------
--      Locals      --
----------------------

local orig
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

	local butt = GearManagerDialogSaveSet

	local temp = {}
	orig = butt:GetScript("OnClick")
	butt:SetScript("OnClick", self.UpdateSet)
	hooksecurefunc("GearManagerDialog_Update", self.MODIFIER_STATE_CHANGED)

	self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	LibStub("tekKonfig-AboutPanel").new(nil, "EquipSetUpdater")

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end


function f:MODIFIER_STATE_CHANGED()
	GearManagerDialogSaveSet:SetText((not GearManagerDialog.selectedSet or IsModifiedClick()) and "Save" or "Update")
end
f.EQUIPMENT_SETS_CHANGED = f.MODIFIER_STATE_CHANGED


local function GetTextureIndex(tex)
	RefreshEquipmentSetIconInfo()
	tex = tex:lower()
	local numicons = GetNumMacroIcons()
	for i=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do if GetInventoryItemTexture("player", i) then numicons = numicons + 1 end end
	for i=1,numicons do
		local texture, index = GetEquipmentSetIconInfo(i)
		if texture:lower() == tex then return index end
	end
end


function f:UpdateSet(...)
	local set = GearManagerDialog.selectedSet
	if not set or IsModifiedClick() then return orig(self, ...) end

	local texi = GetTextureIndex(set.icon:GetTexture())
	if not texi then return Print("Error finding icon index, cannot save set.") end
	SaveEquipmentSet(set.name, texi)
end
