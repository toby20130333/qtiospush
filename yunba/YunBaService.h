#import <Foundation/Foundation.h>

// sdk version
extern NSString * const kYunBaSDKVersion;   //@"1.4.8"

// notifications
extern NSString * const kYBConnectionStatusChangedNotification;
extern NSString * const kYBDidReceiveMessageNotification;
extern NSString * const kYBDidReceivePresenceNotification;

// error domain
extern NSString * const kYBErrorDomain;
extern NSString * const kYBErrorMessageId;

// publish option
extern NSString * const kYBOptionQosKey;

// error code
typedef NS_ENUM(NSUInteger, YBErrorCode) {
    kYBErrorNoError = 0,                // succ
    kYBErrorInternalError = 1,          // YunBa Service internal error

    kYBErrorTimeoutError = 100,         // Operation Timeout
    kYBErrorServiceNotSetup = 101,      // YunBa Service NOT setup yet
    kYBErrorArgumentIllegal = 102,      // Call YunBa Api with illegal arguments
    kYBErrorNetworkError = 103,         // Operation Failed because of Network
    kYBErrorOperationInterrupted = 104, // Called API is interrupted by some operation, maybe YunBa Service is closed during invacation or upload token for twice and the like
};

// qos level
typedef NS_ENUM(UInt8, YBQosLevel) {
    kYBQosLevel0 = 0,
    kYBQosLevel1 = 1,
    kYBQosLevel2 = 2,
};

// log level
typedef NS_ENUM(unsigned long, YBLogLevel) {
    kYBLogLevelNoLog = 0,
    kYBLogLevelError = 1,
    kYBLogLevelWarn = 2,
    kYBLogLevelInfo = 3,
    kYBLogLevelDebug = 4,
    kYBLogLevelDefault = kYBLogLevelInfo,
};

extern YBLogLevel kYBLogLevel;  // You can change log level by modify this global variable, default is kYBLogLevelDefault

#define YBLog(level, fmt, ...) \
do { \
    if (kYBLogLevel >= level) { \
        \
    } \
} while(0)

#pragma mark - YBMessage
@interface YBMessage : NSObject{
//NSString *topic;
//NSString * data;
}
@property (nonatomic, readonly, strong) NSString *topic;
@property (nonatomic, readonly, strong) NSData *data;
@end

#pragma mark - YBPresenceEvent
@interface YBPresenceEvent : NSObject
@property (nonatomic, readonly, strong) NSString *action;       // presence action type
@property (nonatomic, readonly, strong) NSString *topic;        // topic
@property (nonatomic, readonly, strong) NSString *alias;        // user alias
@property (nonatomic, readonly, assign) NSTimeInterval time;    // UTC time
@end

#pragma mark - YBUserState
@interface YBUserState : NSObject
@property (nonatomic, readonly, strong) NSString *alias;        // user alias
@property (nonatomic, readonly, strong) NSString *state;        // user state
@end

#pragma mark - options
@interface YBSetupOption : NSObject
@property (nonatomic, copy) NSString *subscribeKey;             // subscribe key
@property (nonatomic, copy) NSString *publishKey;               // publish key
@property (nonatomic, copy) NSString *secreteKey;               // secrete key
@property (nonatomic, copy) NSString *authorizeKey;             // authorize key
+ (instancetype)optionWithSubKey:(NSString *)subcribeKey pubKey:(NSString *)publishKey secKey:(NSString *)secreteKey authKey:(NSString *)authorizeKey;
@end

@interface YBPublishOption : NSObject
@property (nonatomic, assign) UInt8 qosLevel;                   // qos level
@property (nonatomic, assign) BOOL retained;                    // is retained
+ (instancetype)optionWithQos:(YBQosLevel)qosLevel retained:(BOOL)retained;
@end

