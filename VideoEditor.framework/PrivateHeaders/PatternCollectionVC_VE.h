
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"

@protocol PatternDownloadDelegate <NSObject>
@optional
-(void)getSelectedPatternPath:(NSString *)imagePath;
@end

@interface PatternCollectionVC : UICollectionViewController
@property (nonatomic, weak) id<PatternDownloadDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *PatternCollectionView;

@end
