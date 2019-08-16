//
//  SJSQLiteTableInfo.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteTableInfo.h"
#import "SJSQLiteTableModelConstraints.h"
#import "SJSQLiteColumnInfo.h"
#import "SJSQLiteCore.h"


#pragma mark - YYModel <https://github.com/ibireme/YYModel>

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, _YYEncodingType) {
    _YYEncodingTypeMask       = 0xFF, ///< mask of type value
    _YYEncodingTypeUnknown    = 0, ///< unknown
    _YYEncodingTypeVoid       = 1, ///< void
    _YYEncodingTypeBool       = 2, ///< bool
    _YYEncodingTypeInt8       = 3, ///< char / BOOL
    _YYEncodingTypeUInt8      = 4, ///< unsigned char
    _YYEncodingTypeInt16      = 5, ///< short
    _YYEncodingTypeUInt16     = 6, ///< unsigned short
    _YYEncodingTypeInt32      = 7, ///< int
    _YYEncodingTypeUInt32     = 8, ///< unsigned int
    _YYEncodingTypeInt64      = 9, ///< long long
    _YYEncodingTypeUInt64     = 10, ///< unsigned long long
    _YYEncodingTypeFloat      = 11, ///< float
    _YYEncodingTypeDouble     = 12, ///< double
    _YYEncodingTypeLongDouble = 13, ///< long double
    _YYEncodingTypeObject     = 14, ///< id
    _YYEncodingTypeClass      = 15, ///< Class
    _YYEncodingTypeSEL        = 16, ///< SEL
    _YYEncodingTypeBlock      = 17, ///< block
    _YYEncodingTypePointer    = 18, ///< void*
    _YYEncodingTypeStruct     = 19, ///< struct
    _YYEncodingTypeUnion      = 20, ///< union
    _YYEncodingTypeCString    = 21, ///< char*
    _YYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    _YYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    _YYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    _YYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    _YYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    _YYEncodingTypeQualifierOut    = 1 << 11, ///< out
    _YYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    _YYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    _YYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    _YYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    _YYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    _YYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    _YYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    _YYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    _YYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    _YYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    _YYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    _YYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
_YYEncodingType _YYEncodingGetType(const char *typeEncoding);


/**
 Instance variable information.
 */
@interface _YYClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) _YYEncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface _YYClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface _YYClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) _YYEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 Class information for a class.
 */
@interface _YYClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) _YYClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, _YYClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, _YYClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, _YYClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END


//
//  _YYClassInfo.m
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <objc/runtime.h>

_YYEncodingType _YYEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return _YYEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return _YYEncodingTypeUnknown;
    
    _YYEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= _YYEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= _YYEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= _YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= _YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= _YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= _YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= _YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return _YYEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return _YYEncodingTypeVoid | qualifier;
        case 'B': return _YYEncodingTypeBool | qualifier;
        case 'c': return _YYEncodingTypeInt8 | qualifier;
        case 'C': return _YYEncodingTypeUInt8 | qualifier;
        case 's': return _YYEncodingTypeInt16 | qualifier;
        case 'S': return _YYEncodingTypeUInt16 | qualifier;
        case 'i': return _YYEncodingTypeInt32 | qualifier;
        case 'I': return _YYEncodingTypeUInt32 | qualifier;
        case 'l': return _YYEncodingTypeInt32 | qualifier;
        case 'L': return _YYEncodingTypeUInt32 | qualifier;
        case 'q': return _YYEncodingTypeInt64 | qualifier;
        case 'Q': return _YYEncodingTypeUInt64 | qualifier;
        case 'f': return _YYEncodingTypeFloat | qualifier;
        case 'd': return _YYEncodingTypeDouble | qualifier;
        case 'D': return _YYEncodingTypeLongDouble | qualifier;
        case '#': return _YYEncodingTypeClass | qualifier;
        case ':': return _YYEncodingTypeSEL | qualifier;
        case '*': return _YYEncodingTypeCString | qualifier;
        case '^': return _YYEncodingTypePointer | qualifier;
        case '[': return _YYEncodingTypeCArray | qualifier;
        case '(': return _YYEncodingTypeUnion | qualifier;
        case '{': return _YYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return _YYEncodingTypeBlock | qualifier;
            else
                return _YYEncodingTypeObject | qualifier;
        }
        default: return _YYEncodingTypeUnknown | qualifier;
    }
}

@implementation _YYClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = _YYEncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation _YYClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    self = [super init];
    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end

