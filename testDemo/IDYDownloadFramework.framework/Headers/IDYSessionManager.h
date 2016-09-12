//
//  IDYUploadManager.h
//  DYZB
//
//  Created by qiyun on 16/9/5.
//  Copyright © 2016年 mydouyu. All rights reserved.
//  example:http://baobab.wdjcdn.com/1458625865688ONE.mp4
//          http://baobab.wdjcdn.com/1455968234865481297704.mp4

#import <Foundation/Foundation.h>

typedef void (^CompletionHandlerType) ();
typedef void (^UploadCompletionHanlder) (NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend );
typedef void (^DownloadCompletionHanlder) (NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend );
typedef void (^SessionRequestCompletionHanlder) (NSData *data, NSURLResponse *response, NSError *error);
typedef void (^DownloadFinishedHanlder) (NSURLSessionTask *task , NSURL *location);
typedef void (^SessionFaildHanlder) (NSError *error , NSURLSessionTask *task);

typedef NS_ENUM(NSInteger, IDYUploadSessionType) {
    
    IDYUploadSession_background = 0x01, //Background sessions are similar to default sessions, except that a separate process handles all data transfers. Background sessions have some additional limitations, described in Background Transfer Considerations.
    
    IDYUploadSession_default    = 0x02, //Default sessions behave similarly to other Foundation methods for downloading URLs. They use a persistent disk-based cache and store credentials in the user’s keychain.
   
    IDYUploadSession_ephemeral  = 0x03  //Ephemeral sessions do not store any data to disk; all caches, credential stores, and so on are kept in RAM and tied to the session. Thus, when your app invalidates the session, they are purged automatically.

};


typedef NS_ENUM(NSInteger, IDYSessionCachePolicy) {
    
    IDYSessionRequestCachePolicy_protocol = 0,
    IDYSessionRequestCachePolicy_localCacheData = 1,
    IDYSessionRequestCachePolicy_localAdnRemoteCacheData = 4,
    IDYSessionRequestCachePolicy_dataElseLoad = 2,
    IDYSessionRequestCachePolicy_elseLoad = 3,
    IDYSessionRequestCachePolicy_revalidatingCacheData = 5
};


/*
 The session must provide a delegate for event delivery. (For uploads and downloads, the delegates behave the same as for in-process transfers.)
 Only HTTP and HTTPS protocols are supported (no custom protocols).
 Redirects are always followed.
 Only upload tasks from a file are supported (uploading from data objects or a stream will fail after the program exits).
 If the background transfer is initiated while the app is in the background, the configuration object’s discretionary property is treated as being true.
 */
@interface IDYSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>


+ (id)shareInstanceManagerWithSessionType:(IDYUploadSessionType)type;

- (id)initWithSessionType:(IDYUploadSessionType)type;

/**!
 *  The NSURLSession API provides a wide range of configuration options:
 *
 *  Private storage support for caches, cookies, credentials, and protocols in a way that is specific to a single session
 *  Authentication, tied to a specific request (task) or group of requests (session)
 *  File uploads and downloads by URL, which encourages separation of the data (the file’s contents) from the metadata (the URL and settings)
 *  Configuration of the maximum number of connections per host
 *  Per-resource timeouts that are triggered if an entire resource cannot be downloaded in a certain amount of time
 *  Minimum and maximum TLS version support
 *  Custom proxy dictionaries
 *  Control over cookie policies
 *  Control over HTTP pipelining behavior
 */
@property NSURLSession *backgroundSession;
@property NSURLSession *defaultSession;
@property NSURLSession *ephemeralSession;

@property IDYSessionCachePolicy   cachePolicy;
@property NSTimeInterval  timeoutInterval;

@property (nonatomic, copy) DownloadFinishedHanlder downloadFinished;
@property (nonatomic, copy) SessionFaildHanlder errorSession;
@property (nonatomic, copy) NSData  *resumeData;

#if TARGET_OS_IPHONE
@property NSMutableDictionary *completionHandlerDictionary;
#endif

- (void) addCompletionHandler: (CompletionHandlerType) handler forSession: (NSString *)identifier;
- (void) callCompletionHandlerForSession: (NSString *)identifier;

- (void)resumePause;
- (void)resumeStart;



/**!
 * The calculation of the size of the file in a network download process, and the current size of the download file for comparison, get when the speed
 */
- (void)daskDownloadOfSpeed:(void (^) (NSString *spped))speedDescription;



/**!
 *  Uploading Body Content Using a File
 *
 *  Your app can provide the request body content for an HTTP POST request in three ways: as an NSData object, as a file, or as a stream. In general, your app should:
 *
 *  To upload body content from a file, your app calls either the uploadTaskWithRequest:fromFile: or uploadTaskWithRequest:fromFile:completionHandler: method to create an upload task, and provides a file URL from which the task reads the body content.
 *
 *  The session object computes the Content-Length header based on the size of the data object. If your app does not provide a value for the Content-Type header, the session also provides one.
 *
 *  Your app can provide any additional header information that the server might require as part of the URL request object.
 *
 */
- (void)uploadManagerWithIdentifier:(NSString *)identifier fromFile:(NSString *)filePath requestUrl:(NSURL *)url completionHanlder:(UploadCompletionHanlder)complete;



/**!
 *  Downloading Files
 *
 *  Before this method returns, it must either open the file for reading or move it to a permanent location. When this method returns, the temporary file is deleted if it still exists at its original location.
 *
 *  If you schedule the download in a background session, the download continues when your app is not running. If you schedule the download in a standard or ephemeral session, the download must begin anew when your app is relaunched.
 *
 *  During the transfer from the server, if the user tells your app to pause the download, your app can cancel the task by calling the cancelByProducingResumeData: method. Later, your app can pass the returned resume data to either the downloadTaskWithResumeData: or downloadTaskWithResumeData:completionHandler: method to create a new download task that continues the download.
 *
 */
- (void)downloadManagerWithRequestUrl:(NSURL *)url storeFilePath:(NSString *)path completionHanlder:(DownloadCompletionHanlder)complete;
- (void)downloadManagerWithRequestUrl:(NSURL *)url storeFileName:(NSString *)fileName completionHanlder:(DownloadCompletionHanlder)complete;

/**!
 *  free delegate
 */
- (void)defaultManagerWithRequestUrl:(NSURL *)url completionHanlder:(SessionRequestCompletionHanlder)complete;

@end
