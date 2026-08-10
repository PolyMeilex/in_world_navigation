#include <RED4ext/InstanceType.hpp>
#include <RED4ext/RED4ext.hpp>
#include <RED4ext/RTTITypes.hpp>
#include <RED4ext/Scripting/IScriptable.hpp>
#include <iostream>

#include "stdafx.hpp"
#include "ext.hpp"
#include <RED4ext/Scripting/Natives/Generated/game/ui/MinimapContainerController.hpp>

#include <RED4ext/Scripting/Natives/Generated/game/FxResource.hpp>
#include <RED4ext/Scripting/Natives/Generated/red/ResourceReferenceScriptToken.hpp>
#include "InWorldNavigation.hpp"

void UpdateNavPath(
    RED4ext::game::ui::MinimapContainerController *mmcc, 
    __int64 updateContext, 
    unsigned __int8 targetType,
    RED4ext::ink::WidgetReference *widgetRef
);

decltype(&UpdateNavPath) UpdateNavPath_Original;

void UpdateNavPath(
    RED4ext::game::ui::MinimapContainerController *mmcc, 
    __int64 updateContext, 
    unsigned __int8 targetType,
    RED4ext::ink::WidgetReference *widgetRef
) {
  UpdateNavPath_Original(mmcc, updateContext, targetType, widgetRef);

  auto rtti = RED4ext::CRTTISystem::Get();
  if (mmcc->GetType() == rtti->GetClass("gameuiMinimapContainerController")) {
    auto fnp = InWorldNavigation::GetInstance();
    auto args = RED4ext::CStackType(rtti->GetType("Int32"), &targetType);
    auto stack = RED4ext::CStack(fnp, &args, 1, nullptr);
    auto update = rtti->GetClass("InWorldNavigation")->GetFunction("Update");
    if (update)
      update->Execute(&stack);
  }
}

void CastResRefToFxResource(RED4ext::IScriptable *aContext, RED4ext::CStackFrame *aFrame, RED4ext::game::FxResource *aOut, int64_t a4) {
  RED4ext::red::ResourceReferenceScriptToken value;
  RED4ext::GetParameter(aFrame, &value);
  aFrame->code++; // skip ParamEnd

  if (aOut) {
    aOut->effect.path = value.resource.path;
  }
}

RED4EXT_C_EXPORT void RED4EXT_CALL RegisterTypes() {
  InWorldNavigation::RegisterTypes();
}

RED4EXT_C_EXPORT void RED4EXT_CALL PostRegisterTypes() {
  InWorldNavigation::PostRegisterTypes();
  auto rtti = RED4ext::CRTTISystem::Get();

  auto ms = rtti->GetClass("gameuiMinimapContainerController");
  ms->props.PushBack(RED4ext::CProperty::Create(rtti->GetType("array:Vector4"), "questPoints", nullptr, offsetof(RED4ext::game::ui::MinimapContainerControllerExt, questMappinPoints)));
  ms->props.PushBack(RED4ext::CProperty::Create(rtti->GetType("array:Vector4"), "poiPoints", nullptr, offsetof(RED4ext::game::ui::MinimapContainerControllerExt, poiMappinPoints)));

  auto f = RED4ext::CGlobalFunction::Create("Cast;ResRef;FxResource", "Cast;ResRef;FxResource", &CastResRefToFxResource);
  rtti->RegisterFunction(f);
}

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason, const RED4ext::v1::Sdk *aSdk) {
  auto m_address = RED4ext::UniversalRelocBase::Resolve(3770693656) - reinterpret_cast<uintptr_t>(GetModuleHandle(nullptr));

  switch (aReason) {
  case RED4ext::v1::EMainReason::Load: {
    // Attach hooks, register RTTI types, add custom states or initialize your
    // application. DO NOT try to access the game's memory at this point, it
    // is not initialized yet.

    RED4ext::CRTTISystem::Get()->AddRegisterCallback(RegisterTypes);
    RED4ext::CRTTISystem::Get()->AddPostRegisterCallback(PostRegisterTypes);

    aSdk->scripts->Add(aHandle, L"packed.reds");
    aSdk->scripts->Add(aHandle, L"module.reds");

    while (!aSdk->hooking->Attach(aHandle, RED4EXT_OFFSET_TO_ADDR(m_address), reinterpret_cast<void*>(&UpdateNavPath), reinterpret_cast<void**>(&UpdateNavPath_Original))) {}

    break;
  }
  case RED4ext::v1::EMainReason::Unload: {
    // Free memory, detach hooks.
    // The game's memory is already freed, to not try to do anything with it.
    aSdk->hooking->Detach(aHandle, RED4EXT_OFFSET_TO_ADDR(m_address));

    break;
  }
  }

  return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo *aInfo) {
  aInfo->name = L"In-World Navigation";
  aInfo->author = L"Jack Humbert";
  aInfo->version = RED4EXT_V1_SEMVER(0, 1, 22);
  aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_INDEPENDENT;
  aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports() { 
  return RED4EXT_API_VERSION_1; 
}
