local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local lp = players.LocalPlayer

local function uh()
	local e = rs:FindFirstChild("Events")
	if e then
		local r = e:FindFirstChild("CatalogGuiRemote")
		if r then return r end
	end
	local r = rs:FindFirstChild("CatalogGuiRemote")
	if r then return r end
	for _, d in ipairs(rs:GetDescendants()) do
		if d.Name == "CatalogGuiRemote" and (d:IsA("RemoteFunction") or d:IsA("RemoteEvent")) then
			return d
		end
	end
end

local function ins()
	local e = rs:FindFirstChild("Events")
	if e then
		local r = e:FindFirstChild("ClientInspectHumanoidDescription")
		if r then return r end
	end
	local r = rs:FindFirstChild("ClientInspectHumanoidDescription")
	if r then return r end
	for _, d in ipairs(rs:GetDescendants()) do
		if d.Name == "ClientInspectHumanoidDescription" then
			return d
		end
	end
end

local rem = uh()

local function sf()
	local g = lp:FindFirstChild("PlayerGui")
	local v = g and g:FindFirstChild("ViewPlayer")
	local m = v and v:FindFirstChild("Main") and v.Main:FindFirstChild("Menu")
	return m and m:FindFirstChild("ScrollingFrame")
end

local function rgb(c)
	if typeof(c) ~= "Color3" then
		return {r = 255, g = 255, b = 255, IsRGBTable = true}
	end
	return {r = c.R * 255, g = c.G * 255, b = c.B * 255, IsRGBTable = true}
end

local function dict(d)
	local p = {
		HatAccessory = d.HatAccessory or "",
		HairAccessory = d.HairAccessory or "",
		FaceAccessory = d.FaceAccessory or "",
		BackAccessory = d.BackAccessory or "",
		FrontAccessory = d.FrontAccessory or "",
		NeckAccessory = d.NeckAccessory or "",
		ShouldersAccessory = d.ShouldersAccessory or "",
		WaistAccessory = d.WaistAccessory or "",
		Face = d.Face or 0,
		Head = d.Head or 0,
		Torso = d.Torso or 0,
		LeftArm = d.LeftArm or 0,
		RightArm = d.RightArm or 0,
		LeftLeg = d.LeftLeg or 0,
		RightLeg = d.RightLeg or 0,
		Shirt = d.Shirt or 0,
		Pants = d.Pants or 0,
		GraphicTShirt = d.GraphicTShirt or 0,
		HeadColor = rgb(d.HeadColor),
		TorsoColor = rgb(d.TorsoColor),
		LeftArmColor = rgb(d.LeftArmColor),
		RightArmColor = rgb(d.RightArmColor),
		LeftLegColor = rgb(d.LeftLegColor),
		RightLegColor = rgb(d.RightLegColor),
		HeightScale = d.HeightScale or 1,
		WidthScale = d.WidthScale or 1,
		DepthScale = d.DepthScale or 1,
		HeadScale = d.HeadScale or 1,
		BodyTypeScale = d.BodyTypeScale or 0,
		ProportionScale = d.ProportionScale or 0,
		ClimbAnimation = d.ClimbAnimation or 0,
		FallAnimation = d.FallAnimation or 0,
		IdleAnimation = d.IdleAnimation or 0,
		JumpAnimation = d.JumpAnimation or 0,
		MoodAnimation = d.MoodAnimation or 0,
		RunAnimation = d.RunAnimation or 0,
		SwimAnimation = d.SwimAnimation or 0,
		WalkAnimation = d.WalkAnimation or 0,
		MakeupItems = {},
		AccessoryRefinements = {},
		LayeredAccessories = {},
		StaticFacialAnimation = false,
	}
	pcall(function()
		local a = d:GetAccessories(true)
		if type(a) ~= "table" then return end
		local o = {}
		for _, x in ipairs(a) do
			if type(x) == "table" and x.AssetId then
				o[#o + 1] = {
					AssetId = x.AssetId,
					AccessoryType = tostring(x.AccessoryType or ""),
					Order = x.Order,
					Puffiness = x.Puffiness,
				}
			end
		end
		p.LayeredAccessories = o
	end)
	return p
end

local function ser(m, d)
	if type(m) == "table" and type(m.ToDictionary) == "function" then
		local ok, t = pcall(m.ToDictionary, m, d)
		if ok and type(t) == "table" then return t end
	end
	return dict(d)
end

local function descfrom(plr)
	if not plr then return end
	local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if h then
		local ok, live = pcall(function()
			return h:GetAppliedDescription()
		end)
		if ok and live and live:IsA("HumanoidDescription") then
			return live, h.RigType
		end
	end
	local ok, d = pcall(function()
		return players:GetHumanoidDescriptionFromUserId(plr.UserId)
	end)
	if ok and d and d:IsA("HumanoidDescription") then
		return d, Enum.HumanoidRigType.R15
	end
end

