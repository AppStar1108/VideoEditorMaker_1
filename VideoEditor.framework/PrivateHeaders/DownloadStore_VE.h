
#import <Foundation/Foundation.h>
#import "HWIFileDownloadDelegate_VE.h"

@class DownloadItem_VE;

@interface DownloadStore_VE : NSObject<HWIFileDownloadDelegate>

@property (nonatomic, strong, readonly, nonnull) NSMutableArray<DownloadItem_VE *> *downloadItemsArray;

- (void)cancelDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier;
- (void)startDownloadWithDownloadItem:(nonnull DownloadItem_VE *)aDemoDownloadItem;
- (void)restartDownload;
- (void)restartDownloadWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier;

@end
