-- feos and TheZlomuS, 2012
-- Minor Updates Made by Lobsterzelda in 2020 to force the object map to always be visible on screen.
-- Battletoads Object RAM Viewer

require 'auxlib'

Root = 0x3C0	-- Objects start address
Offs = 0xF		-- Number of slots
lastID,lastSlot,lasti = 0,0,0
Show = false
last_draw = false
last_keys = input.get()

-- Instert anything to check
-- You can check for single bit matches applying AND masks
Highlight = {
--	ID,		Attr,	 Val,	Color,		  Opr
	{0x22, "Anim_2", 0x55, 	"0 0 150",    "EQL"},	-- Respawner/Warp (Event Set)
	{0x7E, "VarFlg", 0x7F, 	"0 150 0",    "GRT"},	-- Dark Queen/Game End (Event Call)
	{0x7F, "Cntr_2", 0x7F, 	"150 0 0",    "GRT"},	-- Level End
	{0x46, "VarFlg", 0x7F, 	"150 125 0",  "GRT"},	-- Running Rat/Level End (Event Call)
	{0x01, "",		 0, 	"32 32 32",   "NON"},	-- Player 1/??? (Event ???)
	{0x02, "",		 0, 	"64 64 64",   "NON"},	-- Player 2/??? (Event ???)
	{0x4F, "",		 0, 	"125 75 0",   "NON"},	-- Exit Hole/Level Stage End (Event Call)
	{0x44, "",		 0, 	"150 150 150","NON"},	-- Destroyer/Clear Object (Event Call)
	{0x42, "",		 0, 	"125 125 125","NON"},	-- Positioner/Set Coordinates (Event Call)
	{0x41, "",		 0, 	"150 150 0",  "NON"}	-- CheckPoint/Invoke Objects (Event Call)
	--0x4 - clear sprite
	--...
}

-- Whole Object RAM block
Attribs = {
--  "Name", offset
	"ID",     -- 0
	"Anim_1", -- 1
	"Cntr_1", -- 2
	"Xpos_H", -- 3
	"Xpos_L", -- 4
	"Ypos_H", -- 5
	"Ypos_L", -- 6
	"Zpos_H", -- 7
	"Zpos_L", -- 8
	"Xsub",   -- 9
	"Ysub",   -- 10
	"Zsub",   -- 11
	"Zshad",  -- 12
	"Xshad",  -- 13
	"Yshad",  -- 14
	"Flag",   -- 15
	"State",  -- 16
	"Zspd",   -- 17
	"Unk_1",  -- 18
	"Cntr_2", -- 19
	"Unk_2",  -- 20 
	"HitID",  -- 21
	"HitTmr", -- 22
	"HP",     -- 23
	"Linked", -- 24
	"Linker", -- 25
	"AnmTmr", -- 26
	"Unk_3",  -- 27
	"Xspd",   -- 28
	"DthTmr", -- 29
	"Anim_2", -- 30
	"Target", -- 31
	"VarFlg", -- 32
	"Unk_4",  -- 33
	"EndTmr" -- 34
}

function DrawMatrix()
	-- Matrix
	mat = iup.matrix {
		lastCol=0, lastLin = 0,
		readonly="YES", hidefocus="YES",
		numcol=Offs, numlin=#Attribs,
		numcol_visible=Offs, numlin_visible=Offs,
		width0="30", widthDef="10", heightDef="7"
	};

	-- Headers BG color
	for c=0,#Attribs do
		for l=0,Offs do
			mat["bgcolor".. 0 ..":".. l] = "80 0 0"
			mat["bgcolor".. c ..":".. 0] = "80 0 0"
		end
	end

	-- Line headers
	for i,v in pairs(Attribs) do
		mat:setcell(i,0,v)
	end;

	-- Column headers
	for i=1, Offs do
		mat:setcell(0,i,i)
	end;

	-- Table colors
	mat.bgcolor = "0 0 0"
	mat.fgcolor = "255 255 255"

	-- Dialog name and pos
	dialogs = 1
	handles[dialogs] = iup.dialog{
		iup.vbox{mat,iup.fill{}},
		title="Battletoads - Object Attribute Viewer",
		size="295x443"
	};
	handles[dialogs]:showxy(iup.CENTER, iup.CENTER)

	function mat:click_cb(lin,col,r)
		if lin == 0 then
			self["fgcolor*:"..self.lastCol] = "255 255 255"
			self["fgcolor"..self.lastLin..":*"] = "255 255 255"
			self.lastCol = col
			self["fgcolor*:"..col] = "255 180 0"
		elseif col == 0 then
			self["fgcolor"..self.lastLin..":*"] = "255 255 255"
			self["fgcolor*:"..self.lastCol] = "255 255 255"
			self.lastLin = lin
			self["fgcolor"..lin..":*"] ="255 180 0"		
		end
		mat.redraw = "C1:15"
		return IUP_DEFAULT
	end
