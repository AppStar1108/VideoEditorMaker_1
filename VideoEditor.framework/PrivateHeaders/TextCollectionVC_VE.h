
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"

@protocol TextDownloadDelegate <NSObject>
@optional
-(void)getSelectedTextPath:(NSString *)textPath;
@end

@interface TextCollectionVC : UICollectionViewController
@property (nonatomic, weak) id<TextDownloadDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *textCollectionView;

@end
