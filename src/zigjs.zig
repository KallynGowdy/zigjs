const std = @import("std");
const testing = std.testing;

const JSClassEnum = enum {
    // /* classid tag        */    /* union usage   | properties */
    ///  must be first
    JS_CLASS_OBJECT = 1,        
    JS_CLASS_ARRAY,             
    JS_CLASS_ERROR,
    JS_CLASS_NUMBER,            
    JS_CLASS_STRING,            
    JS_CLASS_BOOLEAN,           
    JS_CLASS_SYMBOL,            
    JS_CLASS_ARGUMENTS,         
    JS_CLASS_MAPPED_ARGUMENTS,  
    JS_CLASS_DATE,              
    JS_CLASS_MODULE_NS,
    JS_CLASS_C_FUNCTION,        
    JS_CLASS_BYTECODE_FUNCTION, 
    JS_CLASS_BOUND_FUNCTION,    
    JS_CLASS_C_FUNCTION_DATA,   
    JS_CLASS_GENERATOR_FUNCTION, 
    JS_CLASS_FOR_IN_ITERATOR,   
    JS_CLASS_REGEXP,            
    JS_CLASS_ARRAY_BUFFER,      
    JS_CLASS_SHARED_ARRAY_BUFFER, 
    JS_CLASS_UINT8C_ARRAY,      
    JS_CLASS_INT8_ARRAY,        
    JS_CLASS_UINT8_ARRAY,       
    JS_CLASS_INT16_ARRAY,       
    JS_CLASS_UINT16_ARRAY,      
    JS_CLASS_INT32_ARRAY,       
    JS_CLASS_UINT32_ARRAY,      

    // TODO: Add support for bignum
// #ifdef CONFIG_BIGNU
//     JS_CLASS_BIG_INT64_ARRAY,  
//     JS_CLASS_BIG_UINT64_ARRAY,  
// #endif
    JS_CLASS_FLOAT32_ARRAY,     
    JS_CLASS_FLOAT64_ARRAY,     
    JS_CLASS_DATAVIEW,

// TODO: Add support for bignum
// #ifdef CONFIG_BIGNU
//     JS_CLASS_BIG_INT,          
//     JS_CLASS_BIG_FLOAT,        
//     JS_CLASS_FLOAT_ENV,        
//     JS_CLASS_BIG_DECIMAL,      
//     JS_CLASS_OPERATOR_SET,      
// #endif

    JS_CLASS_MAP,               
    JS_CLASS_SET,               
    JS_CLASS_WEAKMAP,           
    JS_CLASS_WEAKSET,           
    JS_CLASS_MAP_ITERATOR,      
    JS_CLASS_SET_ITERATOR,      
    JS_CLASS_ARRAY_ITERATOR,    
    JS_CLASS_STRING_ITERATOR,   
    JS_CLASS_REGEXP_STRING_ITERATOR,   
    JS_CLASS_GENERATOR,         
    JS_CLASS_PROXY,             
    JS_CLASS_PROMISE,           
    JS_CLASS_PROMISE_RESOLVE_FUNCTION,  
    JS_CLASS_PROMISE_REJECT_FUNCTION,   
    JS_CLASS_ASYNC_FUNCTION,            
    JS_CLASS_ASYNC_FUNCTION_RESOLVE,    
    JS_CLASS_ASYNC_FUNCTION_REJECT,     
    JS_CLASS_ASYNC_FROM_SYNC_ITERATOR,  
    JS_CLASS_ASYNC_GENERATOR_FUNCTION,  
    JS_CLASS_ASYNC_GENERATOR,   

    JS_CLASS_INIT_COUNT, 
};

const JSRefCountHeader = struct {
    ref_count: i32
};


const JSError = enum {
    JS_EVAL_ERROR,
    JS_RANGE_ERROR,
    JS_REFERENCE_ERROR,
    JS_SYNTAX_ERROR,
    JS_TYPE_ERROR,
    JS_URI_ERROR,
    JS_INTERNAL_ERROR,
    JS_AGGREGATE_ERROR,
    
    /// number of different NativeError objects
    JS_NATIVE_ERROR_COUNT, 
};

const JS_MAX_LOCAL_VARS: u32 = 65536;
const JS_STACK_SIZE_MAX: u32 = 65536;
const JS_STRING_LEN_MAX: u32 = ((1 << 30) - 1);

const JSGCPhase = enum {
    JS_GC_PHASE_NONE,
    JS_GC_PHASE_DECREF,
    JS_GC_PHASE_REMOVE_CYCLES,
};

const JSPointerValue = opaque{};

const float64_nan = std.math.nan(f64);

const JSValueUnion = union {
    int32: i32,
    float64: f64,
    ptr: *JSPointerValue,
};

const JSClassID = u32;
const JSAtom = u32;

const JSTag = enum(i6) {
    // /* all tags with a reference count are negative */
    // JS_TAG_BIG_DECIMAL = -11,
    // JS_TAG_BIG_INT     = -10,
    // JS_TAG_BIG_FLOAT   = -9,
    JS_TAG_SYMBOL      = -8,
    JS_TAG_STRING      = -7,
    JS_TAG_MODULE      = -3, //* used internally */
    JS_TAG_FUNCTION_BYTECODE = -2, //* used internally */
    JS_TAG_OBJECT      = -1,

    JS_TAG_INT         = 0,
    JS_TAG_BOOL        = 1,
    JS_TAG_NULL        = 2,
    JS_TAG_UNDEFINED   = 3,
    JS_TAG_UNINITIALIZED = 4,
    JS_TAG_CATCH_OFFSET = 5,
    JS_TAG_EXCEPTION   = 6,
    JS_TAG_FLOAT64     = 7,
    // /* any larger tag is FLOAT64 if JS_NAN_BOXING */
};

const JSValue = union(JSTag) {
    JS_TAG_SYMBOL: JSAtom,
    JS_TAG_MODULE: *JSModuleDef,
    JS_TAG_STRING: *JSString,
    JS_TAG_OBJECT: *JSValue,
    JS_TAG_FUNCTION_BYTECODE: *JSFunctionBytecode,
    JS_TAG_INT: i32,
    JS_TAG_BOOL: bool,
    JS_TAG_NULL: void,
    JS_TAG_UNDEFINED: void,
    JS_TAG_UNINITIALIZED: void,
    JS_TAG_CATCH_OFFSET: i32,
    JS_TAG_EXCEPTION: void,
    JS_TAG_FLOAT64: f64,
};

const JSSymbol = struct {

};

const JSModuleDef = struct {

};

// const JSValue = struct {
//     u: JSValueUnion,
//     tag: JSTag,
// };

const JSPropertyGetterSetter = struct {
    getter: *JSObject,
    setter: *JSObject,
};

const JSPropertyAutoInit = struct {
    realm_and_id: u64,
    // o: opaque{},
};

const JSVarRef = opaque{};

const JSProperty = union {
    value: JSValue,
    getset: JSPropertyGetterSetter,
    var_ref: *JSVarRef,
    init: JSPropertyAutoInit
};

// typedef struct JSProperty {
//     union {
//         JSValue value;      /* JS_PROP_NORMAL */
//         struct {            /* JS_PROP_GETSET */
//             JSObject *getter; /* NULL if undefined */
//             JSObject *setter; /* NULL if undefined */
//         } getset;
//         JSVarRef *var_ref;  /* JS_PROP_VARREF */
//         struct {            /* JS_PROP_AUTOINIT */
//             /* in order to use only 2 pointers, we compress the realm
//                and the init function pointer */
//             uintptr_t realm_and_id; /* realm and init_id (JS_AUTOINIT_ID_x)
//                                        in the 2 low bits */
//             void *opaque;
//         } init;
//     } u;
// } JSProperty;


