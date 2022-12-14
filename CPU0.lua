-- Assets
local spriteSheet:SpriteSheet = gdt.ROM.User.SpriteSheets.Digimon1
-- Hardware
local video:VideoChip = gdt.VideoChip0
local but0 = gdt.LedButton0
local but1 = gdt.LedButton1
local but2 = gdt.LedButton2
-- advance one frame
local frameDuration = 1
-- this will keep track of DeltaTime
local deltaCounter = 0
-- keep track of the current frame
local frameNumber = 0 
-- keep track of menu 
local menuPos = 0
-- set a max for menu pos
local maxMenuPos = 9

-- keep track of position of selector
local selectorPos:vec2 = vec2(0,5)

local selposX = 0
local selposY = 5
-- this will draw menu sprites
function drawMenuSprites()
-- Draws the top menu
video:DrawSprite(vec2(5,5), spriteSheet, 0, 0, color.white, color.clear)
video:DrawSprite(vec2(20,5), spriteSheet, 1, 0, color.white, color.clear)
video:DrawSprite(vec2(35,5), spriteSheet, 2, 0, color.white, color.clear)
video:DrawSprite(vec2(50,5), spriteSheet, 3, 0, color.white, color.clear)
video:DrawSprite(vec2(65,5), spriteSheet, 4, 0, color.white, color.clear)

-- draw the bottom menu
video:DrawSprite(vec2(5,50), spriteSheet, 0, 1, color.white, color.clear)
video:DrawSprite(vec2(20,50), spriteSheet, 1, 1, color.white, color.clear)
video:DrawSprite(vec2(35,50), spriteSheet, 2, 1, color.white, color.clear)
video:DrawSprite(vec2(50,50), spriteSheet, 3, 1, color.white, color.clear)
video:DrawSprite(vec2(65,50), spriteSheet, 4, 1, color.white, color.clear)
end



function drawSelSprite()
    
    
    video:DrawSprite(selectorPos, spriteSheet, 5, 1, color.white, color.clear)
    
end

function CursorHandler()
    menuPos += 1
    selposX += 15
    if selposX > 60 then
        selposY = 50
        selposX = 0
    end      
    -- if its over the max we go bac
    if menuPos > maxMenuPos then
        menuPos = 0
        selposX = 0
        selposY = 5
        
        
    end
    
end

-- this will get called every 0.5 seconds
function frame()


-- increment the frame number
frameNumber += 1

end
-- ######## MAIN GAME LOOP ########
function update()
print("Cursor x Pos:" .. selposX,"Cursor y Pos:" .. selposY)
selectorPos = vec2(selposX,selposY)

-- increase the counter by the CPU's DeltaTime
    deltaCounter += gdt.CPU0.DeltaTime
   
-- this function will draw the menu sprites
    drawMenuSprites()

-- everytime the button is pressed we change the cursor pos
    drawSelSprite()

-- checks if the button is pressed down to cycle tru menu
    if but0.ButtonDown then
        CursorHandler()
    end
		
			
					
									
    -- we run a while loop for however many times the delta counter is greater
    -- than the duration of one frame, such that if for some reason the counter
    -- has gone past over one frame duration, we run our frame loop however many
    -- times necessary to keep the logic tied to the timer.
    while (deltaCounter >= frameDuration) do
        deltaCounter -= frameDuration
        video:Clear(color.white)
        frame()

    end
	  
end