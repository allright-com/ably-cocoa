#import "ARTInternalLog.h"
#import "ARTVersion2Log.h"

@interface ARTInternalLog ()

@property (nonatomic, readonly) id<ARTVersion2Log> logger;

@end

@implementation ARTInternalLog

- (instancetype)initWithLogger:(id<ARTVersion2Log>)logger {
    if (self = [super init]) {
        _logger = logger;
    }

    return self;
}

// MARK: Logging

- (void)log:(NSString *)message withLevel:(ARTLogLevel)level {
    [self.logger log:message withLevel:level];
}

- (void)logWithError:(ARTErrorInfo *)error {
    [self.logger logWithError:error];
}

// MARK: Log level

- (ARTLogLevel)logLevel {
    return self.logger.logLevel;
}

- (void)setLogLevel:(ARTLogLevel)logLevel {
    self.logger.logLevel = logLevel;
}

// MARK: Shorthand

// These implementations are all copied from ARTLog.

- (void)verbose:(NSString *)format, ... {
    if (self.logLevel <= ARTLogLevelVerbose) {
        va_list args;
        va_start(args, format);
        [self log:[[NSString alloc] initWithFormat:format arguments:args]
        withLevel:ARTLogLevelVerbose];
        va_end(args);
    }
}

- (void)verbose:(const char *)fileName line:(NSUInteger)line message:(NSString *)message, ... {
    if (self.logLevel <= ARTLogLevelVerbose) {
        va_list args;
        va_start(args, message);
        [self log:[[NSString alloc] initWithFormat:[NSString stringWithFormat:@"(%@:%lu) %@", [[NSString stringWithUTF8String:fileName] lastPathComponent], (unsigned long)line, message] arguments:args]
        withLevel:ARTLogLevelVerbose];
        va_end(args);
    }
}

- (void)debug:(NSString *)format, ... {
    if (self.logLevel <= ARTLogLevelDebug) {
        va_list args;
        va_start(args, format);
        [self log:[[NSString alloc] initWithFormat:format arguments:args]
        withLevel:ARTLogLevelDebug];
        va_end(args);
    }
}

- (void)debug:(const char *)fileName line:(NSUInteger)line message:(NSString *)message, ... {
    if (self.logLevel <= ARTLogLevelDebug) {
        va_list args;
        va_start(args, message);
        [self log:[[NSString alloc] initWithFormat:[NSString stringWithFormat:@"(%@:%lu) %@", [[NSString stringWithUTF8String:fileName] lastPathComponent], (unsigned long)line, message] arguments:args]
        withLevel:ARTLogLevelDebug];
        va_end(args);
    }
}

- (void)info:(NSString *)format, ... {
    if (self.logLevel <= ARTLogLevelInfo) {
        va_list args;
        va_start(args, format);
        [self log:[[NSString alloc] initWithFormat:format arguments:args]
        withLevel:ARTLogLevelInfo];
        va_end(args);
    }
}

- (void)warn:(NSString *)format, ... {
    if (self.logLevel <= ARTLogLevelWarn) {
        va_list args;
        va_start(args, format);
        [self log:[[NSString alloc] initWithFormat:format arguments:args]
        withLevel:ARTLogLevelWarn];
        va_end(args);
    }
}

- (void)error:(NSString *)format, ... {
    if (self.logLevel <= ARTLogLevelError) {
        va_list args;
        va_start(args, format);
        [self log:[[NSString alloc] initWithFormat:format arguments:args]
        withLevel:ARTLogLevelError];
        va_end(args);
    }
}

@end
