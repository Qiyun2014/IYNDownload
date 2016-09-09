//
//  IDYUploadManager.m
//  DYZB
//
//  Created by qiyun on 16/9/5.
//  Copyright © 2016年 mydouyu. All rights reserved.
//

#import "IDYSessionManager.h"
#import <objc/runtime.h>

typedef void (^DownloadSpeedHanlder) (NSString *speed);

@interface IDYSessionManager ()

@property (copy, nonatomic) UploadCompletionHanlder completionHanlder;
@property (copy, nonatomic) DownloadCompletionHanlder downloadCompletionHanlder;
@property (copy, nonatomic) DownloadSpeedHanlder    speedHanlder;
@property (copy, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (copy, nonatomic) NSString    *resumeFilePath;
@property (weak, nonatomic) NSTimer     *timer;

@end

@implementation IDYSessionManager{
    
    int64_t     afterTotal;
    int64_t     beforeTotal;
}


static IDYSessionManager *uploadManager = nil;
+ (id)shareInstanceManagerWithSessionType:(IDYUploadSessionType)type{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        uploadManager = [[IDYSessionManager alloc] init];
        
        switch (type) {
                
            case IDYUploadSession_default:{
                
                NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
                
#if TARGET_OS_IPHONE
                NSString *cachePath = @"/Download";
                
                NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *myPath    = [myPathList  objectAtIndex:0];
                
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                
                NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
                NSLog(@"Download path: %@\n", fullCachePath);
#else
                NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/nsurlsession.cache"];
                
                NSLog(@"Cache path: %@\n", cachePath);
#endif
                
                NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity: 16384 diskCapacity: 268435456 diskPath: cachePath];
                defaultConfigObject.URLCache = myCache;
                defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
                if (uploadManager.cachePolicy) defaultConfigObject.requestCachePolicy = (NSURLRequestCachePolicy)uploadManager.cachePolicy;
                defaultConfigObject.timeoutIntervalForRequest = uploadManager.timeoutInterval;
                
                //uploadManager.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: uploadManager delegateQueue: [NSOperationQueue mainQueue]];
                uploadManager.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
            }
                
                break;
                
            case IDYUploadSession_background:{
                
                NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: @"com.douyu.tv.myBackgroundSessionIdentifier"];
                if (uploadManager.cachePolicy) backgroundConfigObject.requestCachePolicy = (NSURLRequestCachePolicy)uploadManager.cachePolicy;
                else backgroundConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                backgroundConfigObject.timeoutIntervalForRequest = uploadManager.timeoutInterval;
                uploadManager.backgroundSession = [NSURLSession sessionWithConfiguration: backgroundConfigObject delegate: uploadManager delegateQueue: [NSOperationQueue mainQueue]];
            }
                
                break;
                
            case IDYUploadSession_ephemeral:{
                
                NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
                if (uploadManager.cachePolicy) ephemeralConfigObject.requestCachePolicy = (NSURLRequestCachePolicy)uploadManager.cachePolicy;
                ephemeralConfigObject.timeoutIntervalForRequest = uploadManager.timeoutInterval;
                uploadManager.ephemeralSession = [NSURLSession sessionWithConfiguration: ephemeralConfigObject delegate: uploadManager delegateQueue: [NSOperationQueue mainQueue]];
                ephemeralConfigObject.allowsCellularAccess = NO;    //是否允许蜂窝网络请求
            }
                
                break;
                
            default:
                break;
        }
        
#if TARGET_OS_IPHONE
        uploadManager.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
#endif
        
    });
    return uploadManager;
}

- (id)initWithSessionType:(IDYUploadSessionType)type{
    
    if (self == [super init]) {
        
        switch (type) {
                
            case IDYUploadSession_default:{
                
                NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
                
#if TARGET_OS_IPHONE
                NSString *cachePath = @"/Download";
                
                NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *myPath    = [myPathList  objectAtIndex:0];
                
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                
                NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
                NSLog(@"Download path: %@\n", fullCachePath);
#else
                NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/nsurlsession.cache"];
                
                NSLog(@"Cache path: %@\n", cachePath);
#endif
                
                NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity: 16384 diskCapacity: 268435456 diskPath: cachePath];
                defaultConfigObject.URLCache = myCache;
                defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
                if (self.cachePolicy) defaultConfigObject.requestCachePolicy = (NSURLRequestCachePolicy)self.cachePolicy;
                defaultConfigObject.timeoutIntervalForRequest = self.timeoutInterval;
                
                //uploadManager.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: uploadManager delegateQueue: [NSOperationQueue mainQueue]];
                self.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
            }
                
                break;
                
            case IDYUploadSession_background:{
                
                NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: @"com.douyu.tv.myBackgroundSessionIdentifier"];
                if (self.cachePolicy) backgroundConfigObject.requestCachePolicy = (NSURLRequestCachePolicy)self.cachePolicy;
                backgroundConfigObject.timeoutIntervalForRequest = self.timeoutInterval;
                self.backgroundSession = [NSURLSession sessionWithConfiguration: backgroundConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
            }
                
                break;
                
            case IDYUploadSession_ephemeral:{
                
                NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
                if (self.cachePolicy) ephemeralConfigObject.requestCachePolicy = (NSURLRequestCachePolicy)self.cachePolicy;
                ephemeralConfigObject.timeoutIntervalForRequest = self.timeoutInterval;
                self.ephemeralSession = [NSURLSession sessionWithConfiguration: ephemeralConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
                ephemeralConfigObject.allowsCellularAccess = NO;    //是否允许蜂窝网络请求
            }
                
                break;
                
            default:
                break;
        }
        
#if TARGET_OS_IPHONE
        self.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
#endif
        
    }
    return self;
}

