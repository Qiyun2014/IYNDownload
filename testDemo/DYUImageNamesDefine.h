//
//  DYUImageNameDefine.h
//  DYVideoTools
//
//  Created by qiyun on 16/8/25.
//  Copyright © 2016年 qiyun. All rights reserved.
//


#ifndef DYUImageNamesDefine_h
#define DYUImageNamesDefine_h

#pragma mark    -   notification key

static NSString * const DY_Home_camera_start = @"com.douyu.cameraStart";

#pragma mark    -   take of video images

static NSString * const DY_Home_tabbar_background                   = @"tab_bg";            /* 背景图 */
static NSString * const DY_Home_tabbar_camera_normal                = @"tab_room";          /* 相机未点击状态图 */
static NSString * const DY_Home_tabbar_camera_select                = @"tab_room_p";        /* 相机点击状态图 */
static NSString * const DY_Camera_tools_hiden                       = @"tab_room_p";        /* 隐藏图片 */
static NSString * const DY_camera_tools_camera                      = @"btn_record_big_a";
static NSString * const DY_camera_tools_upload                      = @"btn_del_active_a";
static NSString * const DY_camera_record_back_available             = @"btn_del_a";
static NSString * const DY_camera_record_back_unavailable           = @"btn_del_c";
static NSString * const DY_camera_record_record_start               = @"filter_mask_b";
static NSString * const DY_camera_record_record_stop                = @"icon_badge_bg_list";
static NSString * const DY_camera_record_complete_available         = @"btn_camera_done_a";
static NSString * const DY_camera_record_complete_unavailable       = @"btn_camera_done_c";
static NSString * const DY_camera_player_pause                      = @"btn_play_bg_b";


static NSString * const dy_userCenter_title_image           = @"Img_user_register";
static NSString * const dy_video_play_title_image           = @"btn_video_upload_title";

static NSString * const dy_video_record_start               = @"btn_record_start";
static NSString * const dy_video_record_recording           = @"btn_recording";
static NSString * const dy_video_record_play                = @"btn_record_play";
//static NSString * const dy_video_record_start               = @"btn_record_start";

static NSString * const dy_video_record_upload              = @"btn_record_upload";
static NSString * const dy_video_record_confirm             = @"btn_record_confirm";
static NSString * const dy_video_record_rest                = @"btn_record_rest";


static NSString * const dy_camera_video_back                = @"dyla_返回";
static NSString * const dy_camera_video_back_press          = @"dyla_返回pressed";
static NSString * const dy_camera_video_beaultiful          = @"dyla_美颜";
static NSString * const dy_camera_video_beaultiful_select   = @"dyla_关闭美颜";
static NSString * const dy_camera_video_camera              = @"dyla_白底镜头pressed";
static NSString * const dy_camera_video_camera_press        = @"dyla_转换摄像头pressed";
static NSString * const dy_camera_video_flash               = @"dyla_btn_flash_close_pressed";
static NSString * const dy_camera_video_flash_unable        = @"dyla_关闭闪光灯";


static NSString * const dy_camera_record_reset              = @"btn_giftsview_close";
static NSString * const dy_camera_record_complete           = @"image_message_select";


static NSString * const dy_camera_record_upad               = @"上传视频";
static NSString * const dy_camera_record_rest               = @"重录";
static NSString * const dy_camera_record_comp               = @"完成";
static NSString * const dy_camera_record_duration_limit     = @"至少录制10s";


#define metamacro_concat_(A, B) A ## B
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) metamacro_concat_(weak,object) = object
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) metamacro_concat_(block,object) = object
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) metamacro_concat_(weak,object) = object
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) metamacro_concat_(block,object) = object
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = metamacro_concat_(weak,object)
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = metamacro_concat_(block,object)
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = metamacro_concat_(weak,object)
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = metamacro_concat_(block,object)
#endif
#endif
#endif



#ifndef YNSYNTH_DUMMY_CLASS
#define YNSYNTH_DUMMY_CLASS(_name_) \
@interface YNSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation YNSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


//屏幕宽度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

//屏幕高度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define DYImageNamed(name) [UIImage imageNamed:name]

//rgb色值
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#ifdef DEBUG
#   define DYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DYLog(...)
#endif

#endif /* DYUImageNameDefine_h */
