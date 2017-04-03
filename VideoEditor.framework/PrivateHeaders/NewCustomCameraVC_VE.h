
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FX_VE.h"
#import "GlobalData_VE.h"

@interface NewCustomCameraVC : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIView *flashView;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureStillImageOutput  *stillImageOutput;
    AVCaptureVideoDataOutput   *videoDataOutput;
    dispatch_queue_t           videoDataOutputQueue;
    CGFloat effectiveScale;

     AVCaptureSession *session;
    
    IBOutlet UIView *previewView;
    IBOutlet UIImageView *imgPreivew;
    BOOL isUsingFrontFacingCamera;
    
    UIImagePickerController *imagePicker;
}
@property (weak, nonatomic) IBOutlet UIButton *btnFlipCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIButton *btnGallery;

@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
- (IBAction)btnFlashClicked:(id)sender;
- (IBAction)btnTakePicClickedNew:(id)sender;

@property (nonatomic,retain) NSString *strDescription;
- (IBAction)btnCameraClicked:(id)sender;

-(IBAction)closeClicked:(id)sender;
- (IBAction)btnPhotoLibClicked:(id)sender;

@end
