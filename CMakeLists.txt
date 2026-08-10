cmake_minimum_required(VERSION 3.24)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_C_COMPILER cl)
set(CMAKE_CXX_COMPILER cl)
set(CMAKE_SYSTEM_NAME Windows)

project(in_world_navigation VERSION 1.0.0 LANGUAGES CXX)

add_subdirectory(deps/red4ext.sdk)

set(PROJECT_HEADER_FILES
  src/red4ext/InWorldNavigation.hpp
  src/red4ext/stdafx.hpp
  src/red4ext/ext.hpp
)

set(PROJECT_SRC_FILES
  src/red4ext/Main.cpp
  src/red4ext/InWorldNavigation.cpp
  src/red4ext/stdafx.cpp
)

add_library(${CMAKE_PROJECT_NAME} SHARED "")

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${PROJECT_HEADER_FILES} ${PROJECT_SRC_FILES})

target_link_libraries(${CMAKE_PROJECT_NAME}
  PRIVATE
  RED4ext::SDK
)

add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "mod_package/red4ext/plugins/in_world_navigation"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "in_world_navigation.dll"
        "mod_package/red4ext/plugins/in_world_navigation/in_world_navigation.dll"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "../resources/packed/archive/pc/mod/in_world_navigation.archive"
        "mod_package/red4ext/plugins/in_world_navigation/in_world_navigation.archive"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "../src/redscript/module.reds"
        "mod_package/red4ext/plugins/in_world_navigation/module.reds"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "../src/redscript/packed.reds"
        "mod_package/red4ext/plugins/in_world_navigation/packed.reds"
)
