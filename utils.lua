---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Zoë.
--- DateTime: 11/04/2022 17:56
---

local utils = {};

function utils.split(inputstr, sep)
    sep = sep or '%s'
    local t = {};
    for field, s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
        table.insert(t, field);
        if s == "" then
            return t;
        end
    end
end

function utils.DoLog(message, level)
    if level > CDDetector.DebugLevel then
        JoinChannelByName("CDDetector", "AddonDev");
        SendChatMessage(message, "CHANNEL", nil, GetChannelName("CDDetector"));
    end
end

CDDetector.utils = utils;