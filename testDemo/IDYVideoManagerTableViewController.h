//
//  IDYVideoManagerTableViewController.h
//  testDemo
//
//  Created by qiyun on 16/9/12.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDYVideoManagerTableViewController : UITableViewController



@end


@interface IDYVideoModel : NSObject

@property (copy, nonatomic) NSString *videoTitle;
@property (copy, nonatomic) NSURL   *videoUrl;
@property (copy, nonatomic) NSDate  *videoCreation;

@end