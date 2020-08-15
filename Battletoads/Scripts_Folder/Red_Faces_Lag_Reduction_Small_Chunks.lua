-- Written by Lobsterzelda in 2020 for Battletoads (NES on BizHawk)

-- This script attempts to make RNG-address 2 (0X26) have a value which, when bitwise-ANDed with 7, has a value of 7.
-- More specifically, this script only tries to manipulate what value RNG-2 has when a new object tries to load.
-- If a new object is written to the object table and RNG-2 doesn't have a correct value, then an earlier save state is loaded.
-- Random inputs are applied throughout this process, and the reloading of save states continues until a favorable RNG-2 value is reached.
-- The above process continues until either 10 objects have loaded into memory or 200 frames have passed, at which point the total number of lag frames
-- that occured is calculated to determine if this try had less lag frames than the previous best.
-- 2500 trials are run using this process, and whenever an attempt generates a new lowest number of lag frames, 
-- the button presses that occured on the attempt are written to a file named "resultsOfRedFaceScriptFile.txt"
-- The button presses are written to the file in a format that will let them be copy and pasted directly to the "Input Log.txt" file of a bk2 file. 
-- The bk2 file that they are copied to can then be used to create a new tasproj file,
-- and the inputs from that tasproj file can be copied directly to the tasproj file where your movie is. 
-- This way, you don't have to manually enter in the button presses for each frame.

