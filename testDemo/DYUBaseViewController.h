//
//  DYUBaseViewController.h
//  DYVideoTools
//
//  Created by qiyun on 16/8/25.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYUImageNamesDefine.h"
//#import "QiniuSDK.h"
#import "UIImage+Utils.h"

@interface DYUBaseViewController : UIViewController

/* 截屏 */
+ (UIImage *)screenShorture;

/* 七牛上传 */
/*
- (void)qn_uploadData:(NSData *)data
                  key:(NSString *)key
                token:(NSString *)token
     completedHanlder:(void(^)(QNResponseInfo *info, NSDictionary *resp))completed;
*/


/**!
 *  视频上传
 *  params @{width : 320, height : 480, duration : 10, title : aaa, description : bbb}
 */
- (void)uploadVideoOfFilePath:(NSString *)filePath videoParams:(NSDictionary *)params completedHandler:(void (^) (int result, NSString *resMessage, id data))complete;


/**!
 *  视频处理(剪切和水印)
 */
- (void)editingVideoWithUrl:(NSURL *)url videoSize:(CGSize)size completedHanlder:(void (^) (int result, NSString *outPath))complete;

@end



@interface IDYButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame buttonWithType:(UIButtonType)type;

//action 响应的block函数
@property (nonatomic, copy)     void (^actionBlock)(id sender);

@property (nonatomic, assign)   BOOL         cornerRadius;
@property (nonatomic, assign)   BOOL         graduallyHidden;

@property (nonatomic, copy)     NSString     *normalImageNamed;
@property (nonatomic, copy)     NSString     *highLightImageNamed;
@property (nonatomic, copy)     NSString     *disableImageNamed;
@property (nonatomic, copy)     NSString     *titleString;

@end



@interface UIView (IDYView)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;


@end