
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "SimpleEditor_VE.h"
#import "SSMovieMaker_VE.h"
#import "FrameCollectionVC_VE.h"
#import <QuartzCore/QuartzCore.h>
#import "CCColorCube_VE.h"
#import "BrutalUIImageView_VE.h"
#import "GlobalData_VE.h"

@protocol FrameViewDelegate <NSObject>
@required
@optional
-(void)frameDoneClicked;
@end

@interface FrameVC : UIViewController
{
    IBOutlet UIImageView *imgView;
    int index;
    AVURLAsset *audioAsset;
    NSTimeInterval videoLength;
    int selectedIndex;
    CGFloat exportProgress;
}
@property(nonatomic,strong)SimpleEditor *objSimple;
@property (nonatomic,strong) SSMovieMaker_VE *movieMaker;
@property (strong, nonatomic) id <FrameViewDelegate> delegate;
@property(nonatomic, strong) AVAsset *videoAsset;
@property(nonatomic,strong)UIImage *imgVideo;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UIView *frameCollectionView;
@end
