require "imgui"
require "Hook"
require "TLBB.TypeDefine"

local robot = nil
local bQuitApp = false
local bShowLogs = true
local logWindowHeight = 250
local theLogicThreadName = "Thread_Game"
local logLevel = EnumLogLevel.eDebug

local gameWndArray = nil
local gameWndSelected = nil

local clearColor = { 0.2, 0.2, 0.2 }

local guiOpts = Wolves.SharedManager.NewSharedTable()
guiOpts.started = false
guiOpts.paused = false
guiOpts.gameWndHandle = 0
guiOpts.subModule = EnumSubModule.eCombat
guiOpts.combat = {}
guiOpts.combat.lowHealthEnabled = false
guiOpts.combat.lowHealth = 3
guiOpts.combat.keyHealth = EnumKeys.F8

guiOpts.combat.lowQiEnabled = false
guiOpts.combat.lowQi = 5
guiOpts.combat.keyQi = EnumKeys.F9

guiOpts.combat.lowBBEnabled = false
guiOpts.combat.lowBB = 4
guiOpts.combat.keyBB = EnumKeys.F10

guiOpts.combat.targetEnabled = false
--guiOpts.combat.keyTarget = EnumKeys.F1
guiOpts.combat.freqTarget = 1
guiOpts.combat.modeTarget = 2

guiOpts.combat.keys = {
{logickey = EnumKeys.F1, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F2, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F3, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F4, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F5, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F5, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F7, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F8, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F9, freq = 10, checked = false, cur = 0},
{logickey = EnumKeys.F10, freq = 10, checked = false, cur = 0},
}

--
-- GUIs
--

----[[
---------------------------------------------------------------------
-- 图形化Log窗口, 采用imgui实现
-- 使用方法，主线程调用:
--  theAppLog.AddLog("Hello world");
--  theAppLog.Draw("title");
local theAppLog = 
{
    Buf = "",
    ScrollToBottom = true,
	LogLevel = EnumLogLevel.eDebug,

    Clear = function(self)
		self.Buf = ""
	end,

    AddLog = function(self, content)
		self.Buf = self.Buf .. os.date("%H:%M:%S ", os.time()) .. content .. "\n"
	end,
	
	SetLogLevel = function(self, level)
		self.LogLevel = level
	end,
	
	AddLog_Debug = function(self, content)
		if self.LogLevel <= EnumLogLevel.eDebug then
			self:AddLog("[Debug] " .. content);
		end
	end,

	AddLog_Info = function(self, content)
		if self.LogLevel <= EnumLogLevel.eInfo then
			self:AddLog("[Info ] " .. content);
		end
	end,

	AddLog_Warn = function(self, content)
		if self.LogLevel <= EnumLogLevel.eWarn then
			self:AddLog("[Warn ] " .. content);
		end
	end,

	AddLog_Error = function(self, content)
		if self.LogLevel <= EnumLogLevel.eFatal then
			self:AddLog("[Error] " .. content);
		end
	end,

	AddLog_Fatal = function(self, content)
		if self.LogLevel <= EnumLogLevel.eError then
			self:AddLog("[Fatal] " .. content);
		end
	end,

    Draw = function(self, title, open)
		imgui.SetNextWindowPos(5, love.graphics.getHeight() - logWindowHeight)
        imgui.SetNextWindowSize(love.graphics.getWidth() - 10, logWindowHeight, "imguiCond_Always");
        
		imgui.Begin(title, true, { "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoTitleBar" });
        if (imgui.Button("清除")) then
			self:Clear();
		end
        
		imgui.SameLine();
        local copy = imgui.Button("复制");
        imgui.Separator();
		
        imgui.BeginChild("scrolling", 0, 0, false, "imguiWindowFlags_HorizontalScrollbar");
			if copy then
				imgui.LogToClipboard();
			end

			imgui.TextUnformatted(self.Buf);

			if (self.ScrollToBottom) then
				imgui.SetScrollHere(1.0);
			end
			
        imgui.EndChild();
        
		imgui.End();
    end
}

---------------------------------------------------------------------
-- Called from C, do not use in lua
function G_CalledFromC_AppAddLog(level, content)
	theAppLog:AddLog("[".. level .. "] " .. content);
end
--]]

