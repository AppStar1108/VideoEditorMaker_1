
#import <Foundation/Foundation.h>

/**
 HWIFileDownloadDelegate is a protocol for handling salient download events.
 */
@protocol HWIFileDownloadDelegate

/**
 Called on successful download of a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @param aLocalFileURL Local file URL of the downloaded item.
 */
- (void)downloadDidCompleteWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                             localFileURL:(nonnull NSURL *)aLocalFileURL;

/**
 Called on a failed download.
 @param aDownloadIdentifier Download identifier of the download item.
 @param anError Download error.
 @param aResumeData Incompletely downloaded data that can be reused later if the download is started again.
 */
- (void)downloadFailedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                               error:(nonnull NSError *)anError
                          resumeData:(nullable NSData *)aResumeData;

/**
 Called when the network activity indicator should be displayed because a download started.
 @discussion Use UIApplication's setNetworkActivityIndicatorVisible: to actually set the visibility of the network activity indicator.
 */
- (void)incrementNetworkActivityIndicatorActivityCount;

/**
 Called when the display of the network activity indicator might end (if the last running network activity stopped with this call).
 @discussion Use UIApplication's setNetworkActivityIndicatorVisible: to actually set the visibility of the network activity indicator.
 */
- (void)decrementNetworkActivityIndicatorActivityCount;


@optional


/**
 Optionally called when the progress changed for a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @discussion Use HWIFileDownloader's downloadProgressForIdentifier: to access the current download progress of a download item at any time.
 */
- (void)downloadProgressChangedForIdentifier:(nonnull NSString *)aDownloadIdentifier;


/**
 Optionally called on a paused download.
 @param aDownloadIdentifier Download identifier of the download item.
 @param aResumeData Incompletely downloaded data that can be reused later if the download is started again.
 */
- (void)downloadPausedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                          resumeData:(nullable NSData *)aResumeData;


/**
 Optionally called when the HWIFileDownloader needs to store the downloaded data for a download item.
 @param aDownloadIdentifier Download identifier of the download item.
 @param aRemoteURL Remote URL from where the data has been downloaded.
 @return The local file URL where the downloaded data should be persistently stored in the file system.
 @discussion Although the download identifier is enough to identify a singular download item, the remote URL is passed here too for convenience as it might convey useful information for determining a local file URL.
 */
- (nullable NSURL *)localFileURLForIdentifier:(nonnull NSString *)aDownloadIdentifier
                                    remoteURL:(nonnull NSURL *)aRemoteURL;


/**
 Optionally called to validate downloaded data.
 @param aDownloadIdentifier Download identifier of the download item.
 @param aLocalFileURL Local file URL of the downloaded item.
 @return True if downloaded data in local file passed validation test.
 @discussion The download might finish successfully with an error string as downloaded data. This method can be used to check whether the downloaded data is the expected content and data type.
 */
- (BOOL)downloadIsValidForDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                              atLocalFileURL:(nonnull NSURL *)aLocalFileURL;


/**
 Optionally set timeout interval for a request with this return value.
 @return The timeout to use for the a request.
 @discussion The timeout fires if no data is transmitted for the given timeout value.
 */
- (NSTimeInterval)requestTimeoutInterval;


/**
 Optionally set timeout interval for downloading an individual item with this return value.
 @return The timeout to use for a download item.
 @discussion The timeout fires if a download item does not complete download during the time interval (only applies to NSURLSession).
 */
- (NSTimeInterval)resourceTimeoutInterval;


/**
 Optionally provide a progress object for tracking progress across individual downloads.
 @return Root progress object.
 @discussion NSProgress is set up in a hierarchy. Download progress of HWIFileDownloader items can be tracked individually and in total.
 */
- (nullable NSProgress *)rootProgress;


@end
