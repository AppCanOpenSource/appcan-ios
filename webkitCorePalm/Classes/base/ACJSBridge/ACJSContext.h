//
//  ACJSContext.h
//  AppCanEngine
//
//  Created by Jay on 2020/5/15.
//

#ifndef ACJSContext_h
#define ACJSContext_h

@protocol ACJSContext <NSObject>

- (void)ac_evaluateJavaScript:(NSString *)javaScriptString;

- (void)ac_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

@end

#endif /* ACJSContext_h */
