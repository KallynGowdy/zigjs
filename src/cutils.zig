// 
//  C utilities
//  
//  Copyright (c) 2017 Fabrice Bellard
//  Copyright (c) 2018 Charlie Gordon
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 
// #include <stdlib.h>
// #include <stdio.h>
// #include <stdarg.h>
// #include <string.h>

// #include "cutils.h"
const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub const DynBuf = struct {
    buf: []u8,
    size: usize,
    allocated_size: usize,
    
    /// true if a memory allocation error occurred
    err: bool,
    
    allocator: *Allocator,
};

pub fn pstrcpy(buf: []u8, buf_size: usize, str: []const u8) noreturn
{
    if (buf_size <= 0)
        return;

    var i: usize = 0;
    while(i < str.len and i < buf_size) {
        buf[i] = str[i];
    }
}

/// strcat and truncate.
pub fn pstrcat(buf: []u8, buf_size: usize, s: []const u8) []u8
{
    const len = buf.len;
    if (len < buf_size)
        pstrcpy(buf + len, buf_size - len, s);
    return buf;
}

// TODO: Implement
// pub fn strstart(str: []const u8, val: []const u8,  const char **ptr) i32
// {
//     const char *p, *q;
//     p = str;
//     q = val;
//     while (*q != '\0') {
//         if (*p != *q)
//             return 0;
//         p++;
//         q++;
//     }
//     if (ptr)
//         *ptr = p;
//     return 1;
// }

pub fn has_suffix(str: []const u8, suffix: []const u8) bool
{
    return std.mem.endsWith([]const u8, str, suffix);
}

// /* Dynamic buffer package */

// void dbuf_init2(s: *DynBuf, allocator: *Allocator)
// {
    
//     memset(s, 0, sizeof(*s));
//     if (!realloc_func)
//         realloc_func = dbuf_default_realloc;
//     s->opaque = opaque;
//     s->realloc_func = realloc_func;
// }

// void dbuf_init(DynBuf *s)
// {
//     dbuf_init2(s, NULL, NULL);
// }

/// return true if error
pub fn dbuf_realloc(s: *DynBuf, new_size: usize) bool
{
    var alloc_size = new_size;
    if (alloc_size > s.*.allocated_size) {
        if (s.*.err) {
            return true;
        }
        const size: usize = s.*.allocated_size * 3 / 2;
        if (size > alloc_size) {
            alloc_size = size;
        }
        const new_buf = try s.*.allocator.*.realloc(s.*.buf, alloc_size);
        if (new_buf == error.OutOfMemory) {
            s.*.err = true;
            return true;
        }
        s.*.buf = new_buf;
        s.*.allocated_size = alloc_size;
    }
    return false;
}

/// returns true if errors
pub fn dbuf_write(s: *DynBuf, offset: usize, data: []const u8) bool
{
    const end = offset + data.len;
    if (dbuf_realloc(s, end)) {
        return true;
    }
    std.mem.copy([]u8, s.*.buf[offset..], data);
    if (end > s.*.size)
        s.*.size = end;
    return false;
}

/// returns true if errors
pub fn dbuf_put(s: *DynBuf, data: []const u8) bool
{
    // TODO: Add branch prediction hint
    if (s.*.size + data.len > s.*.allocated_size) {
        if (dbuf_realloc(s, s.*.size + data.len)) {
            return true;
        }
    }
    std.mem.copy([]u8, s.*.buf[s.*.size..], data);
    s.*.size += data.len;
    return false;
}

/// returns true if errors
pub fn dbuf_put_self(s: *DynBuf, offset: usize, len: usize) bool
{
    // TODO: Add branch prediction hint
    if (s.*.size + len > s.*.allocated_size) {
        if (dbuf_realloc(s, s.*.size + len))
            return true;
    }
    std.mem.copy([]u8, s.*.buf[s.*.size..], s.*.buf[offset..offset+len]);
    s.*.size += len;
    return false;
}

pub fn dbuf_putc(s: *DynBuf, c: u8) bool
{
    return dbuf_put(s, &c, 1);
}

pub fn dbuf_putstr(s: *DynBuf, str: []const u8) bool
{
    return dbuf_put(s, str, str.len);
}

pub fn dbuf_printf(s: *DynBuf, fmt: []const u8, args: anytype) bool
{
    const needed_len = std.fmt.count(fmt, args);

    if (s.*.size + needed_len > s.*.allocated_size) {
        if (dbuf_realloc(s, s.*.size + needed_len)) {
            return true;
        }
    }

    const written = std.fmt.bufPrint(s.*.buf[s.*.size..], fmt, args) catch |err| return true;
    s.*.size += written;
    
    return false;
}

