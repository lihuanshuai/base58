const std = @import("std");
const base58 = @import("base58.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    const test_string = "Hello World!";
    const encoded = try base58.encode(allocator, test_string);
    defer allocator.free(encoded);

    try stdout.print("Original: {s}\n", .{test_string});
    try stdout.print("Encoded: {s}\n", .{encoded});

    const decoded = try base58.decode(allocator, encoded);
    defer allocator.free(decoded);
    try stdout.print("Decoded: {s}\n", .{decoded});
}

test {
    std.testing.refAllDecls(@This());
    _ = @import("base58.zig");
}