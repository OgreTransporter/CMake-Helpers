# ================================================================================================ #
#  GET_CPU_DETAILS()                                                                               #
#                                                                                                  #
# Set a number of useful variables to indicate things about the current CPU
#
# Result variables:
#    CPU_COUNT
#    CPU_INTEL
#    CPU_EXE_64BIT
#    CPU_EXE_32BIT
#    CPU_HAS_SSE
#    CPU_HAS_SSE2
#    CPU_HAS_SSE3
#    CPU_HAS_SSSE3
#    CPU_HAS_SSE4_1
#    CPU_HAS_SSE4_2

if(__get_cpu_details)
	return()
endif()
set(__get_cpu_details YES)

function(get_cpu_details)

	###
	# CPU_COUNT
	if(NOT DEFINED CPU_COUNT)
		# Unknown:
		set(CPU_COUNT 1)
		# Linux:
		set(cpuinfo_file "/proc/cpuinfo")
		if(EXISTS "${cpuinfo_file}")
			file(STRINGS "${cpuinfo_file}" procs REGEX "^processor.: [0-9]+$")
			list(LENGTH procs CPU_COUNT)
		endif()
		# Mac:
		if(APPLE)
			find_program(cmd_sys_pro "system_profiler")
			if(cmd_sys_pro)
				execute_process(COMMAND ${cmd_sys_pro} OUTPUT_VARIABLE info)
				string(REGEX REPLACE "^.*Total Number Of Cores: ([0-9]+).*$" "\\1"
				CPU_COUNT "${info}")
			endif()
		endif()
		# Windows:
		if(WIN32)
			set(CPU_COUNT "$ENV{NUMBER_OF_PROCESSORS}")
		endif()
		set(CPU_COUNT
			${CPU_COUNT}
			CACHE
			INTERNAL
			"Number of cpu cores")
	endif()

	###
	# CPU_INTEL
	if(NOT DEFINED CPU_INTEL)
		if("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86_64" OR "${CMAKE_SYSTEM_PROCESSOR}" MATCHES "i[3456]86")
			set(CPU_INTEL ON)
		elseif(APPLE)
			# Mac Intel boxes return i386 in 10.5 - so assume this is a PPC
			set(CPU_INTEL OFF)
		else()
			# TODO: Assuming yes in case of doubt - probably not a great idea
			set(CPU_INTEL ON)
		endif()
		set(CPU_INTEL
			${CPU_INTEL}
			CACHE
			INTERNAL
			"Intel x86 or x86_64 architecture machine?")
	endif()

	###
	# CPU_EXE_64BIT/32BIT
	if(NOT DEFINED CPU_EXE_64BIT)
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(CPU_EXE_64BIT ON)
			set(CPU_EXE_32BIT OFF)
		else()
			set(CPU_EXE_64BIT OFF)
			set(CPU_EXE_32BIT ON)
		endif()
		set(CPU_EXE_64BIT
			${CPU_EXE_64BIT}
			CACHE
			INTERNAL
			"Compile x64")
		set(CPU_EXE_32BIT
			${CPU_EXE_32BIT}
			CACHE
			INTERNAL
			"Compile x84")
	endif()

	###
	# CPU_HAS_SSE/SSE2/SSE3/SSSE3/SSE4.1/SSE4.2
	if(CPU_INTEL)
		if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
			# Use /proc/cpuinfo to find this out.
			file(STRINGS "/proc/cpuinfo" _cpuinfo)
			if(_cpuinfo MATCHES "(sse)|(xmm)")
				set(CPU_HAS_SSE YES)
			else()
				set(CPU_HAS_SSE NO)
			endif()

			if(_cpuinfo MATCHES "(sse2)|(xmm2)")
				set(CPU_HAS_SSE2 YES)
			else()
				set(CPU_HAS_SSE2 NO)
			endif()

			if(_cpuinfo MATCHES "(sse3)|(xmm3)")
				set(CPU_HAS_SSE3 YES)
			else()
				set(CPU_HAS_SSE3 NO)
			endif()

			if(_cpuinfo MATCHES "ssse3")
				set(CPU_HAS_SSSE3 YES)
			else()
				set(CPU_HAS_SSSE3 NO)
			endif()

			if(_cpuinfo MATCHES "(sse4_1)|(xmm4_1)")
				set(CPU_HAS_SSE4_1 YES)
			else()
				set(CPU_HAS_SSE4_1 NO)
			endif()

			if(_cpuinfo MATCHES "(sse4_2)|(xmm4_2)")
				set(CPU_HAS_SSE4_2 YES)
			else()
				set(CPU_HAS_SSE4_2 NO)
			endif()

		elseif(APPLE)
			# Mac OS X Intel requires SSE3
			set(CPU_HAS_SSE YES)
			set(CPU_HAS_SSE2 YES)
			set(CPU_HAS_SSE3 YES)
			set(CPU_HAS_SSSE3 NO)
			set(CPU_HAS_SSE4_1 NO)
			set(CPU_HAS_SSE4_2 NO)
		elseif(WIN32)
			if(CPU_EXE_64BIT)
				#TODO: Assume only common-denominator for 64-bit machines,
				# since I don't know how to check.
				set(CPU_HAS_SSE YES)
				set(CPU_HAS_SSE2 YES)
				set(CPU_HAS_SSE3 NO)
				set(CPU_HAS_SSSE3 NO)
				set(CPU_HAS_SSE4_1 NO)
				set(CPU_HAS_SSE4_2 NO)
			else()
				#TODO:  Assume no SSE, since I don't know how to check.
				set(CPU_HAS_SSE NO)
				set(CPU_HAS_SSE2 NO)
				set(CPU_HAS_SSE3 NO)
				set(CPU_HAS_SSSE3 NO)
				set(CPU_HAS_SSE4_1 NO)
				set(CPU_HAS_SSE4_2 NO)
			endif()
		endif()
	endif()
endfunction()
