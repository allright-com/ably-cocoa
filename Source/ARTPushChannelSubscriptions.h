//
//  ARTPushChannelSubscriptions.h
//  Ably
//
//  Created by Ricardo Pereira on 20/02/2017.
//  Copyright © 2017 Ably. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ably/ARTTypes.h>

@class ARTPushChannelSubscription;
@class ARTPaginatedResult;
@class ARTRest;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTPushChannelSubscriptionsProtocol

- (instancetype)init NS_UNAVAILABLE;

- (void)save:(ARTPushChannelSubscription *)channelSubscription callback:(void (^)(ARTErrorInfo *_Nullable))callback;

- (void)listChannels:(ARTPaginatedTextCallback)callback;

- (void)list:(NSStringDictionary *)params callback:(ARTPaginatedPushChannelCallback)callback;

- (void)remove:(ARTPushChannelSubscription *)subscription callback:(void (^)(ARTErrorInfo *_Nullable))callback;
- (void)removeWhere:(NSStringDictionary *)params callback:(void (^)(ARTErrorInfo *_Nullable))callback;

@end

@interface ARTPushChannelSubscriptions : NSObject <ARTPushChannelSubscriptionsProtocol>

@end

NS_ASSUME_NONNULL_END
