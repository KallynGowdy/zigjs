const std = @import("std");
const testing = std.testing;
const CharPoints = std.ArrayList(u8);

/// A character range is a list that uses pairs of characters to specify
/// entire ranges that should be included by a Regex condition. 
/// (i.e. square bracket [] expressions)
/// Because they are in a simple list, presenting "a-z" is as
/// simple as storing ["a", "z"].
/// Additionally, this range can be inverted by simply adding
/// 0 to the start and std.math.maxInt(u32) to the end because 
/// this shifts the pairings so that the ranges now represent 0-"a" and "b" - max.
pub const CharRange = std.ArrayList(u32);

pub fn cr_invert(cr: *CharRange) !void {
    try cr.ensureCapacity(cr.items.len + 2);
    try cr.insert(0, 0);
    try cr.append(std.math.maxInt(u32));

    // int len;
    // len = cr->len;
    // if (cr_realloc(cr, len + 2))
    //     return -1;
    // memmove(cr->points + 1, cr->points, len * sizeof(cr->points[0]));
    // cr->points[0] = 0;
    // cr->points[len + 1] = UINT32_MAX;
    // cr->len = len + 2;
    // cr_compress(cr);
    // return 0;
}

test "cr_invert()" {
    const a = testing.allocator;
    {
        var range = CharRange.init(a);
        defer range.deinit();
        
        range.append('a') catch unreachable;
        range.append('d') catch unreachable;

        cr_invert(&range) catch unreachable;

        testing.expect(range.items.len == 4);
        testing.expect(range.items[0] == 0);
        testing.expect(range.items[1] == 'a');
        testing.expect(range.items[2] == 'd');
        testing.expect(range.items[3] == std.math.maxInt(u32));
    }
}

// /* merge consecutive intervals and remove empty intervals */
pub fn cr_compress(cr: *CharRange) !void {
    const items = cr.items;
    const len = items.len;
    var k: usize = 0;
    var i: usize = 0;
    var j: usize = 0;
    while(i + 1 < len) {
        if (items[i] == items[i + 1]) {
            // empty interval
            i += 2;
        } else {
            j = i;

            // Skip over all characters
            // that represent an empty interval
            while((j + 3) < len and items[j + 1] == items[j + 2]) {
                j += 2;
            }

            // just copy
            items[k] = items[i];
            items[k + 1] = items[j + 1];
            k += 2;
            i = j + 2;
        }
    }
    cr.shrinkRetainingCapacity(k);
}

test "cr_compress()" {
    const a = testing.allocator;
    {
        // should remove empty intervals
        var range = CharRange.init(a);
        defer range.deinit();
        
        range.append('a') catch unreachable;
        range.append('d') catch unreachable;

        // empty interval
        range.append('q') catch unreachable;
        range.append('q') catch unreachable;

        cr_compress(&range) catch unreachable;

        testing.expect(range.items.len == 2);
        testing.expect(range.items[0] == 'a');
        testing.expect(range.items[1] == 'd');
        testing.expect(range.capacity >= 4);
    }
}

pub const CharRangeOp = enum {
    CR_OP_UNION,
    CR_OP_INTER,
    CR_OP_XOR,
};

// /* union or intersection */
/// Performs a union/intersection between the given first and second points
/// and returns a CharRange that contains the results.
/// Caller owns result.
pub fn cr_op(allocator: *std.mem.Allocator, first_points: []const u32, second_points: []const u32, op: CharRangeOp) !CharRange {
    var cr = CharRange.init(allocator);
    var a_idx: usize = 0;
    var b_idx: usize = 0;
    var is_in: usize = 0;
    var char: u32 = 0;
    
    while(true) {
        // /* get one more point from a or b in increasing order */
        if (a_idx < first_points.len and b_idx < second_points.len) {
            if (first_points[a_idx] < second_points[b_idx]) {
                char = first_points[a_idx];
                a_idx += 1;
            } else if (first_points[a_idx] == second_points[b_idx]) {
                char = first_points[a_idx];
                a_idx += 1;
                b_idx += 1;
            } else {
                char = second_points[b_idx];
                b_idx += 1;
            }
        } else if (a_idx < first_points.len) {
            char = first_points[a_idx];
            a_idx += 1;
        } else if (b_idx < second_points.len) {
            char = second_points[b_idx];
            b_idx += 1;
        } else {
            break;
        }

        // /* add the point if the in/out status changes */
        is_in = switch(op) {
            .CR_OP_UNION => (a_idx & 1) | (b_idx & 1),
            .CR_OP_INTER => (a_idx & 1) & (b_idx & 1),
            .CR_OP_XOR => (a_idx & 1) ^ (b_idx & 1),
        };
        if (is_in != (cr.items.len & 1)) {
            try cr.append(char);
        }
    }
    try cr_compress(&cr);
    return cr;
}

test "cr_op()" {
    const a = testing.allocator;
    {
        // union
        const first: []const u32 = &[_] u32{
            'a', 'd', 'w', 'z'
        };

        const second: []const u32 = &[_] u32{
            'a', 'c', 'j', 'l'
        };

        const result = cr_op(a, first, second, .CR_OP_UNION) catch unreachable;
        defer result.deinit();

        testing.expect(result.items.len == 6);
        testing.expect(result.items[0] == 'a');
        testing.expect(result.items[1] == 'd');
        testing.expect(result.items[2] == 'j');
        testing.expect(result.items[3] == 'l');
        testing.expect(result.items[4] == 'w');
        testing.expect(result.items[5] == 'z');
    }
    {
        // intersect
        const first: []const u32 = &[_] u32{
            'a', 'd', 'w', 'z'
        };

        const second: []const u32 = &[_] u32{
            'a', 'c', 'j', 'l'
        };

        const result = cr_op(a, first, second, .CR_OP_INTER) catch unreachable;
        defer result.deinit();

        testing.expect(result.items.len == 2);
        testing.expect(result.items[0] == 'a');
        testing.expect(result.items[1] == 'c');
    }
    {
        // XOR
        const first: []const u32 = &[_] u32{
            'a', 'd', 'w', 'z'
        };

        const second: []const u32 = &[_] u32{
            'a', 'c', 'j', 'l'
        };

        const result = cr_op(a, first, second, .CR_OP_INTER) catch unreachable;
        defer result.deinit();

        testing.expect(result.items.len == 2);
        testing.expect(result.items[0] == 'a');
        testing.expect(result.items[1] == 'c');
    }
}

/// Takes the union of the given character range and the given slice of points
/// and returns a new character range containing the combination of the two.
/// Caller owns result.
pub fn cr_union1(cr: *CharRange, other_points: []const u32) !CharRange {
    const result = try cr_op(cr.allocator, cr.items, other_points, .CR_OP_UNION);
    return result;
}

test "cr_union1()" {
    const a = testing.allocator;
    {
        // union
        var first = CharRange.init(a);
        defer first.deinit();
        try first.append('a');
        try first.append('d');
        try first.append('w');
        try first.append('z');

        const second: []const u32 = &[_] u32{
            'a', 'c', 'j', 'l'
        };

        const result = try cr_union1(&first, second);
        defer result.deinit();

        // const result = cr_op(a, first, second, .CR_OP_UNION) catch unreachable;
        // defer result.deinit();

        testing.expect(result.items.len == 6);
        testing.expect(result.items[0] == 'a');
        testing.expect(result.items[1] == 'd');
        testing.expect(result.items[2] == 'j');
        testing.expect(result.items[3] == 'l');
        testing.expect(result.items[4] == 'w');
        testing.expect(result.items[5] == 'z');
    }
}