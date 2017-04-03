
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"

@protocol LineDownloadDelegate <NSObject>
@optional
-(void)getSelectedLinePath:(NSString *)imagePath;
@end

@interface LinesCollectionVC : UICollectionViewController
@property (nonatomic, weak) id<LineDownloadDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *lineCollectionView;
@end
