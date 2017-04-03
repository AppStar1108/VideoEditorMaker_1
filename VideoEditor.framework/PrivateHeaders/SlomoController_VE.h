
#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"
#import "AssetVideo.h"

@protocol SlomoCompletedDelegate <NSObject>
@optional
-(void)slomoCompletedAction;
@end

@interface SlomoController : UIViewController{
    NSString *strDevicename;
}

@property (strong, nonatomic) AssetVideo *assetVideo;
@property (weak, nonatomic) IBOutlet UIImageView *slowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fastImageView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic,strong) NSMutableArray *arrTimes;
@property (weak, nonatomic) IBOutlet UISlider *tempSlider;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, weak) id<SlomoCompletedDelegate> delegate;
@end
