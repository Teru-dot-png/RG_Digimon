
--! EventCH
gdt.CPU0.EventChannels[1] = gdt.Wifi0 -- Adding the Wifi chip as the first element of this array, so that it can trigger events for the CPU to handle.
--[[
 This line of code initializes a table named handleFuncs, which maps request handles (numbers) 
to functions that accept a WifiWebResponseEvent parameter and return nothing 
(i.e. (result: WifiWebResponseEvent) -> ()).
This table is used to store functions that should be called when a web request's
response event is received.

]]--
local handleFuncs: {[number]: (result: WifiWebResponseEvent) -> ()} = {}


--! Assets 
local menuSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.Digimon1 -- Menu Sprites for main game
local bgs:SpriteSheet = gdt.ROM.User.SpriteSheets.bgs -- Background sprites for the game
local digimonSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1 -- digimon Sprites looking left
local digimonSpritesFlip:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1Flip -- digimon Sprites looking right

--! Code modules
local dt = require("debugTools")
local debugPrint = dt.debugPrint



--! Hardware
local cpu:CPU = gdt.CPU0
local vid:VideoChip = gdt.VideoChip0 -- graphics chip
local web:Wifi = gdt.Wifi0 -- wifi web conectivity
local but0 = gdt.LedButton0 -- bottom button
local but1 = gdt.LedButton1 -- mid button
local but2 = gdt.LedButton2 -- top button

--!----------------------------------------------------------------------------
--!----   EventCH 1      ------------------------------------------------------
--!----------------------------------------------------------------------------
--[[
 This function is an event handler for the Wifi module, specifically for the WifiWebResponseEvent.
When this event is triggered, it is passed to this function along with the Wifi module that triggered it.
The function then looks up a function in the handleFuncs table using the RequestHandle from the event as the key.
This function is then called with the event as its argument. Finally, the function stored in handleFuncs
for the given RequestHandle is removed. This allows for the ability to associate a specific function with 
a specific web request, allowing for better organization and management of web requests in the code.
]]--
function eventChannel1(_: Wifi, event: WifiWebResponseEvent)
  handleFuncs[event.RequestHandle](event)
  handleFuncs[event.RequestHandle] = nil
end
--!----------------------------------------------------------------------------


--? Flag to enable debugging messages
local debugBool = true

--? keep track of room info
local room = {
lights = true, -- room lights if on then true if off then false
r = 0 -- random number  between (1, 0)
}



--? keep track of time deltas and frames
local timeDlt = {
  counter = 0, -- this will keep track of DeltaTime
 frameDuration = 1, -- how long in seconds it runs
 frameNum = 0 -- keep track of the current frame
}

--? Time data i cant give info on this its pretty self explanatory
local time = {
  seconds = 0,
  minutes = 0,
  hours = 0,
  days = 0,
  weeks = 0,
  months = 0,
  years = 0,
  counter = 0,
  health = {
  condition = false, -- a warning to see if the condition of the time is bad and unupdated
  updating = true -- if its updating or not 
}}

  --? keep track of digimon position and stats
  local digimon = {
    pos = vec2(35,24), -- possition of Digimon
    r = 0, -- Random value
    sleepTime0 = 0, -- Sleep timer
    looking = 0, -- facing (0 = left, 1 = right)
    sleeping = false -- if its sleeping or not
  }
  
  --? flush data 
  flush = {
ing = false, -- check if currently "flush-ing"
queue = 0, -- asks a queue if it can flush
posX = 55, -- possition of water
posY = 16 -- possition of water
}

