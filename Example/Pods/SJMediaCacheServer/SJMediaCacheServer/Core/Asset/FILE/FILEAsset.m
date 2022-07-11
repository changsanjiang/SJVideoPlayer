//
//  MCSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEAsset.h"
#import "FILEAssetContentProvider.h"
#import "MCSUtils.h"
#import "MCSConsts.h"
#import "MCSConfiguration.h"
#import "MCSRootDirectory.h"
#import "NSFileHandle+MCS.h"
#import "MCSQueue.h"

@interface FILEAssetContentNode : NSObject<FILEAssetContentNode>
@property (nonatomic, readonly) UInt64 startPositionInAsset;
@property (nonatomic, readonly, nullable) id<MCSAssetContent> longestContent;
@property (nonatomic, readonly, nullable) NSArray<id<MCSAssetContent>> *allContents;
@end

@interface FILEAssetContentNode ()
- (instancetype)initWithContent:(id<MCSAssetContent>)content;
@property (nonatomic, unsafe_unretained, nullable) FILEAssetContentNode *prev;
@property (nonatomic, unsafe_unretained, nullable) FILEAssetContentNode *next;
- (void)addContent:(id<MCSAssetContent>)content;
- (void)removeContentAtIndex:(NSInteger)index;
@end

@implementation FILEAssetContentNode {
    NSMutableArray<id<MCSAssetContent>> *mContents;
}
- (instancetype)initWithContent:(id<MCSAssetContent>)content {
    self = [super init];
    if ( self ) {
        mContents = [NSMutableArray arrayWithObject:content];
    }
    return self;
}

- (UInt64)startPositionInAsset {
    return mContents.firstObject.startPositionInAsset;
}

- (nullable id<MCSAssetContent>)longestContent {
    id<MCSAssetContent> retv = mContents.firstObject;
    for ( NSInteger i = 1 ; i < mContents.count ; ++ i ) {
        id<MCSAssetContent> content = mContents[i];
        if ( content.length > retv.length ) {
            retv = content;
        }
    }
    return retv;
}

- (void)addContent:(id<MCSAssetContent>)content {
    [mContents addObject:content];
}

- (void)removeContentAtIndex:(NSInteger)index {
    [mContents removeObjectAtIndex:index];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p> { startPositionInAsset: %llu, maximumLength: %llu, contents: %lu };\n", NSStringFromClass(self.class), self, self.startPositionInAsset, self.longestContent.length, (unsigned long)mContents.count];
}
@end

@interface FILEAssetContentNodeList : NSObject
- (instancetype)initWithContents:(nullable NSArray<id<MCSAssetContent>> *)contents;
@property (nonatomic, readonly) NSUInteger count; // node count
@property (nonatomic, readonly, nullable) FILEAssetContentNode *head;
@property (nonatomic, readonly, nullable) FILEAssetContentNode *tail;
- (void)bringContentToNode:(id<MCSAssetContent>)content;
- (void)removeNode:(FILEAssetContentNode *)node;
- (void)enumerateContentNodesUsingBlock:(void(NS_NOESCAPE ^)(id<FILEAssetContentNode> node, BOOL *stop))block;
@end

@implementation FILEAssetContentNodeList {
    NSMutableDictionary<NSNumber *, FILEAssetContentNode *> *mNodes;
}
- (instancetype)initWithContents:(nullable NSArray<id<MCSAssetContent>> *)contents {
    self = [super init];
    mNodes = NSMutableDictionary.dictionary;
    for ( id<MCSAssetContent> content in contents ) {
        [self bringContentToNode:content];
    }
    return self;
}

- (NSUInteger)count {
    return mNodes.count;
}

