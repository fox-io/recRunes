-- $Id: runic_power.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local _, recRunes = ...
if not recRunes.opt.runic_power.show then return end

local delay = 0

rp = CreateFrame("StatusBar", "rr_rp", rr_rune_bg)
rp:SetHeight(10)
rp:SetPoint("TOPLEFT", rr_rune_1, "BOTTOMLEFT", 4, -1)
rp:SetPoint("TOPRIGHT", rr_rune_6, "BOTTOMRIGHT", -4, -1)
rp:SetStatusBarColor(0, 0, 1, 0.5)

rp.tx = rp:CreateTexture(nil, "ARTWORK")
rp.tx:SetAllPoints()
rp.tx:SetTexture([[Interface\AddOns\recRunes\media\normtexa.tga]])
rp.tx:SetVertexColor(.5, .75, 1, 1)
rp:SetStatusBarTexture(rp.tx)

rp.lbl = rp:CreateFontString("CDKR_rpl", "ARTWORK")
rp.lbl:SetFontObject(recRunesFont)
rp.lbl:SetPoint("CENTER", 0, 1)

rp.soft_edge = CreateFrame("Frame", nil, rp)
rp.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
rp.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
rp.soft_edge:SetBackdrop({
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\Addons\recRunes\media\glowtex]], edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
rp.soft_edge:SetFrameStrata("BACKGROUND")
rp.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
rp.soft_edge:SetBackdropBorderColor(0, 0, 0)

rp.bg = rp:CreateTexture(nil, "BORDER")
rp.bg:SetAllPoints()
rp.bg:SetTexture([[Interface\AddOns\recRunes\media\normtexa.tga]])
rp.bg:SetVertexColor(0.25, 0.25, 0.25, 1)

local timer = 0
rp:SetScript("OnUpdate", function(self, elapsed)
	-- Throttle Updates.
	timer = timer - elapsed
	if timer > 0 then return end
	timer = 0.25
	
	rp.lbl:SetText(UnitPower("player"))
	rp:SetMinMaxValues(0,UnitPowerMax("player"))
	rp:SetValue(UnitPower("player"))
end)