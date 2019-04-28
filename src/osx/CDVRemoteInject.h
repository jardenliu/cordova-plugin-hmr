#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

#define CDV_JS_KEY_CONSOLE @"console"
#define CDV_JS_KEY_CORDOVABRIDGE @"cordovabridge"

@class CDVConsole;
@class CDVBridge;
@class CDVViewController;

@interface CDVRemoteInject : CDVPlugin <WebFrameLoadDelegate>
{
    // CFRunLoopSourceRef runLoopSource;
    // float level;
    // bool isPlugged;
    // NSString *callbackId;
}

@property(nonatomic) BOOL allowWebViewNavigation;
@property(nonatomic, strong) CDVConsole *console;
@property(nonatomic, strong) CDVBridge *bridge;

// @property(nonatomic) CFRunLoopSourceRef runLoopSource;
// @property(nonatomic) float level;
// @property(nonatomic) bool isPlugged;
// @property(strong) NSString *callbackId;

// - (void)start:(CDVInvokedUrlCommand *)command;
// - (void)stop:(CDVInvokedUrlCommand *)command;
// - (NSDictionary *)getBatteryStatus;
// - (void)dealloc;

// void handlePowerSourceChange(CDVOSXBattery *context);

@end
