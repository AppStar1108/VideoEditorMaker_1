
#import <UIKit/UIKit.h>
#import "SAVideoRangeSlider_VE.h"
#import "GlobalData_VE.h"

@protocol TrimViewDelegate <NSObject>
@required
@optional
-(void)TrimViewFinishAtPosition:(CGFloat)startTime endTime:(CGFloat)endtime;
-(void)TrimDoneButtonPressed;
-(void)TrimCancelButtonPressed;
@end

@interface TrimView : UIView <SAVideoRangeSliderDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) id <TrimViewDelegate> delegate;
@property (strong, nonatomic)  SAVideoRangeSlider *mySAVideoRangeSlider;

- (void)showInView:(UIView *)view;
@property (weak, nonatomic) IBOutlet UIButton *btnTrim;
@property (readwrite) CGFloat startTime;
@property (readwrite) CGFloat stopTime;

- (IBAction)btnClickedAction:(id)sender;

@end
