/*
 * This module allows players to have multiple SPELL_AURA_TRACK_RESOURCES auras
 * active at the same time.
 *
 * By default, all tracking spells share the SPELL_SPECIFIC_TRACKER exclusivity
 * group, which means activating one tracker removes any other active tracker.
 * The aura handler (HandleAuraTrackResources) already uses independent bit flags
 * in PLAYER_TRACK_RESOURCES, so only the exclusivity classification needs removing.
 *
 * This module uses the OnLoadSpellCustomAttr hook to override _spellSpecific
 * to SPELL_SPECIFIC_NORMAL for every spell that applies SPELL_AURA_TRACK_RESOURCES,
 * allowing them to coexist without removing one another.
 */

#include "GlobalScript.h"
#include "SpellAuraDefines.h"
#include "SpellInfo.h"

class TrackResourcesMultiGlobalScript : public GlobalScript
{
public:
    TrackResourcesMultiGlobalScript() : GlobalScript("TrackResourcesMultiGlobalScript") { }

    void OnLoadSpellCustomAttr(SpellInfo* spell) override
    {
        for (uint8 i = 0; i < MAX_SPELL_EFFECTS; ++i)
        {
            if (spell->Effects[i].ApplyAuraName == SPELL_AURA_TRACK_RESOURCES)
            {
                // Remove from the exclusive SPELL_SPECIFIC_TRACKER group so multiple
                // resource tracking auras can be active simultaneously.
                spell->_spellSpecific = SPELL_SPECIFIC_NORMAL;
                return;
            }
        }
    }
};

void AddSC_TrackResourcesMulti()
{
    new TrackResourcesMultiGlobalScript();
}
