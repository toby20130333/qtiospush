#include "qmlmainobject.h"
#ifdef Q_OS_IOS
#import "YunBaService.h"
#include <QObject>
#include <QTimer>
#include <QString>
#include <QDebug>
#include <QDateTime>
#import <UIKit/UIKit.h>
namespace{
QString qt_mac_NSStringToQString(const NSString *nsstr)
{
    NSRange range;
    range.location = 0;
    range.length = [nsstr length];
    
    
    unichar *chars = new unichar[range.length];
    [nsstr getCharacters:chars range:range];
    
    QString result = QString::fromUtf16(chars, range.length);
    
    delete[] chars;
    
    return result;
}
}

@interface ViberApplicationDelegate : UIResponder <UIApplicationDelegate>{
                                          BOOL isRegistered;
QmlMainObject* mainWindow;
NSObject <UIApplicationDelegate>* qtDelegate;
}
- (id) initWithMainWindow :(QmlMainObject*)MainWindowInstance;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void) registerPushNotifications;
- (void) application:(UIApplication*)application didReceiveRemoteNotification: (NSDictionary*)userInfo;
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/*Qt delegate forwarding*/
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)application:(UIApplication *)sender openFiles:(NSArray *)filenames;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationDidResignActive:(NSNotification *)notification;

- (void)addNotificationHandler;
- (void)onMessageReceived:(NSNotification *)notification;
- (void)onPresenceReceived:(NSNotification *)notification;
- (void)setTopicFromQtView:(NSString *)message;
-(void)publishMsgFromQtView:(NSString *)topics setMessage:(NSString *) message;
-(void)setLocalPushNotification:(NSString *)message;
@end

ViberApplicationDelegate* viberApplicationDelegate(void){
    return (ViberApplicationDelegate*)[UIApplication sharedApplication].delegate;
}

@implementation ViberApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    qDebug()<<"didFinishLaunchingWithOptions------------------- ";
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    // uncomment to setup yunba service, refer to http://www.yunba.io to get an appkey
    //#define AppKey
    kYBLogLevel = kYBLogLevelDebug;
    [YunBaService setupWithAppkey:@"54c0f18e52be1f7e1dd8490b"];

    // uncomment to register for remote notification(APNs)     //注册APNs，申请获取device token
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    return YES;
}
//signalUIdelegateStatus itype 0:foregroud 1:backgroud 2:app terminate
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if(mainWindow != NULL){
        mainWindow->signalUIdelegateStatus(1);
    }
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if(mainWindow != NULL){
        mainWindow->signalUIdelegateStatus(0);
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    if(mainWindow != NULL){
        mainWindow->signalUIdelegateStatus(2);
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (id) initWithMainWindow :(QmlMainObject*)MainWindowInstance{

    qDebug()<<"initWithMainWindow---------------- "<<MainWindowInstance;

    mainWindow = MainWindowInstance;
    qDebug()<<"initWithMainWindow22222 "<<mainWindow;
    self = [super init];
    isRegistered = FALSE;

    qDebug()<<"initWithMainWindow33333 "<<mainWindow;

    [[UIApplication sharedApplication] setDelegate:self];

    qtDelegate = [[UIApplication sharedApplication] delegate];


    qDebug()<<"initWithMainWindow44444444 "<<qtDelegate;

    kYBLogLevel = kYBLogLevelDebug;
    [YunBaService setupWithAppkey:@"54c0f18e52be1f7e1dd8490b"];

    [self addNotificationHandler];
    return self;
}

- (void) registerPushNotifications{    
    qDebug()<<"registerPushNotifications..........";
    //    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

}
/**
  3.广播频道（broadcast channel）用于同时联系到所有用户，所以很多时候开发者可能需要自己创建一些更精准化的频道。
一旦推送通知被接受但是应用不在前台，就会被显示在iOS推送中心。反之如果应用刚好处于活动状态，则交于应用去自行处理。
具体我们可以在app delegate中实现[application:didReceiveRemoteNotification]方法。
一下示例代码只是简单的将这一需求交由Parse去处理，Parse会创建一个模态警报显示推送内容
**/
- (void) application:(UIApplication*)application didReceiveRemoteNotification: (NSDictionary*)userInfo{
    NSLog(@"Receive remote notification : %@",userInfo);
}
/**
  在 APNs 服务器响应后，应用程序代理中的 didRegisterForRemoteNotificationsWithDeviceToken 方法被调用，
并将设备令牌作为一个调用参数传递进来。您必须保存设备令牌并将它上传到自己的推送通知服务器
服务器应该将令牌及其相关的标识信息保存在数据库中。在大多数应用程序中，它被保存在用户配置文件数据库中。
**/
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    isRegistered = TRUE;
    qDebug()<<"didRegisterForRemoteNotificationsWithDeviceToken ";
    NSString* token = [[[[deviceToken description]
            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                                      stringByReplacingOccurrencesOfString:@">" withString:@""]
                                                      stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(mainWindow){
        //[[UIApplication sharedApplication] setDelegate:qtDelegate];
        QString qstring_token = qt_mac_NSStringToQString(token);
        mainWindow->onPushTokenRequestSuccessful(qstring_token);
    }
    [YunBaService storeDeviceToken:deviceToken resultBlock:^(BOOL succ, NSError *error) {
        if (succ) {
            NSLog(@"store device token to YunBa succ");
        } else {
            NSLog(@"store device token to YunBa failed due to : %@, recovery suggestion: %@", error, [error localizedRecoverySuggestion]);
        }
    }];
    //Save it to myself server
    /**
// Save the token to server
    NSString *urlStr = [NSString stringWithFormat:@"https://%@/push_token", RINGFULDOMAIN];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

   [req setHTTPMethod:@"POST"];
   [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
   NSMutableData *postBody = [NSMutableData data];
   [postBody appendData:[[NSString stringWithFormat:@"username=%@", username]
      dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"&token=%@",
      pushToken] dataUsingEncoding:NSUTF8StringEncoding]];

   [req setHTTPBody:postBody];
   [[NSURLConnection alloc] initWithRequest:req delegate:nil];
**/
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    isRegistered = FALSE;
    NSString* reason = [error localizedFailureReason];
    NSString* description = [error localizedDescription];
    qDebug()<<"didFailToRegisterForRemoteNotificationsWithError2222 "<<error;
    if(mainWindow){
        qDebug()<<"didFailToRegisterForRemoteNomainWindowtificationsWithError "<<mainWindow;
        //[[UIApplication sharedApplication] setDelegate:qtDelegate];
        QString qstring_error = QString::fromNSString(description);
        mainWindow->onPushTokenRequestError(qstring_error);
    }
}

///*Qt delegate forwarding*/
//- (UIApplication)applicationShouldTerminate:(UIApplication *)sender{
//    [qtDelegate applicationShouldTerminate:sender];
//}
//- (void) applicationDidFinishLaunching: (UIApplication*)aNotification{
//    [qtDelegate applicationDidFinishLaunching:aNotification];
//}
//- (void)application:(UIApplication *)sender openFiles:(NSArray *)filenames{
//    [qtDelegate application:sender openFiles:filenames];
//}
//- (void)applicationDidBecomeActive:(UIApplication *)notification{
//    [qtDelegate applicationDidBecomeActive:notification];
//}
//- (void)applicationDidResignActive:(NSNotification *)notification{
//    [qtDelegate applicationDidResignActive:notification];
//}

- (void)addNotificationHandler {
    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self selector:@selector(onConnectionStateChanged:) name:kYBConnectionStatusChangedNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onMessageReceived:) name:kYBDidReceiveMessageNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onPresenceReceived:) name:kYBDidReceivePresenceNotification object:nil];
}

