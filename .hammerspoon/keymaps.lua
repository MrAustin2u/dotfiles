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

hs.hotkey.bind({ "command" }, ".", open_app("kitty", "/Applications/Kitty.app"))
hs.hotkey.bind({ "command" }, "/", open_app("WezTerm", "/Applications/WezTerm.app"))
-- Ctrl + 1,2,3 is used to switch to different desktops
hs.hotkey.bind({ "control" }, "4", open_app("Arc", "/Applications/Arc.app"))
hs.hotkey.bind({ "control" }, "5", open_app("Dash", "/Applications/Dash.app"))
hs.hotkey.bind({ "control" }, "6", open_app("Slack", "/Applications/Slack.app"))
hs.hotkey.bind({ "control" }, "6", open_app("Slack", "/Applications/DataGrip.app"))
