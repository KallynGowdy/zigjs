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
};

const JS_NATIVE_ERROR_COUNT: u8 = 8;

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
    JS_TAG_OBJECT: *JSObject,
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

const JSAtom = enum {
    JS_ATOM_NULL,

    // /* Note: first atoms are considered as keywords in the parser */
    JS_ATOM_null,
    JS_ATOM_false,
    JS_ATOM_true,
    JS_ATOM_if,
    JS_ATOM_else,
    JS_ATOM_return,
    JS_ATOM_var,
    JS_ATOM_this,
    JS_ATOM_delete,
    JS_ATOM_void,
    JS_ATOM_typeof,
    JS_ATOM_new,
    JS_ATOM_in,
    JS_ATOM_instanceof,
    JS_ATOM_do,
    JS_ATOM_while,
    JS_ATOM_for,
    JS_ATOM_break,
    JS_ATOM_continue,
    JS_ATOM_switch,
    JS_ATOM_case,
    JS_ATOM_default,
    JS_ATOM_throw,
    JS_ATOM_try,
    JS_ATOM_catch,
    JS_ATOM_finally,
    JS_ATOM_function,
    JS_ATOM_debugger,
    JS_ATOM_with,
    // /* FutureReservedWord */
    JS_ATOM_class,
    JS_ATOM_const,
    JS_ATOM_enum,
    JS_ATOM_export,
    JS_ATOM_extends,
    JS_ATOM_import,
    JS_ATOM_super,
    // /* FutureReservedWords when parsing strict mode code */
    JS_ATOM_implements,
    JS_ATOM_interface,
    JS_ATOM_let,
    JS_ATOM_package,
    JS_ATOM_private,
    JS_ATOM_protected,
    JS_ATOM_public,
    JS_ATOM_static,
    JS_ATOM_yield,
    JS_ATOM_await,

    // /* empty string */
    JS_ATOM_empty_string,
    // /* identifiers */
    JS_ATOM_length,
    JS_ATOM_fileName,
    JS_ATOM_lineNumber,
    JS_ATOM_message,
    JS_ATOM_errors,
    JS_ATOM_stack,
    JS_ATOM_name,
    JS_ATOM_toString,
    JS_ATOM_toLocaleString,
    JS_ATOM_valueOf,
    JS_ATOM_eval,
    JS_ATOM_prototype,
    JS_ATOM_constructor,
    JS_ATOM_configurable,
    JS_ATOM_writable,
    JS_ATOM_enumerable,
    JS_ATOM_value,
    JS_ATOM_get,
    JS_ATOM_set,
    JS_ATOM_of,
    JS_ATOM___proto__,
    JS_ATOM_undefined,
    JS_ATOM_number,
    JS_ATOM_boolean,
    JS_ATOM_string,
    JS_ATOM_object,
    JS_ATOM_symbol,
    JS_ATOM_integer,
    JS_ATOM_unknown,
    JS_ATOM_arguments,
    JS_ATOM_callee,
    JS_ATOM_caller,
    JS_ATOM__eval_,
    JS_ATOM__ret_,
    JS_ATOM__var_,
    JS_ATOM__with_,
    JS_ATOM_lastIndex,
    JS_ATOM_target,
    JS_ATOM_index,
    JS_ATOM_input,
    JS_ATOM_defineProperties,
    JS_ATOM_apply,
    JS_ATOM_join,
    JS_ATOM_concat,
    JS_ATOM_split,
    JS_ATOM_construct,
    JS_ATOM_getPrototypeOf,
    JS_ATOM_setPrototypeOf,
    JS_ATOM_isExtensible,
    JS_ATOM_preventExtensions,
    JS_ATOM_has,
    JS_ATOM_deleteProperty,
    JS_ATOM_defineProperty,
    JS_ATOM_getOwnPropertyDescriptor,
    JS_ATOM_ownKeys,
    JS_ATOM_add,
    JS_ATOM_done,
    JS_ATOM_next,
    JS_ATOM_values,
    JS_ATOM_source,
    JS_ATOM_flags,
    JS_ATOM_global,
    JS_ATOM_unicode,
    JS_ATOM_raw,
    JS_ATOM_new_target,
    JS_ATOM_this_active_func,
    JS_ATOM_home_object,
    JS_ATOM_computed_field,
    JS_ATOM_static_computed_field,
    JS_ATOM_class_fields_init,
    JS_ATOM_brand,
    JS_ATOM_hash_constructor,
    JS_ATOM_as,
    JS_ATOM_from,
    JS_ATOM_meta,
    JS_ATOM__default_,
    JS_ATOM__star_,
    JS_ATOM_Module,
    JS_ATOM_then,
    JS_ATOM_resolve,
    JS_ATOM_reject,
    JS_ATOM_promise,
    JS_ATOM_proxy,
    JS_ATOM_revoke,
    JS_ATOM_async,
    JS_ATOM_exec,
    JS_ATOM_groups,
    JS_ATOM_status,
    JS_ATOM_reason,
    JS_ATOM_globalThis,

    // TODO: Support bignum
    // #ifdef CONFIG_BIGNUM
    // JS_ATOM_bigint,
    // JS_ATOM_bigfloat,
    // JS_ATOM_bigdecimal,
    // JS_ATOM_roundingMode,
    // JS_ATOM_maximumSignificantDigits,
    // JS_ATOM_maximumFractionDigits,
    // #endif

    // TODO: Support atomics
    // #ifdef CONFIG_ATOMICS
    // JS_ATOM_not_equal,
    // JS_ATOM_timed_out,
    // JS_ATOM_ok,
    // #endif

    JS_ATOM_toJSON,

    // /* class names */
    JS_ATOM_Object,
    JS_ATOM_Array,
    JS_ATOM_Error,
    JS_ATOM_Number,
    JS_ATOM_String,
    JS_ATOM_Boolean,
    JS_ATOM_Symbol,
    JS_ATOM_Arguments,
    JS_ATOM_Math,
    JS_ATOM_JSON,
    JS_ATOM_Date,
    JS_ATOM_Function,
    JS_ATOM_GeneratorFunction,
    JS_ATOM_ForInIterator,
    JS_ATOM_RegExp,
    JS_ATOM_ArrayBuffer,
    JS_ATOM_SharedArrayBuffer,

    // /* must keep same order as class IDs for typed arrays */
    JS_ATOM_Uint8ClampedArray,
    JS_ATOM_Int8Array,
    JS_ATOM_Uint8Array,
    JS_ATOM_Int16Array,
    JS_ATOM_Uint16Array,
    JS_ATOM_Int32Array,
    JS_ATOM_Uint32Array,

    // TODO: Support bignum
    // #ifdef CONFIG_BIGNUM
    // JS_ATOM_BigInt64Array,
    // JS_ATOM_BigUint64Array,
    // #endif
    JS_ATOM_Float32Array,
    JS_ATOM_Float64Array,
    JS_ATOM_DataView,

    // TODO: Support bignum
    // #ifdef CONFIG_BIGNUM
    // JS_ATOM_BigInt,
    // JS_ATOM_BigFloat,
    // JS_ATOM_BigFloatEnv,
    // JS_ATOM_BigDecimal,
    // JS_ATOM_OperatorSet,
    // JS_ATOM_Operators,
    // #endif

    JS_ATOM_Map,
    JS_ATOM_Set,
    JS_ATOM_WeakMap,
    JS_ATOM_WeakSet,
    JS_ATOM_Map_Iterator,
    JS_ATOM_Set_Iterator,
    JS_ATOM_Array_Iterator,
    JS_ATOM_String_Iterator,
    JS_ATOM_RegExp_String_Iterator,
    JS_ATOM_Generator,
    JS_ATOM_Proxy,
    JS_ATOM_Promise,
    JS_ATOM_PromiseResolveFunction,
    JS_ATOM_PromiseRejectFunction,
    JS_ATOM_AsyncFunction,
    JS_ATOM_AsyncFunctionResolve,
    JS_ATOM_AsyncFunctionReject,
    JS_ATOM_AsyncGeneratorFunction,
    JS_ATOM_AsyncGenerator,
    JS_ATOM_EvalError,
    JS_ATOM_RangeError,
    JS_ATOM_ReferenceError,
    JS_ATOM_SyntaxError,
    JS_ATOM_TypeError,
    JS_ATOM_URIError,
    JS_ATOM_InternalError,
    // /* private symbols */
    JS_ATOM_Private_brand,
    // /* symbols */
    JS_ATOM_Symbol_toPrimitive,
    JS_ATOM_Symbol_iterator,
    JS_ATOM_Symbol_match,
    JS_ATOM_Symbol_matchAll,
    JS_ATOM_Symbol_replace,
    JS_ATOM_Symbol_search,
    JS_ATOM_Symbol_split,
    JS_ATOM_Symbol_toStringTag,
    JS_ATOM_Symbol_isConcatSpreadable,
    JS_ATOM_Symbol_hasInstance,
    JS_ATOM_Symbol_species,
    JS_ATOM_Symbol_unscopables,
    JS_ATOM_Symbol_asyncIterator,

    // TODO: Support bignum
    // #ifdef CONFIG_BIGNUM
    // JS_ATOM_Symbol_operatorSet,
    // #endif
};
//     enum {
//     JS_ATOM_NULL,
// #define DEF(name, str) JS_ATOM_ ## name,
// #include "quickjs-atom.h"
// #undef DEF
//     JS_ATOM_END,
// };

