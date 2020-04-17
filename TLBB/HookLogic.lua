--io.write("Waiting for debug hook...")
--local str = io.read()

--package.cpath = "W:\\?.dll"
require "Hook"
require "TLBB.StateScripts"

-- test love.enet
--require "love"
--local enet = require "enet"


---------------------------------------------------------------------
-- some global configs

g_InputUseDriver = false
g_mainGameWnd = nil
g_theSharedTable = nil

---------------------------------------------------------------------
g_UpdateTime =
{
	preTime = 0,
	curTime = 0,
	totalTime = 0
}

function UpdateTimeAdvance(robot, mostMS)
	g_UpdateTime.curTime = Wolves.GetCurTime()
	local dtTime = g_UpdateTime.curTime - g_UpdateTime.preTime
	g_UpdateTime.preTime = g_UpdateTime.curTime
	
	if dtTime < mostMS then
		Wolves.Sleep(mostMS - dtTime)
	end
	
	g_UpdateTime.totalTime = g_UpdateTime.totalTime + dtTime
	
	return dtTime
end

---------------------------------------------------------------------
function SleepWithSnapshot(robot, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		if g_mainGameWnd ~= nil then
			robot:TakeSnapshotWindow(g_mainGameWnd);
		end
		
		Wolves.Sleep(30)
		timePassed = timePassed + 30
	end
end

---------------------------------------------------------------------
function IsSubSceneMatched_InTime(robot, subScene, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		local rcOuts = robot:IsSubSceneMatched(subScene)
		if (rcOuts:Size() ~= 0) then
			return true, rcOuts;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

function IsAnySubSceneMatched_InTime(robot, subScenes, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		local rcOuts = robot:IsAnySubSceneMatched(subScenes)
		if (rcOuts:Size() ~= 0) then
			return true, rcOuts;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

function IsSubSceneMatchedInRect_InTime(robot, subScene, rect, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		local rcOuts = robot:IsSubSceneMatchedInRect(subScene)
		if (rcOuts:Size() ~= 0) then
			return true, rcOuts;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

function IsPixelMatched_InTime(robot, posStart, offSetX, offSetY, pixelCount, rgb, rgbT, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		if robot:IsPixelMatched(posStart, offSetX, offSetY, pixelCount, rgb, rgbT) then
			return true;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

---------------------------------------------------------------------
function ForegroundClick(robot, x, y)

	robot:InputForegroundMouseMove(g_mainGameWnd, g_InputUseDriver, x, y, false)
	Wolves.Sleep(10)
	
	-- left button down
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, 0, true, false)

	Wolves.Sleep(10)

	-- left button up
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, 0, false, false)
end

function ForegroundPressKey(robot, vk)
	robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, vk, false, true, false)
	Wolves.Sleep(2)
	robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, vk, false, false, false)
end

function BackgroundPressKey(robot, vk)
	robot:InputKeyEvent(g_mainGameWnd, vk, true)
	Wolves.Sleep(2)
	robot:InputKeyEvent(g_mainGameWnd, vk, false)
end

---------------------------------------------------------------------
function RobotRun(robot, msDelta)

	if g_mainGameWnd ~= nil and g_mainGameWnd:IsValid() then
		local gs = robot:TakeSnapshotWindow(g_mainGameWnd);

		--if gs ~= nil then
			--print("Save image...")
			--gs:SaveToFile("E:/" .. iCount ..".png")
			--iCount = iCount + 1
			--gs:ShowDebugWindow("gs")
			--GameScene.s_WaitKey(1000)
		--end

	end

	StateManager:Update(robot, msDelta)
	
end

---------------------------------------------------------------------
-- 这些Log函数只在lua里面使用
-- 因为是在线程里面调用，需要使用SendMessageToMainThread将日志输出到Log窗口
function LogDebug(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = EnumLogLevel.eDebug
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogDebug(content)
end

function LogInfo(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = EnumLogLevel.eInfo
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogInfo(content)
end

function LogWarn(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = EnumLogLevel.eWarn
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogWarn(content)
end

function LogError(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = EnumLogLevel.eError
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)

	-- to log to file
	Wolves.LogError(content)
end

function LogFatal(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = EnumLogLevel.eFatal
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)

	-- to log to file
	Wolves.LogFatal(content)
end

---------------------------------------------------------------------
function main()

	-- test love.enet
	--local host = enet.host_create("localhost:6789")

	LogInfo("Enter HookLogic...")

	local robot = Wolves.GetRobot()
	LogInfo("Wolves.GetRobot()")
	

	g_mainGameWnd = Window()
	
	g_UpdateTime.preTime = Wolves.GetCurTime()
	g_UpdateTime.curTime = g_UpdateTime.preTime
	
	StateManager:ChangeState(robot, StateManager.stateUnknown)
	
	local bRun = true
	while bRun do
	
		local dtTime = UpdateTimeAdvance(robot, 50)

		g_theSharedTable = Wolves.SharedManager.AcquireSharedTable(g_theSharedTableName)
		assert(g_theSharedTable)

		RobotRun(robot, dtTime)
		
		local st = Wolves.SharedManager.FetchCurThreadMessage()
		if st ~= nil then
			if st.type == "Stop" then
				LogInfo("Received Stop msg...")
				StateManager:ChangeState(robot, StateManager.stateUnknown)
			elseif st.type == "Quit" then
				LogInfo("Received Quit msg...")
				bRun = false
			end
		end
	end

	robot:StopHookWindow();

end

main()
