-- Modern UI Library
local library = {
    flags = {},
    items = {},
    theme = {
        -- Main Colors
        ["Background"] = Color3.fromRGB(25, 25, 25),
        ["Accent"] = Color3.fromRGB(65, 105, 225), -- Royal Blue
        ["Light Accent"] = Color3.fromRGB(85, 125, 245),
        ["Dark Accent"] = Color3.fromRGB(45, 85, 205),
        
        -- UI Elements
        ["Section Background"] = Color3.fromRGB(30, 30, 30),
        ["Element Background"] = Color3.fromRGB(35, 35, 35),
        ["Selected"] = Color3.fromRGB(40, 40, 40),
        ["Hover"] = Color3.fromRGB(45, 45, 45),
        
        -- Text Colors
        ["Text"] = Color3.fromRGB(255, 255, 255),
        ["Dim Text"] = Color3.fromRGB(175, 175, 175),
        ["Dark Text"] = Color3.fromRGB(125, 125, 125),
        
        -- Border Colors
        ["Border"] = Color3.fromRGB(40, 40, 40),
        ["Dark Border"] = Color3.fromRGB(20, 20, 20),
    }
}

-- Utility Functions
local utility = {}

function utility.create(class, properties)
    local obj = Drawing.new(class)
    
    for prop, value in next, properties do
        obj[prop] = value
    end
    
    if not properties.Visible then
        obj.Visible = true  -- Make visible by default
    end
    
    return obj
end

function utility.round(number, float)
    if float then
        return math.floor(number * 10^float) / 10^float
    else
        return math.floor(number)
    end
end

function utility.lerp(start, goal, alpha)
    return start + (goal - start) * alpha
end

function utility.tween(obj, prop, goal, time, callback)
    local start = obj[prop]
    local elapsed = 0
    
    -- Animation loop
    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function(delta)
        elapsed = elapsed + delta
        
        if elapsed >= time then
            obj[prop] = goal
            connection:Disconnect()
            if callback then callback() end
            return
        end
        
        local alpha = elapsed / time
        obj[prop] = utility.lerp(start, goal, alpha)
    end)
end

-- Modern Window Creation
function library:CreateWindow(options)
    local window = {
        dragging = false,
        drag_offset = Vector2.new(),
        size = Vector2.new(options.width or 600, options.height or 400)
    }
    
    -- Main Window Frame
    window.frame = utility.create("Square", {
        Size = UDim2.new(0, window.size.X, 0, window.size.Y),
        Position = UDim2.new(0.5, -window.size.X/2, 0.5, -window.size.Y/2),
        Color = library.theme.Background,
        Filled = true,
        Thickness = 0,
        ZIndex = 100
    })
    
    -- Window Border (Rounded Corners)
    window.border = utility.create("Square", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        Color = library.theme.Border,
        Filled = false,
        Thickness = 2,
        Parent = window.frame,
        ZIndex = 99
    })
    
    -- Title Bar
    window.titlebar = utility.create("Square", {
        Size = UDim2.new(1, 0, 0, 30),
        Color = library.theme["Section Background"],
        Filled = true,
        Parent = window.frame,
        ZIndex = 101
    })
    
    -- Title Text
    window.title = utility.create("Text", {
        Text = options.title or "Modern UI",
        Font = Drawing.Fonts.Plex,
        Size = 16,
        Position = UDim2.new(0, 10, 0, 8),
        Color = library.theme.Text,
        ZIndex = 102,
        Parent = window.titlebar,
        Outline = true
    })
    
    -- Content Container
    window.container = utility.create("Square", {
        Size = UDim2.new(1, -20, 1, -45),
        Position = UDim2.new(0, 10, 0, 35),
        Transparency = 0,
        Parent = window.frame,
        ZIndex = 101
    })
    
    -- Dragging Functionality
    do
        window.titlebar.MouseButton1Down:Connect(function(input)
            window.dragging = true
            window.drag_offset = window.frame.Position - input
        end)
        
        window.titlebar.MouseButton1Up:Connect(function()
            window.dragging = false
        end)
        
        window.titlebar.MouseLeave:Connect(function()
            window.dragging = false
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if window.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                utility.tween(window.frame, "Position", 
                    window.drag_offset + input,
                    0.1 -- Smooth dragging
                )
            end
        end)
    end
    
    -- Tab System
    function window:AddTab(name)
        local tab = {
            name = name,
            sections = {}
        }
        
        -- Tab Container
        tab.container = utility.create("Square", {
            Size = UDim2.new(1, 0, 1, 0),
            Transparency = 0,
            Visible = false,
            Parent = window.container,
            ZIndex = 102
        })
        
        function tab:AddSection(options)
            local section = {
                name = options.name,
                size = options.size or UDim2.new(0.5, -5, 0, 0),
                position = options.position or UDim2.new(0, 0, 0, 0)
            }
            
            -- Section Container
            section.main = utility.create("Square", {
                Size = section.size,
                Position = section.position,
                Color = library.theme["Section Background"],
                Filled = true,
                Parent = tab.container,
                ZIndex = 103
            })
            
            -- Section Title
            section.title = utility.create("Text", {
                Text = section.name,
                Font = Drawing.Fonts.Plex,
                Size = 15,
                Position = UDim2.new(0, 10, 0, 8),
                Color = library.theme.Text,
                Parent = section.main,
                ZIndex = 104,
                Outline = true
            })
            
            -- Section Content
            section.content = utility.create("Square", {
                Size = UDim2.new(1, -20, 1, -35),
                Position = UDim2.new(0, 10, 0, 25),
                Transparency = 0,
                Parent = section.main,
                ZIndex = 104
            })
            
            -- Add Elements Functions
            function section:AddButton(options)
                local button = {}
                
                button.main = utility.create("Square", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Color = library.theme["Element Background"],
                    Filled = true,
                    Parent = section.content,
                    ZIndex = 105
                })
                
                button.title = utility.create("Text", {
                    Text = options.name,
                    Font = Drawing.Fonts.Plex,
                    Size = 14,
                    Center = true,
                    Position = UDim2.new(0.5, 0, 0, 8),
                    Color = library.theme.Text,
                    Parent = button.main,
                    ZIndex = 106,
                    Outline = true
                })
                
                -- Hover Effect
                button.main.MouseEnter:Connect(function()
                    utility.tween(button.main, "Color", library.theme.Hover, 0.2)
                end)
                
                button.main.MouseLeave:Connect(function()
                    utility.tween(button.main, "Color", library.theme["Element Background"], 0.2)
                end)
                
                button.main.MouseButton1Click:Connect(function()
                    utility.tween(button.main, "Color", library.theme.Selected, 0.1)
                    if options.callback then
                        options.callback()
                    end
                    wait(0.1)
                    utility.tween(button.main, "Color", library.theme["Element Background"], 0.1)
                end)
                
                return button
            end
            
            -- Add more element types here (Toggle, Slider, etc.)
            
            return section
        end
        
        return tab
    end
    
    return window
end

return library
