//
//  SJUTAttributes.h
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJUIKitAttributesDefines.h"
#import "SJUTRecorder.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJUTAttributes : NSObject<SJUTAttributesProtocol>
@property (nonatomic, strong, readonly) SJUTRecorder *recorder;
@end
NS_ASSUME_NONNULL_END