// typedef struct JSVarRef {
//     union {
//         JSGCObjectHeader header; /* must come first */
//         struct {
//             int __gc_ref_count; /* corresponds to header.ref_count */
//             uint8_t __gc_mark; /* corresponds to header.mark/gc_obj_type */

//             /* 0 : the JSVarRef is on the stack. header.link is an element
//                of JSStackFrame.var_ref_list.
//                1 : the JSVarRef is detached. header.link has the normal meanning 
//             */
//             uint8_t is_detached : 1; 
//             uint8_t is_arg : 1;
//             uint16_t var_idx; /* index of the corresponding function variable on
//                                  the stack */
//         };
//     };
//     JSValue *pvalue; /* pointer to the value, either on the stack or
//                         to 'value' */
//     JSValue value; /* used when the variable is no longer on the stack */
// } JSVarRef;


    

//     JS_CLASS_OBJECT = 1,        
//     JS_CLASS_ARRAY,             
//     JS_CLASS_ERROR,
//     JS_CLASS_NUMBER,            
//     JS_CLASS_STRING,            
//     JS_CLASS_BOOLEAN,           
//     JS_CLASS_SYMBOL,            
//     JS_CLASS_ARGUMENTS,         
//     JS_CLASS_MAPPED_ARGUMENTS,  
//     JS_CLASS_DATE,              
//     JS_CLASS_MODULE_NS,
//     JS_CLASS_C_FUNCTION,        
//     JS_CLASS_BYTECODE_FUNCTION, 
//     JS_CLASS_BOUND_FUNCTION,    
//     JS_CLASS_C_FUNCTION_DATA,   
//     JS_CLASS_GENERATOR_FUNCTION, 
//     JS_CLASS_FOR_IN_ITERATOR,   
//     JS_CLASS_REGEXP,            
//     JS_CLASS_ARRAY_BUFFER,      
//     JS_CLASS_SHARED_ARRAY_BUFFER, 
//     JS_CLASS_UINT8C_ARRAY,      
//     JS_CLASS_INT8_ARRAY,        
//     JS_CLASS_UINT8_ARRAY,       
//     JS_CLASS_INT16_ARRAY,       
//     JS_CLASS_UINT16_ARRAY,      
//     JS_CLASS_INT32_ARRAY,       
//     JS_CLASS_UINT32_ARRAY,      

//     // TODO: Add support for bignum
// // #ifdef CONFIG_BIGNU
// //     JS_CLASS_BIG_INT64_ARRAY,  
// //     JS_CLASS_BIG_UINT64_ARRAY,  
// // #endif
//     JS_CLASS_FLOAT32_ARRAY,     
//     JS_CLASS_FLOAT64_ARRAY,     
//     JS_CLASS_DATAVIEW,

// // TODO: Add support for bignum
// // #ifdef CONFIG_BIGNU
// //     JS_CLASS_BIG_INT,          
// //     JS_CLASS_BIG_FLOAT,        
// //     JS_CLASS_FLOAT_ENV,        
// //     JS_CLASS_BIG_DECIMAL,      
// //     JS_CLASS_OPERATOR_SET,      
// // #endif

//     JS_CLASS_MAP,               
//     JS_CLASS_SET,               
//     JS_CLASS_WEAKMAP,           
//     JS_CLASS_WEAKSET,           
//     JS_CLASS_MAP_ITERATOR,      
//     JS_CLASS_SET_ITERATOR,      
//     JS_CLASS_ARRAY_ITERATOR,    
//     JS_CLASS_STRING_ITERATOR,   
//     JS_CLASS_REGEXP_STRING_ITERATOR,   
//     JS_CLASS_GENERATOR,         
//     JS_CLASS_PROXY,             
//     JS_CLASS_PROMISE,           
//     JS_CLASS_PROMISE_RESOLVE_FUNCTION,  
//     JS_CLASS_PROMISE_REJECT_FUNCTION,   
//     JS_CLASS_ASYNC_FUNCTION,            
//     JS_CLASS_ASYNC_FUNCTION_RESOLVE,    
//     JS_CLASS_ASYNC_FUNCTION_REJECT,     
//     JS_CLASS_ASYNC_FROM_SYNC_ITERATOR,  
//     JS_CLASS_ASYNC_GENERATOR_FUNCTION,  
//     JS_CLASS_ASYNC_GENERATOR,   

//     JS_CLASS_INIT_COUNT, 

const JSBoundFunction = struct{
    func_obj: JSValue,
    this_val: JSValue,
    args: []JSValue,
    // JSValue func_obj;
    // JSValue this_val;
    // int argc;
    // JSValue argv[0];
};
const JSCFunction = fn(ctx: *JSContext, this_val: JSValue, args: []JSValue) JSValue;
const JSCFunctionMagic = fn(ctx: *JSContext, this_val: JSValue, args: []JSValue, magic: i32) JSValue;
const JSCFunctionWithData = fn(ctx: *JSContext, this_val: JSValue, args: []JSValue, magic: i32, func_data: *JSValue)  JSValue;

const JSCFunctionDataRecord = struct{
    func: *JSCFunctionWithData,
    length: u8,
    data_len: u8,
    magic: u16,
    data: []JSValue,
    // JSCFunctionData *func;
    // uint8_t length;
    // uint8_t data_len;
    // uint16_t magic;
    // JSValue data[0];
};

fn JSCTypedArray(comptime T: type) type {
    return struct {
        obj: *JSObject,
        buffer: *JSObject,
        offset: u32,
        length: u32,
        data: ?[]T
        // struct list_head link; /* link to arraybuffer */
        // JSObject *obj; /* back pointer to the TypedArray/DataView object */
        // JSObject *buffer; /* based array buffer */
        // uint32_t offset; /* offset in the array buffer */
        // uint32_t length; /* length in the array buffer */
    };
}

const JSFreeArrayBufferDataFunc = fn(handle: *JSFreeArrayBufferDataFuncCallee) void;
const JSFreeArrayBufferDataFuncCallee = struct{};

const JSCArrayBufferMode = enum {
    Normal,
    Detached,
};

fn JSCNormalArrayBuffer(comptime T: type) type {
    return struct {
        shared: bool,
        data: []u8,
        array_list: std.TailQueue(JSCTypedArray(T)),
        free_func: *JSFreeArrayBufferDataFunc,
        callee: *JSFreeArrayBufferDataFuncCallee
    };
}

const JSCDetachedArrayBuffer = struct {
    free_func: *JSFreeArrayBufferDataFunc,
    callee: *JSFreeArrayBufferDataFuncCallee
};

fn JSCArrayBuffer(comptime T: type) type {
    return union(JSCArrayBufferMode) {
        Normal: JSCNormalArrayBuffer(T),
        Detached: JSCDetachedArrayBuffer,
    };
}

// const JSCArrayBuffer = struct{
//     // 0 if detached
//     byte_length: usize,
//     detached: bool,

//     // if shared, the array buffer cannot be detached
//     shared: bool,

//     // int byte_length; /* 0 if detached */
//     // uint8_t detached;
//     // uint8_t shared; /* if shared, the array buffer cannot be detached */
//     // uint8_t *data; /* NULL if detached */
//     // struct list_head array_list;
//     // void *opaque;
//     // JSFreeArrayBufferDataFunc *free_func;
// };

const JSCForInIterator = struct{
    obj: JSValue,
    is_array: bool,
    array_length: usize,
    idx: usize,
    // JSValue obj;
    // BOOL is_array;
    // uint32_t array_length;
    // uint32_t idx;
};
const JSCArray = struct{
    values: []JSValue
};
const JSMapIteratorData = struct{};
const JSArrayIteratorData = struct{};
const JSRegExpStringIteratorData = struct{};
const JSGeneratorData = struct{};