--? keep track of menu
local menu = { 
  current = 0, -- current menu from (0, 9)
  maxItems = 9, -- max number of items
  isInsideMenu = false, -- check if its inside sub menu
  isUnselected = false,-- check if its unselected
  
  
  --? Define an array of menu items and their associated actions.
  -- (0:info)
  -- (1:feed)
  -- (2:train)
  -- (3:challange) 
  -- (4:flush)
  -- (5:lights)
  -- (6:patch)
  -- (7:inteligence training)
  -- (8:online)
  -- (9:wip)
  items = {
    {name = "info", action = function() 
      debugPrint(time, debugBool,"info","Menu position 0 selected") 
    end},
    {name = "feed", action = function() 
      debugPrint(time, debugBool,"info","Menu position 1 selected") 
    end},
    {name = "train", action = function() 
      debugPrint(time, debugBool,"info","Menu position 2 selected") 
    end},
    {name = "challange", action = function() 
      debugPrint(time, debugBool,"info","Menu position 3 selected") 
    end},
    {name = "flush", action = function() 
      debugPrint(time, debugBool,"info","Menu position 4 selected") 
      -- if sleeping = true we cant flush
      if digimon.sleeping == false then
        -- if room lights are of theres also no reason to flush
        if room.lights == true then
          flush.queue = 1 
          flush.ing = 1
        end
      end
    end},
    {name = "lights", action = function() 
      debugPrint(time, debugBool,"info","Menu position 5 selected")
      -- turn on and off room lights
      if room.lights == false then
        room.lights = true 
      elseif room.lights == true then
        room.lights = false
      end
    end},
    {name = "patch", action = function() 
      debugPrint(time, debugBool,"info","Menu position 6 selected") 
    end},
    {name = "Evo/info Album", action = function() 
      debugPrint(time, debugBool,"info","Menu position 7 selected") 
    end},
    {name = "Online", action = function() 
      debugPrint(time, debugBool,"info","Menu position 8 selected") 
    end},
    {name = "wip", action = function() 
      debugPrint(time, debugBool,"info","Menu position 9 selected") 
    end},
  },
  
  -- This is a method of the `menu` object. It iterates over the `items` array and
  -- executes the appropriate action based on the value of the `current` property.
  select = function(self)
    for i, item in ipairs(self.items) do
      if self.current == i - 1 then
        item.action()
      end
    end
  end
}

--? keep track of position of selector
local cursor = {
  pos = vec2(0,5), -- possition of the cursor
  posX = 0, -- X possition of the cursor
  posY = 5 -- Y possition of the cursor
}




--? as much as i dont want to we need to keep track of poop
poop = {
  r = 0,-- random number from 0, 10000
  value = 0, -- time until digimon shits itself
  hasHappend = false, -- if it has shat itself
  anim = 0, -- number between 1, 0
  pos = vec2(0, 0), -- shit position
  posX = 35,
  posY = 35
}




--* gets executed every second for the duration of a second
function deltaTimeHandler()
  while (timeDlt.counter >= timeDlt.frameDuration) do
    timeDlt.counter -= timeDlt.frameDuration
    timeDlt.frameNum += 1
   
  end
end

--* this function sends a GET request to the specified URL and stores the provided function to be called when the request completes.
local function fetch(wifi: Wifi, url: string, resultFunc: (response: WifiWebResponseEvent) -> ())
  local handle = wifi:WebGet(url)
  handleFuncs[handle] = resultFunc
end

--? Background values
local _darkRoom = 5 -- We change to dark room set of sprites
local _paddingX = 8.5 -- Padding for the X
local _paddingY = 16 -- Padding for the Y
local _spot = {
one = 15, -- The first spot of the second bg sprite
two = 15 *2, -- The second spot of the third bg sprite
three = 15 *3, -- The third spot of the fourth bg sprite
four = 15 *4 -- The fourth spot of the fifth bg sprite
}
--* This function will draw the background acordingly to the light state
function drawbg()
  --$ Checks if lights are on or off
  if room.lights then
    vid:DrawSprite(vec2(_paddingX, _paddingY), bgs ,0 ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.one , _paddingY), bgs ,1 ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.two , _paddingY), bgs ,2 ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.three , _paddingY), bgs ,3 ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.four , _paddingY), bgs ,4 ,0, color.white, color.clear)

    vid:DrawSprite(vec2(_paddingX, _paddingY + _spot.one), bgs ,0 ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.one , _paddingY + _spot.one), bgs ,1 ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.two , _paddingY + _spot.one), bgs ,2 ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.three , _paddingY + _spot.one), bgs ,3 ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.four , _paddingY + _spot.one), bgs ,4 ,1, color.white, color.clear)
  else

    vid:DrawSprite(vec2(_paddingX, _paddingY), bgs ,0 + _darkRoom ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.one , _paddingY), bgs ,1 + _darkRoom ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.two , _paddingY), bgs ,2 + _darkRoom ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.three , _paddingY), bgs ,3 + _darkRoom ,0, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.four , _paddingY), bgs ,4 + _darkRoom ,0, color.white, color.clear)

    vid:DrawSprite(vec2(_paddingX, _paddingY + _spot.one), bgs ,0 + _darkRoom ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.one , _paddingY + _spot.one), bgs ,1 + _darkRoom ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.two , _paddingY + _spot.one), bgs ,2 + _darkRoom ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.three , _paddingY + _spot.one), bgs ,3 + _darkRoom ,1, color.white, color.clear)
    vid:DrawSprite(vec2(_paddingX + _spot.four , _paddingY + _spot.one), bgs ,4 + _darkRoom ,1, color.white, color.clear)
  end --$ endof room.lights check 

