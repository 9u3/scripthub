--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

type ScriptEntry = {
	id: string,
	name: string,
	gameId: number?,
	description: string,
	run: () -> (),
}

local function gameCheck(targetPlace: number)
    if game.PlaceId ~= targetPlace then return false else return true end
end

local scripts: { ScriptEntry } = {
    {
		id = "industrialist",
		name = "Industrialist Helper",
		gameId = 3448264866,
		description = "Removes grass and pollution lighting effects. Shows RP/s and Pollution/HR",
		run = function(): ()

            local gID = 3448264866

            local check = gameCheck(gID)
            if not check then error("Incorrect game. You are in " .. game.GameId .. ". Script requires " .. gID .. ".") end
			
			local source = game:HttpGet("https://just-a.puppyonthewifi.com/p/raw/TDM4JZFp")
            local scriptFunction = loadstring(source)

            if scriptFunction == nil then
                error("Industrialist Helper failed to compile / or is deleted.")
            end

            scriptFunction()
		end,
	},
    {
		id = "soundspace",
		name = "SoundSpace Player",
		gameId = 964540701,
		description = "Automatically hits notes ingame, Does not move cursor (you can larp!)",
		run = function(): ()

            local gID = 964540701

            local check = gameCheck(gID)
            if not check then error("Incorrect game. You are in " .. game.GameId .. ". Script requires " .. gID .. ".") end

			local source = game:HttpGet("https://just-a.puppyonthewifi.com/p/raw/p3PxRgml")
            local scriptFunction = loadstring(source)

            if scriptFunction == nil then
                error("SoundSpace Player failed to compile / or is deleted.")
            end

            scriptFunction()
		end,
	}
}

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

local close = button(header, "Ã—")
close.Name = "Close"
close.Position = UDim2.new(1, -39, 0, 15)
close.Size = UDim2.fromOffset(25, 25)
close.TextSize = 20

local minimize = button(header, "âˆ’")
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
		local empty = label(list, if #scripts == 0 then "No scripts yet. Add entries to the scripts table near the top of this file." else "No scripts match this view.", 13, palette.muted, false)
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
			status.Text = "Running " .. entry.name .. "â€¦"
			status.TextColor3 = palette.muted
			local ok, err = pcall(function(): string
				entry.run()
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
	minimize.Text = if collapsed then "+" else "âˆ’"
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
