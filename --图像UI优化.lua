--图像UI优化版本
local rgbasupported = getrawmetatable and setrawmetatable and newcclosure
local firsttabsignal
local drawing = {}

-- 优化的服务获取
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

-- 保持原有的Signal系统，但优化实现
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindableEvent = Instance.new("BindableEvent")
    self._argMap = {}
    return self
end

function Signal:Fire(...)
    if not self._bindableEvent then return end
    local args = table.pack(...)
    local key = services.HttpService:GenerateGUID(false)
    self._argMap[key] = args
    self._bindableEvent:Fire(key)
end

function Signal:Connect(handler)
    return self._bindableEvent.Event:Connect(function(key)
        local args = self._argMap[key]
        if args then
            handler(table.unpack(args, 1, args.n))
        end
    end)
end

-- 优化的绘图系统
do
    local objchildren = {}
    local objmts = {}
    local objvisibles = {}
    local mtobjs = {}
    local squares = {}
    
    function drawing:new(shape)
        local obj = Drawing.new(shape)
        obj.Visible = false
        
        if shape == "Square" then
            table.insert(squares, obj)
        end
        
        local mt = setmetatable({exists = true}, {
            __index = function(self, k)
                if k == "Parent" then
                    return self._parent
                end
                return obj[k]
            end,
            
            __newindex = function(self, k, v)
                if k == "Parent" then
                    self._parent = v
                    if v then
                        objchildren[v] = objchildren[v] or {}
                        table.insert(objchildren[v], obj)
                    end
                    return
                end
                obj[k] = v
            end
        })
        
        objmts[obj] = mt
        mtobjs[mt] = obj
        objchildren[mt] = {}
        
        return mt
    end
end

-- 现代化主题系统
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
local utility = {}

function utility.create(class, properties)
    local obj = drawing:new(class)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

function utility.getcenter(sizeX, sizeY)
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end

-- 保持原有库的核心功能
local library = {
    theme = themes.Default,
    folder = "AirHub V2",
    flags = {},
    open = false,
    mousestate = services.InputService.MouseIconEnabled,
    connections = {}
}

-- 窗口创建函数
function library:CreateWindow(props)
    local window = {
        title = props.Title or "Aimbot UI",
        theme = props.Theme or "Default",
        sizeX = props.SizeX or 600,
        sizeY = props.SizeY or 400
    }
    
    -- 创建主窗口UI
    window.main = utility.create("Square", {
        Size = UDim2.new(0, window.sizeX, 0, window.sizeY),
        Position = utility.getcenter(window.sizeX, window.sizeY),
        Color = themes[window.theme]["Window Background"],
        Filled = true
    })
    
    -- 添加标题栏
    window.titlebar = utility.create("Square", {
        Size = UDim2.new(1, 0, 0, 30),
        Color = themes[window.theme]["Window Border"],
        Filled = true,
        Parent = window.main
    })
    
    -- 添加拖动功能
    local dragging = false
    local dragStart
    local startPos
    
    window.titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.main.Position
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
    
    -- 保持原有功能的实现...
    
    return window
end

-- 保持其他原有功能的实现...

return library
