cmake_minimum_required(VERSION 3.13)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/external/findwix/cmake/")

project(crfpp VERSION 0.59 LANGUAGES C CXX)

if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
        set(VCPKG_TARGET_TRIPLET "x64-windows-static" CACHE STRING "VCPKG_TARGET_TRIPLET" FORCE)
    else()
        set(VCPKG_TARGET_TRIPLET "x86-windows-static" CACHE STRING "VCPKG_TARGET_TRIPLET" FORCE)
    endif()
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "CMAKE_TOOLCHAIN_FILE" FORCE)
endif()

include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckCSourceCompiles)
include(FindLibM)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Generate 'compile_commands.json' for clang_complete
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CXX_STD 14 CACHE STRING "Set to 11, 14, 17 or 20 to enable C++11, C++14, C++17 or C++20 builds, respectively." FORCE)
set(C_STD 11 CACHE STRING "Set to 99 or 11 to enable C99 or C11 builds, respectively." FORCE)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
        add_compile_options("-Wno-everything")
    endif()
endif()

if(WIN32)
    add_compile_definitions(_CRT_SECURE_NO_DEPRECATE WIN32_LEAN_AND_MEAN _CRT_SECURE_NO_WARNINGS UNICODE _UNICODE HAVE_WINDOWS_H HAVE_CONFIG_H DLL_EXPORT)
    add_compile_options("/utf-8" "/EHsc" "/GA" "/GL" "/Gy" "/Oi" "/Ob2" "/nologo" "/W3" "/wd4244")
    add_link_options("/OPT:REF" "/OPT:ICF" "/LTCG" "/NXCOMPAT" "/DYNAMICBASE")
    if(MSVC)
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /MT")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
    endif()
else()
    if(UNIX)
        if(APPLE)
            add_compile_options("-m64" "-fPIC" "-O3" "-march=native")
            set(CMAKE_MACOSX_RPATH 1 CACHE STRING "CMAKE_MACOSX_RPATH" FORCE)
        else()
            add_compile_options("-fPIC" "-O3")
            if(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
                add_compile_options("-m64" "-march=westmere")
            endif()
        endif()
    endif()
endif()

foreach(keyword "__thread" "__declspec(thread)")
    check_c_source_compiles(
        "#if defined(__MINGW32__) && !(__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 5))
        #error This MinGW version has broken __thread support
        #endif
        #ifdef __OpenBSD__
        #error OpenBSD has broken __thread support
        #endif

        int ${keyword} test;
        int main() { return 0; }"
        HAVE_TLS_${keyword})
    if(HAVE_TLS_${keyword})
        set(HAVE_TLS_KEYWORD ${keyword})
        break()
    endif()
endforeach()

CHECK_INCLUDE_FILE("ctype.h" HAVE_CTYPE_H)
CHECK_INCLUDE_FILE("dlfcn.h" HAVE_DLFCN_H)
CHECK_INCLUDE_FILE("fcntl.h" HAVE_FCNTL_H)
CHECK_INCLUDE_FILE("inttypes.h" HAVE_INTTYPES_H)
CHECK_INCLUDE_FILE("math.h" HAVE_MATH_H)
CHECK_INCLUDE_FILE("memory.h" HAVE_MEMORY_H)
CHECK_INCLUDE_FILE("stdint.h" HAVE_STDINT_H)
CHECK_INCLUDE_FILE("stdlib.h" HAVE_STDLIB_H)
CHECK_INCLUDE_FILE("strings.h" HAVE_STRINGS_H)
CHECK_INCLUDE_FILE("string.h" HAVE_STRING_H)
CHECK_INCLUDE_FILE("sys/mman.h" HAVE_SYS_MMAN_H)
CHECK_INCLUDE_FILE("sys/param.h" HAVE_SYS_PARAM_H)
CHECK_INCLUDE_FILE("sys/stat.h" HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILE("sys/times.h" HAVE_SYS_TIMES_H)
CHECK_INCLUDE_FILE("sys/types.h" HAVE_SYS_TYPES_H)
CHECK_INCLUDE_FILE("unistd.h" HAVE_UNISTD_H)
CHECK_INCLUDE_FILE("pthread.h" HAVE_PTHREAD_H)

check_function_exists("getpagesize" HAVE_GETPAGESIZE)
check_function_exists("mmap" HAVE_MMAP)

set(EXTRA_LINKING_LIBRARIES "")

find_package(LibM QUIET)
if(LIBM_FOUND)
    list(APPEND EXTRA_LINKING_LIBRARIES ${LIBM_LIBRARIES})
    include_directories(${LIBM_INCLUDE_DIRS})
    set(HAVE_LIBM 1 CACHE STRING "HAVE_LIBM" FORCE)
endif()

find_package(Threads QUIET)
if(Threads_FOUND)
    list(APPEND EXTRA_LINKING_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
    include_directories(${Threads_INCLUDE_DIRS})
    set(HAVE_LIBPTHREAD 1 CACHE STRING "HAVE_LIBPTHREAD" FORCE)
endif()

message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "Version: ${PROJECT_VERSION}")

set(CRF_PACKAGE_NAME ${PROJECT_NAME} CACHE STRING "CRF_PACKAGE_NAME" FORCE)
set(CRF_PACKAGE_VERSION ${PROJECT_VERSION} CACHE STRING "CRF_PACKAGE_VERSION" FORCE)

configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h.cmake.in config.h)

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR})

