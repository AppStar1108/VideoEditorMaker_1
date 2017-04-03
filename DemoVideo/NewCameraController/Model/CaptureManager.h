

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>
#import <CoreMedia/CMAudioClock.h>
#import <ImageIO/CGImageProperties.h>
#import "MovieRecorder.h"


typedef NS_ENUM(NSInteger, RecordingStatus) {
  RecordingStatusIdle = 0,
  RecordingStatusStartingRecording,
  RecordingStatusRecording,
  RecordingStatusPaused,
  RecordingStatusStoppingRecording,
};


#define RECORD_AUDIO 1


@protocol CaptureManagerDelegate <NSObject>
@required
- (void)captureManagerDidFailWithError:(NSError *)error;
// Preview
- (void)captureManagerPreviewPixelBufferReadyForDisplay:(CVPixelBufferRef)previewPixelBuffer;
@optional
// Recording
- (CVPixelBufferRef)captureManagerPixelBufferReadyForRecord:(CVPixelBufferRef)pixelBuffer;
- (void)captureManagerRecordingDidStart;
- (void)captureManagerRecordingDidStop;
@end


@interface CaptureManager : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, MovieRecorderDelegate>
{
  AVCaptureSession      *captureSession;
  AVCaptureDevice       *videoDevice;
  AVCaptureDeviceInput  *videoDeviceInput;
  AVCaptureConnection   *videoConnection, *audioConnection;
  
  AVCaptureStillImageOutput *stillImageOutput;
  
  BOOL              running;
  BOOL              startCaptureSessionOnEnteringForeground;
  id                applicationDidEnterBackgroundNotificationObserver;
  id                applicationWillEnterForegroundNotificationObserver;
  
  dispatch_queue_t  sessionQueue;
  dispatch_queue_t  videoDataOutputQueue;
  
  NSMutableArray    *previousSecondTimestamps;
  
  NSURL             *recordingURL;
  RecordingStatus   recordingStatus;
  
  UIBackgroundTaskIdentifier pipelineRunningTask;
  
  MovieRecorder           *recorder;
  CVPixelBufferRef        currentPreviewPixelBuffer;
  CMFormatDescriptionRef  outputVideoFormatDescription;
  CMFormatDescriptionRef  outputAudioFormatDescription;
}
@property(nonatomic, weak)     id<CaptureManagerDelegate> delegate;
@property(nonatomic, readonly) AVCaptureSession *captureSession;
@property(nonatomic, readonly) float videoFrameRate;
@property(nonatomic, readonly) CMVideoDimensions videoDimensions;
@property(nonatomic, readonly) NSTimeInterval videoDuration;
@property(nonatomic, readonly) AVCaptureVideoOrientation videoOrientation;
@property(nonatomic, assign)   AVCaptureVideoOrientation recordingOrientation; // client can set the orientation for the recorded movie

- (void)setupCaptureSessionWithPreset:(NSString *)captureSessionPreset completion:(void (^)(void))completion;
- (void)pauseCaptureSession;
- (void)resumeCaptureSession;
- (void)cleanupCaptureSession;

- (void)captureStillImageWithCompletion:(void (^)(UIImage *image, NSError *error))completion;

- (void)startRecordingToPath:(NSString *)path;
- (void)stopRecording;
- (void)pauseRecording;
- (void)resumeRecording;

- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(UIInterfaceOrientation)orientation
                                                    withAutoMirroring:(BOOL)mirroring;  // only valid after startRunning has been called

- (void)focusAtPoint:(CGPoint)point;

- (BOOL)hasFlash;
- (BOOL)hasTorch;
- (AVCaptureFlashMode)flashMode;
- (AVCaptureTorchMode)torchMode;
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

- (BOOL)hasFrontFacingCamera;
- (BOOL)isFrontFacingCameraActive;
- (void)switchCameraWithCompletion:(void (^)(void))completion;

@end


