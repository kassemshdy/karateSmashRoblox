-- The temporary runner plugin also loads in child server/client sessions.
-- Only the edit session may launch the test or signal the runner to finish.
if not game:GetService("RunService"):IsEdit() or not game.ServerScriptService:FindFirstChild("Phase1Tests") then
    task.wait(100000000)
end
local result = game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2, "KaratePhase1")
assert(result == "PHASE1_ALL_TESTS_PASSED", tostring(result))
print(result)
