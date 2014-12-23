//
//  SpeechUser.h
//
//
//  Created by ypzhao on 12-10-16.
//
//

#import <Foundation/Foundation.h>
@class SpeechUserImp;

@interface SpeechUser : NSObject
{
    SpeechUserImp *_speechUserImp;
}

/**
 * @fn      login
 * @brief   登录接口
 *
 * @return  BOOL                    -Return YES,表示成功; Return NO,表示失败.
 * @param   NSString* usr           -[in] 登录时用户传入的用户名－用户名为再开发者论坛中申请
 * @param   NSString* pwd           -[in] 登录时传入的用户密码
 * @param   NSString* params        -[in] 用户登录时传入的参数
 * @see
 */
- (BOOL) login: (NSString*) usr password: (NSString*)pwd params: (NSString *)params;


/**
 * @fn      getLoginState
 * @brief   获取登录状态
 *
 * @return  int                     -Return 1,表示登录成功; Return 0,表示登录失败.
 * @see
 */
- (int) getLoginSate;


/**
 * @fn      logout
 * @brief   注销登录
 *
 * @return  BOOL                    -Return YES,表示登录成功; Return NO,表示登录失败.
 * @see
 */
- (BOOL) logout;

/**
 * @fn
 */
- (id) init;

@end