end




--* this will draw menu sprites
function drawMenuSprites()

 --$ Check if the room lights are off
if room.lights == false then 
  -- Check if the digimon is sleeping
  if digimon.sleeping == true then
      -- If the digimon is sleeping, make zz appear when light off (draw zz sleeping particles in dark)
      vid:DrawSprite(digimon.pos + vec2(15, room.r), menuSprites, 6, room.r, color.white, color.clear)
  else
      -- If the digimon is not sleeping, and lights are of it will get angry (draw "#" angry symbol)
      vid:DrawSprite(digimon.pos + vec2(15, room.r), menuSprites, 7, 2, color.white, color.clear)
  end

-- If the room lights are on
else
  -- Check if the digimon is sleeping
  if digimon.sleeping == true then
      -- If the digimon is sleeping, draw (draw zz sleeping particles on a lit room)
      vid:DrawSprite(digimon.pos + vec2(15, room.r), menuSprites, 6, room.r, color.white, color.clear ) 
  end
end--$ endof room.lights check

  --! makes the menu borders $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
  vid:DrawRect(vec2(7, 15), vec2(70, 47), color.black)
  -- two lil cheeky borders on the sides so it hides the digimon 
  vid:FillRect(vec2(0, 15), vec2(6, 47), Color(0,4,25))
  vid:FillRect(vec2(71, 15), vec2(79, 47), Color(0,4,25)) 
  --! $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

  --! Draws the top menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  vid:DrawSprite(vec2(5,5), menuSprites, 0, 0, color.white, color.clear)
  vid:DrawSprite(vec2(20,5), menuSprites, 1, 0, color.white, color.clear)
  vid:DrawSprite(vec2(35,5), menuSprites, 2, 0, color.white, color.clear)
  vid:DrawSprite(vec2(50,5), menuSprites, 3, 0, color.white, color.clear)
  vid:DrawSprite(vec2(65,5), menuSprites, 4, 0, color.white, color.clear)
  --!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  --! draw the bottom menu @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  vid:DrawSprite(vec2(5,50), menuSprites, 0, 1, color.white, color.clear)
  vid:DrawSprite(vec2(20,50), menuSprites, 1, 1, color.white, color.clear)
  vid:DrawSprite(vec2(35,50), menuSprites, 2, 1, color.white, color.clear)
  vid:DrawSprite(vec2(50,50), menuSprites, 3, 1, color.white, color.clear)
  vid:DrawSprite(vec2(65,50), menuSprites, 4, 1, color.white, color.clear)
  --!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end

--* draws the cursor at the position
function drawSelSprite()
    vid:DrawSprite(cursor.pos, menuSprites, 5, 1, color.white, color.clear)
end

function CursorHandler()
    -- everytime the button is clicked
    menu.current += 1 -- menu position add 1
    cursor.pos += vec2(15,0) -- move the position to 15 units

    -- if the cursor position is over the screen we go to next
    if cursor.pos.X > 60 then
        cursor.pos = vec2(0, 50)
    end      

    -- if its over the max options we go bac
    if menu.current > menu.maxItems then
        -- reseting positions
        menu.current = 0
        cursor.pos = vec2(0,5)  
    end
end

--* this function will move the digimon once and a while
function digimonMover()
    
  if digimon.sleeping == false then
    -- random number for looking left or right
    digimon.looking = math.random()
    
    -- if its above 0.5 we move it 5 units else we go back 5 units
    if digimon.looking < 0.5 then
        
        
        digimon.pos += vec2(5, 0) 
    else
        
        digimon.pos -= vec2(5, 0)
    end
  end
    
end

--* this function will handdle the digimon stats and needs
function digimonHandler()
  -- digimon time counter
  digimon.sleepTime0 += gdt.CPU0.DeltaTime

  -- Clamp the value of sleepTime0 to a range of 0 to 28800 (8 hours)
  digimon.sleepTime0 = math.clamp(digimon.sleepTime0, 0, 28800)

  --$ Check if the digimon is currently sleeping
  if digimon.sleeping then
    -- If the digimon has been sleeping for at least 2 hours, set sleeping to false
    if digimon.sleepTime0 >= 7200 then
      digimon.sleepTime0 -= 7200
      digimon.sleeping = false
    end
  else
    -- If the digimon has been awake for at least 8 hours, set sleeping to true
    if digimon.sleepTime0 >= 28800 then
      digimon.sleepTime0 -= 28800
      digimon.sleeping = true
    end --$ endof if digimon been awake for 8 hours
  end --$ endof digimon.sleeping check

