-- $Id: settings.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local _, recRunes = ...

recRunes.opt = {

	-- Color of the background (a = 0 for none).
	background_color = { r = 0, g = 0, b = 0, a = 1 },
	
	-- Show the runes and timers when you are out of combat?
	show_ooc = true,
	
	-- Show the runes and timers when you are in a vehicle?
	show_vehicle = false,
	
	runes = {
		-- Hide the Blizzard default runes?
		hide_blizzard_runes = true,
	},
	
	global_cooldown = {
		-- Show global cooldown bar?
		show = true,
	},
	
	runic_power = {
		-- Show Runic Power bar?
		show = true,
	},
	
	diseases = {
		-- Show disease timers?
		show = false,
	},
}

recRunes.gcd_reference_spell = [[Death Coil]]

if not recMedia then
	recRunes.font_face         = [[Interface\AddOns\recRunes\media\pf_tempesta_five_condensed.ttf]]
	recRunes.font_size         = 10
	recRunes.font_flags        = "OUTLINE"
	recRunes.bg_file           = [[Interface\ChatFrame\ChatFrameBackground]]
	recRunes.edge_file         = [[Interface\AddOns\recRunes\media\glowtex]]
	recRunes.statusbar_texture = [[Interface\AddOns\recRunes\media\normtexa]]
else
	recRunes.font_face         = recMedia.fontFace.TINY_PIXEL
	recRunes.font_size         = 10
	recRunes.font_flags        = recMedia.fontFlag.OUTLINE
	recRunes.bg_file           = recMedia.texture.BACKDROP
	recRunes.edge_file         = recMedia.texture.BORDER
	recRunes.statusbar_texture = recMedia.texture.STATUSBAR
end