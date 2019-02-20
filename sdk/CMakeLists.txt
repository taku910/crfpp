#1.cmake verson
cmake_minimum_required(VERSION 2.8)

#2.project name
project(crfpp_wrapper)

set(CMAKE_CXX_STANDARD 11)

# 3.head file directory
include_directories(/usr/local/include)

#4.link directory
link_directories(/usr/local/lib)

#5.generate executable
add_executable(crfpp_wrapper crfpp_wrapper.cpp)

#6.set dependent libs
set(LIBS crfpp)

#7.add link library
target_link_libraries(crfpp_wrapper ${LIBS})