const JSSymbol = struct {

};

const  JSReqModuleEntry = struct{
    module_name: JSAtom,
    module: *JSModuleDef,
    // JSAtom module_name;
    // JSModuleDef *module; /* used using resolution */
};

const JSExportTypeEnum = enum {
    JS_EXPORT_TYPE_LOCAL,
    JS_EXPORT_TYPE_INDIRECT,
};

const JSExportEntryLocal = struct {
    var_idx: u32,
    var_ref: ?*JSVarRef,
};

const JSExportEntryValue = union(JSExportTypeEnum) {
    JS_EXPORT_TYPE_LOCAL: JSExportEntryLocal,
    JS_EXPORT_TYPE_INDIRECT: u32
};

const JSExportEntry = struct {
    value: JSExportEntryValue,

    /// "*" if export ns from. not used for local export
    /// after compilation
    local_name: JSAtom,

    /// exported variable name
    export_name: JSAtom,
    // union {
    //     struct {
    //         int var_idx; /* closure variable index */
    //         JSVarRef *var_ref; /* if != NULL, reference to the variable */
    //     } local; /* for local export */
    //     int req_module_idx; /* module for indirect export */
    // } u;
    // JSExportTypeEnum export_type;
    // JSAtom local_name; /* '*' if export ns from. not used for local
    //                       export after compilation */
    // JSAtom export_name; /* exported variable name */
};

const JSStarExportEntry = struct {
    /// in req_module_entries
    req_module_idx: usize,
};

const JSImportEntry = struct {
    /// closure variable index
    var_idx: u32,

    import_name: JSAtom,

    /// in req_module_entries
    req_module_idx: usize,

    // int var_idx; /* closure variable index */
    // JSAtom import_name;
    // int req_module_idx; /* in req_module_entries */
};

const JSModuleInitFunc = fn(ctx: *JSContext, m: *JSModuleDef) u32;
// typedef int JSModuleInitFunc(JSContext *ctx, JSModuleDef *m);

const JSModuleDef = struct {
    header: JSRefCountHeader,
    module_name: JSAtom,

    req_module_entries: std.ArrayList(JSReqModuleEntry),

    export_entries: std.ArrayList(JSExportEntry),

    star_export_entries: std.ArrayList(JSStarExportEntry),

    import_entries: std.ArrayList(JSImportEntry),

    module_ns: JSValue,

    /// Only used for JS modules
    func_obj: JSValue,

    /// only used for C modules
    init_func: JSModuleInitFunc,
    resolved: bool,
    func_created: bool,
    instantiated: bool,
    evaluated: bool,

    /// temporary use during js_evaluate_module()
    eval_mark: bool,

    /// true if evaluation yielded an exception.
    /// It is saved in eval_exception.
    eval_has_exception: bool,
    eval_exception: JSValue,

    /// For import.meta
    meta_obj: JSValue

    // JSRefCountHeader header; /* must come first, 32-bit */
    // JSAtom module_name;
    // struct list_head link;

    // JSReqModuleEntry *req_module_entries;
    // int req_module_entries_count;
    // int req_module_entries_size;

    // JSExportEntry *export_entries;
    // int export_entries_count;
    // int export_entries_size;

    // JSStarExportEntry *star_export_entries;
    // int star_export_entries_count;
    // int star_export_entries_size;

    // JSImportEntry *import_entries;
    // int import_entries_count;
    // int import_entries_size;

    // JSValue module_ns;
    // JSValue func_obj; /* only used for JS modules */
    // JSModuleInitFunc *init_func; /* only used for C modules */
    // BOOL resolved : 8;
    // BOOL func_created : 8;
    // BOOL instantiated : 8;
    // BOOL evaluated : 8;
    // BOOL eval_mark : 8; /* temporary use during js_evaluate_module() */
    // /* true if evaluation yielded an exception. It is saved in
    //    eval_exception */
    // BOOL eval_has_exception : 8; 
    // JSValue eval_exception;
    // JSValue meta_obj; /* for import.meta */
};

// const JSValue = struct {
//     u: JSValueUnion,
//     tag: JSTag,
// };

const JSPropertyGetterSetter = struct {
    getter: ?*JSObject,
    setter: ?*JSObject,
};

const JSPropertyAutoInit = struct {
    realm: *JSContext,
    init_id: JSAutoInitIDEnum,
    // o: opaque{},
};

const JSAutoInitIDEnum = enum(u2) {
    JS_AUTOINIT_ID_PROTOTYPE,
    JS_AUTOINIT_ID_MODULE_NS,
    JS_AUTOINIT_ID_PROP,
};

const JSPropertyType = enum {
    VALUE,
    GETSET,
    VAR_REF,
    AUTO_INIT
};

