


#import "CDVRemoteInject.h"
#import <Cordova/CDVConsole.h>
#import <Cordova/CDVBridge.h>
#import <objc/runtime.h>


static void exchangeMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL orginReplaceSel){
    // 原方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    // 替换方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    // 如果没有实现 delegate 方法，则手动动态添加
    if (!originalMethod) {
        Method orginReplaceMethod = class_getInstanceMethod(replacedClass, orginReplaceSel);
        BOOL didAddOriginMethod = class_addMethod(originalClass, originalSel, method_getImplementation(orginReplaceMethod), method_getTypeEncoding(orginReplaceMethod));
        if (didAddOriginMethod) {
            NSLog(@"did Add Origin Replace Method");
        }
        return;
    }
    // 向实现 delegate 的类中添加新的方法
    // 这里是向 originalClass 的 replaceSel（@selector(replace_webViewDidFinishLoad:)） 添加 replaceMethod
    BOOL didAddMethod = class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        // 添加成功
        NSLog(@"class_addMethod_success --> (%@)", NSStringFromSelector(replacedSel));
        // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        // 实现交换
        method_exchangeImplementations(originalMethod, newMethod);
    }else{
        // 添加失败，则说明已经 hook 过该类的 delegate 方法，防止多次交换。
        NSLog(@"Already hook class --> (%@)",NSStringFromClass(originalClass));
    }
}


@interface CDVRemoteInject (PrivateMethods)
    @end

@implementation CDVRemoteInject

 - (void)pluginInitialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        [self exchangeWebViewDelegateMethod];
        [self.webView setFrameLoadDelegate: self.webView.frameLoadDelegate];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLoadForFrame) name:@"webView:didFinishLoadForFrame:" object:nil];
    
}

- (void)exchangeWebViewDelegateMethod{
    
    Class delegate = object_getClass((id)self.webView.frameLoadDelegate);
    Class class = object_getClass((id)self);
    
    exchangeMethod([delegate class], @selector(webView:didFinishLoadForFrame:), [class class], @selector(webView:replace_didFinishLoadForFrame:),@selector(webView:replace_didFinishLoadForFrame:));
}


-(id)settingForkey:(NSString *)key
{
    return [self.commandDelegate.settings objectForKey:key];
}

-(void) injectCordovaJsForRemotePage {
    NSString* isWebviewRemoteInject = [self settingForkey: @"isWebviewRemoteInject"];
    if(isWebviewRemoteInject){
        NSString* injectCordovaJs =[ NSString stringWithFormat: @";(function injectCordovaJS(){var scriptTag = document.createElement('script');scriptTag.src ='cordova/cordova.js';document.body.appendChild(scriptTag);})();"];

        id win = [self.webView windowScriptObject];
        
        [win evaluateWebScript:injectCordovaJs];
        
    }
    
}

- (void) didFinishLoadForFrame{
    [self injectCordovaJsForRemotePage];
}

#pragma mark WebFrameLoadDelegate for replace CDVWebViewDelegate webView:didFinishLoadForFrame:

- (void) webView:(WebView*) sender replace_didFinishLoadForFrame:(WebFrame*) frame {
    [self webView:sender replace_didFinishLoadForFrame:frame]; // 因为和didFinishLoadForFrame交换了实现，所以这不是循环调用
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webView:didFinishLoadForFrame:" object:nil];
}
    
@end
