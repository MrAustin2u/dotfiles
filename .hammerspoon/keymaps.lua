local function open_app(appName, appPath)
  return function()
    local app = hs.application.get(appName)
    if app ~= nil and app:isFrontmost() then
      app:hide()
    else
      hs.application.launchOrFocus(appPath)
    end
  end
end

hs.hotkey.bind({ "command" }, ".", open_app("Ghostty", "/Applications/Ghostty.app"))
-- Ctrl + 1,2,3 is used to switch to different desktops
hs.hotkey.bind({ "command" }, "4", open_app("Arc", "/Applications/Arc.app"))
hs.hotkey.bind({ "command" }, "5", open_app("Firefox", "/Applications/Firefox.app"))
hs.hotkey.bind({ "command" }, "6", open_app("Dash", "/Applications/Dash.app"))
hs.hotkey.bind({ "command" }, "7", open_app("Slack", "/Applications/Slack.app"))
hs.hotkey.bind({ "command" }, "8", open_app("DataGrip", "/Applications/DataGrip.app"))
hs.hotkey.bind({ "command" }, "0", open_app("Obsidian", "/Applications/Obsidian.app"))
