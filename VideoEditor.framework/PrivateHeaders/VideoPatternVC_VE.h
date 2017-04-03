
#import <UIKit/UIKit.h>
#import "SSMovieMaker_VE.h"
#import "GlobalData_VE.h"

@protocol PatternCompletedDelegate <NSObject>
@optional
-(void)patternCompletedAction;
@end
@interface VideoPatternVC : UIViewController
{
    IBOutlet UIImageView *imgView;
    IBOutlet UIScrollView *scView;
    SSMovieMaker_VE *movieMaker;
    UIColor *lastColor;
    BOOL isColor;
    UIImage *patternImage;
    int selectedIndex;
    AVCaptureVideoOrientation orientation;
    AVAssetExportSession *export;
    float prevProgress;
}
@property(nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, weak) id<PatternCompletedDelegate> delegate;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *btnLine;
@property (weak, nonatomic) IBOutlet UIButton *btnPatterns;
@property (weak, nonatomic) IBOutlet UIButton *btnCustom;
@property (weak, nonatomic) IBOutlet UIButton *btnColors;
@end