pub fn dbuf_free(s: *DynBuf) void
{
    // /* we test s->buf as a fail safe to avoid crashing if dbuf_free()
    //    is called twice */
    if (s.*.buf) {
        s.*.allocator.free(s.*.buf);
    }
}

// /* Note: at most 31 bits are encoded. At most UTF8_CHAR_LEN_MAX bytes
//    are output. */
/// Writes the given unicode codepoint (c) to the buffer (buf) encoded in UTF-8.
pub fn unicode_to_utf8(buf: []u8, c: u32) !i32 {
    return try std.unicode.utf8Encode(c, buf);
}

// /* return -1 if error. *pp is not updated in this case. max_len must
//    be >= 1. The maximum length for a UTF8 byte sequence is 6 bytes. */
// Decodes a unicode character from the given buffer and puts it in the given output.
pub fn unicode_from_utf8(buf: []const u8, max_len: i32, out: **const u8) i32
{
    const len = std.unicode.utf8ByteSequenceLength(buf[0]) catch unreachable;
    if (len > max_len) {
        return -1;
    }
    const result = std.unicode.utf8Decode(buf[0..len]) catch -1;
    if(result < 0) {
        return result;
    }
    out.* = result;
    return len;
}


// typedef void (*exchange_f)(void *a, void *b, size_t size);
// typedef int (*cmp_f)(const void *, const void *, void *opaque);

// static void exchange_bytes(void *a, void *b, size_t size) {
//     uint8_t *ap = (uint8_t *)a;
//     uint8_t *bp = (uint8_t *)b;

//     while (size-- != 0) {
//         uint8_t t = *ap;
//         *ap++ = *bp;
//         *bp++ = t;
//     }
// }

// static void exchange_one_byte(void *a, void *b, size_t size) {
//     uint8_t *ap = (uint8_t *)a;
//     uint8_t *bp = (uint8_t *)b;
//     uint8_t t = *ap;
//     *ap = *bp;
//     *bp = t;
// }

// static void exchange_int16s(void *a, void *b, size_t size) {
//     uint16_t *ap = (uint16_t *)a;
//     uint16_t *bp = (uint16_t *)b;

//     for (size /= sizeof(uint16_t); size-- != 0;) {
//         uint16_t t = *ap;
//         *ap++ = *bp;
//         *bp++ = t;
//     }
// }

// static void exchange_one_int16(void *a, void *b, size_t size) {
//     uint16_t *ap = (uint16_t *)a;
//     uint16_t *bp = (uint16_t *)b;
//     uint16_t t = *ap;
//     *ap = *bp;
//     *bp = t;
// }

// static void exchange_int32s(void *a, void *b, size_t size) {
//     uint32_t *ap = (uint32_t *)a;
//     uint32_t *bp = (uint32_t *)b;

//     for (size /= sizeof(uint32_t); size-- != 0;) {
//         uint32_t t = *ap;
//         *ap++ = *bp;
//         *bp++ = t;
//     }
// }

// static void exchange_one_int32(void *a, void *b, size_t size) {
//     uint32_t *ap = (uint32_t *)a;
//     uint32_t *bp = (uint32_t *)b;
//     uint32_t t = *ap;
//     *ap = *bp;
//     *bp = t;
// }

// static void exchange_int64s(void *a, void *b, size_t size) {
//     uint64_t *ap = (uint64_t *)a;
//     uint64_t *bp = (uint64_t *)b;

//     for (size /= sizeof(uint64_t); size-- != 0;) {
//         uint64_t t = *ap;
//         *ap++ = *bp;
//         *bp++ = t;
//     }
// }

// static void exchange_one_int64(void *a, void *b, size_t size) {
//     uint64_t *ap = (uint64_t *)a;
//     uint64_t *bp = (uint64_t *)b;
//     uint64_t t = *ap;
//     *ap = *bp;
//     *bp = t;
// }

// static void exchange_int128s(void *a, void *b, size_t size) {
//     uint64_t *ap = (uint64_t *)a;
//     uint64_t *bp = (uint64_t *)b;

//     for (size /= sizeof(uint64_t) * 2; size-- != 0; ap += 2, bp += 2) {
//         uint64_t t = ap[0];
//         uint64_t u = ap[1];
//         ap[0] = bp[0];
//         ap[1] = bp[1];
//         bp[0] = t;
//         bp[1] = u;
//     }
// }

