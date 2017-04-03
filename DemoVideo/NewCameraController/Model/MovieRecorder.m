

#import "MovieRecorder.h"


#define LOG_STATUS_TRANSITIONS 0

// internal state machine
typedef NS_ENUM(NSInteger, MovieRecorderStatus) {
  MovieRecorderStatusIdle = 0,
  MovieRecorderStatusPreparingToRecord,
  MovieRecorderStatusRecording,
  MovieRecorderStatusFinishingRecordingPart1, // waiting for inflight buffers to be appended
  MovieRecorderStatusFinishingRecordingPart2, // calling finish writing on the asset writer
  MovieRecorderStatusFinished,                // terminal state
  MovieRecorderStatusFailed                   // terminal state
};


@interface MovieRecorder ()
{
  MovieRecorderStatus status;
}
@end


@implementation MovieRecorder
@synthesize duration;

- (instancetype)initWithURL:(NSURL *)url
{
  if (!url)
    return nil;
  
  if (self = [super init]) {
    writingQueue = dispatch_queue_create("movierecorder.writing", DISPATCH_QUEUE_SERIAL);
    videoTrackTransform = CGAffineTransformIdentity;
    URL = url;
  }
  return self;
}

- (void)addVideoTrackWithDimensions:(CMVideoDimensions)dimensions transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings
{
  videoDimensions = dimensions;
  
  @synchronized(self) {
    if (status != MovieRecorderStatusIdle) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
      return;
    }
    videoTrackTransform = transform;
    videoTrackSettings = [videoSettings copy];
  }
}

- (void)addAudioTrackWithSettings:(NSDictionary *)audioSettings
{
  @synchronized(self) {
    if (status != MovieRecorderStatusIdle) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
      return;
    }
    audioTrackSettings = [audioSettings copy];
  }
}

- (void)setDelegate:(id<MovieRecorderDelegate>)delegate_ callbackQueue:(dispatch_queue_t)delegateCallbackQueue_
{
  if (delegate_ && (delegateCallbackQueue_ == NULL)) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Caller must provide a delegateCallbackQueue" userInfo:nil];
  }
  
  @synchronized(self) {
    delegate = delegate_;
    if (delegateCallbackQueue_ != delegateCallbackQueue ) {
      delegateCallbackQueue = delegateCallbackQueue_;
    }
  }
}

- (void)prepareToRecord
{
  @synchronized(self) {
    if (status != MovieRecorderStatusIdle) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already prepared, cannot prepare again" userInfo:nil];
      return;
    }
    
    isPaused = NO;
    needsUpdateTimeOffset = NO;
    timeOffset = CMTimeMake(0, 30);
    
    [self transitionToStatus:MovieRecorderStatusPreparingToRecord error:nil];
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    
    @autoreleasepool
    {
      NSError *error = nil;
      // AVAssetWriter will not write over an existing file.
      [[NSFileManager defaultManager] removeItemAtURL:URL error:NULL];
      
      assetWriter = [[AVAssetWriter alloc] initWithURL:URL fileType:AVFileTypeQuickTimeMovie error:&error];
      
      // Create and add inputs
      
      if (!error) {
        [self setupAssetWriterVideoInputWithTransform:videoTrackTransform settings:videoTrackSettings error:&error];
      }
      
      if (!error) {
        [self setupAssetWriterAudioInputWithSettings:audioTrackSettings error:&error];
      }
      
      if (!error) {
        [assetWriter startWriting];
        error = assetWriter.error;
      }
      
      @synchronized(self) {
        if (error)
          [self transitionToStatus:MovieRecorderStatusFailed error:error];
        else
          [self transitionToStatus:MovieRecorderStatusRecording error:nil];
      }
    }
  });
}

- (CMSampleBufferRef)adjustSampleBufferTime:(CMSampleBufferRef)sampleBuffer by:(CMTime)offset
{
  CMItemCount count;
  CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
  CMSampleTimingInfo *pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
  CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, count, pInfo, &count);
  
  for (CMItemCount i = 0; i < count; i++) {
    pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
    pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
  }
  CMSampleBufferRef resultSampleBuffer;
  CMSampleBufferCreateCopyWithNewTiming(nil, sampleBuffer, count, pInfo, &resultSampleBuffer);
  free(pInfo);
  return resultSampleBuffer;
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime
{
  CMSampleBufferRef sampleBuffer = NULL;
  
  CMSampleTimingInfo timingInfo = {0,};
  timingInfo.duration = kCMTimeInvalid;
  timingInfo.decodeTimeStamp = kCMTimeInvalid;
  timingInfo.presentationTimeStamp = presentationTime;
  
  CMFormatDescriptionRef videoFormatDescription = NULL;
  CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoFormatDescription);
  
  OSStatus err = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoFormatDescription, &timingInfo, &sampleBuffer);
  
  if (sampleBuffer) {
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
    CFRelease(sampleBuffer);
  }
  else {
    NSString *exceptionReason = [NSString stringWithFormat:@"sample buffer create failed (%i)", (int)err];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:exceptionReason userInfo:nil];
    return;
  }
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}

