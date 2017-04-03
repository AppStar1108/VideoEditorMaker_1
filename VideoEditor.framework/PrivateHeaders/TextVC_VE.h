
#import <UIKit/UIKit.h>
#import "SAVideoRangeSlider_VE.h"
#import "TLTiltSlider_VE.h"
#import "TextVC_VE.h"
#import "UIImage+FX_VE.h"
#import "UIImage+Utils_VE.h"
#import "PopoverView_VE.h"
#import "MessageComposerView_VE.h"
#import "ShapesButton_VE.h"
#import "GlobalData_VE.h"
#import "TextCollectionVC_VE.h"

@protocol TextDelegate <NSObject>
@required
@optional
-(void)textDoneClicked;
-(void)textCancelClicked;

@end

@interface TextVC : UIViewController<SAVideoRangeSliderDelegate,ZDStickerViewDelegate,MessageComposerViewDelegate,UIImagePickerControllerDelegate,TextDownloadDelegate,UINavigationBarDelegate>
{
    BOOL isFromLabel;
    int mainLabelTag,gloabalSelectedTag;
    IBOutlet UIImageView *imgView;
    UITapGestureRecognizer *gestureSingleTap,*gestureDoubleTap;
    IBOutlet UINavigationBar *navBar;
    PopoverView *cameraPopup;
    IBOutlet UIButton *TextButton;
    
    UITextView *textView;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageViewH1;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewH2;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewV1;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView3D;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCurve;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSpaceHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTextSpace;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLeftAlign;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCenterAlign;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRightAlign;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOpacity;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFontSize;

@property(strong, nonatomic) NSMutableArray *arrTexts;
@property (strong, nonatomic) UIImage *imgVideo;
@property(strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (strong, nonatomic) id <TextDelegate> delegate;
@property(strong, nonatomic) IBOutlet UICollectionView *colView;
@property (weak, nonatomic) IBOutlet UIView *bottomView,*textEditorView;
@property (readwrite) CGFloat startTime;
@property (readwrite) CGFloat stopTime;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlTextColors;
@property (weak, nonatomic) IBOutlet TLTiltSlider *sliderTextAlpha,*sliderZoom,*sliderCharSpace,*sliderParSpace,*slider3d,*sliderFisheye;
@property (nonatomic, strong) MessageComposerView *messageComposerView;
@property (weak, nonatomic) IBOutlet UIView *textCollectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

//Color Button Array
@property (nonatomic, strong) NSArray *colorCollection;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;


@end