const JSProxyData = struct{
    target: JSValue,
    handler: JSValue,
    is_func: bool,
    is_revoked: bool,
    // JSValue target;
    // JSValue handler;
    // uint8_t is_func;
    // uint8_t is_revoked;
};

const JSPromiseStateEnum = enum {
    JS_PROMISE_PENDING,
    JS_PROMISE_FULFILLED,
    JS_PROMISE_REJECTED,
};

const JSPromiseData = struct{
    promise_state: JSPromiseStateEnum,
    is_handled: bool,
    promise_reactions: [2]JSPromiseReactionData,
    promise_result: JSValue,

    // JSPromiseStateEnum promise_state;
    // /* 0=fulfill, 1=reject, list of JSPromiseReactionData.link */
    // struct list_head promise_reactions[2];
    // BOOL is_handled; /* Note: only useful to debug */
    // JSValue promise_result;
};
const JSPromiseFunctionData = struct{
    promise: JSValue,
    presolved: *JSPromiseFunctionDataResolved,
};
const JSPromiseFunctionDataResolved = struct {
    ref_count: usize,
    already_resolved: bool,
};
const JSAsyncFunctionData = struct{
    header: JSGCObjectHeader,
    resolving_funcs: [2]JSValue,
    is_active: bool,
    func_state: JSAsyncFunctionState,
    // JSGCObjectHeader header; /* must come first */
    // JSValue resolving_funcs[2];
    // BOOL is_active; /* true if the async function state is valid */
    // JSAsyncFunctionState func_state;
};
const JSAsyncFunctionState = struct {
    /// "this" generator argument
    this_val: JSValue,

    /// number of function arguments
    num_args: i32,

    /// used to throw an exception in JS_CallInternal()
    throw_flag: bool,
    frame: JSStackFrame,

    // JSValue this_val; /* 'this' generator argument */
    // int argc; /* number of function arguments */
    // BOOL throw_flag; /* used to throw an exception in JS_CallInternal() */
    // JSStackFrame frame;
};
const JSAsyncFromSyncIteratorData = struct{
    sync_iter: JSValue,
    next_method: JSValue
    // JSValue sync_iter;
    // JSValue next_method;
};
const JSAsyncGeneratorStateEnum = enum {
    JS_ASYNC_GENERATOR_STATE_SUSPENDED_START,
    JS_ASYNC_GENERATOR_STATE_SUSPENDED_YIELD,
    JS_ASYNC_GENERATOR_STATE_SUSPENDED_YIELD_STAR,
    JS_ASYNC_GENERATOR_STATE_EXECUTING,
    JS_ASYNC_GENERATOR_STATE_AWAITING_RETURN,
    JS_ASYNC_GENERATOR_STATE_COMPLETED,
};
const JSAsyncGeneratorData = struct{
    generator: *JSObject,
    state: JSAsyncGeneratorStateEnum,
    func_state: JSAsyncFunctionState,

    // JSObject *generator; /* back pointer to the object (const) */
    // JSAsyncGeneratorStateEnum state;
    // JSAsyncFunctionState func_state;
    // struct list_head queue; /* list of JSAsyncGeneratorRequest.link */
};
const JSPromiseReactionData = struct {
    resolving_funcs: [2]JSValue,
    handler: JSValue,
    // struct list_head link; /* not used in promise_reaction_job */
    // JSValue resolving_funcs[2];
    // JSValue handler;
};
const JSCRegexData = struct{};

// typedef struct JSPromiseReactionData {
//     struct list_head link; /* not used in promise_reaction_job */
//     JSValue resolving_funcs[2];
//     JSValue handler;
// } JSPromiseReactionData;

const JSObjectData = union(JSClassEnum) {
    JS_CLASS_BOUND_FUNCTION: *JSBoundFunction,
    JS_CLASS_C_FUNCTION_DATA: *JSCFunctionDataRecord,
    JS_CLASS_FOR_IN_ITERATOR: *JSCForInIterator,
    JS_CLASS_ARRAY_BUFFER: *JSCArrayBuffer(JSValue),
    JS_CLASS_SHARED_ARRAY_BUFFER: *JSCArrayBuffer(JSValue),
    JS_CLASS_UINT8C_ARRAY: *JSCTypedArray(u8),
    JS_CLASS_INT8_ARRAY: *JSCTypedArray(i8),
    JS_CLASS_UINT8_ARRAY: *JSCTypedArray(u8),
    JS_CLASS_INT16_ARRAY: *JSCTypedArray(i16),
    JS_CLASS_UINT16_ARRAY: *JSCTypedArray(u16),
    JS_CLASS_INT32_ARRAY: *JSCTypedArray(i32),
    JS_CLASS_UINT32_ARRAY: *JSCTypedArray(u32),
    JS_CLASS_FLOAT32_ARRAY: *JSCTypedArray(f32),
    JS_CLASS_FLOAT64_ARRAY: *JSCTypedArray(f64),
    JS_CLASS_DATAVIEW: *JSCTypedArray(JSValue),

    JS_CLASS_ARRAY: *JSCArray,

    // TODO: Support BigNum
    // JS_CLASS_FLOAT_ENV: *JSFloatEnv,
    //         struct JSOperatorSetData *operator_set; /* JS_CLASS_OPERATOR_SET */

    JS_CLASS_MAP: *JSMapState,
    JS_CLASS_SET: *JSMapState,
    JS_CLASS_WEAKMAP: *JSMapState,
    JS_CLASS_WEAKSET: *JSMapState,

    JS_CLASS_MAP_ITERATOR: *JSMapIteratorData,
    JS_CLASS_SET_ITERATOR: *JSMapIteratorData,

    JS_CLASS_ARRAY_ITERATOR: *JSArrayIteratorData,
    JS_CLASS_STRING_ITERATOR: *JSArrayIteratorData,
    JS_CLASS_REGEXP_STRING_ITERATOR: *JSRegExpStringIteratorData,
    JS_CLASS_GENERATOR: *JSGeneratorData,
    JS_CLASS_PROXY: *JSProxyData,
    JS_CLASS_PROMISE: *JSPromiseData,
    JS_CLASS_PROMISE_RESOLVE_FUNCTION: *JSPromiseFunctionData,
    JS_CLASS_PROMISE_REJECT_FUNCTION: *JSPromiseFunctionData,
    JS_CLASS_ASYNC_FUNCTION_RESOLVE: *JSAsyncFunctionData,
    JS_CLASS_ASYNC_FUNCTION_REJECT: *JSAsyncFunctionData,
    JS_CLASS_ASYNC_FROM_SYNC_ITERATOR: *JSAsyncFromSyncIteratorData,
    JS_CLASS_ASYNC_GENERATOR: *JSAsyncGeneratorData,

    JS_CLASS_BYTECODE_FUNCTION: *JSCBytecodeFunctionData,
    JS_CLASS_GENERATOR_FUNCTION: *JSCBytecodeFunctionData,
    JS_CLASS_ASYNC_FUNCTION: *JSCBytecodeFunctionData,
    JS_CLASS_ASYNC_GENERATOR_FUNCTION: JSCBytecodeFunctionData,

    JS_CLASS_C_FUNCTION: JS_C_FunctionData,
    JS_CLASS_REGEXP: JSCRegexData,

    JS_CLASS_OBJECT: JSValue,
    JS_CLASS_ERROR: JSValue,
    JS_CLASS_NUMBER: JSValue,
    JS_CLASS_STRING: JSValue,
    JS_CLASS_BOOLEAN: JSValue,
    JS_CLASS_SYMBOL: JSValue,
    JS_CLASS_ARGUMENTS: *JSCArray,
    JS_CLASS_MAPPED_ARGUMENTS: JSValue,
    JS_CLASS_DATE: JSValue,

    JS_CLASS_MODULE_NS: void,
    JS_CLASS_INIT_COUNT: void,

};