local function grab(s)
	local w = s:FindFirstChild("WearOutfit")
	local plr, mod, desc, rig

	if w and getconnections and getupvalues then
		local c = getconnections(w.Activated)
		local f = c[1] and c[1].Function
		if type(f) ~= "function" then
			c = getconnections(w.MouseButton1Click)
			f = c[1] and c[1].Function
		end
		if type(f) == "function" then
			local u = getupvalues(f)
			plr, mod, desc, rig = u[2], u[3], u[4], u[5]
			for _, v in pairs(u) do
				if typeof(v) == "Instance" and v:IsA("Player") then
					plr = v
				elseif typeof(v) == "Instance" and v:IsA("HumanoidDescription") then
					desc = v
				elseif type(v) == "table" and type(v.ToDictionary) == "function" then
					mod = v
				elseif typeof(v) == "EnumItem" and v.EnumType == Enum.HumanoidRigType then
					rig = v
				end
			end
		end
	end

	if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
		return
	end

	local live, lrig = descfrom(plr)
	if live then
		desc, rig = live, lrig
	end

	if typeof(desc) ~= "Instance" or not desc:IsA("HumanoidDescription") then
		return
	end

	return plr, mod, desc, typeof(rig) == "EnumItem" and rig or Enum.HumanoidRigType.R15
end

local function go(d, m, r)
	rem = rem or uh()
	if not rem then return end
	local p = {
		Action = "CreateAndWearHumanoidDescription",
		Properties = ser(m, d),
		RigType = r or Enum.HumanoidRigType.R15,
	}
	pcall(function()
		if rem:IsA("RemoteFunction") then
			rem:InvokeServer(p)
		else
			rem:FireServer(p)
		end
	end)
end

local function view(plr, d)
	if not plr or not d then return end
	local title = "@" .. plr.Name .. "'s Current Outfit"
	local payload = {
		HumanoidDescription = d,
		Title = title,
	}

	local ev = ins()
	if ev then
		pcall(function()
			if ev:IsA("BindableEvent") then
				ev:Fire(payload)
			elseif ev.Fire then
				ev:Fire(payload)
			end
		end)
		pcall(function()
			if ev:IsA("BindableEvent") then
				ev:Fire(d, title)
			elseif ev.Fire then
				ev:Fire(d, title)
			end
		end)
		return
	end

	local vb = sf() and sf():FindFirstChild("ViewOutfit")
	if vb and getconnections then
		for _, c in ipairs(getconnections(vb.Activated)) do
			pcall(function()
				if c.Function then c.Function() end
			end)
		end
		for _, c in ipairs(getconnections(vb.MouseButton1Click)) do
			pcall(function()
				if c.Function then c.Function() end
			end)
		end
	end
end

local function ok()
	local s = sf()
	if not s then return false end
	local v = s:FindFirstChild("ViewOutfit")
	local w = s:FindFirstChild("WearOutfit")
	if not v or not w then return false end

	for _, n in ipairs({"StealOutfit", "ForceViewOutfit"}) do
		local o = s:FindFirstChild(n)
		if o then o:Destroy() end
	end

	local fv = v:Clone()
	fv.Name = "ForceViewOutfit"
	fv.Text = "Force View Outfit"
	fv.LayoutOrder = v.LayoutOrder + 1
	fv.Parent = s
	fv.Activated:Connect(function()
		local plr, _, d = grab(s)
		if not plr then return end
		view(plr, d)
	end)

	local st = w:Clone()
	st.Name = "StealOutfit"
	st.Text = "Steal Outfit"
	st.LayoutOrder = w.LayoutOrder + 1
	st.Parent = s
	st.Activated:Connect(function()
		local plr, m, d, r = grab(s)
		if plr then go(d, m, r) end
	end)

	return true
end

task.spawn(function()
	for _ = 1, 60 do
		if ok() then break end
		task.wait(1)
	end
end)

lp.PlayerGui.ChildAdded:Connect(function(c)
	if c.Name == "ViewPlayer" then
		task.wait(0.3)
		ok()
	end
end)

task.spawn(function()
	local uid = 1
	pcall(function()
		uid = players:GetUserIdFromNameAsync("Ockonner")
	end)

	local cb = Instance.new("BindableFunction")
	cb.OnInvoke = function(btn)
		if btn == "Discord Profile" then
			local link = "https://discord.com/users/1528740132717334563"
			if setclipboard then
				setclipboard(link)
			elseif toclipboard then
				toclipboard(link)
			end
		end
	end
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Click on someone to view the Steal Outfit buttons",
		Text = "Will not work on Xeno/Solara",
		Duration = 8,
		Button1 = "Okay",
	})
end)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "original source from @Nox",
			Text = "updated by Nox",
			Icon = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=150&h=150",
			Duration = 8,
			Button1 = "Discord Profile",
			Button2 = "bz tmr gros fdp",
			Callback = cb,
		})
	end)
end)
