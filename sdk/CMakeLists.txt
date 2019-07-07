cmake_minimum_required(VERSION 3.13)
project(crfpp_sdk_example VERSION 0.59 LANGUAGES C CXX)

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR})

file(GLOB CRFPP_SDK_EXAMPLE_SOURCE_FILES
	${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

add_executable(crf_sdk_example ${CRFPP_SDK_EXAMPLE_SOURCE_FILES})
target_link_libraries(crf_sdk_example crfpp)