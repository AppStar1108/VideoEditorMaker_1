
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

enum SSCameraInputManagerErrorCode {
  ErrorVideoInputCode = 101,
  ErrorAudioInputCode = 102,
  ErrorImageInputCode = 103,
  ErrorOutputFileCode = 104,
  ErrorAlredySetup = 105,
  };

typedef void (^ErrorHandlingBlock)(NSError *error);

@interface SSCameraInputManager : NSObject <AVCaptureFileOutputRecordingDelegate>

@property (strong, readonly) AVCaptureSession *captureSession;
@property (assign, readonly) bool isPaused;
@property (assign, readwrite) float maxDuration;
@property (copy, readwrite) ErrorHandlingBlock asyncErrorHandler;

- (void)setupCaptureDeviceWithPosition:(AVCaptureDevicePosition)captureDevicePosition
                     error:(NSError **)error;
- (void)setupSessionWithPreset:(NSString *)preset
             captureDevice:(AVCaptureDevicePosition)cdp
                 torchMode:(AVCaptureTorchMode)tm
                     error:(NSError **)error;
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;

- (void)startRecording;

- (void)stopRecording;

- (void)audioSetupWithCompletion:(void (^)(BOOL granted))completion;

- (void)reset;

- (void)finalizeRecordingToFile:(NSURL *)finalVideoLocationURL
          withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (CMTime)totalRecordingDuration;

- (void)capturePhotoWithCompletionHandler:(void (^)(NSError *error, UIImage *image))completionHandler;

@end
