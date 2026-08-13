#include "InWorldNavigation.hpp"

RED4ext::CClass* InWorldNavigation::GetNativeType() {
  return RED4ext::CRTTISystem::Get()->GetClass("InWorldNavigation");
}

RED4ext::Handle<InWorldNavigation> handle;

RED4ext::Handle<InWorldNavigation> InWorldNavigation::GetInstance() {
  if (!handle.instance) {
    auto rtti = RED4ext::CRTTISystem::Get();
    auto instance = reinterpret_cast<InWorldNavigation *>(rtti->GetClass("InWorldNavigation")->CreateInstance());
    handle = RED4ext::Handle<InWorldNavigation>(instance);
  }

  return handle;
}

void GetInstance_Native(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, void* aOut, int64_t a4) {
    // Skip ParamEnd since there are no input parameters
    aFrame->code++; 
    
    if (aOut) {
        auto* outHandle = static_cast<RED4ext::Handle<InWorldNavigation>*>(aOut);
        *outHandle = InWorldNavigation::GetInstance();
    }
}

void InWorldNavigation::RegisterTypes() {
    auto* inWorldNavigationClass = new RED4ext::TTypedClass<InWorldNavigation>("InWorldNavigation");
    RED4ext::CRTTISystem::Get()->RegisterType(inWorldNavigationClass);
}

void InWorldNavigation::PostRegisterTypes() {
    auto rtti = RED4ext::CRTTISystem::Get();
    
    RED4ext::CClass* inWorldNavigationClass = rtti->GetClass("InWorldNavigation");

    // Setup inheretence
    auto scriptable = rtti->GetClass("IScriptable");
    inWorldNavigationClass->parent = scriptable;
    inWorldNavigationClass->flags = { .isNative = true };

    auto getInstanceMethod = RED4ext::CClassStaticFunction::Create(
        inWorldNavigationClass, 
        "GetInstance",
        "GetInstance",
        &GetInstance_Native, 
        { .isNative = true }
    );
    getInstanceMethod->SetReturnType("handle:InWorldNavigation");
    inWorldNavigationClass->RegisterFunction(getInstanceMethod);
}
