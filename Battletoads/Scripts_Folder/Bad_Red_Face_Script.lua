-- IMPORTANT NOTE: This is a MUCH less useful script than the red faces w/ chunks script that I wrote. To get a faster time, you should use that!
-- the only advantage of this script is that it can give you the input for an entire red face all at once, whereas the other script has to be run 3 times
-- to get all of the input for each red face. Thus, this script is slightly easier to use, and doesn't require the user to check where they left off
-- before they start the next fraction of a red face section.

-- Written by Lobsterzelda

-- This script attempts to make RNG-address 2 (0X26) have a value which when ANDed with 7 equals 7
-- before an object loads. If it doesn't have the right value, then an earlier save state
-- is loaded, and random inputs are applied to make it happen. 2500 trials of this are then run.
-- save state 1 stores the initial save state, and save state 5 is updated after every frame that a new object is created
-- (save state 5 is also what's loaded when an attempt fails)
-- in each attempt, button presses are kept track of, and are output to a file if a new best occurs.
-- additionally, at the end of the program, the best attempt is reported.

math.randomseed( os.time() )
file = io.open("resultsOfWorstScriptFile.txt", "w")
io.output(file)
io.write("Starting up my weak battletoads script: ")
io.flush()
NeedToLoad = false
NeedToSave = true
earlierBetterSave = 0
needToExtraSave = false
attemptsInRow = 0

buttonsPressed = {}
for i = 0, 400 do
buttonsPressed[i] = {A = false, B = false, Select = false, Right = false, Left = false, Up = false}
end


realStartFrame = 34541
currentFrame = 0
frameOfLastSave = 0
savestate.loadslot(1)
savestate.saveslot(5)
currentNumLagBeforeSave = 0
currentNumLagAfterSave = 0
currentBestLag = 999

function firstFunc()
if memory.readbyte(0X3C1) ~= 0 then
	goBackwards()
end
end


function secondFunc()
if memory.readbyte(0X3C2) ~= 0 then
	goBackwards()
end
end

function thirdFunc()
if memory.readbyte(0X3C3) ~= 0 then
	goBackwards()
end
end

function fourthFunc()
if memory.readbyte(0X3C4) ~= 0 then
	goBackwards()
end
end

function fifthFunc()
if memory.readbyte(0X3C5) ~= 0 then
	goBackwards()
end
end

function sixthFunc()
if memory.readbyte(0X3C6) ~= 0 then
	goBackwards()
end
end

function seventhFunc()
if memory.readbyte(0X3C7) ~= 0 then
	goBackwards()
end
end

function eighthFunc()
if memory.readbyte(0X3C8) ~= 0 then
	goBackwards()
end
end

function ninthFunc()
if memory.readbyte(0X3C9) ~= 0 then
	goBackwards()
end
end



function tenthFunc()
if memory.readbyte(0X3CA) ~= 0 then
	goBackwards()
end
end

function eleventhFunc()
if memory.readbyte(0X3CB) ~= 0 then
	goBackwards()
end
end

function twelthFunc()
if memory.readbyte(0X3CC) ~= 0 then
	goBackwards()
end
end

function thirteenthFunc()
if memory.readbyte(0X3CD) ~= 0 then
	goBackwards()
end
end

function fourteenthFunc()
if memory.readbyte(0X3CE) ~= 0 then
	goBackwards()
end
end

function fifteenthFunc()
if memory.readbyte(0X3CF) ~= 0 then
	goBackwards()
end
end

function goBackwards()

RNG_Byte = memory.readbyte(0X26)
if bit.band(RNG_Byte, 7) ~= 7 then
	if currentFrame - frameOfLastSave > 8 then
		needToExtraSave = true
		earlierBetterSave = currentFrame - 8
	end	

	if frameOfLastSave + 1 >= currentFrame then
		isFailure = true
		io.write("Attempt failed!\n")
		io.flush()
	end

currentNumLagAfterSave = 0
currentFrame = frameOfLastSave
attemptsInRow = attemptsInRow + 1
if attemptsInRow >= 5000 then
isFailure = true
io.write(" Attempt failed!\n")
io.flush()
end
needToLoad = true

else
currentNumLagBeforeSave = currentNumLagBeforeSave + currentNumLagAfterSave
attemptsInRow = 0
currentNumLagAfterSave = 0
frameOfLastSave = currentFrame
needToSave = true


end
end


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

numSuccess = 0
while numSuccess < 2500 do
needToExtraSave = false
currentFrame = 0
frameOfLastSave = 0
currentNumLagBeforeSave = 0
currentNumLagAfterSave = 0

savestate.loadslot(1)
savestate.saveslot(5)
io.write("Try: ", numSuccess, "\n")
io.flush()
isFailure = false 
attemptsInRow = 0
while currentFrame < 398 and isFailure == false and currentNumLagBeforeSave <= currentBestLag do

if math.random(0, 1) == 0 and needToExtraSave == false then
	buttonsPressed[currentFrame]["A"] = true
else
	buttonsPressed[currentFrame]["A"] = false
end

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


if needToExtraSave and currentFrame == earlierBetterSave then
savestate.saveslot(5)
currentNumLagBeforeSave = currentNumLagBeforeSave + currentNumLagAfterSave
currentNumLagAfterSave = 0
frameOfLastSave = currentFrame
needToExtraSave = false
end

joypad.set(buttonsPressed[currentFrame], 1)
	currentFrame = currentFrame + 1
	if emu.islagged() then
		currentNumLagAfterSave = currentNumLagAfterSave + 1
	end
	emu.frameadvance()

	if needToLoad == true then
	savestate.loadslot(5)
	needToLoad = false
	end

	if needToSave == true then
	savestate.saveslot(5)
	needToSave = false
	end
end

io.write(" (lag of ", currentNumLagBeforeSave + currentNumLagAfterSave, ")\n")
io.flush()

numSuccess = numSuccess + 1


if isFailure == false and currentNumLagBeforeSave + currentNumLagAfterSave < currentBestLag then
io.write("New best of ", currentNumLagBeforeSave + currentNumLagAfterSave, " frames of lag!\n\n")
	currentBestLag = currentNumLagBeforeSave + currentNumLagAfterSave
	for tempCount = 0, 399 do
	
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
