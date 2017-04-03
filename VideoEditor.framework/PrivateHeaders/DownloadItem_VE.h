#import <Foundation/Foundation.h>
#import "DownloadItemStatus_VE.h"

@class HWIFileDownloadProgress;

@interface DownloadItem_VE : NSObject

- (nullable instancetype)initWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                                          remoteURL:(nonnull NSURL *)aRemoteURL;

@property (nonatomic, strong, readonly, nonnull) NSString *downloadIdentifier;
@property (nonatomic, strong, readonly, nonnull) NSURL *remoteURL;

@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, assign) DownloadItemStatus status;

@property (nonatomic, strong, nullable) HWIFileDownloadProgress *progress;
@property (nonatomic, strong, nullable) NSError *downloadError;

- (nullable DownloadItem_VE *)init __attribute__((unavailable("use initWithDownloadIdentifier:remoteURL:")));
+ (nullable DownloadItem_VE *)new __attribute__((unavailable("use initWithDownloadIdentifier:remoteURL:")));

@end
