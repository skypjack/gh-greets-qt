cmake_minimum_required(VERSION 3.8.2)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "Prevented in-tree built. Please create a build directory outside of the source code and call cmake from there. Thank you.")
endif()

project(gh-greets-qt VERSION 0.0.1)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Threads REQUIRED)
find_package(Qt5 COMPONENTS Core Gui Widgets REQUIRED)

add_executable(gh-greets-qt WIN32 src/main.cpp)
target_compile_features(gh-greets-qt PRIVATE cxx_std_17)

target_compile_options(
    gh-greets-qt
    PRIVATE $<$<PLATFORM_ID:Windows>:/w>
    PRIVATE $<$<AND:$<CONFIG:Debug>,$<NOT:$<PLATFORM_ID:Windows>>>:-O0 -g>
    PRIVATE $<$<AND:$<CONFIG:Release>,$<NOT:$<PLATFORM_ID:Windows>>>:-O3>
)

target_link_libraries(
    gh-greets-qt
    PRIVATE Qt5::Core
    PRIVATE Qt5::Gui
    PRIVATE Qt5::Widgets
)

install(
    TARGETS gh-greets-qt
    RUNTIME DESTINATION gh-greets-qt
    COMPONENT gh-greets-qt_component
    BUNDLE DESTINATION gh-greets-qt
    COMPONENT gh-greets-qt_component
)

if(CPACK_IFW_ROOT OR DEFINED ENV{QTIFWDIR})
    if(DEFINED ENV{QTDIR})
        set(CPACK_PACKAGE_NAME GH-GREETS-QT)
        set(CPACK_PACKAGE_VENDOR ".")
        set(CPACK_PACKAGE_FILE_NAME gh-greets-qt_installer)
        set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "GH greets Qt - Installation Tool")
        set(CPACK_PACKAGE_VERSION 1.0.0) # Version of installer

        set(CPACK_IFW_VERBOSE ON)

        set(CPACK_IFW_PACKAGE_NAME ${CPACK_PACKAGE_NAME})
        set(CPACK_IFW_PACKAGE_START_MENU_DIRECTORY Hi-Qt)
        set(CPACK_IFW_PRODUCT_URL https://github.com/skypjack/gh-greets-qt)

        set(CPACK_GENERATOR IFW)

        include(CPack REQUIRED)
        include(CPackIFW REQUIRED)

        if(WIN32)
            if(EXISTS $ENV{QTDIR}/bin/windeployqt.exe)
                if(CMAKE_BUILD_TYPE MATCHES Release)
                    set(BINARIES_TYPE --release)
                else()
                    set(BINARIES_TYPE --debug)
                endif()

                add_custom_command(
                    TARGET gh-greets-qt POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/windeployqt_stuff
                    COMMAND $ENV{QTDIR}/bin/windeployqt.exe ${BINARIES_TYPE} --compiler-runtime --no-system-d3d-compiler --no-angle --no-webkit2 --no-quick-import --no-translations --dir ${CMAKE_BINARY_DIR}/windeployqt_stuff $<TARGET_FILE:gh-greets-qt>
                )

                install(
                    DIRECTORY ${CMAKE_BINARY_DIR}/windeployqt_stuff/
                    DESTINATION gh-greets-qt
                    COMPONENT gh-greets-qt_component
                )

                cpack_add_component(
                    gh-greets-qt_component
                    DISPLAY_NAME Hi-Qt
                    DESCRIPTION "Hi Qt"
                    REQUIRED
                )

                cpack_ifw_configure_component(
                    gh-greets-qt_component
                    NAME gh.greets.qt.${PROJECT_NAME}
                    VERSION ${PROJECT_VERSION} # Version of component
                    LICENSES "License" ${gh-greets-qt_SOURCE_DIR}/LICENSE
                    SCRIPT "${gh-greets-qt_SOURCE_DIR}/installer/component.qs"
                )
            else()
                message("Unable to find executable QTDIR/bin/windeployqt.")
            endif()
        endif()
    else()
        message("Set properly environment variable QTDIR to be able to create a package.")
    endif()
else()
    message("If you want to enable target package you can:")
    message("\t* Either pass -DCPACK_IFW_ROOT=<path> to cmake")
    message("\t* Or set the environment variable QTIFWDIR")
    message("To specify the location of the QtIFW tool suite.")
    message("The specified path should not contain bin at the end (for example: D:\\DevTools\\QtIFW2.0.5).")
endif()

FILE(GLOB GH_WORKFLOWS .github/workflows/*.yml)
FILE(GLOB IFW_SCRIPTS installer/*.qs)
FILE(GLOB CI_SCRIPTS ci/*.qs)

add_custom_target(
    gh-greets-qt_aob
    SOURCES
        ${GH_WORKFLOWS}
        ${IFW_SCRIPTS}
        ${CI_SCRIPTS}
        AUTHORS
        LICENSE
        README.md
)

