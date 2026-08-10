#pragma once

#include <RED4ext/RED4ext.hpp>
#include <RED4ext/Scripting/Natives/Generated/game/ui/ProjectedHUDGameController.hpp>

namespace RED4ext::game::ui
{
struct MappinsContainerControllerExt : RED4ext::game::ui::ProjectedHUDGameController
{
    static constexpr const char* NAME = "gameuiMappinsContainerController";
    static constexpr const char* ALIAS = "MappinsContainerController";

    uint8_t unk160[0x218 - 0x160]; // 160

    WeakHandle<void> questMappin; // 1E8
    DynArray<Vector4> questMappinPoints; // 1F8
    uint64_t hasQuestMappin; // 208
    WeakHandle<void> poiMappin; // 210
    DynArray<Vector4> poiMappinPoints; // 220
    uint64_t hasPoiMappin; // 230
    uint64_t unk220; // 240
    volatile signed __int8 needsUpdateMaybe; // 248
    uint64_t unk270_new[6];
    Handle<void> callback[4]; // 250
    int32_t psmVision; // 288
    int32_t psmCombat; // 28C
    int32_t psmZone; // 290
    int32_t tier; // 294
    uint32_t braindance;
    uint32_t unk284;
    void* unk288[3];
    volatile signed __int8 mappinsNeedUpdatingMaybe;
    DynArray<Handle<void>> mappins;
    Handle<void> insert;
};
RED4EXT_ASSERT_SIZE(MappinsContainerControllerExt, 0x340);

struct MinimapContainerControllerExt : MappinsContainerControllerExt
{
    static constexpr const char* NAME = "gameuiMinimapContainerController";
    static constexpr const char* ALIAS = "MinimapContainerController";
    uint8_t unk340[696]; // 340
};
RED4EXT_ASSERT_SIZE(MinimapContainerControllerExt, 0x5F8);
}
