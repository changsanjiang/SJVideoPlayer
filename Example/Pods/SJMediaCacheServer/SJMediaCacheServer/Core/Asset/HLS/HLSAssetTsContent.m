//
//  HLSAssetTsContent.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/25.
//

#import "HLSAssetTsContent.h"
 
@implementation HLSAssetTsContent
- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength length:(UInt64)length {
    return [self initWithName:name filepath:filepath totalLength:totalLength length:length rangeInAsset:NSMakeRange(0, totalLength)];
}
- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength {
    return [self initWithName:name filepath:filepath totalLength:totalLength length:0];
}

- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength length:(UInt64)length rangeInAsset:(NSRange)range {
    self = [super initWithFilepath:filepath startPositionInAsset:range.location length:length];
    if ( self ) {
        _name = name;
        _rangeInAsset = range;
        _totalLength = totalLength;
    }
    return self;
}
- (instancetype)initWithName:(NSString *)name filepath:(NSString *)filepath totalLength:(UInt64)totalLength rangeInAsset:(NSRange)range {
    return [self initWithName:name filepath:filepath totalLength:totalLength length:0 rangeInAsset:range];
}
@end