function FindAllGameWnds()

	--gameWndArray = Window.s_FindWindow("", "TianLongBaBu WndClass")
	--gameWndArray = Window.s_FindWindow("", "Notepad")
	gameWndArray = Window.s_FindWindow("example-00-helloworldRelease", "")

	local count = gameWndArray:Size()
	if count ~= 0 then
		Wolves.LogInfo("Find all TLBB windows: " .. tostring(count))

		if gameWndSelected == nil then
			gameWndSelected = gameWndArray:At(1)
		else
			local found = false
			for i = 1, gameWndArray:Size() do
				local wnd = gameWndArray:At(i)
				if wnd:GetHandle() == gameWndSelected:GetHandle() then
					found = true
					break
				end
			end
			
			if not found then
				gameWndSelected = gameWndArray:At(1)
			end
		end
		
	else
		gameWndSelected = nil
	end
	
end


function GUI_Toolbar()

    imgui.SetNextWindowPos(0, 0, "imguiCond_Always")
	imgui.SetNextWindowSize(love.graphics.getWidth(), 30)
	imgui.Begin("MainControl", true, { "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize"
									, "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoScrollbar" });

	local runOldState = guiOpts.started
	guiOpts.started = imgui.Checkbox("运行", guiOpts.started)
	if guiOpts.started and runOldState == false then
		if gameWndArray ~= nil and gameWndSelected ~= nil then
			theAppLog:AddLog_Info("运行辅助");
			guiOpts.gameWndHandle = gameWndSelected:GetHandle()

			-- 发消息给辅助线程
			local t = Wolves.SharedManager.NewSharedTable()
			t.type = "Start"
			Wolves.SharedManager.SendMessageToThread(theLogicThreadName, t)
			
			gameWndSelected:SetForegroundWindow()
		else
			guiOpts.started = false
			theAppLog:AddLog_Error("当前没有天龙八部游戏在运行！");
		end
	elseif not guiOpts.started and runOldState then
		if guiOpts.paused then
			Wolves.SharedManager.ResumeThread(theLogicThreadName)
			guiOpts.paused = false
		end

		theAppLog:AddLog_Info("停止辅助");
		-- 发消息给辅助线程
		local t = Wolves.SharedManager.NewSharedTable()
		t.type = "Stop"
		Wolves.SharedManager.SendMessageToThread(theLogicThreadName, t)
	end

	local pauseOldState = guiOpts.paused
	imgui.SameLine()
	guiOpts.paused = imgui.Checkbox("暂停", guiOpts.paused)
	if pauseOldState ~= guiOpts.paused then
		if guiOpts.paused then
			if guiOpts.started then
				Wolves.SharedManager.PauseThread(theLogicThreadName)
				theAppLog:AddLog_Info("暂停辅助");
			else
				guiOpts.paused = false
			end
		else
			Wolves.SharedManager.ResumeThread(theLogicThreadName)
			theAppLog:AddLog_Info("取消暂停");

			gameWndSelected:SetForegroundWindow()
		end
	end

	imgui.SameLine()
	imgui.PushItemWidth(80)
	if guiOpts.started then
		imgui.Text(TableSubModuleCap[guiOpts.subModule]);
	else
		guiOpts.subModule = imgui.Combo("", guiOpts.subModule, TableSubModuleCap, #TableSubModuleCap);
	end
	imgui.PopItemWidth()

	imgui.SameLine()
	bShowLogs = imgui.Checkbox("日志窗口", bShowLogs)
	
	imgui.SameLine()
	local logLevelOld = logLevel
	imgui.PushItemWidth(70)
	logLevel = imgui.Combo("日志等级", logLevel, TableLogLevelCap, #TableLogLevelCap);
	imgui.PopItemWidth()
	if logLevel ~= logLevelOld then
		Wolves.SetLogLevel(logLevel)
		theAppLog:SetLogLevel(logLevel)
	end

	imgui.SameLine()
	imgui.Dummy(50, 10)
	imgui.SameLine()
    bQuitApp = imgui.Button("退出辅助")
	if bQuitApp and guiOpts.started then
		guiOpts.started = false
		guiOpts.paused = false
	end

    imgui.End();

end

function GUI_Tabs()
	
    imgui.SetNextWindowPos(0, 30)
	if bShowLogs then
		imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight() - 32 - logWindowHeight)
	else 
		imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight() - 32)
	end


	imgui.Begin("Tabs Window", true, { "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoTitleBar" });
	
	imgui.BeginTabBar("#Funcs");

	imgui.DrawTabsBackground();

	if imgui.AddTab("系统") then
		if gameWndArray ~= nil then
		
			imgui.Text("运行中的游戏：")

			if not guiOpts.started then
				imgui.SameLine()
				if imgui.Button("刷新") then
					FindAllGameWnds();
				end
			end
			
			local curSel = 0
			local wndList = {}
			local wndCapList = {}
			for i = 1, gameWndArray:Size() do
				local wnd = gameWndArray:At(i)
				if wnd:IsValid() then
					wndList[#wndList + 1] = wnd
					wndCapList[#wndCapList + 1] = gameWndArray:At(i):GetWindowText()
					if gameWndSelected ~= nil and wnd:GetHandle() == gameWndSelected:GetHandle() then
						curSel = #wndCapList	--找到当前选中的窗口
						--theAppLog:AddLog_Info("Find:" .. tostring(wnd))
					end
				else
					--是否是当前选中的窗口?
					if gameWndSelected ~= nil and wnd:GetHandle() == gameWndSelected:GetHandle() then

						theAppLog:AddLog_Info("当前游戏窗口没了。")
						gameWndSelected = nil	--重置当前选中窗口

						--如果辅助已经开始，停止辅助
						if guiOpts.started then
							guiOpts.started = false
							guiOpts.paused = false
							guiOpts.gameWndHandle = 0

							local t = Wolves.SharedManager.NewSharedTable()
							t.type = "GameWndGone"
							-- 发消息给辅助线程
							Wolves.SharedManager.SendMessageToThread(theLogicThreadName, t)
						end
					end
				end
			end

			if #wndCapList ~= 0 then
				if curSel == 0 then
					curSel = 1
					gameWndSelected = wndList[1]
				end
				
				if guiOpts.started then
					imgui.Text(wndCapList[curSel]);
				else
					imgui.PushItemWidth(-0.8)
					local sel = imgui.Combo("", curSel, wndCapList, #wndCapList);
					imgui.PopItemWidth(100)
					--theAppLog:AddLog_Info(tostring(sel))
					if sel ~= curSel then
						gameWndSelected = wndList[sel]
						gameWndSelected:ShowWindow(9)	--SW_RESTORE
						gameWndSelected:FlashWindow()
					end
				end
			end
			

		end
	end

	if imgui.AddTab("打怪") then

		local id = 1
		local excludeKeyIndex = {}

		-----------------------------------------		
		guiOpts.combat.lowHealthEnabled = imgui.Checkbox("角色血低于", guiOpts.combat.lowHealthEnabled)

		imgui.SameLine()
		imgui.PushItemWidth(60)
		imgui.PushID(id)
		guiOpts.combat.lowHealth = imgui.Combo("按", guiOpts.combat.lowHealth, TableBloodRatioCap, #TableBloodRatioCap);
		imgui.PopID()
		imgui.PopItemWidth()

		imgui.SameLine()
		imgui.PushItemWidth(60)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.keyHealth = imgui.Combo("键", guiOpts.combat.keyHealth, TableKeysCap, #TableKeysCap);
		imgui.PopID()
		imgui.PopItemWidth()

		if guiOpts.combat.lowHealthEnabled then
			guiOpts.combat.keys[guiOpts.combat.keyHealth].checked = false
			excludeKeyIndex[#excludeKeyIndex + 1] = guiOpts.combat.keyHealth
		end

		-----------------------------------------		
		guiOpts.combat.lowQiEnabled = imgui.Checkbox("角色蓝低于", guiOpts.combat.lowQiEnabled)

		imgui.SameLine()
		id = id + 1
		imgui.PushItemWidth(60)
		imgui.PushID(id)
		guiOpts.combat.lowQi = imgui.Combo("按", guiOpts.combat.lowQi, TableBloodRatioCap, #TableBloodRatioCap);
		imgui.PopID()
		imgui.PopItemWidth()

		imgui.SameLine()
		imgui.PushItemWidth(60)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.keyQi = imgui.Combo("键", guiOpts.combat.keyQi, TableKeysCap, #TableKeysCap);
		imgui.PopID()
		imgui.PopItemWidth()

		if guiOpts.combat.lowQiEnabled then
			guiOpts.combat.keys[guiOpts.combat.keyQi].checked = false
			excludeKeyIndex[#excludeKeyIndex + 1] = guiOpts.combat.keyQi
		end

		-----------------------------------------		
		guiOpts.combat.lowBBEnabled = imgui.Checkbox("宠物血低于", guiOpts.combat.lowBBEnabled)

		imgui.SameLine()
		imgui.PushItemWidth(60)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.lowBB = imgui.Combo("按", guiOpts.combat.lowBB, TableBloodRatioCap, #TableBloodRatioCap);
		imgui.PopID()
		imgui.PopItemWidth()

		imgui.SameLine()
		imgui.PushItemWidth(60)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.keyBB = imgui.Combo("键", guiOpts.combat.keyBB, TableKeysCap, #TableKeysCap);
		imgui.PopID()
		imgui.PopItemWidth()

		if guiOpts.combat.lowBBEnabled then
			guiOpts.combat.keys[guiOpts.combat.keyBB].checked = false
			excludeKeyIndex[#excludeKeyIndex + 1] = guiOpts.combat.keyBB
		end

		-----------------------------------------		
		guiOpts.combat.targetEnabled = imgui.Checkbox("选怪, 按<Ctrl>+<Tab> 间隔", guiOpts.combat.targetEnabled)

--[[
		imgui.SameLine()
		imgui.PushItemWidth(60)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.keyTarget = imgui.Combo("间隔(秒)", guiOpts.combat.keyTarget, TableKeysCap, #TableKeysCap);
		imgui.PopID()
		imgui.PopItemWidth()
--]]

		imgui.SameLine()
		imgui.PushItemWidth(80)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.freqTarget = imgui.InputInt("秒, 模式", guiOpts.combat.freqTarget)
		if guiOpts.combat.freqTarget <= 0 then
			guiOpts.combat.freqTarget = 1
		end
		imgui.PopID()
		imgui.PopItemWidth()

		imgui.SameLine()
		imgui.PushItemWidth(100)
		id = id + 1
		imgui.PushID(id)
		guiOpts.combat.modeTarget = imgui.Combo(" ", guiOpts.combat.modeTarget, TableTargetModeCap, #TableTargetModeCap);
		imgui.PopID()
		imgui.PopItemWidth()

--[[
		if guiOpts.combat.targetEnabled then
			guiOpts.combat.keys[guiOpts.combat.keyTarget].checked = false
			excludeKeyIndex[#excludeKeyIndex + 1] = guiOpts.combat.keyTarget
		end
--]]
		-----------------------------------------
		imgui.PushItemWidth(100)
		imgui.LabelText("间隔(秒)", "按")
		imgui.PopItemWidth()
		for k = 1, #guiOpts.combat.keys do
			if not IsInTable(excludeKeyIndex, k) then
				local item = guiOpts.combat.keys[k]
				local oldCheck = item.checked
				item.checked = imgui.Checkbox(TableKeysCap[k], item.checked)
				if item.checked and not oldCheck then
					item.cur = 0
				end
				
				imgui.SameLine()
				imgui.PushItemWidth(100)
				imgui.PushID(k)
				item.freq = imgui.InputInt("", item.freq)
				if item.freq <= 0 then
					item.freq = 1
				end
				imgui.PopID()
				imgui.PopItemWidth()
			end
		end
	end

	if imgui.AddTab("种植") then
		imgui.Text("Tab 3")
	end

	imgui.EndTabBar();

	if bShowLogs then
		theAppLog:Draw("Log", true);
	end
	
	imgui.End();

end


--
-- LOVE callbacks
--
function love.load(arg)
	imgui.AddFontFromFileTTF("simhei.ttf", 16)
	theAppLog:AddLog("[Info ] AddFontFromFileTTF");

----[[
	if not Wolves.Initialize("TLBB") then
		print("Wolves.Initialize() failed!")
		return
	else
		Wolves.LogInfo("Wolves.Initialize() OK")

		robot = Wolves.GetRobot()

		-- Initialize() Params: enableMonitorWindow, useInputDriver
		-- InitializeEx() Params: useInputDriver, PositionMonitor, SizeMonitor, ChildWnd
		if not robot:Initialize(false, false) then
			Wolves.LogError("robot:Initialize() failed!")
			return
		end
		Wolves.LogInfo("robot:Initialize() OK")

		FindAllGameWnds();

		-- 共享界面设定数据
		Wolves.SharedManager.ShareSharedTable(guiOpts, g_theSharedTableName)
		theAppLog:AddLog_Info(g_theSharedTableName .. "is shared.");

		-- 启动辅助线程
		if not Wolves.SharedManager.CreateThread(theLogicThreadName, "TLBB/HookLogic.lua") then
			Wolves.LogError("Wolves.SharedManager.CreateThread() failed!")
		else
			theAppLog:AddLog_Info("Wolves.SharedManager.CreateThread()");
		end
		
	end
	
--]]	
	
end

function love.update(dt)
    imgui.NewFrame()

----[[
	Wolves.Update(dt)
	
	-- 收到辅助线程消息
	local st = Wolves.SharedManager.FetchCurThreadMessage()
	if st ~= nil and st.type == "Log" then
		if st.level == EnumLogLevel.eDebug  then
			theAppLog:AddLog_Debug(st.data)
		elseif st.level == EnumLogLevel.eInfo then
			theAppLog:AddLog_Info(st.data)
		elseif st.level == EnumLogLevel.eError then
			theAppLog:AddLog_Error(st.data)
		elseif st.level == EnumLogLevel.eFatal then
			theAppLog:AddLog_Fatal(st.data)
		end
	end
--]]		

end

function love.draw()

    -- Menu
	--[[
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("菜单") then
            bQuitApp = imgui.MenuItem("退出")
            imgui.EndMenu()
        end
        imgui.EndMainMenuBar()
    end
	--]]--
	
	GUI_Toolbar();
	GUI_Tabs();	
	

    love.graphics.clear(clearColor[1], clearColor[2], clearColor[3])
    imgui.Render();

	if bQuitApp then
		
----[[
		local t = Wolves.SharedManager.NewSharedTable()
		t.type = "Quit"
		-- 发消息给辅助线程
		Wolves.SharedManager.SendMessageToThread(theLogicThreadName, t)
--]]		

		love.window.close()
		love.quit()
	end
end

function love.quit()
    imgui.ShutDown();

----[[
	-- wait robot:StopHookWindow();
	Wolves.Sleep(3000)

	robot:Finalize();
	Wolves.Finalize();
--]]		

end

--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keypressed(key)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end