--[[
    ☁️ CloudyLib - Cloud Themed Roblox UI Library  (Enhanced Edition v2)
    Silky smooth, sky-high UI for your scripts.

    New in Enhanced Edition v2:
        • Window:Toggle()         – Show/hide the window without destroying it
        • Window:Destroy()        – Gracefully destroy the UI with animation
        • Window:SaveConfig(file) – Save all Flags to a JSON file (writefile)
        • Window:LoadConfig(file) – Load Flags back from a JSON file (readfile)
        • Mobile / Touch support  – Dragging and sliders now work on touch devices
        • Canvas auto-sizing      – ScrollingFrames always fit their content

    Original features:
        • Paragraph     – titled multi-line text block
        • Label         – info label with optional icon tint & color override
        • Divider       – decorative horizontal rule
        • Dropdown      – single or multi-select option list
        • ColorPicker   – HSV picker with hex + RGB inputs
        • Keybind       – live key-capture with HoldToInteract support
        • Input         – text box with placeholder & RemoveTextAfterFocusLost
        • Slider        – Increment and Range[min,max] like Rayfield
        • Button        – returns :Set() handle
        • Toggle        – returns :Set() handle
        • Section       – unchanged
        • Notification  – polished toast with progress bar
        • ThemeSelector – dropdown + swatches for all 12 cloud themes
        • Flags / Configuration-saving (SaveConfig/LoadConfig)

    Usage:
        local Cloudy = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
        local Window = Cloudy:CreateWindow({ Title = "My Script", Theme = "Cumulus" })
        local Tab = Window:CreateTab("Main", "⚡")
        Tab:CreateToggle({ Name = "Fly", Default = false, Flag = "Fly", Callback = function(v) end })
        -- Save/Load config:
        Window:SaveConfig("MyScript_Config.json")
        Window:LoadConfig("MyScript_Config.json")
        -- Show/hide:
        Window:Toggle()
        -- Destroy:
        Window:Destroy()
]]

-- // Services
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

-- // Utility helpers
local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.25, style, dir), props):Play()
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, child in pairs(children or {}) do child.Parent = inst end
    return inst
end

local function RippleEffect(button, color)
    local ripple = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.6,
        ZIndex = button.ZIndex + 5,
        Parent = button,
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.55, Enum.EasingStyle.Quad)
    game:GetService("Debris"):AddItem(ripple, 0.6)
end

-- // ☁️ Cloud Themes (all 12 original + unchanged)
local Themes = {
    Cumulus = {
        Name="☁️ Cumulus",
        Primary=Color3.fromRGB(140,190,255), Secondary=Color3.fromRGB(100,155,230),
        Background=Color3.fromRGB(12,18,30),  Surface=Color3.fromRGB(20,28,48),
        Card=Color3.fromRGB(28,38,62),        Border=Color3.fromRGB(60,90,140),
        Text=Color3.fromRGB(225,238,255),     SubText=Color3.fromRGB(140,170,210),
        Accent=Color3.fromRGB(180,215,255),   Toggle=Color3.fromRGB(130,185,255),
        Glow=Color3.fromRGB(100,160,255),
    },
    Cirrus = {
        Name="🌅 Cirrus",
        Primary=Color3.fromRGB(255,185,100), Secondary=Color3.fromRGB(220,145,65),
        Background=Color3.fromRGB(18,12,8),   Surface=Color3.fromRGB(30,20,12),
        Card=Color3.fromRGB(44,28,16),        Border=Color3.fromRGB(120,80,35),
        Text=Color3.fromRGB(255,238,210),     SubText=Color3.fromRGB(200,165,120),
        Accent=Color3.fromRGB(255,210,140),   Toggle=Color3.fromRGB(255,190,105),
        Glow=Color3.fromRGB(255,170,80),
    },
    Cumulonimbus = {
        Name="🌩️ Cumulonimbus",
        Primary=Color3.fromRGB(160,120,255), Secondary=Color3.fromRGB(110,75,210),
        Background=Color3.fromRGB(8,6,16),    Surface=Color3.fromRGB(14,10,28),
        Card=Color3.fromRGB(20,14,40),        Border=Color3.fromRGB(70,45,120),
        Text=Color3.fromRGB(225,215,255),     SubText=Color3.fromRGB(150,130,200),
        Accent=Color3.fromRGB(200,165,255),   Toggle=Color3.fromRGB(165,125,255),
        Glow=Color3.fromRGB(140,100,255),
    },
    Stratus = {
        Name="🌸 Stratus",
        Primary=Color3.fromRGB(255,140,175), Secondary=Color3.fromRGB(215,100,140),
        Background=Color3.fromRGB(18,10,16),  Surface=Color3.fromRGB(30,16,26),
        Card=Color3.fromRGB(44,22,36),        Border=Color3.fromRGB(120,55,85),
        Text=Color3.fromRGB(255,228,238),     SubText=Color3.fromRGB(195,148,170),
        Accent=Color3.fromRGB(255,175,200),   Toggle=Color3.fromRGB(255,145,180),
        Glow=Color3.fromRGB(255,120,160),
    },
    Cirrostratus = {
        Name="❄️ Cirrostratus",
        Primary=Color3.fromRGB(185,230,255), Secondary=Color3.fromRGB(140,195,235),
        Background=Color3.fromRGB(8,14,22),   Surface=Color3.fromRGB(14,22,36),
        Card=Color3.fromRGB(20,30,50),        Border=Color3.fromRGB(65,105,150),
        Text=Color3.fromRGB(230,245,255),     SubText=Color3.fromRGB(145,185,218),
        Accent=Color3.fromRGB(210,238,255),   Toggle=Color3.fromRGB(190,228,255),
        Glow=Color3.fromRGB(160,215,255),
    },
    Nimbostratus = {
        Name="🌋 Nimbostratus",
        Primary=Color3.fromRGB(255,100,60),  Secondary=Color3.fromRGB(200,65,30),
        Background=Color3.fromRGB(14,8,6),    Surface=Color3.fromRGB(24,14,10),
        Card=Color3.fromRGB(36,20,14),        Border=Color3.fromRGB(120,50,25),
        Text=Color3.fromRGB(255,220,205),     SubText=Color3.fromRGB(195,145,120),
        Accent=Color3.fromRGB(255,145,100),   Toggle=Color3.fromRGB(255,110,65),
        Glow=Color3.fromRGB(255,85,40),
    },
    Fogbank = {
        Name="🌿 Fogbank",
        Primary=Color3.fromRGB(100,210,160), Secondary=Color3.fromRGB(65,165,120),
        Background=Color3.fromRGB(8,16,12),   Surface=Color3.fromRGB(14,26,20),
        Card=Color3.fromRGB(20,36,28),        Border=Color3.fromRGB(40,100,72),
        Text=Color3.fromRGB(210,248,230),     SubText=Color3.fromRGB(125,185,155),
        Accent=Color3.fromRGB(145,225,185),   Toggle=Color3.fromRGB(105,215,165),
        Glow=Color3.fromRGB(85,205,145),
    },
    Noctilucent = {
        Name="🌙 Noctilucent",
        Primary=Color3.fromRGB(100,145,220), Secondary=Color3.fromRGB(65,100,175),
        Background=Color3.fromRGB(5,7,18),    Surface=Color3.fromRGB(9,12,28),
        Card=Color3.fromRGB(13,17,40),        Border=Color3.fromRGB(40,60,115),
        Text=Color3.fromRGB(200,218,255),     SubText=Color3.fromRGB(115,140,195),
        Accent=Color3.fromRGB(150,185,240),   Toggle=Color3.fromRGB(105,150,225),
        Glow=Color3.fromRGB(85,125,210),
    },
    Iridescent = {
        Name="🌈 Iridescent",
        Primary=Color3.fromRGB(180,120,255), Secondary=Color3.fromRGB(100,200,255),
        Background=Color3.fromRGB(10,8,20),   Surface=Color3.fromRGB(18,14,34),
        Card=Color3.fromRGB(26,20,48),        Border=Color3.fromRGB(80,55,140),
        Text=Color3.fromRGB(235,220,255),     SubText=Color3.fromRGB(160,140,210),
        Accent=Color3.fromRGB(210,175,255),   Toggle=Color3.fromRGB(185,130,255),
        Glow=Color3.fromRGB(160,100,255),
    },
    Anvil = {
        Name="☀️ Anvil",
        Primary=Color3.fromRGB(255,215,55),  Secondary=Color3.fromRGB(215,170,15),
        Background=Color3.fromRGB(16,12,4),   Surface=Color3.fromRGB(26,20,6),
        Card=Color3.fromRGB(38,28,8),         Border=Color3.fromRGB(125,95,18),
        Text=Color3.fromRGB(255,248,215),     SubText=Color3.fromRGB(200,175,120),
        Accent=Color3.fromRGB(255,230,110),   Toggle=Color3.fromRGB(255,218,60),
        Glow=Color3.fromRGB(255,200,30),
    },
    Overcast = {
        Name="🩶 Overcast",
        Primary=Color3.fromRGB(155,170,195), Secondary=Color3.fromRGB(110,125,150),
        Background=Color3.fromRGB(10,11,14),  Surface=Color3.fromRGB(18,20,25),
        Card=Color3.fromRGB(26,28,36),        Border=Color3.fromRGB(58,65,82),
        Text=Color3.fromRGB(220,228,242),     SubText=Color3.fromRGB(138,150,172),
        Accent=Color3.fromRGB(185,198,220),   Toggle=Color3.fromRGB(160,175,200),
        Glow=Color3.fromRGB(140,158,185),
    },
    Squall = {
        Name="🌊 Squall",
        Primary=Color3.fromRGB(50,185,210),  Secondary=Color3.fromRGB(25,145,175),
        Background=Color3.fromRGB(5,14,20),   Surface=Color3.fromRGB(9,22,32),
        Card=Color3.fromRGB(13,30,44),        Border=Color3.fromRGB(25,90,120),
        Text=Color3.fromRGB(200,242,255),     SubText=Color3.fromRGB(110,175,205),
        Accent=Color3.fromRGB(100,215,235),   Toggle=Color3.fromRGB(55,190,215),
        Glow=Color3.fromRGB(35,170,200),
    },
}

