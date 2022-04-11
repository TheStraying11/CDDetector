local DebugLevel = 0

local hasteSpells = {
	[2825] = true, -- Bloodlust
	[32182] = true, -- Heroism
	[80353] = true, -- Time Warp
	[264667] = true, -- Primal Rage, Direct
	[272678] = true, -- Primal Rage, Command Pet
	[146613] = true, -- Drums of Rage
	[178207] = true, -- Drums of Fury
	[230935] = true, -- Drums of the Mountain
	[256740] = true, -- Drums of the Maelstrom
	[309658] = true, -- Drums of Deathly Ferocity
	[293076] = true -- Mallet of Thunderous Skins
}

local CRSpells = {
	[20484] = true, -- Rebirth
	[61999] = true, -- Raise Ally
	[267922] = true, -- Eternal Guardian
	[159931] = true, -- Gift of Chi-Ji
	[159956] = true, -- Dust of Life
	[20707] = true -- Soulstone
}

local HostileSpells = {
	[240446] = true
}

local function split(inputstr, sep) 
	sep=sep or '%s' 
	local t={}  
	for field, s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do 
		table.insert(t,field)  
		if s == "" then 
			return t 
		end 
	end 
end


local function DoLog(message, level)
	if level > DebugLevel then
		JoinChannelByName("CDDetector", "AddonDev")
		SendChatMessage(message, "CHANNEL", nil, GetChannelName("CDDetector"))
	end
end

local commands = {}

function commands:toggleDebug(...)
	local args = {...}
	DebugLevel = tonumber(args[1])
	DoLog("DebugLevel: "..DebugLevel, DebugLevel)
end

local function CDD(arg)
	local args = split(arg, " ")
	if commands[args[1]] then
		local status, err = pcall(commands[args[1]], unpack(args))
 		if not status then
			print(err)
			print(unpack(args))
		end
	else
		print("command "..args[1].." not found")
	end
end

SLASH_CDD1 = "/cdd"
SlashCmdList["CDD"] = CDD

local frame, events = CreateFrame("Frame", "CDDetectorFrame"), {}

function events:ADDON_LOADED(Addon)
	if Addon == "CDDetector" then print("CDDetector loaded") end
end

function events:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, _, sourceName, _, _, _, destName, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	
	if subevent ~= "SPELL_CAST_SUCCESS" then return nil end
	if not UnitGUID(sourceName) then return nil end
	

	if destName ~= nil then 
		DoLog(subevent..", "..spellName.." ("..spellID.."), "..sourceName..", "..destName, 2)
	else
		DoLog(subevent..", "..spellName.." ("..spellID.."), "..sourceName, 2)
	end

	local channel = "YELL"
	if IsInGroup() then channel = "PARTY" end
	if IsInRaid() then channel = "RAID" end
	if UnitIsUnit(sourceName, "pet") then
		sourceName = UnitName("player") -- replace pet name with player name
	end
	if IsInGroup() then
		for i = 1, GetNumGroupMembers() do
			if UnitIsUnit(("%spet%i"):format(channel:lower(), i), sourceName) then
				sourceName = ("%s"):format(UnitName(("%s%i"):format(channel:lower(), i))) -- replace pet name with player name
				break
			end
		end
	end

	if CRSpells[spellID] then
		SendChatMessage("CD Detector: "..sourceName.." cast combat res spell "..GetSpellLink(spellID).." on "..destName, channel)
	end 
	if hasteSpells[spellID] then
		SendChatMessage("CD Detector: "..sourceName.." cast haste spell "..GetSpellLink(spellID), channel)
	end
	if HostileSpells[spellID] then
		SendChatMessage("CD Detector: Enemy "..sourceName.." cast hostile spell "..GetSpellLink(spellId), channel)
	end
end

frame:SetScript(
	"OnEvent", 
	function(self, event, ...)
		local status, err = pcall(events[event], self, ...)
 		if not status then
 			DoLog(event, 1)
 			DoLog(err, 1)
 			for k, v in pairs {...} do
 				DoLog(k..' : '..v, 1)
 			end
 		end
	end
)

for k, v in pairs(events) do
	frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end