

#import "CaptureManager.h"


@implementation CaptureManager
@synthesize captureSession, videoFrameRate, videoDimensions, videoDuration, videoOrientation, recordingOrientation;

- (instancetype)init {
  if (self = [super init])
  {
    previousSecondTimestamps = [[NSMutableArray alloc] init];
    recordingOrientation = [self avOrientationForDeviceOrientation:[[UIDevice currentDevice] orientation]];;
    
    sessionQueue = dispatch_queue_create("capturemanager.session", DISPATCH_QUEUE_SERIAL);
    
    // In a multi-threaded producer consumer system it's generally a good idea to make sure that producers do not get starved of CPU time by their consumers.
    // In this app we start with VideoDataOutput frames on a high priority queue, and downstream consumers use default priority queues.
    // Audio uses a default priority queue because we aren't monitoring it live and just want to get it into the movie.
    // AudioDataOutput can tolerate more latency than VideoDataOutput as its buffers aren't allocated out of a fixed size pool.
    videoDataOutputQueue = dispatch_queue_create("capturemanager.video", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(videoDataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    pipelineRunningTask = UIBackgroundTaskInvalid;
  }
  return self;
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        return  AVCaptureVideoOrientationLandscapeRight;
    
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        return AVCaptureVideoOrientationLandscapeLeft;
    
    return AVCaptureVideoOrientationPortrait;
}


- (void)dealloc
{
  _delegate = nil;
  
  [self teardownCaptureSession];
  
  outputVideoFormatDescription = NULL;
  outputAudioFormatDescription = NULL;
}


#pragma mark - Capture Session

- (void)setupCaptureSessionWithPreset:(NSString *)captureSessionPreset completion:(void (^)(void))completion
{
  dispatch_sync(sessionQueue, ^{
    
    if (captureSession != nil) {
      pauseOutputSampleBuffer = YES;
      outputVideoFormatDescription = nil;
      
      [captureSession beginConfiguration];
      [captureSession setSessionPreset:captureSessionPreset];
      [captureSession commitConfiguration];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        pauseOutputSampleBuffer = NO;
        if (completion)
          completion();
      });
      return;
    }
    
    captureSession = [[AVCaptureSession alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionNotification:) name:nil object:captureSession];
      
    applicationDidEnterBackgroundNotificationObserver = [[NSNotificationCenter defaultCenter]
                                                          addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:[UIApplication sharedApplication]
                                                          queue:nil
                                                          usingBlock:^(NSNotification *note) {
                                                            // Client must stop us running before we can be deallocated
                                                            [self applicationDidEnterBackground];
                                                          }];
    applicationWillEnterForegroundNotificationObserver = [[NSNotificationCenter defaultCenter]
                                                          addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:[UIApplication sharedApplication]
                                                          queue:nil
                                                          usingBlock:^(NSNotification *note) {
                                                            // Client must stop us running before we can be deallocated
                                                            [self applicationWillEnterForeground];
                                                          }];
    
#if RECORD_AUDIO
    // Audio
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    if ([captureSession canAddInput:audioIn]) {
      [captureSession addInput:audioIn];
    }
    
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    // Put audio on its own queue to ensure that our video processing doesn't cause us to drop audio
    dispatch_queue_t audioCaptureQueue = dispatch_queue_create("capturemanager.audio", DISPATCH_QUEUE_SERIAL);
    [audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
    
    if ([captureSession canAddOutput:audioOut]) {
      [captureSession addOutput:audioOut];
    }
    audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
      
#endif
    
    // Video input
    videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    if ([captureSession canAddInput:videoDeviceInput]) {
      [captureSession addInput:videoDeviceInput];
    }
    
    // Still image output
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    //[stillImageOutput setOutputSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
    if ([captureSession canAddOutput:stillImageOutput]) {
      [captureSession addOutput:stillImageOutput];
    }
    
    // Video output
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    videoOut.videoSettings = @{(__bridge id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [videoOut setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    // we prefer not to have any dropped frames in the video recording.
    // By setting alwaysDiscardsLateVideoFrames to NO we ensure that minor fluctuations in system load or in our processing time for a given frame won't cause framedrops.
    // We do however need to ensure that on average we can process frames in realtime.
    // If we were doing preview only we would probably want to set alwaysDiscardsLateVideoFrames to YES.
    videoOut.alwaysDiscardsLateVideoFrames = YES;
    
    if ([captureSession canAddOutput:videoOut]) {
      [captureSession addOutput:videoOut];
    }
    
    captureSession.sessionPreset = captureSessionPreset;
    [captureSession startRunning];
    
    videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo] ;
    videoOrientation = videoConnection.videoOrientation;
    running = YES;
           
      [self performInMainThread:^{
          if (completion)
              completion();
      }];
      
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//      if (completion)
//        completion();
//    });
    
  });
}

- (void)performInMainThread:(void (^)(void))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)pauseCaptureSession
{
  dispatch_sync(sessionQueue, ^{
    running = NO;
    [captureSession stopRunning];
  });
}

- (void)resumeCaptureSession
{
  dispatch_sync(sessionQueue, ^{
    running = YES;
    [captureSession startRunning];
  });
}

- (void)cleanupCaptureSession
{
    
    dispatch_async(sessionQueue, ^{
        running = NO;
        [self stopRecording];
        [captureSession stopRunning];
        [self captureSessionDidStopRunning];
        [self teardownCaptureSession];
    });
    
//  dispatch_sync(sessionQueue, ^{
//    running = NO;
//    [self stopRecording];
//    [captureSession stopRunning];
//    [self captureSessionDidStopRunning];
//    [self teardownCaptureSession];
//  });
}

- (void)teardownCaptureSession
{
  if (captureSession)
  {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:captureSession];
    
    [[NSNotificationCenter defaultCenter] removeObserver:applicationDidEnterBackgroundNotificationObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationWillEnterForegroundNotificationObserver];
    applicationDidEnterBackgroundNotificationObserver = nil;
    applicationWillEnterForegroundNotificationObserver = nil;
    
    captureSession = nil;
  }
}

static AVCaptureTorchMode lastTorchMode = AVCaptureTorchModeOff;
static AVCaptureFlashMode lastFlashMode = AVCaptureFlashModeOff;

- (void)captureSessionNotification:(NSNotification *)notification
{
  dispatch_async(sessionQueue, ^{
    
    if ([notification.name isEqualToString:AVCaptureSessionWasInterruptedNotification]) {
      NSLog(@"session interrupted");
      [self captureSessionDidStopRunning];
    }
    else if ([notification.name isEqualToString:AVCaptureSessionInterruptionEndedNotification]) {
      NSLog(@"session interruption ended");
    }
    else if ([notification.name isEqualToString:AVCaptureSessionRuntimeErrorNotification])
    {
      [self captureSessionDidStopRunning];
      
      NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
      if (error.code == AVErrorDeviceIsNotAvailableInBackground) {
        NSLog(@"device not available in background");
        if (running) {
          // Since we can't resume running while in the background we need to remember this for next time we come to the foreground
          startCaptureSessionOnEnteringForeground = YES;
        }
      }
      else if (error.code == AVErrorMediaServicesWereReset) {
        NSLog(@"media services were reset");
        [self handleRecoverableCaptureSessionRuntimeError:error];
      }
      else {
        [self handleNonRecoverableCaptureSessionRuntimeError:error];
      }
    }
    else if ([notification.name isEqualToString:AVCaptureSessionDidStartRunningNotification]) {
      [self setTorchMode:lastTorchMode];
      [self setFlashMode:lastFlashMode];
      NSLog(@"session started running");
    }
    else if ([notification.name isEqualToString:AVCaptureSessionDidStopRunningNotification]) {
      NSLog(@"session stopped running");
    }
  });
}

- (void)handleRecoverableCaptureSessionRuntimeError:(NSError *)error
{
  if (running) {
    [captureSession startRunning];
  }
}

- (void)handleNonRecoverableCaptureSessionRuntimeError:(NSError *)error
{
  NSLog(@"fatal runtime error %@, code %i", error, (int)error.code);
  
  running = NO;
  [self teardownCaptureSession];
  
  if (self.delegate) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate captureManagerDidFailWithError:error];
    });
  }
}