-- // CloudyLib
local CloudyLib = {}
CloudyLib.__index = CloudyLib

function CloudyLib:CreateWindow(config)
    config     = config or {}
    local title    = config.Title    or "CloudyLib"
    local subtitle = config.Subtitle or "☁️ Sky High Scripts"
    local theme    = Themes[config.Theme] or Themes.Cumulus
    local size     = config.Size or UDim2.new(0, 620, 0, 450)

    -- // ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name           = "CloudyLib_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- // Main frame
    local Main = Create("Frame", {
        Name             = "Main",
        Size             = size,
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
        Parent           = ScreenGui,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
    Create("UIStroke",  {Color = theme.Border, Thickness = 1.5, Parent = Main})

    -- Glow shadow
    local Shadow = Create("ImageLabel", {
        Name                  = "Shadow",
        Size                  = UDim2.new(1, 60, 1, 60),
        Position              = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency= 1,
        Image                 = "rbxassetid://6014261993",
        ImageColor3           = theme.Glow,
        ImageTransparency     = 0.45,
        ScaleType             = Enum.ScaleType.Slice,
        SliceCenter           = Rect.new(49,49,450,450),
        ZIndex                = 0,
        Parent                = Main,
    })

    -- // Topbar
    local Topbar = Create("Frame", {
        Name             = "Topbar",
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Main,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Topbar})
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Topbar,
    })

    -- Animated cloud icon
    local CloudIcon = Create("TextLabel", {
        Size             = UDim2.new(0, 30, 1, 0),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text             = "☁️",
        TextSize         = 20,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 3,
        Parent           = Topbar,
    })
    local driftOffset = 0
    local driftDir    = 1
    RunService.Heartbeat:Connect(function(dt)
        driftOffset = driftOffset + dt * 4 * driftDir
        if driftOffset > 5  then driftDir = -1 end
        if driftOffset < -5 then driftDir =  1 end
        CloudIcon.Position = UDim2.new(0, 12 + driftOffset, 0, 0)
    end)

    local TitleLabel = Create("TextLabel", {
        Size             = UDim2.new(1, -140, 0, 22),
        Position         = UDim2.new(0, 48, 0, 8),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = theme.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
        Parent           = Topbar,
    })
    local SubLabel = Create("TextLabel", {
        Size             = UDim2.new(1, -140, 0, 14),
        Position         = UDim2.new(0, 48, 0, 30),
        BackgroundTransparency = 1,
        Text             = subtitle,
        TextColor3       = theme.SubText,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
        Parent           = Topbar,
    })

    -- Topbar shimmer
    local TopGrad = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.94,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Topbar,
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180,180,255)),
        }),
        Rotation = 90,
        Parent = TopGrad,
    })

    -- Accent line
    local AccentLine = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.Primary,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = Topbar,
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   theme.Primary),
            ColorSequenceKeypoint.new(0.5, theme.Accent),
            ColorSequenceKeypoint.new(1,   theme.Primary),
        }),
        Parent = AccentLine,
    })

    -- Top buttons (Close, Minimise)
    local function MakeTopBtn(xOff, icon, hoverColor, callback)
        local btn = Create("TextButton", {
            Size             = UDim2.new(0, 28, 0, 28),
            Position         = UDim2.new(1, xOff, 0.5, 0),
            AnchorPoint      = Vector2.new(1, 0.5),
            BackgroundColor3 = theme.Card,
            Text             = icon,
            TextColor3       = theme.SubText,
            Font             = Enum.Font.GothamBold,
            TextSize         = 14,
            ZIndex           = 4,
            Parent           = Topbar,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = btn})
        btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = hoverColor}, 0.15) end)
        btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = theme.Card},  0.15) end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local minimized   = false
    local ContentFrame

    local closeBtn = MakeTopBtn(-10, "✕", Color3.fromRGB(200,55,55), function()
        Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.35, function() ScreenGui:Destroy() end)
    end)
    local minimizeBtn = MakeTopBtn(-46, "—", theme.Border, function()
        minimized = not minimized
        Tween(Main, {Size = minimized and UDim2.new(0, size.X.Offset, 0, 52) or size}, 0.3, Enum.EasingStyle.Back)
    end)

    -- // Drag (Mouse + Touch)
    local dragging, dragStart, startPos = false, nil, nil
    local function isDragInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end
    local function isMoveInput(input)
        return input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
    end
    Topbar.InputBegan:Connect(function(input)
        if isDragInput(input) then
            dragging  = true
            dragStart = input.Position
            startPos  = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and isMoveInput(input) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if isDragInput(input) then dragging = false end
    end)

    -- // Sidebar
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 140, 1, -52),
        Position         = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel  = 0,
        Parent           = Main,
    })
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel  = 0,
        Parent           = Sidebar,
    })
    local SideGrad = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.97,
        BorderSizePixel  = 0,
        Parent           = Sidebar,
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Primary),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
        }),
        Rotation = 45,
        Parent = SideGrad,
    })
    Create("UIListLayout", {
        Padding             = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = Sidebar,
    })
    Create("UIPadding", {
        PaddingTop   = UDim.new(0, 10),
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent       = Sidebar,
    })

    -- // Content
    ContentFrame = Create("Frame", {
        Name                   = "Content",
        Size                   = UDim2.new(1, -140, 1, -52),
        Position               = UDim2.new(0, 140, 0, 52),
        BackgroundTransparency = 1,
        Parent                 = Main,
    })

    -- // Window object
    local Window = {
        Theme     = theme,
        ScreenGui = ScreenGui,
        Main      = Main,
        Tabs      = {},
        ActiveTab = nil,
        Flags     = {},
    }

    -- // Notification system (bottom-right corner toast)
    local notifHolder = Create("Frame", {
        Size             = UDim2.new(0, 280, 1, 0),
        Position         = UDim2.new(1, -292, 0, 0),
        BackgroundTransparency = 1,
        Parent           = ScreenGui,
    })
    Create("UIListLayout", {
        Padding             = UDim.new(0, 8),
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = notifHolder,
    })
    Create("UIPadding", {PaddingBottom = UDim.new(0, 14), Parent = notifHolder})

    function Window:Notify(cfg)
        cfg = cfg or {}
        local t = self.Theme
        local notif = Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = t.Surface,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            Parent           = notifHolder,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = notif})
        Create("UIStroke",  {Color = t.Border, Thickness = 1, Parent = notif})
        -- left accent bar
        local side = Create("Frame", {
            Size             = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = t.Primary,
            BorderSizePixel  = 0,
            Parent           = notif,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = side})
        Create("TextLabel", {
            Size             = UDim2.new(1, -16, 0, 18),
            Position         = UDim2.new(0, 14, 0, 10),
            BackgroundTransparency = 1,
            Text             = "☁️  " .. (cfg.Title or "CloudyLib"),
            TextColor3       = t.Text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = notif,
        })
        Create("TextLabel", {
            Size             = UDim2.new(1, -16, 0, 32),
            Position         = UDim2.new(0, 14, 0, 28),
            BackgroundTransparency = 1,
            Text             = cfg.Content or "",
            TextColor3       = t.SubText,
            Font             = Enum.Font.Gotham,
            TextSize         = 11,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            Parent           = notif,
        })
        -- progress bar
        local prog = Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 2),
            Position         = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = t.Primary,
            BorderSizePixel  = 0,
            Parent           = notif,
        })
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, t.Primary),
                ColorSequenceKeypoint.new(1, t.Accent),
            }),
            Parent = prog,
        })
        Tween(notif, {Size = UDim2.new(1,0,0,74)}, 0.3, Enum.EasingStyle.Back)
        local dur = cfg.Duration or 4
        Tween(prog, {Size = UDim2.new(0,0,0,2)}, dur, Enum.EasingStyle.Linear)
        task.delay(dur, function()
            Tween(notif, {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.28)
            task.delay(0.32, function() notif:Destroy() end)
        end)
    end

    -- // Toggle visibility
    local _visible = true
    function Window:Toggle()
        _visible = not _visible
        Main.Visible = _visible
    end

    -- // Destroy the UI entirely
    function Window:Destroy()
        Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.35, function() ScreenGui:Destroy() end)
    end

    -- // Config saving (uses writefile/readfile from exploit executor environment)
    function Window:SaveConfig(fileName)
        fileName = fileName or "CloudyLib_Config.json"
        local data = {}
        for flag, value in pairs(self.Flags) do
            if typeof(value) == "Color3" then
                data[flag] = {__type="Color3", r=value.R, g=value.G, b=value.B}
            elseif type(value) == "table" then
                data[flag] = {__type="array", v=value}
            else
                data[flag] = value
            end
        end
        local HttpService = game:GetService("HttpService")
        local ok, err = pcall(writefile, fileName, HttpService:JSONEncode(data))
        if not ok then
            warn("[CloudyLib] SaveConfig failed: " .. tostring(err))
        end
        return ok
    end

    function Window:LoadConfig(fileName)
        fileName = fileName or "CloudyLib_Config.json"
        local fileExists = pcall(isfile, fileName) and isfile(fileName)
        if not fileExists then return false end
        local ok, raw = pcall(readfile, fileName)
        if not ok or not raw then return false end
        local HttpService = game:GetService("HttpService")
        local success, data = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not success or type(data) ~= "table" then return false end
        for flag, value in pairs(data) do
            if type(value) == "table" and value.__type == "Color3" then
                self.Flags[flag] = Color3.new(value.r, value.g, value.b)
            elseif type(value) == "table" and value.__type == "array" then
                self.Flags[flag] = value.v
            else
                self.Flags[flag] = value
            end
        end
        return true
    end

    -- // Theme switcher
    function Window:ApplyTheme(newName)
        local newT = Themes[newName]
        if not newT then return end
        self.Theme = newT
        theme = newT
        Tween(Main,       {BackgroundColor3 = newT.Background}, 0.4)
        Tween(Topbar,     {BackgroundColor3 = newT.Surface},    0.4)
        Tween(Sidebar,    {BackgroundColor3 = newT.Surface},    0.4)
        Tween(AccentLine, {BackgroundColor3 = newT.Primary},    0.4)
        Shadow.ImageColor3 = newT.Glow
        TitleLabel.TextColor3 = newT.Text
        SubLabel.TextColor3   = newT.SubText
        for _, tab in pairs(self.Tabs) do
            if tab._themeRefresh then tab._themeRefresh(newT) end
        end
    end

    -- // CreateTab
    function Window:CreateTab(name, icon)
        local t       = self.Theme
        local isFirst = #self.Tabs == 0

        local TabBtn = Create("TextButton", {
            Name             = name,
            Size             = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = isFirst and t.Card or t.Surface,
            Text             = (icon and icon .. "  " or "☁️  ") .. name,
            TextColor3       = isFirst and t.Text or t.SubText,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 12,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 2,
            Parent           = Sidebar,
        })
        Create("UICorner",  {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        Create("UIPadding", {PaddingLeft  = UDim.new(0, 10), Parent = TabBtn})

        local TabAccent = Create("Frame", {
            Size             = UDim2.new(0, 3, 0.65, 0),
            Position         = UDim2.new(0, -1, 0.175, 0),
            BackgroundColor3 = t.Primary,
            BorderSizePixel  = 0,
            Visible          = isFirst,
            ZIndex           = 3,
            Parent           = TabBtn,
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TabAccent})

        -- Content scroll
        local TabContent = Create("ScrollingFrame", {
            Name                 = name .. "_Content",
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = t.Border,
            Visible              = isFirst,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Parent               = ContentFrame,
        })
        Create("UIListLayout", {
            Padding             = UDim.new(0, 6),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent              = TabContent,
        })
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
            Parent        = TabContent,
        })

        local Tab = { _btn = TabBtn, _content = TabContent, _themeCallbacks = {} }
        table.insert(self.Tabs, Tab)
        if isFirst then self.ActiveTab = Tab end

        TabBtn.MouseButton1Click:Connect(function()
            if self.ActiveTab == Tab then return end
            if self.ActiveTab then
                Tween(self.ActiveTab._btn, {BackgroundColor3 = t.Surface, TextColor3 = t.SubText}, 0.2)
                self.ActiveTab._content.Visible = false
                self.ActiveTab._accent.Visible  = false
            end
            self.ActiveTab = Tab
            TabContent.Visible = true
            TabAccent.Visible  = true
            Tween(TabBtn, {BackgroundColor3 = t.Card, TextColor3 = t.Text}, 0.2)
        end)
        Tab._accent = TabAccent

        Tab._themeRefresh = function(newT)
            t = newT
            local active = self.ActiveTab == Tab
            Tween(TabBtn, {
                BackgroundColor3 = active and newT.Card or newT.Surface,
                TextColor3       = active and newT.Text or newT.SubText,
            }, 0.3)
            Tween(TabAccent, {BackgroundColor3 = newT.Primary}, 0.3)
            TabContent.ScrollBarImageColor3 = newT.Border
        end

        -- ──────────────────────────────────────────────────────────
        --  SHARED HELPERS
        -- ──────────────────────────────────────────────────────────

        local function MakeCard(h)
            local card = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, h or 44),
                BackgroundColor3 = t.Card,
                BorderSizePixel  = 0,
                Parent           = TabContent,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = card})
            Create("UIStroke",  {Color = t.Border, Thickness = 1, Transparency = 0.45, Parent = card})
            -- cloud sheen
            local sheen = Create("Frame", {
                Size             = UDim2.new(1, 0, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 0.94,
                BorderSizePixel  = 0,
                ZIndex           = 1,
                Parent           = card,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = sheen})
            return card
        end

        local function MakeLabel(parent, text, font, size, color, xAlign, pos, sizeUDim, zIndex)
            return Create("TextLabel", {
                Size             = sizeUDim,
                Position         = pos,
                BackgroundTransparency = 1,
                Text             = text,
                TextColor3       = color,
                Font             = font or Enum.Font.Gotham,
                TextSize         = size or 13,
                TextXAlignment   = xAlign or Enum.TextXAlignment.Left,
                TextWrapped      = true,
                ZIndex           = zIndex or 2,
                Parent           = parent,
            })
        end

        -- ──────────────────────────────────────────────────────────
        --  SECTION
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateSection(name)
            local sec = Create("Frame", {
                Size                   = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent                 = TabContent,
            })
            Create("Frame", {Size=UDim2.new(0.28,0,0,1), Position=UDim2.new(0,0,0.5,0), BackgroundColor3=t.Border, BorderSizePixel=0, Parent=sec})
            Create("Frame", {Size=UDim2.new(0.28,0,0,1), Position=UDim2.new(0.72,0,0.5,0), BackgroundColor3=t.Border, BorderSizePixel=0, Parent=sec})
            local lbl = Create("TextLabel", {
                Size             = UDim2.new(0.44, 0, 1, 0),
                Position         = UDim2.new(0.28, 0, 0, 0),
                BackgroundTransparency = 1,
                Text             = "☁  " .. name:upper() .. "  ☁",
                TextColor3       = t.SubText,
                Font             = Enum.Font.GothamBold,
                TextSize         = 10,
                TextXAlignment   = Enum.TextXAlignment.Center,
                Parent           = sec,
            })
            local val = {}
            function val:Set(n) lbl.Text = "☁  " .. n:upper() .. "  ☁" end
            return val
        end

        -- ──────────────────────────────────────────────────────────
        --  DIVIDER  (NEW – from Rayfield)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateDivider()
            local wrapper = Create("Frame", {
                Size                   = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Parent                 = TabContent,
            })
            local line = Create("Frame", {
                Size             = UDim2.new(0.92, 0, 0, 1),
                Position         = UDim2.new(0.04, 0, 0.5, 0),
                BackgroundColor3 = t.Border,
                BorderSizePixel  = 0,
                BackgroundTransparency = 0.4,
                Parent           = wrapper,
            })
            local divVal = {}
            function divVal:Set(visible) wrapper.Visible = visible end
            return divVal
        end

        -- ──────────────────────────────────────────────────────────
        --  LABEL  (enhanced – icon tint + color override)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateLabel(cfg)
            if type(cfg) == "string" then cfg = {Text = cfg} end
            cfg = cfg or {}
            local bgColor  = cfg.Color or t.Card
            local h        = cfg.Color and 36 or 36
            local card     = MakeCard(h)
            if cfg.Color then
                card.BackgroundColor3 = bgColor
                card.BackgroundTransparency = 0.25
            end

            -- optional leading emoji/icon text
            local prefix = cfg.Icon and (cfg.Icon .. "  ") or "☁  "
            local lbl = MakeLabel(card,
                prefix .. (cfg.Text or "Label"),
                Enum.Font.Gotham, 12,
                cfg.Color and t.Text or t.SubText,
                Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 0),
                UDim2.new(1, -22, 1, 0), 2
            )

            local val = {}
            function val:Set(newText, newIcon)
                local p = newIcon and (newIcon .. "  ") or prefix
                lbl.Text = p .. (newText or "")
            end
            return val
        end

        -- ──────────────────────────────────────────────────────────
        --  PARAGRAPH  (NEW – from Rayfield)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateParagraph(cfg)
            cfg = cfg or {}
            local card = MakeCard(60)
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.Size = UDim2.new(1, 0, 0, 0)
            Create("UIPadding", {
                PaddingLeft=UDim.new(0,14), PaddingRight=UDim.new(0,14),
                PaddingTop=UDim.new(0,10),  PaddingBottom=UDim.new(0,10),
                Parent=card,
            })
            Create("UIListLayout", {Padding=UDim.new(0,4), Parent=card})
            local titleLbl = Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text             = cfg.Title or "Title",
                TextColor3       = t.Text,
                Font             = Enum.Font.GothamBold,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 2,
                Parent           = card,
            })
            local contentLbl = Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text             = cfg.Content or "",
                TextColor3       = t.SubText,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                ZIndex           = 2,
                Parent           = card,
            })
            local val = {}
            function val:Set(newCfg)
                titleLbl.Text   = newCfg.Title   or titleLbl.Text
                contentLbl.Text = newCfg.Content or contentLbl.Text
            end
            return val
        end

        -- ──────────────────────────────────────────────────────────
        --  TOGGLE
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local val  = cfg.Default or false
            local card = MakeCard(cfg.Description and 58 or 44)

            MakeLabel(card, cfg.Name or "Toggle",
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, cfg.Description and 8 or 13),
                UDim2.new(1, -68, 0, 18), 2)

            if cfg.Description then
                MakeLabel(card, cfg.Description,
                    Enum.Font.Gotham, 10, t.SubText, Enum.TextXAlignment.Left,
                    UDim2.new(0, 14, 0, 30), UDim2.new(1, -68, 0, 13), 2)
            end

            -- Switch track
            local track = Create("Frame", {
                Size             = UDim2.new(0, 38, 0, 20),
                Position         = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = card,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
            Create("UIStroke",  {Color = t.Border, Thickness = 1, Parent = track})

            -- Knob
            local knob = Create("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = val and t.Toggle or t.SubText,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = track,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

            local function setToggle(newVal, fireCallback)
                val = newVal
                Tween(knob, {
                    Position         = val and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                    BackgroundColor3 = val and t.Toggle or t.SubText,
                }, 0.2, Enum.EasingStyle.Back)
                Tween(track, {BackgroundColor3 = val and t.Primary or t.Surface}, 0.2)
                if fireCallback and cfg.Callback then
                    pcall(cfg.Callback, val)
                end
            end

            -- Interact overlay
            local btn = Create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 4,
                Parent           = card,
            })
            btn.MouseButton1Click:Connect(function()
                RippleEffect(card, t.Primary)
                setToggle(not val, true)
                if cfg.Flag then Window.Flags[cfg.Flag] = val end
            end)
            btn.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = t.Surface}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = t.Card},    0.15) end)

            local handle = {}
            function handle:Set(newVal)
                setToggle(newVal, true)
                if cfg.Flag then Window.Flags[cfg.Flag] = newVal end
            end
            function handle:Get() return val end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  SLIDER  (enhanced – Increment + Range[min,max])
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local minV   = cfg.Min   or (cfg.Range and cfg.Range[1]) or 0
            local maxV   = cfg.Max   or (cfg.Range and cfg.Range[2]) or 100
            local incr   = cfg.Increment or 1
            local curVal = math.clamp(cfg.Default or cfg.CurrentValue or minV, minV, maxV)
            local suffix = cfg.Suffix or ""

            local card  = MakeCard(62)
            MakeLabel(card, cfg.Name or "Slider",
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 8), UDim2.new(0.6, 0, 0, 16), 2)

            local valLabel = Create("TextLabel", {
                Size             = UDim2.new(0, 80, 0, 16),
                Position         = UDim2.new(1, -90, 0, 8),
                BackgroundTransparency = 1,
                Text             = tostring(curVal) .. suffix,
                TextColor3       = t.Primary,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = 2,
                Parent           = card,
            })

            -- Track
            local trackBg = Create("Frame", {
                Size             = UDim2.new(1, -28, 0, 6),
                Position         = UDim2.new(0, 14, 0, 40),
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = card,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = trackBg})
            Create("UIStroke",  {Color = t.Border, Thickness = 1, Transparency = 0.4, Parent = trackBg})

            -- Fill
            local fillPct = (curVal - minV) / (maxV - minV)
            local fill = Create("Frame", {
                Size             = UDim2.new(fillPct, 0, 1, 0),
                BackgroundColor3 = t.Primary,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = trackBg,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, t.Primary),
                    ColorSequenceKeypoint.new(1, t.Accent),
                }),
                Parent = fill,
            })

            -- Knob
            local knob = Create("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(fillPct, -7, 0.5, -7),
                BackgroundColor3 = t.Text,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = trackBg,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
            Create("UIStroke",  {Color = t.Primary, Thickness = 2, Parent = knob})

            -- Drag logic
            local draggingSl = false
            local function updateSlider(mouseX)
                local abs  = trackBg.AbsolutePosition.X
                local absW = trackBg.AbsoluteSize.X
                local pct  = math.clamp((mouseX - abs) / absW, 0, 1)
                local raw  = minV + pct * (maxV - minV)
                local snapped = math.floor(raw / incr + 0.5) * incr
                snapped = math.clamp(snapped, minV, maxV)
                local newPct = (snapped - minV) / (maxV - minV)
                curVal = snapped
                Tween(fill,  {Size     = UDim2.new(newPct, 0, 1, 0)}, 0.08, Enum.EasingStyle.Linear)
                Tween(knob,  {Position = UDim2.new(newPct, -7, 0.5, -7)}, 0.08, Enum.EasingStyle.Linear)
                valLabel.Text = tostring(snapped) .. suffix
                if cfg.Callback then pcall(cfg.Callback, snapped) end
                if cfg.Flag then Window.Flags[cfg.Flag] = snapped end
            end

            local interact = Create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 22),
                Position         = UDim2.new(0, 0, 0, -8),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 5,
                Parent           = trackBg,
            })
            interact.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSl = true
                    updateSlider(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSl = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingSl and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(inp.Position.X)
                end
            end)

            local handle = {}
            function handle:Set(newVal)
                newVal = math.clamp(newVal, minV, maxV)
                local pct = (newVal - minV) / (maxV - minV)
                curVal = newVal
                Tween(fill,  {Size     = UDim2.new(pct, 0, 1, 0)}, 0.2)
                Tween(knob,  {Position = UDim2.new(pct, -7, 0.5, -7)}, 0.2)
                valLabel.Text = tostring(newVal) .. suffix
                if cfg.Callback then pcall(cfg.Callback, newVal) end
                if cfg.Flag then Window.Flags[cfg.Flag] = newVal end
            end
            function handle:Get() return curVal end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  BUTTON
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local card = MakeCard(44)

            local icon = cfg.Icon and (cfg.Icon .. "  ") or ""
            MakeLabel(card, icon .. (cfg.Name or "Button"),
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 0), UDim2.new(1, -28, 1, 0), 2)

            -- Arrow hint
            Create("TextLabel", {
                Size             = UDim2.new(0, 20, 1, 0),
                Position         = UDim2.new(1, -28, 0, 0),
                BackgroundTransparency = 1,
                Text             = "›",
                TextColor3       = t.SubText,
                Font             = Enum.Font.GothamBold,
                TextSize         = 18,
                ZIndex           = 2,
                Parent           = card,
            })

            local btn = Create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 3,
                Parent           = card,
            })
            btn.MouseButton1Click:Connect(function()
                RippleEffect(card, t.Primary)
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            btn.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = t.Surface}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = t.Card},    0.15) end)

            local handle = {}
            function handle:Set(newName)
                -- update displayed text
                for _, ch in ipairs(card:GetChildren()) do
                    if ch:IsA("TextLabel") and ch.Text:find(cfg.Name or "Button") then
                        ch.Text = (cfg.Icon and cfg.Icon .. "  " or "") .. newName
                        break
                    end
                end
            end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  INPUT  (NEW – full Rayfield-style input box)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local card = MakeCard(60)

            MakeLabel(card, cfg.Name or "Input",
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 7), UDim2.new(1, -28, 0, 16), 2)

            -- Box frame
            local boxFrame = Create("Frame", {
                Size             = UDim2.new(1, -28, 0, 28),
                Position         = UDim2.new(0, 14, 0, 28),
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = card,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = boxFrame})
            Create("UIStroke",  {Color = t.Border, Thickness = 1, Transparency = 0.3, Parent = boxFrame})

            local box = Create("TextBox", {
                Size             = UDim2.new(1, -16, 1, 0),
                Position         = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text             = cfg.CurrentValue or "",
                PlaceholderText  = cfg.Placeholder or cfg.PlaceholderText or "Type here…",
                PlaceholderColor3 = t.SubText,
                TextColor3       = t.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex           = 3,
                Parent           = boxFrame,
            })

            box.FocusLost:Connect(function(entered)
                if cfg.Callback then
                    pcall(cfg.Callback, box.Text, entered)
                end
                if cfg.RemoveTextAfterFocusLost then box.Text = "" end
                if cfg.Flag then Window.Flags[cfg.Flag] = box.Text end
            end)
            boxFrame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    Tween(boxFrame, {BackgroundColor3 = t.Card}, 0.15)
                    box:CaptureFocus()
                end
            end)
            box.FocusLost:Connect(function()
                Tween(boxFrame, {BackgroundColor3 = t.Surface}, 0.15)
            end)

            local handle = {}
            function handle:Set(text)
                box.Text = text
                if cfg.Callback then pcall(cfg.Callback, text, false) end
                if cfg.Flag then Window.Flags[cfg.Flag] = text end
            end
            function handle:Get() return box.Text end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  KEYBIND  (NEW – full Rayfield-style keybind with HoldToInteract)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local currentKey  = cfg.Default or cfg.CurrentKeybind or "None"
            local listening   = false

            local card = MakeCard(44)

            MakeLabel(card, cfg.Name or "Keybind",
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 0), UDim2.new(1, -110, 1, 0), 2)

            -- Key pill
            local pill = Create("TextButton", {
                Size             = UDim2.new(0, 80, 0, 26),
                Position         = UDim2.new(1, -90, 0.5, -13),
                BackgroundColor3 = t.Surface,
                Text             = currentKey,
                TextColor3       = t.Primary,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                ZIndex           = 3,
                Parent           = card,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = pill})
            Create("UIStroke",  {Color = t.Border, Thickness = 1, Transparency = 0.3, Parent = pill})

            pill.MouseButton1Click:Connect(function()
                listening = true
                pill.Text = "…"
                Tween(pill, {BackgroundColor3 = t.Card}, 0.15)
            end)

            local holdConn
            UserInputService.InputBegan:Connect(function(inp, gp)
                if listening then
                    if inp.KeyCode ~= Enum.KeyCode.Unknown then
                        local split = string.split(tostring(inp.KeyCode), ".")
                        currentKey  = split[3]
                        pill.Text   = currentKey
                        listening   = false
                        Tween(pill, {BackgroundColor3 = t.Surface}, 0.15)
                        if cfg.Flag then Window.Flags[cfg.Flag] = currentKey end
                        if cfg.CallOnChange and cfg.Callback then
                            pcall(cfg.Callback, currentKey)
                        end
                    end
                elseif not gp and currentKey ~= "None" and inp.KeyCode == Enum.KeyCode[currentKey] then
                    if cfg.HoldToInteract then
                        local held = true
                        local hConn
                        hConn = inp.Changed:Connect(function(p)
                            if p == "UserInputState" then held = false; hConn:Disconnect() end
                        end)
                        task.wait(0.25)
                        if held then
                            holdConn = RunService.Stepped:Connect(function()
                                if not held then
                                    if cfg.Callback then pcall(cfg.Callback, false) end
                                    holdConn:Disconnect()
                                else
                                    if cfg.Callback then pcall(cfg.Callback, true) end
                                end
                            end)
                        end
                    else
                        if cfg.Callback then pcall(cfg.Callback) end
                    end
                end
            end)

            local handle = {}
            function handle:Set(key)
                currentKey = key
                pill.Text  = key
                if cfg.Flag then Window.Flags[cfg.Flag] = key end
            end
            function handle:Get() return currentKey end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  DROPDOWN  (NEW – single or multi-select)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local options     = cfg.Options or {}
            local multi       = cfg.MultipleOptions or cfg.Multi or false
            local selected    = {}

            -- Normalise default selection
            if cfg.Default then
                if type(cfg.Default) == "string" then
                    selected = {cfg.Default}
                elseif type(cfg.Default) == "table" then
                    selected = cfg.Default
                end
            elseif cfg.CurrentOption then
                if type(cfg.CurrentOption) == "string" then
                    selected = {cfg.CurrentOption}
                else
                    selected = cfg.CurrentOption
                end
            end

            local function selectedText()
                if #selected == 0 then return "None"
                elseif #selected == 1 then return selected[1]
                else return "Various (" .. #selected .. ")"
                end
            end

            local isOpen = false
            local ITEM_H = 32
            local closedH = 44
            local maxItems = math.min(#options, 5)

            local card = MakeCard(closedH)
            card.ClipsDescendants = true

            MakeLabel(card, cfg.Name or "Dropdown",
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 0), UDim2.new(0.6, 0, 0, closedH), 2)

            -- Selected value label
            local selLabel = Create("TextLabel", {
                Size             = UDim2.new(0, 110, 0, closedH),
                Position         = UDim2.new(1, -126, 0, 0),
                BackgroundTransparency = 1,
                Text             = selectedText(),
                TextColor3       = t.Primary,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = 2,
                Parent           = card,
            })

            -- Arrow
            local arrow = Create("TextLabel", {
                Size             = UDim2.new(0, 14, 0, closedH),
                Position         = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = t.SubText,
                Font             = Enum.Font.GothamBold,
                TextSize         = 14,
                ZIndex           = 2,
                Parent           = card,
            })

            -- Separator
            local sep = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 0, closedH - 1),
                BackgroundColor3 = t.Border,
                BorderSizePixel  = 0,
                BackgroundTransparency = 0.5,
                Visible          = false,
                ZIndex           = 2,
                Parent           = card,
            })

            -- List container (scrollable)
            local listFrame = Create("ScrollingFrame", {
                Size                 = UDim2.new(1, 0, 0, 0),
                Position             = UDim2.new(0, 0, 0, closedH),
                BackgroundTransparency = 1,
                BorderSizePixel      = 0,
                ScrollBarThickness   = 2,
                ScrollBarImageColor3 = t.Border,
                CanvasSize           = UDim2.new(0, 0, 0, #options * ITEM_H),
                Visible              = false,
                ZIndex               = 3,
                Parent               = card,
            })
            Create("UIListLayout", {Padding=UDim.new(0,0), Parent=listFrame})

            local function isSelected(opt)
                for _, s in ipairs(selected) do
                    if s == opt then return true end
                end
                return false
            end

            local optionBtns = {}

            local function refreshVisuals()
                for _, ob in ipairs(optionBtns) do
                    Tween(ob.frame, {BackgroundColor3 = isSelected(ob.name) and t.Primary or t.Surface}, 0.15)
                    ob.label.TextColor3 = isSelected(ob.name) and t.Text or t.SubText
                end
                selLabel.Text = selectedText()
            end

            for _, opt in ipairs(options) do
                local row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, ITEM_H),
                    BackgroundColor3 = isSelected(opt) and t.Primary or t.Surface,
                    BorderSizePixel  = 0,
                    ZIndex           = 4,
                    Parent           = listFrame,
                })
                local rowLbl = Create("TextLabel", {
                    Size             = UDim2.new(1, -16, 1, 0),
                    Position         = UDim2.new(0, 14, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = (isSelected(opt) and "✓  " or "   ") .. opt,
                    TextColor3       = isSelected(opt) and t.Text or t.SubText,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 4,
                    Parent           = row,
                })
                local rowBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 5,
                    Parent           = row,
                })
                table.insert(optionBtns, {frame=row, label=rowLbl, name=opt})

                rowBtn.MouseButton1Click:Connect(function()
                    if multi then
                        if isSelected(opt) then
                            for i, s in ipairs(selected) do
                                if s == opt then table.remove(selected, i); break end
                            end
                        else
                            table.insert(selected, opt)
                        end
                    else
                        selected = {opt}
                    end
                    -- update tick marks
                    for _, ob in ipairs(optionBtns) do
                        ob.label.Text = (isSelected(ob.name) and "✓  " or "   ") .. ob.name
                    end
                    refreshVisuals()
                    if cfg.Callback then
                        pcall(cfg.Callback, multi and selected or selected[1])
                    end
                    if cfg.Flag then Window.Flags[cfg.Flag] = multi and selected or selected[1] end
                    if not multi then
                        -- close after single selection
                        isOpen = false
                        Tween(card, {Size = UDim2.new(1, 0, 0, closedH)}, 0.25, Enum.EasingStyle.Back)
                        sep.Visible = false
                        listFrame.Visible = false
                        arrow.Text = "▾"
                    end
                end)
            end

            -- Toggle open/close
            local interact = Create("TextButton", {
                Size             = UDim2.new(1, 0, 0, closedH),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 3,
                Parent           = card,
            })
            interact.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local openH = closedH + math.min(#options, 5) * ITEM_H + 4
                if isOpen then
                    listFrame.Visible = true
                    sep.Visible = true
                    arrow.Text  = "▴"
                    Tween(card, {Size = UDim2.new(1, 0, 0, openH)}, 0.25, Enum.EasingStyle.Back)
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, math.min(#options, 5) * ITEM_H)}, 0.2)
                else
                    arrow.Text = "▾"
                    Tween(card, {Size = UDim2.new(1, 0, 0, closedH)}, 0.2, Enum.EasingStyle.Back)
                    Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                    task.delay(0.2, function()
                        sep.Visible = false
                        listFrame.Visible = false
                    end)
                end
            end)
            interact.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = t.Surface}, 0.15) end)
            interact.MouseLeave:Connect(function() if not isOpen then Tween(card, {BackgroundColor3 = t.Card}, 0.15) end end)

            local handle = {}
            function handle:Set(newOpt)
                if type(newOpt) == "string" then newOpt = {newOpt} end
                selected = newOpt
                for _, ob in ipairs(optionBtns) do
                    ob.label.Text = (isSelected(ob.name) and "✓  " or "   ") .. ob.name
                end
                refreshVisuals()
                if cfg.Flag then Window.Flags[cfg.Flag] = multi and selected or selected[1] end
            end
            function handle:Refresh(newOptions)
                -- clear and rebuild
                options = newOptions
                for _, ob in ipairs(optionBtns) do ob.frame:Destroy() end
                optionBtns = {}
                listFrame.CanvasSize = UDim2.new(0, 0, 0, #newOptions * ITEM_H)
                for _, opt in ipairs(newOptions) do
                    local row = Create("Frame", {Size=UDim2.new(1,0,0,ITEM_H), BackgroundColor3=isSelected(opt) and t.Primary or t.Surface, BorderSizePixel=0, ZIndex=4, Parent=listFrame})
                    local rowLbl = Create("TextLabel", {Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Text=(isSelected(opt) and "✓  " or "   ")..opt, TextColor3=isSelected(opt) and t.Text or t.SubText, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4, Parent=row})
                    local rowBtn = Create("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5, Parent=row})
                    table.insert(optionBtns, {frame=row, label=rowLbl, name=opt})
                    rowBtn.MouseButton1Click:Connect(function()
                        if multi then
                            if isSelected(opt) then for i,s in ipairs(selected) do if s==opt then table.remove(selected,i);break end end
                            else table.insert(selected, opt) end
                        else selected={opt} end
                        for _,ob in ipairs(optionBtns) do ob.label.Text=(isSelected(ob.name) and "✓  " or "   ")..ob.name end
                        refreshVisuals()
                        if cfg.Callback then pcall(cfg.Callback, multi and selected or selected[1]) end
                        if not multi then
                            isOpen=false; Tween(card,{Size=UDim2.new(1,0,0,closedH)},0.25,Enum.EasingStyle.Back); sep.Visible=false; listFrame.Visible=false; arrow.Text="▾"
                        end
                    end)
                end
            end
            function handle:Get() return multi and selected or selected[1] end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  COLOR PICKER  (NEW – HSV 2D pad + hue strip + hex + RGB)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateColorPicker(cfg)
            cfg = cfg or {}
            local color = cfg.Default or cfg.Color or Color3.fromRGB(130,185,255)
            local h, s, v = color:ToHSV()
            local isOpen  = false

            local closedH = 44
            local card    = MakeCard(closedH)
            card.ClipsDescendants = true

            MakeLabel(card, cfg.Name or "Color",
                Enum.Font.GothamSemibold, 13, t.Text, Enum.TextXAlignment.Left,
                UDim2.new(0, 14, 0, 0), UDim2.new(0.7, 0, 0, closedH), 2)

            -- Color preview swatch
            local swatch = Create("Frame", {
                Size             = UDim2.new(0, 28, 0, 20),
                Position         = UDim2.new(1, -42, 0.5, -10),
                BackgroundColor3 = color,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = card,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = swatch})
            Create("UIStroke",  {Color = t.Border, Thickness = 1, Parent = swatch})

            -- Dropdown arrow
            local arrow = Create("TextLabel", {
                Size             = UDim2.new(0, 14, 0, closedH),
                Position         = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = t.SubText,
                Font             = Enum.Font.GothamBold,
                TextSize         = 14,
                ZIndex           = 2,
                Parent           = card,
            })

            -- ── PANEL (hidden by default) ──────────────────────────
            local panelH = 170
            local panel = Create("Frame", {
                Size             = UDim2.new(1, -20, 0, panelH),
                Position         = UDim2.new(0, 10, 0, closedH + 4),
                BackgroundTransparency = 1,
                Visible          = false,
                ZIndex           = 3,
                Parent           = card,
            })

            -- SV 2D pad
            local pad = Create("Frame", {
                Size             = UDim2.new(0, 120, 0, 90),
                Position         = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = panel,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = pad})
            -- saturation white gradient
            local satGrad = Create("Frame", {
                Size             = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 0,
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = pad,
            })
            Create("UICorner", {CornerRadius=UDim.new(0,6), Parent=satGrad})
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Rotation = 0,
                Parent = satGrad,
            })
            -- value black gradient
            local valGrad = Create("Frame", {
                Size             = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 0,
                BorderSizePixel  = 0,
                ZIndex           = 6,
                Parent           = pad,
            })
            Create("UICorner", {CornerRadius=UDim.new(0,6), Parent=valGrad})
            Create("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Rotation = 90,
                Parent = valGrad,
            })
            -- SV cursor
            local svCursor = Create("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                ZIndex           = 7,
                Parent           = pad,
            })
            Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=svCursor})
            Create("UIStroke",  {Color=Color3.fromRGB(0,0,0), Thickness=1.5, Parent=svCursor})

            -- Hue strip (vertical, right side)
            local hueStrip = Create("Frame", {
                Size             = UDim2.new(0, 18, 0, 90),
                Position         = UDim2.new(0, 128, 0, 0),
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = panel,
            })
            Create("UICorner", {CornerRadius=UDim.new(0,6), Parent=hueStrip})
            -- rainbow gradient for hue strip
            local hueColors = {}
            for i = 0, 6 do
                table.insert(hueColors, ColorSequenceKeypoint.new(i/6, Color3.fromHSV(i/6, 1, 1)))
            end
            Create("UIGradient", {
                Color    = ColorSequence.new(hueColors),
                Rotation = 90,
                Parent   = hueStrip,
            })
            local hueCursor = Create("Frame", {
                Size             = UDim2.new(1, 4, 0, 4),
                Position         = UDim2.new(0, -2, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = hueStrip,
            })
            Create("UIStroke", {Color=Color3.fromRGB(0,0,0), Thickness=1.5, Parent=hueCursor})

            -- Hex input
            local hexFrame = Create("Frame", {
                Size             = UDim2.new(0, 90, 0, 24),
                Position         = UDim2.new(0, 0, 0, 98),
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = panel,
            })
            Create("UICorner", {CornerRadius=UDim.new(0,6), Parent=hexFrame})
            Create("UIStroke",  {Color=t.Border, Thickness=1, Parent=hexFrame})
            local hexBox = Create("TextBox", {
                Size             = UDim2.new(1,-8,1,0),
                Position         = UDim2.new(0,4,0,0),
                BackgroundTransparency = 1,
                Text             = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                TextColor3       = t.Text,
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                ZIndex           = 5,
                ClearTextOnFocus = false,
                Parent           = hexFrame,
            })

            -- RGB row
            local function makeRGBBox(label, xPos)
                local f = Create("Frame", {
                    Size=UDim2.new(0,38,0,24),
                    Position=UDim2.new(0,xPos,0,128),
                    BackgroundColor3=t.Surface,
                    BorderSizePixel=0,
                    ZIndex=4,
                    Parent=panel,
                })
                Create("UICorner",{CornerRadius=UDim.new(0,6),Parent=f})
                Create("UIStroke",{Color=t.Border,Thickness=1,Parent=f})
                Create("TextLabel",{
                    Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,0,-12),
                    BackgroundTransparency=1, Text=label,
                    TextColor3=t.SubText, Font=Enum.Font.GothamBold, TextSize=9,
                    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4, Parent=f,
                })
                local box = Create("TextBox",{
                    Size=UDim2.new(1,-4,1,0), Position=UDim2.new(0,2,0,0),
                    BackgroundTransparency=1, Text="",
                    TextColor3=t.Text, Font=Enum.Font.GothamBold, TextSize=11,
                    ZIndex=5, ClearTextOnFocus=false, Parent=f,
                })
                return box
            end
            local rBox = makeRGBBox("R", 0)
            local gBox = makeRGBBox("G", 42)
            local bBox = makeRGBBox("B", 84)

            local function getColor() return Color3.fromHSV(h, s, v) end

            local function updateUI()
                local c = getColor()
                pad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                swatch.BackgroundColor3 = c
                svCursor.Position = UDim2.new(s, -5, 1-v, -5)
                hueCursor.Position = UDim2.new(0,-2, h, -2)
                hexBox.Text = string.format("#%02X%02X%02X", math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
                rBox.Text = tostring(math.floor(c.R*255+0.5))
                gBox.Text = tostring(math.floor(c.G*255+0.5))
                bBox.Text = tostring(math.floor(c.B*255+0.5))
            end
            updateUI()

            local function fireCallback()
                local c = getColor()
                if cfg.Callback then pcall(cfg.Callback, c) end
                if cfg.Flag then Window.Flags[cfg.Flag] = c end
            end

            -- SV pad drag
            local svDrag = false
            local svInteract = Create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8,Parent=pad})
            svInteract.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then svDrag=true end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then svDrag=false end
            end)
            RunService.RenderStepped:Connect(function()
                if svDrag then
                    local pos = UserInputService:GetMouseLocation()
                    local mx = pos.X
                    local my = pos.Y
                    local px = pad.AbsolutePosition.X; local py = pad.AbsolutePosition.Y
                    local pw = pad.AbsoluteSize.X;     local ph = pad.AbsoluteSize.Y
                    s = math.clamp((mx-px)/pw, 0, 1)
                    v = 1 - math.clamp((my-py)/ph, 0, 1)
                    updateUI(); fireCallback()
                end
            end)

            -- Hue strip drag
            local hueDrag = false
            local hueInteract = Create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=6,Parent=hueStrip})
            hueInteract.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then hueDrag=true end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then hueDrag=false end
            end)
            RunService.RenderStepped:Connect(function()
                if hueDrag then
                    local my = UserInputService:GetMouseLocation().Y
                    local py = hueStrip.AbsolutePosition.Y
                    local ph = hueStrip.AbsoluteSize.Y
                    h = math.clamp((my-py)/ph, 0, 1)
                    updateUI(); fireCallback()
                end
            end)

            -- Hex input
            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#","")
                if #hex == 6 then
                    local r2,g2,b2 = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
                    if r2 and g2 and b2 then
                        local c = Color3.fromRGB(r2,g2,b2)
                        h,s,v = c:ToHSV()
                        updateUI(); fireCallback()
                    end
                end
            end)

            -- RGB inputs
            local function rgbFocusLost()
                local r2 = tonumber(rBox.Text) or 0
                local g2 = tonumber(gBox.Text) or 0
                local b2 = tonumber(bBox.Text) or 0
                local c = Color3.fromRGB(
                    math.clamp(r2,0,255),
                    math.clamp(g2,0,255),
                    math.clamp(b2,0,255)
                )
                h,s,v = c:ToHSV()
                updateUI(); fireCallback()
            end
            rBox.FocusLost:Connect(rgbFocusLost)
            gBox.FocusLost:Connect(rgbFocusLost)
            bBox.FocusLost:Connect(rgbFocusLost)

            -- Toggle open/close
            local interact = Create("TextButton",{
                Size=UDim2.new(1,0,0,closedH), BackgroundTransparency=1, Text="", ZIndex=3, Parent=card,
            })
            interact.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    panel.Visible = true
                    arrow.Text    = "▴"
                    Tween(card, {Size=UDim2.new(1,0,0,closedH+panelH+16)}, 0.25, Enum.EasingStyle.Back)
                else
                    arrow.Text = "▾"
                    Tween(card, {Size=UDim2.new(1,0,0,closedH)}, 0.2)
                    task.delay(0.22, function() panel.Visible = false end)
                end
            end)
            interact.MouseEnter:Connect(function() Tween(card,{BackgroundColor3=t.Surface},0.15) end)
            interact.MouseLeave:Connect(function() if not isOpen then Tween(card,{BackgroundColor3=t.Card},0.15) end end)

            local handle = {}
            function handle:Set(newColor)
                h,s,v = newColor:ToHSV()
                updateUI()
                if cfg.Flag then Window.Flags[cfg.Flag] = newColor end
            end
            function handle:Get() return getColor() end
            return handle
        end

        -- ──────────────────────────────────────────────────────────
        --  THEME SELECTOR  (combined dropdown + swatches)
        -- ──────────────────────────────────────────────────────────
        function Tab:CreateThemeSelector(cfg)
            cfg = cfg or {}
            self:CreateSection(cfg.Name or "Sky Themes")

            local themeNames = {}
            for k in pairs(Themes) do table.insert(themeNames, k) end
            table.sort(themeNames)

            self:CreateDropdown({
                Name     = "Active Theme",
                Options  = themeNames,
                Default  = cfg.Default or "Cumulus",
                Callback = function(chosen)
                    Window:ApplyTheme(chosen)
                    if cfg.Callback then cfg.Callback(chosen) end
                end,
            })

            -- Swatches
            local swatchCard = MakeCard(56)
            swatchCard.Size  = UDim2.new(1, 0, 0, 56)
            Create("UIGridLayout", {
                CellSize            = UDim2.new(0, 24, 0, 24),
                CellPadding         = UDim2.new(0, 6, 0, 6),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Parent              = swatchCard,
            })
            Create("UIPadding", {
                PaddingLeft=UDim.new(0,10), PaddingTop=UDim.new(0,8),
                Parent=swatchCard,
            })
            for _, name in ipairs(themeNames) do
                local th = Themes[name]
                local sw = Create("TextButton", {
                    Size             = UDim2.new(0,24,0,24),
                    BackgroundColor3 = th.Primary,
                    Text             = "",
                    ZIndex           = 3,
                    Parent           = swatchCard,
                })
                Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=sw})
                Create("UIStroke",  {Color=Color3.fromRGB(255,255,255), Transparency=0.65, Thickness=1.5, Parent=sw})
                sw.MouseButton1Click:Connect(function()
                    Window:ApplyTheme(name)
                    if cfg.Callback then cfg.Callback(name) end
                end)
                sw.MouseEnter:Connect(function() Tween(sw,{Size=UDim2.new(0,28,0,28)},0.12) end)
                sw.MouseLeave:Connect(function() Tween(sw,{Size=UDim2.new(0,24,0,24)},0.12) end)
            end
        end

        -- Notify shortcut on Tab
        function Tab:Notify(cfg) Window:Notify(cfg) end

        return Tab
    end -- CreateTab

    -- // Animate open
    Main.Position = UDim2.new(0.5, 0, 0.3, 0)
    Main.BackgroundTransparency = 1
    Tween(Main, {
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0
    }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return Window
end -- CreateWindow

return CloudyLib