const JSProperty = union(JSPropertyType) {
    VALUE: JSValue,
    GETSET: JSPropertyGetterSetter,
    VAR_REF: *JSVarRef,
    AUTO_INIT: JSPropertyAutoInit
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

const JSVarRef = struct {
    header: JSGCObjectHeaderNode,
    is_detached: bool,
    is_arg: bool,
    var_idx: u16,
    pvalue: *JSValue,
    value: JSValue,
};

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

/// Calculates the hashcode for the given values.
/// Used by the shape system to allow reusing memory when describing object metadata.
/// See https://marcradziwill.com/blog/mastering-javascript-high-performance/
fn shape_hash(h: u32, val: u32) u32 {
    // uses same magic hash multiplier as the Linux kernel
    return (h + val) * 0x9e370001;
}

const JSObject = struct {
    header: JSGCObjectHeaderNode,
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

    class_id: u16,

    shape: *JSShape,
    properties: []JSProperty,

    // TODO:
    // first_weak_ref: *JSMapRecord,

    data: JSObjectData,

    const Self = @This();

    /// Gets the initial shape hash for this object.
    pub fn shape_initial_hash(self: *Self) u32 {
        return shape_initial_hash(self);
    }

    /// Adds a reference to this object
    /// and returns itself.
    pub fn duplicate(self: *Self) *JSObject {
        self.header.data.add_ref();
        return self;
    }
};

fn shape_initial_hash(shape: ?*JSObject) u32 {
    const ptr: usize = if (shape) |self| @ptrToInt(self) else 0;
    const hash = shape_hash(1, @truncate(u32, ptr));
    if  (ptr > std.math.maxInt(u32)) {
        return shape_hash(hash, @truncate(u32, ptr >> 32));
    } 
    return hash;
    // uint32_t h;
    // h = shape_hash(1, (uintptr_t)proto);
    // if (sizeof(proto) > 4)
    //     h = shape_hash(h, (uint64_t)(uintptr_t)proto >> 32);
    // return h;
}

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

// flags for object properties
const JS_PROP_CONFIGURABLE: u32 = (1 << 0);
const JS_PROP_WRITABLE: u32 = (1 << 1);
const JS_PROP_ENUMERABLE: u32 = (1 << 2);
const JS_PROP_C_W_E: u32 = (JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE | JS_PROP_ENUMERABLE);

/// used internally in Arrays
const JS_PROP_LENGTH: u32 = (1 << 3);

/// mask for NORMAL, GETSET, VARREF, AUTOINIT
const JS_PROP_TMASK: u32 = (3 << 4);
const JS_PROP_NORMAL: u32 = (0 << 4);
const JS_PROP_GETSET: u32 = (1 << 4);

/// used internally
const JS_PROP_VARREF: u32 = (2 << 4);

/// used internally
const JS_PROP_AUTOINIT: u32 = (3 << 4);

// /* flags for JS_DefineProperty */
const JS_PROP_HAS_SHIFT: u32 = 8;
const JS_PROP_HAS_CONFIGURABLE: u32 = (1 << 8);
const JS_PROP_HAS_WRITABLE: u32 = (1 << 9);
const JS_PROP_HAS_ENUMERABLE: u32 = (1 << 10);
const JS_PROP_HAS_GET: u32 = (1 << 11);
const JS_PROP_HAS_SET: u32 = (1 << 12);
const JS_PROP_HAS_VALUE: u32 = (1 << 13);

// /* throw an exception if false would be returned
//    (JS_DefineProperty/JS_SetProperty) */
const JS_PROP_THROW: u32 = (1 << 14);
// /* throw an exception if false would be returned in strict mode
//    (JS_SetProperty) */
const JS_PROP_THROW_STRICT: u32 =(1 << 15);

/// internal use
const JS_PROP_NO_ADD: u32 = (1 << 16);

/// internal use
const JS_PROP_NO_EXOTIC: u32 =(1 << 17);

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
    cur_sp: ?*JSValue,
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
    gc_mark: ?*JSClassGCMark,
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

    const Self = @This();

    pub fn init(obj_type: JSGCObjectType) Self {
        return Self{
            .ref_count = 0,
            .gc_obj_type = obj_type,
            .mark = 0
        };
    }

    pub fn add_ref(self: *Self) void {
        self.ref_count += 1;
    }

    pub fn remove_ref(self: *Self) void {
        self.ref_count -= 1;
    }
};

const JSGCObjectHeaderList = std.TailQueue(JSGCObjectHeader);
const JSGCObjectHeaderNode = JSGCObjectHeaderList.Node;

const JSClassFinalizer = fn(runtime: *JSRuntime, val: JSValue) void;
const JSClassGCMark = fn(runtime: *JSRuntime, val: JSValue, mark_func: MarkFunc) void;

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

const JSShapeProperty = struct {
    hash_next: u32,
    flags: u32,
    atom: JSAtom,
    // uint32_t hash_next : 26; /* 0 if last in list */
    // uint32_t flags : 6;   /* JS_PROP_XXX */
    // JSAtom atom; /* JS_ATOM_NULL = free property entry */
};

const JSShape = struct {
    header: JSGCObjectHeaderNode,
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

    /// includes deleted properties
    deleted_prop_count: u32,

    proto: ?*JSObject,
    properties: std.ArrayList(JSShapeProperty),

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

    const Self = @This();

    /// Creates a new JSShape for the given context and prototype.
    /// Returns a pointer to the newly allocated shape.
    /// The context owns the new shape.
    pub fn initFromProto(ctx: *JSContext, proto: ?*JSObject) !*Self {
        return Self.initFromProtoWithSizes(ctx, proto, 4, 2);
    }

    /// Creates a new JSShape for the given context and prototype.
    /// Returns a pointer to the newly allocated shape.
    /// The context owns the new shape.
    pub fn initFromProtoWithSizes(ctx: *JSContext, proto: ?*JSObject, hash_size: u32, prop_size: u32) !*Self {
        const self = try ctx.runtime.allocator.allocator.create(Self);
        errdefer ctx.runtime.allocator.allocator.destroy(self);
        self.header = .{
            .data = JSGCObjectHeader.init(.JS_GC_OBJ_TYPE_SHAPE)
        };
        self.header.data.add_ref();
        ctx.runtime.add_gc_obj(&self.header);
        self.proto = if (proto) |p| p.duplicate() else null;
        self.prop_hash_mask = hash_size - 1;
        self.deleted_prop_count = 0;
        self.properties = try std.ArrayList(JSShapeProperty).initCapacity(&ctx.runtime.allocator.allocator, prop_size);
        self.hash = shape_initial_hash(self.proto);
        self.is_hashed = true;
        self.has_small_array_index = false;
        try ctx.runtime.add_shape(self);

        return self;


        // JSRuntime *rt = ctx->rt;
        // void *sh_alloc;
        // JSShape *sh;

        // /* resize the shape hash table if necessary */
        // if (2 * (rt->shape_hash_count + 1) > rt->shape_hash_size) {
        //     resize_shape_hash(rt, rt->shape_hash_bits + 1);
        // }

        // sh_alloc = js_malloc(ctx, get_shape_size(hash_size, prop_size));
        // if (!sh_alloc)
        //     return NULL;
        // sh = get_shape_from_alloc(sh_alloc, hash_size);
        // sh->header.ref_count = 1;
        // add_gc_object(rt, &sh->header, JS_GC_OBJ_TYPE_SHAPE);
        // if (proto)
        //     JS_DupValue(ctx, JS_MKPTR(JS_TAG_OBJECT, proto));
        // sh->proto = proto;
        // memset(sh->prop_hash_end - hash_size, 0, sizeof(sh->prop_hash_end[0]) *
        //     hash_size);
        // sh->prop_hash_mask = hash_size - 1;
        // sh->prop_size = prop_size;
        // sh->prop_count = 0;
        // sh->deleted_prop_count = 0;
        
        // /* insert in the hash table */
        // sh->hash = shape_initial_hash(proto);
        // sh->is_hashed = TRUE;
        // sh->has_small_array_index = FALSE;
        // js_shape_hash_link(ctx->rt, sh);
        // return sh;
    }

    /// Releases and frees resources that this shape owns.
    pub fn deinit(self: *Self) void {
        self.properties.deinit();
    }

    /// Adds a reference to this shape
    /// and returns itself.
    pub fn duplicate(self: *Self) *JSShape {
        self.header.data.add_ref();
        return self;
    }
};