const JSCBytecodeFunctionData = struct {
    function_bytecode: *JSFunctionBytecode,
    var_refs: []* JSVarRef,
    home_object: *JSObject,
};

const JSCFunctionEnum = enum {
    JS_CFUNC_generic,
    JS_CFUNC_generic_magic,
    JS_CFUNC_constructor,
    JS_CFUNC_constructor_magic,
    JS_CFUNC_constructor_or_func,
    JS_CFUNC_constructor_or_func_magic,
    JS_CFUNC_f_f,
    JS_CFUNC_f_f_f,
    JS_CFUNC_getter,
    JS_CFUNC_setter,
    JS_CFUNC_getter_magic,
    JS_CFUNC_setter_magic,
    JS_CFUNC_iterator_next,
};



const JS_C_FunctionData = struct {
    realm: *JSContext,
    c_function: JSCFunctionType,
    length: u8,
    cproto: u8,
    magic: u16,
};

const JSCFunctionType = union(JSCFunctionEnum) {
    JS_CFUNC_generic: *JSCFunction,
    JS_CFUNC_generic_magic: *JSCFunctionMagic,
    JS_CFUNC_constructor: *JSCFunction,
    JS_CFUNC_constructor_magic: *fn(ctx: *JSContext, new_target: JSValue, args: []JSValue, magic: i32) JSValue,
    JS_CFUNC_constructor_or_func: *JSCFunction,
    JS_CFUNC_constructor_or_func_magic: *JSCFunctionMagic,
    JS_CFUNC_f_f: void,
    JS_CFUNC_f_f_f: void,
    JS_CFUNC_getter: *fn(ctx: *JSContext, this_val: JSValue) JSValue,
    JS_CFUNC_setter: *fn(ctx: *JSContext, this_val: JSValue, val: JSValue) JSValue,
    JS_CFUNC_getter_magic: *fn(ctx: *JSContext, this_val: JSValue, magic: i32) JSValue,
    JS_CFUNC_setter_magic: *fn(ctx: *JSContext, this_val: JSValue, val: JSValue, magic: i32) JSValue,
    JS_CFUNC_iterator_next: *fn(ctx: *JSContext, this_val: JSValue, args: []JSValue, pdone: *i32, magic: i32) JSValue,
};
// JSCFunction *generic;
//     JSValue (*generic_magic)(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv, int magic);
//     JSCFunction *constructor;
//     JSValue (*constructor_magic)(JSContext *ctx, JSValueConst new_target, int argc, JSValueConst *argv, int magic);
//     JSCFunction *constructor_or_func;
//     double (*f_f)(double);
//     double (*f_f_f)(double, double);
//     JSValue (*getter)(JSContext *ctx, JSValueConst this_val);
//     JSValue (*setter)(JSContext *ctx, JSValueConst this_val, JSValueConst val);
//     JSValue (*getter_magic)(JSContext *ctx, JSValueConst this_val, int magic);
//     JSValue (*setter_magic)(JSContext *ctx, JSValueConst this_val, JSValueConst val, int magic);
//     JSValue (*iterator_next)(JSContext *ctx, JSValueConst this_val,
//                              int argc, JSValueConst *argv, int *pdone, int magic);

// struct JSBoundFunction *bound_function; /* JS_CLASS_BOUND_FUNCTION */
//         struct JSCFunctionDataRecord *c_function_data_record; /* JS_CLASS_C_FUNCTION_DATA */
//         struct JSForInIterator *for_in_iterator; /* JS_CLASS_FOR_IN_ITERATOR */
//         struct JSArrayBuffer *array_buffer; /* JS_CLASS_ARRAY_BUFFER, JS_CLASS_SHARED_ARRAY_BUFFER */
//         struct JSTypedArray *typed_array; /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_DATAVIEW */
// #ifdef CONFIG_BIGNUM
//         struct JSFloatEnv *float_env; /* JS_CLASS_FLOAT_ENV */
//         struct JSOperatorSetData *operator_set; /* JS_CLASS_OPERATOR_SET */
// #endif
//         struct JSMapState *map_state;   /* JS_CLASS_MAP..JS_CLASS_WEAKSET */
//         struct JSMapIteratorData *map_iterator_data; /* JS_CLASS_MAP_ITERATOR, JS_CLASS_SET_ITERATOR */
//         struct JSArrayIteratorData *array_iterator_data; /* JS_CLASS_ARRAY_ITERATOR, JS_CLASS_STRING_ITERATOR */
//         struct JSRegExpStringIteratorData *regexp_string_iterator_data; /* JS_CLASS_REGEXP_STRING_ITERATOR */
//         struct JSGeneratorData *generator_data; /* JS_CLASS_GENERATOR */
//         struct JSProxyData *proxy_data; /* JS_CLASS_PROXY */
//         struct JSPromiseData *promise_data; /* JS_CLASS_PROMISE */
//         struct JSPromiseFunctionData *promise_function_data; /* JS_CLASS_PROMISE_RESOLVE_FUNCTION, JS_CLASS_PROMISE_REJECT_FUNCTION */
//         struct JSAsyncFunctionData *async_function_data; /* JS_CLASS_ASYNC_FUNCTION_RESOLVE, JS_CLASS_ASYNC_FUNCTION_REJECT */
//         struct JSAsyncFromSyncIteratorData *async_from_sync_iterator_data; /* JS_CLASS_ASYNC_FROM_SYNC_ITERATOR */
//         struct JSAsyncGeneratorData *async_generator_data; /* JS_CLASS_ASYNC_GENERATOR */
//         struct { /* JS_CLASS_BYTECODE_FUNCTION: 12/24 bytes */
//             /* also used by JS_CLASS_GENERATOR_FUNCTION, JS_CLASS_ASYNC_FUNCTION and JS_CLASS_ASYNC_GENERATOR_FUNCTION */
//             struct JSFunctionBytecode *function_bytecode;
//             JSVarRef **var_refs;
//             JSObject *home_object; /* for 'super' access */
//         } func;
//         struct { /* JS_CLASS_C_FUNCTION: 12/20 bytes */
//             JSContext *realm;
//             JSCFunctionType c_function;
//             uint8_t length;
//             uint8_t cproto;
//             int16_t magic;
//         } cfunc;
//         /* array part for fast arrays and typed arrays */
//         struct { /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS, JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
//             union {
//                 uint32_t size;          /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS */
//                 struct JSTypedArray *typed_array; /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
//             } u1;
//             union {
//                 JSValue *values;        /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS */ 
//                 void *ptr;              /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
//                 int8_t *int8_ptr;       /* JS_CLASS_INT8_ARRAY */
//                 uint8_t *uint8_ptr;     /* JS_CLASS_UINT8_ARRAY, JS_CLASS_UINT8C_ARRAY */
//                 int16_t *int16_ptr;     /* JS_CLASS_INT16_ARRAY */
//                 uint16_t *uint16_ptr;   /* JS_CLASS_UINT16_ARRAY */
//                 int32_t *int32_ptr;     /* JS_CLASS_INT32_ARRAY */
//                 uint32_t *uint32_ptr;   /* JS_CLASS_UINT32_ARRAY */
//                 int64_t *int64_ptr;     /* JS_CLASS_INT64_ARRAY */
//                 uint64_t *uint64_ptr;   /* JS_CLASS_UINT64_ARRAY */
//                 float *float_ptr;       /* JS_CLASS_FLOAT32_ARRAY */
//                 double *double_ptr;     /* JS_CLASS_FLOAT64_ARRAY */
//             } u;
//             uint32_t count; /* <= 2^31-1. 0 for a detached typed array */
//         } array;    /* 12/20 bytes */
//         JSRegExp regexp;    /* JS_CLASS_REGEXP: 8/16 bytes */
//         JSValue object_data;    /* for JS_SetObjectData(): 8/16/16 bytes */

