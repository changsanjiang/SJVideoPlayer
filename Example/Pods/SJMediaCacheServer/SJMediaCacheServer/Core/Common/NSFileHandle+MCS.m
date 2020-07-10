//
//  NSFileHandle+MCS.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/9.
//

#import "NSFileHandle+MCS.h"
#import "MCSError.h"

@implementation NSFileHandle (MCS)

- (BOOL)mcs_seekToFileOffset:(NSUInteger)offset error:(out NSError **)error {
    if ( @available(iOS 13.0, *) ) {
        unsigned long long fileOffset = 0;
        if ( ![self getOffset:&fileOffset error:error] ) {
            return NO;
        }
        
        if ( fileOffset == offset )
            return YES;
        
        return [self seekToOffset:offset error:error];
    }
    else {
        @try {
            if ( self.offsetInFile == offset )
                return YES;
            
            [self seekToFileOffset:offset];
            return YES;
        } @catch (NSException *exception) {
            if ( error != nil ) *error = [NSError mcs_exception:exception];
            return NO;
        }
    }
}

@end
