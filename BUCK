load(":cmake.bzl", "cmake_project")

cmake_project(
    name = "ladybird",
    srcs = glob(["**/*"]),
    preset = "default",
)

python_binary(
    name = "query_cmake",
    main = "query_cmake.py",
)