//建立连接后监听,通知UI而已，订阅topic放到UI来操作
- (void)onConnectionStateChanged:(NSNotification *)notification {
    if ([YunBaService isConnected]) {
        NSLog(@"................didConnect");
        mainWindow->emitConnectYunbaServer(true);
        QString str("System2");
        NSString* topicmsg = str.toNSString();
        [self setTopicFromQtView:topicmsg];
        //NSString *prompt = [NSString stringWithFormat:@"[YunBaService] => didConnect"];
    } else {
        NSLog(@"didDisconnected");
        mainWindow->emitConnectYunbaServer(false);
        //NSString *prompt = [NSString stringWithFormat:@"[YunBaService] => disconnected"];
    }
}
//获取云巴服务器传递过来的信息
- (void)onMessageReceived:(NSNotification *)notification {
    YBMessage *message = [notification object];
    NSLog(@"new message, %zu bytes, topic=%@", (unsigned long)[[message data] length], [message topic]);
    NSString *payloadString = [[NSString alloc] initWithData:[message data] encoding:NSUTF8StringEncoding];
    NSLog(@"data: %@ %@", payloadString,[message data]);
    NSString *curMsg = [NSString stringWithFormat:@"[Message] %@ => %@", [message topic], payloadString];
    //    [self addMsgToTextView:curMsg];
    NSString *qtTopic=[message topic];
    QString topicType = QString::fromNSString(qtTopic);
    qDebug()<<" topicType is "<< topicType;
    if(topicType == "System2"){
        qDebug()<<" msg is "<<QString::fromNSString(payloadString);
        mainWindow->recieveMsgFromYunba(QString::fromNSString(payloadString));
        //通知本地
        [self setLocalPushNotification:payloadString];
    }
    //    mainWindow->pushNotifiction(QString::fromNSString(payloadString),QDateTime::currentDateTime());
}
//存在的通知
- (void)onPresenceReceived:(NSNotification *)notification {
    YBPresenceEvent *presence = [notification object];
    NSLog(@"new presence, action=%@, topic=%@, alias=%@, time=%lf", [presence action], [presence topic], [presence alias], [presence time]);

    NSString *curMsg = [NSString stringWithFormat:@"[Presence] %@:%@ => %@[%@]", [presence topic], [presence alias], [presence action], [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:[presence time]/1000] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
    //[self addMsgToTextView:curMsg];
}
//订阅频道
- (void)setTopicFromQtView:(NSString *)message {

    //[self hideAllKeyboard];
    //    NSString *topic = [[NSString alloc] stringWithCString:message];
    [YunBaService subscribe:message resultBlock:^(BOOL succ, NSError *error){
        if (succ) {
            NSLog(@"setTopicFromQtView");
            mainWindow->signalSubTopic(true);
        } else {
            NSLog(@"dis_setTopicFromQtView");
            mainWindow->signalSubTopic(false);
        }
    }];
}
//发布消息
-(void)publishMsgFromQtView:(NSString *)topics setMessage:(NSString *) message{
    //[self hideAllKeyboard];
    //    NSString *topic = [[NSString alloc] stringWithCString:message];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSString *room_name = @"0";
    UInt8 qosLevel[2];
    memcpy(qosLevel, [room_name UTF8String],[room_name lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
    BOOL isRetained = NO;
    //向某个topic发送消息message
    [YunBaService publish:topics data:data option:[YBPublishOption optionWithQos:kYBQosLevel0
                          retained:isRetained] resultBlock:^(BOOL succ, NSError *error){
        if (succ) {
            NSLog(@"publish data succuess");
            mainWindow->signalSendMsg(true);
        } else {
            NSLog(@"publish data error");
            mainWindow->signalSendMsg(false);
        }
    }];
}
//设置本地推送到通知栏
-(void)setLocalPushNotification:(NSString *)message{

    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;

    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:types categories:NULL];

    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];

    QDateTime dateTime = QDateTime::currentDateTime();
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    dateComp.year = dateTime.date().year();
    dateComp.month = dateTime.date().month();
    dateComp.day = dateTime.date().day();
    dateComp.hour = dateTime.time().hour();
    dateComp.minute = dateTime.time().minute();
    dateComp.second = dateTime.time().second();
    dateComp.timeZone = [NSTimeZone systemTimeZone];

    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];

    NSDate *date = [calendar dateFromComponents:dateComp];

    UILocalNotification *notifiction = [[UILocalNotification alloc]init];
    //    NSString *astring =
    notifiction.alertBody = [[NSString alloc] initWithString:message];;
    notifiction.fireDate = date;
    //    notification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] scheduleLocalNotification:notifiction];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
}
@end
ViberApplicationDelegate* appDelegate;
void QmlMainObject::setupPushNotifications()
{
    qDebug()<<"setupPushNotifications "<<this;
    appDelegate = [[ViberApplicationDelegate alloc] initWithMainWindow:this];
    [appDelegate registerPushNotifications];
}