- (void)bringContentToNode:(id<MCSAssetContent>)content {
    UInt64 curNodePosition = content.startPositionInAsset;
    NSNumber *curNodeKey = @(curNodePosition);
    FILEAssetContentNode *curNode = mNodes[curNodeKey];
    if ( curNode == nil ) {
        // create new node
        //
        curNode = [FILEAssetContentNode.alloc initWithContent:content];
        mNodes[curNodeKey] = curNode;
         
        // restructure nodes position
        //
        // prevNode.position < curNode.position < nextNode.position
        //
        // preNode.next = curNode; curNode.prev = prevNode, curNode.next = nextNode; nextNode.prev = curNode;
        //
        FILEAssetContentNode *prevNode = _tail;
        FILEAssetContentNode *nextNode = nil;
        while ( prevNode.startPositionInAsset > curNodePosition ) {
            nextNode = prevNode;
            prevNode = prevNode.prev;
        }
        
        prevNode.next = curNode;
        curNode.prev = prevNode;
        curNode.next = nextNode;
        nextNode.prev = curNode;
        
        if ( _head == nil || _head.startPositionInAsset > curNodePosition ) {
            _head = curNode;
        }
        
        if ( _tail == nil || _tail.startPositionInAsset < curNodePosition ) {
            _tail = curNode;
        }
    }
    else {
        [curNode addContent:content];
    }
}

- (void)enumerateContentNodesUsingBlock:(void(NS_NOESCAPE ^)(id<FILEAssetContentNode> node, BOOL *stop))block {
    BOOL stop = NO;
    FILEAssetContentNode *cur = _head;
    while ( cur != nil ) {
        block(cur, &stop);
        cur = cur.next;
        if ( stop ) break;;
    }
}

- (void)removeNode:(FILEAssetContentNode *)node {
    FILEAssetContentNode *prevNode = node.prev;
    FILEAssetContentNode *nextNode = node.next;
    nextNode.prev = prevNode;
    prevNode.next = nextNode;

    if ( _head == node ) _head = nextNode;
    if ( _tail == node ) _tail = prevNode;
    
    NSNumber *nodeKey = @(node.startPositionInAsset);
    [mNodes removeObjectForKey:nodeKey];
}
@end


@interface FILEAsset () {
    FILEAssetContentProvider *mProvider;
    FILEAssetContentNodeList *mNodeList;
    BOOL mIsPrepared;
}

@property (nonatomic) NSInteger id; // saveable
@property (nonatomic, copy) NSString *name; // saveable
@property (nonatomic, copy, nullable) NSString *pathExtension; // saveable
@property (nonatomic, copy, nullable) NSString *contentType; // saveable
@property (nonatomic) NSUInteger totalLength;  // saveable
@end

@implementation FILEAsset
@synthesize id = _id;
@synthesize name = _name;
@synthesize configuration = _configuration;
@synthesize isStored = _isStored;

+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"readwriteCount", @"isStored", @"configuration", @"contents", @"provider"];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if ( self ) {
        _name = name.copy;
    }
    return self;
}

- (void)prepare {
    mcs_queue_sync(^{
        NSParameterAssert(self.name != nil);
        if ( mIsPrepared ) return;
        mIsPrepared = YES;
        NSString *directory = [MCSRootDirectory assetPathForFilename:self.name];
        _configuration = MCSConfiguration.alloc.init;
        mProvider = [FILEAssetContentProvider contentProviderWithDirectory:directory];
        mNodeList = [FILEAssetContentNodeList.alloc initWithContents:mProvider.contents];
        [self _restructureContents];
    });
}

- (NSString *)path {
    return [MCSRootDirectory assetPathForFilename:_name];
}

#pragma mark - mark

- (MCSAssetType)type {
    return MCSAssetTypeFILE;
}

- (void)enumerateContentNodesUsingBlock:(void(NS_NOESCAPE ^)(id<FILEAssetContentNode> node, BOOL *stop))block {
    mcs_queue_sync(^{
        [mNodeList enumerateContentNodesUsingBlock:block];
    });
}

- (BOOL)isStored {
    __block BOOL isStored = NO;
    mcs_queue_sync(^{
        isStored = _isStored;
    });
    return isStored;
}

- (nullable NSString *)filepathForContent:(id<MCSAssetContent>)content {
    return [mProvider contentFilepath:content];
}

- (nullable NSString *)pathExtension {
    __block NSString *pathExtension = nil;
    mcs_queue_sync(^{
        pathExtension = _pathExtension;
    });
    return pathExtension;
}

- (nullable NSString *)contentType {
    __block NSString *contentType = nil;
    mcs_queue_sync(^{
        contentType = _contentType;
    });
    return contentType;
}

