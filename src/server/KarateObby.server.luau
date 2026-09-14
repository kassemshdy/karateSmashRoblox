local world = workspace:WaitForChild("JawadKarateWorld")
world:WaitForChild("DojoSign")
require(script.Parent.Obby.Service).start(world)
