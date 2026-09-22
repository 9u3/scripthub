--!strict

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local SCRIPT_MANIFEST_URL: string = "https://raw.githubusercontent.com/9u3/scripthub/refs/heads/main/scripts.json"

type ScriptEntry = {
	id: string,
	name: string,
	gameId: number?,
	description: string,
	sourceUrl: string,
}

type ManifestDocument = {
	version: number?,
	scripts: {any},
}

type ManifestState = "loading" | "ready" | "error"

local scripts: {ScriptEntry} = {}
local manifestState: ManifestState = "loading"
local manifestMessage: string = "Loading the script list..."

local function readManifestEntry(value: any, index: number): ScriptEntry
	if type(value) ~= "table" then
		error(string.format("Entry %d must be an object.", index))
	end
	if type(value.id) ~= "string" or value.id == "" then
		error(string.format("Entry %d has no valid id.", index))
	end
	if type(value.name) ~= "string" or value.name == "" then
		error(string.format("Entry %d has no valid name.", index))
	end
	if type(value.description) ~= "string" then
		error(string.format("Entry %d has no valid description.", index))
	end
	if type(value.sourceUrl) ~= "string" or not value.sourceUrl:match("^https://") then
		error(string.format("Entry %d has no valid HTTPS sourceUrl.", index))
	end
	if value.gameId ~= nil and type(value.gameId) ~= "number" then
		error(string.format("Entry %d has an invalid gameId.", index))
	end
	return {
		id = value.id,
		name = value.name,
		gameId = value.gameId,
		description = value.description,
		sourceUrl = value.sourceUrl,
	}
end

local function fetchManifest(): {ScriptEntry}
	local requestUrl: string = SCRIPT_MANIFEST_URL .. "?v=" .. tostring(os.time())
	local body: string = game:HttpGet(requestUrl)
	local decoded: any = HttpService:JSONDecode(body)
	if type(decoded) ~= "table" or type(decoded.scripts) ~= "table" then
		error("Manifest root must contain a scripts array.")
	end

	local document: ManifestDocument = decoded :: ManifestDocument
	local entries: {ScriptEntry} = {}
	local ids: {[string]: boolean} = {}
	for index: number, value: any in document.scripts do
		if type(value) ~= "table" or value.enabled ~= false then
			local entry: ScriptEntry = readManifestEntry(value, index)
			if ids[entry.id] then
				error("Duplicate manifest id: " .. entry.id)
			end
			ids[entry.id] = true
			table.insert(entries, entry)
		end
	end
	return entries
end

local function runEntry(entry: ScriptEntry): ()
	local source: string = game:HttpGet(entry.sourceUrl)
	local scriptFunction: (() -> any)?, compileError: string? = loadstring(source)
	if not scriptFunction then
		error(entry.name .. " failed to compile: " .. tostring(compileError))
	end
	scriptFunction()
end

local creatorName = game:GetService("Players"):GetNameFromUserIdAsync(546976648)
local creditsDuration = 3

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local previous = playerGui:FindFirstChild("ScriptHub")
if previous then
	previous:Destroy()
end

local palette = {
	background = Color3.fromRGB(19, 21, 25),
	surface = Color3.fromRGB(27, 30, 35),
	surfaceHover = Color3.fromRGB(36, 40, 46),
	border = Color3.fromRGB(54, 59, 66),
	text = Color3.fromRGB(235, 237, 239),
	muted = Color3.fromRGB(146, 153, 161),
	accent = Color3.fromRGB(117, 190, 154),
	danger = Color3.fromRGB(235, 132, 126),
}

local function corner(parent: Instance, radius: number): ()
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

local function stroke(parent: Instance): ()
	local item = Instance.new("UIStroke")
	item.Color = palette.border
	item.Thickness = 1
	item.Parent = parent
end

local function label(parent: Instance, value: string, size: number, color: Color3, bold: boolean): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Text = value
	item.TextColor3 = color
	item.TextSize = size
	item.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function button(parent: Instance, value: string): TextButton
	local item = Instance.new("TextButton")
	item.AutoButtonColor = false
	item.BackgroundColor3 = palette.surface
	item.Text = value
	item.TextColor3 = palette.text
	item.TextSize = 13
	item.Font = Enum.Font.GothamMedium
	item.Parent = parent
	corner(item, 7)
	return item
end

local gui = Instance.new("ScreenGui")
gui.Name = "ScriptHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local credits = Instance.new("Frame")
credits.Name = "Credits"
credits.AnchorPoint = Vector2.new(0.5, 0.5)
credits.Position = UDim2.fromScale(0.5, 0.5)
credits.Size = UDim2.new(0.92, 0, 0, 220)
credits.BackgroundColor3 = palette.background
credits.Parent = gui
corner(credits, 12)
stroke(credits)

