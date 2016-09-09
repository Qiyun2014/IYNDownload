//
//  IDYDownloadManager.h
//  testDemo
//
//  Created by qiyun on 16/9/8.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDYSessionManager.h"

typedef void (^SessionRequestSpeed) (NSString *speed);

typedef NS_ENUM(NSInteger, IDYSessionStatus) {
    
    IDYSessionStatus_unknow = 0,
    IDYSessionStatus_start,
    IDYSessionStatus_stop,
    IDYSessionStatus_completed,
    IDYSessionStatus_faild
};


@class IDYRequestTask;
@protocol IDYSessionDelegate <NSObject>

@optional
- (void)sessionDownloadStart:(IDYRequestTask *)request;
- (void)sessionDownloadStop:(IDYRequestTask *)request;
- (void)sessionDownloadResume:(IDYRequestTask *)request;
- (void)sessionDownloadError:(NSError *)error withTaskRequest:(IDYRequestTask *)request; /* 下载完成之后，也会执行此方法，如果有错就抛出异常，否则是空 */
- (void)sessionDownloadComplete:(IDYRequestTask *)request;

@end

/**!
 *  此处作为所有可用信息的获取
 *
 *  如果不上传文件指定路径，将使用默认路径地址；可用只是用文件名称进行网络视频下载，将自动下载到library/caches目录下
 */
@interface IDYSessionRequest : NSObject

@property (nonatomic, copy) NSString                *fileName;
@property (nonatomic, copy) NSString                *filePath;     /* optionl */
@property (nonatomic, copy) NSString                *total;
@property (nonatomic, copy) NSURL                   *originUrl;
@property (nonatomic, copy) NSString                *destinationPath;
@property (nonatomic, copy) SessionRequestSpeed     receive;
@property (nonatomic, copy) SessionRequestSpeed     speed;
@property (nonatomic) IDYSessionStatus              status;

@end



@interface IDYDownloadManager : NSObject<IDYSessionDelegate>

+ (IDYDownloadManager *)shareInstanceManager;

@property NSInteger maxTaskCount;   /* 最大下载数,默认是3 */
@property (copy, nonatomic) NSMutableArray  *finishRequests;            /* 下载完成 */
@property (copy, nonatomic) NSMutableArray  *downloadingRequests;       /* 下载中 */
@property (copy, nonatomic) NSMutableArray  *waitingRequests;           /* 下载等待 */

- (void)requestWithUrl:(NSURL *)url fileName:(NSString *)name;

@end


@interface IDYRequestTask : NSObject

@property (nonatomic, weak) id<IDYSessionDelegate>  delegate;
@property (strong, nonatomic) IDYSessionRequest *requestModel;

- (instancetype)initWithRequestUrl:(NSURL *)url storeWithFileName:(NSString *)fileName;

- (void)downloadStart;
- (void)downloadStop;
- (void)downloadResume;

@end