end

function ToBin8(Num,Switch)
-- 1 byte to binary converter by feos, 2012
-- Switch: "s" for string, "n" for number
	if Num > 0 then 
		Bin = ""
		while Num > 0 do
			Bin = (Num % 2)..Bin
			Num = math.floor(Num / 2)
		end
		Low = string.format("%04d",(Bin % 10000))
		High = string.format("%04d",math.floor(Bin / 10000))
		
		if Switch == "s" then return High.." "..Low
		elseif Switch == "n" then return Bin
		else return "Wrong Switch parameter!\nUse \"s\" or \"n\"."
		end
	else
		if Switch == "s" then return "0000 0000"
		elseif Switch == "n" then return 0
		else return "Wrong Switch parameter!\nUse \"s\" or \"n\"."
		end
	end
end

-- Set Highlight to Matrix
function SetHighLight(param, Slot, i, ID, v, Address, Val, DoColor, DoText, DoPause)
	if Show then
		mat["bgcolor*:"..Slot] = param[4]
		if DoColor then mat["bgcolor"..i..":*"] = param[4] end
	end
	if DoText then gui.text(1, 1, string.format(
		"ID%d: $%2X %s: $%2X = $%02X : %s",
		Slot,ID,v,Address,Val,ToBin8(Val,"s")
	)) end
	lastID = ID
	lastSlot = Slot
	lasti = i
	if DoPause and (Val == param[3]) then emu.pause() end	-- We need do it in other way!
end

-- Values calculation
function DoAll()
	keys = input.get()
	Show = true
	
	if Show and not last_draw then DrawMatrix() end
	
	if Show then Btext = "Hide\nRAM"; Bcolor = "#00ff0088"
	else Btext = "See\nRAM"; Bcolor = "#0000ff88"	
	end
	gui.box(225,205,252,230,Bcolor)
	gui.text(230,210,Btext,"white","black")
	
	for Slot = 1, Offs do
		ID = memory.readbyte(0x3c1+Slot-1)
		for i,v in ipairs(Attribs) do			
			Address = (Root+(i-1)*Offs+Slot)
			Val = memory.readbyte(Address)
			if Show then mat:setcell(i,Slot,string.format("%02X",Val)) end
			
			for _,param in ipairs(Highlight) do
				if param[5] == "EQL" then
					if (ID == param[1] or ID == param[1] + 0x80)
					and v == param[2] and Val == param[3] then SetHighLight(
						param, Slot, i, ID, v, Address, Val, true, true, false
					)
					end
				elseif param[5] == "GRT" then
					if (ID == param[1] or ID == param[1] + 0x80)
					and v == param[2] and Val > param[3] then SetHighLight(
						param, Slot, i, ID, v, Address, Val, true, true, false
					)
					end
				elseif (ID == param[1] or ID == param[1] + 0x80) then SetHighLight(
					param, Slot, i, ID, v, Address, Val, false, false, false
				)
				end
				if memory.readbyte(0x3c1+lastSlot-1) ~= lastID then
					if Show then 
						mat["bgcolor*:"..lastSlot] = "0 0 0"
						mat["bgcolor"..lasti..":*"] = "0 0 0"
					end
					gui.text(0,0, "")
					lastID = 0
				end
			end
		end
	end
	if Show then mat.redraw = "C1:15"; last_draw = true
	else last_draw = false
	end
	last_keys = keys
end

emu.registerafter(DoAll)
