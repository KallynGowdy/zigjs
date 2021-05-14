const std = @import("std");
const testing = std.testing;

const JSClassEnum = enum(u16) {
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

    const Self = @This();

    /// Duplicates this value by incrementing the ref_count of the attached object.
    /// Returns a copy of the value.
    pub fn dupe(self: *Self, context: *JSContext) JSValue {
        if (self.get_gc_header()) |header| {
            header.data.add_ref();
        }
        return self;
    }

    /// Gets the JSGCObjectHeaderNode for the object that is referenced by the given value.
    /// Returns null if the value has no GC header.
    pub fn get_gc_header(self: *Self) ?*JSGCObjectHeader {
        return switch(value) {
            .JS_TAG_FUNCTION_BYTECODE => |bytecode| &bytecode.header,
            .JS_TAG_OBJECT => |obj| &obj.header,

            // TODO: Support refcounting on symbols and strings.
            .JS_TAG_SYMBOL => unreachable,
            .JS_TAG_STRING => unreachable,

            else => null
        };
    }
};

const JSAtom = u32;

const JSAtomEnum = enum {
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

    JS_ATOM_END,
};

/// Increments the refcount of the given atom.
fn JS_DupAtom(atom: JSAtom, context: *JSContext) JSAtom {
    if (!atom_is_const(atom)) {
        if (context.runtime.atom_hash.get(atom)) |*atomData| {
            atomData.header.ref_count += 1;
        }
    }

    return atom;
    // JSRuntime *rt;
    // JSAtomStruct *p;

    // if (!__JS_AtomIsConst(v)) {
    //     rt = ctx->rt;
    //     p = rt->atom_array[v];
    //     p->header.ref_count++;
    // }
    // return v;
}

//     enum {
//     JS_ATOM_NULL,
// #define DEF(name, str) JS_ATOM_ ## name,
// #include "quickjs-atom.h"
// #undef DEF
    
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
const JSFastArray = std.ArrayList(JSValue);

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
    header: JSGCObjectHeaderNode,
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

const JSArrayType = enum {
    FAST,
    SLOW
};

