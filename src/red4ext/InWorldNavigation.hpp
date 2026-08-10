#pragma once

#include <RED4ext/RED4ext.hpp>

struct InWorldNavigation : RED4ext::IScriptable {
    RED4ext::CClass* GetNativeType(); 

    static RED4ext::Handle<InWorldNavigation> GetInstance();
    static void RegisterTypes();
    static void PostRegisterTypes();

    virtual bool CanBeDestructed() override {
        return false;
    }
};

void InWorldNavigationRegisterTypes();
void InWorldNavigationPostRegisterTypes();
