
#import <UIKit/UIKit.h>
#import "CLToolbarMenuItem_VE.h"
#import "UIImage+Utility_VE.h"
#import "UIView+Frame_VE.h"
#import "UIImage+FX_VE.h"

static const CGFloat kCLImageToolAnimationDuration = 0.3;
static const CGFloat kCLImageToolFadeoutDuration   = 0.2;

@protocol ClippingDelegate <NSObject>
@required
@optional
-(void)clipDoneClicked;
@end

@interface ClippingVC : UIViewController{
    BOOL isMargin;
    NSTimer *cropTimer;
    int isChangeCrop;
    int selectedVideo;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnRotate;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)btnDoneClicked:(id)sender;
@property (strong, nonatomic) id <ClippingDelegate> delegate;
- (IBAction)btnBackClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackMain;
@property (weak, nonatomic) IBOutlet UIScrollView *menuScroll;
- (IBAction)btnRotateClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
