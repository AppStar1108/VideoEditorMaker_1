
#ifndef DownloadItemStatus_VE_h
#define DownloadItemStatus_VE_h


#endif /* DownloadItemStatus_VE_h */


typedef NS_ENUM(NSUInteger, DownloadItemStatus) {
    DownloadItemStatusNotStarted = 0,
    DownloadItemStatusStarted,
    DownloadItemStatusCompleted,
    DownloadItemStatusPaused,
    DownloadItemStatusCancelled,
    DownloadItemStatusError
};