- (void)captureSessionDidStopRunning
{
  [self stopRecording]; // does nothing if we aren't currently recording
  [self teardownVideoPipeline];
}

- (void)applicationDidEnterBackground
{
  [self stopRecording];
}

- (void)applicationWillEnterForeground
{
  dispatch_sync(sessionQueue, ^{
    if (startCaptureSessionOnEnteringForeground) {
      NSLog(@"manually restarting session");
      startCaptureSessionOnEnteringForeground = NO;
      if (running) {
        [captureSession startRunning];
      }
    }
  });
}

#pragma mark Capture Pipeline

- (void)setupVideoPipelineWithInputFormatDescription:(CMFormatDescriptionRef)inputFormatDescription
{
  NSLog(@"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  
  [self videoPipelineWillStartRunning];
  
  videoDimensions = CMVideoFormatDescriptionGetDimensions(inputFormatDescription);
  
  outputVideoFormatDescription = inputFormatDescription;
}

// synchronous, blocks until the pipeline is drained, don't call from within the pipeline
- (void)teardownVideoPipeline
{
  // The session is stopped so we are guaranteed that no new buffers are coming through the video data output.
  // There may be inflight buffers on _videoDataOutputQueue however.
  // Synchronize with that queue to guarantee no more buffers are in flight.
  // Once the pipeline is drained we can tear it down safely.
  
  NSLog(@"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  
  dispatch_sync(videoDataOutputQueue, ^{
    if (!outputVideoFormatDescription) {
      return;
    }
    outputVideoFormatDescription = nil;
    
    if (currentPreviewPixelBuffer)
      CFRelease(currentPreviewPixelBuffer), currentPreviewPixelBuffer = NULL;
    
    NSLog(@"-[%@ %@] finished teardown", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self videoPipelineDidFinishRunning];
  });
}

- (void)videoPipelineWillStartRunning
{
  if (pipelineRunningTask == UIBackgroundTaskInvalid)
    return;
  
  NSLog(@"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  
  pipelineRunningTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    NSLog(@"video capture pipeline background task expired");
  }];
}

- (void)videoPipelineDidFinishRunning
{
  NSLog(@"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
  
  //NSAssert(pipelineRunningTask != UIBackgroundTaskInvalid, @"should have a background task active when the video pipeline finishes running");
  
  if (pipelineRunningTask != UIBackgroundTaskInvalid) {
    [[UIApplication sharedApplication] endBackgroundTask:pipelineRunningTask];
    pipelineRunningTask = UIBackgroundTaskInvalid;
  }
}

static BOOL pauseOutputSampleBuffer = NO;

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
  if (pauseOutputSampleBuffer)
    return;
  
  CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
  
  if (outputVideoFormatDescription == nil) {
    if (connection == videoConnection)
      [self setupVideoPipelineWithInputFormatDescription:formatDescription];
    return;
  }
  
  if (connection == videoConnection) {
    [self renderVideoSampleBuffer:sampleBuffer];
  }
  else if (connection == audioConnection) {
    outputAudioFormatDescription = formatDescription;
    if (recordingStatus == RecordingStatusRecording || recordingStatus == RecordingStatusPaused)
      [recorder appendAudioSampleBuffer:sampleBuffer];
  }
}

static BOOL rendering = NO;

- (void)renderVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  CVPixelBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  if (sourcePixelBuffer == NULL)
    return;
  
  if (rendering) {
    //NSLog(@"  still rendering. skip frame");
    return;
  }
  
  rendering = YES;
  currentPreviewPixelBuffer = (CVPixelBufferRef)CFRetain(sourcePixelBuffer);
  CFRetain(sampleBuffer);
  
  CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
  [self calculateFramerateAtTimestamp:timestamp];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool
    {
      [self.delegate captureManagerPreviewPixelBufferReadyForDisplay:currentPreviewPixelBuffer];
      
      if (recordingStatus == RecordingStatusRecording || recordingStatus == RecordingStatusPaused) {
        CVPixelBufferRef renderedPixelBuffer = currentPreviewPixelBuffer;
        if ([self.delegate respondsToSelector:@selector(captureManagerPixelBufferReadyForRecord:)])
          renderedPixelBuffer = [self.delegate captureManagerPixelBufferReadyForRecord:currentPreviewPixelBuffer];
        if (renderedPixelBuffer && recordingStatus == RecordingStatusRecording) {
          [recorder appendVideoPixelBuffer:renderedPixelBuffer withPresentationTime:timestamp];
          videoDuration = CMTimeGetSeconds(recorder.duration);
        }
      }
      if (currentPreviewPixelBuffer)
        CFRelease(currentPreviewPixelBuffer), currentPreviewPixelBuffer = NULL;
      
      CFRelease(sampleBuffer);
      rendering = NO;
    }
  });
}


