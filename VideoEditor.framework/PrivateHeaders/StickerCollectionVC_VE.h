
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"

@protocol StickerDownloadDelegate <NSObject>
@optional
-(void)getSelectedStickerPath:(NSString *)imagePath;
@end

@interface StickerCollectionVC : UICollectionViewController
@property (nonatomic, weak) id<StickerDownloadDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *stickerCollectionView;

@end
