const std = @import("std");

pub const Package = struct {
    zjobs: *std.Build.Module,

    pub fn link(pkg: Package, exe: *std.Build.Step.Compile) void {
        exe.root_module.addImport("zjobs", pkg.zjobs);
    }
};

pub fn package(
    b: *std.Build,
    _: std.Build.ResolvedTarget,
    _: std.builtin.Mode,
    _: struct {},
) Package {
    const zjobs = b.addModule("zjobs", .{
        .root_source_file = .{ .path = thisDir() ++ "/src/zjobs.zig" },
    });
    return .{ .zjobs = zjobs };
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const test_step = b.step("test", "Run zjobs tests");
    test_step.dependOn(runTests(b, optimize, target));

    _ = package(b, target, optimize, .{});
}

pub fn runTests(
    b: *std.Build,
    optimize: std.builtin.Mode,
    target: std.Build.ResolvedTarget,
) *std.Build.Step {
    const tests = b.addTest(.{
        .name = "zjobs-tests",
        .root_source_file = .{ .path = thisDir() ++ "/src/zjobs.zig" },
        .target = target,
        .optimize = optimize,
    });
    return &b.addRunArtifact(tests).step;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