const JSObject = struct {
    header: JSGCObjectHeader,
    extensible: bool,

    /// only used when freeing objects with cycles
    free_mark: bool,
    /// true if object has exotic property handlers
    is_exotic: bool,
    /// true if u.array is used for get/put
    fast_array: bool,
    /// true if object is a constructor function
    is_constructor: bool,
    /// true if error is not catchable
    is_uncatchable_error: bool,
    /// used in JS_WriteObjectRec()
    tmp_mark: bool,

    shape: *JSShape,
    properties: []JSProperty,

    // TODO:
    // first_weak_ref: *JSMapRecord,

    data: JSObjectData
};

// struct JSObject {
//     union {
//         JSGCObjectHeader header;
//         struct {
//             int __gc_ref_count; /* corresponds to header.ref_count */
//             uint8_t __gc_mark; /* corresponds to header.mark/gc_obj_type */
            
//             uint8_t extensible : 1;
//             uint8_t free_mark : 1; /* only used when freeing objects with cycles */
//             uint8_t is_exotic : 1; /* TRUE if object has exotic property handlers */
//             uint8_t fast_array : 1; /* TRUE if u.array is used for get/put */
//             uint8_t is_constructor : 1; /* TRUE if object is a constructor function */
//             uint8_t is_uncatchable_error : 1; /* if TRUE, error is not catchable */
//             uint8_t tmp_mark : 1; /* used in JS_WriteObjectRec() */
//             uint16_t class_id; /* see JS_CLASS_x */
//         };
//     };
//     /* byte offsets: 16/24 */
//     JSShape *shape; /* prototype and property names + flag */
//     JSProperty *prop; /* array of properties */
//     /* byte offsets: 24/40 */
//     struct JSMapRecord *first_weak_ref; /* XXX: use a bit and an external hash table? */
//     /* byte offsets: 28/48 */
//     union {
//         void *opaque;
//         struct JSBoundFunction *bound_function; /* JS_CLASS_BOUND_FUNCTION */
//         struct JSCFunctionDataRecord *c_function_data_record; /* JS_CLASS_C_FUNCTION_DATA */
//         struct JSForInIterator *for_in_iterator; /* JS_CLASS_FOR_IN_ITERATOR */
//         struct JSArrayBuffer *array_buffer; /* JS_CLASS_ARRAY_BUFFER, JS_CLASS_SHARED_ARRAY_BUFFER */
//         struct JSTypedArray *typed_array; /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_DATAVIEW */
// #ifdef CONFIG_BIGNUM
//         struct JSFloatEnv *float_env; /* JS_CLASS_FLOAT_ENV */
//         struct JSOperatorSetData *operator_set; /* JS_CLASS_OPERATOR_SET */
// #endif
//         struct JSMapState *map_state;   /* JS_CLASS_MAP..JS_CLASS_WEAKSET */
//         struct JSMapIteratorData *map_iterator_data; /* JS_CLASS_MAP_ITERATOR, JS_CLASS_SET_ITERATOR */
//         struct JSArrayIteratorData *array_iterator_data; /* JS_CLASS_ARRAY_ITERATOR, JS_CLASS_STRING_ITERATOR */
//         struct JSRegExpStringIteratorData *regexp_string_iterator_data; /* JS_CLASS_REGEXP_STRING_ITERATOR */
//         struct JSGeneratorData *generator_data; /* JS_CLASS_GENERATOR */
//         struct JSProxyData *proxy_data; /* JS_CLASS_PROXY */
//         struct JSPromiseData *promise_data; /* JS_CLASS_PROMISE */
//         struct JSPromiseFunctionData *promise_function_data; /* JS_CLASS_PROMISE_RESOLVE_FUNCTION, JS_CLASS_PROMISE_REJECT_FUNCTION */
//         struct JSAsyncFunctionData *async_function_data; /* JS_CLASS_ASYNC_FUNCTION_RESOLVE, JS_CLASS_ASYNC_FUNCTION_REJECT */
//         struct JSAsyncFromSyncIteratorData *async_from_sync_iterator_data; /* JS_CLASS_ASYNC_FROM_SYNC_ITERATOR */
//         struct JSAsyncGeneratorData *async_generator_data; /* JS_CLASS_ASYNC_GENERATOR */
//         struct { /* JS_CLASS_BYTECODE_FUNCTION: 12/24 bytes */
//             /* also used by JS_CLASS_GENERATOR_FUNCTION, JS_CLASS_ASYNC_FUNCTION and JS_CLASS_ASYNC_GENERATOR_FUNCTION */
//             struct JSFunctionBytecode *function_bytecode;
//             JSVarRef **var_refs;
//             JSObject *home_object; /* for 'super' access */
//         } func;
//         struct { /* JS_CLASS_C_FUNCTION: 12/20 bytes */
//             JSContext *realm;
//             JSCFunctionType c_function;
//             uint8_t length;
//             uint8_t cproto;
//             int16_t magic;
//         } cfunc;
//         /* array part for fast arrays and typed arrays */
//         struct { /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS, JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
//             union {
//                 uint32_t size;          /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS */
//                 struct JSTypedArray *typed_array; /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
//             } u1;
//             union {
//                 JSValue *values;        /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS */ 
//                 void *ptr;              /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
//                 int8_t *int8_ptr;       /* JS_CLASS_INT8_ARRAY */
//                 uint8_t *uint8_ptr;     /* JS_CLASS_UINT8_ARRAY, JS_CLASS_UINT8C_ARRAY */
//                 int16_t *int16_ptr;     /* JS_CLASS_INT16_ARRAY */
//                 uint16_t *uint16_ptr;   /* JS_CLASS_UINT16_ARRAY */
//                 int32_t *int32_ptr;     /* JS_CLASS_INT32_ARRAY */
//                 uint32_t *uint32_ptr;   /* JS_CLASS_UINT32_ARRAY */
//                 int64_t *int64_ptr;     /* JS_CLASS_INT64_ARRAY */
//                 uint64_t *uint64_ptr;   /* JS_CLASS_UINT64_ARRAY */
//                 float *float_ptr;       /* JS_CLASS_FLOAT32_ARRAY */
//                 double *double_ptr;     /* JS_CLASS_FLOAT64_ARRAY */
//             } u;
//             uint32_t count; /* <= 2^31-1. 0 for a detached typed array */
//         } array;    /* 12/20 bytes */
//         JSRegExp regexp;    /* JS_CLASS_REGEXP: 8/16 bytes */
//         JSValue object_data;    /* for JS_SetObjectData(): 8/16/16 bytes */
//     } u;
//     /* byte sizes: 40/48/72 */
// };

const JSMapRecord = struct {
    ref_count: u32,
    empty: bool,
    map: *JSMapState,
    next_weak_ref: *JSMapRecord,
    key: JSValue,
    value: JSvalue,
};

// typedef struct JSMapRecord {
//     int ref_count; /* used during enumeration to avoid freeing the record */
//     BOOL empty; /* TRUE if the record is deleted */
//     struct JSMapState *map;
//     struct JSMapRecord *next_weak_ref;
//     struct list_head link;
//     struct list_head hash_link;
//     JSValue key;
//     JSValue value;
// } JSMapRecord;

const JSMapState = struct {
    is_weak: bool,
    // TODO:
};

// typedef struct JSMapState {
//     BOOL is_weak; /* TRUE if WeakSet/WeakMap */
//     struct list_head records; /* list of JSMapRecord.link */
//     uint32_t record_count;
//     struct list_head *hash_table;
//     uint32_t hash_size; /* must be a power of two */
//     uint32_t record_count_threshold; /* count at which a hash table
//                                         resize is needed */
// } JSMapState;


