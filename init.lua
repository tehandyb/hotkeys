-- we have to watch for flag changes *and* keyDown/Up since a command key (e.g. Cmd-C) is
-- it's own event
-- hs.hotkey.bind({"cmd"}, "W", function()
--     hs.alert.show("Hello World!")
--   end)
e = hs.eventtap.new({
    hs.eventtap.event.types.flagsChanged,
    hs.eventtap.event.types.keyDown}, function(ev) 
    -- synthesized events set 0x20000000 and we may or may not get the nonCoalesced bit,
    -- so filter them out
    local rawFlags = ev:getRawEventData().CGEventData.flags & 0xdffffeff
    local regularFlags = ev:getFlags()

    -- uncomment this out when troubleshooting -- apparently different modifiers use
    -- different flags indicating left vs right: e.g.
--     {
--       cmd = true
--     }    1048584
--     {}   0
--     {
--       cmd = true
--     }    1048592        // right
--     {}   0
--
--     {
--       shift = true
--     }    131076         // right
--     {}   0
--     {
--       shift = true
--     }    131074
--     {}   0
--
-- etc.adsf23wq
    -- print(inspect(regularFlags), rawFlags)
    local evType = ev:getType()
    local keyCode = ev:getKeyCode()
    -- hs.alert.show(keyCode)

    -- hs.alert.show(rawFlags)
    if rawFlags == 131076 then
        -- hs.alert.show(evType)
        if evType == 10 then
            -- hs.alert.show(keyCode)
         -- this is key down, key up is 11a
            if keyCode == 0 then
                -- hs.alert.show("a")
                -- using eventtap.keyStroke is less responsive
                -- likely its causing more events to be processed or it might be retriggering this logic somehow
                -- hs.eventtap.keyStroke(nil, "left") 
                hs.eventtap.event.newKeyEvent(nil, "left", true):post()
                return true, {} -- eat the event
            end
            if keyCode == 1 then
                -- hs.alert.show("s")
                hs.eventtap.event.newKeyEvent(nil, "down", true):post()
                return true, {} -- eat the event
            end
            if keyCode == 2 then
                -- hs.alert.show("d")
                hs.eventtap.event.newKeyEvent(nil, "right", true):post()
                return true, {} -- eat the event
            end
            if keyCode == 13 then
                -- hs.alert.show("w")
                hs.eventtap.event.newKeyEvent(nil, "up", true):post()
                return true, {} -- eat the event
            end
            if keyCode == 49 then
                -- hs.alert.show("play")
                hs.eventtap.event.newSystemKeyEvent('PLAY', true):post()
                return true, {} -- eat the event
            end
            if keyCode == 53 then
                -- hs.alert.show("esc key")
                hs.eventtap.event.newKeyEvent("shift", 50, true):post()
                return true, {} -- eat the event
            end
        end
        

        -- do what the right cmd key is supposed to do
        -- may want to check ev:getType() to see if this was just the modifier (flagsChanged)
        -- or a command key sequence (keyDown/keyUp)
        -- print("righty!", ev:getType())
        -- hs.alert.show("got it")
        return true, {} -- eat the event
        -- if you want to replace it with a different modifier, you'd do something like:
        -- local newEvent = hs.eventtap.event.newEvent(....)....
        -- return true, { newEvent }
    end
end):start()

