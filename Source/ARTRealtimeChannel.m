#import "ARTRealtimeChannel+Private.h"
#import "ARTChannel+Private.h"
#import "ARTChannel+Subclass.h"
#import "ARTDataQuery+Private.h"

#import "ARTRealtime+Private.h"
#import "ARTMessage.h"
#import "ARTBaseMessage+Private.h"
#import "ARTAuth.h"
#import "ARTRealtimePresence+Private.h"
#import "ARTChannel.h"
#import "ARTChannelOptions.h"
#import "ARTRealtimeChannelOptions.h"
#import "ARTProtocolMessage.h"
#import "ARTProtocolMessage+Private.h"
#import "ARTPresenceMap.h"
#import "ARTNSArray+ARTFunctional.h"
#import "ARTStatus.h"
#import "ARTDefault.h"
#import "ARTRest.h"
#import "ARTClientOptions.h"
#import "ARTClientOptions+TestConfiguration.h"
#import "ARTTestClientOptions.h"
#import "ARTTypes.h"
#import "ARTTypes+Private.h"
#import "ARTGCD.h"
#import "ARTConnection+Private.h"
#import "ARTRestChannels+Private.h"
#import "ARTEventEmitter+Private.h"
#import "ARTChannelStateChangeMetadata.h"
#import "ARTAttachRequestMetadata.h"
#import "ARTRetrySequence.h"
#import "ARTBackoffRetryDelayCalculator.h"
#import "ARTInternalLog.h"
#import "ARTAttachRetryState.h"
#if TARGET_OS_IPHONE
#import "ARTPushChannel+Private.h"
#endif

@implementation ARTRealtimeChannel {
    ARTQueuedDealloc *_dealloc;
}

- (void)internalAsync:(void (^)(ARTRealtimeChannelInternal * _Nonnull))use {
    dispatch_async(_internal.queue, ^{
        use(self->_internal);
    });
}

- (void)internalSync:(void (^)(ARTRealtimeChannelInternal * _Nonnull))use {
    dispatch_sync(_internal.queue, ^{
        use(self->_internal);
    });
}