@interface YBApnOption : NSObject
@property (nonatomic, strong) id alert;
@property (nonatomic, strong) NSNumber *badge;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic, strong) NSNumber *contentAvailable;
@property (nonatomic, strong) NSDictionary *extra;
+ (instancetype)optionWithAlert:(id)alert;
+ (instancetype)optionWithAlert:(id)alert badge:(NSNumber *)badge sound:(NSString *)sound;
+ (instancetype)optionWithAlert:(id)alert badge:(NSNumber *)badge sound:(NSString *)sound contentAvailable:(NSNumber *)contentAvailable extra:(NSDictionary *)extra;
@end

@interface YBPublish2Option : NSObject
@property (nonatomic, strong) YBApnOption *apnOption;
+ (instancetype)optionWithApnOption:(YBApnOption *)apnOption;
@end

//result block
typedef void (^YBResultBlock)(BOOL succ, NSError *error);
typedef void (^YBStringResultBlock)(NSString *res, NSError *error);
typedef void (^YBArrayResultBlock)(NSArray *res, NSError *error);
typedef void (^YBArrayCountResultBlock)(NSArray *resArray, size_t resCount, NSError *error);

#pragma mark - YunBaService
@interface YunBaService : NSObject
// setup && close
+ (BOOL)setupWithAppkey:(NSString *)appkey;
+ (BOOL)setupWithAppkey:(NSString *)appkey option:(YBSetupOption *)option;
+ (BOOL)setup;
+ (BOOL)close;
+ (BOOL)isConnected;

// publish/subscribe/unsubscribe
+ (void)subscribe:(NSString *)topic resultBlock:(YBResultBlock)resultBlock;
+ (void)subscribe:(NSString *)topic qos:(UInt8)qosLevel resultBlock:(YBResultBlock)resultBlock;
+ (void)unsubscribe:(NSString *)topic resultBlock:(YBResultBlock)resultBlock;
+ (void)publish:(NSString *)topic data:(NSData *)data resultBlock:(YBResultBlock)resultBlock;
+ (void)publish:(NSString *)topic data:(NSData *)data option:(YBPublishOption *)option resultBlock:(YBResultBlock)resultBlock;
+ (void)publishToAlias:(NSString *)alias data:(NSData *)data resultBlock:(YBResultBlock)resultBlock;
+ (void)publishToAlias:(NSString *)alias data:(NSData *)data option:(YBPublishOption *)option resultBlock:(YBResultBlock)resultBlock;
+ (void)publish2:(NSString *)topic data:(NSData *)data resultBlock:(YBResultBlock)resultBlock;
+ (void)publish2:(NSString *)topic data:(NSData *)data option:(YBPublish2Option *)option resultBlock:(YBResultBlock)resultBlock;
+ (void)publish2ToAlias:(NSString *)alias data:(NSData *)data option:(YBPublish2Option *)option resultBlock:(YBResultBlock)resultBlock;

// subscribe/unsubscribe presence
+ (void)subscribePresence:(NSString *)topic resultBlock:(YBResultBlock)resultBlock;
+ (void)unsubscribePresence:(NSString *)topic resultBlock:(YBResultBlock)resultBlock;

// get alias list of topic
+ (void)getAliasList:(NSString *)topic resultBlock:(YBArrayCountResultBlock)arrayCountResultBlock;
+ (void)getAliasList:(NSString *)topic disableState:(BOOL)disableState disableAlias:(BOOL)disableAlias resultBlock:(YBArrayCountResultBlock)arrayCountResultBlock;

// get topic list of alias
+ (void)getTopicList:(YBArrayResultBlock)arrayResultBlock;
+ (void)getTopicList:(NSString *)alias resultBlock:(YBArrayResultBlock)arrayResultBlock;

// get state of alias
+ (void)getState:(NSString *)alias resultBlock:(YBStringResultBlock)stringResultBlock;

// report
+ (void)report:(NSString *)action withData:(NSData *)data;

// alias
+ (void)setAlias:(NSString *)alias resultBlock:(YBResultBlock)resultBlock;
+ (void)getAlias:(YBStringResultBlock)stringResultBlock;

// store device token for apns
+ (void)storeDeviceToken:(NSData *)token resultBlock:(YBResultBlock)resultBlock;
@end
