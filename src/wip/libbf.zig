const std = @import("std");

// always assume 64 bit arch
// See https://github.com/bellard/quickjs/blob/b5e62895c619d4ffc75c9d822c8d85f1ece77e5b/libbf.h#L30
const LIMB_LOG2_BITS = 6;
const LIMB_BITS = (1 << LIMB_LOG2_BITS);

const BF_RAW_EXP_MIN = std.math.minInt(i64);
const BF_RAW_EXP_MAX = std.math.maxInt(i64);
const LIMB_DIGITS = 19;
const BF_DEC_BASE: u64 = 10000000000000000000;

/// minimum number of bits for the exponent 
const BF_EXP_BITS_MIN  = 3;
/// maximum number of bits for the exponent 
const BF_EXP_BITS_MAX = (LIMB_BITS - 3);
/// extended range for exponent, used internally
const BF_EXT_EXP_BITS_MAX = (BF_EXP_BITS_MAX + 1);
/// minimum possible precision
const BF_PREC_MIN = 2;
/// minimum possible precision 
const BF_PREC_MAX = ((1 << (LIMB_BITS - 2)) - 2);
/// some operations support infinite precision 
const BF_PREC_INF = (BF_PREC_MAX + 1); // infinite precision

const BF_CHKSUM_MOD = (975620677 * 9795002197);

const BF_EXP_ZERO = BF_RAW_EXP_MIN;
const BF_EXP_INF = (BF_RAW_EXP_MAX - 1);
const BF_EXP_NAN = BF_RAW_EXP_MAX;

const slimb_t = i64;
const limb_t = u64;
const dlimb_t = u128;

/// +/-zero is represented with expn = BF_EXP_ZERO and len = 0,
/// +/-infinity is represented with expn = BF_EXP_INF and len = 0,
/// NaN is represented with expn = BF_EXP_NAN and len = 0 (sign is ignored)
const bf_t = struct {
    ctx: *bf_context_t,
    sign: i32,
    expn: slimb_t,
    len: limb_t,
    tab: *limb_t,
};

const bf_rnd_t = enum {
    /// round to nearest, ties to even
    BF_RNDN,
    /// round to zero
    BF_RNDZ,
    /// round to -inf (the code relies on (BF_RNDD xor BF_RNDU) = 1)
    BF_RNDD,
    /// round to +inf
    BF_RNDU, 
    /// round to nearest, ties away from zero
    BF_RNDNA,
    /// round away from zero
    BF_RNDA,
    /// faithful rounding (nondeterministic, either RNDD or RNDU,
    ///    inexact flag is always set)
    BF_RNDF,
};

/// allow subnormal numbers. Only available if the number of exponent
/// bits is <= BF_EXP_BITS_USER_MAX and prec != BF_PREC_INF.
const BF_FLAG_SUBNORMAL = (1 << 3);
/// 'prec' is the precision after the radix point instead of the whole
/// mantissa. Can only be used with bf_round() and
/// bfdec_[add|sub|mul|div|sqrt|round]().
const BF_FLAG_RADPNT_PREC = (1 << 4);

const BF_RND_MASK = 0x7;
const BF_EXP_BITS_SHIFT = 5;
const BF_EXP_BITS_MASK = 0x3f;

/// shortcut for bf_set_exp_bits(BF_EXT_EXP_BITS_MAX)
const BF_FLAG_EXT_EXP = (BF_EXP_BITS_MASK << BF_EXP_BITS_SHIFT);

/// contains the rounding mode and number of exponents bits
const bf_flags_t = u32;

const bf_realloc_func_t = fn(opaque: *c_void, ptr: *c_void, size: usize) *c_void;

const BFConstCache = struct {
    val: bf_t,
    prec: limb_t
};

const bf_context_t = struct {
    realloc_opaque: c_void,
    realloc_func: bf_realloc_func_t,
    log2_cache: BFConstCache,
    pi_cache: BFConstCache,
    struct BFNTTState *ntt_state,
};

const BFNTTState = struct {
    ctx:  *bf_context_t;
    
    /// used for mul_mod_fast()
    ntt_mods_div: [NB_MODS]limb_t,

    ntt_proot_pow: [NB_MODS][2][NTT_PROOT_2EXP + 1]limb_t,
    ntt_proot_pow_inv: [NB_MODS][2][NTT_PROOT_2EXP + 1]limb_t,
    ntt_trig: *[NB_MODS][2][NTT_TRIG_K_MAX + 1]NTTLimb,

    /// 1/2^n mod m
    ntt_len_inv: [NB_MODS][NTT_PROOT_2EXP + 1][2]limb_t,
    
    ntt_mods_cr_inv: [NB_MODS * (NB_MODS - 1) / 2]limb_t;
#endif
};