- (instancetype)initWithInternal:(ARTRealtimeChannelInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc {
    self = [super init];
    if (self) {
        _internal = internal;
        _dealloc = dealloc;
    }
    return self;
}

- (NSString *)name {
    return _internal.name;
}

- (ARTRealtimeChannelState)state {
    return _internal.state;
}

- (ARTErrorInfo *)errorReason {
    return _internal.errorReason;
}

- (ARTRealtimePresence *)presence {
    return [[ARTRealtimePresence alloc] initWithInternal:_internal.presence queuedDealloc:_dealloc];
}

#if TARGET_OS_IPHONE

- (ARTPushChannel *)push {
    return [[ARTPushChannel alloc] initWithInternal:_internal.push queuedDealloc:_dealloc];
}

#endif

- (void)publish:(nullable NSString *)name data:(nullable id)data {
    [_internal publish:name data:data];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data callback:(nullable ARTCallback)callback {
    [_internal publish:name data:data callback:callback];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId {
    [_internal publish:name data:data clientId:clientId];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId callback:(nullable ARTCallback)callback {
    [_internal publish:name data:data clientId:clientId callback:callback];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data extras:(nullable id<ARTJsonCompatible>)extras {
    [_internal publish:name data:data extras:extras];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data extras:(nullable id<ARTJsonCompatible>)extras callback:(nullable ARTCallback)callback {
    [_internal publish:name data:data extras:extras callback:callback];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId extras:(nullable id<ARTJsonCompatible>)extras {
    [_internal publish:name data:data clientId:clientId extras:extras];
}

- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId extras:(nullable id<ARTJsonCompatible>)extras callback:(nullable ARTCallback)callback {
    [_internal publish:name data:data clientId:clientId extras:extras callback:callback];
}

- (void)publish:(NSArray<ARTMessage *> *)messages {
    [_internal publish:messages];
}

- (void)publish:(NSArray<ARTMessage *> *)messages callback:(nullable ARTCallback)callback {
    [_internal publish:messages callback:callback];
}

- (void)history:(ARTPaginatedMessagesCallback)callback {
    [_internal history:callback];
}

- (BOOL)exceedMaxSize:(NSArray<ARTBaseMessage *> *)messages {
    return [_internal exceedMaxSize:messages];
}

- (void)attach {
    [_internal attach];
}

- (void)attach:(nullable ARTCallback)callback {
    [_internal attach:callback];
}

- (void)detach {
    [_internal detach];
}

- (void)detach:(nullable ARTCallback)callback {
    [_internal detach:callback];
}

- (ARTEventListener *_Nullable)subscribe:(ARTMessageCallback)callback {
    return [_internal subscribe:callback];
}

- (ARTEventListener *_Nullable)subscribeWithAttachCallback:(nullable ARTCallback)onAttach callback:(ARTMessageCallback)cb {
    return [_internal subscribeWithAttachCallback:onAttach callback:cb];
}

- (ARTEventListener *_Nullable)subscribe:(NSString *)name callback:(ARTMessageCallback)cb {
    return [_internal subscribe:name callback:cb];
}

- (ARTEventListener *_Nullable)subscribe:(NSString *)name onAttach:(nullable ARTCallback)onAttach callback:(ARTMessageCallback)cb {
    return [_internal subscribe:name onAttach:onAttach callback:cb];
}

- (void)unsubscribe {
    [_internal unsubscribe];
}

- (void)unsubscribe:(ARTEventListener *_Nullable)listener {
    [_internal unsubscribe:listener];
}

- (void)unsubscribe:(NSString *)name listener:(ARTEventListener *_Nullable)listener {
    [_internal unsubscribe:name listener:listener];
}

- (BOOL)history:(ARTRealtimeHistoryQuery *_Nullable)query callback:(ARTPaginatedMessagesCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr {
    return [_internal history:query callback:callback error:errorPtr];
}

- (ARTEventListener *)on:(ARTChannelStateCallback)cb {
    return [_internal on:cb];
}

- (ARTEventListener *)once:(ARTChannelEvent)event callback:(ARTChannelStateCallback)cb {
    return [_internal once:event callback:cb];
}

- (ARTEventListener *)once:(ARTChannelStateCallback)cb {
    return [_internal once:cb];
}

- (void)off:(ARTChannelEvent)event listener:(ARTEventListener *)listener {
    [_internal off:event listener:listener];
}

- (void)off:(ARTEventListener *)listener {
    [_internal off:listener];
}

- (void)off {
    [_internal off];
}

- (nonnull ARTEventListener *)on:(ARTChannelEvent)event callback:(nonnull ARTChannelStateCallback)cb {
    return [_internal on:event callback:cb];
}

- (ARTRealtimeChannelOptions *)getOptions {
    return [_internal getOptions];
}

- (void)setOptions:(ARTRealtimeChannelOptions *_Nullable)options callback:(nullable ARTCallback)cb {
    [_internal setOptions:options callback:cb];
}

@end

@interface ARTRealtimeChannelInternal () {
    ARTRealtimePresenceInternal *_realtimePresence;
    #if TARGET_OS_IPHONE
    ARTPushChannelInternal *_pushChannel;
    #endif
    CFRunLoopTimerRef _attachTimer;
    CFRunLoopTimerRef _detachTimer;
    ARTEventEmitter<ARTEvent *, ARTErrorInfo *> *_attachedEventEmitter;
    ARTEventEmitter<ARTEvent *, ARTErrorInfo *> *_detachedEventEmitter;
    NSString * _Nullable _lastPayloadMessageId;
    NSString * _Nullable _lastPayloadProtocolMessageChannelSerial;
    BOOL _decodeFailureRecoveryInProgress;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface ARTRealtimeChannelInternal ()

@property (nonatomic, readonly) ARTAttachRetryState *attachRetryState;

@end

NS_ASSUME_NONNULL_END

@implementation ARTRealtimeChannelInternal {
    dispatch_queue_t _queue;
    dispatch_queue_t _userQueue;
    ARTErrorInfo *_errorReason;
}

- (instancetype)initWithRealtime:(ARTRealtimeInternal *)realtime andName:(NSString *)name withOptions:(ARTRealtimeChannelOptions *)options logger:(ARTInternalLog *)logger {
    self = [super initWithName:name andOptions:options rest:realtime.rest logger:logger];
    if (self) {
        _realtime = realtime;
        _queue = realtime.rest.queue;
        _userQueue = realtime.rest.userQueue;
        _restChannel = [_realtime.rest.channels _getChannel:self.name options:options addPrefix:true];
        _state = ARTRealtimeChannelInitialized;
        _attachSerial = nil;
        _presenceMap = [[ARTPresenceMap alloc] initWithQueue:_queue logger:self.logger];
        _presenceMap.delegate = self;
        _statesEventEmitter = [[ARTPublicEventEmitter alloc] initWithRest:_realtime.rest logger:logger];
        _messagesEventEmitter = [[ARTInternalEventEmitter alloc] initWithQueues:_queue userQueue:_userQueue];
        _presenceEventEmitter = [[ARTInternalEventEmitter alloc] initWithQueue:_queue];
        _attachedEventEmitter = [[ARTInternalEventEmitter alloc] initWithQueue:_queue];
        _detachedEventEmitter = [[ARTInternalEventEmitter alloc] initWithQueue:_queue];
        _internalEventEmitter = [[ARTInternalEventEmitter alloc] initWithQueue:_queue];
        const id<ARTRetryDelayCalculator> attachRetryDelayCalculator = [[ARTBackoffRetryDelayCalculator alloc] initWithInitialRetryTimeout:realtime.options.channelRetryTimeout
                                                                                                                jitterCoefficientGenerator:realtime.options.testOptions.jitterCoefficientGenerator];
        _attachRetryState = [[ARTAttachRetryState alloc] initWithRetryDelayCalculator:attachRetryDelayCalculator
                                                                               logger:logger
                                                                     logMessagePrefix:[NSString stringWithFormat:@"RT: %p C:%p ", _realtime, self]];
    }
    return self;
}

- (ARTRealtimeChannelState)state {
    __block ARTRealtimeChannelState ret;
dispatch_sync(_queue, ^{
    ret = [self state_nosync];
});
    return ret;
}

- (ARTErrorInfo *)errorReason {
    __block ARTErrorInfo * ret;
dispatch_sync(_queue, ^{
    ret = [self errorReason_nosync];
});
    return ret;
}

- (ARTRealtimeChannelState)state_nosync {
    return _state;
}

- (BOOL)canBeReattached {
    switch (self.state_nosync) {
        case ARTRealtimeChannelAttaching:
        case ARTRealtimeChannelAttached:
        case ARTRealtimeChannelSuspended:
            return YES;
        default:
            return NO;
    }
}

- (ARTErrorInfo *)errorReason_nosync {
    return _errorReason;
}

- (ARTRealtimePresenceInternal *)presence {
    if (!_realtimePresence) {
        _realtimePresence = [[ARTRealtimePresenceInternal alloc] initWithChannel:self logger:self.logger];
    }
    return _realtimePresence;
}

#if TARGET_OS_IPHONE
- (ARTPushChannelInternal *)push {
    if (!_pushChannel) {
        _pushChannel = [[ARTPushChannelInternal alloc] init:self.realtime.rest withChannel:self logger:self.logger];
    }
    return _pushChannel;
}
#endif

- (void)internalPostMessages:(id)data callback:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *__nullable error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

    if (![data isKindOfClass:[NSArray class]]) {
        data = @[data];
    }

dispatch_sync(_queue, ^{
    if ([data isKindOfClass:[ARTMessage class]]) {
        ARTMessage *message = (ARTMessage *)data;
        if (message.clientId && self->_realtime.rest.auth.clientId_nosync && ![message.clientId isEqualToString:self->_realtime.rest.auth.clientId_nosync]) {
            if (callback)
                callback([ARTErrorInfo createWithCode:ARTStateMismatchedClientId message:@"attempted to publish message with an invalid clientId"]);
            return;
        }
    }
    else if ([data isKindOfClass:[NSArray class]]) {
        NSArray<ARTMessage *> *messages = (NSArray *)data;
        for (ARTMessage *message in messages) {
            if (message.clientId && self->_realtime.rest.auth.clientId_nosync && ![message.clientId isEqualToString:self->_realtime.rest.auth.clientId_nosync]) {
                if (callback)
                    callback([ARTErrorInfo createWithCode:ARTStateMismatchedClientId message:@"attempted to publish message with an invalid clientId"]);
                return;
            }
        }
    }

    if (!self.realtime.connection.isActive_nosync) {
        if (callback)
            callback([self.realtime.connection error_nosync]);
        return;
    }

    ARTProtocolMessage *msg = [[ARTProtocolMessage alloc] init];
    msg.action = ARTProtocolMessageMessage;
    msg.channel = self.name;
    msg.messages = data;

    [self publishProtocolMessage:msg callback:^void(ARTStatus *status) {
        if (callback)
            callback(status.errorInfo);
    }];
});
}

- (void)sync {
    [self sync:nil];
}

- (void)sync:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *__nullable error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

    switch (self.state_nosync) {
        case ARTRealtimeChannelInitialized:
        case ARTRealtimeChannelDetaching:
        case ARTRealtimeChannelDetached: {
            ARTErrorInfo *error = [ARTErrorInfo createWithCode:ARTErrorBadRequest
                                                       message:@"Unable to sync to channel; not attached."];
            ARTLogError(self.logger, @"%@", error.message);
            if (callback) callback(error);
            return;
        }
        default:
            break;
    }

    ARTLogVerbose(self.logger, @"R:%p C:%p (%@) requesting a sync operation", _realtime, self, self.name);

    ARTProtocolMessage *msg = [[ARTProtocolMessage alloc] init];
    msg.action = ARTProtocolMessageSync;
    msg.channel = self.name;
    msg.channelSerial = self.presenceMap.syncChannelSerial;

    [self.presenceMap startSync];
    [self.realtime send:msg sentCallback:^(ARTErrorInfo *error) {
        if (error) {
            ARTLogDebug(self.logger, @"R:%p C:%p (%@) SYNC request failed with %@", self->_realtime, self, self.name, error);
            [self.presenceMap endSync];
            if (callback) callback(error);
        }
        else {
            ARTLogDebug(self.logger, @"R:%p C:%p (%@) SYNC requested with success", self->_realtime, self, self.name);
            if (callback) callback(nil);
        }
    } ackCallback:nil];
}

- (void)publishProtocolMessage:(ARTProtocolMessage *)pm callback:(ARTStatusCallback)cb {
    switch (self.state_nosync) {
        case ARTRealtimeChannelSuspended:
        case ARTRealtimeChannelFailed: {
            if (cb) {
                ARTStatus *statusInvalidChannelState = [ARTStatus state:ARTStateError info:[ARTErrorInfo createWithCode:ARTErrorChannelOperationFailedInvalidState message:[NSString stringWithFormat:@"channel operation failed (invalid channel state: %@)", ARTRealtimeChannelStateToStr(self.state_nosync)]]];
                cb(statusInvalidChannelState);
            }
            break;
        }
        case ARTRealtimeChannelInitialized:
        case ARTRealtimeChannelDetaching:
        case ARTRealtimeChannelDetached:
        case ARTRealtimeChannelAttaching:
        case ARTRealtimeChannelAttached: {
            [self.realtime send:pm sentCallback:nil ackCallback:^(ARTStatus *status) {
                if (cb) cb(status);
            }];
            break;
        }
    }
}

- (ARTPresenceMap *)presenceMap {
    return _presenceMap;
}

- (void)throwOnDisconnectedOrFailed {
    if (self.realtime.connection.state_nosync == ARTRealtimeFailed || self.realtime.connection.state_nosync == ARTRealtimeDisconnected) {
        [ARTException raise:@"realtime cannot perform action in disconnected or failed state" format:@"state: %d", (int)self.realtime.connection.state_nosync];
    }
}

- (ARTEventListener *)subscribe:(ARTMessageCallback)callback {
    return [self subscribeWithAttachCallback:nil callback:callback];
}

- (ARTEventListener *)subscribeWithAttachCallback:(ARTCallback)onAttach callback:(ARTMessageCallback)cb {
    if (cb) {
        ARTMessageCallback userCallback = cb;
        cb = ^(ARTMessage *_Nonnull m) {
            if (self.state_nosync != ARTRealtimeChannelAttached) { //RTL17
                return;
            }
            dispatch_async(self->_userQueue, ^{
                userCallback(m);
            });
        };
    }
    if (onAttach) {
        ARTCallback userOnAttach = onAttach;
        onAttach = ^(ARTErrorInfo *_Nullable e) {
            dispatch_async(self->_userQueue, ^{
                userOnAttach(e);
            });
        };
    }

    __block ARTEventListener *listener = nil;
dispatch_sync(_queue, ^{
    if (self.state_nosync == ARTRealtimeChannelFailed) {
        if (onAttach) onAttach([ARTErrorInfo createWithCode:0 message:@"attempted to subscribe while channel is in FAILED state."]);
        ARTLogWarn(self.logger, @"R:%p C:%p (%@) subscribe has been ignored (attempted to subscribe while channel is in FAILED state)", self->_realtime, self, self.name);
        return;
    }
    if (self.state_nosync == ARTRealtimeChannelInitialized) { //RTL7c
        [self _attach:onAttach];
    }
    listener = [self.messagesEventEmitter on:cb];
    ARTLogVerbose(self.logger, @"R:%p C:%p (%@) subscribe to all events", self->_realtime, self, self.name);
});
    return listener;
}

- (ARTEventListener *)subscribe:(NSString *)name callback:(ARTMessageCallback)cb {
    return [self subscribe:name onAttach:nil callback:cb];
}

- (ARTEventListener *)subscribe:(NSString *)name onAttach:(ARTCallback)onAttach callback:(ARTMessageCallback)cb {
    if (cb) {
        ARTMessageCallback userCallback = cb;
        cb = ^(ARTMessage *_Nonnull m) {
            dispatch_async(self->_userQueue, ^{
                userCallback(m);
            });
        };
    }
    if (onAttach) {
        ARTCallback userOnAttach = onAttach;
        onAttach = ^(ARTErrorInfo *_Nullable e) {
            dispatch_async(self->_userQueue, ^{
                userOnAttach(e);
            });
        };
    }

    __block ARTEventListener *listener = nil;
dispatch_sync(_queue, ^{
    if (self.state_nosync == ARTRealtimeChannelFailed) {
        if (onAttach) onAttach([ARTErrorInfo createWithCode:0 message:@"attempted to subscribe while channel is in FAILED state."]);
        ARTLogWarn(self.logger, @"R:%p C:%p (%@) subscribe of '%@' has been ignored (attempted to subscribe while channel is in FAILED state)", self->_realtime, self, self.name, name);
        return;
    }
    [self _attach:onAttach];
    listener = [self.messagesEventEmitter on:name callback:cb];
    ARTLogVerbose(self.logger, @"R:%p C:%p (%@) subscribe to event '%@'", self->_realtime, self, self.name, name);
});
    return listener;
}

- (void)unsubscribe {
dispatch_sync(_queue, ^{
    [self _unsubscribe];
    ARTLogVerbose(self.logger, @"R:%p C:%p (%@) unsubscribe to all events", self->_realtime, self, self.name);
});
}

- (void)_unsubscribe {
    [self.messagesEventEmitter off];
}

- (void)unsubscribe:(ARTEventListener *)listener {
dispatch_sync(_queue, ^{
    [self.messagesEventEmitter off:listener];
    ARTLogVerbose(self.logger, @"RT:%p C:%p (%@) unsubscribe to all events", self->_realtime, self, self.name);
});
}

- (void)unsubscribe:(NSString *)name listener:(ARTEventListener *)listener {
dispatch_sync(_queue, ^{
    [self.messagesEventEmitter off:name listener:listener];
    ARTLogVerbose(self.logger, @"RT:%p C:%p (%@) unsubscribe to event '%@'", self->_realtime, self, self.name, name);
});
}

- (ARTEventListener *)on:(ARTChannelEvent)event callback:(ARTChannelStateCallback)cb {
    return [self.statesEventEmitter on:[ARTEvent newWithChannelEvent:event] callback:cb];
}

- (ARTEventListener *)on:(ARTChannelStateCallback)cb {
    return [self.statesEventEmitter on:cb];
}

- (ARTEventListener *)once:(ARTChannelEvent)event callback:(ARTChannelStateCallback)cb {
    return [self.statesEventEmitter once:[ARTEvent newWithChannelEvent:event] callback:cb];
}

- (ARTEventListener *)once:(ARTChannelStateCallback)cb {
    return [self.statesEventEmitter once:cb];
}

- (void)off {
    [self.statesEventEmitter off];
}


- (void)off_nosync {
    [(ARTPublicEventEmitter *)self.statesEventEmitter off_nosync];
}

- (void)off:(ARTChannelEvent)event listener:listener {
    [self.statesEventEmitter off:[ARTEvent newWithChannelEvent:event] listener:listener];
}

- (void)off:(ARTEventListener *)listener {
    [self.statesEventEmitter off:listener];
}

- (void)emit:(ARTChannelEvent)event with:(ARTChannelStateChange *)data {
    [self.statesEventEmitter emit:[ARTEvent newWithChannelEvent:event] with:data];
    [self.internalEventEmitter emit:[ARTEvent newWithChannelEvent:event] with:data];
}

- (void)transition:(ARTRealtimeChannelState)state withMetadata:(ARTChannelStateChangeMetadata *)metadata {
    ARTLogDebug(self.logger, @"RT:%p C:%p (%@) channel state transitions from %tu - %@ to %tu - %@%@", _realtime, self, self.name, self.state_nosync, ARTRealtimeChannelStateToStr(self.state_nosync), state, ARTRealtimeChannelStateToStr(state), metadata.retryAttempt ? [NSString stringWithFormat: @" (result of %@)", metadata.retryAttempt.id] : @"");
    ARTChannelStateChange *stateChange = [[ARTChannelStateChange alloc] initWithCurrent:state previous:self.state_nosync event:(ARTChannelEvent)state reason:metadata.errorInfo resumed:NO retryAttempt:metadata.retryAttempt];
    self.state = state;

    if (metadata.storeErrorInfo) {
        _errorReason = metadata.errorInfo;
    }

    [self.attachRetryState channelWillTransitionToState:state];

    ARTEventListener *channelRetryListener = nil;
    switch (state) {
        case ARTRealtimeChannelAttached:
            self.attachResume = true;
            break;
        case ARTRealtimeChannelSuspended: {
            ARTRetryAttempt *const retryAttempt = [self.attachRetryState addRetryAttempt];

            [_attachedEventEmitter emit:nil with:metadata.errorInfo];
            if (self.realtime.shouldSendEvents) {
                channelRetryListener = [self unlessStateChangesBefore:retryAttempt.delay do:^{
                    ARTLogDebug(self.logger, @"RT:%p C:%p (%@) reattach initiated by retry timeout, acting on retry attempt %@", self->_realtime, self, self.name, retryAttempt.id);
                    ARTAttachRequestMetadata *const attachMetadata = [[ARTAttachRequestMetadata alloc] initWithReason:nil
                                                                                                        channelSerial:nil
                                                                                                         retryAttempt:retryAttempt];
                    [self reattachWithMetadata:attachMetadata];
                }];
            }
            break;
        }
        case ARTRealtimeChannelDetaching:
            self.attachResume = false;
            break;
        case ARTRealtimeChannelDetached:
            [self.presenceMap failsSync:metadata.errorInfo];
            break;
        case ARTRealtimeChannelFailed:
            self.attachResume = false;
            [_attachedEventEmitter emit:nil with:metadata.errorInfo];
            [_detachedEventEmitter emit:nil with:metadata.errorInfo];
            [self.presenceMap failsSync:metadata.errorInfo];
            break;
        default:
            break;
    }

    [self emit:stateChange.event with:stateChange];

    if (channelRetryListener) {
        [channelRetryListener startTimer];
    }
}

- (ARTEventListener *)unlessStateChangesBefore:(NSTimeInterval)deadline do:(void(^)(void))callback {
    return [[self.internalEventEmitter once:^(ARTChannelStateChange *stateChange) {
        // Any state change cancels the timeout.
    }] setTimer:deadline onTimeout:^{
        if (callback) {
            callback();
        }
    }];
}

/**
 Checks that a channelSerial is the final serial in a sequence of sync messages,
 by checking that there is nothing after the colon
 */
- (bool)isLastChannelSerial:(NSString *)channelSerial {
    NSArray * a = [channelSerial componentsSeparatedByString:@":"];
    if([a count] >1 && ![[a objectAtIndex:1] isEqualToString:@""] ) {
        return false;
    }
    return true;
}

- (void)onChannelMessage:(ARTProtocolMessage *)message {
    ARTLogDebug(self.logger, @"R:%p C:%p (%@) received channel message %tu - %@", _realtime, self, self.name, message.action, ARTProtocolMessageActionToStr(message.action));
    switch (message.action) {
        case ARTProtocolMessageAttached:
            ARTLogDebug(self.logger, @"R:%p C:%p (%@) %@", _realtime, self, self.name, message.description);
            [self setAttached:message];
            break;
        case ARTProtocolMessageDetach:
        case ARTProtocolMessageDetached:
            [self setDetached:message];
            break;
        case ARTProtocolMessageMessage:
            if (_decodeFailureRecoveryInProgress) {
                ARTLogDebug(self.logger, @"R:%p C:%p (%@) message decode recovery in progress, message skipped: %@", _realtime, self, self.name, message.description);
                break;
            }
            [self onMessage:message];
            break;
        case ARTProtocolMessagePresence:
            [self onPresence:message];
            break;
        case ARTProtocolMessageError:
            [self onError:message];
            break;
        case ARTProtocolMessageSync:
            [self onSync:message];
            break;
        default:
            ARTLogWarn(self.logger, @"R:%p C:%p (%@) unknown ARTProtocolMessage action: %tu", _realtime, self, self.name, message.action);
            break;
    }
}

- (void)setAttached:(ARTProtocolMessage *)message {
    switch (self.state_nosync) {
        case ARTRealtimeChannelDetaching:
        case ARTRealtimeChannelFailed:
            // Ignore
            return;
        default:
            break;
    }

    if (message.resumed) {
        ARTLogDebug(self.logger, @"R:%p C:%p (%@) channel has resumed", _realtime, self, self.name);
    }

    self.attachSerial = message.channelSerial;

    if (message.hasPresence) {
        [self.presenceMap startSync];
    }
    else if ([self.presenceMap.members count] > 0 || [self.presenceMap.localMembers count] > 0) {
        if (!message.resumed) {
            // When an ATTACHED message is received without a HAS_PRESENCE flag and PresenceMap has existing members
            [self.presenceMap startSync];
            [self.presenceMap endSync];
            ARTLogDebug(self.logger, @"R:%p C:%p (%@) PresenceMap has been reset", _realtime, self, self.name);
        }
    }

    if (self.state_nosync == ARTRealtimeChannelAttached) {
        if (message.error != nil) {
            _errorReason = message.error;
        }
        ARTChannelStateChange *stateChange = [[ARTChannelStateChange alloc] initWithCurrent:self.state_nosync previous:self.state_nosync event:ARTChannelEventUpdate reason:message.error resumed:message.resumed];
        [self emit:stateChange.event with:stateChange];
        return;
    }

    ARTChannelStateChangeMetadata *metadata;
    if (message.error) {
        metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateError errorInfo:message.error];
    } else {
        metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateOk];
    }
    [self transition:ARTRealtimeChannelAttached withMetadata:metadata];
    [_attachedEventEmitter emit:nil with:nil];

    [self.presence sendPendingPresence];
}

- (void)setDetached:(ARTProtocolMessage *)message {
    switch (self.state_nosync) {
        case ARTRealtimeChannelAttached:
        case ARTRealtimeChannelSuspended: {
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) reattach initiated by DETACHED message", _realtime, self, self.name);
            ARTAttachRequestMetadata *const metadata = [[ARTAttachRequestMetadata alloc] initWithReason:message.error];
            [self reattachWithMetadata:metadata];
            return;
        }
        case ARTRealtimeChannelAttaching: {
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) reattach initiated by DETACHED message but it is currently attaching", _realtime, self, self.name);
            const ARTState state = message.error ? ARTStateError : ARTStateOk;
            ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:state
                                                                                                       errorInfo:message.error
                                                                                                  storeErrorInfo:NO];
            [self setSuspended:metadata];
            return;
        }
        case ARTRealtimeChannelFailed:
            return;
        default:
            break;
    }

    self.attachSerial = nil;

    ARTErrorInfo *errorInfo = message.error ? message.error : [ARTErrorInfo createWithCode:0 message:@"channel has detached"];
    ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateNotAttached
                                                                                               errorInfo:errorInfo];
    [self detachChannel:metadata];
    [_detachedEventEmitter emit:nil with:nil];
}

- (void)failPendingPresenceWithState:(ARTState)state info:(nullable ARTErrorInfo *)info {
    ARTStatus *const status = [ARTStatus state:state info:info];
    [self.presence failPendingPresence:status];
}

- (void)detachChannel:(ARTChannelStateChangeMetadata *)metadata {
    if (self.state_nosync == ARTRealtimeChannelDetached) {
        return;
    }
    [self failPendingPresenceWithState:metadata.state info:metadata.errorInfo];
    [self transition:ARTRealtimeChannelDetached withMetadata:metadata];
}

- (void)setFailed:(ARTChannelStateChangeMetadata *)metadata {
    [self failPendingPresenceWithState:metadata.state info:metadata.errorInfo];
    [self transition:ARTRealtimeChannelFailed withMetadata:metadata];
}

- (void)setSuspended:(ARTChannelStateChangeMetadata *)metadata {
    [self failPendingPresenceWithState:metadata.state info:metadata.errorInfo];
    [self transition:ARTRealtimeChannelSuspended withMetadata:metadata];
}

- (void)onMessage:(ARTProtocolMessage *)pm {
    int i = 0;

    ARTMessage *firstMessage = pm.messages.firstObject;
    if (firstMessage.extras) {
        NSError *extrasDecodeError;
        NSDictionary *const extras = [firstMessage.extras toJSON:&extrasDecodeError];
        if (extrasDecodeError) {
            ARTLogError(self.logger, @"R:%p C:%p (%@) message extras %@ decode error: %@", _realtime, self, self.name, firstMessage.extras, extrasDecodeError);
        }
        else {
            NSString *const deltaFrom = [[extras objectForKey:@"delta"] objectForKey:@"from"];
            if (deltaFrom && _lastPayloadMessageId && ![deltaFrom isEqualToString:_lastPayloadMessageId]) {
                ARTErrorInfo *incompatibleIdError = [ARTErrorInfo createWithCode:ARTErrorUnableToDecodeMessage message:[NSString stringWithFormat:@"previous id '%@' is incompatible with message delta %@", _lastPayloadMessageId, firstMessage]];
                ARTLogError(self.logger, @"R:%p C:%p (%@) %@", _realtime, self, self.name, incompatibleIdError.message);
                for (int j = i + 1; j < pm.messages.count; j++) {
                    ARTLogVerbose(self.logger, @"R:%p C:%p (%@) message skipped %@", _realtime, self, self.name, pm.messages[j]);
                }
                [self startDecodeFailureRecoveryWithChannelSerial:_lastPayloadProtocolMessageChannelSerial error:incompatibleIdError];
                return;
            }
        }
    }

    ARTDataEncoder *dataEncoder = self.dataEncoder;
    for (ARTMessage *m in pm.messages) {
        ARTMessage *msg = m;

        if (msg.data && dataEncoder) {
            NSError *decodeError = nil;
            msg = [msg decodeWithEncoder:dataEncoder error:&decodeError];
            if (decodeError) {
                ARTErrorInfo *errorInfo = [ARTErrorInfo wrap:[ARTErrorInfo createWithCode:ARTErrorUnableToDecodeMessage message:decodeError.localizedFailureReason] prepend:@"Failed to decode data: "];
                ARTLogError(self.logger, @"R:%p C:%p (%@) %@", _realtime, self, self.name, errorInfo.message);
                _errorReason = errorInfo;
                ARTChannelStateChange *stateChange = [[ARTChannelStateChange alloc] initWithCurrent:self.state_nosync previous:self.state_nosync event:ARTChannelEventUpdate reason:errorInfo];
                [self emit:stateChange.event with:stateChange];

                if (decodeError.code == ARTErrorUnableToDecodeMessage) {
                    [self startDecodeFailureRecoveryWithChannelSerial:_lastPayloadProtocolMessageChannelSerial error:errorInfo];
                    return;
                }
            }
        }

        if (!msg.timestamp) {
            msg.timestamp = pm.timestamp;
        }
        if (!msg.id) {
            msg.id = [NSString stringWithFormat:@"%@:%d", pm.id, i];
        }

        _lastPayloadMessageId = msg.id;

        [self.messagesEventEmitter emit:msg.name with:msg];

        ++i;
    }

    _lastPayloadProtocolMessageChannelSerial = pm.channelSerial;
}

- (void)onPresence:(ARTProtocolMessage *)message {
    ARTLogDebug(self.logger, @"RT:%p C:%p (%@) handle PRESENCE message", _realtime, self, self.name);
    int i = 0;
    ARTDataEncoder *dataEncoder = self.dataEncoder;
    for (ARTPresenceMessage *p in message.presence) {
        ARTPresenceMessage *presence = p;
        if (presence.data && dataEncoder) {
            NSError *decodeError = nil;
            presence = [p decodeWithEncoder:dataEncoder error:&decodeError];
            if (decodeError != nil) {
                ARTErrorInfo *errorInfo = [ARTErrorInfo wrap:[ARTErrorInfo createWithCode:ARTErrorUnableToDecodeMessage message:decodeError.localizedFailureReason] prepend:@"Failed to decode data: "];
                ARTLogError(self.logger, @"RT:%p C:%p (%@) %@", _realtime, self, self.name, errorInfo.message);
            }
        }

        if (!presence.timestamp) {
            presence.timestamp = message.timestamp;
        }

        if (!presence.id) {
            presence.id = [NSString stringWithFormat:@"%@:%d", message.id, i];
        }

        if ([self.presenceMap add:presence]) {
            [self broadcastPresence:presence];
        }

        ++i;
    }
}

- (void)onSync:(ARTProtocolMessage *)message {
    self.presenceMap.syncMsgSerial = [message.msgSerial longLongValue];
    self.presenceMap.syncChannelSerial = message.channelSerial;

    if (!self.presenceMap.syncInProgress) {
        [self.presenceMap startSync];
    }
    else {
        ARTLogDebug(self.logger, @"RT:%p C:%p (%@) PresenceMap sync is in progress", _realtime, self, self.name);
    }

    for (int i=0; i<[message.presence count]; i++) {
        ARTPresenceMessage *presence = [message.presence objectAtIndex:i];
        if ([self.presenceMap add:presence]) {
            [self broadcastPresence:presence];
        }
    }

    if ([self isLastChannelSerial:message.channelSerial]) {
        [self.presenceMap endSync];
        self.presenceMap.syncChannelSerial = nil;
        ARTLogDebug(self.logger, @"RT:%p C:%p (%@) PresenceMap sync ended", _realtime, self, self.name);
    }
}

- (void)broadcastPresence:(ARTPresenceMessage *)pm {
    [self.presenceEventEmitter emit:[ARTEvent newWithPresenceAction:pm.action] with:pm];
}

- (void)onError:(ARTProtocolMessage *)msg {
    ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateError
                                                                                               errorInfo:msg.error];
    [self transition:ARTRealtimeChannelFailed withMetadata:metadata];
    [self failPendingPresenceWithState:ARTStateError info:msg.error];
}

