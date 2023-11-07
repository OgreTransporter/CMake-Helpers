# ================================================================================================ #
#  APPEND_PYTHON( <target> )                                                                       #
#                                                                                                  #
# Downloads and add Python to a target project
#
# <target> - A target into whose file output the python is to be copied.

if(__appendpython)
    return()
endif()
set(__appendpython YES)

if(WIN32)
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/python/)
		make_directory(${CMAKE_BINARY_DIR}/python/)
	endif()
	set(Python_ROOT_DIR "${CMAKE_BINARY_DIR}/python/")
	set(Python_EXECUTABLE "${Python_ROOT_DIR}python.exe")
	if(NOT EXISTS ${Python_EXECUTABLE})
		file(DOWNLOAD "https://www.python.org/ftp/python/" "${CMAKE_BINARY_DIR}/pythonftp.html")
		set(python_version 3.12.0)
		file(STRINGS "${CMAKE_BINARY_DIR}/pythonftp.html" _pyver REGEX "\>3.12.[0-9]+/\<")
		foreach(tmp in ${_pyver})
			if(tmp MATCHES "\>(3.12.[0-9]+)/\<")
				if(${CMAKE_MATCH_1} VERSION_GREATER ${python_version})
					set(python_version ${CMAKE_MATCH_1})
				endif()
			endif()
		endforeach()
		file(REMOVE "${CMAKE_BINARY_DIR}/pythonftp.html")
		message("Download and install python ${python_version}")
		file(DOWNLOAD "https://www.python.org/ftp/python/${python_version}/python-${python_version}-amd64.exe" "${CMAKE_BINARY_DIR}/pythonsetup.exe")
		cmake_path(CONVERT "${CMAKE_BINARY_DIR}/tmppython" TO_NATIVE_PATH_LIST _temp_target)
		execute_process(
			COMMAND "${CMAKE_BINARY_DIR}/pythonsetup.exe" /passive InstallAllUsers=0 TargetDir=${_temp_target} AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=1 Include_dev=1 Include_exe=1 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=1 Include_tcltk=0 Include_test=1 Include_tools=0
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
		execute_process(
			COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${CMAKE_BINARY_DIR}/tmppython/" "${CMAKE_BINARY_DIR}/python/"
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
		execute_process(
			COMMAND python -m pip install -U pip
			WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/python/"
		)
		execute_process(
			COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${CMAKE_BINARY_DIR}/python/" "${CMAKE_BINARY_DIR}/windeployqt/Debug/"
			COMMAND "${CMAKE_BINARY_DIR}/pythonsetup.exe" /passive /uninstall InstallAllUsers=0 TargetDir=${_temp_target} AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=1 Include_dev=1 Include_exe=1 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=1 Include_tcltk=0 Include_test=1 Include_tools=0
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
		execute_process(
			COMMAND "${CMAKE_BINARY_DIR}/pythonsetup.exe" /passive InstallAllUsers=0 TargetDir=${_temp_target} AssociateFiles=0 CompileAll=1 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_exe=1 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
		execute_process(
			COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${CMAKE_BINARY_DIR}/tmppython/" "${CMAKE_BINARY_DIR}/windeployqt/Release/"
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
		execute_process(
			COMMAND python -m pip install -U pip
			WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/windeployqt/Release/"
		)
		execute_process(
			COMMAND "${CMAKE_BINARY_DIR}/pythonsetup.exe" /passive /uninstall InstallAllUsers=0 TargetDir=${_temp_target} AssociateFiles=0 CompileAll=1 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_exe=1 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
		file(REMOVE "${CMAKE_BINARY_DIR}/pythonsetup.exe")
		file(REMOVE_RECURSE "${CMAKE_BINARY_DIR}/tmppython/")
	endif()

    function(append_python target)
		add_custom_command(TARGET ${target} PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:${target}>"
			COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${Python_ROOT_DIR}" "$<TARGET_FILE_DIR:${target}>/"
		)
	endfunction()
endif()
