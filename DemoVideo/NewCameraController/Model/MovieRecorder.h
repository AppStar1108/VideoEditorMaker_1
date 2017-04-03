

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class MovieRecorder;


@protocol MovieRecorderDelegate <NSObject>
@required
- (void)movieRecorderDidFinishPreparing:(MovieRecorder *)recorder;
- (void)movieRecorder:(MovieRecorder *)recorder didFailWithError:(NSError *)error;
- (void)movieRecorderDidFinishRecording:(MovieRecorder *)recorder;
@end


@interface MovieRecorder : NSObject
{
  __weak id <MovieRecorderDelegate> delegate;
  dispatch_queue_t delegateCallbackQueue;
  
  dispatch_queue_t    writingQueue;
  
  NSURL               *URL;
  
  AVAssetWriter       *assetWriter;
  BOOL                haveStartedSession;
  
  NSDictionary        *audioTrackSettings;
  AVAssetWriterInput  *audioInput;
  
  CMVideoDimensions   videoDimensions;
  CGAffineTransform   videoTrackTransform;
  NSDictionary        *videoTrackSettings;
  AVAssetWriterInput  *videoInput;
  
  CMTime startTime;
}
@property(nonatomic, readonly) CMTime duration;

- (instancetype)initWithURL:(NSURL *)url;

- (void)setDelegate:(id<MovieRecorderDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;

// Only one audio and video track each are allowed.
- (void)addVideoTrackWithDimensions:(CMVideoDimensions)dimensions transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings;
- (void)addAudioTrackWithSettings:(NSDictionary *)audioSettings;

- (void)prepareToRecord; // When finished the delegate's recorderDidFinishPreparing: or recorder:didFailWithError: method will be called.

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime;
- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)pauseRecording;
- (void)resumeRecording;
- (void)finishRecording; // When finished the delegate's recorderDidFinishRecording: or recorder:didFailWithError: method will be called.

@end