- (void)attach {
    [self attach:nil];
}

- (void)attach:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *__nullable error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }
dispatch_sync(_queue, ^{
    [self _attach:callback];
});
}

- (void)_attach:(ARTCallback)callback {
    switch (self.state_nosync) {
        case ARTRealtimeChannelAttaching:
            ARTLogVerbose(self.logger, @"RT:%p C:%p (%@) already attaching", _realtime, self, self.name);
            if (callback) [_attachedEventEmitter once:callback];
            return;
        case ARTRealtimeChannelAttached:
            ARTLogVerbose(self.logger, @"RT:%p C:%p (%@) already attached", _realtime, self, self.name);
            if (callback) callback(nil);
            return;
        default:
            break;
    }
    ARTAttachRequestMetadata *const metadata = [[ARTAttachRequestMetadata alloc] initWithReason:nil];
    [self internalAttach:callback metadata:metadata];
}

- (void)reattachWithMetadata:(ARTAttachRequestMetadata *)metadata {
    if ([self canBeReattached]) {
        ARTLogDebug(self.logger, @"RT:%p C:%p (%@) %@ and will reattach", _realtime, self, self.name, ARTRealtimeChannelStateToStr(self.state_nosync));
        [self internalAttach:nil metadata:metadata];
    } else {
        ARTLogDebug(self.logger, @"RT:%p C:%p (%@) %@ should not reattach", _realtime, self, self.name, ARTRealtimeChannelStateToStr(self.state_nosync));
    }
}

