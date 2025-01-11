const std = @import("std");

/// Base58 encoding alphabet, confusing characters are removed to avoid confusion,
/// such as 0, O, I, l, etc.
const ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

/// Encode bytes to base58 string
pub fn encode(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    if (input.len == 0) return &[_]u8{};

    var bigint = try std.math.big.int.Managed.init(allocator);
    defer bigint.deinit();

    // Transform input to bigint
    try bigint.set(0);
    for (input) |byte| {
        try bigint.shiftLeft(&bigint, 8);
        try bigint.addScalar(&bigint, @as(u64, byte));
    }

    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    var remainder = try std.math.big.int.Managed.init(allocator);
    defer remainder.deinit();

    var base = try std.math.big.int.Managed.init(allocator);
    try base.set(@as(u64, 58));
    defer base.deinit();

    var zero = try std.math.big.int.Managed.init(allocator);
    try zero.set(@as(u64, 0));
    defer zero.deinit();

    while (!bigint.eql(zero)) {
        try bigint.divFloor(&remainder, &bigint, &base);
        const digit = try remainder.to(usize);
        try result.insert(0, ALPHABET[digit]);
    }

    // Add leading zeros
    for (input) |byte| {
        if (byte != 0) break;
        try result.insert(0, ALPHABET[0]);
    }

    return result.toOwnedSlice();
}

/// Decode base58 string to bytes
pub fn decode(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    if (input.len == 0) return &[_]u8{};

    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    var bigint = try std.math.big.int.Managed.init(allocator);
    defer bigint.deinit();

    try bigint.set(@as(u64, 0));
    var base58 = try std.math.big.int.Managed.init(allocator);
    try base58.set(@as(u64, 58));
    defer base58.deinit();

    for (input) |c| {
        const digit = std.mem.indexOfScalar(u8, ALPHABET, c) orelse return error.InvalidCharacter;
        try bigint.mul(&bigint, &base58);
        try bigint.addScalar(&bigint, @as(u64, digit));
    }

    var remainder = try std.math.big.int.Managed.init(allocator);
    defer remainder.deinit();

    var base = try std.math.big.int.Managed.init(allocator);
    try base.set(@as(u64, 256));
    defer base.deinit();

    var zero = try std.math.big.int.Managed.init(allocator);
    try zero.set(@as(u64, 0));
    defer zero.deinit();

    while (!bigint.eql(zero)) {
        try bigint.divFloor(&remainder, &bigint, &base);
        const byte = try remainder.to(u8);
        try result.insert(0, byte);
    }

    // Add leading zeros
    for (input) |c| {
        if (c != ALPHABET[0]) break;
        try result.insert(0, 0);
    }

    return result.toOwnedSlice();
}

test "base58 encode/decode" {
    const testing = std.testing;
    const allocator = testing.allocator;

    const test_cases = .{
        .{ "Hello World!", "2NEpo7TZRRrLZSi2U" },
        .{ "", "" },
        .{ "1234567890", "3mJr7AoUCHxNqd" },
        .{ "\x00\x00Hello World!", "11" ++ "2NEpo7TZRRrLZSi2U" },
        .{ &[_]u8{0} ** 32, "1" ** 32 }, // Test long input
    };

    inline for (test_cases) |tc| {
        const encoded = try encode(allocator, tc[0]);
        defer allocator.free(encoded);
        try testing.expectEqualStrings(tc[1], encoded);

        const decoded = try decode(allocator, tc[1]);
        defer allocator.free(decoded);
        try testing.expectEqualStrings(tc[0], decoded);
    }
}
