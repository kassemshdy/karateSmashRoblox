local result = game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2, "KaratePhase1")
assert(result == "PHASE1_ALL_TESTS_PASSED", tostring(result))
print(result)