bool QmlMainObject::isMainWindowActive()
{
    //return (isActiveWindow() || [[reinterpret_cast<NSView *>(winId()) window] isMainWindow]);
}
void QmlMainObject::setTopicTitle(const QString &topic)
{
    QString str(topic);
    NSString* topicmsg = str.toNSString();
    //    [ViberApplicationDelegate setTopicFromQtView:topicmsg];
    //    ViberApplicationDelegate* appDelegate = [[ViberApplicationDelegate alloc] initWithMainWindow:this];
    [appDelegate setTopicFromQtView:topicmsg];
}
void QmlMainObject::publishMsg(const QString &topic,const QString &msg)
{
    QString str(topic);
    NSString* topicmsg = str.toNSString();
    NSString* message  = msg.toNSString();
    //    ViberApplicationDelegate* appDelegate = [[ViberApplicationDelegate alloc] initWithMainWindow:this];
    [appDelegate publishMsgFromQtView: topicmsg setMessage : message ];
    //    [appDelegate release];
}
void QmlMainObject::pushNotifiction(const QString &message, const QDateTime &dateTime)
{
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;

    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:types categories:NULL];

    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];

    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    dateComp.year = dateTime.date().year();
    dateComp.month = dateTime.date().month();
    dateComp.day = dateTime.date().day();
    dateComp.hour = dateTime.time().hour();
    dateComp.minute = dateTime.time().minute();
    dateComp.second = dateTime.time().second();
    dateComp.timeZone = [NSTimeZone systemTimeZone];

    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];

    NSDate *date = [calendar dateFromComponents:dateComp];

    UILocalNotification *notifiction = [[UILocalNotification alloc]init];
    notifiction.alertBody = [NSString stringWithFormat:@"%s" , message.toStdString().c_str()];
    notifiction.fireDate = date;
    //notification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication]scheduleLocalNotification:notifiction];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
}

void QmlMainObject::cancelAllNotifictions(void)
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
#endif
