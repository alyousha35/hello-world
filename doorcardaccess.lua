local component = require("component")
local sides = require("sides")
local colors = require("colors")
local term = require('term')
local rs = component.redstone
local c = component.computer
local gpu = component.gpu
local door = component.os_door
local accesslevel = 1

local event = require "event" -- load event table and store the pointer to it in event
 
local char_space = string.byte(" ") -- numerical representation of the space char
local running = true -- state variable so the loop can terminate
 
function unknownEvent()
  -- do nothing if the event wasn't relevant
end
 
-- table that holds all event handlers, and in case no match can be found returns the dummy function unknownEvent
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })
 
-- Example key-handler that simply sets running to false if the user hits space
function myEventHandlers.key_up(adress, char, code, playerName)
  if (char == char_space) then
    running = false
  end
end

function openDoor()
    if not (door.isOpen()) then
        door.toggle()
    end
end

function closeDoor()
    if (door.isOpen()) then
        door.toggle()
    end
end

function accessApproved()
    gpu.setForeground(0x00FF00)
    print("ACCESS APPROVED")
    c.beep(2000,0.5)
    c.beep(2000,0.5)
    os.sleep(1)
    c.beep(1000,0.5)
    openDoor()
    os.sleep(1)
    c.beep(1000,0.5)
    os.sleep(1)
    c.beep(2000,1)
    os.sleep(1)
    closeDoor()
    term.clear()
    gpu.setForeground(0xFFFFFF)
    gpu.setResolution(32, 12)
end

function accessDenied()
    gpu.setForeground(0xFF3300)
    print("ACCESS DENIED")
    c.beep(20,1)
    gpu.setForeground(0xFFFFFF)
    term.clear()
    gpu.setResolution(32, 12)
end

function verifyCard(playername, data, UUID, locked)
    os.sleep(0.1)
    print("User: "..playername)
    os.sleep(0.1)
    print("Access Level: "..data)
    os.sleep(0.2)
    print("Card authenticated...")
    os.sleep(0.3)
    local lvl = tonumber(data)
    if lvl >= accesslevel then 
        print("User has sufficient access...")
        return true
    else
        print("User has insufficient access!")
        return false
    end
end

function handleEvent(eventname, UUID, playername, data, locked)
    gpu.setResolution(32, 12)
    term.clear()
    gpu.setForeground(0xFFFFFF)
    print("========================")
    print("=====ACCESS ATTEMPT=====")
    print("========================")
    c.beep(200,0.5)
    os.sleep(0.1)
    print("Verifying card authenticity...")
    if verifyCard(playername, data, UUID, locked) then
        accessApproved()
    else
        accessDenied()
    end
end
 
 closeDoor()
 gpu.setResolution(32, 12)
 term.clear()
 event.listen("magData", handleEvent)


