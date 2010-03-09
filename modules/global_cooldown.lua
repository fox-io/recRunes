-- $Id: global_cooldown.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local _, recRunes = ...
if not recRunes.opt.global_cooldown.show then return end

gcd = CreateFrame("StatusBar", "rr_gcd", rr_rune_bg)
gcd:SetHeight(5)
gcd:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, 1)
gcd:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, 1)

gcd.tx = gcd:CreateTexture(nil, "ARTWORK")
gcd.tx:SetAllPoints()
gcd.tx:SetTexture(recRunes.statusbar_texture)
gcd.tx:SetVertexColor(.6, .6, 0, 1)
gcd:SetStatusBarTexture(gcd.tx)

gcd.soft_edge = CreateFrame("Frame", nil, gcd)
gcd.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
gcd.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
gcd.soft_edge:SetBackdrop({
	bgFile = recRunes.bg_file,
	edgeFile = recRunes.edge_file, edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
gcd.soft_edge:SetFrameStrata("BACKGROUND")
gcd.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
gcd.soft_edge:SetBackdropBorderColor(0, 0, 0)

--gcd.bg = gcd:CreateTexture(nil, "BORDER")
--gcd.bg:SetPoint("TOPLEFT")
--gcd.bg:SetPoint("BOTTOMRIGHT")
--gcd.bg:SetTexture(recRunes.statusbar_texture)
--gcd.bg:SetVertexColor(0.25, 0.25, 0.25, 1)

gcd:Hide()
--gcd:SetMinMaxValues(0, 1)
--gcd:SetValue(.6)
--gcd:Show()
gcd.s = 0
gcd.d = 0

local timer = 0
gcd:SetScript("OnUpdate", function(self, elapsed)

	-- Throttle Updates.
	--timer = timer - elapsed
	--if timer > 0 then return end
	--timer = 0.025
	
	gcd:SetMinMaxValues(0, 1)
	
	local p = (GetTime() - gcd.s) / gcd.d
	if p > 1 then
		gcd:Hide()
	else
		gcd:SetValue(p)
	end
end)

gcd:RegisterEvent("SPELL_UPDATE_COOLDOWN")

local function GCD()
	local s, d = GetSpellCooldown(recRunes.gcd_reference_spell)
	
	if not s or s == 0 or not d or d == 0 or d > 1.5 then
		gcd:Hide()
		return
	end
	
	-- We only store the values here.  The display is updated in the OnUpdate.
	gcd.s = s
	gcd.d = d
	gcd:SetValue(0)
	gcd:Show()
end

gcd:SetScript("OnEvent", GCD)--]]