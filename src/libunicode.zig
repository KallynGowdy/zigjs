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

//
// unicode_find_name(const char *name_table, const char *name) []const u8 {
//     const char *p, *r;
//     int pos;
//     size_t name_len, len;
    
//     p = name_table;
//     pos = 0;
//     name_len = strlen(name);
//     while (*p) {
//         for(;;) {
//             r = strchr(p, ',');
//             if (!r)
//                 len = strlen(p);
//             else
//                 len = r - p;
//             if (len == name_len && !memcmp(p, name, name_len))
//                 return pos;
//             p += len + 1;
//             if (!r)
//                 break;
//         }
//         pos++;
//     }
//     return -1;
// }

// /* 'cr' must be initialized and empty. Return 0 if OK, -1 if error, -2
//    if not found */
// Gets a new character range for the unicode characters that are in the given category.
// pub fn unicode_script(script_name: []const u8, is_ext: bool) !CharRange {

//     var script_idx: usize = 0;
//     // int script_idx;


//     const uint8_t *p, *p_end;
//     uint32_t c, c1, b, n, v, v_len, i, type;
//     CharRange cr1_s, *cr1;
//     CharRange cr2_s, *cr2 = &cr2_s;
//     BOOL is_common;
    
//     script_idx = unicode_find_name(unicode_script_name_table, script_name);
//     if (script_idx < 0)
//         return -2;
//     /* Note: we remove the "Unknown" Script */
//     script_idx += UNICODE_SCRIPT_Unknown + 1;
        
//     is_common = (script_idx == UNICODE_SCRIPT_Common ||
//                  script_idx == UNICODE_SCRIPT_Inherited);
//     if (is_ext) {
//         cr1 = &cr1_s;
//         cr_init(cr1, cr->mem_opaque, cr->realloc_func);
//         cr_init(cr2, cr->mem_opaque, cr->realloc_func);
//     } else {
//         cr1 = cr;
//     }

//     p = unicode_script_table;
//     p_end = unicode_script_table + countof(unicode_script_table);
//     c = 0;
//     while (p < p_end) {
//         b = *p++;
//         type = b >> 7;
//         n = b & 0x7f;
//         if (n < 96) {
//         } else if (n < 112) {
//             n = (n - 96) << 8;
//             n |= *p++;
//             n += 96;
//         } else {
//             n = (n - 112) << 16;
//             n |= *p++ << 8;
//             n |= *p++;
//             n += 96 + (1 << 12);
//         }
//         if (type == 0)
//             v = 0;
//         else
//             v = *p++;
//         c1 = c + n + 1;
//         if (v == script_idx) {
//             if (cr_add_interval(cr1, c, c1))
//                 goto fail;
//         }
//         c = c1;
//     }

//     if (is_ext) {
//         /* add the script extensions */
//         p = unicode_script_ext_table;
//         p_end = unicode_script_ext_table + countof(unicode_script_ext_table);
//         c = 0;
//         while (p < p_end) {
//             b = *p++;
//             if (b < 128) {
//                 n = b;
//             } else if (b < 128 + 64) {
//                 n = (b - 128) << 8;
//                 n |= *p++;
//                 n += 128;
//             } else {
//                 n = (b - 128 - 64) << 16;
//                 n |= *p++ << 8;
//                 n |= *p++;
//                 n += 128 + (1 << 14);
//             }
//             c1 = c + n + 1;
//             v_len = *p++;
//             if (is_common) {
//                 if (v_len != 0) {
//                     if (cr_add_interval(cr2, c, c1))
//                         goto fail;
//                 }
//             } else {
//                 for(i = 0; i < v_len; i++) {
//                     if (p[i] == script_idx) {
//                         if (cr_add_interval(cr2, c, c1))
//                             goto fail;
//                         break;
//                     }
//                 }
//             }
//             p += v_len;
//             c = c1;
//         }
//         if (is_common) {
//             /* remove all the characters with script extensions */
//             if (cr_invert(cr2))
//                 goto fail;
//             if (cr_op(cr, cr1->points, cr1->len, cr2->points, cr2->len,
//                       CR_OP_INTER))
//                 goto fail;
//         } else {
//             if (cr_op(cr, cr1->points, cr1->len, cr2->points, cr2->len,
//                       CR_OP_UNION))
//                 goto fail;
//         }
//         cr_free(cr1);
//         cr_free(cr2);
//     }
//     return 0;
//  fail:
//     if (is_ext) {
//         cr_free(cr1);
//         cr_free(cr2);
//     }
//     goto fail;
// }