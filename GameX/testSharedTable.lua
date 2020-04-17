require "Hook"

--这几个函数不需要调用Wolves.Initialize()也能用
--Wolves.SharedManager.NewSharedTable()
--Wolves.SharedManager.DumpSharedTable()
--Wolves.SharedManager.SharedTable_pairs()
--Wolves.SharedManager.SharedTable_ipairs()
if not Wolves.Initialize("R6") then
	print("Wolves.Initialize() failed!")
	return
end

print("\n1:")

local t = Wolves.SharedManager.NewSharedTable()

local subT = {1, 2, 3}
t.hello = {world = true, "one", "two", 3, False = false, testT = {true, 3, testttt = {"Alpha", nil, 6}}} 

print("\n2:")

print(t.hello[1], t.hello[2])

t.subT = subT
t.hello[0] = nil

print("\nDumpSharedTable(t, false):")
Wolves.SharedManager.DumpSharedTable(t, false)

print("\n3:")
function dumpSTable(tbl)
	for k,v in Wolves.SharedManager.SharedTable_pairs(tbl) do
		if type(v) == "userdata" or type(v) == "table" then
			print(k)
			dumpSTable(v)
		else
			print(k, v)
		end
	end
end

t[0] = 10
t[1] = nil
t[2] = 20
print("\ndumpSTable(t):")
dumpSTable(t)

print("\n4:")
function dumpArraySTable(tbl)
	for k,v in Wolves.SharedManager.SharedTable_ipairs(tbl) do
		if type(v) == "userdata" or type(v) == "table" then
			print(k)
			dumpArraySTable(v)
		else
			print(k, v)
		end
	end
end

print("\ndumpArraySTable(t):")
dumpArraySTable(t)


print("\nDumpSharedTable(t, true):")
Wolves.SharedManager.DumpSharedTable(t, true)


print("\n5:")

--下面几个函数需要调用Wolves.Initialize("R6")
--ShareSharedTable(), AcquireSharedTable(), CreateThread(), SendMessageToThread(), FetchCurThreadMessage()

--跨线程共享
Wolves.SharedManager.ShareSharedTable(t, "theSharedTable")
--当然自身线程也可以获取
local st = Wolves.SharedManager.AcquireSharedTable("theSharedTable")
print("\nDumpSharedTable(st, true):")
Wolves.SharedManager.DumpSharedTable(st, false)

--发送到指定线程
--Wolves.SharedManager.CreateThread("Thread_Game", "R6/HookLogic.lua")
--Wolves.SharedManager.SendMessageToThread("Thread_Game", t)
-- in Thread_Game
--local st = Wolves.SharedManager.FetchCurThreadMessage()

print("\nThe end.")


