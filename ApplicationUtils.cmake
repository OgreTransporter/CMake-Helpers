# ================================================================================================ #
#  APPLICATION_BASICS( TARGET <target> [FILENAME <filename>] [ICON <icon>] [COMPANY <company>]     #
#                      [DESCRIPTION <description>] [COPYRIGHT <copyright>] [GUID <gui identifer>]  #
#                    )                                                                             #
#                                                                                                  #
# This function sets some standard properties for a target and creates a resource file under       #
# Windows.
#
# <target>        - Target whose properties are to be set
# <filename>      - Name of the output file without extension. If the name is missing, it is set to
#                   the name of the target.
# <icon>          - An icon for an executable file under Windows. A relative path to the RC file
#                   (OUTPUT) is required!
# <company>       - Company name for the Windows resource file.
# <description>   - Application/File description for the Windows resource file.
# <copyright>     - Copyright text for the Windows resource file.
# <gui identifer> - Mac OSX gui identifer string

if(__application_basics)
	return()
endif()
set(__application_basics YES)

include(Win32Resource)

macro(application_basics)
	set(options)
	set(oneValueArgs TARGET FILENAME ICON COMPANY DESCRIPTION COPYRIGHT GUID)
	set(multiValueArgs)
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
		create_win32_resource_file(TARGET ${APP_TARGET} FILENAME "${APP_FILENAME}" ICON "${APP_ICON}" COMPANY "${APP_COMPANY}" DESCRIPTION "${APP_DESCRIPTION}" COPYRIGHT "${APP_COPYRIGHT}" VERSION ${PROJECT_VERSION} OUTPUT "${CURRENT_BINARY_DIR}/${APP_TARGET}.rc")
	endif()
endmacro()
