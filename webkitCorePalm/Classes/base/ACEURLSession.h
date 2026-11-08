#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 引擎私有的POST请求封装；HTTP状态由业务判断，完成回调统一派发到主队列。
typedef void (^ACEURLSessionCompletion)(NSData * _Nullable data,
                                        NSHTTPURLResponse * _Nullable response,
                                        NSError * _Nullable error);

@interface ACEURLSession : NSObject

/// 启动即返回；每个请求独立持有证书策略，避免并发请求串用配置。
+ (nullable NSURLSessionDataTask *)postURL:(nullable NSURL *)URL
                                 headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                                    body:(nullable NSData *)body
              validatesServerCertificate:(BOOL)validatesServerCertificate
                   clientCertificateData:(nullable NSData *)certificateData
                     certificatePassword:(nullable NSString *)password
                              completion:(nullable ACEURLSessionCompletion)completion;

/// 仅编码普通表单，不支持multipart；字符串及NSNumber按UTF-8进行百分号编码。
+ (NSData *)formBodyWithParameters:(NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END
