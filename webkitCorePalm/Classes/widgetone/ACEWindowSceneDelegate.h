#import <UIKit/UIKit.h>

// 由宿主Manifest交给UIKit创建；首阶段仅承载一个主Scene，不新增插件协议。
@interface ACEWindowSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (nonatomic, strong) UIWindow *window;
@end