#pragma mark Still Image Capture

- (void)captureStillImageWithCompletion:(void (^)(UIImage *image, NSError *error))completion
{
  AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    int ori = 0;
    
    AVCaptureVideoOrientation orientation;
    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
        orientation = AVCaptureVideoOrientationLandscapeLeft;
        ori = 3;
    }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        orientation = AVCaptureVideoOrientationLandscapeRight;
        ori = 2;
    }else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
        orientation = AVCaptureVideoOrientationLandscapeRight;
        ori = 4;
    }else {
        orientation = AVCaptureVideoOrientationPortrait;
        ori =1;
    }
    
    
    [stillImageConnection setVideoOrientation:orientation];
  
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
    
    if (error || !sampleBuffer) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (completion)
          completion(nil, error);
        if ([self.delegate respondsToSelector:@selector(captureManagerDidFailWithError:)])
          [self.delegate captureManagerDidFailWithError:error];
      });
      return;
    }
    
    // Success...
    
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
        UIImage *temp;
        if(ori == 3){
            if(self.isFrontFacingCameraActive){
                temp = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationDown];
            }else{
                temp = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationUp];
            }
        }else if(ori == 2){
            if(self.isFrontFacingCameraActive){
                temp = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationUp];
            }else{
                temp = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationDown];
            }
            
        }else if(ori == 4){
            temp = [UIImage imageWithCGImage:temp.CGImage scale:1.0f orientation:UIImageOrientationLeft];
        }
        else{
            temp = image;
        }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (completion)
        completion(temp, nil);
    });
    
  }];
}

