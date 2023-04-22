


--! Assets 
local menuSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.Digimon1 -- Menu Sprites for main game
local bgs:SpriteSheet = gdt.ROM.User.SpriteSheets.bgs -- Background sprites for the game
local digimonSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1 -- digimon Sprites looking left
local digimonSpritesFlip:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1Flip -- digimon Sprites looking right
local shitsing:AudioSample = gdt.ROM.User.AudioSamples["shitsing.wav"]
local flushing:AudioSample = gdt.ROM.User.AudioSamples["flushing.wav"]
local bootsnd:AudioSample = gdt.ROM.User.AudioSamples["boot.wav"]

--! Code modules
local digiCare = require("digiCare")
local timeTools = require("timeTools")
local webTools = require("webTools")
local gfx = require("gfx")
local dt = require("debugTools")
local debugPrint = dt.debugPrint
local createTimer = timeTools.createTimer


--! Hardware
local cpu:CPU = gdt.CPU0
local vid:VideoChip = gdt.VideoChip0 -- graphics chip
local web:Wifi = gdt.Wifi0 -- wifi web conectivity
local but0 = gdt.LedButton0 -- bottom button
local but1 = gdt.LedButton1 -- mid button
local but2 = gdt.LedButton2 -- top button


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
    {name = "quest", action = function() 
      debugPrint(time, debugBool,"info","Menu position 3 selected") 
    end},
    {name = "flush", action = function() 
      debugPrint(time, debugBool,"info","Menu position 4 selected") 
      -- if sleeping = true we cant flush
      if not digimon.sleeping then
        -- if room lights are of theres also no reason to flush
        if room.lights then
          gdt.AudioChip0:Play(flushing,2)
          flush.queue = 1 
          flush.ing = 1
        end
      end
    end},
    {name = "Lights", action = function() 
      debugPrint(time, debugBool,"info","Menu position 5 selected")
      -- turn on and off room lights
      if not room.lights then
        room.lights = true 
      elseif room.lights then
        room.lights = false
      end
    end},
    {name = "Patch", action = function() 
      debugPrint(time, debugBool,"info","Menu position 6 selected") 
    end},
    {name = "Evo/info Album", action = function() 
      debugPrint(time, debugBool,"info","Menu position 7 selected") 
    end},
    {name = "Online", action = function() 
      debugPrint(time, debugBool,"info","Menu position 8 selected") 
    end},
    {name = "Alert", action = function() 
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
local poop = {
  r = 0,-- random number from 0, 10000
  value = 0, -- time until digimon shits itself
  hasHappend = false, -- if it has shat itself
  anim = 0, -- number between 1, 0
  pos = vec2(35, 35) -- shit position
}






--* this function handles the cursor position
--$ the object this function is attached to is menu and cursor
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





--* this function checks if we made a request to flush
--$ the object this function is attached to is flush, poop and it uses debugprint
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
      if poop.hasHappend then
        
      poop.hasHappend = false
      poop.value = 0
      debugPrint(time, debugBool,"info", "poop has been flushed")
      else
        debugPrint(time, debugBool,"info", "pressed flush with no shit") -- what a funny print
      end
      --$ endof poophashappend
    end
    --$ endof posX check
   end
   --$ endof flushqueue
end





--* this variable will count up to 8004 and then reset to 0 to run the time update
local webtimeC = 0


local timer = createTimer(
    gdt.CPU0,
    0.5,
    function() 
        webtimeC = timeTools.runEvery(function()
         time = webTools.getTimeFromWeb(time)
        end,
          webtimeC,
          8004 -- 2 hours and 13 minutes
        )
        time = timeTools.incrementTime(time)
        -- add 1 to the poop value
        poop.value += 1
        -- keeps track of time
        -- timeTracker()
        digimon.r = math.random(0, 1) 
        poop.anim = math.random(2, 3)
        room.r = math.random(0, 1) 
        digimon = digiCare.digimonMover(digimon)
        flushPoop()
        
    end
)


local debugTimer = createTimer( 
    gdt.CPU0,
    5,
    function()
      --todo| info about positions for debugging
      debugPrint(time, debugBool,"digimon", "Digimon", "X" .. digimon.pos.X, "Y" .. digimon.pos.Y  )
      debugPrint(time, debugBool,"debug", "Cursor", "X".. cursor.pos.X, "Y".. cursor.pos.Y, "Menu:", menu.current)
      
      
      
      
      --$ check if condition of time health is ok
      if not time.health.condition and time.health.updating then
        debugPrint(time, debugBool,"warning", "TimeNotStarted/NotUpdated YOU ARE OFFLINE")
        local countRestart = 0
        countRestart += 1
        if countRestart == 12 then
          time = webTools.getTimeFromWeb(time)
        end
      end --$ endof timeHealth check
end)

local boot = false
--! ################################################
--! ######## MAIN GAME LOOP ########################
--! ################################################
function update()

 if not boot then
  gdt.AudioChip0:Play(bootsnd,1)
  gfx.drawBoot()
  sleep(2)
  boot = true
 end
  --! important updater 
  timer.update()
  debugTimer.update()
  -- clears the screen
  vid:Clear(Color(18,14,32))
  -- draws the  background
  gfx.drawbg(room)

  
  -- increase the counter by the CPU's DeltaTime
  timeDlt.counter += gdt.CPU0.DeltaTime

  -- does colision for digimon
  digimon = digiCare.colision(digimon)
  
  -- handdler for digimon stuff
  digimon = digicare.digimonHandler(digimon)
  
  -- checks if you shat yourself
  poop = digiCare.poopCheck(digimon, poop)
  
  -- draw funny poopoo.... uhhhh
  gfx.drawPoop(poop)
  
  -- draws the little waves to flush shit
  gfx.drawflush(flush)
  
  -- draws the digimon
  gfx.drawDigimon(digimon)
  
  -- this function will draw the menu sprites
  gfx.drawMenuSprites(digimon, room)
  
  -- draws the cursor
  gfx.drawSelSprite(cursor)
 

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
    poop.value += 5000
    -- digimon.pos += vec2(4, 0)
    -- digimon.sleepTime0 += 28799
    --if not debugBool then
    --  debugBool = true 
    --elseif debugBool then
    --  debugBool = false
    --end
end
  

  
  
   
  -- Time tracker 
  local elapsed = timer.getTotalTime()
end