static BOOL isPaused = NO;
static BOOL needsUpdateTimeOffset = NO;
static CMTime lastVideoTime = {0,};
static CMTime lastAudioTime = {0,};
static CMTime timeOffset = {0,};

- (void)pauseRecording
{
  //Mark;
  isPaused = YES;
  needsUpdateTimeOffset = YES;
}

- (void)resumeRecording
{
  //Mark;
  isPaused = NO;
}

- (void)finishRecording
{
  @synchronized(self)
  {
    BOOL shouldFinishRecording = NO;
    switch (status)
    {
      case MovieRecorderStatusIdle:
      case MovieRecorderStatusPreparingToRecord:
      case MovieRecorderStatusFinishingRecordingPart1:
      case MovieRecorderStatusFinishingRecordingPart2:
      case MovieRecorderStatusFinished:
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not recording" userInfo:nil];
        break;
      case MovieRecorderStatusFailed:
        // From the client's perspective the movie recorder can asynchronously transition to an error state as the result of an append.
        // Because of this we are lenient when finishRecording is called and we are in an error state.
        NSLog(@"Recording has failed, nothing to do");
        break;
      case MovieRecorderStatusRecording:
        shouldFinishRecording = YES;
        break;
    }
    
    if (shouldFinishRecording) {
      [self transitionToStatus:MovieRecorderStatusFinishingRecordingPart1 error:nil];
    }
    else {
      return;
    }
  }
  
  dispatch_async(writingQueue, ^{
    @autoreleasepool {
      @synchronized(self) {
        // We may have transitioned to an error state as we appended inflight buffers. In that case there is nothing to do now.
        if (status != MovieRecorderStatusFinishingRecordingPart1) {
          return;
        }
        
        // It is not safe to call -[AVAssetWriter finishWriting*] concurrently with -[AVAssetWriterInput appendSampleBuffer:]
        // We transition to MovieRecorderStatusFinishingRecordingPart2 while on writingQueue, which guarantees that no more buffers will be appended.
        [self transitionToStatus:MovieRecorderStatusFinishingRecordingPart2 error:nil];
      }
      
      [assetWriter finishWritingWithCompletionHandler:^{
        @synchronized(self) {
          NSError *error = assetWriter.error;
          if (error)
            [self transitionToStatus:MovieRecorderStatusFailed error:error];
          else
            [self transitionToStatus:MovieRecorderStatusFinished error:nil];
        }
      }];
    }
  });
}

- (void)dealloc
{
  delegate = nil;
  [self teardownAssetWriterAndInputs];
}

#pragma mark -
#pragma mark Internal

