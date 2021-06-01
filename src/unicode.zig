const std = @import("std");
const testing = std.testing;
const mem = std.mem;

/// Converts the given UTF-8 formatted string to a UTF-16 array.
/// The caller owns the returned data.
pub fn utf8ToUtf16LeAlloc(allocator: *mem.Allocator, utf8: []const u8) !std.ArrayList(u16) {
    var result = std.ArrayList(u16).init(allocator);
    // optimistically guess that it will not require surrogate pairs
    try result.ensureCapacity(utf8.len);

    const view = try std.unicode.Utf8View.init(utf8);
    var it = view.iterator();
    while (it.nextCodepoint()) |codepoint| {
        if (codepoint < 0x10000) {
            const short = @intCast(u16, codepoint);
            try result.append(mem.nativeToLittle(u16, short));
        } else {
            const high = @intCast(u16, (codepoint - 0x10000) >> 10) + 0xD800;
            const low = @intCast(u16, codepoint & 0x3FF) + 0xDC00;
            var out: [2]u16 = undefined;
            out[0] = mem.nativeToLittle(u16, high);
            out[1] = mem.nativeToLittle(u16, low);
            try result.appendSlice(out[0..]);
        }
    }

    return result;
}

test "utf8ToUtf16LeAlloc()" {
    {
        const array = try utf8ToUtf16LeAlloc(testing.allocator, "𐐷");
        defer array.deinit();
        try testing.expectEqual(@as(usize, 2), array.items.len);
        try testing.expectEqualSlices(u8, "\x01\xd8\x37\xdc", mem.sliceAsBytes(array.items[0..]));
    }
    {
        const array = try utf8ToUtf16LeAlloc(testing.allocator, "\u{1F600}"); // 😀
        defer array.deinit();
        try testing.expectEqual(@as(usize, 2), array.items.len);
        try testing.expectEqualSlices(u8, "\x3D\xD8\x00\xDE", mem.sliceAsBytes(array.items[0..]));
    }
    {
        const array = try utf8ToUtf16LeAlloc(testing.allocator, "a");
        defer array.deinit();
        try testing.expectEqual(@as(usize, 1), array.items.len);
        try testing.expectEqualSlices(u8, "\x61\x00", mem.sliceAsBytes(array.items[0..]));
    }
}