
-- DolmenComponent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local DolmenComponent = React.Component:extend("DolmenComponent")
function DolmenComponent:init(props)
    self.props = props or {}
    self.props._ref = self.props._ref or React.createRef()
end
function DolmenComponent:render()
    return React.createElement("Model", {
        key=self.props._key or 'Dolmen1',
        ref=self.props._ref,
        --Position=props.Position or Vector3.new(0, 0, 0),
    }, {
        Dolmen = React.createElement("Part", {
            Position=Vector3.new(0, 26, -106),
            Orientation=Vector3.new(21, 0, 78),
            Size=Vector3.new(37,12,3),
            Color=Color3.fromHex("#333333"),
            Transparency=0.9,
            Anchored=true,
            Name="AreaVolumeCube1_Label",
        }, {
            SurfaceGuiFront = React.createElement("SurfaceGui", {
                Face=Enum.NormalId.Front,
                --CanvasSize=Vector2.new(200, 200),
                ResetOnSpawn=false,
                ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
                SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud,
                PixelsPerStud=28,
            }, {
                TextLabel1 = React.createElement("TextLabel", {
                    Text="Area Volume Cube",
                    TextColor3=Color3.fromHex("#cccccc"),
                    FontSize=Enum.FontSize.Size96,
                    Font=Enum.Font.GothamBold,
                    --FontWeight=Enum.FontWeight.Bold,
                    TextScaled=false,
                    TextWrapped=false,
                    TextXAlignment=Enum.TextXAlignment.Center,
                    TextYAlignment=Enum.TextYAlignment.Center,
                    BackgroundTransparency=1,
                    ZIndex=2,
                    Size=UDim2.new(0.8, 0, 0.8, 0),
                    Position=UDim2.new(0.1, 0, 0.1, 0),
                }),
                TextLabel2 = React.createElement("TextLabel", {
                    Text="#stemgame",
                    TextColor3=Color3.fromHex("#9c9999"),
                    FontSize=Enum.FontSize.Size60,
                    TextScaled=false,
                    TextWrapped=false,
                    TextXAlignment=Enum.TextXAlignment.Center,
                    TextYAlignment=Enum.TextYAlignment.Center,
                    BackgroundTransparency=1,
                    ZIndex=3,
                    Size=UDim2.new(0.4, 0, 0.1, 0),
                    Position=UDim2.new(0.55, 0, 0.95, 0),
                })
            })
        }),

        areaVolumeCube1_dolmen_pillar2 = React.createElement("Part", {
            Position=Vector3.new(-3.82, 21.43, -93.68),
            Orientation=Vector3.new(-26, -40.2, 86.86),
            Size=Vector3.new(30,10,2),
            Color=Color3.fromHex("#333333"),
            Transparency=0.7,
            Anchored=true,
        }),

        areaVolumeCube1_dolmen_pillar3 = React.createElement("Part", {
            Position=Vector3.new(9.21, 21.90, -93.35),
            Orientation=Vector3.new(-17.42, 55, 89.71),
            Size=Vector3.new(30.4, 14.92, 2.03),
            Color=Color3.fromHex("#333333"),
            Transparency=0.7,
            Anchored=true,
        }),

        areaVolumeCube1_dolmen_lid1 = React.createElement("Part", {
            Position=Vector3.new(4.92, 37.92, -91.42),
            Orientation=Vector3.new(0.43, -3.14, 97.85),
            Size=Vector3.new(3,27.6,16),
            --Color=Color3.fromHex("#333333"),
            --BrickColor=BrickColor.new("Bright blue"),
            Material=Enum.Material.Neon,
            Color=Color3.fromRGB(7, 116, 140),
            Transparency=0.6,
            Anchored=true,
        }, {
            surfaceLight_up = React.createElement("SurfaceLight", {
                Brightness=2.1,
                Face=Enum.NormalId.Right,
                Color=Color3.new(60, 219, 255),
            }),
            surfaceLight_down = React.createElement("SurfaceLight", {
                Brightness=6.5,
                Face=Enum.NormalId.Left,
                Color=Color3.new(130, 245, 255),
            })
        })
    })
end

return DolmenComponent