static CMTime prevVideoTime = {0,};
static CMTime prevAudioTime = {0,};

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
  if (sampleBuffer == NULL) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
    return;
  }
  
  @synchronized(self) {
    if (status < MovieRecorderStatusRecording) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not ready to record yet" userInfo:nil];
      return;
    }
  }
  
  if (isPaused) {
    //NSLog(@"  movie recorder paused. skip %@ frame", (mediaType == AVMediaTypeVideo ? @"video" : @"audio"));
    needsUpdateTimeOffset = YES;
    return;
  }
  
  CFRetain(sampleBuffer);
  
  dispatch_async(writingQueue, ^{
    @autoreleasepool{
      @synchronized(self) {
        // From the client's perspective the movie recorder can asynchronously transition to an error state as the result of an append.
        // Because of this we are lenient when samples are appended and we are no longer recording.
        // Instead of throwing an exception we just release the sample buffers and return.
        if (status > MovieRecorderStatusFinishingRecordingPart1) {
          CFRelease(sampleBuffer);
          return;
        }
      }
      
      CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
      
      if (!haveStartedSession) {
        if (mediaType != AVMediaTypeVideo) {
          return;
        }
        startTime = time;
        [assetWriter startSessionAtSourceTime:time];
        haveStartedSession = YES;
        //NSLog(@"assetWriter startSessionAtSourceTime: %0.3f", CMTimeGetSeconds(time));
      }
      
      if (isPaused) {
        //NSLog(@"  movie recorder paused. skip %@ frame", (mediaType == AVMediaTypeVideo ? @"video" : @"audio"));
        CFRelease(sampleBuffer);
        needsUpdateTimeOffset = YES;
        return;
      }
      
      AVAssetWriterInput *input = (mediaType == AVMediaTypeVideo ? videoInput : audioInput);
      
      if (input.readyForMoreMediaData)
      {
        CMSampleBufferRef sampleBufferToAppend = sampleBuffer;
        CFRetain(sampleBufferToAppend);
        
        if (needsUpdateTimeOffset) {
          CMTime offset = CMTimeSubtract(time, (mediaType == AVMediaTypeVideo ? lastVideoTime : lastAudioTime));
          timeOffset = (timeOffset.value == 0 ? offset : CMTimeAdd(timeOffset, offset));
          needsUpdateTimeOffset = NO;
        }
        
        if (timeOffset.value > 0) {
          CFRelease(sampleBuffer);
          sampleBufferToAppend = [self adjustSampleBufferTime:sampleBuffer by:timeOffset];
        }
        
        if (mediaType == AVMediaTypeVideo)
          lastVideoTime = time;
        else
          lastAudioTime = time;
        
        // get updated sample buffer time
        time = CMSampleBufferGetPresentationTimeStamp(sampleBufferToAppend);
        double t0 = CMTimeGetSeconds((mediaType == AVMediaTypeVideo ? prevVideoTime : prevAudioTime));
        double t1 = CMTimeGetSeconds(time);
        
        if (mediaType == AVMediaTypeVideo)
          prevVideoTime = time;
        else
          prevAudioTime = time;
        
        // time shouldn't be equal to prev sample buffer time!
        if (t1 <= t0) {
          CFRelease(sampleBuffer);
          return;
        }
        
        BOOL success = [input appendSampleBuffer:sampleBufferToAppend];
        CFRelease(sampleBufferToAppend);
        
        if (mediaType == AVMediaTypeVideo) {
          duration = CMTimeSubtract(time, startTime);
          //NSLog(@"duration = (%zd, %zd)", duration.value, duration.timescale);
        }
        
        if (!success) {
          NSError *error = assetWriter.error;
          @synchronized(self) {
            [self transitionToStatus:MovieRecorderStatusFailed error:error];
          }
        }
      }
      else
      {
        NSLog(@"  %@ input not ready for more media data, dropping buffer", mediaType);
      }
      CFRelease(sampleBuffer);
    }
  });
}

// call under @synchonized(self)
- (void)transitionToStatus:(MovieRecorderStatus)newStatus error:(NSError *)error
{
  BOOL shouldNotifyDelegate = NO;
  
#if LOG_STATUS_TRANSITIONS
  NSLog(@"MovieRecorder state transition: %@->%@", [self stringForStatus:status], [self stringForStatus:newStatus]);
#endif
  
  if (newStatus != status) {
    // terminal states
    if ((newStatus == MovieRecorderStatusFinished) || (newStatus == MovieRecorderStatusFailed))
    {
      shouldNotifyDelegate = YES;
      // make sure there are no more sample buffers in flight before we tear down the asset writer and inputs
      dispatch_async(writingQueue, ^{
        [self teardownAssetWriterAndInputs];
        if (newStatus == MovieRecorderStatusFailed) {
          [[NSFileManager defaultManager] removeItemAtURL:URL error:NULL];
        }
      });
      
#if LOG_STATUS_TRANSITIONS
      if (error) {
        NSLog(@"MovieRecorder error: %@, code: %i", error, (int)error.code);
      }
#endif
    }
    else if (newStatus == MovieRecorderStatusRecording) {
      shouldNotifyDelegate = YES;
    }
    
    status = newStatus;
  }
  
  if (shouldNotifyDelegate && delegate) {
    dispatch_async(delegateCallbackQueue, ^{
      @autoreleasepool {
        switch (newStatus) {
          case MovieRecorderStatusRecording:
            [delegate movieRecorderDidFinishPreparing:self];
            break;
          case MovieRecorderStatusFinished:
            [delegate movieRecorderDidFinishRecording:self];
            break;
          case MovieRecorderStatusFailed:
            [delegate movieRecorder:self didFailWithError:error];
            break;
          default:
            break;
        }
      }
    });
  }
}

