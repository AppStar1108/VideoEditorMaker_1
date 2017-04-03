
#import <UIKit/UIKit.h>
#import "SAVideoRangeSlider_VE.h"
#import "ZDStickerView_VE.h"
#import "MyNewImage_VE.h"
#import "UIImage+Utils_VE.h"
#import "GzColors_VE.h"
#import "ColorButton_VE.h"
#import "UIImage+Tint_VE.h"
#import "TLTiltSlider_VE.h"
#import "Sticker_VE.h"
#import "PopoverView_VE.h"
#import "IMSuggestionView.h"
#import "Masonry.h"
#import "IMHalfScreenView.h"

@protocol StickerViewDelegate <NSObject>
@required
@optional

-(void)StickerViewFinishAtPosition:(CGFloat)startTime endTime:(CGFloat)endtime;
-(void)StickerImage:(UIImage *)image;

@end

@interface StickerVC : UIViewController<SAVideoRangeSliderDelegate,ImageToolDelegate,IMCollectionViewDelegate,IMStickerSearchContainerViewDelegate>
{
    PopoverView *cameraPopup;
    int  globalSelectedTag;
    int  mainStickerTag ;
    UIColor *lastColor;
    IBOutlet UIImageView *imgView;
    BOOL isTrim;
    NSMutableArray *arrSticker;
    IBOutlet UIButton *StickerButton;       
    IBOutlet UIView *ViewForStickerBtn;
     BOOL isImojiCategory;
}
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIView *toolsView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) UIImage *imgVideo;
@property (strong, nonatomic) IBOutlet UICollectionView *colView;
@property (strong, nonatomic) id <StickerViewDelegate> delegate;
@property (strong, nonatomic)  SAVideoRangeSlider *mySAVideoRangeSlider;
@property (weak, nonatomic) IBOutlet UIButton *btnTrim;
@property (readwrite) CGFloat startTime;
@property (readwrite) CGFloat stopTime;
@property (strong, nonatomic)IBOutlet UIView *shapesPopUpView;
@property (nonatomic,strong) NSMutableArray *arrStickers;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollTextColors;
@property (weak, nonatomic) IBOutlet TLTiltSlider *sliderShapeAlpha;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewH1;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewH2;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewH3;

//Color Button Array
@property (nonatomic, strong) NSArray *colorCollection;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property(nonatomic, strong) IMImojiSession *session;
@property(nonatomic, strong) IMSuggestionView *imojiSuggestionView;
@property(nonatomic, strong) IMHalfScreenView *halfScreenView;
@property (weak, nonatomic) IBOutlet UIView *imojiView;

- (IBAction)btnCancelPressed:(id)sender;
- (IBAction)btnDonePressed:(id)sender;

-(IBAction)btnTrimFinished:(id)sender;
-(IBAction)sliderShapeAlphaChanged:(id)sender;

@end
