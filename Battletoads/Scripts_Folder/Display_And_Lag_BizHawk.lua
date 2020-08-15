-- Written by Lobsterzelda in 2020 for BizHawk

-- This script is designed to show what inputs player 1 is pressing in Battletoads, while also showing
-- how many lag frames have occured. Player 1's inputs are drawn on the bottom of the screen in boxes. 
-- During non-lag frames, these boxes are green. During lag frames, these boxes are red, and show no input. 
-- Above the input display is a counter showing the total number of lag frames that have occured so far.
-- This script only counts lag frames while a red face is loaded into memory, but making two small changes
-- is all that's neccesary to make this a general purpose lag counting script that could be used for any NES game:
-- 1. change line 129 to: if isLag then
-- 2. Delete lines 135-137

-- NOTE: This script was written and designed for usage in BizHawk. I also have another equivalent script 
-- I wrote that works in FCEUX.
-- The order that inputs are displayed on screen is: U, D, L, R, Start, Select, B, A
 


-- x_start stores the x position of the leftmost edge of the leftmost box of the input display.
-- to alter how far to the left or right the input display is, change the number on the line below.
x_start = 7

-- y_pos_box stores the y-position of the top line of the box of the input display.
-- to alter how far up or down the input display is, change the number on the line below.
y_pos_box = 211


-- square_length controls how big each side of the squares are that make up the input display.
-- to alter how big the input display is, change the number on the line below.
square_length = 25


-- the ID of the red face objects.
faceID = 96
lagCounter = 0
isLag = true


-- this function takes as input the name of a button, and returns the abbreviated name of the button
-- which is displayed in the input viewer box.

function getShortName(myString)
	if myString == "Up" then
		return "U"
	end

	if myString == "Down" then
		return "D"
	end

	if myString == "Left" then
		return "L"
	end

	if myString == "Right" then
		return "R"
	end

	if myString == "Start" then
		return "S"
	end

	if myString == "Select" then
		return "s"
	end

	if myString == "A" then
		return "A"
	end

	if myString == "B" then
		return "B" 
	end

	return "N/A"
end


-- this function returns true if a red face is loaded into any of the 15 object slots used by Battletoads, 
-- and returns false otherwise
function checkForFaceLoaded()

	if memory.readbyte(0X3C1) == faceID or memory.readbyte(0X3C2) == faceID or
   		memory.readbyte(0X3C3) == faceID or memory.readbyte(0X3C4) == faceID or
   		memory.readbyte(0X3C5) == faceID or memory.readbyte(0X3C6) == faceID or
   		memory.readbyte(0X3C7) == faceID or memory.readbyte(0X3C8) == faceID or
   		memory.readbyte(0X3C9) == faceID or memory.readbyte(0X3CA) == faceID or
   		memory.readbyte(0X3CB) == faceID or memory.readbyte(0X3CC) == faceID or
  	 	memory.readbyte(0X3CD) == faceID or memory.readbyte(0X3CE) == faceID or
   		memory.readbyte(0X3CF) == faceID then
			return true
	end

	return false

end



-- stores the full names of buttons in the order that they are outputted on the input display
InputStringArray = {"Up", "Down", "Left", "Right", "Start", "Select", "B", "A"}

function setNotLag()
	isLag = false
end

event.oninputpoll(setNotLag)

-- main execution loop.
while true do
	isLag = true
	emu.frameadvance()
	boxNum = 1
	
	-- Setting the color of the input display to green
	innerColor = "lightGreen"
	myInputTable = movie.getinput(emu.framecount() - 1, 1)
	
	-- if we have a lag frame, then the input display is changed to red. Otherwise, it remains green.
	if isLag then
		innerColor = "red"
	end

	while boxNum <= 8 do
		buttonName = InputStringArray[boxNum]
		
		--drawing the next square of the input display
		gui.drawRectangle(x_start + (square_length * (boxNum - 1)), y_pos_box, square_length, square_length, "black", innerColor)

		-- if this is not a lag frame and the user pressed the button that the box refers to, then the button
		-- name is displayed in the box. Otherwise, no text is written in the box in the input display
		if isLag == false and myInputTable[buttonName] == true  then
			gui.drawText(x_start + 8 + (square_length * (boxNum - 1)), y_pos_box + 4, getShortName(buttonName), "black")
		end

		boxNum = boxNum + 1
	end

	--increasing the lag counter if the current frame was a lag frame and a red face was loaded into memory.
	--if you want to make this a general purpose lag counter, then change the following line to: if isLag then
	if isLag == true and checkForFaceLoaded() == true then
		lagCounter = lagCounter + 1
	end

	--resetting the lag counter to 0 if no red face was loaded into memory.
	--if you want to make this a general purpose lag counter, then delete the following 3 lines of code
	if checkForFaceLoaded() == false then
		lagCounter = 0
	end

	--drawing the box for the lag counter.
	gui.drawRectangle(x_start, y_pos_box - 15, 65, 15, "black", "white")
	
	--drawing the text that says how many lag frames have occured.
	gui.drawText(x_start + 3, y_pos_box - 15, "Lag: " .. tostring(lagCounter), "red")
end