#pragma mark    -   private method

- (void)uploadManagerWithIdentifier:(NSString *)identifier
                           fromFile:(NSString *)filePath
                         requestUrl:(NSURL *)url
                    completionHanlder:(UploadCompletionHanlder)complete{
    
    NSAssert(!self.backgroundSession, @"session can not nil");
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionUploadTask *uploadTask = [self.backgroundSession uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:filePath]];
    [uploadTask resume];
    
    _completionHanlder = complete;
}


- (void)downloadManagerWithRequestUrl:(NSURL *)url storeFilePath:(NSString *)path completionHanlder:(DownloadCompletionHanlder)complete{
    
    NSLog(@"path = %@",path);
    
    self.resumeData = [NSData dataWithContentsOfFile:path];
    self.resumeFilePath = path;
    
    if (self.resumeData) {
        
        _downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
        
    }else{
        
        [self.resumeData writeToFile:path atomically:YES];
        _downloadTask = [self.backgroundSession downloadTaskWithURL: url];
    }
    
    [_downloadTask resume];
    
    _downloadCompletionHanlder = complete;
    
    beforeTotal = 0;
    afterTotal = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(reachabilityAction:) userInfo:nil repeats:YES];

    objc_setAssociatedObject(self, (__bridge const void *)(url.absoluteString), path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)downloadManagerWithRequestUrl:(NSURL *)url storeFileName:(NSString *)fileName completionHanlder:(DownloadCompletionHanlder)complete{
    
    if ([self fileExistsWithName:fileName]) return;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    fileName = [cachesDir stringByAppendingPathComponent:fileName];
    
    [self saveUrlToPlistWithPath:cachesDir fileName:fileName requestUrl:url];
    
    self.resumeData = [NSData dataWithContentsOfFile:fileName];
    self.resumeFilePath = fileName;
    NSLog(@"fileName = %@",self.resumeFilePath);

    if (self.resumeData) {
        
        _downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
        
    }else{
        
        [self.resumeData writeToFile:fileName atomically:YES];
        _downloadTask = [self.backgroundSession downloadTaskWithURL: url];
    }
    
    [_downloadTask resume];
    
    _downloadCompletionHanlder = complete;
    
    beforeTotal = 0;
    afterTotal = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(reachabilityAction:) userInfo:nil repeats:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:url.absoluteString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)defaultManagerWithRequestUrl:(NSURL *)url completionHanlder:(SessionRequestCompletionHanlder)complete{
    
    IDYSessionManager *manager = [IDYSessionManager shareInstanceManagerWithSessionType:IDYUploadSession_default];
    NSAssert(!manager, @"manager is null");
    
    [[manager.defaultSession dataTaskWithURL: url completionHandler:complete] resume];
    
    /*
     NSLog(@"Got response %@ with error %@.\n", response, error);
     NSLog(@"DATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData: data
     encoding: NSUTF8StringEncoding]);
     */
}


- (void)resumePause{
    
    if (_downloadTask) {
        
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
            NSLog(@"暂停下载 = %zd",resumeData.length);
            // 记录续传数据
            self.resumeData = resumeData;
            
            // 清空下载任务
            self.downloadTask = nil;
            
            // 将续传数据写入文件中
            [resumeData writeToFile:self.resumeFilePath atomically:YES];
        }];
    }
}

- (void)resumeStart{
    
    if (self.resumeData == nil)  return;
    
    // 根据续传数据发起下载任务，那么任务的下载就从续传数据指定的位置开始下载
    self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
    
    // 继续任务
    [self.downloadTask resume];
}

- (NSData *)dataWithResumeOfPath:(NSString *)filePath{
    
    return [NSData dataWithContentsOfFile:filePath];
}