const AtomType = enum {
    JS_ATOM_TYPE_STRING = 1,
    JS_ATOM_TYPE_GLOBAL_SYMBOL,
    JS_ATOM_TYPE_SYMBOL,
    JS_ATOM_TYPE_PRIVATE,
};

const JSStringType = enum {
    /// 8 bit code points
    _8_BIT,

    /// 16 bit code points
    _16_BIT
};

const JSStringValue = union(JSStringType) {
    _8_BIT: []u8,
    _16_BIT: []u16,
};

const JSString = struct {
    header: JSRefCountHeader,
    hash: u30,
    hash_next: u30,
    val: JSStringValue
};

// struct JSString {
//     JSRefCountHeader header; /* must come first, 32-bit */
//     uint32_t len : 31;
//     uint8_t is_wide_char : 1; /* 0 = 8 bits, 1 = 16 bits characters */
//     /* for JS_ATOM_TYPE_SYMBOL: hash = 0, atom_type = 3,
//        for JS_ATOM_TYPE_PRIVATE: hash = 1, atom_type = 3
//        XXX: could change encoding to have one more bit in hash */
//     uint32_t hash : 30;
//     uint8_t atom_type : 2; /* != 0 if atom, JS_ATOM_TYPE_x */
//     uint32_t hash_next; /* atom_index for JS_ATOM_TYPE_SYMBOL */
// #ifdef DUMP_LEAKS
//     struct list_head link; /* string list */
// #endif
//     union {
//         uint8_t str8[0]; /* 8 bit strings will get an extra null terminator */
//         uint16_t str16[0];
//     } u;
// };

const JSFunctionBytecode = struct {};

// fn JS_VALUE_GET_TAG(v: JSValue) i32 { 
//     return @intCast(i32, v.tag);
// }

// /// same as JS_VALUE_GET_TAG, but return JS_TAG_FLOAT64 with NaN boxing
// fn JS_VALUE_GET_NORM_TAG(v: JSValue) i32 {
//     return JS_VALUE_GET_TAG(v);
// }

// fn JS_VALUE_GET_INT(v: JSValue) i32 {
//     return  v.u.int32;
// }

// fn JS_VALUE_GET_BOOL(v: JSValue) bool {
//     return v.u.int32 == 1;
// }

// fn JS_VALUE_GET_FLOAT64(v: JSValue) f64 {
//     return v.u.float64;
// }

// fn JS_VALUE_GET_PTR(v: JSValue) *JSPointerValue {
//     return v.u.ptr;
// }

// fn JS_MakeIntVal(tag: JSTag, val: i32) JSValue {
//     return JSValue{
//         .JS_TAG_INT = val
//     };
// }

// fn JS_MakeFloatVal(tag: JSTag, val: f64) JSValue {
//     return JSValue{
//         .tag = tag,
//         .u = JSValueUnion{
//             .float64 = val
//         }
//     };
// }

// test "JS_MakeIntVal" {
//     {
//         // make int value
//         const result = JS_MakeIntVal(.JS_TAG_INT, 32);
//         testing.expect(result.tag == .JS_TAG_INT);
//         testing.expect(result.u.int32 == 32);
//     }
// }

// fn JS_MKPTR(tag: JSTag, p: *JSPointerValue) JSValue {
//     return JSValue{
//         .tag = tag,
//         .u = JSValueUnion{
//             .ptr = p
//         }
//     };
// }

fn JS_NewInt(val: i32) JSValue {
    return JSValue{
        .JS_TAG_INT = val
    };
}

test "JS_NewInt()" {
    const result = JS_NewInt(42);
    testing.expect(@as(JSTag, result) == .JS_TAG_INT);

    switch(result) {
        .JS_TAG_INT => |val| testing.expect(val == 42),
        else => unreachable
    }
}

fn JS_NewFloat(val: f64) JSValue {
    return JSValue{
        .JS_TAG_FLOAT64 = val
    };
}

test "JS_NewFloat()" {
    const result = JS_NewFloat(42.32);
    testing.expect(@as(JSTag, result) == .JS_TAG_FLOAT64);

    switch(result) {
        .JS_TAG_FLOAT64 => |val| testing.expect(val == 42.32),
        else => unreachable
    }
}

const JS_NULL = JSValue{
    .JS_TAG_NULL = {}
};

fn JS_NAN() JSValue { 
    return JSValue{
        .JS_TAG_FLOAT64 = float64_nan
    };
}

test "JS_NAN()" {
    const result = JS_NAN();
    testing.expect(@as(JSTag, result) == .JS_TAG_FLOAT64);

    switch(result) {
        .JS_TAG_FLOAT64 => |val| testing.expect(std.math.isNan(val)),
        else => unreachable
    }
}


fn JS_VALUE_IS_BOTH_INT(v1: JSValue, v2: JSValue) bool {
    return @as(JSTag, v1) == .JS_TAG_INT and @as(JSTag, v2) == .JS_TAG_INT;
}

test "JS_VALUE_IS_BOTH_INT()" {
    testing.expect(JS_VALUE_IS_BOTH_INT(JS_NewInt(33), JS_NewInt(11)) == true);
    testing.expect(JS_VALUE_IS_BOTH_INT(JS_NewInt(33), JS_NewFloat(3.2)) == false);
    testing.expect(JS_VALUE_IS_BOTH_INT(JS_NewFloat(3.2), JS_NewInt(33)) == false);
    testing.expect(JS_VALUE_IS_BOTH_INT(JS_NewFloat(3.2), JS_NewFloat(3.14)) == false);
}

fn JS_VALUE_IS_BOTH_FLOAT(v1: JSValue, v2: JSValue) bool {
    return @as(JSTag, v1) == .JS_TAG_FLOAT64 and @as(JSTag, v2) == .JS_TAG_FLOAT64;
}

test "JS_VALUE_IS_BOTH_FLOAT()" {
    testing.expect(JS_VALUE_IS_BOTH_FLOAT(JS_NewFloat(3.2), JS_NewFloat(3.14)) == true);
    testing.expect(JS_VALUE_IS_BOTH_FLOAT(JS_NewFloat(3.2), JS_NewInt(33)) == false);
    testing.expect(JS_VALUE_IS_BOTH_FLOAT(JS_NewInt(33), JS_NewFloat(3.2)) == false);
    testing.expect(JS_VALUE_IS_BOTH_FLOAT(JS_NewInt(33), JS_NewInt(11)) == false);
}

// fn Allocator(allocator: *std.mem.Allocator) type {
//     return struct {
//         malloc_count: usize,
//         malloc_size: usize,
//         malloc_limit: usize,

//         const Self = @This();

//         pub fn js_alloc(self: *Self, comptime T: type, n: anytype) ![]T {
//             const result = try allocator.alloc(T, n);
//             return std.mem.zeroInit([]T, result);
//         }

//         pub fn js_create(self: *Self, comptime T: type) !*T {
//             const result = try allocator.create(T);

//             return result;
//         }

//         pub fn js_free(self: *Self, comptime T: type, val: anytype) void {
//             try allocator.free(val);
//         }

//         pub fn js_realloc(self: *Self, comptime T: type, val: []T, new_n: anytype) ![]T {
//             const result = try allocator.realloc(val, new_n);
//             return result;
//         }
//     };
// }


// typedef struct JSMallocState {
//     size_t malloc_count;
//     size_t malloc_size;
//     size_t malloc_limit;
//     void *opaque; /* user opaque */
// } JSMallocState;

