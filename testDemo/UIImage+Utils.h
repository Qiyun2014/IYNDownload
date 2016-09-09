//
//  UIImage+Utils.h
//  DYZB
//
//  Created by 周兵 on 15/4/27.
//  Copyright (c) 2015年 mydouyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (NSString *)imageURLString;
- (void)setImageURLString:(NSString *)URLString;


/**
 *  存颜色创建图片
 */
+ (UIImage *)imgWithRed:(float)red green:(float)green blue:(float)blue size:(CGSize)size alpha:(float)alpha;

/**
 *	根据颜色，生成图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *	将UIImage改成圆角
 */
- (UIImage *)imageWithSize:(CGSize)size roundCorners:(CGFloat)radius;

/**
 *	改变图片尺寸
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;

/**
 *	裁剪图片
 */
+ (UIImage *)imageWithImage:(UIImage *)image clippedToSize:(CGSize)size;

/**
 *	保持原来的长宽比，生成一个缩略图
 */
+ (UIImage *)imageWithImage:(UIImage *)image thumbnailWithoutScaleToSize:(CGSize)size;

/**
 *  修改图片尺寸
 *
 *  @param image     image
 *  @param scaleSize 比例
 *
 *  @return
 */
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;


- (UIImage *)gaussBlurImage:(CGFloat)blurRadius;
- (UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end
