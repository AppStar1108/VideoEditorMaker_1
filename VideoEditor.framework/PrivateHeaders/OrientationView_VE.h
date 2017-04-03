
#import <UIKit/UIKit.h>

@protocol OrientationViewDelegate <NSObject>
@required
@optional
-(void)OrientationViewDidChangeOrientation:(int)index;
@end

@interface OrientationView : UIView{
    }

@property (strong, nonatomic) id <OrientationViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *btnHorizontal;
@property (weak, nonatomic) IBOutlet UIButton *btnVertical;
- (void)showInView:(UIView *)view;
@end
