
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"

@protocol FrameDownloadDelegate <NSObject>
@optional
-(void)getSelectedFramePath:(NSString *)imagePath;
@end

@interface FrameCollectionVC : UICollectionViewController
@property (nonatomic, weak) id<FrameDownloadDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *frameCollectionView;
@property int orientationFlag;
@property (readwrite) BOOL isPortrait;

@end
