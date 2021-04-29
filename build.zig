const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zjs", "src/zjs.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const wasmlib = b.addStaticLibrary("zigjs", "src/wasm/main.zig");
    wasmlib.setBuildMode(mode);
    wasmlib.setTarget(.{.cpu_arch = .wasm32, .os_tag = .freestanding });
    wasmlib.setOutputDir("zig-cache");
    wasmlib.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const main_tests = b.addTest("src/zjs.zig");
    main_tests.setBuildMode(mode);

    const cutils_tests = b.addTest("src/cutils.zig");
    cutils_tests.setBuildMode(mode);
    
    const unicode_tests = b.addTest("src/libunicode.zig");
    unicode_tests.setBuildMode(mode);

    const regex_tests = b.addTest("src/libregexp.zig");
    regex_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    test_step.dependOn(&cutils_tests.step);
    test_step.dependOn(&unicode_tests.step);
    test_step.dependOn(&regex_tests.step);
}
