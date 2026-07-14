    const check_step = b.step("check", "Check if compiles");
    const exe_check = b.addExecutable(.{
        .name = exe.name,
        .root_module = exe.root_module,
    });
    check_step.dependOn(&exe_check.step);