- (NSUInteger)totalLength {
    __block NSUInteger totalLength = 0;
    mcs_queue_sync(^{
        totalLength = _totalLength;
    });
    return totalLength;
}

/// 该操作将会对 content 进行一次 readwriteRetain, 请在不需要时, 调用一次 readwriteRelease.
- (nullable id<MCSAssetContent>)createContentReadwriteWithDataType:(MCSDataType)dataType response:(id<MCSDownloadResponse>)response {
    switch ( dataType ) {
        case MCSDataTypeHLSMask:
        case MCSDataTypeHLSPlaylist:
        case MCSDataTypeHLSAESKey:
        case MCSDataTypeHLSTs:
        case MCSDataTypeHLS:
        case MCSDataTypeFILEMask:
            /* return */
            return nil;
        case MCSDataTypeFILE:
            break;
    }
    NSString *pathExtension = response.pathExtension;
    NSString *contentType = response.contentType;
    NSUInteger totalLength = response.totalLength;
    NSUInteger offset = response.range.location;
    __block id<MCSAssetContent>content = nil;
    __block BOOL isUpdated = NO;
    mcs_queue_sync(^{
        if ( _totalLength != totalLength || ![_pathExtension isEqualToString:pathExtension] || ![_contentType isEqualToString:contentType] ) {
            _totalLength = totalLength;
            _pathExtension = pathExtension;
            _contentType = contentType;
            isUpdated = YES;
        }
        
        content = [mProvider createContentAtOffset:offset pathExtension:_pathExtension];
        [content readwriteRetain];
        if ( content != nil ) [mNodeList bringContentToNode:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}

- (void)readwriteCountDidChange:(NSInteger)count {
    if ( count == 0 )
        [self _restructureContents];
}

// 拆分重组内容. 将内容按指定字节拆分重组
- (void)_restructureContents {
    if ( _isStored || self.readwriteCount != 0 ) return;
    UInt64 capacity = 1 * 1024 * 1024;
    FILEAssetContentNode *curNode = mNodeList.head;
    while ( curNode != nil ) {
        [self _removeExcessContentsForNode:curNode];
        FILEAssetContentNode *nextNode = curNode.next;
        if ( nextNode == nil ) break;
        [self _removeExcessContentsForNode:nextNode];
        
        id<MCSAssetContent> write = curNode.longestContent;
        id<MCSAssetContent> read = nextNode.longestContent;
        
        NSRange curRange = {write.startPositionInAsset, write.length};
        NSRange nextRange = {read.startPositionInAsset, read.length};
        if      ( MCSNSRangeContains(curRange, nextRange) ) {
            [mProvider removeContent:read];
            [mNodeList removeNode:nextNode];
        }
        else if ( NSIntersectionRange(curRange, nextRange).location != NSNotFound ) { // 连续的, 存在交集
            NSRange readRange = {NSMaxRange(curRange), NSMaxRange(nextRange) - NSMaxRange(curRange)};   // 读取read中未相交的部分
            [write readwriteRetain];
            [read readwriteRetain];
            NSError *error = nil;
            UInt64 position = readRange.location;
            while ( true ) { @autoreleasepool {
                NSData *data = [read readDataAtPosition:position capacity:capacity error:&error];
                if ( error != nil || data.length == 0 )
                    break;
                if ( ![write writeData:data error:&error] )
                    break;
                position += data.length;
                if ( position == NSMaxRange(readRange) ) break;
            }}
            [read readwriteRelease];
            [read closeRead];
            [write readwriteRelease];
            [write closeWrite];
            
            if ( error == nil ) {
                [mProvider removeContent:read];
                [mNodeList removeNode:nextNode];
            }
        }
        curNode = curNode.next;
    }
    
    _isStored = mNodeList.head.longestContent.length == _totalLength;
}

- (void)_removeExcessContentsForNode:(FILEAssetContentNode *)node {
    NSArray<id<MCSAssetContent>> *contents = node.allContents;
    // 同一段位置可能存在多个文件
    // 删除多余的无用的content
    if ( contents.count > 1 ) {
        [contents enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MCSAssetContent>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( idx != 0 && obj.readwriteCount == 0 ) {
                [mProvider removeContent:obj];
                [node removeContentAtIndex:idx];
            }
        }];
    }
}
@end
