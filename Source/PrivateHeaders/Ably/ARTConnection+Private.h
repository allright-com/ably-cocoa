#import <Ably/ARTConnection.h>
#import <Ably/ARTEventEmitter.h>
#import <Ably/ARTTypes.h>
#import "ARTQueuedDealloc.h"

NS_ASSUME_NONNULL_BEGIN

@class ARTRealtimeInternal;
@class ARTInternalLog;

@interface ARTConnectionInternal : NSObject<ARTConnectionProtocol>

@property (nullable, readonly, nonatomic) NSString *id;
@property (nullable, readonly, nonatomic) NSString *key;
@property (nullable, readonly) NSString *recoveryKey;
@property (readonly, nonatomic) int64_t serial;
@property (readonly, nonatomic) NSInteger maxMessageSize;
@property (readonly, nonatomic) ARTRealtimeConnectionState state;
@property (nullable, readonly, nonatomic) ARTErrorInfo *errorReason;

- (instancetype)initWithRealtime:(ARTRealtimeInternal *)realtime logger:(ARTInternalLog *)logger;

- (nullable NSString *)id_nosync;
- (nullable NSString *)key_nosync;
- (int64_t)serial_nosync;
- (BOOL)isActive_nosync;
- (ARTRealtimeConnectionState)state_nosync;
- (nullable ARTErrorInfo *)errorReason_nosync;
- (nullable ARTErrorInfo *)error_nosync;
- (nullable NSString *)recoveryKey_nosync;

@property (readonly, nonatomic) ARTEventEmitter<ARTEvent *, ARTConnectionStateChange *> *eventEmitter;
@property(weak, nonatomic) ARTRealtimeInternal* realtime; // weak because realtime owns self

- (void)setId:(NSString *_Nullable)newId;
- (void)setKey:(NSString *_Nullable)key;
- (void)setSerial:(int64_t)serial;
- (void)setMaxMessageSize:(NSInteger)maxMessageSize;
- (void)setState:(ARTRealtimeConnectionState)state;
- (void)setErrorReason:(ARTErrorInfo *_Nullable)errorReason;

- (void)emit:(ARTRealtimeConnectionEvent)event with:(ARTConnectionStateChange *)data;

@property (readonly, nonatomic) dispatch_queue_t queue;

@end

@interface ARTConnection ()

@property (nonatomic, readonly) ARTConnectionInternal *internal;

- (instancetype)initWithInternal:(ARTConnectionInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc;

@property (readonly) ARTConnectionInternal *internal_nosync;

@end

NS_ASSUME_NONNULL_END
