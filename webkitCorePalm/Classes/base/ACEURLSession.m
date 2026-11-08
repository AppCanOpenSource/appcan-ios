#import "ACEURLSession.h"
#import <Security/Security.h>

/// 一个实例只服务一个请求，由session持有至完成后invalidate，不维护全局可变TLS状态。
@interface ACEURLSession () <NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (nonatomic) BOOL validatesServerCertificate;
@property (nonatomic, strong) NSURLCredential *clientCredential;
@end

@implementation ACEURLSession

+ (NSURLSessionDataTask *)postURL:(NSURL *)URL
                         headers:(NSDictionary<NSString *, NSString *> *)headers
                            body:(NSData *)body
      validatesServerCertificate:(BOOL)validatesServerCertificate
           clientCertificateData:(NSData *)certificateData
             certificatePassword:(NSString *)password
                      completion:(ACEURLSessionCompletion)completion {
    if (!URL || !([URL.scheme.lowercaseString isEqualToString:@"http"] ||
                  [URL.scheme.lowercaseString isEqualToString:@"https"]) || URL.host.length == 0) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]);
            });
        }
        return nil;
    }

    ACEURLSession *delegate = [[self alloc] init];
    delegate.validatesServerCertificate = validatesServerCertificate;
    if (certificateData) {
        // SecPKCS12Import返回的identity由items持有；NSURLCredential在items释放前接管所需引用。
        CFArrayRef importedItems = NULL;
        NSDictionary *options = @{(__bridge NSString *)kSecImportExportPassphrase: password ?: @""};
        OSStatus status = SecPKCS12Import((__bridge CFDataRef)certificateData,
                                        (__bridge CFDictionaryRef)options, &importedItems);
        NSArray *items = CFBridgingRelease(importedItems);
        NSDictionary *item = items.firstObject;
        SecIdentityRef identity = (__bridge SecIdentityRef)item[(__bridge NSString *)kSecImportItemIdentity];
        if (status == errSecSuccess && identity) {
            // 证书链首项是客户端自身证书，credential的certificates只传中间证书。
            NSArray *chain = item[(__bridge NSString *)kSecImportItemCertChain];
            NSArray *intermediates = chain.count > 1 ? [chain subarrayWithRange:NSMakeRange(1, chain.count - 1)] : nil;
            delegate.clientCredential = [NSURLCredential credentialWithIdentity:identity
                                                                   certificates:intermediates
                                                                    persistence:NSURLCredentialPersistenceForSession];
        }
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:60];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = headers;
    request.HTTPBody = body;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.URLCache = nil; // 这些推送POST不使用响应缓存，Cookie仍使用系统共享存储。
    configuration.timeoutIntervalForRequest = 60;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 无论成功、HTTP错误或取消，都释放session对delegate的持有，不留下循环引用。
        [session finishTasksAndInvalidate];
        if (completion) {
            NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data, HTTPResponse, error);
            });
        }
    }];
    [task resume];
    return task;
}

+ (NSData *)formBodyWithParameters:(NSDictionary<NSString *, id> *)parameters {
    // 只保留RFC3986的unreserved字符；不能使用URLHostAllowedCharacterSet编码表单。
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"];
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:parameters.count];
    for (NSString *key in [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSString *name = [key stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *value = [[parameters[key] description] stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", name, value]];
    }
    return [[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}

/// 只在旧业务明确关闭校验时接收server trust；默认校验始终交给系统，不能绕过ATS。
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSString *method = challenge.protectionSpace.authenticationMethod;
    if (challenge.previousFailureCount > 0) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    } else if ([method isEqualToString:NSURLAuthenticationMethodServerTrust] &&
               !self.validatesServerCertificate && challenge.protectionSpace.serverTrust) {
        completionHandler(NSURLSessionAuthChallengeUseCredential,
                          [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    } else if ([method isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        completionHandler(self.clientCredential ? NSURLSessionAuthChallengeUseCredential : NSURLSessionAuthChallengeCancelAuthenticationChallenge,
                          self.clientCredential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    [self URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
}

@end