-- IMPORTANT NOTE: Save state 1 must be set by the user to store where the script should start testing from BEFORE 
-- this script is run for the first time (otherwise, an exception will occur)
-- Save state 5 is updated after every frame that a new object is created (save state 5 is also what's loaded when an attempt fails)


-- initializing RNG for random button presses
math.randomseed( os.time() )

-- to change the name of the output file, change the name "resultsOfRedFaceScriptFile.txt" on the line below 
-- to whatever you would like the output file to be called.
file = io.open("resultsOfRedFaceScriptFile.txt", "w")
io.output(file)
io.write("Starting up battletoads lag script: ")
io.flush()

NeedToLoad = false
NeedToSave = false
earlierBetterSave = 0
needToExtraSave = false

-- attemptsInRow counts the number of times that a state has been loaded in a row without a new state being saved
attemptsInRow = 0


-- buttonsPressed is an array which stores the button presses on player 1's controller for 200 frames.
buttonsPressed = {}

for i = 0, 200 do
	buttonsPressed[i] = {A = false, B = false, Select = false, Start = false, Right = false, Left = false, Up = false, Down = false}
end


numTrials = 0
currentFrame = 0
frameOfLastSave = 0
numObjectsLoaded = 0
savestate.loadslot(1)
savestate.saveslot(5)
currentNumLagBeforeSave = 0
currentNumLagAfterSave = 0
currentBestLag = 999


-- the following 15 functions are called by event.onmemorywrite() whenever a new value is written to one of the 15 object ID slots (which go from 0X3C1 to 0X3CF)
-- each function checks to see if a non-zero value was written to the ID section. If the value written was non-zero, then the function goBackwardsOrForwards() 
-- is called. Otherwise, if zero was written, that means the object was deleted, in which case goBackwardsOrForwards() is not called

-- function called whenever 0X3C1 is written to
function firstFunc()
	if memory.readbyte(0X3C1) ~= 0 then
		goBackwardsOrForwards()
	end
end


-- function called whenever 0X3C2 is written to
function secondFunc()
	if memory.readbyte(0X3C2) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C3 is written to
function thirdFunc()
	if memory.readbyte(0X3C3) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C4 is written to
function fourthFunc()
	if memory.readbyte(0X3C4) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C5 is written to
function fifthFunc()
	if memory.readbyte(0X3C5) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C6 is written to
function sixthFunc()
	if memory.readbyte(0X3C6) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C7 is written to
function seventhFunc()
	if memory.readbyte(0X3C7) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C8 is written to
function eighthFunc()
	if memory.readbyte(0X3C8) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3C9 is written to
function ninthFunc()
	if memory.readbyte(0X3C9) ~= 0 then
		goBackwardsOrForwards()
	end
end


-- function called whenever 0X3CA is written to
function tenthFunc()
	if memory.readbyte(0X3CA) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3CB is written to
function eleventhFunc()
	if memory.readbyte(0X3CB) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3CC is written to
function twelthFunc()
	if memory.readbyte(0X3CC) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3CD is written to
function thirteenthFunc()
	if memory.readbyte(0X3CD) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3CE is written to
function fourteenthFunc()
	if memory.readbyte(0X3CE) ~= 0 then
		goBackwardsOrForwards()
	end
end

-- function called whenever 0X3CF is written to
function fifteenthFunc()
	if memory.readbyte(0X3CF) ~= 0 then
		goBackwardsOrForwards()
	end
end


-- This function is called whenever a new object is created. The function checks to see if the value of RNG_2 & 7 is 7.
-- If RNG_2 & 7 is 7, then the function sets needToSave to true to signal that a savestate should be written into slot 5 at the end of this frame, 
-- adds the lag that occured since the last save state was made to the running total, increases the number of loaded objects by 1 and effectively "moves forwards".
-- If RNG_2 & 7 wasn't 7, then needToLoad is set to true to signal that savestate 5 should be re-loaded at the end of this frame, 
-- the counter for lag that occured since the last save state is set to 0, 
-- and the value for current frame is set to the frame number of the last save (in effect, "going backwards")

-- Note: if there were more than 8 frames b/w two objects loading and RNG_2 & 7 wasn't 7, then needToExtraSave will be set to true, 
-- earlierBetterSave will be set to currentFrame - 8 and save state 5 will be reloaded. 
-- When current frame equals earlierBetterSave for the next time, then a new save state will be written to slot 5. 
-- This cuts down on how long the script runs, since, for example, if there were 100 frames b/w two objects loading and it took 30 attempts 
-- to get RNG_2 to have the right value, then this would require running through 3,000 frames to get the right value, 
-- while if a new save state was made on the 92nd frame on the second try, then only 416 frames would need to be run through to get the right value.

-- Other Note: If an object loads on the same frame that the last save state was made on and RNG_2 & 7 wasn't 7, 
-- then there is no way to manipulate RNG_2 to have the right value, since there are 0 frames of input to work with. 
-- As such, this attempt is considered a failure, all values for lag and frame numbers are reset, 
-- save state 1 is reloaded, and a new trial begins right after this.

function goBackwardsOrForwards()

	RNG_2_Byte = memory.readbyte(0X26)

	-- if RNG_2_Byte & 7 wasn't equal to 7, then we need to either load an earlier save state or set isFailure to true if the attempt failed.
	if bit.band(RNG_2_Byte, 7) ~= 7 then

		--if more than 8 frames have passed since the last save and RNG_2 didn't have a correct value on this frame, 
		--then we set an extra save to occur on currentFrame - 8
		if currentFrame - frameOfLastSave > 8 then
			needToExtraSave = true
			earlierBetterSave = currentFrame - 8
		end	

		-- if the current frame is the same frame that the last save state was made on, then an error occured, 
		-- and we set isFailure to true and move on to the next trial
		if frameOfLastSave + 1 >= currentFrame then
			isFailure = true
			io.write("Attempt failed!\n")
			io.flush()
		end

		-- resetting the lag counter for the section after the last save state, and setting current frame back to the frame of the earlier save
		currentNumLagAfterSave = 0
		currentFrame = frameOfLastSave
		attemptsInRow = attemptsInRow + 1

		-- if 5000 or more attempts to get a favorable value of RNG_2 have happened in a row since the last save state was saved to, 
		-- then the attempt is considered to have failed, and we move on to the next trial.
		if attemptsInRow >= 5000 then
			isFailure = true
			io.write(" Attempt failed!\n")
			io.flush()
		end

		-- signals to load the savestate in slot 5 when the emu.frameadvance() function finishes
		needToLoad = true


	-- this branch is reached when RNG_2 & 7 IS equal to 7, which is a success.
	-- in this case, we add the lag since the last save state to the running lag total, set the lag after save state counter to 0,
	-- set the frame number that the last save occured on to the value of the current frame, increase the count of the number of objects loaded by 1,
	-- and set needToSave to true to signal that we need to save state to slot 5 when the emu.frameadvance() function finishes
	else
		currentNumLagBeforeSave = currentNumLagBeforeSave + currentNumLagAfterSave
		attemptsInRow = 0
		currentNumLagAfterSave = 0
		frameOfLastSave = currentFrame
		needToSave = true
		numObjectsLoaded = numObjectsLoaded + 1

	end
end


-- setting the 15 functions described above to be called whenever the memory addresses 0X3C1 to 0X3CF are written to.
event.onmemorywrite(firstFunc, 0X3C1)
event.onmemorywrite(secondFunc, 0X3C2)
event.onmemorywrite(thirdFunc, 0X3C3)
event.onmemorywrite(fourthFunc, 0X3C4)
event.onmemorywrite(fifthFunc, 0X3C5)
event.onmemorywrite(sixthFunc, 0X3C6)
event.onmemorywrite(seventhFunc, 0X3C7)
event.onmemorywrite(eighthFunc, 0X3C8)
event.onmemorywrite(ninthFunc, 0X3C9)
event.onmemorywrite(tenthFunc, 0X3CA)
event.onmemorywrite(eleventhFunc, 0X3CB)
event.onmemorywrite(twelthFunc, 0X3CC)
event.onmemorywrite(thirteenthFunc, 0X3CD)
event.onmemorywrite(fourteenthFunc, 0X3CE)
event.onmemorywrite(fifteenthFunc, 0X3CF)



-- the "main function" for the program
while numTrials < 2500 do

	needToLoad = false
	needToSave = false
	needToExtraSave = false
	currentFrame = 0
	frameOfLastSave = 0
	currentNumLagBeforeSave = 0
	currentNumLagAfterSave = 0

	savestate.loadslot(1)
	savestate.saveslot(5)
	io.write("Try: ", numTrials, "\n")
	io.flush()
	isFailure = false 
	attemptsInRow = 0
	numObjectsLoaded = 0

	-- the process below repeats while less than 10 objects have loaded, the current attempt wasn't a failure, 
	-- the number of lag frames that have occured up to the last save state is less than the current lowest number of total lag frames for a trial, 
	-- and the number of frames advanced from the starting frame is less than 200
	while numObjectsLoaded < 10 and isFailure == false and currentNumLagBeforeSave < currentBestLag and currentFrame < 200 do


		-- randomly deciding what buttons to press on player 1's controller for this frame
		-- the A, B, Left, Right, Up, and Select buttons each have a random 50-50 chance of being set to true or false for player 1's controller. 
		-- Down and Start on player 1's controller are always set to false (not pressed), and no buttons on player 2's controller are pressed
		if math.random(0, 1) == 0 and needToExtraSave == false then
			buttonsPressed[currentFrame]["A"] = true
		else
			buttonsPressed[currentFrame]["A"] = false
		end

		-- button B isn't pressed if it has been 10 frames or less since the starting frame, 
		-- since this sometimes causes the toad to punch left and miss the pole
		if math.random(0, 1) == 0 and needToExtraSave == false and currentFrame >= 10 then
			buttonsPressed[currentFrame]["B"] = true
		else
			buttonsPressed[currentFrame]["B"] = false
		end


		if math.random(0, 1) == 0 and needToExtraSave == false then
			buttonsPressed[currentFrame]["Left"] = true
		else
			buttonsPressed[currentFrame]["Left"] = false
		end


		if math.random(0, 1) == 0 and needToExtraSave == false then
			buttonsPressed[currentFrame]["Right"] = true
		else
			buttonsPressed[currentFrame]["Right"] = false
		end


		if math.random(0, 1) == 0 and needToExtraSave == false then
			buttonsPressed[currentFrame]["Up"] = true
		else
			buttonsPressed[currentFrame]["Up"] = false
		end


		if math.random(0, 1) == 0 and needToExtraSave == false then
			buttonsPressed[currentFrame]["Select"] = true
		else
			buttonsPressed[currentFrame]["Select"] = false
		end


		joypad.set(buttonsPressed[currentFrame], 1)

		-- if needToExtraSave was set to true and the current frame equals the frame that the save is supposed to happen on, 
		-- then we save to slot 5, add the number of lag frames that happened since the last save to the running total, 
		-- set the number of lag frames after the last save to 0, set the frame of the last save to be the current frame,
		-- and set needToExtraSave to false
		if needToExtraSave and currentFrame == earlierBetterSave then
			savestate.saveslot(5)
			currentNumLagBeforeSave = currentNumLagBeforeSave + currentNumLagAfterSave
			currentNumLagAfterSave = 0
			frameOfLastSave = currentFrame
			needToExtraSave = false
		end

		currentFrame = currentFrame + 1	
		--advancing forwards 1 frame (if goBackwardsOrForwards() is going to be called, 
		--it will happen in the middle of the emu.frameadvance() function executing)
		emu.frameadvance()
	
		--if a lag frame occured, then we increase the count for the number of lag frames that occured since the last save state.
		if emu.islagged() then
			currentNumLagAfterSave = currentNumLagAfterSave + 1
		end


		--if needToLoad is true, then we load the savestate in slot 5, and set needToLoad to false
		if needToLoad == true then
			currentNumLagAfterSave = 0
			savestate.loadslot(5)
			needToLoad = false
		end


		--if needToSave is true, then we savestate to slot 5, and set needToSave to false
		if needToSave == true then
			currentNumLagBeforeSave = currentNumLagBeforeSave + currentNumLagAfterSave
			currentNumLagAfterSave = 0
			savestate.saveslot(5)
			needToSave = false
		end
	end

	--if the last try wasn't a failure, then we print out how many lag frames occured
	if isFailure == false then
		io.write(" (lag of ", currentNumLagBeforeSave + currentNumLagAfterSave, ")\n")
		io.flush()
	end


	numTrials = numTrials + 1


	--if we had a new best for least number of lag frames, then we write out all 200 frames of player 1's input to the output file in a format 
	--that will let it be copy and pasted directly into the "Input Log.txt" file of a 2 player bk2 file
	if isFailure == false and currentNumLagBeforeSave + currentNumLagAfterSave < currentBestLag then
		io.write("New best of ", currentNumLagBeforeSave + currentNumLagAfterSave, " frames of lag!\n\n")
		currentBestLag = currentNumLagBeforeSave + currentNumLagAfterSave


		for tempCount = 0, 200 do
	
			io.write("|..|")
	

			if buttonsPressed[tempCount]["Up"] == true then
				io.write("U.")
			else
				io.write("..")
			end


			if buttonsPressed[tempCount]["Left"] == true then
				io.write("L")
			else
				io.write(".")
			end


			if buttonsPressed[tempCount]["Right"] == true then
				io.write("R.")
			else
				io.write("..")
			end


			if buttonsPressed[tempCount]["Select"] == true then
				io.write("s")
			else
				io.write(".")
			end


			if buttonsPressed[tempCount]["B"] == true then
				io.write("B")
			else
				io.write(".")
			end



			if buttonsPressed[tempCount]["A"] == true then
				io.write("A|........|\n")
			else
				io.write(".|........|\n")
			end

		end

		io.write("\nEnd of sequence for ", currentNumLagBeforeSave + currentNumLagAfterSave, " frames of lag input\n")
		io.flush()

	end

end
