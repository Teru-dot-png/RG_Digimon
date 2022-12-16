-- Assets
local menuSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.Digimon1
local digimonSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1
local digimonSpritesFlip:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1Flip

-- Hardware
local vid:VideoChip = gdt.VideoChip0
local web:Wifi = gdt.Wifi0
local but0 = gdt.LedButton0
local but1 = gdt.LedButton1
local but2 = gdt.LedButton2

-- keep track of room info
local room = {
lights = true,
r = 0
}

-- advance one frame
-- this will keep track of DeltaTime
-- keep track of the current frame
local timeDlt = {
 counter = 0,
 frameDuration = 1,
 frameNum = 0
}

-- Time data
local time = {
   seconds = 0,
   minutes = 0,
   hours = 0,
   days = 0,
   weeks = 0,
   months = 0,
   years = 0
  
}


-- flush data 
flush = {
ing = false,
queue = 0,
posX = 55,
posY = 16
}

-- keep track of menu
local menu = { 
  current = 0,
  maxItems = 9,
  isInsideMenu = false,
  isUnselected = false,

  nextButton = function(self)
    if self.current < self.maxItems then
      self.current += 1
    elseif self.current > self.maxItems then
    self.current = 0
    end
  end,

  -- Define an array of menu items and their associated actions.
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
      if room.lights == true then
      flush.queue = 1 
      flush.ing = 1
      end
    end},
    {name = "lights", action = function() 
      print("Menu position 5 selected")
      if room.lights == false then
      room.lights = true 
      elseif room.lights == true then
      room.lights = false
      end
    end},
    {name = "patch", action = function() 
      print("Menu position 6 selected") 
    end},
    {name = "int train", action = function() 
      print("Menu position 7 selected") 
    end},
    {name = "0nline", action = function() 
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
  pos = vec2(0,5),
  posX = 0,
  posY = 5
}

-- keep track of digimon position and stats
local digimon = {
   pos = vec2(0,0),
   posX = 35,
   posY = 25,
   sleepTime0 = 0,
   looking = 0,
   sleeping = false
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

function deltaTimeHandler()
  while (timeDlt.counter >= timeDlt.frameDuration) do
    timeDlt.counter -= timeDlt.frameDuration
    timeDlt.frameNum += 1
    poop.value += 1
    timeTracker()
    poop.anim = math.random(2, 3)
    room.r = math.random(0, 1)

    

    digimonMover()
    flushPoop()
  end
end

-- this will draw menu sprites
function drawMenuSprites()

  if flush.ing == false then
   if room.lights == false then
     vid:FillRect(vec2(5, 15), vec2(72, 48), color.black)

    if digimon.sleeping == true then
     vid:DrawSprite(vec2(digimon.posX + room.r ,digimon.posY + room.r), menuSprites, 7, room.r, color.white, color.white)
  
    elseif digimon.sleeping == false then
    vid:DrawSprite(vec2(digimon.posX + room.r ,digimon.posY + room.r), menuSprites, 7, 2, color.white, color.white)
    end
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
    end
  end
end



--this is like a vibe check but to see if you shat yourself
function poopCheck()



    poop.r = math.random( 1, 13150 )

  
    if poop.r == 500 or poop.value >= 10800 then
    poop.hasHappend = true
    poop.value = 0
    end
end

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
    end
  end
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
        vid:DrawSprite(digimon.pos, digimonSpritesFlip, 0, 1, color.white, color.clear)
    else
        vid:DrawSprite(digimon.pos, digimonSprites, 0, 1, color.white, color.clear)
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
    "room " .. "l" .. tostring(room.lights) .. " " .. "F" .. tostring(flush.ing) .. "\n",
    "DigimonInfo " .. digimon.sleepTime0 .. " " .. tostring(digimon.sleeping) .. "\n",
  
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