file(GLOB CRFPP_SOURCE_FILES
	${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/*.c
    ${CMAKE_CURRENT_BINARY_DIR}/*.cpp)

set(CRF_LEARN_SOURCE_FILES "${CMAKE_CURRENT_LIST_DIR}/crf_learn.cpp")

set(CRF_TEST_SOURCE_FILES "${CMAKE_CURRENT_LIST_DIR}/crf_test.cpp")

list(FILTER CRFPP_SOURCE_FILES EXCLUDE REGEX "crf_.+\.cpp")
list(REMOVE_DUPLICATES CRFPP_SOURCE_FILES)

add_library(crfpp-static STATIC ${CRFPP_SOURCE_FILES})
target_include_directories(crfpp-static PUBLIC ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(crfpp-static ${EXTRA_LINKING_LIBRARIES})
if(NOT WIN32)
    set_target_properties(crfpp-static PROPERTIES OUTPUT_NAME "crfpp")
endif()
set_target_properties(crfpp-static PROPERTIES PUBLIC_HEADER "crfpp.h")

add_library(crfpp SHARED ${CRFPP_SOURCE_FILES})
target_include_directories(crfpp PUBLIC ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(crfpp ${EXTRA_LINKING_LIBRARIES})
set_target_properties(crfpp PROPERTIES PUBLIC_HEADER "crfpp.h")

add_executable(crfpp_learn ${CRF_LEARN_SOURCE_FILES})
target_link_libraries(crfpp_learn crfpp-static)

add_executable(crfpp_test ${CRF_LEARN_SOURCE_FILES})
target_link_libraries(crfpp_test crfpp-static)

add_subdirectory(sdk)

# Installer

install(TARGETS crfpp crfpp-static
    RUNTIME
        DESTINATION bin
    LIBRARY
        DESTINATION bin
    RESOURCE
        DESTINATION bin
    LIBRARY
        DESTINATION lib
    ARCHIVE
        DESTINATION lib
    PUBLIC_HEADER
        DESTINATION include)

if(WIN32)
	if(CMAKE_SIZEOF_VOID_P MATCHES "8")
		set(CPACK_WIX_PLATFORM "x64" CACHE STRING "CPACK_WIX_PLATFORM" FORCE)
	else()
		set(CPACK_WIX_PLATFORM "x86" CACHE STRING "CPACK_WIX_PLATFORM" FORCE)
	endif()
	set(CPACK_WIX_EXTENSIONS "WixUtilExtension" "WixUIExtension" "WixNetFxExtension" CACHE STRING "CPACK_WIX_EXTENSIONS" FORCE)
else()
    include(GNUInstallDirs)
endif()
