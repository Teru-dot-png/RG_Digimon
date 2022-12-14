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

function frame1()
    -- this will get called every 0.5 seconds




    video:DrawSprite(vec2(5,5), spriteSheet, frameNumber, 0, color.white, color.clear)

-- increment the frame number
frameNumber += 1
end




function update()
    -- increase the counter by the CPU's DeltaTime
    deltaCounter += gdt.CPU0.DeltaTime

		
		-- when the but0 is pressed it raises the frame number
			if but0.ButtonDown then
					frameNumber += 1
			end	
					
									
    -- we run a while loop for however many times the delta counter is greater
    -- than the duration of one frame, such that if for some reason the counter
    -- has gone past over one frame duration, we run our frame loop however many
    -- times necessary to keep the logic tied to the timer.
    while (deltaCounter >= frameDuration) do
        deltaCounter -= frameDuration
        video:Clear(color.white)
        frame1()

    end
	  
end