- (void)internalAttach:(ARTCallback)callback metadata:(ARTAttachRequestMetadata *)metadata {
    switch (self.state_nosync) {
        case ARTRealtimeChannelDetaching: {
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) attach after the completion of Detaching", _realtime, self, self.name);
            [_detachedEventEmitter once:^(ARTErrorInfo *error) {
                [self _attach:callback];
            }];
            return;
        }
        default:
            break;
    }

    _errorReason = nil;

    if (![self.realtime isActive]) {
        ARTLogDebug(self.logger, @"RT:%p C:%p (%@) can't attach when not in an active state", _realtime, self, self.name);
        if (callback) callback([ARTErrorInfo createWithCode:ARTErrorChannelOperationFailed message:@"Can't attach when not in an active state"]);
        return;
    }

    if (callback) [_attachedEventEmitter once:callback];
    // Set state: Attaching
    const ARTState stateChangeMetadataState = metadata.reason ? ARTStateError : ARTStateOk;
    ARTChannelStateChangeMetadata *const stateChangeMetadata = [[ARTChannelStateChangeMetadata alloc] initWithState:stateChangeMetadataState
                                                                                                          errorInfo:metadata.reason
                                                                                                     storeErrorInfo:NO
                                                                                                       retryAttempt:metadata.retryAttempt];
    [self transition:ARTRealtimeChannelAttaching withMetadata:stateChangeMetadata];

    [self attachAfterChecks:callback channelSerial:metadata.channelSerial];
}