#pragma mark Recording

- (void)startRecordingToPath:(NSString *)path
{
  if (recordingStatus != RecordingStatusIdle) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
    return;
  }
  [self transitionToRecordingStatus:RecordingStatusStartingRecording error:nil];
  
  videoDuration = 0.0;
    
    recordingOrientation = [self avOrientationForDeviceOrientation:[[UIDevice currentDevice] orientation]];;
  
  recordingURL = [[NSURL alloc] initFileURLWithPath:path];
  [[NSFileManager defaultManager] removeItemAtURL:recordingURL error:NULL];
  
  recorder = [[MovieRecorder alloc] initWithURL:recordingURL];
  
  CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(outputVideoFormatDescription);
  
  CGAffineTransform videoTransform = [self transformFromVideoBufferOrientationToOrientation:self.recordingOrientation withAutoMirroring:NO];  // Front camera recording shouldn't be mirrored
  
#if RECORD_AUDIO
  AVCaptureAudioDataOutput *audioOut = (AVCaptureAudioDataOutput *)audioConnection.output;
  NSDictionary *audioCompressionSettings = [[audioOut recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
  [recorder addAudioTrackWithSettings:audioCompressionSettings];
#endif
  AVCaptureVideoDataOutput *videoOut = (AVCaptureVideoDataOutput *)videoConnection.output;
  NSDictionary *videoCompressionSettings = [[videoOut recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
  [recorder addVideoTrackWithDimensions:dimensions transform:videoTransform settings:videoCompressionSettings];
  
  dispatch_queue_t callbackQueue = dispatch_queue_create("capturemanager.recordercallback", DISPATCH_QUEUE_SERIAL); // guarantee ordering of callbacks with a serial queue
  [recorder setDelegate:self callbackQueue:callbackQueue];
  
  [recorder prepareToRecord];  // asynchronous, will call recorderDidFinishPreparing: or recorder:didFailWithError:
}

- (void)stopRecording {
  if (recordingStatus == RecordingStatusRecording || recordingStatus == RecordingStatusPaused) {
    [self transitionToRecordingStatus:RecordingStatusStoppingRecording error:nil];
    [recorder finishRecording];  // asynchronous, will call recorderDidFinishRecording: or recorder:didFailWithError:
  }
}

- (void)pauseRecording {
  if (recordingStatus == RecordingStatusRecording) {
    recordingStatus = RecordingStatusPaused;
    [recorder pauseRecording];
  }
}

- (void)resumeRecording {
  if (recordingStatus == RecordingStatusPaused) {
    recordingStatus = RecordingStatusRecording;
    [recorder resumeRecording];
  }
}

#pragma mark MovieRecorder Delegate

- (void)movieRecorderDidFinishPreparing:(MovieRecorder *)recorder
{
  if (recordingStatus != RecordingStatusStartingRecording) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StartingRecording state" userInfo:nil];
    return;
  }
  [self transitionToRecordingStatus:RecordingStatusRecording error:nil];
}

- (void)movieRecorder:(MovieRecorder *)rec didFailWithError:(NSError *)error
{
  recorder = nil;
  [self transitionToRecordingStatus:RecordingStatusIdle error:error];
}

- (void)movieRecorderDidFinishRecording:(MovieRecorder *)rec
{
  if (recordingStatus != RecordingStatusStoppingRecording) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
    return;
  }
  // No state transition, we are still in the process of stopping.
  // We will be stopped once we save video
  
  recorder = nil;
  
  [self transitionToRecordingStatus:RecordingStatusIdle error:nil];
}


#pragma mark Recording State Machine

- (void)transitionToRecordingStatus:(RecordingStatus)newStatus error:(NSError *)error
{
  RecordingStatus oldStatus = recordingStatus;
  recordingStatus = newStatus;
  
  if (newStatus != oldStatus) {
    dispatch_async(dispatch_get_main_queue(), ^{
      @autoreleasepool {
        if (error && (newStatus == RecordingStatusIdle)) {
          [self.delegate captureManagerDidFailWithError:error];
        }
        else {
          if ((oldStatus == RecordingStatusStartingRecording) && (newStatus == RecordingStatusRecording)) {
            if ([self.delegate respondsToSelector:@selector(captureManagerRecordingDidStart)])
              [self.delegate captureManagerRecordingDidStart];
          }
          else if ((oldStatus == RecordingStatusStoppingRecording) && (newStatus == RecordingStatusIdle)) {
            if ([self.delegate respondsToSelector:@selector(captureManagerRecordingDidStop)])
              [self.delegate captureManagerRecordingDidStop];
          }
        }
      }
    });
  }
}


#pragma mark Utilities

// Auto mirroring: Front camera is mirrored; back camera isn't
- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(UIInterfaceOrientation)orientation
                                                    withAutoMirroring:(BOOL)mirror
{
  CGAffineTransform transform = CGAffineTransformIdentity;
		
  // Calculate offsets from an arbitrary reference orientation (portrait)
  CGFloat orientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation(orientation);
  CGFloat videoOrientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation(self.videoOrientation);
  
  // Find the difference in angle between the desired orientation and the video orientation
  CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
  transform = CGAffineTransformMakeRotation(angleOffset);
  
  if (videoDevice.position == AVCaptureDevicePositionFront) {
    if (mirror)
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
    else {
      if (UIInterfaceOrientationIsPortrait(orientation)) {
        transform = CGAffineTransformRotate(transform, M_PI);
      }
    }
  }
  
  return transform;
}

static CGFloat angleOffsetFromPortraitOrientationToOrientation(UIInterfaceOrientation orientation)
{
  switch ((AVCaptureVideoOrientation)orientation) {
    case AVCaptureVideoOrientationPortraitUpsideDown:
      return M_PI;
    case AVCaptureVideoOrientationLandscapeLeft:
      return M_PI_2;
    case AVCaptureVideoOrientationLandscapeRight:
      return -M_PI_2;
    default:
      return 0.0;
  }
}

- (void)calculateFramerateAtTimestamp:(CMTime)timestamp
{
  [previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
  
  CMTime oneSecond = CMTimeMake(1, 1);
  CMTime oneSecondAgo = CMTimeSubtract(timestamp, oneSecond);
  
  while(CMTIME_COMPARE_INLINE([previousSecondTimestamps[0] CMTimeValue], <, oneSecondAgo)) {
    [previousSecondTimestamps removeObjectAtIndex:0];
  }
  
  if ([previousSecondTimestamps count] > 1) {
    const Float64 duration = CMTimeGetSeconds(CMTimeSubtract([[previousSecondTimestamps lastObject] CMTimeValue], [previousSecondTimestamps[0] CMTimeValue]));
    const float newRate = (float)([previousSecondTimestamps count] - 1) / duration;
    videoFrameRate = newRate;
  }
}


- (void)focusAtPoint:(CGPoint)point
{
  AVCaptureDevice *device = videoDevice;
  if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
      [device setFocusPointOfInterest:point];
      [device setFocusMode:AVCaptureFocusModeAutoFocus];
      [device unlockForConfiguration];
    } else {
      NSLog(@"%@", error);
    }
  }
}

