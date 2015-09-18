//
//  EUExBase+Bundle.h
//  AppCanEngine
//
//  Created by Cerino on 15/9/11.
//
//



#import "EUExBase.h"



/**
 *  @method uexLocalizedString(...) 
 *
 *  @discussion 从插件资源文件加载本地化字符串的预定义宏
 *
 *  @see localizedString:
 *
 *  @example uexLocalizedString(@"test");
 *      搜索@"test"对应的本地字符串，未找到时返回key本身（即@"test"）
 *
 *  @example uexLocalizedString(@"test",@"测试");
 *      搜索@"test"对应的本地字符串，未找到时返回@"测试"
 */
#define uexLocalizedString(...)   \
    [self localizedString:__VA_ARGS__,nil]





/**
 *  @method meBundle  插件的bundle实例的预定义宏
 *
 */
#define meBundle \
    [self pluginBundle]


@interface EUExBase (Bundle)
/**
 *  获取插件的bundle实例
 *
 *  @return 插件同名的NSBundle实例
 */
-(NSBundle *)pluginBundle;


/**
 *  获取本地化字符串
 *
 *  @param 第一个参数为获取本地化字符串的key,
 *  @param 第二个参数(可选)为取值失败时的返回值,(此参数不传，取值失败时，将返回key的值）
 *  @param 其他参数将被忽略
 *  @return 取得的本地化字符串
 */
-(NSString *)localizedString:(NSString *)param,...;





@end
