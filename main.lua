CDDetector.frame:SetScript(
		"OnEvent",
		function(self, event, ...)
			local status, err = pcall(CDDetector.events[event], self, ...)
			if not status then
				CDDetector.utils.DoLog(event, 1)
				CDDetector.utils.DoLog(err, 1)
				for k, v in pairs {...} do
					CDDetector.utils.DoLog(k..' : '..v, 1)
				end
			end
		end
)

for k, v in pairs(CDDetector.events) do
	CDDetector.frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end

for command, func in pairs(CDDetector.commands) do
	_G["SLASH_"..command:upper().."1"] = "/"..command;
	SlashCmdList[command:upper()] = func;
end

