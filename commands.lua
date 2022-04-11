---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Zoë.
--- DateTime: 11/04/2022 17:59
---

local commands = {};

function commands.CDDToggleDebug(arg)
    local args = CDDetector.utils.split(arg)
    CDDetector.DebugLevel = tonumber(args[1])
    CDDetector.DoLog("DebugLevel: "..CDDetector.DebugLevel, CDDetector.DebugLevel)
end

for command, func in pairs(commands) do
    _G["SLASH_"..command:upper().."1"] = "/"..command;
    SlashCmdList[command:upper()] = func;
end

CDDetector.commands = commands;