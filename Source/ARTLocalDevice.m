#import "ARTLocalDevice+Private.h"
#import "ARTDevicePushDetails.h"
#import "ARTPush.h"
#import "ARTEncoder.h"
#import "ARTDeviceStorage.h"
#import "ARTDeviceIdentityTokenDetails+Private.h"
#import "ARTCrypto+Private.h"
#import "ARTInternalLog.h"

NSString *const ARTDevicePlatform = @"ios";

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
NSString *const ARTDeviceFormFactor = @"phone";
#elif TARGET_OS_TV
NSString *const ARTDeviceFormFactor = @"tv";
#elif TARGET_OS_WATCH
NSString *const ARTDeviceFormFactor = @"watch";
#elif TARGET_OS_SIMULATOR
NSString *const ARTDeviceFormFactor = @"simulator";
#elif TARGET_OS_MAC
NSString *const ARTDeviceFormFactor = @"desktop";
#else
NSString *const ARTDeviceFormFactor = @"embedded";
#endif

NSString *const ARTDevicePushTransportType = @"apns";

NSString *const ARTDeviceIdKey = @"ARTDeviceId";
NSString *const ARTDeviceSecretKey = @"ARTDeviceSecret";
NSString *const ARTDeviceIdentityTokenKey = @"ARTDeviceIdentityToken";
NSString *const ARTAPNSDeviceTokenKey = @"ARTAPNSDeviceToken";

NSString *const ARTAPNSDeviceDefaultTokenType = @"default";
NSString *const ARTAPNSDeviceLocationTokenType = @"location";

NSString* ARTAPNSDeviceTokenKeyOfType(NSString *tokenType) {
    return [ARTAPNSDeviceTokenKey stringByAppendingFormat:@"-%@", tokenType ?: ARTAPNSDeviceDefaultTokenType];
}

@interface ARTLocalDevice ()

@property (nullable, nonatomic, readonly) ARTInternalLog *logger;

@end

@implementation ARTLocalDevice

- (instancetype)initWithClientId:(NSString *)clientId storage:(id<ARTDeviceStorage>)storage logger:(nullable ARTInternalLog *)logger {
    if (self = [super init]) {
        self.clientId = clientId;
        self.storage = storage;
        _logger = logger;
    }
    return self;
}

+ (ARTLocalDevice *)load:(NSString *)clientId storage:(id<ARTDeviceStorage>)storage logger:(nullable ARTInternalLog *)logger {
    ARTLocalDevice *device = [[ARTLocalDevice alloc] initWithClientId:clientId storage:storage logger:logger];
    device.platform = ARTDevicePlatform;
    #if TARGET_OS_IOS
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPad:
            device.formFactor = @"tablet";
        case UIUserInterfaceIdiomCarPlay:
            device.formFactor = @"car";
        default:
            device.formFactor = ARTDeviceFormFactor;
    }
    #else
    device.formFactor = ARTDeviceFormFactor;
    #endif
    device.push.recipient[@"transportType"] = ARTDevicePushTransportType;

    NSString *deviceId = [storage objectForKey:ARTDeviceIdKey];
    NSString *deviceSecret = deviceId == nil ? nil : [storage secretForDevice:deviceId];
    
    if (deviceId == nil || deviceSecret == nil) { // generate both at the same time
        deviceId = [self generateId];
        deviceSecret = [self generateSecret];
        
        [storage setObject:deviceId forKey:ARTDeviceIdKey];
        [storage setSecret:deviceSecret forDevice:deviceId];
    }
    
    device.id = deviceId;
    device.secret = deviceSecret;

    id identityTokenDetailsInfo = [storage objectForKey:ARTDeviceIdentityTokenKey];
    ARTDeviceIdentityTokenDetails *identityTokenDetails = [ARTDeviceIdentityTokenDetails unarchive:identityTokenDetailsInfo withLogger:logger];
    device->_identityTokenDetails = identityTokenDetails;

    NSArray *supportedTokenTypes = @[
        ARTAPNSDeviceDefaultTokenType,
        ARTAPNSDeviceLocationTokenType
    ];
    
    for (NSString *tokenType in supportedTokenTypes) {
        NSString *token = [ARTLocalDevice apnsDeviceTokenOfType:tokenType fromStorage:storage];
        [device setAPNSDeviceToken:token tokenType:tokenType];
    }
    return device;
}

+ (NSString *)generateId {
    return [NSUUID new].UUIDString;
}

+ (NSString *)generateSecret {
    NSData *randomData = [ARTCrypto generateSecureRandomData:32];
    NSData *hash = [ARTCrypto generateHashSHA256:randomData];
    return [hash base64EncodedStringWithOptions:0];
}

+ (NSString *)apnsDeviceTokenOfType:(nullable NSString *)tokenType fromStorage:(id<ARTDeviceStorage>)storage {
    NSString *token = [storage objectForKey:ARTAPNSDeviceTokenKeyOfType(tokenType)];
    if ([tokenType isEqualToString:ARTAPNSDeviceDefaultTokenType] && token == nil) {
        token = [storage objectForKey:ARTAPNSDeviceTokenKey]; // Read legacy token
    }
    return token;
}

- (NSString *)apnsDeviceToken {
    NSDictionary *deviceTokens = (NSDictionary *)self.push.recipient[@"apnsDeviceTokens"];
    return deviceTokens[ARTAPNSDeviceDefaultTokenType];
}

- (void)setAPNSDeviceToken:(NSString *)token tokenType:(NSString *)tokenType {
    NSMutableDictionary *deviceTokens = [(self.push.recipient[@"apnsDeviceTokens"] ?: (token != nil ? @{} : nil)) mutableCopy];
    deviceTokens[tokenType] = token;
    self.push.recipient[@"apnsDeviceTokens"] = [deviceTokens copy];
}

- (void)setAndPersistAPNSDeviceToken:(NSString *)token tokenType:(NSString *)tokenType {
    [self.storage setObject:token forKey:ARTAPNSDeviceTokenKeyOfType(tokenType)];
    [self setAPNSDeviceToken:token tokenType:tokenType];
}

- (void)setAndPersistAPNSDeviceToken:(NSString *)token {
    [self setAndPersistAPNSDeviceToken:token tokenType:ARTAPNSDeviceDefaultTokenType];
}

- (void)setAndPersistIdentityTokenDetails:(ARTDeviceIdentityTokenDetails *)tokenDetails {
    [self.storage setObject:[tokenDetails archiveWithLogger:self.logger]
                     forKey:ARTDeviceIdentityTokenKey];
    _identityTokenDetails = tokenDetails;
    if (self.clientId == nil) {
        self.clientId = tokenDetails.clientId;
    }
}

- (BOOL)isRegistered {
    return _identityTokenDetails != nil;
}

@end
