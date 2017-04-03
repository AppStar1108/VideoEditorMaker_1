
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"
@protocol FilterDownloadDelegate <NSObject>
@optional
-(void)getSelectedFilterPath:(NSString *)imagePath;
-(void)filterDownloadEventCalled;
@end

@interface FilterCollectionVC : UICollectionViewController
@property (nonatomic, weak) id<FilterDownloadDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *filterCollectionView;

@end
