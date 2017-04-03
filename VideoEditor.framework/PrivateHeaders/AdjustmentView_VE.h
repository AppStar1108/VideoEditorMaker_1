
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"
typedef void(^AdjustmentHandler)(UIView *AdjustmentView, NSInteger buttonIndex);

@protocol AdjustmentViewDelegate <NSObject>
@required
@optional
-(void)AdjustmentDidSelectFilterAtIndex:(int)index;
@end

@interface AdjustmentView : UIView
{
    IBOutlet UILabel *lblMid;
    CIContext *myContext;;
}
- (void)showInView:(UIView *)view withFilters:(NSArray*)arrFilters handler:(AdjustmentHandler)handler;

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;
@property (strong, nonatomic) id <AdjustmentViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnBrightness;
@property (weak, nonatomic) IBOutlet UIButton *btnShadow;
@property (weak, nonatomic) IBOutlet UIButton *btnContrast;
@property (weak, nonatomic) IBOutlet UIButton *btnHighlight;
@property (weak, nonatomic) IBOutlet UIButton *btnBlur;

@property (readwrite) float defaultBrightnessValue;
@property (readwrite) float defaultContrastValue;
@property (readwrite) float defaultHighlightValue;
@property (readwrite) float defaultShadowValue;
@property (readwrite) float defaultBlurValue;

//Sliders

@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *contrastSlider;
@property (weak, nonatomic) IBOutlet UISlider *highlightSlider;
@property (weak, nonatomic) IBOutlet UISlider *shadowSlider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brightnessBottomValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contrastBottomValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highlightBottomValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowBottomValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blurBottomValue;
@property (weak, nonatomic) IBOutlet UISlider *blurSlider;

@property (nonatomic,strong) UIImage *filterImage;

@end