local creditsSize = Instance.new("UISizeConstraint")
creditsSize.MaxSize = Vector2.new(420, 220)
creditsSize.Parent = credits

local creditsTitle = label(credits, "FERAL HUB", 20, palette.text, true)
creditsTitle.Position = UDim2.fromOffset(26, 43)
creditsTitle.Size = UDim2.new(1, -52, 0, 30)
creditsTitle.TextXAlignment = Enum.TextXAlignment.Center

local creditsByline = label(credits, "Created by " .. creatorName, 13, palette.muted, false)
creditsByline.Position = UDim2.fromOffset(26, 85)
creditsByline.Size = UDim2.new(1, -52, 0, 24)
creditsByline.TextXAlignment = Enum.TextXAlignment.Center

local creditsDivider = Instance.new("Frame")
creditsDivider.Position = UDim2.new(0.5, -18, 0, 124)
creditsDivider.Size = UDim2.fromOffset(36, 2)
creditsDivider.BorderSizePixel = 0
creditsDivider.BackgroundColor3 = palette.accent
creditsDivider.Parent = credits

local skipCredits = button(credits, "Skip")
skipCredits.Position = UDim2.new(0.5, -42, 1, -56)
skipCredits.Size = UDim2.fromOffset(84, 30)

local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.new(0.92, 0, 0, 420)
window.BackgroundColor3 = palette.background
window.Parent = gui
window.Visible = false
corner(window, 12)
stroke(window)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 58)
sizeConstraint.MaxSize = Vector2.new(650, 420)
sizeConstraint.Parent = window

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundTransparency = 1
header.Active = true
header.Parent = window

local title = label(header, "FERAL HUB", 15, palette.text, true)
title.Position = UDim2.fromOffset(20, 9)
title.Size = UDim2.new(1, -112, 0, 22)

local subtitle = label(header, "Scripts I made, Easy to find.", 11, palette.muted, false)
subtitle.Position = UDim2.fromOffset(20, 30)
subtitle.Size = UDim2.new(1, -112, 0, 16)

local close = button(header, "X")
close.Name = "Close"
close.Position = UDim2.new(1, -39, 0, 15)
close.Size = UDim2.fromOffset(25, 25)
close.TextSize = 20

local minimize = button(header, "-")
minimize.Name = "Minimize"
minimize.Position = UDim2.new(1, -70, 0, 15)
minimize.Size = UDim2.fromOffset(25, 25)
minimize.TextSize = 18

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(0, 57)
divider.Size = UDim2.new(1, 0, 0, 1)
divider.BorderSizePixel = 0
divider.BackgroundColor3 = palette.border
divider.Parent = window

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.fromOffset(0, 58)
body.Size = UDim2.new(1, 0, 1, -58)
body.BackgroundTransparency = 1
body.Parent = window

local search = Instance.new("TextBox")
search.Name = "Search"
search.Position = UDim2.fromOffset(20, 16)
search.Size = UDim2.new(1, -40, 0, 36)
search.BackgroundColor3 = palette.surface
search.PlaceholderText = "Search scripts"
search.PlaceholderColor3 = palette.muted
search.Text = ""
search.TextColor3 = palette.text
search.TextSize = 13
search.Font = Enum.Font.Gotham
search.TextXAlignment = Enum.TextXAlignment.Left
search.ClearTextOnFocus = false
search.Parent = body
corner(search, 7)
stroke(search)
local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 12)
searchPadding.PaddingRight = UDim.new(0, 12)
searchPadding.Parent = search

local filter = button(body, "All games")
filter.Name = "GameFilter"
filter.Position = UDim2.fromOffset(20, 62)
filter.Size = UDim2.fromOffset(104, 28)

local count = label(body, "", 11, palette.muted, false)
count.Position = UDim2.fromOffset(137, 62)
count.Size = UDim2.new(1, -157, 0, 28)
count.TextXAlignment = Enum.TextXAlignment.Right

local list = Instance.new("ScrollingFrame")
list.Name = "Scripts"
list.Position = UDim2.fromOffset(20, 101)
list.Size = UDim2.new(1, -40, 1, -120)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = palette.border
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.fromOffset(0, 0)
list.Parent = body

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local status = label(body, "", 11, palette.muted, false)
status.Position = UDim2.new(0, 20, 1, -19)
status.Size = UDim2.new(1, -40, 0, 15)

local onlyCurrentGame = false