test "JSShape - initFromProto()" {
    { // null prototype
        var gpa = JSAllocator{};
        defer std.testing.expect(!gpa.deinit());

        var runtime = JSRuntime.init(&gpa);
        defer runtime.deinit();

        var context = try runtime.new_context();
        defer context.deinit();

        var shape = try JSShape.initFromProto(context, null);

        testing.expect(shape.properties.capacity == 2);
        testing.expect(shape.properties.items.len == 0);
        testing.expect(shape.header.data.ref_count == 1);
        testing.expect(shape.is_hashed == true);
        testing.expect(shape.deleted_prop_count == 0);
        testing.expect(shape.has_small_array_index == false);
        testing.expect(shape.proto == null);
        
        var found = runtime.shape_hash.get(shape.hash);
        testing.expect(found.? == shape);
    }
}

const JSContext = struct {
    header: JSGCObjectHeaderNode,
    runtime: *JSRuntime,
    binary_object_count: u16,
    binary_object_size: u32,

    array_shape: ?*JSShape,
    class_proto: std.ArrayList(JSValue),
    function_proto: JSValue,
    function_ctor: JSValue,
    array_ctor: JSValue,
    regexp_ctor: JSValue,
    promise_ctor: JSValue,
    native_error_proto: [JS_NATIVE_ERROR_COUNT]JSValue,
    iterator_proto: JSValue,
    async_iterator_proto: JSValue,
    array_proto_values: JSValue,
    throw_type_error: JSValue,
    eval_obj: JSValue,
    global_obj: JSValue,
    global_var_obj: JSValue,

    /// Used for random number generation
    random_state: u64,

    /// The number of cycles left before the interrupt handler should be called
    interrupt_counter: i32,

    loaded_modules: std.TailQueue(JSModuleDef),

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

    const Self = @This();

    pub fn init(runtime: *JSRuntime) !Self {
        var self = Self{
            .runtime = runtime,
            .header = .{
                .data = JSGCObjectHeader.init(.JS_GC_OBJ_TYPE_JS_CONTEXT)
            },
            .class_proto = std.ArrayList(JSValue).init(&runtime.allocator.allocator),
            .loaded_modules = std.TailQueue(JSModuleDef){},
            .binary_object_count = 0,
            .binary_object_size = 0,
            .array_shape = null,
            .function_proto = JS_NULL,
            .function_ctor = JS_NULL,
            .array_ctor = JS_NULL,
            .regexp_ctor = JS_NULL,
            .promise_ctor = JS_NULL,
            .native_error_proto = .{
                JS_NULL,
                JS_NULL,
                JS_NULL,
                JS_NULL,
                JS_NULL,
                JS_NULL,
                JS_NULL,
                JS_NULL,
            },
            .iterator_proto = JS_NULL,
            .async_iterator_proto = JS_NULL,
            .array_proto_values = JS_NULL,
            .throw_type_error = JS_NULL,
            .eval_obj = JS_NULL,
            .global_obj = JS_NULL,
            .global_var_obj = JS_NULL,
            .random_state = 0,
            .interrupt_counter = 10000,
        };

        // add_intrinsic_basic_objects(self);

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.class_proto.deinit();
    }

    // pub fn add_intrinsic_basic_objects(self: *Self) void {

    // }

    /// Creates a new value from the given prototype with the given class.
    /// This can be useful for creating objects/arrays and other primitive values with a specific prototype.
    /// Returns a value that points to the created value.
    pub fn new_object_proto_class(self: *Self, proto_val: JSValue, class: JSClassEnum) JSValue {
        var proto: *JSObject = if (proto_val == .JS_CLASS_OBJECT) |obj| obj else unreachable;
        var foundShape: ?*JSShape = self.runtime.find_shape_for_proto(proto);
        var shape = if (foundShape) |shape| shape.duplicate() else try JSShape.initFromProto(self, proto);
        return self.new_object_from_shape(shape, class);

    //     JSShape *sh;
    // JSObject *proto;

    // proto = get_proto_obj(proto_val);
    // sh = find_hashed_shape_proto(ctx->rt, proto);
    // if (likely(sh)) {
    //     sh = js_dup_shape(sh);
    // } else {
    //     sh = js_new_shape(ctx, proto);
    //     if (!sh)
    //         return JS_EXCEPTION;
    // }
    // return JS_NewObjectFromShape(ctx, sh, class_id);
    }

    /// Creates a new object from the given prototype.
    /// Returns a value that points to the created object.
    pub fn new_object_proto(self: *Self, proto_val: JSValue) JSValue {
        return self.new_object_proto_class(proto_val, .JS_CLASS_OBJECT);
    }

    /// Creates a new object from the given shape and class.
    /// Returns a value that points to the new object.
    pub fn new_object_from_shape(self: *Self, shape: *JSShape, class: JSClassEnum) JSValue {

        self.runtime.trigger_gc();

    //     JSObject *p;

    //     js_trigger_gc(ctx->rt, sizeof(JSObject));
    //     p = js_malloc(ctx, sizeof(JSObject));
    //     if (unlikely(!p))
    //         goto fail;
    //     p->class_id = class_id;
    //     p->extensible = TRUE;
    //     p->free_mark = 0;
    //     p->is_exotic = 0;
    //     p->fast_array = 0;
    //     p->is_constructor = 0;
    //     p->is_uncatchable_error = 0;
    //     p->tmp_mark = 0;
    //     p->first_weak_ref = NULL;
    //     p->u.opaque = NULL;
    //     p->shape = sh;
    //     p->prop = js_malloc(ctx, sizeof(JSProperty) * sh->prop_size);
    //     if (unlikely(!p->prop)) {
    //         js_free(ctx, p);
    //     fail:
    //         js_free_shape(ctx->rt, sh);
    //         return JS_EXCEPTION;
    //     }

    //     switch(class_id) {
    //     case JS_CLASS_OBJECT:
    //         break;
    //     case JS_CLASS_ARRAY:
    //         {
    //             JSProperty *pr;
    //             p->is_exotic = 1;
    //             p->fast_array = 1;
    //             p->u.array.u.values = NULL;
    //             p->u.array.count = 0;
    //             p->u.array.u1.size = 0;
    //             /* the length property is always the first one */
    //             if (likely(sh == ctx->array_shape)) {
    //                 pr = &p->prop[0];
    //             } else {
    //                 /* only used for the first array */
    //                 /* cannot fail */
    //                 pr = add_property(ctx, p, JS_ATOM_length,
    //                                 JS_PROP_WRITABLE | JS_PROP_LENGTH);
    //             }
    //             pr->u.value = JS_NewInt32(ctx, 0);
    //         }
    //         break;
    //     case JS_CLASS_C_FUNCTION:
    //         p->prop[0].u.value = JS_UNDEFINED;
    //         break;
    //     case JS_CLASS_ARGUMENTS:
    //     case JS_CLASS_UINT8C_ARRAY ... JS_CLASS_FLOAT64_ARRAY:
    //         p->is_exotic = 1;
    //         p->fast_array = 1;
    //         p->u.array.u.ptr = NULL;
    //         p->u.array.count = 0;
    //         break;
    //     case JS_CLASS_DATAVIEW:
    //         p->u.array.u.ptr = NULL;
    //         p->u.array.count = 0;
    //         break;
    //     case JS_CLASS_NUMBER:
    //     case JS_CLASS_STRING:
    //     case JS_CLASS_BOOLEAN:
    //     case JS_CLASS_SYMBOL:
    //     case JS_CLASS_DATE:
    // #ifdef CONFIG_BIGNUM
    //     case JS_CLASS_BIG_INT:
    //     case JS_CLASS_BIG_FLOAT:
    //     case JS_CLASS_BIG_DECIMAL:
    // #endif
    //         p->u.object_data = JS_UNDEFINED;
    //         goto set_exotic;
    //     case JS_CLASS_REGEXP:
    //         p->u.regexp.pattern = NULL;
    //         p->u.regexp.bytecode = NULL;
    //         goto set_exotic;
    //     default:
    //     set_exotic:
    //         if (ctx->rt->class_array[class_id].exotic) {
    //             p->is_exotic = 1;
    //         }
    //         break;
    //     }
    //     p->header.ref_count = 1;
    //     add_gc_object(ctx->rt, &p->header, JS_GC_OBJ_TYPE_JS_OBJECT);
    //     return JS_MKPTR(JS_TAG_OBJECT, p);
    }
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

fn OpaqueCallback(comptime Handle: type, comptime Args: type, comptime R: type) type {
    return struct {
        callback: fn(handle: Handle, args: Args) R,
        handle: Handle,
    };
}

const JSInterruptCallback = OpaqueCallback(usize, *JSRuntime, bool);

const JSHostPromiseRejectionTrackerArgs = struct {
    ctx: *JSContext,
    promise: JSValue,
    reason: JSValue,
    is_handled: bool,
};
const JSHostPromiseRejectionTracker = OpaqueCallback(usize, JSHostPromiseRejectionTrackerArgs, void);

const JSJobFunc = fn(ctx: *JSContext, args: []JSValue) JSValue;
const JSJobEntry = struct {
    ctx: *JSContext,
    jop_func: *JSJobFunc,
    args: []JSValue,
    // struct list_head link;
    // JSContext *ctx;
    // JSJobFunc *job_func;
    // int argc;
    // JSValue argv[0];
};

// typedef char *JSModuleNormalizeFunc(JSContext *ctx,
                                    // const char *module_base_name,
                                    // const char *module_name, void *opaque);
const JSModuleNormalizeFuncArgs = struct {
    ctx: *JSContext,
    module_base_name: []const u8,
    module_name: []const u8,
};
const JSModuleNormalizeFunc = OpaqueCallback(usize, JSModuleNormalizeFuncArgs, []u8);

const JSModuleLoaderFuncArgs = struct {
    ctx: *JSContext,
    module_name: []const u8,
};
const JSModuleLoaderFunc = OpaqueCallback(usize, JSModuleLoaderFuncArgs, *JSModuleDef);

const JSSharedArrayBufferFunctions = struct {
    sab_alloc: fn(handle: *JSSharedArrayBufferFunctions, size: usize) []u8,
    sab_free: fn(handle: *JSSharedArrayBufferFunctions, data: []u8) void,
    sab_dup: fn(handle: *JSSharedArrayBufferFunctions, data: []u8) void,

    const Self = @This();

    pub fn alloc(self: *Self, size: usize) []u8 {
        return self.sab_alloc(self, size);
    }

    pub fn free(data: []u8) void {
        return self.sab_free(self, data);
    }

    pub fn dup(data: []u8) void {
        return self.sab_dup(self, data);
    }

    // void *(*sab_alloc)(void *opaque, size_t size);
    // void (*sab_free)(void *opaque, void *ptr);
    // void (*sab_dup)(void *opaque, void *ptr);
    // void *sab_opaque;
};

fn get_shape_hash(hash: u32) u64 {
    return @intCast(u64, hash);
}

fn are_shapes_equal(first: u32, second: u32) bool {
    return true;
}

const ShapeHashMap = std.HashMap(u32, *JSShape, get_shape_hash, are_shapes_equal, std.hash_map.default_max_load_percentage);

const JS_DEFAULT_STACK_SIZE: usize = (256 * 1024);

const MarkFunc = fn(runtime: *JSRuntime, gp: *JSGCObjectHeader) void;


fn gc_decref_child(runtime: *JSRuntime, header: *JSGCObjectHeaderNode) void {
    std.debug.assert(header.ref_count > 0);
    header.ref_count -= 1;
    if (header.ref_count == 0 and header.mark == 1) {
        // Remove from the gc list and add to the temp obj list
        runtime.gc_obj_list.remove(header);
        runtime.tmp_obj_list.append(header);
    }
    // assert(p->ref_count > 0);
    // p->ref_count--;
    // if (p->ref_count == 0 && p->mark == 1) {
    //     list_del(&p->link);
    //     list_add_tail(&p->link, &rt->tmp_obj_list);
    // }
}

const JSRuntime = struct {
    allocator: *JSAllocator,
    classes: std.ArrayList(JSClass),
    
    context_list: std.ArrayList(JSContext),

    // Garbage Collection data
    gc_phase: JSGCPhase,
    gc_obj_list: JSGCObjectHeaderList,
    gc_zero_ref_count_list: std.TailQueue(*JSGCObjectHeader),
    tmp_obj_list: std.TailQueue(*JSGCObjectHeader),

    /// The address of the top stack frame for the runtime
    stack_top: usize,

    /// The maximum stack size for the runtime
    stack_size: usize,

    /// The current JS stack frame
    current_stack_frame: ?*JSStackFrame,
    current_exception: JSValue,

    /// Whether the runtime is currently processing a OutOfMemory error
    in_out_of_memory: bool,

    interrupt_handler: ?JSInterruptCallback,
    host_promise_rejection_tracker: ?JSHostPromiseRejectionTracker,

    job_list: std.TailQueue(JSJobEntry),

    module_normalize_func: ?JSModuleNormalizeFunc,
    module_loader_func: ?JSModuleLoaderFunc,

    can_block: bool,

    /// Used to allocate, free, and clone SharedArrayBuffers
    sab_funcs: ?JSSharedArrayBufferFunctions,
    shape_hash: ShapeHashMap,

    /// The threshold that should be used to trigger garbage collection.
    /// This is automatically adjusted whenever garbage collection is triggered.
    gc_threshold: usize,
    
// #ifdef CONFIG_BIGNUM
//     bf_context_t bf_ctx;
//     JSNumericOperations bigint_ops;
//     JSNumericOperations bigfloat_ops;
//     JSNumericOperations bigdecimal_ops;
//     uint32_t operator_count;
// #endif

//     JSDebuggerInfo debugger_info;

    const Self = @This();

    pub fn init(allocator: *JSAllocator) Self {
        return Self{
            .allocator = allocator,
            .classes = std.ArrayList(JSClass).init(&allocator.allocator),
            .current_exception = JS_NULL,
            .current_stack_frame = null,
            .gc_phase = .JS_GC_PHASE_NONE,
            .context_list = std.ArrayList(JSContext).init(&allocator.allocator),
            .gc_obj_list = JSGCObjectHeaderList{},
            .gc_zero_ref_count_list = std.TailQueue(*JSGCObjectHeader){},
            .tmp_obj_list = std.TailQueue(*JSGCObjectHeader){},
            .job_list = std.TailQueue(JSJobEntry){},
            .stack_top = @frameAddress(),
            .stack_size = JS_DEFAULT_STACK_SIZE,
            .in_out_of_memory = false,
            .interrupt_handler = null,
            .host_promise_rejection_tracker = null,
            .module_normalize_func = null,
            .module_loader_func = null,
            .can_block = false,
            .sab_funcs = null,
            .shape_hash = ShapeHashMap.init(&allocator.allocator),
            .gc_threshold = 256 * 1024
        };
    }

    pub fn deinit(self: *Self) void {
        self.classes.deinit();
        self.context_list.deinit();
        var shape_it = self.shape_hash.iterator();
        while(shape_it.next()) |kv| {
            kv.value.deinit();
            self.allocator.allocator.destroy(kv.value);
        }
        self.shape_hash.deinit();
    }

    /// Creates a new JSContext and returns a pointer to it.
    /// The runtime owns the context but you can signal to it that
    /// you are no longer using the context by calling JSContext.deref().
    /// Calling JSRuntime.deinit() will invalidate all contexts.
    pub fn new_context(self: *Self) !*JSContext {
        var context = try JSContext.init(self);
        errdefer context.deinit();

        var context_ptr = try self.context_list.addOne();
        context_ptr.* = context;
        errdefer self.context_list.pop();

        self.add_gc_obj(&context_ptr.header);
        errdefer self.remove_gc_obj(&context_ptr.header);
        context_ptr.header.data.add_ref();

        return context_ptr;
    }

    /// Adds the given GC Object header to the list of objects
    /// that need GC.
    pub fn add_gc_obj(self: *Self, node: *JSGCObjectHeaderNode) void {
        node.data.mark = 0;
        self.gc_obj_list.append(node);
    }

    /// Removes the given GC Object header from the list of objects that 
    /// need GC.
    pub fn remove_gc_obj(self: *Self, node: *JSGCObjectHeaderNode) void {
        self.gc_obj_list.remove(node);
    }

    /// Finds a hashed empty shape that matches the given prototype.
    /// Returns null if not found.
    pub fn find_shape_for_proto(self: *Self, proto: *JSObject) ?*JSShape {
        var hash: u32 = proto.shape_initial_hash();
        return self.shape_hash.get(hash);
    }

    /// Adds the given shape to the shape hash table.
    /// Once added, this context owns the shape.
    pub fn add_shape(self: *Self, shape: *JSShape) !void {
        return self.shape_hash.put(shape.hash, shape);
    }

    /// Runs a Garbage Collection pass if there is more allocated space
    /// than the configured limit. Takes an extra space parameter that can be used
    /// to determine if GC should be run before some space is allocated to try to prevent
    /// exceeding memory limits.
    pub fn trigger_gc(self: *Self, extra_space: usize) void {
        const force_gc = (self.allocator.total_requested_bytes + extra_space) > self.gc_threshold;

        if (force_gc) {
            self.run_gc();

            // Adjust the gc threshold based on how much memory is left
            self.gc_threshold = self.allocator.total_requested_bytes + self.allocator.total_requested_bytes >> 1;
        }

//         BOOL force_gc;
// #ifdef FORCE_GC_AT_MALLOC
//     force_gc = TRUE;
// #else
//     force_gc = ((rt->malloc_state.malloc_size + size) >
//                 rt->malloc_gc_threshold);
// #endif
//     if (force_gc) {
// #ifdef DUMP_GC
//         printf("GC: size=%" PRIu64 "\n",
//                (uint64_t)rt->malloc_state.malloc_size);
// #endif
//         JS_RunGC(rt);
//         rt->malloc_gc_threshold = rt->malloc_state.malloc_size +
//             (rt->malloc_state.malloc_size >> 1);
//     }
    }

    /// Runs a garbage collection pass.
    fn run_gc(self: *Self) void {

        self.gc_deref();

        // /* decrement the reference of the children of each object. mark =
        // 1 after this pass. */
        // gc_decref(rt);

        // /* keep the GC objects with a non zero refcount and their childs */
        // gc_scan(rt);

        // /* free the GC objects in a cycle */
        // gc_free_cycles(rt);
    }

    /// Decrements each GC object's refcount by 1 and sets their mark to 1.
    fn gc_deref(self: *Self) void {
        var list_obj: ?*JSGCObjectHeaderNode = self.gc_obj_list.first;

        // decrement the refcount of all the children of all the GC
        // objects and move the GC objects with zero refcount to
        // tmp_obj_list
        while(list_obj) |obj| {
            std.deug.assert(obj.data.mark == 0);
            self.mark_children(obj, gc_deref_child);
            obj.data.mark = 1;
            if (obj.data.ref_count == 0) {
                self.gc_obj_list.remove(obj);
                self.tmp_obj_list.append(obj);
            }
            list_obj = obj.next;
        }

        // struct list_head *el, *el1;
        // JSGCObjectHeader *p;
        
        // init_list_head(&rt->tmp_obj_list);

        // /* decrement the refcount of all the children of all the GC
        // objects and move the GC objects with zero refcount to
        // tmp_obj_list */
        // list_for_each_safe(el, el1, &rt->gc_obj_list) {
        //     p = list_entry(el, JSGCObjectHeader, link);
        //     assert(p->mark == 0);
        //     mark_children(rt, p, gc_decref_child);
        //     p->mark = 1;
        //     if (p->ref_count == 0) {
        //         list_del(&p->link);
        //         list_add_tail(&p->link, &rt->tmp_obj_list);
        //     }
        // }
    }

    fn mark_children(self: *Self, gp: *JSGCObjectHeaderNode, mark_func: MarkFunc) void {
        const gc_obj = get_gc_object(gp);
        switch(gc_obj) {
            .JS_GC_OBJ_TYPE_JS_OBJECT => |obj| {
                const shape = obj.shape;
                mark_func(self, &shape.header.data);

                // mark all the fields
                for(shape.properties.items) |*propertyShape, i| {
                    var prop = &obj.properties[i];
                    if (propertyShape.atom != .JS_ATOM_NULL) {
                        if (propertyShape.flags & JS_PROP_TMASK != 0) {
                            switch(prop) {
                                .GETSET => |*getset| {
                                    if (getset.getter) |getter| {
                                        mark_func(self, &getter.header.data);
                                    }
                                    if (getset.setter) |setter| {
                                        mark_func(self, &setter.header.data);
                                    }
                                    break;
                                },
                                .VAR_REF => |var_ref| {
                                    if (var_ref.is_detached) {
                                        // Note: the tag order does not matter
                                        // provided it is a GC object
                                        mark_func(self, &var_ref.header.data);
                                    }
                                    break;
                                },
                                .AUTO_INIT => |*init| {
                                    self.autoinit_mark(init, mark_func);
                                }
                            }
                        } else {
                            self.mark_value(prop.value, mark_func);
                        }
                    }
                }

                switch(obj.data) {
                    .JS_CLASS_OBJECT => |obj_data| {
                        var gc_mark: ?*JSClassGCMark = self.classes[obj.class_id].gc_mark;
                        if (gc_mark) |mark| {
                            mark(self, JSValue{ .JS_TAG_OBJECT = obj }, mark_func);
                        }
                    },
                }
                //{
        //             JSObject *p = (JSObject *)gp;
        //             JSShapeProperty *prs;
        //             JSShape *sh;
        //             int i;
        //             sh = p->shape;
        //             mark_func(rt, &sh->header);
        //             /* mark all the fields */
        //             prs = get_shape_prop(sh);
        //             for(i = 0; i < sh->prop_count; i++) {
        //                 JSProperty *pr = &p->prop[i];
        //                 if (prs->atom != JS_ATOM_NULL) {
        //                     if (prs->flags & JS_PROP_TMASK) {
        //                         if ((prs->flags & JS_PROP_TMASK) == JS_PROP_GETSET) {
        //                             if (pr->u.getset.getter)
        //                                 mark_func(rt, &pr->u.getset.getter->header);
        //                             if (pr->u.getset.setter)
        //                                 mark_func(rt, &pr->u.getset.setter->header);
        //                         } else if ((prs->flags & JS_PROP_TMASK) == JS_PROP_VARREF) {
        //                             if (pr->u.var_ref->is_detached) {
        //                                 /* Note: the tag does not matter
        //                                 provided it is a GC object */
        //                                 mark_func(rt, &pr->u.var_ref->header);
        //                             }
        //                         } else if ((prs->flags & JS_PROP_TMASK) == JS_PROP_AUTOINIT) {
        //                             js_autoinit_mark(rt, pr, mark_func);
        //                         }
        //                     } else {
        //                         JS_MarkValue(rt, pr->u.value, mark_func);
        //                     }
        //                 }
        //                 prs++;
        //             }

        //             if (p->class_id != JS_CLASS_OBJECT) {
        //                 JSClassGCMark *gc_mark;
        //                 gc_mark = rt->class_array[p->class_id].gc_mark;
        //                 if (gc_mark)
        //                     gc_mark(rt, JS_MKPTR(JS_TAG_OBJECT, p), mark_func);
        //             }
        //         }
                break;
            },
            .JS_GC_OBJ_TYPE_FUNCTION_BYTECODE => |func| {
                // TODO:
                //         /* the template objects can be part of a cycle */
        //         {
        //             JSFunctionBytecode *b = (JSFunctionBytecode *)gp;
        //             int i;
        //             for(i = 0; i < b->cpool_count; i++) {
        //                 JS_MarkValue(rt, b->cpool[i], mark_func);
        //             }
        //             if (b->realm)
        //                 mark_func(rt, &b->realm->header);
        //         }
                break;
            },
            .JS_GC_OBJ_TYPE_VAR_REF => |ref| {
                std.debug.assert(ref.is_detached);
                self.mark_value(ref.pvalue.*, mark_func);
                //         {
        //             JSVarRef *var_ref = (JSVarRef *)gp;
        //             /* only detached variable referenced are taken into account */
        //             assert(var_ref->is_detached);
        //             JS_MarkValue(rt, *var_ref->pvalue, mark_func);
        //         }
                break;
            },
            .JS_GC_OBJ_TYPE_ASYNC_FUNCTION => |func| {
                if (func.is_active) {
                    self.async_func_mark(&func.func_state, mark_func);
                }
                self.mark_value(func.resolving_funcs[0], mark_func);
                self.mark_value(func.resolving_funcs[1], mark_func);

                //         {
        //             JSAsyncFunctionData *s = (JSAsyncFunctionData *)gp;
        //             if (s->is_active)
        //                 async_func_mark(rt, &s->func_state, mark_func);
        //             JS_MarkValue(rt, s->resolving_funcs[0], mark_func);
        //             JS_MarkValue(rt, s->resolving_funcs[1], mark_func);
        //         }
                break;
            },
            .JS_GC_OBJ_TYPE_SHAPE => |shape| {
                if (shape.proto) |proto| {
                    mark_func(self, &proto.header.data);
                }
                //         {
        //             JSShape *sh = (JSShape *)gp;
        //             if (sh->proto != NULL) {
        //                 mark_func(rt, &sh->proto->header);
        //             }
        //         }
                break;
            },
            .JS_GC_OBJ_TYPE_JS_CONTEXT => |ctx| {
                self.mark_context(ctx, mark_func);
                //         {
        //             JSContext *ctx = (JSContext *)gp;
        //             JS_MarkContext(rt, ctx, mark_func);
        //         }
                break;
            },
        }
        // switch(gp->gc_obj_type) {
        //     case JS_GC_OBJ_TYPE_JS_OBJECT:
        //         
        //         break;
        //     case JS_GC_OBJ_TYPE_FUNCTION_BYTECODE:
        
        //         break;
        //     case JS_GC_OBJ_TYPE_VAR_REF:
        
        //         break;
        //     case JS_GC_OBJ_TYPE_ASYNC_FUNCTION:
        
        //         break;
        //     case JS_GC_OBJ_TYPE_SHAPE:
        
        //         break;
        //     case JS_GC_OBJ_TYPE_JS_CONTEXT:
        
        //         break;
        //     default:
        //         abort();
        // }
    }

    /// Marks a JSContext object as part of the "mark" portion of the GC algorithm.
    fn mark_context(self: *Self, ctx: *JSContext, mark_func: MarkFunc) void {

        var loaded_module = ctx.loaded_modules.first;
        while(loaded_module) |module| {
            self.mark_module_def(&module.data, mark_func);
            loaded_module = module.next;
        }

        self.mark_value(ctx.global_obj, mark_func);
        self.mark_value(ctx.global_var_obj, mark_func);
        self.mark_value(ctx.throw_type_error, mark_func);
        self.mark_value(ctx.eval_obj, mark_func);
        self.mark_value(ctx.array_proto_values, mark_func);

        for(ctx.native_error_proto) |proto| {
            self.mark_value(proto, mark_func);
        }
        for(ctx.class_proto) |class| {
            self.mark_value(class, mark_func);
        }

        self.mark_value(ctx.iterator_proto, mark_func);
        self.mark_value(ctx.async_iterator_proto, mark_func);
        self.mark_value(ctx.promise_ctor, mark_func);
        self.mark_value(ctx.array_ctor, mark_func);
        self.mark_value(ctx.regexp_ctor, mark_func);
        self.mark_value(ctx.function_ctor, mark_func);
        self.mark_value(ctx.function_proto, mark_func);

        if (ctx.array_shape) |shape| {
            mark_func(self, &shape.header.data);
        }
        // int i;
        // struct list_head *el;

        // /* modules are not seen by the GC, so we directly mark the objects
        // referenced by each module */
        // list_for_each(el, &ctx->loaded_modules) {
        //     JSModuleDef *m = list_entry(el, JSModuleDef, link);
        //     js_mark_module_def(rt, m, mark_func);
        // }

        // JS_MarkValue(rt, ctx->global_obj, mark_func);
        // JS_MarkValue(rt, ctx->global_var_obj, mark_func);

        // JS_MarkValue(rt, ctx->throw_type_error, mark_func);
        // JS_MarkValue(rt, ctx->eval_obj, mark_func);

        // JS_MarkValue(rt, ctx->array_proto_values, mark_func);
        // for(i = 0; i < JS_NATIVE_ERROR_COUNT; i++) {
        //     JS_MarkValue(rt, ctx->native_error_proto[i], mark_func);
        // }
        // for(i = 0; i < rt->class_count; i++) {
        //     JS_MarkValue(rt, ctx->class_proto[i], mark_func);
        // }
        // JS_MarkValue(rt, ctx->iterator_proto, mark_func);
        // JS_MarkValue(rt, ctx->async_iterator_proto, mark_func);
        // JS_MarkValue(rt, ctx->promise_ctor, mark_func);
        // JS_MarkValue(rt, ctx->array_ctor, mark_func);
        // JS_MarkValue(rt, ctx->regexp_ctor, mark_func);
        // JS_MarkValue(rt, ctx->function_ctor, mark_func);
        // JS_MarkValue(rt, ctx->function_proto, mark_func);

        // if (ctx->array_shape)
        //     mark_func(rt, &ctx->array_shape->header);
    }

    fn async_func_mark(self: *Self, func_state: *JSAsyncFunctionState, mark_func: MarkFunc) void {
        var stack_frame: *JSStackFrame = &func_state.frame;
        self.mark_value(stack_frame.curr_func, mark_func);
        self.mark_value(func_state.this_val, mark_func);
        if (stack_frame.cur_sp) |sp| {
            // if the function is running, cur_sp is not known so we
            // cannot mark the stack. Marking the variables is not needed
            // because a running function cannot be part of a removable cycle
            for (stack_frame.arg_buf) |arg| {
                self.mark_value(arg, mark_func);
            }
        }
        // JSStackFrame *sf;
        // JSValue *sp;

        // sf = &s->frame;
        // JS_MarkValue(rt, sf->cur_func, mark_func);
        // JS_MarkValue(rt, s->this_val, mark_func);
        // if (sf->cur_sp) {
        //     /* if the function is running, cur_sp is not known so we
        //     cannot mark the stack. Marking the variables is not needed
        //     because a running function cannot be part of a removable
        //     cycle */
        //     for(sp = sf->arg_buf; sp < sf->cur_sp; sp++)
        //         JS_MarkValue(rt, *sp, mark_func);
        // }
    }

    fn mark_value(self: *Self, val: JSValue, mark_func: MarkFunc) void {
        switch(val) {
            .JS_TAG_OBJECT, .JS_TAG_FUNCTION_BYTECODE => |v| {
                mark_func(self, &v.header.data);
                break;
            },
        }

        // if (JS_VALUE_HAS_REF_COUNT(val)) {
        //     switch(JS_VALUE_GET_TAG(val)) {
        //     case JS_TAG_OBJECT:
        //     case JS_TAG_FUNCTION_BYTECODE:
        //         mark_func(rt, JS_VALUE_GET_PTR(val));
        //         break;
        //     default:
        //         break;
        //     }
        // }
    }

    fn autoinit_mark(self: *Self, init: *JSPropertyAutoInit, mark_func: MarkFunc) void {
        mark_func(self, &init.realm.header.data);
        // mark_func(rt, &js_autoinit_get_realm(pr)->header);
    }

    fn mark_module_def(self: *Self, module: *JSModuleDef, mark_func: MarkFunc) void {
        for(module.export_entries.items) |*entry| {
            switch(entry.value) {
                .JS_EXPORT_TYPE_LOCAL => |*local| {
                    if (local.var_ref) |ref| {
                        mark_func(self, &ref.header.data);
                    }
                    break;
                }
            }
        }

        self.mark_value(module.module_ns, mark_func);
        self.mark_value(module.func_obj, mark_func);
        self.mark_value(module.eval_exception, mark_func);
        self.mark_value(module.meta_obj, mark_func);
        // int i;

        // for(i = 0; i < m->export_entries_count; i++) {
        //     JSExportEntry *me = &m->export_entries[i];
        //     if (me->export_type == JS_EXPORT_TYPE_LOCAL &&
        //         me->u.local.var_ref) {
        //         mark_func(rt, &me->u.local.var_ref->header);
        //     }
        // }

        // JS_MarkValue(rt, m->module_ns, mark_func);
        // JS_MarkValue(rt, m->func_obj, mark_func);
        // JS_MarkValue(rt, m->eval_exception, mark_func);
        // JS_MarkValue(rt, m->meta_obj, mark_func);
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

test "JSRuntime - deinit" {
    {
        var gpa = JSAllocator{};
        errdefer _ = gpa.deinit();

        var runtime = JSRuntime.init(&gpa);
        errdefer runtime.deinit();

        runtime.deinit();

        testing.expect(!gpa.detectLeaks());
    }
}

test "JSRuntime - new_context()" {
    {
        // Add context to the GC list
        var gpa = JSAllocator{};
        defer _ = gpa.deinit();

        var runtime = JSRuntime.init(&gpa);
        defer runtime.deinit();

        var context = try runtime.new_context();

        testing.expect(runtime.gc_obj_list.len == 1);
        testing.expect(context.header.data.ref_count == 1);
    }
}

/// A tagged union that maps JSGCObjectTypes to the objects that they point to.
const GCObject = union(JSGCObjectType) {
    JS_GC_OBJ_TYPE_JS_OBJECT: *JSObject,
    JS_GC_OBJ_TYPE_FUNCTION_BYTECODE: *JSFunctionBytecode,
    JS_GC_OBJ_TYPE_SHAPE: *JSShape,
    JS_GC_OBJ_TYPE_VAR_REF: *JSVarRef,
    JS_GC_OBJ_TYPE_ASYNC_FUNCTION: *JSAsyncFunctionData,
    JS_GC_OBJ_TYPE_JS_CONTEXT: *JSContext,
};

/// Gets the object that the given JSGCObjectHeaderNode is attached to.
/// Returns a pointer to the resulting object.
fn get_gc_object(gc: *JSGCObjectHeaderNode) GCObject {
    return switch(gc.data.gc_obj_type) {
        .JS_GC_OBJ_TYPE_JS_OBJECT => @fieldParentPtr(JSObject, "header", gc),
        .JS_GC_OBJ_TYPE_SHAPE => @fieldParentPtr(JSShape, "header", gc),
        .JS_GC_OBJ_TYPE_JS_CONTEXT => @fieldParentPtr(JSContext, "header", gc),
        .JS_GC_OBJ_TYPE_FUNCTION_BYTECODE => @fieldParentPtr(JSFunctionBytecode, "header", gc),
        .JS_GC_OBJ_TYPE_VAR_REF => @fieldParentPtr(JSVarRef, "header", gc),
        .JS_GC_OBJ_TYPE_ASYNC_FUNCTION => @fieldParentPtr(JSAsyncFunctionData, "header", gc),
    };
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