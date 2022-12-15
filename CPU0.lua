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
local flushing = false
local flushCount = 0
local poopFlushQueue = 0
local flushPosX = 55
local flushPosY = 16

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
      poopFlushQueue = 1 
    end},
    {name = "lights", action = function() 
      print("Menu position 5 selected") 
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
local DigimonPos:vec2 = vec2(0,0)
local digimon = {
   posX = 35,
   posY = 25,
   looking = 0,
   sleeping = false
}

-- keep track of room info
local lights = false

-- as much as i dont want to we need to keep track of poop
local poopR = 0
local poopValue = 0
local poop = false
local poopAnim = 0
local poopPos = vec2(0, 0)
local PoopPosX = 35
local PoopPosY = 35


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
    poopValue += 1
    timeTracker()
    poopAnim = math.random(2, 3)
    digimonMover()
    flushPoop()
  end
end

-- this will draw menu sprites
function drawMenuSprites()

  -- makes the menu borders
  vid.DrawRect(vid, vec2(5, 15), vec2(72, 48), color.black)


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
    
    -- random number for looking left or right
    digimon.looking = math.random()
    
    -- if its above 0.5 we move it 5 units else we go back 5 units
    if digimon.looking < 0.5 then
        
        
        digimon.posX += 5 
    else
        
        digimon.posX -= 5
    end
    
    
end

-- this function will handdle the digimon stats and needs
function digimonHandler()
    

end


--this is like a vibe check but to see if you shat yourself
function poopCheck()



    poopR = math.random( 1, 3150 )

    
  

    if poopR == 500 or poopR == 200 or poopR == 1000 or poopValue >= 10800 then
    poop = true
    poopValue = 0
    end
end

-- this function will draw poop if digimon has done the peepee poopoo caacaa
function drawPoop()
    if poop == true then
    vid:DrawSprite(poopPos, menuSprites, 6, poopAnim, color.white, color.clear)
    end
end

function flushPoop()

  -- check if we made a flush request
  if poopFlushQueue > 0.5 then
   
    -- move the water left
      flushPosX += -10
    

    -- if flush moved out of screen we set all values to default
    if flushPosX < 2 then
    poop = false
    poopValue = 0
    poopFlushQueue = 0
    flushPosX = 55
    end
  end
end

-- draws the thing that flushes the shiz
function drawflush()

  if poopFlushQueue > 0.5 then
  vid:DrawSprite(vec2(flushPosX, flushPosY), menuSprites, 4, 3, color.white, color.clear)
  vid:DrawSprite(vec2(flushPosX, flushPosY + 16), menuSprites, 4, 3, color.white, color.clear)
  end

end

-- this function will handdle the digimon sprites
function drawDigimon()


    -- if its looking left or right we use diferent sprites 
    if digimon.looking < 0.5 then 
        vid:DrawSprite(DigimonPos, digimonSpritesFlip, 0, 1, color.white, color.clear)
    else
        vid:DrawSprite(DigimonPos, digimonSprites, 0, 1, color.white, color.clear)
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
  "  Digimon X Y Pos:" .. digimon.posX .. " " .. digimon.posY .. "\n",
  "Flush X Y Pos: " .. flushPosX .. " " .. flushPosY .. "\n",
  "MenuItem:" .. menu.current .. "\n",
  "poopV:" .. poopValue .. "\n",
  "flush:" .. poopFlushQueue .. "\n",
  "T: " .. time.seconds .. " " .. time.minutes .. " " .. time.hours .. "\n",
  "dlt-T: " .. timeDlt.counter
  )
end


-- ######## MAIN GAME LOOP ########
function update()
  debugPrint()
  
  -- clears the screen
  vid:Clear(color.white)
  
  -- set according possitions
  cursor.pos = vec2(cursor.posX,cursor.posY)
  DigimonPos = vec2(digimon.posX, digimon.posY)
  poopPos = vec2(PoopPosX, PoopPosY)
  
  
  -- increase the counter by the CPU's DeltaTime
  timeDlt.counter += gdt.CPU0.DeltaTime

  -- this function will draw the menu sprites
  drawMenuSprites()
  
  -- draws the cursor
  drawSelSprite()
  
  -- does colision for digimon
  digimonColision()
  
  -- draws the digimon
  drawDigimon()
  
  -- handdler for digimon stuff
  digimonHandler()
  
  -- draw funny poopoo
  drawPoop()

  -- checks if you shat yourself
  poopCheck()
  
  -- draws the little waves to flush shit
  drawflush()
  
  
  -- checks if the button is pressed down to cycle tru menu
  if but2.ButtonDown then
    CursorHandler()
    
  end
  
  if but1.ButtonDown then
    menu:select()
  end
  
  if but0.ButtonDown then
    poopValue += 1000
  end
  
  
  
  
  -- time tracker 
  deltaTimeHandler()
  
  
  
end