// typedef struct JSMallocFunctions {
//     void *(*js_malloc)(JSMallocState *s, size_t size);
//     void (*js_free)(JSMallocState *s, void *ptr);
//     void *(*js_realloc)(JSMallocState *s, void *ptr, size_t size);
//     size_t (*js_malloc_usable_size)(const void *ptr);
// } JSMallocFunctions;

// #define JS_VALUE_GET_OBJ(v) ((JSObject *)JS_VALUE_GET_PTR(v))
// #define JS_VALUE_GET_STRING(v) ((JSString *)JS_VALUE_GET_PTR(v))
// #define JS_VALUE_HAS_REF_COUNT(v) ((unsigned)JS_VALUE_GET_TAG(v) >= (unsigned)JS_TAG_FIRST)

// /* special values */
// #define JS_NULL      JS_MKVAL(JS_TAG_NULL, 0)
// #define JS_UNDEFINED JS_MKVAL(JS_TAG_UNDEFINED, 0)
// #define JS_FALSE     JS_MKVAL(JS_TAG_BOOL, 0)
// #define JS_TRUE      JS_MKVAL(JS_TAG_BOOL, 1)
// #define JS_EXCEPTION JS_MKVAL(JS_TAG_EXCEPTION, 0)
// #define JS_UNINITIALIZED JS_MKVAL(JS_TAG_UNINITIALIZED, 0)

const JSAllocator = std.heap.GeneralPurposeAllocator(.{
    .enable_memory_limit = true,
});

const JSMode = enum(u8) {
    NONE = 0,
    JS_MODE_STRICT = (1 << 0),
    JS_MODE_STRIP  = (1 << 1),
    JS_MODE_MATH   = (1 << 2),
};

const JSStackFrame = struct {
    prev_frame: ?*JSStackFrame,
    curr_func: JSValue,
    arg_buf: []JSValue,
    var_buf: []JSValue,
    current_program_counter: u8,
    js_mode: JSMode,
    cur_sp: *JSValue,
};

// typedef struct JSStackFrame {
//     struct JSStackFrame *prev_frame; /* NULL if first stack frame */
//     JSValue cur_func; /* current function, JS_UNDEFINED if the frame is detached */
//     JSValue *arg_buf; /* arguments */
//     JSValue *var_buf; /* variables */
//     struct list_head var_ref_list; /* list of JSVarRef.link */
//     const uint8_t *cur_pc; /* only used in bytecode functions : PC of the
//                         instruction after the call */
//     int arg_count;
//     int js_mode; /* 0 or JS_MODE_MATH for C functions */
//     /* only used in generators. Current stack pointer value. NULL if
//        the function is running. */ 
//     JSValue *cur_sp;
// } JSStackFrame;

const JSClassCall = opaque{};

const JSClass = struct {
    //  /* 0 means free entry */
    class_id: u32,
    class_name: JSAtom,
    finalizer: *JSClassFinalizer,
    gc_mark: *JSClassGCMark,
    call: *JSClassCall,
    exotic: ?*const JSClassExoticMethods

    // JSClassFinalizer *finalizer;
    // JSClassGCMark *gc_mark;
    // JSClassCall *call;
    // /* pointers for exotic behavior, can be NULL if none are present */
    // const JSClassExoticMethods *exotic;
};

const JSPropertyDescriptor = opaque{};

const JSClassExoticMethods = struct {
    get_own_property: fn(context: *JSContext, desc: *JSPropertyDescriptor, obj: JSValue, prop: JSAtom) i32,
    // TODO:
    // get_own_property_names: fn(context: *JSContext, obj: JSValue) []JSProperty,
    delete_property: fn(context: *JSContext, obj: JSValue, prop: JSAtom) i32,
    define_own_property: fn(context: *JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, getter: JSValue, setter: JSValue, flags: u32) i32,
    has_property: fn(context: *JSContext, obj: JSValue, prop: JSAtom) i32,
    get_property: fn(context: *JSContext, obj: JSValue, prop: JSAtom, receiver: JSValue) JSValue,
    set_property: fn(context: *JSContext, obj: JSValue, prop: JSAtom, value: JSValue, receiver: JSValue, flags: i32) i32,
};

const JSGCObjectType = enum(u4) {
    JS_GC_OBJ_TYPE_JS_OBJECT,
    JS_GC_OBJ_TYPE_FUNCTION_BYTECODE,
    JS_GC_OBJ_TYPE_SHAPE,
    JS_GC_OBJ_TYPE_VAR_REF,
    JS_GC_OBJ_TYPE_ASYNC_FUNCTION,
    JS_GC_OBJ_TYPE_JS_CONTEXT,
};
// typedef enum {
//     JS_GC_OBJ_TYPE_JS_OBJECT,
//     JS_GC_OBJ_TYPE_FUNCTION_BYTECODE,
//     JS_GC_OBJ_TYPE_SHAPE,
//     JS_GC_OBJ_TYPE_VAR_REF,
//     JS_GC_OBJ_TYPE_ASYNC_FUNCTION,
//     JS_GC_OBJ_TYPE_JS_CONTEXT,
// } JSGCObjectTypeEnum;

/// header for GC objects. GC objects are C data structures with a
/// reference count that can reference other GC objects. JS Objects are
/// a particular type of GC object.
const JSGCObjectHeader = struct {
    /// must come first, 32-bit
    ref_count: u32,
    gc_obj_type: JSGCObjectType,
    mark: u8,
    
    // JSGCObjectTypeEnum gc_obj_type : 4;
    // uint8_t mark : 4; /* used by the GC */
    // uint8_t dummy1; /* not used by the GC */
    // uint16_t dummy2; /* not used by the GC */
    // struct list_head link;
};

const JSClassFinalizer = fn(runtime: *JSRuntime, val: JSValue) void;
const JS_MarkFunc = fn(runtime: *JSRuntime, gp: *JSGCObjectHeader) void;
const JSClassGCMark = fn(runtime: *JSRuntime, val: JSValue, mark_func: *JS_MarkFunc) void;

// typedef struct JSClassExoticMethods {
//     /* Return -1 if exception (can only happen in case of Proxy object),
//        FALSE if the property does not exists, TRUE if it exists. If 1 is
//        returned, the property descriptor 'desc' is filled if != NULL. */
//     int (*get_own_property)(JSContext *ctx, JSPropertyDescriptor *desc,
//                              JSValueConst obj, JSAtom prop);
//     /* '*ptab' should hold the '*plen' property keys. Return 0 if OK,
//        -1 if exception. The 'is_enumerable' field is ignored.
//     */
//     int (*get_own_property_names)(JSContext *ctx, JSPropertyEnum **ptab,
//                                   uint32_t *plen,
//                                   JSValueConst obj);
//     /* return < 0 if exception, or TRUE/FALSE */
//     int (*delete_property)(JSContext *ctx, JSValueConst obj, JSAtom prop);
//     /* return < 0 if exception or TRUE/FALSE */
//     int (*define_own_property)(JSContext *ctx, JSValueConst this_obj,
//                                JSAtom prop, JSValueConst val,
//                                JSValueConst getter, JSValueConst setter,
//                                int flags);
//     /* The following methods can be emulated with the previous ones,
//        so they are usually not needed */
//     /* return < 0 if exception or TRUE/FALSE */
//     int (*has_property)(JSContext *ctx, JSValueConst obj, JSAtom atom);
//     JSValue (*get_property)(JSContext *ctx, JSValueConst obj, JSAtom atom,
//                             JSValueConst receiver);
//     /* return < 0 if exception or TRUE/FALSE */
//     int (*set_property)(JSContext *ctx, JSValueConst obj, JSAtom atom,
//                         JSValueConst value, JSValueConst receiver, int flags);
// } JSClassExoticMethods;

// typedef void JSClassFinalizer(JSRuntime *rt, JSValue val);
// typedef void JSClassGCMark(JSRuntime *rt, JSValueConst val,
//                            JS_MarkFunc *mark_func);

