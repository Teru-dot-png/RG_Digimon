local json = require("JSON")

-- Assets 
local menuSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.Digimon1 -- menu Sprites for main game
local digimonSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1 -- digimon Sprites looking left
local digimonSpritesFlip:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1Flip -- digimon Sprites looking right

-- Hardware
local vid:VideoChip = gdt.VideoChip0 -- graphics chip
local web:Wifi = gdt.Wifi0 -- wifi web conectivity
local but0 = gdt.LedButton0 -- bottom button
local but1 = gdt.LedButton1 -- mid button
local but2 = gdt.LedButton2 -- top button

-- keep track of room info
local room = {
lights = true, -- room lights if on then true if off then false
r = 0 -- random number  between (1, 0)
}


-- keep track of time deltas and frames
local timeDlt = {
 counter = 0, -- this will keep track of DeltaTime
 frameDuration = 1, -- how long in seconds it runs
 frameNum = 0 -- keep track of the current frame
}

-- Time data i cant give info on this its pretty self explanatory
local time = {
   seconds = 0,
   minutes = 0,
   hours = 0,
   days = 0,
   weeks = 0,
   months = 0,
   years = 0
  
  }
  
  -- keep track of digimon position and stats
  local digimon = {
     pos = vec2(0,0), -- possition of Digimon
     posX = 35,  -- X possition of Digimon
     posY = 25,  -- Y possition of Digimon
     r = 0, -- Random value
     sleepTime0 = 0, -- Sleep timer
     looking = 0, -- facing (0 = left, 1 = right)
     sleeping = false
  }
  
-- flush data 
flush = {
ing = false, -- check if currently "flush-ing"
queue = 0, -- asks a queue if it can flush
posX = 55, -- possition of water
posY = 16 -- possition of water
}

