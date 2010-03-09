-- $Id: runes.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local _, recRunes = ...

local runes		= {}
local bg		= CreateFrame("Frame", "rr_rune_bg", UIParent, nil)
local colors	= {
	[1] = { 1.00, 0.00, 0.00 },	-- Blood
	[2] = { 0.00, 0.75, 0.00 },	-- Unholy
	[3] = { 0.00, 1.00, 1.00 },	-- Frost
	[4] = { 0.90, 0.10, 1.00 },	-- Death
}

local font = CreateFont("recRunesFont")
font:SetFont(recRunes.font_face, recRunes.font_size, recRunes.font_flags)

local function make_backdrop(frame)
	frame.bg = CreateFrame("Frame", nil, frame)
	frame.bg:SetPoint("TOPLEFT")
	frame.bg:SetPoint("BOTTOMRIGHT")
	frame.bg:SetBackdrop({
		bgFile = recRunes.bg_file,
		edgeFile = recRunes.edge_file, edgeSize = 4,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	frame.bg:SetFrameStrata("BACKGROUND")
	frame.bg:SetBackdropColor(0, 0, 0, .5)
	frame.bg:SetBackdropBorderColor(0, 0, 0)
end

bg:SetHeight(25)
bg:SetWidth(135)

bg:SetPoint("CENTER")
bg:SetMovable(true)
bg:RegisterForDrag("LeftButton")
bg:SetUserPlaced(true)

bg.in_vehicle = false

for i = 1,6 do
	runes[i] = CreateFrame("Frame", format("rr_rune_%d", i), bg, nil)
	make_backdrop(runes[i])
	runes[i]:SetHeight(23)
	runes[i]:SetWidth(23)
	-- First rune is anchored to the backdrop, the rest are anchored to the previous rune.
	-- runes[i]:SetPoint(i == 1 and "TOPLEFT" or "LEFT" , i == 1 and bg or runes[i - 1], i == 1 and "TOPLEFT" or "RIGHT", i == 1 and 2.5 or 2, i == 1 and (showgcd and -10 or -2.5) or 0)
	runes[i]:SetPoint("LEFT" , i == 1 and bg or runes[i - 1], i == 1 and "LEFT" or "RIGHT", 0, 0)
	runes[i].timer = runes[i]:CreateFontString(format("rr_rune_timer_%d", i), "ARTWORK")
	runes[i].timer:SetFontObject(recRunesFont)
	runes[i].timer:SetPoint("CENTER")
end

local timer = 0
bg:SetScript("OnUpdate", function(self, elapsed)
	-- Throttle Updates.
	timer = timer - elapsed
	if timer > 0 then return end
	timer = 0.25
	
	for i = 1,6 do
		local s, d, r = GetRuneCooldown(i)
		local c = colors[GetRuneType(i)]
		runes[i].bg:SetBackdropColor( (r and c[1] or (c[1] * .3)), (r and c[2] or (c[2] * .3)), (r and c[3] or (c[3] * .3)), 1)
		if not r then
			local t = math.ceil(10 - (GetTime() - s))
			runes[i].timer:SetText(((t < 1) or UnitIsDeadOrGhost("player")) and "" or t)
		else
			runes[i].timer:SetText("")
		end
	end
end)

bg:SetScript("OnDragStart", function() bg:StartMoving() end)
bg:SetScript("OnDragStop", function() bg:StopMovingOrSizing() end)
bg:RegisterEvent("PLAYER_ENTERING_WORLD")

if not recRunes.opt.show_ooc then
	bg:RegisterEvent("PLAYER_REGEN_ENABLED")
	bg:RegisterEvent("PLAYER_REGEN_DISABLED")
	bg:Hide()
end

if not recRunes.opt.show_vehicle then
	bg:RegisterEvent("UNIT_ENTERED_VEHICLE")
	bg:RegisterEvent("UNIT_EXITED_VEHICLE")
end

bg:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_ENTERED_VEHICLE" then
		if select(1, ...) == "player" then
			bg.in_vehicle = true
			bg:Hide()
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		if select(1, ...) == "player" then
			bg.in_vehicle = false
			if recRunes.opt.show_ooc and not InCombatLockdown() then
				bg:Show()
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		if recRunes.opt.show_vehicle or (not recRunes.opt.show_vehicle and not bg.in_vehicle) then
			bg:Show()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		bg:Hide()
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- If character is not a DK, inform player and hibernate.
		local _, class = UnitClass("player")
		if class ~= "DEATHKNIGHT" then
			bg:UnregisterAllEvents()
			bg:SetScript("OnUpdate", nil)
			bg:Hide()
			print("recRunes: You are not playing as a Death Knight.  The addon will be automatically disabled at next login.")
			DisableAddOn("recRunes")
			return
		end
		-- Disable and hide the Blizzard rune frame if option is set.
		if recRunes.opt.runes.hide_blizzard_runes then
			RuneFrame.Show = function() end
			RuneFrame:UnregisterAllEvents()
			RuneFrame:Hide()
		end
	end
end)

SLASH_RECRUNES1 = "/recrunes"
SlashCmdList.RECRUNES = function()
	-- Slash command toggles dragging of frame.
	if bg:IsMouseEnabled() then
		bg:EnableMouse(false)
		-- We need to hide the frame if the user has set the option to hide out of combat.
		if ((not recRunes.opt.show_ooc) and (not InCombatLockdown())) then
			bg:Hide()
		end
		print("recRunes is now locked.")
	else
		bg:EnableMouse(true)
		-- We need to show the frame if the user has turned off the frame out of combat.
		if ((not recRunes.opt.show_ooc) and (not InCombatLockdown())) then
			bg:Show()
		end
		print("recRunes is now movable. /recrunes to lock")
	end
end