const JSShape = struct {
    header: JSGCObjectHeader,
    // true if the shape is inserted in the shape hash table. If not,
    // JSShape.hash is not valid
    is_hashed: bool,

    /// If true, the shape may have small array index properties 'n' with 0
    /// <= n <= 2^31-1. If false, the shape is guaranteed not to have
    /// small array index properties
    has_small_array_index: bool,

    /// current hash value
    hash: u32,
    prop_hash_mask: u32,
    /// allocated properties
    prop_size: u32,
    /// includes deleted properties
    prop_count: u32,
    deleted_prop_count: u32,

    proto: *JSObject,



    // uint32_t prop_hash_end[0]; /* hash table of size hash_mask + 1
    //                               before the start of the structure. */
    // JSGCObjectHeader header;
    // /* true if the shape is inserted in the shape hash table. If not,
    //    JSShape.hash is not valid */
    // uint8_t is_hashed;
    // /* If true, the shape may have small array index properties 'n' with 0
    //    <= n <= 2^31-1. If false, the shape is guaranteed not to have
    //    small array index properties */
    // uint8_t has_small_array_index;
    // uint32_t hash; /* current hash value */
    // uint32_t prop_hash_mask;
    // int prop_size; /* allocated properties */
    // int prop_count; /* include deleted properties */
    // int deleted_prop_count;
    // JSShape *shape_hash_next; /* in JSRuntime.shape_hash[h] list */
    // JSObject *proto;
    // JSShapeProperty prop[0]; /* prop_size elements */
};

const JSContext = struct {
    header: JSGCObjectHeader,
    runtime: *JSRuntime,
    binary_object_count: u16,
    binary_object_size: u32,

    array_shape: JSShape,
};

// struct JSContext {
//     JSGCObjectHeader header; /* must come first */
//     JSRuntime *rt;
//     struct list_head link;

//     uint16_t binary_object_count;
//     int binary_object_size;

//     JSShape *array_shape;   /* initial shape for Array objects */

//     JSValue *class_proto;
//     JSValue function_proto;
//     JSValue function_ctor;
//     JSValue array_ctor;
//     JSValue regexp_ctor;
//     JSValue promise_ctor;
//     JSValue native_error_proto[JS_NATIVE_ERROR_COUNT];
//     JSValue iterator_proto;
//     JSValue async_iterator_proto;
//     JSValue array_proto_values;
//     JSValue throw_type_error;
//     JSValue eval_obj;

//     JSValue global_obj; /* global object */
//     JSValue global_var_obj; /* contains the global let/const definitions */

//     uint64_t random_state;
// #ifdef CONFIG_BIGNUM
//     bf_context_t *bf_ctx;   /* points to rt->bf_ctx, shared by all contexts */
//     JSFloatEnv fp_env; /* global FP environment */
//     BOOL bignum_ext : 8; /* enable math mode */
//     BOOL allow_operator_overloading : 8;
// #endif
//     /* when the counter reaches zero, JSRutime.interrupt_handler is called */
//     int interrupt_counter;
//     BOOL is_error_property_enabled;

//     struct list_head loaded_modules; /* list of JSModuleDef.link */

//     /* if NULL, RegExp compilation is not supported */
//     JSValue (*compile_regexp)(JSContext *ctx, JSValueConst pattern,
//                               JSValueConst flags);
//     /* if NULL, eval is not supported */
//     JSValue (*eval_internal)(JSContext *ctx, JSValueConst this_obj,
//                              const char *input, size_t input_len,
//                              const char *filename, int flags, int scope_idx);
//     void *user_opaque;
// };

const JSRuntime = struct {
    allocator: *JSAllocator,
    classes: std.ArrayList(JSClass),
    current_exception: JSValue,
    
    current_stack_frame: ?*JSStackFrame,

    gc_phase: JSGCPhase,
    context_list: std.TailQueue(*JSContext),
    // struct list_head context_list; /* list of JSContext.link */
//     // /* list of JSGCObjectHeader.link. List of allocated GC objects (used
//     //    by the garbage collector) */
//     struct list_head gc_obj_list;
//     // /* list of JSGCObjectHeader.link. Used during JS_FreeValueRT() */
//     struct list_head gc_zero_ref_count_list; 
//     struct list_head tmp_obj_list; /* used during GC */
//     JSGCPhaseEnum gc_phase : 8;
//     size_t malloc_gc_threshold;

    const Self = @This();

    pub fn init(allocator: *JSAllocator) Self {
        return Self{
            .allocator = allocator,
            .classes = std.ArrayList(JSClass).init(&allocator.allocator),
            .current_exception = JS_NULL,
            .current_stack_frame = null,
            .gc_phase = .JS_GC_PHASE_NONE,
            .context_list = std.TailQueue(*JSContext){}
        };
    }

    pub fn deinit(self: *Self) void {

    }
};

test "JSRuntime - init" {
    {
        var gpa = JSAllocator{};
        defer std.testing.expect(!gpa.deinit());

        var runtime = JSRuntime.init(&gpa);
        defer runtime.deinit();
    }
}

// const JSRuntime = struct {
//     JSMallocFunctions mf,
//     JSMallocState malloc_state,
//     int atom_hash_size, //* power of two */
//     int atom_count,
//     int atom_size,
//     int atom_count_resize, //* resize hash table at this count */
//     const char *rt_info,

    
//     uint32_t *atom_hash;
//     JSAtomStruct **atom_array;
//     int atom_free_index; //* 0 = none */

//     int class_count;    //* size of class_array */
//     JSClass *class_array;

//     struct list_head context_list; /* list of JSContext.link */
//     // /* list of JSGCObjectHeader.link. List of allocated GC objects (used
//     //    by the garbage collector) */
//     struct list_head gc_obj_list;
//     // /* list of JSGCObjectHeader.link. Used during JS_FreeValueRT() */
//     struct list_head gc_zero_ref_count_list; 
//     struct list_head tmp_obj_list; /* used during GC */
//     JSGCPhaseEnum gc_phase : 8;
//     size_t malloc_gc_threshold;
// #ifdef DUMP_LEAKS
//     struct list_head string_list; /* list of JSString.link */
// #endif
//     /* stack limitation */
//     const uint8_t *stack_top;
//     size_t stack_size; /* in bytes */

//     JSValue current_exception;
//     /* true if inside an out of memory error, to avoid recursing */
//     BOOL in_out_of_memory : 8;

//     struct JSStackFrame *current_stack_frame;

//     JSInterruptHandler *interrupt_handler;
//     void *interrupt_opaque;

//     JSHostPromiseRejectionTracker *host_promise_rejection_tracker;
//     void *host_promise_rejection_tracker_opaque;
    
//     struct list_head job_list; /* list of JSJobEntry.link */

//     JSModuleNormalizeFunc *module_normalize_func;
//     JSModuleLoaderFunc *module_loader_func;
//     void *module_loader_opaque;

//     BOOL can_block : 8; /* TRUE if Atomics.wait can block */
//     /* used to allocate, free and clone SharedArrayBuffers */
//     JSSharedArrayBufferFunctions sab_funcs;
    
//     /* Shape hash table */
//     int shape_hash_bits;
//     int shape_hash_size;
//     int shape_hash_count; /* number of hashed shapes */
//     JSShape **shape_hash;
// #ifdef CONFIG_BIGNUM
//     bf_context_t bf_ctx;
//     JSNumericOperations bigint_ops;
//     JSNumericOperations bigfloat_ops;
//     JSNumericOperations bigdecimal_ops;
//     uint32_t operator_count;
// #endif
//     void *user_opaque;

//     JSDebuggerInfo debugger_info;
// };