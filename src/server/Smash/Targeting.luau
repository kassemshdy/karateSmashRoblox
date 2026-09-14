local Parts = require(script.Parent.Parts)
return function(player, attack)
    local root = Parts.root(player)
    if not root then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character }
    -- Both target types use the same server-selected first hit and reach limit.
    return workspace:Raycast(root.Position, root.CFrame.LookVector * attack.Range, params)
end