- (BOOL)hasFlash {
  return ([videoDevice hasFlash] && [videoDevice isFlashModeSupported:AVCaptureFlashModeOn]);
}

- (BOOL)hasTorch {
  return ([videoDevice hasTorch] && [videoDevice isTorchModeSupported:AVCaptureTorchModeOn]);
}

- (AVCaptureFlashMode)flashMode {
  return [videoDevice flashMode];
};

- (AVCaptureTorchMode)torchMode {
  return [videoDevice torchMode];
};

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
  [self setFlashMode:flashMode forDevice:videoDevice];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
  [self setTorchMode:torchMode forDevice:videoDevice];
}

- (BOOL)hasFrontFacingCamera {
  return ([[AVCaptureDevice devices] count] > 1);
}

- (BOOL)isFrontFacingCameraActive {
  return ([videoDevice position] == AVCaptureDevicePositionFront);
}

- (void)switchCameraWithCompletion:(void (^)(void))completion
{
  pauseOutputSampleBuffer = YES;
  outputVideoFormatDescription = nil;
  
  dispatch_async(sessionQueue, ^{
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
    AVCaptureDevicePosition currentPosition = [videoDevice position];
    
    switch (currentPosition) {
      case AVCaptureDevicePositionUnspecified:
        preferredPosition = AVCaptureDevicePositionBack;
        break;
      case AVCaptureDevicePositionBack:
        preferredPosition = AVCaptureDevicePositionFront;
        break;
      case AVCaptureDevicePositionFront:
        preferredPosition = AVCaptureDevicePositionBack;
        break;
    }
    
    AVCaptureDevice *newVideoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
    AVCaptureDeviceInput *newVideoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newVideoDevice error:nil];
    
    [captureSession beginConfiguration];
    
    [captureSession removeInput:videoDeviceInput];
    
    if ([captureSession canAddInput:newVideoDeviceInput])
    {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
      
      [self setFlashMode:AVCaptureFlashModeOff forDevice:newVideoDevice];
      [self setTorchMode:AVCaptureTorchModeOff forDevice:newVideoDevice];
      
      [captureSession addInput:newVideoDeviceInput];
      videoDeviceInput = newVideoDeviceInput;
      
      // restore video/audio connections
      for (AVCaptureOutput *output in captureSession.outputs) {
        if ([output isKindOfClass:[AVCaptureVideoDataOutput class]]) {
          videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
          videoOrientation = videoConnection.videoOrientation;
        }
        else if ([output isKindOfClass:[AVCaptureAudioDataOutput class]]) {
          audioConnection = [output connectionWithMediaType:AVMediaTypeAudio];
        }
      }
      videoDevice = newVideoDevice;
    }
    else {
      [captureSession addInput:videoDeviceInput];
    }
    
    [captureSession commitConfiguration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      pauseOutputSampleBuffer = NO;
      if (completion)
        completion();
    });
  });
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
  AVCaptureDevice *captureDevice = [devices firstObject];
  
  for (AVCaptureDevice *device in devices) {
    if ([device position] == position) {
      captureDevice = device;
      break;
    }
  }
  
  return captureDevice;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
  if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
      [device setFlashMode:flashMode];
      [device unlockForConfiguration];
      lastFlashMode = flashMode;
    }
    else {
      NSLog(@"%@", error);
    }
  }
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode forDevice:(AVCaptureDevice *)device
{
  if ([device hasTorch] && [device isTorchModeSupported:torchMode]) {
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
      [device setTorchMode:torchMode];
      [device unlockForConfiguration];
      lastTorchMode = torchMode;
    }
    else {
      NSLog(@"%@", error);
    }
  }
}

@end




