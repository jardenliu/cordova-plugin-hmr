


#import "CDVRemoteInject.h"
#import <Cordova/CDVConsole.h>
#import <Cordova/CDVBridge.h>

@interface CDVRemoteInject (PrivateMethods)
    @end

@implementation CDVRemoteInject

 - (void)pluginInitialize
{
    [self.webView setFrameLoadDelegate: self];
    
}

-(id)settingForkey:(NSString *)key
{
    return [self.commandDelegate.settings objectForKey:key];
}

-(void) injectCordovaJsForRemotePage {
    NSString* isWebviewRemoteInject = [self settingForkey: @"isWebviewRemoteInject"];
    if(isWebviewRemoteInject){
        // NSString* url =[self.commandDelegate pathForResource:@"cordova.js"];
        // NSString* injectCordovaJs =[ NSString stringWithFormat: @";(function injectCordovaJS(){var scriptTag = document.createElement('script');scriptTag.src ='file://'+ '%@';document.body.appendChild(scriptTag);})();",url];
        NSString* injectCordovaJs =[ NSString stringWithFormat: @";(function injectCordovaJS(){var scriptTag = document.createElement('script');scriptTag.src ='cordova/cordova.js';document.body.appendChild(scriptTag);})();"];

        id win = [self.webView windowScriptObject];
        
        [win evaluateWebScript:injectCordovaJs];
        
    }
    
}


// I am so sorry about that, because I don't know how to get the notification after didFinishLoadForFrame called
- (void) webView:(WebView*) webView didClearWindowObject:(WebScriptObject*) windowScriptObject forFrame:(WebFrame*) frame {
    
    [self initConsole:windowScriptObject];
    
    // allways re-initialized bridge to that it can add the helper methods on the webview's window
    self.bridge = [[CDVBridge alloc] initWithWebView:webView andViewController:self.viewController];
    
    [windowScriptObject setValue:self.bridge forKey:CDV_JS_KEY_CORDOVABRIDGE];
}

- (void) initConsole:(WebScriptObject*) windowScriptObject {
    // only use own console if no debug menu is enabled.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"WebKitDeveloperExtras"]) {
        if (self.console == nil) {
            self.console = [CDVConsole new];
        }
        [windowScriptObject setValue:self.console forKey:CDV_JS_KEY_CONSOLE];
    }
}

#pragma mark WebFrameLoadDelegate

- (void) webView:(WebView*) sender didFinishLoadForFrame:(WebFrame*) frame {
    id win = [sender windowScriptObject];
    NSString* nativeReady = @"try{cordova.require('cordova/channel').onNativeReady.fire();}catch(e){window._nativeReady = true;}";
    [win evaluateWebScript:nativeReady];
    
    [self injectCordovaJsForRemotePage];
}
    
    @end
