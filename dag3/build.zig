const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Executable for del_en.zig
    const exe_del_en = b.addExecutable(.{
        .name = "del_en",
        .root_source_file = b.path("src/del_en.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe_del_en);

    const run_del_en_cmd = b.addRunArtifact(exe_del_en);
    run_del_en_cmd.step.dependOn(b.getInstallStep());

    // Executable for del_to.zig
    const exe_del_to = b.addExecutable(.{
        .name = "del_to",
        .root_source_file = b.path("src/del_to.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe_del_to);

    const run_del_to_cmd = b.addRunArtifact(exe_del_to);
    run_del_to_cmd.step.dependOn(b.getInstallStep());

    // Run step for del_en
    const run_del_en_step = b.step("run-del-en", "Run the del_en executable");
    run_del_en_step.dependOn(&run_del_en_cmd.step);

    // Run step for del_to
    const run_del_to_step = b.step("run-del-to", "Run the del_to executable");
    run_del_to_step.dependOn(&run_del_to_cmd.step);

    // Test steps for both files if needed
    const test_del_en = b.addTest(.{
        .root_source_file = b.path("src/del_en.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_test_del_en = b.addRunArtifact(test_del_en);

    const test_del_to = b.addTest(.{
        .root_source_file = b.path("src/del_to.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_test_del_to = b.addRunArtifact(test_del_to);

    const test_step = b.step("test", "Run all unit tests");
    test_step.dependOn(&run_test_del_en.step);
    test_step.dependOn(&run_test_del_to.step);
}
