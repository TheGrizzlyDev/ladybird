def _cmake_project_impl(ctx: AnalysisContext) -> list[Provider]:
    build_dir = ctx.actions.declare_output("build", dir=True)
    cmake_summary_json = ctx.actions.declare_output("cmake_summary.json")
    ctx.actions.run(
        [
            ctx.attrs._query_cmake.get(RunInfo),
            "--cmake_args", "-DCMAKE_C_COMPILER=clang-18 -DCMAKE_CXX_COMPILER=clang-18 --preset=default",
            "--summary_output", cmake_summary_json.as_output(),
            "--build_dir", build_dir.as_output(),
        ], 
        category = "configure")

    return [DefaultInfo(
        default_outputs=[build_dir, cmake_summary_json],
    )]


cmake_project = rule(impl = _cmake_project_impl, attrs = {
    "srcs": attrs.list(attrs.source()),
    "preset": attrs.option(attrs.string(), default = None),
    "_query_cmake": attrs.exec_dep(default = "//:query_cmake")
})