- (void)attachAfterChecks:(ARTCallback)callback channelSerial:(NSString *)channelSerial {
    ARTProtocolMessage *attachMessage = [[ARTProtocolMessage alloc] init];
    attachMessage.action = ARTProtocolMessageAttach;
    attachMessage.channel = self.name;
    attachMessage.channelSerial = channelSerial;
    attachMessage.params = self.options_nosync.params;
    attachMessage.flags = self.options_nosync.modes;

    if (self.attachResume) {
        attachMessage.flags = attachMessage.flags | ARTProtocolMessageFlagAttachResume;
    }

    [self.realtime send:attachMessage sentCallback:^(ARTErrorInfo *error) {
        if (error) {
            return;
        }
        // Set attach timer after the connection is active
        [[self unlessStateChangesBefore:self.realtime.options.testOptions.realtimeRequestTimeout do:^{
            // Timeout
            ARTErrorInfo *errorInfo = [ARTErrorInfo createWithCode:ARTStateAttachTimedOut message:@"attach timed out"];
            ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateAttachTimedOut
                                                                                                       errorInfo:errorInfo];
            [self setSuspended:metadata];
        }] startTimer];
    } ackCallback:nil];

    if (![self.realtime shouldQueueEvents]) {
        ARTEventListener *reconnectedListener = [self.realtime.connectedEventEmitter once:^(NSNull *n) {
            // Disconnected and connected while attaching, re-attach.
            [self attachAfterChecks:callback channelSerial:channelSerial];
        }];
        [_attachedEventEmitter once:^(ARTErrorInfo *err) {
            [self.realtime.connectedEventEmitter off:reconnectedListener];
        }];
    }
}