@implementation _YYClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    _YYEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = _YYEncodingGetType(attrs[i].value);
                    
                    if ((type & _YYEncodingTypeMask) == _YYEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= _YYEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= _YYEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= _YYEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= _YYEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= _YYEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= _YYEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= _YYEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= _YYEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

@implementation _YYClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];
    
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            _YYClassMethodInfo *info = [[_YYClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            _YYClassPropertyInfo *info = [[_YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            _YYClassIvarInfo *info = [[_YYClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    _YYClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[_YYClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end


#pragma mark -














NS_ASSUME_NONNULL_BEGIN
typedef NSString *SJSQLITEColumnType;
static SJSQLITEColumnType const SJSQLITEColumnType_INTEGER = @"INTEGER";
static SJSQLITEColumnType const SJSQLITEColumnType_FLOAT = @"FLOAT";
static SJSQLITEColumnType const SJSQLITEColumnType_BLOB = @"BLOB";
static SJSQLITEColumnType const SJSQLITEColumnType_TEXT = @"TEXT";

@implementation SJSQLiteColumnInfo (SJSQLiteTableInfoExtended)
- (void)setAssociatedTableInfo:(nullable SJSQLiteTableInfo *)associatedTableInfo {
    objc_setAssociatedObject(self, @selector(associatedTableInfo), associatedTableInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJSQLiteTableInfo *)associatedTableInfo {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation SJSQLiteTableInfo
+ (nullable instancetype)tableInfoWithClass:(Class<SJSQLiteTableModelProtocol>)cls {
    SJSQLiteTableModelConstraints *cons = [[SJSQLiteTableModelConstraints alloc] initWithClass:cls];
    if ( cons.sql_primaryKey.length < 1 )
        return nil;
    
    _YYClassInfo *_Nullable classInfo = [_YYClassInfo classInfoWithClass:cls];
    if ( classInfo == nil || classInfo.superCls == nil )
        return nil;
    NSString *tablename = cons.sql_tableName?:sqlite3_obj_get_default_table_name(cls);
    NSMutableDictionary<SJSQLiteColumnInfo *, SJSQLiteTableInfo *> *associatedTableInfos = NSMutableDictionary.new;
    NSMutableArray<SJSQLiteColumnInfo *> *columns = NSMutableArray.new;
    NSMutableSet<Class> *allClasses = NSMutableSet.new;
    _YYClassInfo *cur = classInfo;
    while ( cur.superCls != nil && cur.cls != NSObject.class ) {
        for ( _YYClassPropertyInfo *property in cur.propertyInfos.allValues ) {
            if ( property.name.length < 1 )
                continue;
            if ( !class_respondsToSelector(cls, property.setter) )
                continue;
            if ( [cons.objc_sysProperties containsObject:property.name] )
                continue;
            if ( cons.sql_blacklist != nil && [cons.sql_blacklist containsObject:property.name] )
                continue;
            if ( cons.sql_whitelist != nil && ![cons.sql_whitelist containsObject:property.name] )
                continue;
            
            // Unavailable
            switch ( property.type & _YYEncodingTypeMask ) {
                case _YYEncodingTypeUnknown:
                case _YYEncodingTypeVoid:
                case _YYEncodingTypeClass:
                case _YYEncodingTypeSEL:
                case _YYEncodingTypeBlock:
                case _YYEncodingTypePointer:
                case _YYEncodingTypeStruct:
                case _YYEncodingTypeUnion:
                case _YYEncodingTypeCString:
                case _YYEncodingTypeCArray:
                    continue;
                default:
                    break;
            }
            
            // Column
            SJSQLiteColumnInfo *columnInfo = SJSQLiteColumnInfo.alloc.init;
            columnInfo.name = cons.sql_customKeyMapper[property.name]?:property.name;
            switch ( property.type & _YYEncodingTypeMask ) {
                case _YYEncodingTypeBool: {
                    columnInfo.type = SJSQLITEColumnType_BLOB;
                }
                    break;
                case _YYEncodingTypeInt8:
                case _YYEncodingTypeUInt8:
                case _YYEncodingTypeInt16:
                case _YYEncodingTypeUInt16:
                case _YYEncodingTypeInt32:
                case _YYEncodingTypeUInt32:
                case _YYEncodingTypeInt64:
                case _YYEncodingTypeUInt64: {
                    columnInfo.type = SJSQLITEColumnType_INTEGER;
                }
                    break;
                case _YYEncodingTypeFloat:
                case _YYEncodingTypeDouble:
                case _YYEncodingTypeLongDouble: {
                    columnInfo.type = SJSQLITEColumnType_FLOAT;
                }
                    break;
                case _YYEncodingTypeObject: {
                    if      ( [property.cls isSubclassOfClass:NSArray.class] ) {
                        [cons.sql_containerPropertyGenericClass enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class<SJSQLiteTableModelProtocol>  _Nonnull genericClass, BOOL * _Nonnull stop) {
                            if ( [key isEqualToString:property.name] ) {
                                *stop = YES;
                                
                                SJSQLiteTableInfo *_Nullable associatedTableInfo = [SJSQLiteTableInfo tableInfoWithClass:genericClass];
                                if ( associatedTableInfo != nil ) {
                                    [allClasses addObject:associatedTableInfo.cls];
                                    [allClasses unionSet:associatedTableInfo.allClasses];
                                    associatedTableInfos[columnInfo] = associatedTableInfo;
                                    columnInfo.isArrayJSONText = YES;
                                    columnInfo.type = SJSQLITEColumnType_TEXT;
                                    columnInfo.associatedTableInfo = associatedTableInfo;
                                }
                            }
                        }];
                    }
                    else if ( [property.cls isSubclassOfClass:NSString.class] ) {
                        columnInfo.type = SJSQLITEColumnType_TEXT;
                    }
                    else if ( [property.cls isSubclassOfClass:NSURL.class] ) {
                        columnInfo.type = SJSQLITEColumnType_TEXT;
                    }
                    else {
                        // Object
                        SJSQLiteTableInfo *_Nullable associatedTableInfo = nil;
                        for ( SJSQLiteColumnInfo *columnInfo in columns ) {
                            if ( [columnInfo.associatedTableInfo.cls isSubclassOfClass:property.cls] ) {
                                associatedTableInfo = columnInfo.associatedTableInfo;
                                break;
                            }
                        }
                        
                        if ( associatedTableInfo == nil ) {
                            associatedTableInfo = [SJSQLiteTableInfo tableInfoWithClass:property.cls];
                        }
                        
                        if ( associatedTableInfo != nil ) {
                            [allClasses addObject:associatedTableInfo.cls];
                            [allClasses unionSet:associatedTableInfo.allClasses];
                            associatedTableInfos[columnInfo] = associatedTableInfo;
                            columnInfo.type = SJSQLITEColumnType_INTEGER;
                            columnInfo.associatedTableInfo = associatedTableInfo;
                        }
                    }
                }
                    break;
                default: break;
            }
            
            if ( columnInfo.type == nil )
                continue;
            
            // Constraints
            NSMutableString *constraints = NSMutableString.new;
            if ( [columnInfo.name isEqualToString:cons.sql_primaryKey] ) {
                [constraints appendString:@" PRIMARY KEY"];
                columnInfo.isPrimaryKey = YES;
            }
            
            for ( NSString *key in cons.sql_autoincrementlist ) {
                if ( [columnInfo.name isEqualToString:key] ) {
                    [constraints appendFormat:@" AUTOINCREMENT"];
                    columnInfo.isAutoincrement = YES;
                }
            }
            
            for ( NSString *key in cons.sql_notnulllist ) {
                if ( [columnInfo.name isEqualToString:key] ) {
                    [constraints appendString:@" NOT NULL"];
                    break;
                }
            }
            
            if ( columnInfo.associatedTableInfo != nil && ![property.cls isSubclassOfClass:NSArray.class]) {
                SJSQLiteTableInfo *tableInfo = columnInfo.associatedTableInfo;
                [constraints appendFormat:@" REFERENCES '%@' ('%@')", tableInfo.name, tableInfo.primaryKey];
            }
            
            if ( constraints.length > 0 ) {
                columnInfo.constraints = constraints.copy;
            }
            
            [columns addObject:columnInfo];
        }
        
        cur = cur.superClassInfo;
    }
    
    if ( columns.count < 1 )
        return nil;
    
    [allClasses addObject:cls];
    
    SJSQLiteTableInfo *info = SJSQLiteTableInfo.alloc.init;
    info->_cls = cls;
    info->_columns = columns.copy;
    info->_name = tablename;
    info->_primaryKey = cons.sql_primaryKey;
    info->_allClasses = allClasses.copy;
    if ( associatedTableInfos.count > 0 ) info->_columnAssociatedTableInfos = associatedTableInfos.copy;
    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SJSQLiteTable:<%p> { %@ }", self, self.columns];
}
@end
NS_ASSUME_NONNULL_END
