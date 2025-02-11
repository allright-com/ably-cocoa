#import <Ably/ARTRealtimePresence.h>
#import <Ably/ARTRealtimeChannel+Private.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTRealtimePresenceInternal : NSObject <ARTRealtimePresenceProtocol>

- (instancetype)initWithChannel:(ARTRealtimeChannelInternal *)channel logger:(ARTInternalLog *)logger;
- (void)_unsubscribe;
- (BOOL)syncComplete_nosync;

- (void)sendPendingPresence;
- (void)failPendingPresence:(ARTStatus *)status;

@property (nonatomic) dispatch_queue_t queue;
@property (readwrite, nonatomic) ARTPresenceAction lastPresenceAction;
@property (readonly, nonatomic) NSMutableArray<ARTQueuedMessage *> *pendingPresence;

@end

@interface ARTRealtimePresence ()

@property (nonatomic, readonly) ARTRealtimePresenceInternal *internal;

- (instancetype)initWithInternal:(ARTRealtimePresenceInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc;

@end

NS_ASSUME_NONNULL_END