- (void)detach:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *__nullable error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }
dispatch_sync(_queue, ^{
    [self _detach:callback];
});
}

- (void)_detach:(ARTCallback)callback {
    switch (self.state_nosync) {
        case ARTRealtimeChannelInitialized:
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) can't detach when not attached", _realtime, self, self.name);
            if (callback) callback(nil);
            return;
        case ARTRealtimeChannelAttaching: {
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) waiting for the completion of the attaching operation", _realtime, self, self.name);
            [_attachedEventEmitter once:^(ARTErrorInfo *errorInfo) {
                if (callback && errorInfo) {
                    callback(errorInfo);
                    return;
                }
                [self _detach:callback];
            }];
            return;
        }
        case ARTRealtimeChannelDetaching:
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) already detaching", _realtime, self, self.name);
            if (callback) [_detachedEventEmitter once:callback];
            return;
        case ARTRealtimeChannelDetached:
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) already detached", _realtime, self, self.name);
            if (callback) callback(nil);
            return;
        case ARTRealtimeChannelSuspended: {
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) transitions immediately to the detached", _realtime, self, self.name);
            ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateOk];
            [self transition:ARTRealtimeChannelDetached withMetadata:metadata];
            if (callback) callback(nil);
            return;
        }
        case ARTRealtimeChannelFailed:
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) can't detach when in a failed state", _realtime, self, self.name);
            if (callback) callback([ARTErrorInfo createWithCode:ARTErrorChannelOperationFailed message:@"can't detach when in a failed state"]);
            return;
        default:
            break;
    }

    if (![self.realtime isActive]) {
        ARTLogDebug(self.logger, @"RT:%p C:%p (%@) can't detach when not in an active state", _realtime, self, self.name);
        if (callback) callback([ARTErrorInfo createWithCode:ARTErrorChannelOperationFailed message:@"Can't detach when not in an active state"]);
        return;
    }

    if (callback) [_detachedEventEmitter once:callback];
    // Set state: Detaching
    ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateOk];
    [self transition:ARTRealtimeChannelDetaching withMetadata:metadata];

    [self detachAfterChecks:callback];
}