// static void exchange_one_int128(void *a, void *b, size_t size) {
//     uint64_t *ap = (uint64_t *)a;
//     uint64_t *bp = (uint64_t *)b;
//     uint64_t t = ap[0];
//     uint64_t u = ap[1];
//     ap[0] = bp[0];
//     ap[1] = bp[1];
//     bp[0] = t;
//     bp[1] = u;
// }

// static inline exchange_f exchange_func(const void *base, size_t size) {
//     switch (((uintptr_t)base | (uintptr_t)size) & 15) {
//     case 0:
//         if (size == sizeof(uint64_t) * 2)
//             return exchange_one_int128;
//         else
//             return exchange_int128s;
//     case 8:
//         if (size == sizeof(uint64_t))
//             return exchange_one_int64;
//         else
//             return exchange_int64s;
//     case 4:
//     case 12:
//         if (size == sizeof(uint32_t))
//             return exchange_one_int32;
//         else
//             return exchange_int32s;
//     case 2:
//     case 6:
//     case 10:
//     case 14:
//         if (size == sizeof(uint16_t))
//             return exchange_one_int16;
//         else
//             return exchange_int16s;
//     default:
//         if (size == 1)
//             return exchange_one_byte;
//         else
//             return exchange_bytes;
//     }
// }

// static void heapsortx(void *base, size_t nmemb, size_t size, cmp_f cmp, void *opaque)
// {
//     uint8_t *basep = (uint8_t *)base;
//     size_t i, n, c, r;
//     exchange_f swap = exchange_func(base, size);

//     if (nmemb > 1) {
//         i = (nmemb / 2) * size;
//         n = nmemb * size;

//         while (i > 0) {
//             i -= size;
//             for (r = i; (c = r * 2 + size) < n; r = c) {
//                 if (c < n - size && cmp(basep + c, basep + c + size, opaque) <= 0)
//                     c += size;
//                 if (cmp(basep + r, basep + c, opaque) > 0)
//                     break;
//                 swap(basep + r, basep + c, size);
//             }
//         }
//         for (i = n - size; i > 0; i -= size) {
//             swap(basep, basep + i, size);

//             for (r = 0; (c = r * 2 + size) < i; r = c) {
//                 if (c < i - size && cmp(basep + c, basep + c + size, opaque) <= 0)
//                     c += size;
//                 if (cmp(basep + r, basep + c, opaque) > 0)
//                     break;
//                 swap(basep + r, basep + c, size);
//             }
//         }
//     }
// }

// static inline void *med3(void *a, void *b, void *c, cmp_f cmp, void *opaque)
// {
//     return cmp(a, b, opaque) < 0 ?
//         (cmp(b, c, opaque) < 0 ? b : (cmp(a, c, opaque) < 0 ? c : a )) :
//         (cmp(b, c, opaque) > 0 ? b : (cmp(a, c, opaque) < 0 ? a : c ));
// }

// /* pointer based version with local stack and insertion sort threshhold */
// void rqsort(void *base, size_t nmemb, size_t size, cmp_f cmp, void *opaque)
// {
//     struct { uint8_t *base; size_t count; int depth; } stack[50], *sp = stack;
//     uint8_t *ptr, *pi, *pj, *plt, *pgt, *top, *m;
//     size_t m4, i, lt, gt, span, span2;
//     int c, depth;
//     exchange_f swap = exchange_func(base, size);
//     exchange_f swap_block = exchange_func(base, size | 128);

//     if (nmemb < 2 || size <= 0)
//         return;

//     sp->base = (uint8_t *)base;
//     sp->count = nmemb;
//     sp->depth = 0;
//     sp++;

//     while (sp > stack) {
//         sp--;
//         ptr = sp->base;
//         nmemb = sp->count;
//         depth = sp->depth;

