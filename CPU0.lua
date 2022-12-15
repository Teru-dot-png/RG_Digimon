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
local frameDuration = 1.5

-- this will keep track of DeltaTime
local deltaCounter = 0

-- keep track of the current frame
local frameNumber = 0 

-- keep track of menu 
local menuPos = 0
local maxMenuPos = 9
local isInsideMenu

-- keep track of position of selector
local selectorPos:vec2 = vec2(0,5)
local selposX = 0
local selposY = 5

-- keep track of digimon position and stats
local DigimonPos:vec2 = vec2(0,0)
local digimonposX = 35
local digimonposY = 25
local looking = 0

-- as much as i dont want to we need to keep track of poop
local poopR = 0
local poopValue = 0
local poop = false
local poopAnim = 0
local poopFlushQueue = 0
local flushing = false
local poopPos = vec2(0, 0)
local PoopPosX = 35
local PoopPosY = 35
local flushPos = vec2(0, 0)
local flushPosX = 0
local flushPosY = 0

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


-- does the menu functions
 function menuSelect()

-- define the if-else statement
    if menuPos == 0 then
      print("Menu position 0 selected")
    elseif menuPos == 1 then
      print("Menu position 1 selected")
    elseif menuPos == 2 then
      print("Menu position 2 selected")
    elseif menuPos == 3 then
      print("Menu position 3 selected")
    elseif menuPos == 4 then
      print("Menu position 4 selected")
      poopFlushQueue = 1
    elseif menuPos == 5 then
      print("Menu position 5 selected")
    elseif menuPos == 6 then
      print("Menu position 6 selected")
    elseif menuPos == 7 then
      print("Menu position 7 selected")
    elseif menuPos == 8 then
      print("Menu position 8 selected")
    elseif menuPos == 9 then
      print("Menu position 9 selected")
    end
 end

-- draws the cursor
function drawSelSprite()
    vid:DrawSprite(selectorPos, menuSprites, 5, 1, color.white, color.clear)
end

function CursorHandler()
    -- everytime the button is clicked
    menuPos += 1 -- menu position add 1
    selposX += 15 -- move the position to 15 units

    -- if the cursor position is over the screen we go to next
    if selposX > 60 then
        selposY = 50
        selposX = 0
    end      

    -- if its over the max options we go bac
    if menuPos > maxMenuPos then
        -- reseting positions
        menuPos = 0
        selposX = 0
        selposY = 5  
    end
end

-- this function will move the digimon once and a while
function digimonMover()
    
    -- random number for looking left or right
    looking = math.random()
    
    -- if its above 0.5 we move it 5 units else we go back 5 units
    if looking < 0.5 then
        
        
        digimonposX += 5 
    else
        
        digimonposX -= 5
    end
    
    
end

-- this function will handdle the digimon stats and needs
function digimonHandler()
    

end


--this is like a vibe check but to see if you shat yourself
function poopCheck()
    poopR = math.random( 1, 3150 )

    if poopR == 500 or poopR == 200 then
    poop = true
    poopValue += 1
    end
end

-- this function will draw poop if digimon has done the peepee poopoo caacaa
function drawPoop()
    if poop == true then
    vid:DrawSprite(poopPos, menuSprites, 6, poopAnim, color.white, color.clear)
    end
end

function flushPoop()
    if poopFlushQueue > 0.5 then


    vid:DrawSprite(flushPos, menuSprites, 4, 3, color.white, color.clear)


    end
end

-- this function will handdle the digimon sprites
function drawDigimon()


    -- if its looking left or right we use diferent sprites 
    if looking < 0.5 then 
        vid:DrawSprite(DigimonPos, digimonSpritesFlip, 0, 1, color.white, color.clear)
    else
        vid:DrawSprite(DigimonPos, digimonSprites, 0, 1, color.white, color.clear)
    end
end

--  we do some colision checking in the rectangle
function digimonColision()
   -- we check if we moved out of bounds and reset it to wall values
   if digimonposX < 0 then
        digimonposX = 2
    end
    if digimonposX > 71 then
       digimonposX = 59
    end
end

-- prints the debug info
function debugPrint()
print(
"  Digimon x Pos:" .. digimonposX .. "\n",
"Digimon y Pos:" .. digimonposY.. "\n",
"Current Menu:" .. menuPos .. "\n",
"poop data:" .. poopValue
)
end


-- ######## MAIN GAME LOOP ########
function update()
    debugPrint()

    -- clears the screen
    vid:Clear(color.white)

    -- set according possitions
    selectorPos = vec2(selposX,selposY)
    DigimonPos = vec2(digimonposX, digimonposY)
    poopPos = vec2(PoopPosX, PoopPosY)
    flushPos = vec2(flushPosX, flushPosY)

    -- increase the counter by the CPU's DeltaTime
    deltaCounter += gdt.CPU0.DeltaTime
    
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

    
    -- checks if the button is pressed down to cycle tru menu
    if but2.ButtonDown then
        CursorHandler()
				
    end
    
    if but1.ButtonDown then
        menuSelect()
    end

    if but0.ButtonDown then
        poop = true
    end

    
    
    
    
    -- we run a while loop for however many times the delta counter is greater
    -- than the duration of one frame, such that if for some reason the counter
    -- has gone past over one frame duration, we run our frame loop however many
    -- times necessary to keep the logic tied to the timer.
    while (deltaCounter >= frameDuration) do
        deltaCounter -= frameDuration
        frameNumber += 1
        poopAnim = math.random(2, 3)
        digimonMover()
							
		end
	  
end