end



--* this is like a vibe check but to see if you shat yourself
function poopCheck()


  if digimon.sleeping == false then
    poop.r = math.random( 0, 10000 )

    --$ check if conditon  poop value is 10800, check if condition poop.r is 21  
    if poop.r == 21 or poop.value >= 10800 then
    poop.hasHappend = true
    poop.value = 0
    end -- $ endof if poop condition
  end -- $ endof sleep Check
end 

--* this function will draw poop if digimon has done the peepee poopoo caacaa
function drawPoop()
    if poop.hasHappend then
    vid:DrawSprite(poop.pos, menuSprites, 6, poop.anim, color.white, color.clear)
    end
end

function flushPoop()
  --* check if we made a flush request
  if flush.queue > 0.5 then
   
    -- move the water left
      flush.posX += -10
    

    --$ if flush moved out of screen we set all values to default
    if flush.posX < 2 then
    flush.queue = 0
    flush.posX = 55
    flush.ing = false
      if poop.hasHappend == true then
      poop.hasHappend = false
      poop.value = 0
      end
      --$ endof poophashappend
    end
    --$ endof posX check
   end
   --$ endof flushqueue
end

--* draws the thing that flushes the shiz
function drawflush()

  if flush.queue > 0.5 then
  vid:DrawSprite(vec2(flush.posX, flush.posY), menuSprites, 4, 3, color.white, color.clear)
  vid:DrawSprite(vec2(flush.posX, flush.posY + 16), menuSprites, 4, 3, color.white, color.clear)
  end

end



--* this function will handdle the digimon sprites
function drawDigimon()

  if digimon.sleeping == false then
    -- if its looking left or right we use diferent sprites 
    if digimon.looking < 0.5 then 
        vid:DrawSprite(digimon.pos, digimonSpritesFlip, 0, 0 + digimon.r, color.white, color.clear)
    else
        vid:DrawSprite(digimon.pos, digimonSprites, 0, 0 + digimon.r, color.white, color.clear)
    end
  else
    if digimon.looking < 0.5 then 
    vid:DrawSprite(digimon.pos, digimonSprites, 0, 3, color.white, color.clear)
    else
    vid:DrawSprite(digimon.pos, digimonSpritesFlip, 0, 3, color.white, color.clear)
    end
  end
end

--  we do some colision checking in the rectangle
-- Check of digimon is inside box
function digimonColision()
   -- we check if we moved out of bounds and reset it to wall values
   if digimon.pos.X < 0 then
        digimon.pos = vec2(3, 24)
    end
    if digimon.pos.X > 71 then
       digimon.pos = vec2(60, 24)
    end
end





function incrementTime()
  time.seconds = time.seconds + 1

  if time.seconds >= 60 then
    time.seconds = 0
    time.minutes = time.minutes + 1
  end

  if time.minutes >= 60 then
    time.minutes = 0
    time.hours = time.hours + 1
  end

  if time.hours >= 24 then
    time.hours = 0
    time.days = time.days + 1
  end

  if time.days >= 7 then
    time.days = 0
    time.weeks = time.weeks + 1
  end

  if time.weeks >= 4 then
    time.weeks = 0
    time.months = time.months + 1
  end

  if time.months >= 12 then
    time.months = 0
    time.years = time.years + 1
  end
end




local function createTimer(cpu: CPU, interval: number, func: (totalTime: number) -> ())
  local startTime = cpu.Time
  local lastInterval = startTime

  return {
      update = function()
          if(cpu.Time - lastInterval) >= interval then 
              lastInterval = cpu.Time
              func(cpu.Time - startTime)
          end
      end,
      getTotalTime = function()
          return cpu.Time - startTime
      end,
  }
end


function spreadTimestamp(timestamp)
  -- Calculate the number of seconds, minutes, hours, days, weeks, months, and years
  -- from the timestamp
  time.seconds = timestamp % 60
  time.minutes = math.floor(timestamp / 60) % 60
  time.hours = math.floor(timestamp / 3600) % 24
  time.days = math.floor(timestamp / 86400) % 7
  time.weeks = math.floor(timestamp / 604800) % 4
  time.months = math.floor(timestamp / 2629743) % 12
  time.years = math.floor(timestamp / 31556926)