//         while (nmemb > 6) {
//             if (++depth > 50) {
//                 /* depth check to ensure worst case logarithmic time */
//                 heapsortx(ptr, nmemb, size, cmp, opaque);
//                 nmemb = 0;
//                 break;
//             }
//             /* select median of 3 from 1/4, 1/2, 3/4 positions */
//             /* should use median of 5 or 9? */
//             m4 = (nmemb >> 2) * size;
//             m = med3(ptr + m4, ptr + 2 * m4, ptr + 3 * m4, cmp, opaque);
//             swap(ptr, m, size);  /* move the pivot to the start or the array */
//             i = lt = 1;
//             pi = plt = ptr + size;
//             gt = nmemb;
//             pj = pgt = top = ptr + nmemb * size;
//             for (;;) {
//                 while (pi < pj && (c = cmp(ptr, pi, opaque)) >= 0) {
//                     if (c == 0) {
//                         swap(plt, pi, size);
//                         lt++;
//                         plt += size;
//                     }
//                     i++;
//                     pi += size;
//                 }
//                 while (pi < (pj -= size) && (c = cmp(ptr, pj, opaque)) <= 0) {
//                     if (c == 0) {
//                         gt--;
//                         pgt -= size;
//                         swap(pgt, pj, size);
//                     }
//                 }
//                 if (pi >= pj)
//                     break;
//                 swap(pi, pj, size);
//                 i++;
//                 pi += size;
//             }
//             /* array has 4 parts:
//              * from 0 to lt excluded: elements identical to pivot
//              * from lt to pi excluded: elements smaller than pivot
//              * from pi to gt excluded: elements greater than pivot
//              * from gt to n excluded: elements identical to pivot
//              */
//             /* move elements identical to pivot in the middle of the array: */
//             /* swap values in ranges [0..lt[ and [i-lt..i[
//                swapping the smallest span between lt and i-lt is sufficient
//              */
//             span = plt - ptr;
//             span2 = pi - plt;
//             lt = i - lt;
//             if (span > span2)
//                 span = span2;
//             swap_block(ptr, pi - span, span);
//             /* swap values in ranges [gt..top[ and [i..top-(top-gt)[
//                swapping the smallest span between top-gt and gt-i is sufficient
//              */
//             span = top - pgt;
//             span2 = pgt - pi;
//             pgt = top - span2;
//             gt = nmemb - (gt - i);
//             if (span > span2)
//                 span = span2;
//             swap_block(pi, top - span, span);

//             /* now array has 3 parts:
//              * from 0 to lt excluded: elements smaller than pivot
//              * from lt to gt excluded: elements identical to pivot
//              * from gt to n excluded: elements greater than pivot
//              */
//             /* stack the larger segment and keep processing the smaller one
//                to minimize stack use for pathological distributions */
//             if (lt > nmemb - gt) {
//                 sp->base = ptr;
//                 sp->count = lt;
//                 sp->depth = depth;
//                 sp++;
//                 ptr = pgt;
//                 nmemb -= gt;
//             } else {
//                 sp->base = pgt;
//                 sp->count = nmemb - gt;
//                 sp->depth = depth;
//                 sp++;
//                 nmemb = lt;
//             }
//         }
//         /* Use insertion sort for small fragments */
//         for (pi = ptr + size, top = ptr + nmemb * size; pi < top; pi += size) {
//             for (pj = pi; pj > ptr && cmp(pj - size, pj, opaque) > 0; pj -= size)
//                 swap(pj, pj - size, size);
//         }
//     }
// }

const HexParseError = error {
    InvalidChar
};


pub fn from_hex(char: u8) !u8 {
    if (char >= '0' and char <= '9') {
        return char - '0';
    } else if (char >= 'A' and char <= 'F') {
        return char - 'A' + 10;
    } else if (char >= 'a' and char <= 'f') {
        return char - 'a' + 10;
    } else {
        return HexParseError.InvalidChar;
    }
}

test "from_hex()" {
    {
        // decimal digits
        testing.expect((try from_hex('0')) == 0);
        testing.expect((try from_hex('1')) == 1);
        testing.expect((try from_hex('2')) == 2);
        testing.expect((try from_hex('3')) == 3);
        testing.expect((try from_hex('4')) == 4);
        testing.expect((try from_hex('5')) == 5);
        testing.expect((try from_hex('6')) == 6);
        testing.expect((try from_hex('7')) == 7);
        testing.expect((try from_hex('8')) == 8);
        testing.expect((try from_hex('9')) == 9);

        // hex digits
        testing.expect((try from_hex('A')) == 10);
        testing.expect((try from_hex('B')) == 11);
        testing.expect((try from_hex('C')) == 12);
        testing.expect((try from_hex('D')) == 13);
        testing.expect((try from_hex('E')) == 14);
        testing.expect((try from_hex('F')) == 15);
        testing.expect((try from_hex('a')) == 10);
        testing.expect((try from_hex('b')) == 11);
        testing.expect((try from_hex('c')) == 12);
        testing.expect((try from_hex('d')) == 13);
        testing.expect((try from_hex('e')) == 14);
        testing.expect((try from_hex('f')) == 15);

        testing.expectError(HexParseError.InvalidChar, from_hex('!'));
    }
}