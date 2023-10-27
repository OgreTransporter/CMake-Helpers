# ================================================================================================ #
#  APPLICATION_BASICS( TARGET <target> [ICON <icon>] [COMPANY <company>] [COPYRIGHT <copyright>]   #
#                      [DESCRIPTION <description>] [VSPATH <path directories> ...]                 #
#                      [GUID <gui identifer>]                                                      #
#                    )                                                                             #
#                                                                                                  #
# This function sets some standard properties for a target and creates a resource file under       #
# Windows.
#
# <target>           - Target whose properties are to be set
# <icon>             - An icon for an executable file under Windows. A relative path to the RC file
#                      (OUTPUT) is required!
# <company>          - Company name for the Windows resource file.
# <copyright>        - Copyright text for the Windows resource file.
# <description>      - Application/File description for the Windows resource file. Default text is
#                      ${PROJECT_DESCRIPTION}.
# <path directories> - Any number of directories to add to the VS Debugger's PATH environment
#                      variable.
# <gui identifer>    - Mac OSX gui identifer string

if(__application_basics)
    return()
endif()
set(__application_basics YES)

include(Win32Resource)

macro(application_basics)
    set(options)
    set(oneValueArgs TARGET ICON COMPANY DESCRIPTION COPYRIGHT GUID)
    set(multiValueArgs VSPATH)
    cmake_parse_arguments(APP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    if(NOT APP_TARGET)
        message(FATAL_ERROR "You must provide a target!")
    endif()
    if(NOT APP_GUID)
        set(APP_GUID "${APP_TARGET}.application.org")
    endif()
    get_target_property(_type ${APP_TARGET} TYPE)
    if (${_type} STREQUAL "EXECUTABLE")
        set_target_properties(${APP_TARGET} PROPERTIES
            MACOSX_BUNDLE_GUI_IDENTIFIER ${APP_GUID}
            MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
            MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
            MACOSX_BUNDLE TRUE
            WIN32_EXECUTABLE TRUE
            VERSION ${PROJECT_VERSION}
            SOVERSION ${PROJECT_VERSION_MAJOR}
        )
    endif()
    if(WIN32)
        create_win32_resource_file(TARGET ${APP_TARGET} ICON "${APP_ICON}" COMPANY "${APP_COMPANY}" DESCRIPTION "${APP_DESCRIPTION}" COPYRIGHT "${APP_COPYRIGHT}" VERSION ${PROJECT_VERSION} OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${APP_TARGET}.rc")
        if(MSVC AND APP_VSPATH)
            if(TARGET Qt::qmake)
                get_target_property(_qt_qmake_location Qt::qmake IMPORTED_LOCATION)
                execute_process(COMMAND "${_qt_qmake_location}" -query QT_INSTALL_PREFIX RESULT_VARIABLE return_code OUTPUT_VARIABLE qt_install_prefix OUTPUT_STRIP_TRAILING_WHITESPACE)
                cmake_path(CONVERT "${qt_install_prefix}" TO_NATIVE_PATH_LIST qt_install_prefix)
                get_target_property(_link_libraries ${APP_TARGET} LINK_LIBRARIES)
                set(_pos_qt_core -1)
                foreach(element Core Widgets Gui)
                    if(${_pos_qt_core} LESS 0)
                        list(FIND _link_libraries "Qt::${element}" _pos_qt_core)
                    endif()
                    if(${_pos_qt_core} LESS 0)
                        list(FIND _link_libraries "Qt6::${element}" _pos_qt_core)
                    endif()
                endforeach()
                if(${_pos_qt_core} GREATER_EQUAL 0)
                    list(INSERT APP_VSPATH 0 "${qt_install_prefix}/bin")
                endif()
            endif()
            list(LENGTH APP_VSPATH _ll)
            if(${_ll} GREATER 0)
                cmake_path(CONVERT "${APP_VSPATH}" TO_NATIVE_PATH_LIST APP_VSPATH)
                set(VSUSER_FILE ${CMAKE_CURRENT_BINARY_DIR}/${APP_TARGET}.vcxproj.user)
                file(WRITE  ${VSUSER_FILE} "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
                file(APPEND ${VSUSER_FILE} "<Project xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">\n")
                file(APPEND ${VSUSER_FILE} "  <PropertyGroup>\n")
                file(APPEND ${VSUSER_FILE} "    <LocalDebuggerEnvironment>PATH=${APP_VSPATH};$(Path)\n")
                file(APPEND ${VSUSER_FILE} "$(LocalDebuggerEnvironment)</LocalDebuggerEnvironment>\n")
                file(APPEND ${VSUSER_FILE} "    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>\n")
                file(APPEND ${VSUSER_FILE} "  </PropertyGroup>\n")
                file(APPEND ${VSUSER_FILE} "</Project>\n")
            endif()
        endif()
    endif()
endmacro()
