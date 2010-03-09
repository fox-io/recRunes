-- $Id: diseases.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local _, recRunes = ...
if not recRunes.opt.diseases.show then return end

local event_frame = CreateFrame("Frame")
local frost_fever = 55095
local blood_plague = 55078

local function on_update(self, elapsed)
	self.timer = self.timer - elapsed
	
	if self.timer > 0 then return end
	self.timer = 0.01
	
	if self.active then
		if self.expires >= GetTime() then
			self:SetValue(self.expires - GetTime())
			self:SetMinMaxValues(0, self.duration)
			self.lbl:SetText(math.floor(self.expires - GetTime()))
		else
			self.active = false
		end
	end
	
	if not self.active then
		self:Hide()
	end
end

local function make_bar(name)
	local bar = CreateFrame("StatusBar", name, rr_rune_bg)
	bar:SetHeight(10)
	bar:SetWidth(100)
	bar.active = false
	bar.expires = 0
	bar.duration = 0
	bar.timer = 0
	
	bar.tx = bar:CreateTexture(nil, "ARTWORK")
	bar.tx:SetAllPoints()
	bar.tx:SetTexture(recRunes.statusbar_texture)	
	bar:SetStatusBarTexture(bar.tx)
	
	bar.soft_edge = CreateFrame("Frame", nil, bar)
	bar.soft_edge:SetPoint("TOPLEFT", -4, 3.5)
	bar.soft_edge:SetPoint("BOTTOMRIGHT", 4, -4)
	bar.soft_edge:SetBackdrop({
		bgFile = recRunes.bg_file,
		edgeFile = recRunes.edge_file, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	bar.soft_edge:SetFrameStrata("BACKGROUND")
	bar.soft_edge:SetBackdropColor(0.15, 0.15, 0.15, 1)
	bar.soft_edge:SetBackdropBorderColor(0, 0, 0)
	
	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints()
	bar.bg:SetTexture(recRunes.statusbar_texture)
	bar.bg:SetVertexColor(recRunes.opt.background_color.r, recRunes.opt.background_color.g, recRunes.opt.background_color.b, recRunes.opt.background_color.a)
	
	bar.lbl = bar:CreateFontString(string.format("%s_label", name), "ARTWORK")
	bar.lbl:SetFontObject(recRunesFont)
	bar.lbl:SetPoint("CENTER", 0, 1)
	
	if name == "cdkd_frost_fever" then
		bar:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, recRunes.opt.global_cooldown.show and 26 or 16)
		bar:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, recRunes.opt.global_cooldown.show and 26 or 16)
		bar.tx:SetVertexColor(0, 1, 1, 1)
	else
		bar:SetPoint("BOTTOMLEFT", rr_rune_1, "TOPLEFT", 3.5, recRunes.opt.global_cooldown.show and 11 or 1)
		bar:SetPoint("BOTTOMRIGHT", rr_rune_6, "TOPRIGHT", -4.5, recRunes.opt.global_cooldown.show and 11 or 1)
		bar.tx:SetVertexColor(0, .75, 0, 1)
	end
	
	bar:Hide()
	--bar:Show()
	bar:SetScript("OnUpdate", on_update)
	return bar
end

local frost_fever_bar = make_bar("cdkd_frost_fever")
local blood_plague_bar = make_bar("cdkd_blood_plague")

local function on_target()
	for i = 1, 40 do
		_, _, _, _, _, duration, expires, caster, _, _, spell_id = UnitDebuff("target", i)
		if spell_id == frost_fever and caster == "player" then
			frost_fever_bar.active = true
			frost_fever_bar.expires = expires
			frost_fever_bar.duration = duration
			frost_fever_bar:Show()
		end
		if spell_id == blood_plague and caster == "player" then
			blood_plague_bar.active = true
			blood_plague_bar.expires = expires
			blood_plague_bar.duration = duration
			blood_plague_bar:Show()
		end
	end
end

local function on_cleu(...)
	local _, event, source_guid, _, _, dest_guid, _, _, spell_id, spell_name, _, _ = ...
	if source_guid ~= UnitGUID("player") then return end
	if dest_guid ~= UnitGUID("target") then return end
	if spell_id ~= frost_fever and spell_id ~= blood_plague then return end
	
	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
		on_target()
		
	elseif event == "SPELL_AURA_REMOVED" then
		if spell_id == frost_fever then
			frost_fever_bar.active = false
			frost_fever_bar.expires = 0
		elseif spell_id == blood_plague then
			blood_plague_bar.active = false
			blood_plague_bar.expires = 0
		end
	end
end

event_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event_frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		frost_fever_bar:Hide()
		blood_plague_bar:Hide()
		on_target()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		on_cleu(...)
	end
end)