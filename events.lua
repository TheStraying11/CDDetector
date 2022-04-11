---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Zoë.
--- DateTime: 11/04/2022 18:06
---

local events

function events:ADDON_LOADED(Addon)
    if Addon == "CDDetector" then print("CDDetector loaded") end
end

function events:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, _, sourceName, _, _, _, destName, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()

    if subevent ~= "SPELL_CAST_SUCCESS" then return nil end
    if not UnitGUID(sourceName) then return nil end


    if destName ~= nil then
        CDDetector.DoLog(subevent..", "..spellName.." ("..spellID.."), "..sourceName..", "..destName, 2)
    else
        CDDetector.DoLog(subevent..", "..spellName.." ("..spellID.."), "..sourceName, 2)
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

    if CDDetector.CRSpells[spellID] then
        SendChatMessage("CD Detector: "..sourceName.." cast combat res spell "..GetSpellLink(spellID).." on "..destName, channel)
    end
    if CDDetector.HasteSpells[spellID] then
        SendChatMessage("CD Detector: "..sourceName.." cast haste spell "..GetSpellLink(spellID), channel)
    end
end

frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            local status, err = pcall(events[event], self, ...)
            if not status then
                CDDetector.DoLog(event, 1)
                CDDetector.DoLog(err, 1)
                for k, v in pairs {...} do
                    CDDetector.DoLog(k..' : '..v, 1)
                end
            end
        end
)

for k, v in pairs(events) do
    CDDetector.frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end

CDDetector.events = events;