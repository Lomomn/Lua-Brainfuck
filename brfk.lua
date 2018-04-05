--[[
    https://esolangs.org/wiki/Brainfuck

    Command     Description
    >           Move the pointer to the right
    <           Move the pointer to the left
    +           Increment the memory cell under the pointer
    -           Decrement the memory cell under the pointer
    .           Output the character signified by the cell at the pointer
    ,           Input a character and store it in the cell at the pointer
    [           Jump past the matching ] if the cell under the pointer is 0
    ]           Jump back to the matching [ if the cell under the pointer is nonzero
]]--
local shouldPrint, showSeen, shouldStep, maxSteps = false,false,false,nil
if arg[1] == nil then error('No file or code provided') end
local file = io.open(arg[1]) or (function() local f = io.tmpfile() f:write(arg[1]) return f end)()
local cells, curCell, bO, seeking, index, seen, steps = {[1]=0},1,{},false,0,'',0
function check() if cells[curCell]==nil then table.insert(cells,0) end end
local commands = {
    ['>'] = function() if seeking then return end curCell = curCell+1 check() end,
    ['<'] = function() if seeking then return end curCell = curCell - (curCell>1 and 1 or 0)  end,
    ['+'] = function() if seeking then return end 
        cells[curCell] = (cells[curCell]<256 and cells[curCell]+1 or 0) end,
    ['-'] = function() if seeking then return end 
        cells[curCell] = (cells[curCell]>0 and cells[curCell]-1 or 0) end,
    ['.'] = function() if seeking then return end io.write(string.char(cells[curCell])) end,
    [','] = function() if seeking then return end cells[curCell] = string.byte(io.read()) end,
    ['['] = function() if seeking then return end
        if cells[curCell] == 0 then 
            seeking = true 
        else
            table.insert(bO, index) 
        end
        end,
    [']'] = function() 
        seeking = false
        if cells[curCell] ~= 0 then
            index = table.remove(bO)-1
            seen = string.sub(seen, 1,index)
        else
            table.remove(bO)
        end
    end}

local char = nil
repeat
    steps = steps + 1
    file:seek('set',index)
    char, index = file:read(1), index+1
    if type(commands[char])=='function' then commands[char]() end
    
    if index>#seen then seen = seen .. (char~=nil and char or '') end
    
    local cellView = ''
    for i,c in ipairs(cells) do 
        local s = tostring(c)
        if i == curCell then s = '['..s..']' end
        cellView = cellView .. s .. (i==#cells and '' or ', ')  
    end
    
    local bof = ''
    for i,c in ipairs(bO) do bof = bof .. tostring(c) .. ',' end
    if shouldPrint then print(char, index, cellView, showSeen and seen or '', seeking, curCell, steps, 'bof',bof) end
    if shouldStep then io.read() end
    if maxSteps~=nil and steps == maxSteps then char = nil end
until char == nil
file:close()