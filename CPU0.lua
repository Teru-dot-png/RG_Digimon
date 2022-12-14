-- Assets
local menuSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.Digimon1
local digimonSprites:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1
local digimonSpritesFlip:SpriteSheet = gdt.ROM.User.SpriteSheets.digimonNIGHTMARE1Flip

-- Hardware
local vid:VideoChip = gdt.VideoChip0
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

-- keep track of position of selector
local selectorPos:vec2 = vec2(0,5)
local selposX = 0
local selposY = 5

-- keep track of digimon position and stats
local DigimonPos:vec2 = vec2(0,0)
local digimonposX = 35
local digimonposY = 25
local looking = 0
local poopR = 0
local poopValue = 0
local poop = false
local poopAnim = 0

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
 function menuHandling(  )
    
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
    poopR = math.random( 1, 11150 )

    if poopR == 46 then
    poop = true
    poopValue += 1
    end

    if poop == true then

        drawPoop()
    end

end

function drawPoop()
    vid:DrawSprite(vec2(35,35), menuSprites, 6, poopAnim, color.white, color.clear)
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
    selectorPos = vec2(selposX,selposY)
    DigimonPos = vec2(digimonposX, digimonposY)
    
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
    
    digimonHandler()
    
    
    -- checks if the button is pressed down to cycle tru menu
    if but2.ButtonDown then
        CursorHandler()
				
    end
    
    if but0.ButtonDown then
        poop = true
    end

    if but1.ButtonDown then
        
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