#if LOG_STATUS_TRANSITIONS

- (NSString *)stringForStatus:(MovieRecorderStatus)status
{
  NSString *statusString = nil;
  
  switch (status)
  {
    case MovieRecorderStatusIdle:
      statusString = @"Idle";
      break;
    case MovieRecorderStatusPreparingToRecord:
      statusString = @"PreparingToRecord";
      break;
    case MovieRecorderStatusRecording:
      statusString = @"Recording";
      break;
    case MovieRecorderStatusFinishingRecordingPart1:
      statusString = @"FinishingRecordingPart1";
      break;
    case MovieRecorderStatusFinishingRecordingPart2:
      statusString = @"FinishingRecordingPart2";
      break;
    case MovieRecorderStatusFinished:
      statusString = @"Finished";
      break;
    case MovieRecorderStatusFailed:
      statusString = @"Failed";
      break;
    default:
      statusString = @"Unknown";
      break;
  }
  return statusString;
  
}

#endif // LOG_STATUS_TRANSITIONS

- (BOOL)setupAssetWriterAudioInputWithSettings:(NSDictionary *)audioSettings error:(NSError **)errorOut
{
  if (!audioSettings) {
    NSLog(@"No audio settings provided, using default settings");
    audioSettings = @{AVFormatIDKey         : @(kAudioFormatMPEG4AAC),
                      AVEncoderBitRateKey   : @64000,
                      AVNumberOfChannelsKey : @1,
                      AVSampleRateKey       : @44100};
  }
  
  if ([assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio])
  {
    audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    audioInput.expectsMediaDataInRealTime = YES;
    
    if ([assetWriter canAddInput:audioInput]) {
      [assetWriter addInput:audioInput];
    }
    else {
      if (errorOut) {
        *errorOut = [[self class] cannotSetupInputError];
      }
      return NO;
    }
  }
  else {
    if (errorOut) {
      *errorOut = [[self class] cannotSetupInputError];
    }
    return NO;
  }
  
  return YES;
}

- (BOOL)setupAssetWriterVideoInputWithTransform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)errorOut
{
  if (!videoSettings)
  {
    float bitsPerPixel;
    int numPixels = videoDimensions.width * videoDimensions.height;
    int bitsPerSecond;
    
    NSLog(@"No video settings provided, using default settings");
    
    bitsPerPixel = 10.1;  // This bitrate approximately matches the quality produced by AVCaptureSessionPresetHigh.
    bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *compressionProperties = @{AVVideoAverageBitRateKey          : @(bitsPerSecond),
                                            AVVideoExpectedSourceFrameRateKey : @(30),
                                            AVVideoMaxKeyFrameIntervalKey     : @(30)};
    
    videoSettings = @{AVVideoCodecKey  : AVVideoCodecH264,
                      AVVideoWidthKey  : @(videoDimensions.width),
                      AVVideoHeightKey : @(videoDimensions.height),
                      AVVideoCompressionPropertiesKey : compressionProperties};
  }
  
  if ([assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo])
  {
    videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    videoInput.expectsMediaDataInRealTime = YES;
    videoInput.transform = transform;
    
    if ([assetWriter canAddInput:videoInput]) {
      [assetWriter addInput:videoInput];
    }
    else {
      if (errorOut) {
        *errorOut = [[self class] cannotSetupInputError];
      }
      return NO;
    }
  }
  else {
    if (errorOut) {
      *errorOut = [[self class] cannotSetupInputError];
    }
    return NO;
  }
  
  return YES;
}

+ (NSError *)cannotSetupInputError
{
  NSString *localizedDescription = NSLocalizedString(@"Recording cannot be started", nil);
  NSString *localizedFailureReason = NSLocalizedString(@"Cannot setup asset writer input.", nil);
  NSDictionary *errorDict = @{NSLocalizedDescriptionKey : localizedDescription,
                              NSLocalizedFailureReasonErrorKey : localizedFailureReason};
  return [NSError errorWithDomain:@"com.apple.dts.samplecode" code:0 userInfo:errorDict];
}

- (void)teardownAssetWriterAndInputs
{
  videoInput = nil;
  audioInput = nil;
  assetWriter = nil;
}

@end


