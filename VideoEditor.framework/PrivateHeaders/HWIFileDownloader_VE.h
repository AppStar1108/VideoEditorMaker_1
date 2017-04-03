
#import <Foundation/Foundation.h>
#import "HWIFileDownloadDelegate_VE.h"
#import "HWIBackgroundSessionCompletionHandlerBlock_VE.h"
#import "HWIFileDownloadProgress_VE.h"
/**
 HWIFileDownloaderPauseResumeDataBlock is a block optionally called after cancelling a download.
 */
typedef void (^HWIFileDownloaderPauseResumeDataBlock)(NSData * _Nullable aResumeData);


/**
 HWIFileDownloader coordinates download activities.
 */
@interface HWIFileDownloader : NSObject


#pragma mark - Initialization


/**
 Secondary initializer.
 @param aDelegate Delegate for salient download events.
 @return HWIFileDownloader.
 */
- (nullable instancetype)initWithDelegate:(nonnull NSObject<HWIFileDownloadDelegate>*)aDelegate;

/**
 Designated initializer.
 @param aDelegate Delegate for salient download events.
 @param aMaxConcurrentFileDownloadsCount Maximum number of concurrent downloads. Default: no limit.
 @return HWIFileDownloader.
 */
- (nullable HWIFileDownloader*)initWithDelegate:(nonnull NSObject<HWIFileDownloadDelegate>*)aDelegate maxConcurrentDownloads:(NSInteger)aMaxConcurrentFileDownloadsCount;
- (nullable HWIFileDownloader*)init __attribute__((unavailable("use initWithDelegate:maxConcurrentDownloads: or initWithDelegate:")));
+ (nullable HWIFileDownloader*)new __attribute__((unavailable("use initWithDelegate:maxConcurrentDownloads: or initWithDelegate:")));


/**
 Set up file downloader.
 @param aSetupCompletionBlock Completion block to be called asynchronously after setup is finished.
 */
- (void)setupWithCompletion:(nullable void (^)(void))aSetupCompletionBlock;


#pragma mark - Download


/**
 Starts a download.
 @param aDownloadIdentifier Download identifier of a download item.
 @param aRemoteURL Remote URL from where data should be downloaded.
 */
- (void)startDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                              fromRemoteURL:(nonnull NSURL *)aRemoteURL;

/**
 Starts a download.
 @param aDownloadIdentifier Download identifier of a download item.
 @param aResumeData Incomplete data from previous download with implicit remote source information.
 */
- (void)startDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                            usingResumeData:(nonnull NSData *)aResumeData;


/**
 Answers the question whether a download is currently running for a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @return YES if a download is currently running for the download item, NO otherwise.
 @discussion Waiting downloads are included.
 */
- (BOOL)isDownloadingIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Answers the question whether a download is currently waiting for start.
 @param aDownloadIdentifier Download identifier of the download item.
 @return YES if a download is currently waiting for start, NO otherwise.
 @discussion Downloads might be queued and waiting for download. When a download is waiting, download of data from a remote host did not start yet.
 */
- (BOOL)isWaitingForDownloadOfIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Answers the question whether any download is currently running.
 @return YES if any download is currently running, NO otherwise.
 */
- (BOOL)hasActiveDownloads;


/**
 Cancels the download of a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 */
- (void)cancelDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Pauses the download of a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @remarks Convenience method, calls pauseDownloadWithIdentifier:resumeDataBlock: with nil as resumeDataBlock.
 */
- (void)pauseDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Pauses the download of a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @param aResumeDataBlock Asynchronously called block with resume data parameter.
 */
- (void)pauseDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier resumeDataBlock:(nullable HWIFileDownloaderPauseResumeDataBlock)aResumeDataBlock;


#pragma mark - BackgroundSessionCompletionHandler


/**
 Sets the completion handler for background session.
 @param aBackgroundSessionCompletionHandlerBlock Completion handler block.
 */
- (void)setBackgroundSessionCompletionHandlerBlock:(nullable HWIBackgroundSessionCompletionHandlerBlock)aBackgroundSessionCompletionHandlerBlock;


#pragma mark - Progress


/**
 Returns download progress information for a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @return Download progress information.
 */
- (nullable HWIFileDownloadProgress *)downloadProgressForIdentifier:(nonnull NSString *)aDownloadIdentifier;


#pragma mark - Download Directory

/**
 Returns the default download directory.
 @return The default download directory.
 */
+ (nullable NSURL *)fileDownloadDirectoryURL;


@end
