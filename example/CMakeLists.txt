cmake_minimum_required(VERSION 3.13)
project(crfpp_examples VERSION 0.59 LANGUAGES C CXX)

set(BIN_PATH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
set(EXAMPLE_DIR ${CMAKE_CURRENT_LIST_DIR})

configure_file(${CMAKE_CURRENT_LIST_DIR}/run_examples.sh.in ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/run_examples.sh)
