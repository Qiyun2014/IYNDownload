//
//  IDYDownloadManager.m
//  testDemo
//
//  Created by qiyun on 16/9/8.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "IDYDownloadManager.h"


#pragma mark    -   IDYSessionRequest

/* ---------------------------------------------------------------------------------------------------------------------------------------------------- */

@implementation IDYSessionRequest

@end


#pragma mark    -   IDYDownloadManager

/* ---------------------------------------------------------------------------------------------------------------------------------------------------- */

@implementation IDYDownloadManager

static  IDYDownloadManager *manager = NULL;
+ (IDYDownloadManager *)shareInstanceManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[IDYDownloadManager alloc] init];
    });
    return manager;
}

- (id)init{
    
    if (self == [super init]) {
        
        _downloadingRequests    = [[NSMutableArray alloc] init];
        _finishRequests         = [[NSMutableArray alloc] init];
        _waitingRequests        = [[NSMutableArray alloc] init];
        _maxTaskCount           = 3;
    }
    return self;
}

/* 添加到下载列表 */
- (void)requestWithUrl:(NSURL *)url fileName:(NSString *)name{
    
    IDYRequestTask *requestTask = [[IDYRequestTask alloc] initWithRequestUrl:url storeWithFileName:name];
    requestTask.delegate = self;
    
    if (self.downloadingRequests.count >= self.maxTaskCount) {
        
        [self.waitingRequests addObject:requestTask];
    }else{
        [requestTask downloadStart];
    }
}


- (void)sessionDownloadStart:(IDYRequestTask *)request{
    
    if (![self.downloadingRequests containsObject:request]) [self.downloadingRequests addObject:request];
}

/**~
 *  如果有一个任务下载停止，就需要从等待任务中新增一条任务进来
 */
- (void)sessionDownloadStop:(IDYRequestTask *)request{
    
    [self.downloadingRequests removeObject:request];
    [_waitingRequests addObject:request];
    

    /* 移动任务到当前下载中 */
    if (_waitingRequests.count) {
        
        IDYRequestTask *requestTask = _waitingRequests.firstObject;
        [requestTask downloadStart];
        [_waitingRequests removeObjectAtIndex:0];
    }
}

/**!
 *  如果需要对任务进行恢复，先判断当前任务是否是三个；少于三个自动恢复下载，否则加入到等待队列
 */
- (void)sessionDownloadResume:(IDYRequestTask *)request{
    
    [_waitingRequests removeObject:request];
    if (![self.downloadingRequests containsObject:request]) [self.downloadingRequests addObject:request];
    
}

- (void)sessionDownloadError:(NSError *)error withTaskRequest:(IDYRequestTask *)request{
    
    if (error) {
        
        [self.downloadingRequests removeObject:request];
        if (![_waitingRequests containsObject:request]) [_waitingRequests addObject:request];
        
        if (_waitingRequests.count) {
            
            IDYRequestTask *requestTask = _waitingRequests.firstObject;
            [requestTask downloadStart];
        }
    }
}

- (void)sessionDownloadComplete:(IDYRequestTask *)request{
    
    if (![self.finishRequests containsObject:request]) [self.finishRequests addObject:request];
    [self.downloadingRequests removeObject:request];
    
    if (_waitingRequests.count) {
        
        IDYRequestTask *requestTask = _waitingRequests.firstObject;
        [requestTask downloadStart];
    }
}

@end

#pragma mark    -   IDYRequestTask

/* ---------------------------------------------------------------------------------------------------------------------------------------------------- */

@interface IDYRequestTask ()

@property (strong, nonatomic) IDYSessionManager *sessionManager;

@end

@implementation IDYRequestTask

- (instancetype)initWithRequestUrl:(NSURL *)url storeWithFileName:(NSString *)fileName{
    
    if (self == [super init]) {
        
        _requestModel = [[IDYSessionRequest alloc] init];
        _requestModel.fileName = fileName;
        _requestModel.originUrl = url;
        _sessionManager = [IDYSessionManager shareInstanceManagerWithSessionType:IDYUploadSession_background];
        _requestModel.status = IDYSessionStatus_unknow;
    }
    return self;
}

- (void)downloadStart{
    
    _requestModel.status = IDYSessionStatus_start;
    
    /* 开始进行下载，并实时获取进度 */
    [_sessionManager downloadManagerWithRequestUrl:_requestModel.originUrl
                                     storeFileName:_requestModel.fileName
                                 completionHanlder:^(NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                                     
                                     if (_requestModel.total) _requestModel.total = [self formatByteCount:totalBytesExpectedToSend];
                                     if (_requestModel.receive) _requestModel.receive([self formatByteCount:totalBytesSent]);
                                     NSLog(@"sent = %lld, total = %lld, expeted = %lld",bytesSent,totalBytesSent, totalBytesExpectedToSend);
                                 }];
    
    /* 当前视频下载完成 */
    _sessionManager.downloadFinished = ^(NSURLSessionTask *task , NSURL *location){
        
        _requestModel.destinationPath = location.path;

        _requestModel.status = IDYSessionStatus_completed;
        
        if ([self.delegate respondsToSelector:@selector(sessionDownloadComplete:)]) {
            
            [self.delegate sessionDownloadComplete:self];
        }
    };
    
    /* 下载报错 */
    _sessionManager.errorSession = ^(NSError *error, NSURLSessionTask *task){
        
        _requestModel.status = IDYSessionStatus_faild;
        
        if ([self.delegate respondsToSelector:@selector(sessionDownloadError:withTaskRequest:)]) {
            
            [self.delegate sessionDownloadError:error withTaskRequest:self];
        }
    };
    
    /* 当前视频下载速度 */
    [_sessionManager daskDownloadOfSpeed:^(NSString *spped) {
        
        NSLog(@"speed = %@",spped);
        if (_requestModel.speed) _requestModel.speed(spped);
    }];
    
    if ([self.delegate respondsToSelector:@selector(sessionDownloadStart:)]) {
        
        [self.delegate sessionDownloadStart:self];
    }
}

- (void)downloadStop{
    
    _requestModel.status = IDYSessionStatus_stop;
    
    /* 中断下载 */
    [_sessionManager resumePause];
    
    if ([self.delegate respondsToSelector:@selector(sessionDownloadStop:)]) {
        
        [self.delegate sessionDownloadStop:self];
    }
}

- (void)downloadResume{
    
    if (!_requestModel.receive) {
        
        [self downloadStart];
        return;
    }
    
    _requestModel.status = IDYSessionStatus_start;
    
    /* 恢复下载 */
    [_sessionManager resumeStart];
    
    if ([self.delegate respondsToSelector:@selector(sessionDownloadResume:)]) {
        
        [self.delegate sessionDownloadResume:self];
    }
}


- (NSString *)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}



@end