- (void)detachAfterChecks:(ARTCallback)callback {
    ARTProtocolMessage *detachMessage = [[ARTProtocolMessage alloc] init];
    detachMessage.action = ARTProtocolMessageDetach;
    detachMessage.channel = self.name;

    [self.realtime send:detachMessage sentCallback:nil ackCallback:nil];

    [[self unlessStateChangesBefore:self.realtime.options.testOptions.realtimeRequestTimeout do:^{
        if (!self.realtime) {
            return;
        }
        // Timeout
        ARTErrorInfo *errorInfo = [ARTErrorInfo createWithCode:ARTStateDetachTimedOut message:@"detach timed out"];
        ARTChannelStateChangeMetadata *const metadata = [[ARTChannelStateChangeMetadata alloc] initWithState:ARTStateAttachTimedOut
                                                                                                   errorInfo:errorInfo];
        [self transition:ARTRealtimeChannelAttached withMetadata:metadata];
        [self->_detachedEventEmitter emit:nil with:errorInfo];
    }] startTimer];

    if (![self.realtime shouldQueueEvents]) {
        ARTEventListener *reconnectedListener = [self.realtime.connectedEventEmitter once:^(NSNull *n) {
            // Disconnected and connected while detaching, re-detach.
            [self detachAfterChecks:callback];
        }];
        [_detachedEventEmitter once:^(ARTErrorInfo *err) {
            [self.realtime.connectedEventEmitter off:reconnectedListener];
        }];
    }

    if (self.presenceMap.syncInProgress) {
        [self.presenceMap failsSync:[ARTErrorInfo createWithCode:ARTErrorChannelOperationFailed message:@"channel is being DETACHED"]];
    }
}