local function render(): ()
	for _, child in list:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local trimmed = string.gsub(search.Text, "^%s*(.-)%s*$", "%1")
	local query = string.lower(trimmed)
	local visible: { ScriptEntry } = {}
	for _, entry in scripts do
		local gameMatches = not onlyCurrentGame or entry.gameId == nil or entry.gameId == game.GameId
		local textMatches = query == "" or string.find(string.lower(entry.name .. " " .. entry.description), query, 1, true) ~= nil
		if gameMatches and textMatches then
			table.insert(visible, entry)
		end
	end

	count.Text = tostring(#visible) .. (if #visible == 1 then " script" else " scripts")
	if #visible == 0 then
		local emptyText: string = if manifestState == "loading"
			then "Loading scripts..."
			elseif manifestState == "error"
			then manifestMessage
			elseif #scripts == 0
			then "No scripts are currently published."
			else "No scripts match this view."
		local empty = label(list, emptyText, 13, palette.muted, false)
		empty.Size = UDim2.new(1, -8, 0, 64)
		empty.TextWrapped = true
		return
	end

	for _, entry in visible do
		local row = Instance.new("Frame")
		row.Name = entry.id
		row.Size = UDim2.new(1, -5, 0, 70)
		row.BackgroundColor3 = palette.surface
		row.Parent = list
		corner(row, 8)
		stroke(row)

		local name = label(row, entry.name, 13, palette.text, true)
		name.Position = UDim2.fromOffset(14, 10)
		name.Size = UDim2.new(1, -120, 0, 19)

		local description = label(row, entry.description, 11, palette.muted, false)
		description.Position = UDim2.fromOffset(14, 33)
		description.Size = UDim2.new(1, -120, 0, 16)
		description.TextTruncate = Enum.TextTruncate.AtEnd

		local gameLabel = label(row, if entry.gameId == nil then "Universal" else "Game " .. tostring(entry.gameId), 10, palette.muted, false)
		gameLabel.Position = UDim2.fromOffset(14, 51)
		gameLabel.Size = UDim2.new(1, -120, 0, 13)

		local run = button(row, "Run")
		run.Position = UDim2.new(1, -87, 0.5, -15)
		run.Size = UDim2.fromOffset(72, 30)
		run.BackgroundColor3 = palette.accent
		run.TextColor3 = palette.background
		run.Activated:Connect(function(): ()
			status.Text = "Running " .. entry.name .. "..."
			status.TextColor3 = palette.muted
			local ok, err = pcall(function(): string
				if entry.gameId ~= nil and entry.gameId ~= game.GameId then
					error(string.format("Incorrect game. You are in %d. %s requires %d.", game.GameId, entry.name, entry.gameId))
				end
				runEntry(entry)
				return ""
			end)
			if ok then
				status.Text = "Ran " .. entry.name
				status.TextColor3 = palette.accent
			else
				status.Text = "Failed: " .. tostring(err)
				status.TextColor3 = palette.danger
				warn("[Script Hub] " .. entry.name .. ": " .. tostring(err))
			end
		end)
	end
end

search:GetPropertyChangedSignal("Text"):Connect(render)
filter.Activated:Connect(function(): ()
	onlyCurrentGame = not onlyCurrentGame
	filter.Text = if onlyCurrentGame then "Current game" else "All games"
	render()
end)

local collapsed = false
minimize.Activated:Connect(function(): ()
	collapsed = not collapsed
	body.Visible = not collapsed
	minimize.Text = if collapsed then "+" else "-"
	TweenService:Create(window, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
		Size = if collapsed then UDim2.new(0.92, 0, 0, 58) else UDim2.new(0.92, 0, 0, 420),
	}):Play()
end)
close.Activated:Connect(function(): ()
	gui:Destroy()
end)

local dragging = false
local dragStart = Vector2.zero
local windowStart = window.Position
local connections: { RBXScriptConnection } = {}

header.InputBegan:Connect(function(input: InputObject): ()
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	dragging = true
	dragStart = Vector2.new(input.Position.X, input.Position.Y)
	windowStart = window.Position
end)

table.insert(connections, UserInputService.InputChanged:Connect(function(input: InputObject): ()
	if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then
		return
	end
	local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
	window.Position = UDim2.new(windowStart.X.Scale, windowStart.X.Offset + delta.X, windowStart.Y.Scale, windowStart.Y.Offset + delta.Y)
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input: InputObject): ()
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end))

gui.Destroying:Connect(function(): ()
	for _, connection in connections do
		connection:Disconnect()
	end
end)

render()
task.spawn(function(): ()
	local ok: boolean, result: any = pcall(fetchManifest)
	if ok then
		scripts = result :: {ScriptEntry}
		manifestState = "ready"
		manifestMessage = string.format("Loaded %d scripts.", #scripts)
		status.Text = manifestMessage
		status.TextColor3 = palette.accent
	else
		manifestState = "error"
		manifestMessage = "Could not load the script list: " .. tostring(result)
		status.Text = manifestMessage
		status.TextColor3 = palette.danger
	end
	render()
end)

local creditsFinished = false
local function finishCredits(): ()
	if creditsFinished or gui.Parent == nil then
		return
	end
	creditsFinished = true
	credits:Destroy()
	window.Visible = true
end

skipCredits.Activated:Connect(finishCredits)
task.delay(creditsDuration, finishCredits)
