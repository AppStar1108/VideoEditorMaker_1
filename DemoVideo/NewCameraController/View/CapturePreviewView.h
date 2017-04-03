

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface CapturePreviewView : UIView

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) NSString *videoGravity;

- (CGPoint)pointOfInterestForPoint:(CGPoint)point;

@end