- (void)detach {
    [self detach:nil];
}

- (NSString *)getClientId {
    return self.realtime.auth.clientId;
}

- (NSString *)clientId_nosync {
    return self.realtime.auth.clientId_nosync;
}

- (void)history:(ARTPaginatedMessagesCallback)callback {
    [self history:[[ARTRealtimeHistoryQuery alloc] init] callback:callback error:nil];
}

- (BOOL)history:(ARTRealtimeHistoryQuery *)query callback:(ARTPaginatedMessagesCallback)callback error:(NSError **)errorPtr {
    query.realtimeChannel = self;
    return [_restChannel history:query callback:callback error:errorPtr];
}

- (void)startDecodeFailureRecoveryWithChannelSerial:(NSString *)channelSerial error:(ARTErrorInfo *)error {
    if (_decodeFailureRecoveryInProgress) {
        return;
    }

    ARTLogWarn(self.logger, @"R:%p C:%p (%@) starting delta decode failure recovery process", _realtime, self, self.name);
    _decodeFailureRecoveryInProgress = true;
    ARTAttachRequestMetadata *const metadata = [[ARTAttachRequestMetadata alloc] initWithReason:error
                                                                                  channelSerial:channelSerial];
    [self internalAttach:^(ARTErrorInfo *e) {
        self->_decodeFailureRecoveryInProgress = false;
    } metadata:metadata];
}

#pragma mark - ARTPresenceMapDelegate

- (NSString *)connectionId {
    return _realtime.connection.id_nosync;
}

- (void)map:(ARTPresenceMap *)map didRemovedMemberNoLongerPresent:(ARTPresenceMessage *)presence {
    presence.action = ARTPresenceLeave;
    presence.id = nil;
    presence.timestamp = [NSDate date];
    [self broadcastPresence:presence];
    ARTLogDebug(self.logger, @"RT:%p C:%p (%@) member \"%@\" no longer present", _realtime, self, self.name, presence.memberKey);
}

- (void)map:(ARTPresenceMap *)map shouldReenterLocalMember:(ARTPresenceMessage *)presence {
    [self.presence enterClient:presence.clientId data:presence.data callback:^(ARTErrorInfo *error) {
        NSString *message = [NSString stringWithFormat:@"Re-entering member \"%@\" as failed with code %ld (%@)", presence.clientId, (long)error.code, error.message];
        ARTErrorInfo *reenterError = [ARTErrorInfo createWithCode:ARTErrorUnableToAutomaticallyReEnterPresenceChannel message:message];
        ARTChannelStateChange *stateChange = [[ARTChannelStateChange alloc] initWithCurrent:self.state_nosync previous:self.state_nosync event:ARTChannelEventUpdate reason:reenterError resumed:true];
        [self emit:stateChange.event with:stateChange];
    }];
    ARTLogDebug(self.logger, @"RT:%p C:%p (%@) re-entering local member \"%@\"", _realtime, self, self.name, presence.memberKey);
}

- (BOOL)exceedMaxSize:(NSArray<ARTBaseMessage *> *)messages {
    NSInteger size = 0;
    for (ARTMessage *message in messages) {
        size += [message messageSize];
    }
    NSInteger maxSize = [ARTDefault maxMessageSize];
    if (self.realtime.connection.maxMessageSize) {
        maxSize = self.realtime.connection.maxMessageSize;
    }
    return size > maxSize;
}

- (ARTRealtimeChannelOptions *)getOptions {
    return (ARTRealtimeChannelOptions *)[self options];
}

- (ARTRealtimeChannelOptions *)getOptions_nosync {
    return (ARTRealtimeChannelOptions *)[self options_nosync];
}

- (void)setOptions:(ARTRealtimeChannelOptions *_Nullable)options callback:(nullable ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *_Nullable error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }
    dispatch_sync(_queue, ^{
        [self setOptions_nosync:options callback:callback];
    });
}

- (void)setOptions_nosync:(ARTRealtimeChannelOptions *_Nullable)options callback:(nullable ARTCallback)callback {
    [self setOptions_nosync:options];
    [self.restChannel setOptions_nosync:options];

    if (!options.modes && !options.params) {
        if (callback)
            callback(nil);
        return;
    }

    switch (self.state_nosync) {
        case ARTRealtimeChannelAttached:
        case ARTRealtimeChannelAttaching: {
            ARTLogDebug(self.logger, @"RT:%p C:%p (%@) set options in %@ state", _realtime, self, self.name, ARTRealtimeChannelStateToStr(self.state_nosync));
            ARTAttachRequestMetadata *const metadata = [[ARTAttachRequestMetadata alloc] initWithReason:nil];
            [self internalAttach:callback metadata:metadata];
            break;
        }
        default:
            if (callback)
                callback(nil);
            break;
    }
}

@end

#pragma mark - ARTEvent

@implementation ARTEvent (ChannelEvent)

- (instancetype)initWithChannelEvent:(ARTChannelEvent)value {
    return [self initWithString:[NSString stringWithFormat:@"ARTChannelEvent%@",ARTChannelEventToStr(value)]];
}

+ (instancetype)newWithChannelEvent:(ARTChannelEvent)value {
    return [[self alloc] initWithChannelEvent:value];
}

@end