const JSArray = union(JSArrayType) {
    FAST = JSFastArray,
    SLOW = JSValue
};

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

    JS_CLASS_ARRAY: *JSArray,

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
    JS_CLASS_ARGUMENTS: JSFastArray,
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

    // class_id: u16,

    shape: *JSShape,
    properties: std.ArrayList(JSProperty),

    // TODO:
    // first_weak_ref: *JSMapRecord,

    data: JSObjectData,

    const Self = @This();

    pub fn init(allocator: *std.mem.Allocator, context: *JSContext, class_id: JSClassEnum, shape: *JSShape) !*Self {
        var self = try allocator.create(JSObject);
        errdefer allocator.destroy(self);
        self.extensible = true;
        self.free_mark = false;
        self.is_exotic = false;
        self.is_constructor = false;
        self.is_uncatchable_error = false;
        self.tmp_mark = false;
        self.shape = shape;
        self.properties = try std.ArrayList(JSProperty).init(allocator);
        errdefer self.properties.deinit();
        try self.properties.resize(shape.properties.items.len);

        // p = js_malloc(ctx, sizeof(JSObject));
        // if (unlikely(!p))
        //     goto fail;
        // p->class_id = class_id;
        // p->extensible = TRUE;
        // p->free_mark = 0;
        // p->is_exotic = 0;
        // p->fast_array = 0;
        // p->is_constructor = 0;
        // p->is_uncatchable_error = 0;
        // p->tmp_mark = 0;
        // p->first_weak_ref = NULL;
        // p->u.opaque = NULL;
        // p->shape = sh;
        // p->prop = js_malloc(ctx, sizeof(JSProperty) * sh->prop_size);
        // if (unlikely(!p->prop)) {
        //     js_free(ctx, p);
        // fail:
        //     js_free_shape(ctx->rt, sh);
        //     return JS_EXCEPTION;
        // }

        switch(class_id) {
            .JS_CLASS_OBJECT => {
                self.data = JSObjectData{
                    .JS_CLASS_OBJECT = JS_NULL
                };
            },
            .JS_CLASS_ARRAY => {
                self.is_exotic = true;
                self.data = JSObjectData{
                    .JS_CLASS_ARRAY = .{
                        .FAST = JSFastArray.init(allocator)
                    }
                };
                var prop: *JSProperty = if (shape == context.array_shape) &self.properties[0] 
                    else self.add_property(context, JSAtomEnum.JS_ATOM_length, JS_PROP_WRITABLE | JS_PROP_LENGTH);
                prop.* = .{
                    .VALUE = JS_NewInt(0)
                };
            }
        }

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

    /// Adds a new property to the current object's shape and returns a reference uninitialized JSProperty
    /// value that this object uses for data.
    /// When adding a property, the system attempts to determine if there is a shape that
    /// will match the new property and flags. If there is, then that shape is reused without modification.
    /// If not, then the shape is copied and modified.
    fn add_property(self: *Self, context: *JSContext, property: JSAtom, flags: u32) !*JSProperty {

        // var new_shape: *JSShape;
        if (self.shape.is_hashed) {
            const foundShape = context.runtime.find_shape_with_extra_property(self.shape, property, flags);
            if (foundShape) |shape| {
                // matching shape found, use it.
                
                var oldShape = self.shape;
                self.shape = shape.duplicate();
                context.runtime.free_shape(oldShape);

                return try self.properties.addOne();
            } else if(self.shape.header.data.ref_count != 1) {
                // no matching shape and the current shape is shared.
                // clone and modify the clone.
                var newShape = self.shape.
            }
        }

        self.add_shape_property(context, self.shape, property, flags);

        return &self.properties.items[self.properties.items.len - 1];
        // JSShape *sh, *new_sh;

        // sh = p->shape;
        // if (sh->is_hashed) {
        //     /* try to find an existing shape */
        //     new_sh = find_hashed_shape_prop(ctx->rt, sh, prop, prop_flags);
        //     if (new_sh) {
        //         /* matching shape found: use it */
        //         /*  the property array may need to be resized */
        //         if (new_sh->prop_size != sh->prop_size) {
        //             JSProperty *new_prop;
        //             new_prop = js_realloc(ctx, p->prop, sizeof(p->prop[0]) *
        //                                 new_sh->prop_size);
        //             if (!new_prop)
        //                 return NULL;
        //             p->prop = new_prop;
        //         }
        //         p->shape = js_dup_shape(new_sh);
        //         js_free_shape(ctx->rt, sh);
        //         return &p->prop[new_sh->prop_count - 1];
        //     } else if (sh->header.ref_count != 1) {
        //         /* if the shape is shared, clone it */
        //         new_sh = js_clone_shape(ctx, sh);
        //         if (!new_sh)
        //             return NULL;
        //         /* hash the cloned shape */
        //         new_sh->is_hashed = TRUE;
        //         js_shape_hash_link(ctx->rt, new_sh);
        //         js_free_shape(ctx->rt, p->shape);
        //         p->shape = new_sh;
        //     }
        // }
        // assert(p->shape->header.ref_count == 1);
        // if (add_shape_property(ctx, &p->shape, p, prop, prop_flags))
        //     return NULL;
        // return &p->prop[p->shape->prop_count - 1];
    }

    /// Adds a new property to the given shape and object and updates the property hashes if needed.
    /// At this point the shape can be modified safely because it is not shared.
    fn add_shape_property(self: *Self, context: *JSContext, shape: *JSShape, atom: JSAtom, flags: u32) !void {

        var new_shape_hash: u32 = 0;
        if (shape.is_hashed) {
            context.runtime.remove_shape(shape);
            new_shape_hash = shape_hash(
                shape_hash(shape.hash, atom),
                flags
            );
        }

        var new_prop = self.properties.addOne() catch |err| {
            if(shape.is_hashed){
                // if we are unable to add a new property,
                // try to add the shape back into the hash table.
                try context.runtime.add_shape(shape);
            }
            return err;
        };

        var shape_prop = shape.properties.addOne() catch |err| {
            if (shape.is_hashed){
                // if we are unable to add a new property,
                // try to add the shape back into the hash table.
                try context.runtime.add_shape(shape);
            }
            return err;
        };

        if (shape.is_hashed) {
            try context.runtime.add_shape(shape);
        }

        // JSRuntime *rt = ctx->rt;
        // JSShape *sh = *psh;
        // JSShapeProperty *pr, *prop;
        // uint32_t hash_mask, new_shape_hash = 0;
        // intptr_t h;

        // /* update the shape hash */
        // if (sh->is_hashed) {
        //     js_shape_hash_unlink(rt, sh);
        //     new_shape_hash = shape_hash(shape_hash(sh->hash, atom), prop_flags);
        // }

        // if (unlikely(sh->prop_count >= sh->prop_size)) {
        //     if (resize_properties(ctx, psh, p, sh->prop_count + 1)) {
        //         /* in case of error, reinsert in the hash table.
        //         sh is still valid if resize_properties() failed */
        //         if (sh->is_hashed)
        //             js_shape_hash_link(rt, sh);
        //         return -1;
        //     }
        //     sh = *psh;
        // }
        // if (sh->is_hashed) {
        //     sh->hash = new_shape_hash;
        //     js_shape_hash_link(rt, sh);
        // }
        // /* Initialize the new shape property.
        // The object property at p->prop[sh->prop_count] is uninitialized */
        // prop = get_shape_prop(sh);
        // pr = &prop[sh->prop_count++];
        // pr->atom = JS_DupAtom(ctx, atom);
        // pr->flags = prop_flags;
        // sh->has_small_array_index |= __JS_AtomIsTaggedInt(atom);
        // /* add in hash table */
        // hash_mask = sh->prop_hash_mask;
        // h = atom & hash_mask;
        // pr->hash_next = sh->prop_hash_end[-h - 1];
        // sh->prop_hash_end[-h - 1] = sh->prop_count;
        // return 0;
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
    // records: std.TailQueue(JSMapRecord)
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



const JSOpCodeFormat = enum {
    none,
    none_int,
    none_loc,
    none_arg,
    none_var_ref,
    _u8,
    _i8,
    loc8,
    const8,
    label8,
    _u16,
    _i16,
    label16,
    npop,
    npopx,
    npop_u16,
    loc,
    arg,
    var_ref,
    _u32,
    _i32,
    _const,
    label,
    atom,
    atom_u8,
    atom_u16,
    atom_label_u8,
    atom_label_u16,
    label_u16,
};

const JSOpCode = struct {
    name: []const u8,

    /// in bytes
    size: u8,

    /// the opcodes remove n_pop items from the top of the stack
    /// then pushes n_push items
    n_pop: u8,
    n_push: u8,
    fmt: JSOpCodeFormat,

    const Self = @This();
    fn init(name: []const u8, size: u8, n_pop: u8, n_push: u8, fmt: JSOpCodeFormat) Self {
        return Self {
            .name = name,
            .size = size,
            .n_pop = n_pop,
            .n_push = n_push,
            .fmt = fmt
        };
    }

// #ifdef DUMP_BYTECODE
//     const char *name;
// #endif
//     uint8_t size; /* in bytes */
//     /* the opcodes remove n_pop items from the top of the stack, then
//        pushes n_push items */
//     uint8_t n_pop;
//     uint8_t n_push;
//     uint8_t fmt;
};

fn generate_op_code_enum(comptime opcodes: []const JSOpCode) type {
    var fields: [opcodes.len] std.builtin.TypeInfo.EnumField = undefined;
    for(fields) |*field, i| {
        const op = opcodes[i];
        field.* = .{
            .name = "OP_" ++ op.name,
            .value = i
        };
    }
    return @Type(.{
        .Enum = .{
            .tag_type = u16,
            .is_exhaustive = true,
            .layout = .Auto,
            .fields = &fields,
            .decls = &[0]std.builtin.TypeInfo.Declaration {},
        }
    });
}

const OpCodeEnum = generate_op_code_enum(&opcode_info);

const OP_COUNT: u16 = @enumToInt(OpCodeEnum.OP_nop);
const OP_TEMP_START: u16 = OP_COUNT + 1;
const OP_TEMP_END: u16 = @enumToInt(OpCodeEnum.OP_is_function) + 1;

const opcode_info = [_]JSOpCode{
    //* never emitted */
    JSOpCode.init("invalid", 1, 0, 0, .none) ,

    // /* push values */
    JSOpCode.init(       "push_i32", 5, 0, 1, ._i32),
    JSOpCode.init(     "push_const", 5, 0, 1, ._const),
    //* must follow push_const */
    JSOpCode.init(       "fclosure", 5, 0, 1, ._const) ,
    JSOpCode.init("push_atom_value", 5, 0, 1, .atom),
    JSOpCode.init( "private_symbol", 5, 0, 1, .atom),
    JSOpCode.init(      "undefined", 1, 0, 1, .none),
    JSOpCode.init(           "null", 1, 0, 1, .none),

    //* only used at the start of a function */
    JSOpCode.init(      "push_this", 1, 0, 1, .none),
    JSOpCode.init(     "push_false", 1, 0, 1, .none),
    JSOpCode.init(      "push_true", 1, 0, 1, .none),
    JSOpCode.init(         "object", 1, 0, 1, .none),
    //* only used at the start of a function */
    JSOpCode.init( "special_object", 2, 0, 1, ._u8),
    //* only used at the start of a function */
    JSOpCode.init(           "rest", 3, 0, 1, ._u16),

    //* a -> */
    JSOpCode.init(           "drop", 1, 1, 0, .none),
    //* a b -> b */
    JSOpCode.init(            "nip", 1, 2, 1, .none),
    //* a b c -> b c */ 
    JSOpCode.init(           "nip1", 1, 3, 2, .none),
    //* a -> a a */
    JSOpCode.init(            "dup", 1, 1, 2, .none),
    //* a b -> a a b */
    JSOpCode.init(           "dup1", 1, 2, 3, .none),
    //* a b -> a b a b */ 
    JSOpCode.init(           "dup2", 1, 2, 4, .none),
    //* a b c -> a b c a b c */
    JSOpCode.init(           "dup3", 1, 3, 6, .none) ,
    //* obj a -> a obj a (dup_x1) */
    JSOpCode.init(        "insert2", 1, 2, 3, .none) ,
    //* obj prop a -> a obj prop a (dup_x2) */
    JSOpCode.init(        "insert3", 1, 3, 4, .none) ,
    //* this obj prop a -> a this obj prop a */
    JSOpCode.init(        "insert4", 1, 4, 5, .none) ,
    //* obj a b -> a obj b */
    JSOpCode.init(          "perm3", 1, 3, 3, .none) ,
    //* obj prop a b -> a obj prop b */
    JSOpCode.init(          "perm4", 1, 4, 4, .none) ,
    //* this obj prop a b -> a this obj prop b */
    JSOpCode.init(          "perm5", 1, 5, 5, .none) ,
    //* a b -> b a */
    JSOpCode.init(           "swap", 1, 2, 2, .none) ,
    //* a b c d -> c d a b */
    JSOpCode.init(          "swap2", 1, 4, 4, .none) ,
    //* x a b -> a b x */
    JSOpCode.init(          "rot3l", 1, 3, 3, .none) ,
    //* a b x -> x a b */
    JSOpCode.init(          "rot3r", 1, 3, 3, .none) ,
    //* x a b c -> a b c x */
    JSOpCode.init(          "rot4l", 1, 4, 4, .none) ,
    //* x a b c d -> a b c d x */
    JSOpCode.init(          "rot5l", 1, 5, 5, .none) ,

    //* func new.target args -> ret. arguments are not counted in n_pop */
    JSOpCode.init("call_constructor", 3, 2, 1, .npop) ,
    //* arguments are not counted in n_pop */
    JSOpCode.init(           "call", 3, 1, 1, .npop) ,
    //* arguments are not counted in n_pop */
    JSOpCode.init(      "tail_call", 3, 1, 0, .npop) ,
    //* arguments are not counted in n_pop */
    JSOpCode.init(    "call_method", 3, 2, 1, .npop) ,
    //* arguments are not counted in n_pop */
    JSOpCode.init("tail_call_method", 3, 2, 0, .npop) ,
    //* arguments are not counted in n_pop */
    JSOpCode.init(     "array_from", 3, 0, 1, .npop) ,
    JSOpCode.init(          "apply", 3, 3, 1, ._u16),
    JSOpCode.init(         "return", 1, 1, 0, .none),
    JSOpCode.init(   "return_undef", 1, 0, 0, .none),
    JSOpCode.init("check_ctor_return", 1, 1, 2, .none),
    JSOpCode.init(     "check_ctor", 1, 0, 0, .none),
    //* this_obj func -> this_obj func */
    JSOpCode.init(    "check_brand", 1, 2, 2, .none) ,
    //* this_obj home_obj -> */
    JSOpCode.init(      "add_brand", 1, 2, 0, .none) ,
    JSOpCode.init(   "return_async", 1, 1, 0, .none),
    JSOpCode.init(          "throw", 1, 1, 0, .none),
    JSOpCode.init(      "throw_var", 6, 0, 0, .atom_u8),
    //* func args... -> ret_val */
    JSOpCode.init(           "eval", 5, 1, 1, .npop_u16) ,
    //* func array -> ret_eval */
    JSOpCode.init(     "apply_eval", 3, 2, 1, ._u16) ,
    //* create a RegExp object from the pattern and a
    JSOpCode.init(         "regexp", 1, 2, 1, .none) ,
    // bytecode string */
    JSOpCode.init(      "get_super", 1, 1, 1, .none),
    //* dynamic module import */
    JSOpCode.init(         "import", 1, 1, 1, .none) ,

    //* check if a variable exists */
    JSOpCode.init(      "check_var", 5, 0, 1, .atom) ,
    //* push undefined if the variable does not exist */
    JSOpCode.init(  "get_var_undef", 5, 0, 1, .atom) ,
    //* throw an exception if the variable does not exist */
    JSOpCode.init(        "get_var", 5, 0, 1, .atom) ,
    //* must come after get_var */
    JSOpCode.init(        "put_var", 5, 1, 0, .atom) ,
    //* must come after put_var. Used to initialize a global lexical variable */
    JSOpCode.init(   "put_var_init", 5, 1, 0, .atom) ,
    //* for strict mode variable write */
    JSOpCode.init( "put_var_strict", 5, 2, 0, .atom) ,

    JSOpCode.init(  "get_ref_value", 1, 2, 3, .none),
    JSOpCode.init(  "put_ref_value", 1, 3, 0, .none),

    JSOpCode.init(     "define_var", 6, 0, 0, .atom_u8),
    JSOpCode.init("check_define_var", 6, 0, 0, .atom_u8),
    JSOpCode.init(    "define_func", 6, 1, 0, .atom_u8),
    JSOpCode.init(      "get_field", 5, 1, 1, .atom),
    JSOpCode.init(     "get_field2", 5, 1, 2, .atom),
    JSOpCode.init(      "put_field", 5, 2, 0, .atom),
    //* obj prop -> value */
    JSOpCode.init( "get_private_field", 1, 2, 1, .none) ,
    //* obj value prop -> */
    JSOpCode.init( "put_private_field", 1, 3, 0, .none) ,
    //* obj prop value -> obj */
    JSOpCode.init("define_private_field", 1, 3, 1, .none) ,
    JSOpCode.init(   "get_array_el", 1, 2, 1, .none),
    //* obj prop -> obj value */
    JSOpCode.init(  "get_array_el2", 1, 2, 2, .none) ,
    JSOpCode.init(   "put_array_el", 1, 3, 0, .none),
    //* this obj prop -> value */
    JSOpCode.init("get_super_value", 1, 3, 1, .none) ,
    //* this obj prop value -> */
    JSOpCode.init("put_super_value", 1, 4, 0, .none) ,
    JSOpCode.init(   "define_field", 5, 2, 1, .atom),
    JSOpCode.init(       "set_name", 5, 1, 1, .atom),
    JSOpCode.init("set_name_computed", 1, 2, 2, .none),
    JSOpCode.init(      "set_proto", 1, 2, 1, .none),
    JSOpCode.init("set_home_object", 1, 2, 2, .none),
    JSOpCode.init("define_array_el", 1, 3, 2, .none),
    //* append enumerated object, update length */
    JSOpCode.init(         "append", 1, 3, 2, .none) ,
    JSOpCode.init("copy_data_properties", 2, 3, 3, ._u8),
    JSOpCode.init(  "define_method", 6, 2, 1, .atom_u8),
    //* must come after define_method */
    JSOpCode.init("define_method_computed", 2, 3, 1, ._u8) ,
    //* parent ctor -> ctor proto */
    JSOpCode.init(   "define_class", 6, 2, 2, .atom_u8) ,
    //* field_name parent ctor -> field_name ctor proto (class with computed name) */
    JSOpCode.init(   "define_class_computed", 6, 3, 3, .atom_u8) ,

    JSOpCode.init(        "get_loc", 3, 0, 1, .loc),
    //* must come after get_loc */
    JSOpCode.init(        "put_loc", 3, 1, 0, .loc) ,
    //* must come after put_loc */
    JSOpCode.init(        "set_loc", 3, 1, 1, .loc) ,
    JSOpCode.init(        "get_arg", 3, 0, 1, .arg),
    //* must come after get_arg */
    JSOpCode.init(        "put_arg", 3, 1, 0, .arg) ,
    //* must come after put_arg */
    JSOpCode.init(        "set_arg", 3, 1, 1, .arg) ,
    JSOpCode.init(    "get_var_ref", 3, 0, 1, .var_ref) ,
    //* must come after get_var_ref */
    JSOpCode.init(    "put_var_ref", 3, 1, 0, .var_ref) ,
    //* must come after put_var_ref */
    JSOpCode.init(    "set_var_ref", 3, 1, 1, .var_ref) ,
    JSOpCode.init("set_loc_uninitialized", 3, 0, 0, .loc),
    JSOpCode.init(  "get_loc_check", 3, 0, 1, .loc),
    //* must come after get_loc_check */
    JSOpCode.init(  "put_loc_check", 3, 1, 0, .loc) ,
    JSOpCode.init(  "put_loc_check_init", 3, 1, 0, .loc),
    JSOpCode.init("get_var_ref_check", 3, 0, 1, .var_ref) ,
    //* must come after get_var_ref_check */
    JSOpCode.init("put_var_ref_check", 3, 1, 0, .var_ref) ,
    JSOpCode.init("put_var_ref_check_init", 3, 1, 0, .var_ref),
    JSOpCode.init(      "close_loc", 3, 0, 0, .loc),
    JSOpCode.init(       "if_false", 5, 1, 0, .label),
    //* must come after if_false */
    JSOpCode.init(        "if_true", 5, 1, 0, .label) ,
    //* must come after if_true */
    JSOpCode.init(           "goto", 5, 0, 0, .label) ,
    JSOpCode.init(          "catch", 5, 0, 1, .label),
    //* used to execute the finally block */
    JSOpCode.init(          "gosub", 5, 0, 0, .label) ,
    //* used to return from the finally block */
    JSOpCode.init(            "ret", 1, 1, 0, .none) ,

    JSOpCode.init(      "to_object", 1, 1, 1, .none),
    //JSOpCode.init(      "to_string", 1, 1, 1, .none),
    JSOpCode.init(     "to_propkey", 1, 1, 1, .none),
    JSOpCode.init(    "to_propkey2", 1, 2, 2, .none),

    //* must be in the same order as scope_xxx */
    JSOpCode.init(   "with_get_var", 10, 1, 0, .atom_label_u8)     ,
    //* must be in the same order as scope_xxx */
    JSOpCode.init(   "with_put_var", 10, 2, 1, .atom_label_u8)     ,
    //* must be in the same order as scope_xxx */
    JSOpCode.init("with_delete_var", 10, 1, 0, .atom_label_u8)     ,
    //* must be in the same order as scope_xxx */
    JSOpCode.init(  "with_make_ref", 10, 1, 0, .atom_label_u8)     ,
    //* must be in the same order as scope_xxx */
    JSOpCode.init(   "with_get_ref", 10, 1, 0, .atom_label_u8)     ,
    JSOpCode.init("with_get_ref_undef", 10, 1, 0, .atom_label_u8),

    JSOpCode.init(   "make_loc_ref", 7, 0, 2, .atom_u16),
    JSOpCode.init(   "make_arg_ref", 7, 0, 2, .atom_u16),
    JSOpCode.init("make_var_ref_ref", 7, 0, 2, .atom_u16),
    JSOpCode.init(   "make_var_ref", 5, 0, 2, .atom),

    JSOpCode.init(   "for_in_start", 1, 1, 1, .none),
    JSOpCode.init(   "for_of_start", 1, 1, 3, .none),
    JSOpCode.init("for_await_of_start", 1, 1, 3, .none),
    JSOpCode.init(    "for_in_next", 1, 1, 3, .none),
    JSOpCode.init(    "for_of_next", 2, 3, 5, ._u8),
    JSOpCode.init("for_await_of_next", 1, 3, 4, .none),
    JSOpCode.init("iterator_get_value_done", 1, 1, 2, .none),
    JSOpCode.init( "iterator_close", 1, 3, 0, .none),
    JSOpCode.init("iterator_close_return", 1, 4, 4, .none),
    JSOpCode.init("async_iterator_close", 1, 3, 2, .none),
    JSOpCode.init("async_iterator_next", 1, 4, 4, .none),
    JSOpCode.init("async_iterator_get", 2, 4, 5, ._u8),
    JSOpCode.init(  "initial_yield", 1, 0, 0, .none),
    JSOpCode.init(          "yield", 1, 1, 2, .none),
    JSOpCode.init(     "yield_star", 1, 2, 2, .none),
    JSOpCode.init("async_yield_star", 1, 1, 2, .none),
    JSOpCode.init(          "await", 1, 1, 1, .none),

    //* arithmetic/logic operations */
    JSOpCode.init(            "neg", 1, 1, 1, .none),
    JSOpCode.init(           "plus", 1, 1, 1, .none),
    JSOpCode.init(            "dec", 1, 1, 1, .none),
    JSOpCode.init(            "inc", 1, 1, 1, .none),
    JSOpCode.init(       "post_dec", 1, 1, 2, .none),
    JSOpCode.init(       "post_inc", 1, 1, 2, .none),
    JSOpCode.init(        "dec_loc", 2, 0, 0, .loc8),
    JSOpCode.init(        "inc_loc", 2, 0, 0, .loc8),
    JSOpCode.init(        "add_loc", 2, 1, 0, .loc8),
    JSOpCode.init(            "not", 1, 1, 1, .none),
    JSOpCode.init(           "lnot", 1, 1, 1, .none),
    JSOpCode.init(         "typeof", 1, 1, 1, .none),
    JSOpCode.init(         "delete", 1, 2, 1, .none),
    JSOpCode.init(     "delete_var", 5, 0, 1, .atom),

    JSOpCode.init(            "mul", 1, 2, 1, .none),
    JSOpCode.init(            "div", 1, 2, 1, .none),
    JSOpCode.init(            "mod", 1, 2, 1, .none),
    JSOpCode.init(            "add", 1, 2, 1, .none),
    JSOpCode.init(            "sub", 1, 2, 1, .none),
    JSOpCode.init(            "pow", 1, 2, 1, .none),
    JSOpCode.init(            "shl", 1, 2, 1, .none),
    JSOpCode.init(            "sar", 1, 2, 1, .none),
    JSOpCode.init(            "shr", 1, 2, 1, .none),
    JSOpCode.init(             "lt", 1, 2, 1, .none),
    JSOpCode.init(            "lte", 1, 2, 1, .none),
    JSOpCode.init(             "gt", 1, 2, 1, .none),
    JSOpCode.init(            "gte", 1, 2, 1, .none),
    JSOpCode.init(     "instanceof", 1, 2, 1, .none),
    JSOpCode.init(             "in", 1, 2, 1, .none),
    JSOpCode.init(             "eq", 1, 2, 1, .none),
    JSOpCode.init(            "neq", 1, 2, 1, .none),
    JSOpCode.init(      "strict_eq", 1, 2, 1, .none),
    JSOpCode.init(     "strict_neq", 1, 2, 1, .none),
    JSOpCode.init(            "and", 1, 2, 1, .none),
    JSOpCode.init(            "xor", 1, 2, 1, .none),
    JSOpCode.init(             "or", 1, 2, 1, .none),
    JSOpCode.init("is_undefined_or_null", 1, 1, 1, .none),

    // TODO: Support bignum
    // #ifdef CONFIG_BIGNUM
    // JSOpCode.init(      "mul_pow10", 1, 2, 1, .none),
    // JSOpCode.init(       "math_mod", 1, 2, 1, .none),
    // #endif
    //* must be the last non short and non temporary opcode */
    JSOpCode.init(            "nop", 1, 0, 0, .none) ,

    //* temporary opcodes: never emitted in the final bytecode */

    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init("set_arg_valid_upto", 3, 0, 0, .arg) ,

    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init(    "enter_scope", 3, 0, 0, ._u16)  ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init(    "leave_scope", 3, 0, 0, ._u16)  ,

    //* emitted in phase 1, removed in phase 3 */
    JSOpCode.init(          ".label", 5, 0, 0, .label) ,

    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init("scope_get_var_undef", 7, 0, 1, .atom_u16) ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init(  "scope_get_var", 7, 0, 1, .atom_u16) ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init(  "scope_put_var", 7, 1, 0, .atom_u16) ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init("scope_delete_var", 7, 0, 1, .atom_u16) ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init( "scope_make_ref", 11, 0, 2, .atom_label_u16) ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init(  "scope_get_ref", 7, 0, 2, .atom_u16) ,
    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init("scope_put_var_init", 7, 0, 2, .atom_u16) ,
    //* obj -> value, emitted in phase 1, removed in phase 2 */
    JSOpCode.init("scope_get_private_field", 7, 1, 1, .atom_u16) ,
    //* obj -> obj value, emitted in phase 1, removed in phase 2 */
    JSOpCode.init("scope_get_private_field2", 7, 1, 2, .atom_u16) ,
    //* obj value ->, emitted in phase 1, removed in phase 2 */
    JSOpCode.init("scope_put_private_field", 7, 1, 1, .atom_u16) ,

    //* emitted in phase 1, removed in phase 2 */
    JSOpCode.init( "set_class_name", 5, 1, 1, ._u32) ,
        
    //* emitted in phase 1, removed in phase 3 */
    JSOpCode.init(       "line_num", 5, 0, 0, ._u32) ,

    // #if SHORT_OPCODES
    JSOpCode.init(    "push_minus1", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_0", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_1", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_2", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_3", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_4", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_5", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_6", 1, 0, 1, .none_int),
    JSOpCode.init(         "push_7", 1, 0, 1, .none_int),
    JSOpCode.init(        "push_i8", 2, 0, 1, ._i8),
    JSOpCode.init(       "push_i16", 3, 0, 1, ._i16),
    JSOpCode.init(    "push_const8", 2, 0, 1, .const8),
    //* must follow push_const8 */
    JSOpCode.init(      "fclosure8", 2, 0, 1, .const8) ,
    JSOpCode.init("push_empty_string", 1, 0, 1, .none),

    JSOpCode.init(       "get_loc8", 2, 0, 1, .loc8),
    JSOpCode.init(       "put_loc8", 2, 1, 0, .loc8),
    JSOpCode.init(       "set_loc8", 2, 1, 1, .loc8),

    JSOpCode.init(       "get_loc0", 1, 0, 1, .none_loc),
    JSOpCode.init(       "get_loc1", 1, 0, 1, .none_loc),
    JSOpCode.init(       "get_loc2", 1, 0, 1, .none_loc),
    JSOpCode.init(       "get_loc3", 1, 0, 1, .none_loc),
    JSOpCode.init(       "put_loc0", 1, 1, 0, .none_loc),
    JSOpCode.init(       "put_loc1", 1, 1, 0, .none_loc),
    JSOpCode.init(       "put_loc2", 1, 1, 0, .none_loc),
    JSOpCode.init(       "put_loc3", 1, 1, 0, .none_loc),
    JSOpCode.init(       "set_loc0", 1, 1, 1, .none_loc),
    JSOpCode.init(       "set_loc1", 1, 1, 1, .none_loc),
    JSOpCode.init(       "set_loc2", 1, 1, 1, .none_loc),
    JSOpCode.init(       "set_loc3", 1, 1, 1, .none_loc),
    JSOpCode.init(       "get_arg0", 1, 0, 1, .none_arg),
    JSOpCode.init(       "get_arg1", 1, 0, 1, .none_arg),
    JSOpCode.init(       "get_arg2", 1, 0, 1, .none_arg),
    JSOpCode.init(       "get_arg3", 1, 0, 1, .none_arg),
    JSOpCode.init(       "put_arg0", 1, 1, 0, .none_arg),
    JSOpCode.init(       "put_arg1", 1, 1, 0, .none_arg),
    JSOpCode.init(       "put_arg2", 1, 1, 0, .none_arg),
    JSOpCode.init(       "put_arg3", 1, 1, 0, .none_arg),
    JSOpCode.init(       "set_arg0", 1, 1, 1, .none_arg),
    JSOpCode.init(       "set_arg1", 1, 1, 1, .none_arg),
    JSOpCode.init(       "set_arg2", 1, 1, 1, .none_arg),
    JSOpCode.init(       "set_arg3", 1, 1, 1, .none_arg),
    JSOpCode.init(   "get_var_ref0", 1, 0, 1, .none_var_ref),
    JSOpCode.init(   "get_var_ref1", 1, 0, 1, .none_var_ref),
    JSOpCode.init(   "get_var_ref2", 1, 0, 1, .none_var_ref),
    JSOpCode.init(   "get_var_ref3", 1, 0, 1, .none_var_ref),
    JSOpCode.init(   "put_var_ref0", 1, 1, 0, .none_var_ref),
    JSOpCode.init(   "put_var_ref1", 1, 1, 0, .none_var_ref),
    JSOpCode.init(   "put_var_ref2", 1, 1, 0, .none_var_ref),
    JSOpCode.init(   "put_var_ref3", 1, 1, 0, .none_var_ref),
    JSOpCode.init(   "set_var_ref0", 1, 1, 1, .none_var_ref),
    JSOpCode.init(   "set_var_ref1", 1, 1, 1, .none_var_ref),
    JSOpCode.init(   "set_var_ref2", 1, 1, 1, .none_var_ref),
    JSOpCode.init(   "set_var_ref3", 1, 1, 1, .none_var_ref),

    JSOpCode.init(     "get_length", 1, 1, 1, .none),

    JSOpCode.init(      "if_false8", 2, 1, 0, .label8),
    //* must come after if_false8 */
    JSOpCode.init(       "if_true8", 2, 1, 0, .label8) ,
    //* must come after if_true8 */
    JSOpCode.init(          "goto8", 2, 0, 0, .label8) ,
    JSOpCode.init(         "goto16", 3, 0, 0, .label16),

    JSOpCode.init(          "call0", 1, 1, 1, .npopx),
    JSOpCode.init(          "call1", 1, 1, 1, .npopx),
    JSOpCode.init(          "call2", 1, 1, 1, .npopx),
    JSOpCode.init(          "call3", 1, 1, 1, .npopx),

    JSOpCode.init(   "is_undefined", 1, 1, 1, .none),
    JSOpCode.init(        "is_null", 1, 1, 1, .none),
    JSOpCode.init(    "is_function", 1, 1, 1, .none),
};

// static const JSOpCode opcode_info[OP_COUNT + (OP_TEMP_END - OP_TEMP_START)] = {
// #define FMT(f)
// #define DEF(id, size, n_pop, n_push, f) { size, n_pop, n_push, OP_FMT_ ## f },
// #include "quickjs-opcode.h"
// #undef DEF
// #undef FMT
// };

fn short_opcode_info(op: u8) JSOpCode {
    return opcode_info[if (op >= OP_TEMP_START) op + OP_TEMP_END - OP_TEMP_START else op];

    // opcode_info[(op) >= OP_TEMP_START ? \
    //             (op) + (OP_TEMP_END - OP_TEMP_START) : (op)]
}

const AtomType = enum(u4) {
    JS_ATOM_TYPE_STRING = 1,
    JS_ATOM_TYPE_GLOBAL_SYMBOL = 2,
    JS_ATOM_TYPE_SYMBOL = 3,
    JS_ATOM_TYPE_PRIVATE = 4,
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
    val: JSStringValue,
    atom_type: AtomType
};

const JSAtomStruct = JSString;

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

const JSVarKindEnum = enum {

    JS_VAR_NORMAL,

    /// Lexical var with function declaration
    JS_VAR_FUNCTION_DECL,

    /// lexical var with async/generator
    /// function declaration
    JS_VAR_NEW_FUNCTION_DECL,

    JS_VAR_CATCH,
    JS_VAR_PRIVATE_FIELD,
    JS_VAR_PRIVATE_METHOD,
    JS_VAR_PRIVATE_GETTER,

    // must come after JS_VAR_PRIVATE_GETTER
    JS_VAR_PRIVATE_SETTER,

    // must come after JS_VAR_PRIVATE_SETTER
    JS_VAR_PRIVATE_GETTER_SETTER,

    // /* XXX: add more variable kinds here instead of using bit fields */
    // JS_VAR_NORMAL,
    // JS_VAR_FUNCTION_DECL, /* lexical var with function declaration */
    // JS_VAR_NEW_FUNCTION_DECL, /* lexical var with async/generator
    //                              function declaration */
    // JS_VAR_CATCH,
    // JS_VAR_PRIVATE_FIELD,
    // JS_VAR_PRIVATE_METHOD,
    // JS_VAR_PRIVATE_GETTER,
    // JS_VAR_PRIVATE_SETTER, /* must come after JS_VAR_PRIVATE_GETTER */
    // JS_VAR_PRIVATE_GETTER_SETTER, /* must come after JS_VAR_PRIVATE_SETTER */
};

const JSVarDef = struct {
    var_name: JSAtom,

    /// Index into fd.scopes of this variable
    /// lexical scope
    scope_level: u32,

    /// index into fd.vars of the next variable in the same
    /// or enclosing lexical scope
    scope_next: u32,

    /// ised for the function self reference
    is_func_var: bool,

    is_const: bool,
    is_lexical: bool,
    is_captured: bool,
    var_kind: JSVarKindEnum,

    /// only used during compilation: function pool index for lexical variables
    /// with var_kind == .JS_VAR_FUNCTION_DECL or .JS_VAR_NEW_FUNCTION_DECL or scope level
    /// of the definition of the 'var' variables (they have scope_level == 0)
    func_pool_or_scope_idx: u32,

    // JSAtom var_name;
    // int scope_level;   /* index into fd->scopes of this variable lexical scope */
    // int scope_next;    /* index into fd->vars of the next variable in the
    //                     * same or enclosing lexical scope */
    // uint8_t is_func_var : 1; /* used for the function self reference */
    // uint8_t is_const : 1;
    // uint8_t is_lexical : 1;
    // uint8_t is_captured : 1;
    // uint8_t var_kind : 4; /* see JSVarKindEnum */
    // /* only used during compilation: function pool index for lexical
    //    variables with var_kind =
    //    JS_VAR_FUNCTION_DECL/JS_VAR_NEW_FUNCTION_DECL or scope level of
    //    the definition of the 'var' variables (they have scope_level =
    //    0) */
    // int func_pool_or_scope_idx : 24; /* only used during compilation */
};

const JSClosureVar = struct {
    is_local: bool,
    is_arg: bool,
    is_const: bool,
    is_lexical: bool,
    var_kind: JSVarKindEnum,

    /// is_local == true: index to a normal variable of the parent function.
    /// else: index to a closure variable of the parent function.
    var_idx: u16,
    var_name: JSAtom,

    // uint8_t is_local : 1;
    // uint8_t is_arg : 1;
    // uint8_t is_const : 1;
    // uint8_t is_lexical : 1;
    // uint8_t var_kind : 3; /* see JSVarKindEnum */
    // /* 9 bits available */
    // uint16_t var_idx; /* is_local = TRUE: index to a normal variable of the
    //                 parent function. otherwise: index to a closure
    //                 variable of the parent function */
    // JSAtom var_name;
};

const JSFunctionBytecode = struct {
    header: JSGCObjectHeaderNode,
    js_mode: u8,

    /// true if a prototype field is necessary
    has_prototype: bool,
    
    has_simple_parameter_list: bool,
    is_derived_class_constructor: bool,

    /// true if home_object needs to be initialized
    need_home_object: bool,
    func_kind: u2,
    new_target_allowed: bool,
    super_call_allowed: bool,
    super_allowed: bool,
    arguments_allowed: bool,
    has_debug: bool,

    /// stop backtrace on this function
    backtrace_barrier: bool,
    read_only_bytecode: bool,

    byte_code_buf: []u8,
    func_name: JSAtom,

    /// arguments + local variables (arg_count + var_count)
    vardefs: []JSVarDef,
    /// list of variables in the closure
    closure_var: []JSClosureVar,

    arg_count: u16,
    var_count: u16,
    /// for the function.length property
    defined_arg_count: u16,

    /// maximum stack size
    stack_size: u16,

    /// function realm
    realm: *JSContext,

    // constant pool
    cpool: []JSValue,

    // JSGCObjectHeader header; /* must come first */
    // uint8_t js_mode;
    // uint8_t has_prototype : 1; /* true if a prototype field is necessary */
    // uint8_t has_simple_parameter_list : 1;
    // uint8_t is_derived_class_constructor : 1;
    // /* true if home_object needs to be initialized */
    // uint8_t need_home_object : 1;
    // uint8_t func_kind : 2;
    // uint8_t new_target_allowed : 1;
    // uint8_t super_call_allowed : 1;
    // uint8_t super_allowed : 1;
    // uint8_t arguments_allowed : 1;
    // uint8_t has_debug : 1;
    // uint8_t backtrace_barrier : 1; /* stop backtrace on this function */
    // uint8_t read_only_bytecode : 1;
    // /* XXX: 4 bits available */
    // uint8_t *byte_code_buf; /* (self pointer) */
    // int byte_code_len;
    // JSAtom func_name;
    // JSVarDef *vardefs; /* arguments + local variables (arg_count + var_count) (self pointer) */
    // JSClosureVar *closure_var; /* list of variables in the closure (self pointer) */
    // uint16_t arg_count;
    // uint16_t var_count;
    // uint16_t defined_arg_count; /* for length function property */
    // uint16_t stack_size; /* maximum stack size */
    // JSContext *realm; /* function realm */
    // JSValue *cpool; /* constant pool (self pointer) */
    // int cpool_count;
    // int closure_var_count;

    // TODO: Add debugger stuff
    // struct {
    //     /* debug info, move to separate structure to save memory? */
    //     JSAtom filename;
    //     int line_num;
    //     int source_len;
    //     int pc2line_len;
    //     uint8_t *pc2line_buf;
    //     char *source;
    // } debug;
    // struct JSDebuggerFunctionInfo debugger;
};

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

// #define JS_VALUE_HAS_REF_COUNT(v) ((unsigned)JS_VALUE_GET_TAG(v) >= (unsigned)JS_TAG_FIRST)

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

// fn JS_VALUE_HAS_REF_COUNT(value: JSValue) bool {
//     return switch(value) {
//         .JS_TAG_OBJECT,
//         .JS_TAG_STRING,
//         .JS_TAG_SYMBOL,
//         .JS_TAG_MODULE,
//         .JS_TAG_FUNCTION_BYTECODE => true,
//         else => false
//     };
// }

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
    finalizer: ?JSClassFinalizer,
    gc_mark: ?JSClassGCMark,
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

const JSHashedProperties = std.AutoArrayHashMap(JSAtom, JSValue);

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
    // prop_hash_mask: u32,

    /// includes deleted properties
    deleted_prop_count: u32,

    proto: ?*JSObject,
    properties: std.ArrayList(JSShapeProperty),

    prop_hash: JSHashedProperties,

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
        // self.prop_hash_mask = hash_size - 1;
        self.deleted_prop_count = 0;
        self.properties = try std.ArrayList(JSShapeProperty).initCapacity(&ctx.runtime.allocator.allocator, prop_size);
        self.prop_hash = JSHashedProperties.init(&ctx.runtime.allocator.allocator);
        errdefer self.prop_hash.deinit();
        try self.prop_hash.ensureCapacity(prop_size);
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

    /// Clones this shape
    pub fn clone(self: *Self, context: *JSContext) !*JSShape {
        var newShape = try Self.initFromProtoWithSizes(context, self.proto, 0, self.properties.items.len);
        newShape.header.data.ref_count = 1;
        newShape.deleted_prop_count = self.deleted_prop_count;
        newShape.hash = self.hash;
        newShape.is_hashed = false;
        newShape.has_small_array_index = self.has_small_array_index;

        newShape.properties.appendSliceAssumeCapacity(self.properties.items);

        for (self.prop_hash.items()) |item| {
            newShape.prop_hash.putAssumeCapacity(item.key, item.value);
        }

        for(newShape.properties.items) |*item| {
            JS_DupAtom(item.atom, context);
        }
        // for(newShape.)


        // var newShape = try context.runtime.allocator.allocator.create(JSShape);
        // newShape.* = self.*;

        // newShape.header.next = null;
        // newShape.header.prev = null;
        // newShape.header.data.ref_count = 1;
        // newShape.header.data.gc_obj_type = .JS_GC_OBJ_TYPE_SHAPE;
        // context.runtime.add_gc_obj(&newShape.header);
        // newShape.is_hashed = false;
        // if (newShape.proto) |proto| {

        // }

        // for()

        // if(newShape.)

        // JSShape *sh;
        // void *sh_alloc, *sh_alloc1;
        // size_t size;
        // JSShapeProperty *pr;
        // uint32_t i, hash_size;

        // hash_size = sh1->prop_hash_mask + 1;
        // size = get_shape_size(hash_size, sh1->prop_size);
        // sh_alloc = js_malloc(ctx, size);
        // if (!sh_alloc)
        //     return NULL;
        // sh_alloc1 = get_alloc_from_shape(sh1);
        // memcpy(sh_alloc, sh_alloc1, size);
        // sh = get_shape_from_alloc(sh_alloc, hash_size);
        // sh->header.ref_count = 1;
        // add_gc_object(ctx->rt, &sh->header, JS_GC_OBJ_TYPE_SHAPE);
        // sh->is_hashed = FALSE;
        // if (sh->proto) {
        //     JS_DupValue(ctx, JS_MKPTR(JS_TAG_OBJECT, sh->proto));
        // }
        // for(i = 0, pr = get_shape_prop(sh); i < sh->prop_count; i++, pr++) {
        //     JS_DupAtom(ctx, pr->atom);
        // }
        // return sh;
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

        self.add_intrinsic_basic_objects();

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.class_proto.deinit();
    }

    pub fn add_intrinsic_basic_objects(self: *Self) void {
        
    }

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
    pub fn new_object_from_shape(self: *Self, shape: *JSShape, class: JSClassEnum) !JSValue {
        self.runtime.trigger_gc();

        var obj = try JSObject.init(&self.runtime.allocator.allocator, @enumToInt(class), shape);
        

    
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

const MarkFunc = fn(runtime: *JSRuntime, gp: *JSGCObjectHeaderNode) void;


fn gc_decref_child(runtime: *JSRuntime, header: *JSGCObjectHeaderNode) void {
    std.debug.assert(header.data.ref_count > 0);
    header.data.ref_count -= 1;
    if (header.data.ref_count == 0 and header.data.mark == 1) {
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

fn gc_scan_incref_child(runtime: *JSRuntime, header: *JSGCObjectHeaderNode) void {
    header.data.ref_count += 1;
    if (header.data.ref_count == 1) {
        // ref_count was 0: remove from tmp_obj_list and add at the
        // end of gc_obj_list
        runtime.tmp_obj_list.remove(header);
        runtime.gc_obj_list.append(header);

        // reset the mark for the next GC call
        header.data.mark = 0;
    }
    // p->ref_count++;
    // if (p->ref_count == 1) {
    //     /* ref_count was 0: remove from tmp_obj_list and add at the
    //        end of gc_obj_list */
    //     list_del(&p->link);
    //     list_add_tail(&p->link, &rt->gc_obj_list);
    //     p->mark = 0; /* reset the mark for the next GC call */
    // }
}

fn gc_scan_incref_child2(runtime: *JSRuntime, header: *JSGCObjectHeaderNode) void {
    header.data.ref_count += 1;
    // p->ref_count++;
}
fn get_atom_hash(hash: u30) u64 {
    return @intCast(u64, hash);
}

fn are_atom_hashes_equal(first: u30, second: u30) bool {
    return true;
}
const AtomHashMap = std.HashMap(u30, *JSAtomStruct, get_atom_hash, are_atom_hashes_equal, std.hash_map.default_max_load_percentage);

const JSRuntime = struct {
    allocator: *JSAllocator,
    classes: std.ArrayList(JSClass),
    
    context_list: std.ArrayList(JSContext),

    // Garbage Collection data
    gc_phase: JSGCPhase,
    gc_obj_list: JSGCObjectHeaderList,
    gc_zero_ref_count_list: JSGCObjectHeaderList,
    tmp_obj_list: JSGCObjectHeaderList,

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

    // TODO: Rework to use hash table
    atom_hash: AtomHashMap,
    
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
            .gc_zero_ref_count_list = JSGCObjectHeaderList{},
            .tmp_obj_list = JSGCObjectHeaderList{},
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
            .atom_hash = AtomHashMap.init(&allocator.allocator),
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

    /// Finds a shape that matches the given shape plus the specified property.
    pub fn find_shape_with_extra_property(self: *Self, shape: *JSShape, atom: JSAtom, prop_flags: u32) ?*JSShape {
        var hash = shape.hash;
        hash = shape_hash(hash, atom);
        hash = shape_hash(hash, prop_flags);

        return self.shape_hash.get(hash);
    }

    /// Adds the given shape to the shape hash table.
    /// Once added, this context owns the shape.
    pub fn add_shape(self: *Self, shape: *JSShape) !void {
        return self.shape_hash.put(shape.hash, shape);
    }

    /// Removes the given shape from the shape hash table.
    /// Once removed, the caller owns the shape.
    pub fn remove_shape(self: *Self, shape: *JSShape) void {
        self.shape_hash.remove(shape.hash);
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
    pub fn run_gc(self: *Self) void {

        // decrement the reference of the children of each object
        // mark = 1 after this pass
        self.gc_deref();

        // keep the GC objects with a non zero refcont and their children.
        // objects to keep are in gc_obj_list
        // objects to destroy are in tmp_obj_list
        self.gc_scan();

        // free the GC objects in a cycle
        self.gc_free_cycles();

        // /* decrement the reference of the children of each object. mark =
        // 1 after this pass. */
        // gc_decref(rt);

        // /* keep the GC objects with a non zero refcount and their childs */
        // gc_scan(rt);

        // /* free the GC objects in a cycle */
        // gc_free_cycles(rt);
    }

    fn gc_free_cycles(self: *Self) void {
        self.gc_phase = .JS_GC_PHASE_REMOVE_CYCLES;

        while(self.tmp_obj_list.first) |obj| {
            // only need to free the GC object associated with JS
            // values. The rest will be automatically removed
            // because they must be referenced by them.
            var gc_obj = get_gc_object(obj);
            switch(gc_obj) {
                .JS_GC_OBJ_TYPE_JS_OBJECT => |object| self.free_object(object),
                .JS_GC_OBJ_TYPE_FUNCTION_BYTECODE => |bytecode| self.free_bytecode(bytecode),
                else => {
                    self.tmp_obj_list.remove(obj);
                    self.gc_zero_ref_count_list.append(obj);
                    break;
                }
            }
        }
        self.gc_phase = .JS_GC_PHASE_NONE;

        while(self.gc_zero_ref_count_list.first) |obj| {
            var gc_obj = get_gc_object(obj);

            switch(gc_obj) {
                .JS_GC_OBJ_TYPE_JS_OBJECT => |object| {
                    self.allocator.allocator.destroy(obj);
                },
                .JS_GC_OBJ_TYPE_FUNCTION_BYTECODE => |bytecode| {
                    self.allocator.allocator.destroy(bytecode);
                },
                else => unreachable
            }

            self.gc_zero_ref_count_list.remove(obj);
        }
    //     struct list_head *el, *el1;
    //     JSGCObjectHeader *p;
    // #ifdef DUMP_GC_FREE
    //     BOOL header_done = FALSE;
    // #endif

    //     rt->gc_phase = JS_GC_PHASE_REMOVE_CYCLES;

    //     for(;;) {
    //         el = rt->tmp_obj_list.next;
    //         if (el == &rt->tmp_obj_list)
    //             break;
    //         p = list_entry(el, JSGCObjectHeader, link);
    //         /* Only need to free the GC object associated with JS
    //         values. The rest will be automatically removed because they
    //         must be referenced by them. */
    //         switch(p->gc_obj_type) {
    //         case JS_GC_OBJ_TYPE_JS_OBJECT:
    //         case JS_GC_OBJ_TYPE_FUNCTION_BYTECODE:
    // #ifdef DUMP_GC_FREE
    //             if (!header_done) {
    //                 printf("Freeing cycles:\n");
    //                 JS_DumpObjectHeader(rt);
    //                 header_done = TRUE;
    //             }
    //             JS_DumpGCObject(rt, p);
    // #endif
    //             free_gc_object(rt, p);
    //             break;
    //         default:
    //             list_del(&p->link);
    //             list_add_tail(&p->link, &rt->gc_zero_ref_count_list);
    //             break;
    //         }
    //     }
    //     rt->gc_phase = JS_GC_PHASE_NONE;
            
    //     list_for_each_safe(el, el1, &rt->gc_zero_ref_count_list) {
    //         p = list_entry(el, JSGCObjectHeader, link);
    //         assert(p->gc_obj_type == JS_GC_OBJ_TYPE_JS_OBJECT ||
    //             p->gc_obj_type == JS_GC_OBJ_TYPE_FUNCTION_BYTECODE);
    //         js_free_rt(rt, p);
    //     }

    //     init_list_head(&rt->gc_zero_ref_count_list);
    }

    fn gc_scan(self: *Self) void {
        var list_obj: ?*JSGCObjectHeaderNode = self.gc_obj_list.first;
        while(list_obj) |obj| {
            std.debug.assert(obj.data.ref_count > 0);
            obj.data.mark = 0;
            self.mark_children(obj, gc_scan_incref_child);
            list_obj = obj.next;
        }

        list_obj = self.tmp_obj_list.first;
        while(list_obj) |obj| {
            self.mark_children(obj, gc_scan_incref_child2);
        }

        // struct list_head *el;
        // JSGCObjectHeader *p;

        // /* keep the objects with a refcount > 0 and their children. */
        // list_for_each(el, &rt->gc_obj_list) {
        //     p = list_entry(el, JSGCObjectHeader, link);
        //     assert(p->ref_count > 0);
        //     p->mark = 0; /* reset the mark for the next GC call */
        //     mark_children(rt, p, gc_scan_incref_child);
        // }
        
        // /* restore the refcount of the objects to be deleted. */
        // list_for_each(el, &rt->tmp_obj_list) {
        //     p = list_entry(el, JSGCObjectHeader, link);
        //     mark_children(rt, p, gc_scan_incref_child2);
        // }
    }

    /// Decrements each GC object's refcount by 1 and sets their mark to 1.
    fn gc_deref(self: *Self) void {
        var list_obj: ?*JSGCObjectHeaderNode = self.gc_obj_list.first;

        // decrement the refcount of all the children of all the GC
        // objects and move the GC objects with zero refcount to
        // tmp_obj_list
        while(list_obj) |obj| {
            std.debug.assert(obj.data.mark == 0);
            self.mark_children(obj, gc_decref_child);
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
                mark_func(self, &shape.header);

                // mark all the fields
                for(shape.properties.items) |*propertyShape, i| {
                    var prop = &obj.properties[i];
                    if (propertyShape.atom != @enumToInt(JSAtomEnum.JS_ATOM_NULL)) {
                        switch(prop.*) {
                            .GETSET => |*getset| {
                                if (getset.getter) |getter| {
                                    mark_func(self, &getter.header);
                                }
                                if (getset.setter) |setter| {
                                    mark_func(self, &setter.header);
                                }
                                break;
                            },
                            .VAR_REF => |var_ref| {
                                if (var_ref.is_detached) {
                                    // Note: the tag order does not matter
                                    // provided it is a GC object
                                    mark_func(self, &var_ref.header);
                                }
                                break;
                            },
                            .AUTO_INIT => |*autoinit| {
                                self.autoinit_mark(autoinit, mark_func);
                            },
                            .VALUE => |value| {
                                self.mark_value(value, mark_func);
                            },
                            // else => unreachable
                        }
                        // if (propertyShape.flags & JS_PROP_TMASK != 0) {
                        // } else {
                        //     self.mark_value(prop.value, mark_func);
                        // }
                    }
                }

                switch(obj.data) {
                    .JS_CLASS_OBJECT => |obj_data| {
                        var gc_mark: ?JSClassGCMark = self.classes.items[obj.class_id].gc_mark;
                        if (gc_mark) |mark| {
                            mark(self, JSValue{ .JS_TAG_OBJECT = obj }, mark_func);
                        }
                    },
                    else => {}
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
                // break;
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
                // break;
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
                // break;
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
                // break;
            },
            .JS_GC_OBJ_TYPE_SHAPE => |shape| {
                if (shape.proto) |proto| {
                    mark_func(self, &proto.header);
                }
                //         {
        //             JSShape *sh = (JSShape *)gp;
        //             if (sh->proto != NULL) {
        //                 mark_func(rt, &sh->proto->header);
        //             }
        //         }
                // break;
            },
            .JS_GC_OBJ_TYPE_JS_CONTEXT => |ctx| {
                self.mark_context(ctx, mark_func);
                //         {
        //             JSContext *ctx = (JSContext *)gp;
        //             JS_MarkContext(rt, ctx, mark_func);
        //         }
                // break;
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
        for(ctx.class_proto.items) |class| {
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
            mark_func(self, &shape.header);
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
            .JS_TAG_OBJECT => |v| {
                mark_func(self, &v.header);
            },
            .JS_TAG_FUNCTION_BYTECODE => |v| {
                mark_func(self, &v.header);
            },
            else => {}
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

    fn autoinit_mark(self: *Self, autoinit: *JSPropertyAutoInit, mark_func: MarkFunc) void {
        mark_func(self, &autoinit.realm.header);
        // mark_func(rt, &js_autoinit_get_realm(pr)->header);
    }

    fn mark_module_def(self: *Self, module: *JSModuleDef, mark_func: MarkFunc) void {
        for(module.export_entries.items) |*entry| {
            switch(entry.value) {
                .JS_EXPORT_TYPE_LOCAL => |*local| {
                    if (local.var_ref) |ref| {
                        mark_func(self, &ref.header);
                    }
                },
                else => {}
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

    fn free_object(self: *Self, obj: *JSObject) void {
        // used to tell the object is invalid whne freeing
        // cycles
        obj.free_mark = true;

        // free all the fields
        var shape = obj.shape;
        for(shape.properties.items) |*shapeProp, i| {
            self.free_property(&obj.properties[i], shapeProp.flags);
        }
        self.allocator.allocator.free(obj.properties);

        // as an optimization we destroy the shape immediately
        // without putting it in gc_zero_ref_count_list
        self.free_shape(shape);

        // TODO: implement for WeakMap
        // if (obj.first_weak_ref) |ref| {
        //     self.reset_weak_ref(obj);
        // }

        var finalizer: ?JSClassFinalizer = self.classes.items[obj.class_id].finalizer;
        if (finalizer) |f| {
            f(self, JSValue{ .JS_TAG_OBJECT = obj });
        }

        self.remove_gc_obj(&obj.header);
        if (self.gc_phase == .JS_GC_PHASE_REMOVE_CYCLES and obj.header.data.ref_count != 0) {
            self.gc_zero_ref_count_list.append(&obj.header);
        } else {
            self.allocator.allocator.destroy(obj);
        }

        // int i;
        // JSClassFinalizer *finalizer;
        // JSShape *sh;
        // JSShapeProperty *pr;

        // p->free_mark = 1; /* used to tell the object is invalid when
        //                     freeing cycles */
        // /* free all the fields */
        // sh = p->shape;
        // pr = get_shape_prop(sh);
        // for(i = 0; i < sh->prop_count; i++) {
        //     free_property(rt, &p->prop[i], pr->flags);
        //     pr++;
        // }
        // js_free_rt(rt, p->prop);
        // /* as an optimization we destroy the shape immediately without
        // putting it in gc_zero_ref_count_list */
        // js_free_shape(rt, sh);

        // /* fail safe */
        // p->shape = NULL;
        // p->prop = NULL;

        // if (unlikely(p->first_weak_ref)) {
        //     reset_weak_ref(rt, p);
        // }

        // finalizer = rt->class_array[p->class_id].finalizer;
        // if (finalizer)
        //     (*finalizer)(rt, JS_MKPTR(JS_TAG_OBJECT, p));

        // /* fail safe */
        // p->class_id = 0;
        // p->u.opaque = NULL;
        // p->u.func.var_refs = NULL;
        // p->u.func.home_object = NULL;

        // remove_gc_object(&p->header);
        // if (rt->gc_phase == JS_GC_PHASE_REMOVE_CYCLES && p->header.ref_count != 0) {
        //     list_add_tail(&p->header.link, &rt->gc_zero_ref_count_list);
        // } else {
        //     js_free_rt(rt, p);
        // }
    }

    fn free_property(self: *Self, prop: *JSProperty, flags: u32) void {

    }

    /// Decrements the refcount of the given shape
    /// and deallocates it if it is no longer in use.
    fn free_shape(self: *Self, shape: *JSShape) void {
        shape.header.data.remove_ref();
        if (shape.header.data.ref_count <= 0) {
            // TODO:
            // uint32_t i;
            // JSShapeProperty *pr;

            // assert(sh->header.ref_count == 0);
            // if (sh->is_hashed)
            //     js_shape_hash_unlink(rt, sh);
            // if (sh->proto != NULL) {
            //     JS_FreeValueRT(rt, JS_MKPTR(JS_TAG_OBJECT, sh->proto));
            // }
            // pr = get_shape_prop(sh);
            // for(i = 0; i < sh->prop_count; i++) {
            //     JS_FreeAtomRT(rt, pr->atom);
            //     pr++;
            // }
            // remove_gc_object(&sh->header);
            // js_free_rt(rt, get_alloc_from_shape(sh));
        }
    }

    fn free_bytecode(self: *Self, bytecode: *JSFunctionBytecode) void {
        self.free_bytecode_atoms(bytecode.byte_code_buf, true);

        // int i;

        // #if 0
        //     {
        //         char buf[ATOM_GET_STR_BUF_SIZE];
        //         printf("freeing %s\n",
        //             JS_AtomGetStrRT(rt, buf, sizeof(buf), b->func_name));
        //     }
        // #endif
        //     free_bytecode_atoms(rt, b->byte_code_buf, b->byte_code_len, TRUE);

        //     if (b->vardefs) {
        //         for(i = 0; i < b->arg_count + b->var_count; i++) {
        //             JS_FreeAtomRT(rt, b->vardefs[i].var_name);
        //         }
        //     }
        //     for(i = 0; i < b->cpool_count; i++)
        //         JS_FreeValueRT(rt, b->cpool[i]);

        //     for(i = 0; i < b->closure_var_count; i++) {
        //         JSClosureVar *cv = &b->closure_var[i];
        //         JS_FreeAtomRT(rt, cv->var_name);
        //     }
        //     if (b->realm)
        //         JS_FreeContext(b->realm);

        //     JS_FreeAtomRT(rt, b->func_name);
        //     if (b->has_debug) {
        //         JS_FreeAtomRT(rt, b->debug.filename);
        //         js_free_rt(rt, b->debug.pc2line_buf);
        //         js_free_rt(rt, b->debug.source);

        //         if (b->debugger.breakpoints)
        //             js_free_rt(rt, b->debugger.breakpoints);
        //     }

        //     remove_gc_object(&b->header);
        //     if (rt->gc_phase == JS_GC_PHASE_REMOVE_CYCLES && b->header.ref_count != 0) {
        //         list_add_tail(&b->header.link, &rt->gc_zero_ref_count_list);
        //     } else {
        //         js_free_rt(rt, b);
        //     }
    }

    fn free_bytecode_atoms(self: *Self, bytecode: []u8, use_short_opcodes: bool) void {
        var pos: usize = 0;
        while(pos < bytecode.len) {
            var op = bytecode[pos];
            var oi = if(use_short_opcodes) &short_opcode_info(op) else &opcode_info[op];
            const len = oi.size;
            switch(oi.fmt) {
                .atom,
                .atom_u8,
                .atom_u16,
                .atom_label_u8,
                .atom_label_u16 => {
                    const atom: JSAtom = std.mem.readIntSlice(JSAtom, bytecode[pos+1..], std.builtin.endian);
                    self.free_atom(atom);
                },
                else => {}
            }
            pos += len;
        }
        // int pos, len, op;
        // JSAtom atom;
        // const JSOpCode *oi;
        
        // pos = 0;
        // while (pos < bc_len) {
        //     op = bc_buf[pos];
        //     if (use_short_opcodes)
        //         oi = &short_opcode_info(op);
        //     else
        //         oi = &opcode_info[op];
                
        //     len = oi->size;
        //     switch(oi->fmt) {
        //     case OP_FMT_atom:
        //     case OP_FMT_atom_u8:
        //     case OP_FMT_atom_u16:
        //     case OP_FMT_atom_label_u8:
        //     case OP_FMT_atom_label_u16:
        //         atom = get_u32(bc_buf + pos + 1);
        //         JS_FreeAtomRT(rt, atom);
        //         break;
        //     default:
        //         break;
        //     }
        //     pos += len;
        // }
    }

    fn free_atom(self: *Self, atom: JSAtom) void {
        if (!atom_is_const(atom)) {
            // const p = self.atom_hash[atom];
            // p.header.ref_count -= 1;

            // if (p.header.ref_count > 0) {
            //     return;
            // }

            // self.free_atom_struct(p);
            // p = rt->atom_array[i];
            // if (--p->header.ref_count > 0)
            //     return;
            // JS_FreeAtomStruct(rt, p);
        }
        // if (!__JS_AtomIsConst(v))
        // __JS_FreeAtom(rt, v);

    //     JSAtomStruct *p;
    }

    fn free_atom_struct(self: *Self, atom: *JSAtomStruct) void {
        if (atom.atom_type != .JS_ATOM_TYPE_SYMBOL) {
            self.atom_hash.remove(atom.hash);
            self.allocator.allocator.destroy(atom);
        }

    //     #if 0   /* JS_ATOM_NULL is not refcounted: __JS_AtomIsConst() includes 0 */
    //     if (unlikely(i == JS_ATOM_NULL)) {
    //         p->header.ref_count = INT32_MAX / 2;
    //         return;
    //     }
    // #endif
    //     uint32_t i = p->hash_next;  /* atom_index */
    //     if (p->atom_type != JS_ATOM_TYPE_SYMBOL) {
    //         JSAtomStruct *p0, *p1;
    //         uint32_t h0;

    //         h0 = p->hash & (rt->atom_hash_size - 1);
    //         i = rt->atom_hash[h0];
    //         p1 = rt->atom_array[i];
    //         if (p1 == p) {
    //             rt->atom_hash[h0] = p1->hash_next;
    //         } else {
    //             for(;;) {
    //                 assert(i != 0);
    //                 p0 = p1;
    //                 i = p1->hash_next;
    //                 p1 = rt->atom_array[i];
    //                 if (p1 == p) {
    //                     p0->hash_next = p1->hash_next;
    //                     break;
    //                 }
    //             }
    //         }
    //     }
    //     /* insert in free atom list */
    //     rt->atom_array[i] = atom_set_free(rt->atom_free_index);
    //     rt->atom_free_index = i;
    //     /* free the string structure */
    // #ifdef DUMP_LEAKS
    //     list_del(&p->link);
    // #endif
    //     js_free_rt(rt, p);
    //     rt->atom_count--;
    //     assert(rt->atom_count >= 0);
    }

    
};

fn atom_is_const(atom: JSAtom) bool {
        return atom < @enumToInt(JSAtomEnum.JS_ATOM_END);
//         static inline BOOL __JS_AtomIsConst(JSAtom v)
// {
// #if defined(DUMP_LEAKS) && DUMP_LEAKS > 1
//         return (int32_t)v <= 0;
// #else
//         return (int32_t)v < JS_ATOM_END;
// #endif
// }
    }

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

test "JSRuntime - run_gc()" {
    {
        // should not remove anything
        var gpa = JSAllocator{};
        defer _ = gpa.deinit();

        var runtime = JSRuntime.init(&gpa);
        defer runtime.deinit();

        var context = try runtime.new_context();

        runtime.run_gc();

        testing.expect(runtime.gc_obj_list.len == 1);
        testing.expect(runtime.tmp_obj_list.len == 0);
        testing.expect(runtime.gc_zero_ref_count_list.len == 0);
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
        .JS_GC_OBJ_TYPE_JS_OBJECT => GCObject{ .JS_GC_OBJ_TYPE_JS_OBJECT = @fieldParentPtr(JSObject, "header", gc) },
        .JS_GC_OBJ_TYPE_SHAPE => GCObject{ .JS_GC_OBJ_TYPE_SHAPE = @fieldParentPtr(JSShape, "header", gc) },
        .JS_GC_OBJ_TYPE_JS_CONTEXT => GCObject{ .JS_GC_OBJ_TYPE_JS_CONTEXT = @fieldParentPtr(JSContext, "header", gc) },
        .JS_GC_OBJ_TYPE_FUNCTION_BYTECODE => GCObject{ .JS_GC_OBJ_TYPE_FUNCTION_BYTECODE = @fieldParentPtr(JSFunctionBytecode, "header", gc) },
        .JS_GC_OBJ_TYPE_VAR_REF => GCObject{ .JS_GC_OBJ_TYPE_VAR_REF = @fieldParentPtr(JSVarRef, "header", gc) },
        .JS_GC_OBJ_TYPE_ASYNC_FUNCTION => GCObject{ .JS_GC_OBJ_TYPE_ASYNC_FUNCTION = @fieldParentPtr(JSAsyncFunctionData, "header", gc) },
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