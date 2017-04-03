

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CaptureManager.h"
#import "CapturePreviewView.h"
#import "CaptureModeSwitch.h"
#import <AVFoundation/AVFoundation.h>

@class ViewController;

typedef NS_ENUM(NSInteger, CaptureMode) {
  CaptureModePhoto = 0,
  CaptureModeVideo = 1,
};


static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

#define   IsIPad          isIPad()
#define   IsIPhone        !isIPad()

#define isPad                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define SCREENSIZE [[UIScreen mainScreen] bounds].size.height


@interface CameraVC : UIViewController
<CaptureManagerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>
{
  IBOutlet CapturePreviewView *previewView;
  IBOutlet CaptureModeSwitch  *captureModeSwitch;
  IBOutlet UIView     *topCurtainView, *bottomCurtainView;
  IBOutlet UIView     *contentView, *headerView, *toolbarView;
  IBOutlet UILabel    *recordingTimeLabel;
  IBOutlet UIButton   *flashButton, *flipButton;
  IBOutlet UIButton   *closeButton, *captureButton, *cropButton;
  
  NSString            *recordingPath;
  CGSize              videoResolution;
  NSTimeInterval      videoDurationInSeconds;
  
  CaptureManager      *captureManager;
  CaptureMode         captureMode;
  BOOL                photoCropEnabled;
  BOOL                isRecording;
  
  CGFloat                 currentOrientationAngle;
  UIInterfaceOrientation  currentOrientation;
    NSTimer *timer;
    CGFloat myCounter;
    
    NSString *saveFileName;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@end


