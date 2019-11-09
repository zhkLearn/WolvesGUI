--io.write("Waiting for debug hook...")
--local str = io.read()

--package.cpath = "W:\\?.dll"
require "Hook"
require "GameX.StateScripts"

---------------------------------------------------------------------
-- some global configs

g_InputUseDriver = true
g_mainGameWnd = nil

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
	robot:TakeSnapshot()
	Wolves.Sleep(msMaxTime)
end

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

	robot:InputForegroundMouseMove(g_mainGameWnd, g_InputUseDriver, x, y)
	Wolves.Sleep(50)
	
	-- left button down
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, true, true)

	Wolves.Sleep(20)

	-- left button up
	robot:InputForegroundMouseButtonEvent(g_mainGameWnd, g_InputUseDriver, true, false)
end

---------------------------------------------------------------------
function RobotRun(robot, msDelta)

	local gs = robot:TakeSnapshot()
	--if gs ~= nil then
		--print("Save image...")
		--gs:SaveToFile("E:/1.png")
		
		--gs:ShowDebugWindow("gs")
		--GameScene.s_WaitKey(1000)
	--end

	StateManager:Update(robot, msDelta)
	
end

---------------------------------------------------------------------
-- 这些Log函数只在lua里面使用
-- 因为是在线程里面调用，需要使用SendMessageToMainThread将日志输出到Log窗口
function LogDebug(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Debug"
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogDebug(content)
end

function LogInfo(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Info "
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogInfo(content)
end

function LogWarn(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Warn "
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogWarn(content)
end

function LogError(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Error"
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)

	-- to log to file
	Wolves.LogError(content)
end

---------------------------------------------------------------------
function main()

	LogInfo("Enter HookLogic...")

	local robot = Wolves.GetRobot()
	LogInfo("Wolves.GetRobot()")

	
	-- 支持通配符*, ?
	local wndArray = Window.s_FindWindow("SHA-WKS-AC117-*", "")
	local count = wndArray:Size()
	LogInfo("Find all windows with titile is 'SHA-WKS-AC117-*': " .. tostring(count))
	
	if count ~= 0 then
		g_mainGameWnd = wndArray:At(1)
	
		-- Params: window, simple(false: hook 3d), flipY
		if not robot:HookWindow(g_mainGameWnd, true, false) then
			LogError("robot:HookWindow failed!")
		return
	end
		LogInfo("robot:HookWindow() OK")
	end


	g_UpdateTime.preTime = Wolves.GetCurTime()
	g_UpdateTime.curTime = g_UpdateTime.preTime
	
	
	StateManager:ChangeState(robot, StateManager.stateUnknown)
	
	local bRun = true
	while bRun do
	
		local dtTime = UpdateTimeAdvance(robot, 50)

		RobotRun(robot, dtTime)

		local st = Wolves.SharedManager.FetchCurThreadMessage()
		if st ~= nil and st.type == "Quit" then
			LogInfo("Received Quit msg...")
			bRun = false
		end
	end

	robot:StopHookWindow();

end

main()

--[[
函数说明： 时间单位都是毫秒。

Wolves
{
	bool Initialize(gameKey)	--例如: R6
	Finalize()
	Update(dt)
	GetRobot()	-- Robot是单例，多线程之间共享

	Sleep(int msTime)						-- [线程安全]
	int GetCurTime()						-- [线程安全]
	LogDebug(string)						-- [线程安全]
	LogInfo(string)							-- [线程安全]
	LogWarn(string)							-- [线程安全]
	LogError(string)						-- [线程安全]
	LogFatal(string)						-- [线程安全]

	-- SharedManager 函数都是线程安全的
	SharedManager
	{
		sharedTable NewSharedTable()
		bool ShareSharedTable(sharedTable, name)
		sharedTable AcquireSharedTable(name)
		DumpSharedTable(sharedTable, codeFormat)

		bool CreateThread(name)
		bool IsThreadValid(name)
		bool PauseThread(name)
		bool ResumeThread(name)
		bool AbortThread(name)
		bool SendMessageToThread(name, sharedTable)
		sharedTable FetchCurThreadMessage()
		bool SendMessageToMainThread(sharedTable)
	}
}

-- Robot函数(注意： 只有标记为[线程安全]的函数才能在所有线程里面使用)
{
	-- 这些函数需要在同一个线程里面使用
	--[
		bool Initialize(g_EnableMonitoringWindow, g_InputUseDriver)
		Finalize()
		bool HookWindow(caption, simple, bFlipY)		-- 如果simple==false, Hook 3D rendering
		StopHookWindow()
		GameScene* TakeSnapshot()
		GameScene* GetCurGameScene()

		SRectVector IsSubSceneMatched(subSceneName)
		SRectVector IsAnySubSceneMatched(StringVector subSceneNames)
		SRectVector IsSubSceneMatchedInRect(subSceneName, rect)
		bool IsPixelMatched(SSize posStart, int offSetX, int offSetY, int pixelCount, SRGB rgb, SRGB rgbT)
		bool IsGrayRect(SRect)
	--]


	bool WindowIsValid()					-- [线程安全]
	WindowShowHide(b)						-- [线程安全] true for show
	WindowSetPosition(x, y)					-- [线程安全]
	WindowMinimize(b)						-- [线程安全] true for Minimize, false for Restore
	SSize WindowGetDeskTopSize()			-- [线程安全]

	-- 后台按键操作，x, y是窗口客户区坐标。Dx游戏要前台方式。
	InputClick(x, y, bChildWnd)				-- [线程安全]
	InputHoldDown(x, y, bChildWnd)			-- [线程安全]
	InputHoldMove(x, y, bChildWnd)			-- [线程安全]
	InputHoldRelease(x, y, bChildWnd)		-- [线程安全]

	-- 前台按键操作，x, y是窗口客户区坐标
	InputForegroundMouseButtonEvent(bool useDriver, bool isLeft, bool isDown)	-- [线程安全]
	InputForegroundMouseMove(bool useDriver, int x, int y)						-- [线程安全]
	InputForegroundMouseScroll(bool useDriver, bool isUp)						-- [线程安全]
	InputForegroundKeyEvent(bool useDriver, int vk, bool isExtend, bool isDown) -- [线程安全] vk is in virtual-key code
}

--]]
