-- Optional script (ALE) for multi-tracking toggle of tracking spells (herbs, minerals, treasure)
-- Allows to toggle tracking auras on/off by casting the same tracking spell again, without needing to open the spellbook or use macros
-- The Client itself does not toggle the aura on/off, just tries to apply the aura on spellcast
-- Playerbot friendly, ignores all accounts with "RNDBOT" in the name and lets them cast normally without tracking

local TrackingSpells = {
    [2383] = true, -- find herbs
    [2580] = true, -- find minerals
    [2481] = true  -- find treasure
}

local TrackingAuraState = {}

local function HupWoW_MultiTrackingToggle(event, caster, spell, skipCheck)
    local spellId = spell:GetEntry()
    
    if TrackingSpells[spellId] then
        local accountName = caster:GetAccountName()
        if string.find(accountName, "RNDBOT") then
            return true
        end
        
        local playerGUID = caster:GetGUIDLow()
        
        local hadAuraBefore = TrackingAuraState[playerGUID .. "_" .. spellId]
        
        if hadAuraBefore then
            TrackingAuraState[playerGUID .. "_" .. spellId] = nil
            caster:RemoveAura(spellId)
            return false
        else
            TrackingAuraState[playerGUID .. "_" .. spellId] = true
            return true
        end
    end
end

local function InitializeTrackingState(event, player)
    local accountName = player:GetAccountName()
    if string.find(accountName, "RNDBOT") then
        return
    end
    
    local playerGUID = player:GetGUIDLow()
    for spellId, _ in pairs(TrackingSpells) do
        if player:HasAura(spellId) then
            TrackingAuraState[playerGUID .. "_" .. spellId] = true
        end
    end
end

for spellId, _ in pairs(TrackingSpells) do
     RegisterSpellEvent(spellId, 2, HupWoW_MultiTrackingToggle)
end

RegisterPlayerEvent(3, InitializeTrackingState)