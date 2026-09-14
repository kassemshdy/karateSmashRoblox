local Lighting = game:GetService("Lighting")
return function()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2.5
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(119, 130, 151)
    Lighting.OutdoorAmbient = Color3.fromRGB(151, 159, 173)
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Density = 0.25
    atmosphere.Offset = 0.15
    atmosphere.Color = Color3.fromRGB(199, 225, 245)
    atmosphere.Decay = Color3.fromRGB(136, 159, 177)
    atmosphere.Haze = 1.2
    atmosphere.Parent = Lighting
    local grade = Instance.new("ColorCorrectionEffect")
    grade.Name = "KarateColorGrade"
    grade.Contrast = 0.12
    grade.Saturation = 0.14
    grade.TintColor = Color3.fromRGB(255, 247, 233)
    grade.Parent = Lighting
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "KarateBloom"
    bloom.Intensity = 0.15
    bloom.Size = 18
    bloom.Threshold = 1.4
    bloom.Parent = Lighting
end
