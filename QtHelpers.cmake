if(__qthelpers)
    return()
endif()
set(__qthelpers YES)

macro(qth_install target)
    install(TARGETS ${target})
    qt_generate_deploy_app_script(
        TARGET ${target}
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endmacro()

macro(qth_deploy_output target)
    add_custom_command(TARGET ${target} POST_BUILD COMMAND Qt6::windeployqt --no-translations --no-compiler-runtime ${W32WARGS}  $<$<CONFIG:Debug>:--debug>$<$<NOT:$<CONFIG:Debug>>:--release> "$<TARGET_FILE_DIR:${target}>/$<TARGET_FILE_NAME:${target}>")
endmacro()