#pragma mark    -   NSURLSession delegate

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"文件已下载完成");
    //NSError *error = [NSError errorWithDomain:@"8080" code:4000 userInfo:@{@"description":@"is invalid address"}];

    if (_completionHanlder) _completionHanlder(task, NSIntegerMax, NSIntegerMax, NSIntegerMax);
    if (self.errorSession) self.errorSession(error, task);
    
    [_timer invalidate];
    _timer = nil;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    if (_completionHanlder) _completionHanlder(task,bytesSent,totalBytesSent,totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
#if 0
    /* Workaround */
    [self callCompletionHandlerForSession:session.configuration.identifier];
#endif
    
    if (!self.resumeFilePath) {
        
        self.resumeFilePath = location.path;
        return;
    }
    
#define READ_THE_FILE 0
#if READ_THE_FILE
    /* Open the newly downloaded file for reading. */
    NSError *err = nil;
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location
                                                           error: &err];
    
    /* Store this file handle somewhere, and read data from it. */
    // ...
    
#else
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    
    NSLog(@"absoluteString = %@",downloadTask.currentRequest.URL.absoluteString);
    self.resumeFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:downloadTask.currentRequest.URL.absoluteString];
    
    //self.resumeFilePath = objc_getAssociatedObject(self, (__bridge const void *)(downloadTask.currentRequest.URL.absoluteString));
    //NSLog(@"\nlocation = %@",location.path);
    //NSLog(@"task = %@",downloadTask.description);
    //NSLog(@"self.resumeFilePath = %@\n",self.resumeFilePath);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:downloadTask.currentRequest.URL.absoluteString];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_timer invalidate];
        _timer = nil;
        objc_removeAssociatedObjects(self);
    });
    
    if (!self.resumeFilePath) { self.errorSession(err, downloadTask); return; }
    
    if ([fileManager moveItemAtPath:location.path toPath:self.resumeFilePath error:&err]) {
        
        if (self){
            
            if (self.downloadFinished) self.downloadFinished(downloadTask, location);
            
        }else{
            
            IDYSessionManager *sessionManager = [IDYSessionManager shareInstanceManagerWithSessionType:IDYUploadSession_background];
            if (sessionManager) sessionManager.downloadFinished(downloadTask, location);
        }
        
        /* Store some reference to the new URL */
        
    }else{
        
        if (self.downloadFinished) self.downloadFinished(downloadTask, location);
        NSLog(@"error = %@",[err description]);
    }
    
    if ([fileManager fileExistsAtPath:location.path]) [fileManager removeItemAtPath:location.path error:nil];
#endif
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    afterTotal = totalBytesWritten;
    if (_downloadCompletionHanlder) _downloadCompletionHanlder(downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
}



#if TARGET_OS_IPHONE
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier)
        [self callCompletionHandlerForSession: session.configuration.identifier];
}

- (void) addCompletionHandler: (CompletionHandlerType) handler forSession: (NSString *)identifier
{
    if ([ self.completionHandlerDictionary objectForKey: identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [ self.completionHandlerDictionary setObject:handler forKey: identifier];
}

- (void) callCompletionHandlerForSession: (NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey: identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler.\n");
        
        handler();
    }
}
#endif

- (void)reachabilityAction:(NSTimer *)timer{
    
    self.speedHanlder([self formatByteCount:llabs(afterTotal - beforeTotal)]);

    beforeTotal = afterTotal;
}


- (void)daskDownloadOfSpeed:(void (^) (NSString *spped))speedDescription{
    
    self.speedHanlder = speedDescription;
}


/* 将文件大小转化为字符串 ，单位为M/K */
- (NSString *)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}


/* 判断文件是否已经下载到文件夹下 */
- (BOOL)fileExistsWithName:(NSString *)name{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    __block BOOL   isExist = NO;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cachesDir error:nil];
    
    @synchronized (self) {
        
        [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isEqualToString:name] && [obj hasSuffix:@".mp4"]) {
                
                isExist =  YES;
            }
        }];
    }
    
    return isExist;
}

- (void)saveUrlToPlistWithPath:(NSString *)cachesDir fileName:(NSString *)fileName requestUrl:(NSURL *)url{
    
    NSArray *infos = @[url.absoluteString,[fileName lastPathComponent]];
    NSString *filePath = [cachesDir stringByAppendingPathComponent:@"download.plist"];
    
    NSMutableArray *fileData = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (!fileData) fileData = [NSMutableArray array];
    
    [fileData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isEqualToArray:infos]) {
            
            [fileData removeObject:obj];
        }
    }];
    
    [fileData addObject:infos];
    [fileData writeToFile:filePath atomically:YES];
}

@end
