def _cmake_project_impl(ctx: AnalysisContext) -> list[Provider]:
    build_dir = ctx.actions.declare_output("build", dir=True)
    cmake_summary_json = ctx.actions.declare_output("cmake_summary.json")
    ctx.actions.run(
        [
            ctx.attrs._query_cmake[RunInfo],
            "--cmake_args", "-DCMAKE_C_COMPILER=clang-18 -DCMAKE_CXX_COMPILER=clang-18 --preset=default",
            "--summary_output", cmake_summary_json.as_output(),
            "--build_dir", build_dir.as_output(),
        ], 
        category = "configure")

    bin_dir = ctx.actions.declare_output("bin", dir=True)
    lib_dir = ctx.actions.declare_output("lib", dir=True)

    def build_cmake_targets(ctx, artifacts, outputs, cmake_summary_json=cmake_summary_json, build_dir=build_dir, bin_dir=bin_dir, lib_dir=lib_dir):
        cmake_summary = artifacts[cmake_summary_json].read_json()
        print(cmake_summary["codemodel-v2-8acb5517b608758adbe4.json"])

    ctx.actions.dynamic_output(
        dynamic=[cmake_summary_json, build_dir],
        inputs=[],
        outputs=[bin_dir.as_output(), lib_dir.as_output()],
        f=build_cmake_targets)

    return [DefaultInfo(
        default_outputs=[cmake_summary_json],
    )]


cmake_project = rule(impl = _cmake_project_impl, attrs = {
    "srcs": attrs.list(attrs.source()),
    "preset": attrs.option(attrs.string(), default = None),
    "targets": attrs.list(attrs.string()),
    "_query_cmake": attrs.exec_dep(default = "//:query_cmake")
})