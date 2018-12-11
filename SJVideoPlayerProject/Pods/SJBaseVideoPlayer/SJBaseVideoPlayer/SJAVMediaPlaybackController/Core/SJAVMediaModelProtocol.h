//
//  SJAVMediaModelProtocol.h
//  Pods
//
//  Created by 畅三江 on 2018/8/12.
//

#ifndef SJAVMediaModelProtocol_h
#define SJAVMediaModelProtocol_h

#import "SJMediaPlaybackProtocol.h"
@protocol SJAVMediaModelProtocol<SJMediaModelProtocol>
@property (nonatomic, strong, readonly, nullable) __kindof AVAsset *avAsset;
@end
#endif /* SJAVMediaModelProtocol_h */
