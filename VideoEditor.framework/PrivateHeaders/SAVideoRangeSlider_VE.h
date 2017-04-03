
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "SASliderLeft_VE.h"
#import "SASliderRight_VE.h"
#import "SAResizibleBubble_VE.h"

@protocol SAVideoRangeSliderDelegate;

@interface SAVideoRangeSlider : UIView

@property (nonatomic, weak) id <SAVideoRangeSliderDelegate> delegate;
@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UILabel *bubleText;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, assign) NSInteger maxGap;
@property (nonatomic, assign) NSInteger minGap;


- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;
- (void)setPopoverBubbleSize: (CGFloat) width height:(CGFloat)height;
-(void)moveslider :(CGFloat)leftPos rightPos:(CGFloat)rightPos;


@end


@protocol SAVideoRangeSliderDelegate <NSObject>

@optional

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)videoRange:(SAVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;


@end