end


local function getTimeFromWeb()
  debugPrint(time, debugBool,"info", "TIME IS UPDATING...")
  time.health.updating = true
  -- Retrieve the current Unix timestamp from the custom API
  -- Get IP  to trow at custom api 
  fetch(web, "https://api64.ipify.org/", function(response)
    -- print ip response to see if we got the right thing
    local ip = response.Text
    debugPrint(time, debugBool,"info", "GOT IP", ip )
    if tonumber(ip:sub(1, 1)) then
      time.health.condition = true
      
      fetch(web, "http://srchforamie.com:5000/time/" .. ip, function(response)
        local time_string = response.Text
        debugPrint(time, debugBool,"info","GOT UNIX" ,time_string)
        if tonumber(time_string:sub(1, #time_string - 2)) then
          debugPrint(time, debugBool,"info", "TIME HAS BEEN UPDATED")
          spreadTimestamp(time_string:sub(1, #time_string - 2))
        else
          time.health.condition = false
          -- There was an error with the request
          debugPrint(time, debugBool,"error", "WEB", response.Status, response.Text)
        end
        
      end)
    else
      debugPrint(time, debugBool,"error", "GOT", response.Text)

    end
  end)
  
end





local webtimeC = 0


function runEvery(func, counting, ends)
  if counting == 0 then
    -- do something here
    func()
  end
  counting = counting + 1
  if counting == ends then
    counting = 0
  end
  return counting
end

local timer = createTimer(
    gdt.CPU0,
    0.5,
    function() 
        webtimeC = runEvery(function()
          getTimeFromWeb()
        end,
          webtimeC,
          5000 -- 82 minutes
        )
        incrementTime()
        -- add 1 to the poop value
        poop.value += 1
        -- keeps track of time
        -- timeTracker()
        digimon.r = math.random(0, 1) 
        poop.anim = math.random(2, 3)
        room.r = math.random(0, 1) 
        digimonMover()
        flushPoop()
        
    end
)


local debugTimer = createTimer( 
    gdt.CPU0,
    5,
    function()
      --todo| info about positions for debugging
      debugPrint(time, debugBool,"debug", "Digimon", "X" .. digimon.pos.X, "Y" .. digimon.pos.Y  )
      debugPrint(time, debugBool,"debug", "Cursor", "X".. cursor.pos.X, "Y".. cursor.pos.Y, "Menu:", menu.current)
      
      
      
      
      --$ check if condition of time health is ok
      if not time.health.condition and time.health.updating then
        debugPrint(time, debugBool,"warning", "TimeNotStarted/NotUpdated YOU ARE OFFLINE")
        -- Output: "[HH:MM:SS] WARNING: TimeNotStarted/NotUpdated YOU ARE OFFLINE"
      end--$ endof timeHealth check
    end)


--! ################################################
--! ######## MAIN GAME LOOP ########################
--! ################################################
function update()
  
  --! important updater 
  timer.update()
  debugTimer.update()
  -- clears the screen
  vid:Clear(Color(18,14,32))
  -- draws the  background
  drawbg()

  
  -- increase the counter by the CPU's DeltaTime
  timeDlt.counter += gdt.CPU0.DeltaTime

  -- does colision for digimon
  digimonColision()
  
  -- handdler for digimon stuff
  digimonHandler()
  
  -- checks if you shat yourself
  poopCheck()
  
  -- draw funny poopoo
  drawPoop()
  
  -- draws the little waves to flush shit
  drawflush()
  
  -- draws the digimon
  drawDigimon()
  
  
  -- this function will draw the menu sprites
  drawMenuSprites()
  
  -- draws the cursor
  drawSelSprite()
 

  if but2.ButtonDown then
    if flush.ing == false and room.lights == true then
    -- every time we exec this cursor moves to apropiate place
    -- cycle tru menu
    CursorHandler()
  end
  end
  
  if but1.ButtonDown then
    -- selects the item you where hovered over
    menu:select()
  end
  
if but0.ButtonDown then
    -- debug shityourself button
    -- poop.value += 4
    -- digimon.pos += vec2(4, 0)
     digimon.sleepTime0 += 28799
    --if debugBool == false then
    --  debugBool = true 
    --elseif debugBool == true then
    --  debugBool = false
    --end
end
  

  
  
   
  -- Time tracker 
  local elapsed = timer.getTotalTime()
  deltaTimeHandler()
end