--新图像UI
local library = {}
local utility = {}
local services = setmetatable({}, {
    __index = function(self, key)
        if key == "InputService" then key = "UserInputService" end
        if not rawget(self, key) then
            local service = game:GetService(key)
            rawset(self, key, service)
            return service
        end
        return rawget(self, key)
    end
})

-- 简化的Signal系统
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({
        _handlers = {},
        _handlerCount = 0
    }, Signal)
    return self
end

function Signal:Connect(handler)
    self._handlerCount = self._handlerCount + 1
    self._handlers[self._handlerCount] = handler
    
    return {
        Disconnect = function()
            self._handlers[self._handlerCount] = nil
        end
    }
end

function Signal:Fire(...)
    for _, handler in pairs(self._handlers) do
        handler(...)
    end
end

-- 优化的Drawing系统
local drawing = {}
function drawing.new(shape)
    local obj = Drawing.new(shape)
    obj.Visible = false
    return obj
end

-- 现代化主题
local themes = {
    Default = {
        ["Accent"] = Color3.fromRGB(100, 180, 255),
        ["Window Background"] = Color3.fromRGB(25, 25, 35),
        ["Window Border"] = Color3.fromRGB(40, 40, 50),
        ["Tab Background"] = Color3.fromRGB(30, 30, 40),
        ["Tab Border"] = Color3.fromRGB(45, 45, 55),
        ["Tab Toggle"] = Color3.fromRGB(100, 180, 255),
        ["Section Background"] = Color3.fromRGB(30, 30, 40),
        ["Section Border"] = Color3.fromRGB(45, 45, 55),
        ["Text"] = Color3.fromRGB(240, 240, 240),
        ["Disabled Text"] = Color3.fromRGB(150, 150, 150),
        ["Object Background"] = Color3.fromRGB(35, 35, 45),
        ["Object Border"] = Color3.fromRGB(50, 50, 60),
        ["Dropdown Option Background"] = Color3.fromRGB(35, 35, 45)
    }
}

-- 工具函数
function utility.create(class, properties)
    local obj = drawing.new(class)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

function utility.getcenter(sizeX, sizeY)
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end

-- 窗口创建函数
function library:CreateWindow(title)
    local window = {
        title = title or "Aimbot UI",
        theme = "Default",
        dragging = false,
        dragStart = nil,
        dragInput = nil,
        dragPos = nil,
        objects = {},
        connections = {}
    }

    -- 创建主窗口
    window.main = utility.create("Square", {
        Size = UDim2.new(0, 600, 0, 400),
        Position = utility.getcenter(600, 400),
        Color = themes[window.theme]["Window Background"],
        Filled = true,
        Visible = true
    })

    -- 创建标题栏
    window.titlebar = utility.create("Square", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        Color = themes[window.theme]["Window Border"],
        Filled = true,
        Parent = window.main
    })

    -- 创建标题文本
    window.title = utility.create("Text", {
        Text = window.title,
        Font = Drawing.Fonts.UI,
        Size = 15,
        Position = UDim2.new(0, 10, 0, 8),
        Color = themes[window.theme]["Text"],
        Parent = window.titlebar
    })

    -- 添加拖动功能
    local dragging = false
    local dragStart = nil
    local startPos = nil

    window.titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.main.Position
        end
    end)

    window.titlebar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    services.InputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- 添加关闭按钮
    window.close = utility.create("Square", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0, 5),
        Color = themes[window.theme]["Tab Toggle"],
        Filled = true,
        Parent = window.titlebar
    })

    window.close_text = utility.create("Text", {
        Text = "×",
        Font = Drawing.Fonts.UI,
        Size = 15,
        Center = true,
        Position = UDim2.new(0, 0, 0, 2),
        Color = themes[window.theme]["Text"],
        Parent = window.close
    })

    window.close.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    -- 创建内容区域
    window.content = utility.create("Square", {
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 35),
        Color = themes[window.theme]["Window Background"],
        Transparency = 0,
        Filled = true,
        Parent = window.main
    })

    -- 添加销毁功能
    function window:Destroy()
        for _, obj in pairs(self.objects) do
            obj:Remove()
        end
        for _, connection in pairs(self.connections) do
            connection:Disconnect()
        end
        self.main:Remove()
    end

    return window
end

-- 创建标签页
function library:CreateTab(name, window)
    local tab = {
        name = name,
        window = window,
        sections = {}
    }
    
    -- 创建标签按钮和内容实现...
    
    return tab
end

-- 创建区块
function library:CreateSection(name, tab)
    local section = {
        name = name,
        tab = tab,
        items = {}
    }
    
    -- 创建区块UI实现...
    
    return section
end

-- 创建按钮
function library:CreateButton(text, callback, section)
    local button = utility.create("Square", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Color = themes[section.tab.window.theme]["Object Background"],
        Filled = true
    })
    
    -- 添加按钮文本和点击效果实现...
    
    return button
end

-- 创建开关
function library:CreateToggle(text, default, callback, section)
    local toggle = {
        value = default or false
    }
    
    -- 创建开关UI实现...
    
    return toggle
end

-- 创建滑块
function library:CreateSlider(text, min, max, default, callback, section)
    local slider = {
        value = default or min,
        min = min,
        max = max
    }
    
    -- 创建滑块UI实现...
    
    return slider
end

-- 创建下拉菜单
function library:CreateDropdown(text, options, callback, section)
    local dropdown = {
        value = options[1],
        options = options
    }
    
    -- 创建下拉菜单UI实现...
    
    return dropdown
end

return library