-- keep track of menu
local menu = { 
  current = 0, -- current menu from (0, 9)
  maxItems = 9, -- max number of items
  isInsideMenu = false, -- check if its inside sub menu
  isUnselected = false,-- check if its unselected


  -- Define an array of menu items and their associated actions.
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
      print("Menu position 0 selected") 
    end},
    {name = "feed", action = function() 
      print("Menu position 1 selected") 
    end},
    {name = "train", action = function() 
      print("Menu position 2 selected") 
    end},
    {name = "challange", action = function() 
      print("Menu position 3 selected") 
    end},
    {name = "flush", action = function() 
      print("Menu position 4 selected") 
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
      print("Menu position 5 selected")
      -- turn on and off room lights
      if room.lights == false then
      room.lights = true 
      elseif room.lights == true then
      room.lights = false
      end
    end},
    {name = "patch", action = function() 
      print("Menu position 6 selected") 
    end},
    {name = "Evo/info Album", action = function() 
      print("Menu position 7 selected") 
    end},
    {name = "Online", action = function() 
      print("Menu position 8 selected") 
    end},
    {name = "wip", action = function() 
      print("Menu position 9 selected") 
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

-- keep track of position of selector
local cursor = {
  pos = vec2(0,5), -- possition of the cursor
  posX = 0, -- X possition of the cursor
  posY = 5 -- Y possition of the cursor
}


-- as much as i dont want to we need to keep track of poop
 poop = {
 r = 0,
 value = 0,
 hasHappend = false,
 anim = 0,
 pos = vec2(0, 0),
 posX = 35,
 posY = 35
}

function timeTracker()
  -- seconds
  time.seconds += 1
  if time.seconds == 60 then
    time.seconds = 0
    -- minutes
    time.minutes += 1
    if time.minutes == 60 then
      time.minutes = 0
      -- hours
      time.hours += 1
      if time.hours == 24 then
        time.hours = 0
        -- days
        time.days += 1
        if time.days == 7 then
          time.days = 0
          -- weeks
          time.weeks += 1
          if time.weeks == 4 then
            time.weeks = 0
            -- month
            time.months += 1
            if time.months == 12 then
              months = 0
              -- years
              time.years += 1
            end
          end
        end
      end
    end
  end
end


-- gets executed every second for the duration of a second
function deltaTimeHandler()
  while (timeDlt.counter >= timeDlt.frameDuration) do
    timeDlt.counter -= timeDlt.frameDuration
    timeDlt.frameNum += 1
    -- add 1 to the poop value
    poop.value += 1
    -- keeps track of time
    timeTracker()
    digimon.r = math.random(0, 1) 
    poop.anim = math.random(2, 3)
    room.r = math.random(0, 1) 
    digimonMover()
    flushPoop()
  end
end


function timer(interval, func, stop_condition, api_key)
  local start_time_url = "https://api.timezonedb.com/v2.1/get-time-zone?key=%s&format=json&by=zone&zone=UTC"
  local start_time = web:WebGet(string.format(start_time_url, api_key))
  start_time = json.decode(start_time).timestamp
  local elapsed_time = 0
  while true do
    if stop_condition() then
      break
    end
    local current_time_url = "https://api.timezonedb.com/v2.1/get-time-zone?key=%s&format=json&by=zone&zone=UTC"
    local current_time = web:WebGet(string.format(current_time_url, api_key))
    current_time = json.decode(current_time).timestamp
    elapsed_time = current_time - start_time
    if elapsed_time >= interval then
      start_time = current_time
      func()
    end
  end
end




-- this will draw menu sprites
function drawMenuSprites()



  

 -- Check if the room lights are off
if room.lights == false then
  -- If the room lights are off, fill the screen with black 
  vid:FillRect(vec2(5, 15), vec2(72, 48), color.black)
  -- Check if the digimon is sleeping
  if digimon.sleeping == true then
      -- If the digimon is sleeping, make zz appear when light off (draw zz sleeping particles in dark)
      vid:DrawSprite(vec2(digimon.posX + 15 ,digimon.posY + room.r), menuSprites, 7, room.r, color.white, color.white)
  else
      -- If the digimon is not sleeping, and lights are of it will get angry (draw "#" angry symbol)
      vid:DrawSprite(vec2(digimon.posX + 15 ,digimon.posY + room.r), menuSprites, 7, 2, color.white, color.white)
  end

-- If the room lights are on
else
  -- Check if the digimon is sleeping
  if digimon.sleeping == true then
      -- If the digimon is sleeping, draw (draw zz sleeping particles on a lit room)
      vid:DrawSprite(vec2(digimon.posX + 15 ,digimon.posY + room.r), menuSprites, 6, room.r, color.white, color.clear ) 
  end
end



  


  -- makes the menu borders
  vid:DrawRect(vec2(5, 15), vec2(72, 48), color.black)
  vid:FillRect(vec2(0, 15), vec2(4, 48), color.white)
  vid:FillRect(vec2(73, 15), vec2(79, 48), color.white)


    
  -- Draws the top menu
  vid:DrawSprite(vec2(5,5), menuSprites, 0, 0, color.white, color.clear)
  vid:DrawSprite(vec2(20,5), menuSprites, 1, 0, color.white, color.clear)
  vid:DrawSprite(vec2(35,5), menuSprites, 2, 0, color.white, color.clear)
  vid:DrawSprite(vec2(50,5), menuSprites, 3, 0, color.white, color.clear)
  vid:DrawSprite(vec2(65,5), menuSprites, 4, 0, color.white, color.clear)

  -- draw the bottom menu
  vid:DrawSprite(vec2(5,50), menuSprites, 0, 1, color.white, color.clear)
  vid:DrawSprite(vec2(20,50), menuSprites, 1, 1, color.white, color.clear)
  vid:DrawSprite(vec2(35,50), menuSprites, 2, 1, color.white, color.clear)
  vid:DrawSprite(vec2(50,50), menuSprites, 3, 1, color.white, color.clear)
  vid:DrawSprite(vec2(65,50), menuSprites, 4, 1, color.white, color.clear)
end

-- draws the cursor
function drawSelSprite()
    vid:DrawSprite(cursor.pos, menuSprites, 5, 1, color.white, color.clear)
end

function CursorHandler()
    -- everytime the button is clicked
    menu.current += 1 -- menu position add 1
    cursor.posX += 15 -- move the position to 15 units

    -- if the cursor position is over the screen we go to next
    if cursor.posX > 60 then
        cursor.posY = 50
        cursor.posX = 0
    end      

    -- if its over the max options we go bac
    if menu.current > menu.maxItems then
        -- reseting positions
        menu.current = 0
        cursor.posX = 0
        cursor.posY = 5  
    end
end

-- this function will move the digimon once and a while
function digimonMover()
    
  if digimon.sleeping == false then
    -- random number for looking left or right
    digimon.looking = math.random()
    
    -- if its above 0.5 we move it 5 units else we go back 5 units
    if digimon.looking < 0.5 then
        
        
        digimon.posX += 5 
    else
        
        digimon.posX -= 5
    end
  end
    
end

-- this function will handdle the digimon stats and needs
function digimonHandler()
  -- digimon time counter
  digimon.sleepTime0 += gdt.CPU0.DeltaTime

  -- Clamp the value of sleepTime0 to a range of 0 to 28800 (8 hours)
  digimon.sleepTime0 = math.clamp(digimon.sleepTime0, 0, 28800)

  -- Check if the digimon is currently sleeping
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
    end -- #endof if digimon been awake for 8 hours
  end -- #endof 
end



--this is like a vibe check but to see if you shat yourself
function poopCheck()


    if digimon.sleeping == false then
    poop.r = math.random( 0, 10000 )

  
    if poop.r == 1 or poop.value >= 10800 then
    poop.hasHappend = true
    poop.value = 0
    end -- #endof if
  end -- #endof sleep Check
end -- #endof poopCheck()

-- this function will draw poop if digimon has done the peepee poopoo caacaa
function drawPoop()
    if poop.hasHappend == true then
    vid:DrawSprite(poop.pos, menuSprites, 6, poop.anim, color.white, color.clear)
    end
end

function flushPoop()
  -- check if we made a flush request
  if flush.queue > 0.5 then
   
    -- move the water left
      flush.posX += -10
    

    -- if flush moved out of screen we set all values to default
    if flush.posX < 2 then
    flush.queue = 0
    flush.posX = 55
    flush.ing = false
      if poop.hasHappend == true then
      poop.hasHappend = false
      poop.value = 0
      end
      -- endof poophashappend
    end
    --endof posX check
   end
   -- endof flushqueue
end

-- draws the thing that flushes the shiz
function drawflush()

  if flush.queue > 0.5 then
  vid:DrawSprite(vec2(flush.posX, flush.posY), menuSprites, 4, 3, color.white, color.clear)
  vid:DrawSprite(vec2(flush.posX, flush.posY + 16), menuSprites, 4, 3, color.white, color.clear)
  end

end

-- this function will handdle the digimon sprites
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
function digimonColision()
   -- we check if we moved out of bounds and reset it to wall values
   if digimon.posX < 0 then
        digimon.posX = 2
    end
    if digimon.posX > 71 then
       digimon.posX = 59
    end
end

-- prints the debug info
function debugPrint()
    
  print(
    "  MenuItem: " .. menu.current .. "\n",
    "room: " .. " L" .. tostring(room.lights) .. " " .. "F" .. tostring(flush.ing) .. "\n",
    "DigimonInfo " .. math.floor(digimon.sleepTime0)  .. " " .. tostring(digimon.sleeping) .. "\n",
  
  --"Flush X Y Pos: " .. flush.posX .. " " .. flush.posY .. "\n",
  --"ShitData:" .. poop.value .. " " .. flush.queue .. "\n",
  --"dlt-T: " .. timeDlt.counter .. "\n",
  --"CPU-D: " .. gdt.CPU0.DeltaTime .. "\n",
  "S" .. time.seconds .. " M" .. time.minutes .. " H" .. time.hours
  )
end



-- ################################
-- ######## MAIN GAME LOOP ########
-- ################################
function update()
  debugPrint()
  




  -- clears the screen
  vid:Clear(color.white)
  
  -- set according possitions
  cursor.pos = vec2(cursor.posX,cursor.posY)
  digimon.pos = vec2(digimon.posX, digimon.posY)
  poop.pos = vec2(poop.posX, poop.posY)
  
  
  -- increase the counter by the CPU's DeltaTime
  timeDlt.counter += gdt.CPU0.DeltaTime

  -- draws the cursor
  drawSelSprite()
  
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
    -- digimon.posX += 4
    digimon.sleepTime0 += 28799
  end
  
  
  
  
  -- time tracker 
  deltaTimeHandler()
end