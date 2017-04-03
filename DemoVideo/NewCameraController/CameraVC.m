

#import "CameraVC.h"
//#import "Common.h"
//#import "UIImage+Utils.h"
#import "NSObject+Blocks.h"
#import "UIDevice+Platform.h"
//#import "MPSettings.h"

#import "DemoVideo-Swift.h"

@implementation CameraVC

-(void)swipeChangesLeft{
    if(captureMode == CaptureModePhoto){
        //  captureMode = CaptureModeVideo;
        [self switchToMode:CaptureModeVideo];
        [captureModeSwitch setSelectedIndex:0 animated:YES];
    }
    
}

-(void)swipeChangesRight{
    
    if(captureMode == CaptureModeVideo){
        //  captureMode = CaptureModePhoto;
        [self switchToMode:CaptureModePhoto];
        [captureModeSwitch setSelectedIndex:0 animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    saveFileName = @"/test.mp4";
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak CameraVC *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            CameraVC *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                //[[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
            });
        }]];
        [[self session] startRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    closeButton.hidden = NO;

    
    NSLog(@"Camera Open");
    
    //    UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeChangesLeft)];
    //    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    //    [self.view addGestureRecognizer:recognizerLeft];
    //
    //
    //    UISwipeGestureRecognizer *recognizerRight= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeChangesRight)];
    //    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    //    [self.view addGestureRecognizer:recognizerRight];
    
    
    // [previewView setSession:captureManager.captureSession];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    recordingTimeLabel.hidden = YES;
    topCurtainView.hidden     = YES;
    bottomCurtainView.hidden  = YES;
    
    captureModeSwitch.titles  = @[@"PHOTO", @"VIDEO"];
    captureModeSwitch.titlesFont  = [UIFont fontWithName:@"DINAlternate-Bold" size:(isPad ? 22 : 11)];
    captureModeSwitch.titlesColor = [UIColor whiteColor];
    captureModeSwitch.distanceBetweenTitles = (isPad ? 48 : 24);
    
    __weak id weakSelf = self;
    
    [captureModeSwitch setSelectBlock:^(NSInteger i, NSString *title) {
        NSLog(@"Selected capture mode: %@", title);
        //  [weakSelf switchToMode:(i == 0 ? CaptureModePhoto : CaptureModeVideo)];
        [weakSelf switchToMode:(i == 0 ? CaptureModeVideo : CaptureModeVideo)];
    }];
    
    // Camera
    
    videoResolution = CGSizeZero;
    //recordingPath = [NSString pathWithComponents:@[NSTemporaryDirectory(), @"video.mov"]];
    
    //
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    recordingPath = [docsPath stringByAppendingPathComponent:saveFileName];
    
    //
    
    //  recordingPath = [CachedDataPath stringByAppendingPathComponent:@"camera.mov"];
    
    currentOrientationAngle = 0;
    currentOrientation = UIInterfaceOrientationPortrait;
    
    if(isPad){
        previewView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }else{
        if(SCREENSIZE == 480){
            previewView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }else{
            previewView.videoGravity = AVLayerVideoGravityResizeAspect;
        }
        
    }
    
    previewView.backgroundColor = [UIColor blackColor];
    
    /*
     captureManager = [[CaptureManager alloc] init];
     captureManager.delegate = self;
     
     
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     NSString *strName = [[UIDevice currentDevice] platformString];
     if([strName isEqualToString:@"iPhone 4"] || [strName isEqualToString:@"iPhone 4 (CDMA)"] || [strName rangeOfString:@"iPod"].location != NSNotFound){
     [captureManager setupCaptureSessionWithPreset:AVCaptureSessionPreset640x480 completion:^{
     [self performInMainThread:^{
     NSLog(@"Camera load finish");
     self.activity.hidden = YES;
     [previewView setSession:captureManager.captureSession];
     }];
     
     }];
     }else{
     [captureManager setupCaptureSessionWithPreset:AVCaptureSessionPreset1280x720 completion:^{
     self.activity.hidden = YES;
     [previewView setSession:captureManager.captureSession];
     }];
     }
     });
     */
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    // Setup the preview view
    [previewView setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CameraVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[previewView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.activity.hidden = YES;
        });
        
    });
    
    captureMode = 1;
    
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                //  [device setExposureMode:exposureMode];
                // [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setTorchMode:(AVCaptureTorchMode)torchMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasTorch] && [device isTorchModeSupported:torchMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:torchMode];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    }
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}


#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[previewView layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[previewView layer] setOpacity:1.0];
        }];
    });
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    self.view.userInteractionEnabled = YES;
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    /*
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     
     [timer invalidate];
     
     NSString *path = [CommonHeaders func_GetDatabasePath];
     
     FMDatabase *database1 = [FMDatabase databaseWithPath:path];
     
     [database1 open];
     
     FMResultSet *results2 = [database1 executeQuery:[NSString stringWithFormat:@"select * from Category where Name = 'com.squaresized.longVideo' AND isPurchased=1"]];
     
     BOOL filterSuccess = NO;
     while ([results2 next]) {
     filterSuccess = YES;
     }
     
     [database1 close];
     
     if(!filterSuccess){
     //  SharedObj.isFromCameraVideo = TRUE;
     
     if(myCounter == 1){
     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
     BOOL openInstagram = [ud boolForKey:@"OpenVideoPro"];
     if (openInstagram == NO){
     [ud setBool:YES forKey:@"OpenVideoPro"];
     [ud synchronize];
     
     [SharedObj showSingleButtonAlertWithTitle:@"In order not to push your phone's performance to the max we've limited videos to 1 minute" :^(NSInteger index) {
     [self dismissViewControllerAnimated:NO completion:^{
     [SharedObj showLoadingWithText:@"Loading..."];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     SharedObj.isFromCameraVideo = TRUE;
     [MPSettings sharedSetting].selectVideo(YES);
     });
     }];
     }];
     }else{
     [self dismissViewControllerAnimated:NO completion:^{
     [SharedObj showLoadingWithText:@"Loading..."];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     SharedObj.isFromCameraVideo = TRUE;
     [MPSettings sharedSetting].selectVideo(YES);
     });
     }];
     }
     }else{
     //            SharedObj.isFromCameraVideo = TRUE;
     //            [self dismissViewControllerAnimated:YES completion:nil];
     [self dismissViewControllerAnimated:NO completion:^{
     [self func_commonVideoInitializeMethod];
     }];
     }
     
     //        [self dismissViewControllerAnimated:YES completion:^{
     //            if(captureManager.videoDuration > 60){
     //                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
     //                BOOL openInstagram = [ud boolForKey:@"OpenVideoPro"];
     //                if (openInstagram == NO){
     //                    [ud setBool:YES forKey:@"OpenVideoPro"];
     //                    [ud synchronize];
     //
     //                    [SharedObj showSingleButtonAlertWithTitle:@"In order not to push your phone's performance to the max we've limited videos to 1 minute" :^(NSInteger index) {
     //
     //                    }];
     //                }
     //            }
     //
     //        }];
     }else{
     [self dismissViewControllerAnimated:NO completion:^{
     [self func_commonVideoInitializeMethod];
     }];
     
     // [self dismissViewControllerAnimated:YES completion:nil];
     }
     });
     */
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self func_commonVideoInitializeMethod];
    }];
    
    
    //    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
    //        if (error)
    //            NSLog(@"%@", error);
    //
    //        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    //
    //        if (backgroundRecordingID != UIBackgroundTaskInvalid)
    //            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    //    }];
}

/*
 
 - (BOOL)shouldAutorotate {
 return !isRecording;
 }
 
 - (NSUInteger)supportedInterfaceOrientations {
 return UIInterfaceOrientationMaskAllButUpsideDown;
 }
 
 - (void)viewDidLayoutSubviews {
 [super viewDidLayoutSubviews];
 [self layoutForCurrentOrientation];
 }
 
 // iOS 7 methods
 - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
 //NSLog(@"Rotation Started");
 if (self.presentedViewController == nil)
 [UIView setAnimationsEnabled:NO];
 }
 
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromOrientation {
 // Rotation Ended
 if (self.presentedViewController == nil)
 [UIView setAnimationsEnabled:YES];
 [self layoutForCurrentOrientation];
 [self animateRotationToNewOrientation];
 }
 */

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[previewView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}


// iOS 8 method
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // Rotation Started
    
    if (self.presentedViewController == nil)
        [UIView setAnimationsEnabled:NO];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Rotation Ended
        if (self.presentedViewController == nil)
            [UIView setAnimationsEnabled:YES];
        [self layoutForCurrentOrientation];
        [self animateRotationToNewOrientation];
    }];
}

- (void)layoutForCurrentOrientation
{
    CGRect Rect = self.view.bounds;
    BOOL isPortrait = (Rect.size.width < Rect.size.height);
    CGRect R = (isPortrait ? Rect : CGRectMake(0, 0, Rect.size.height, Rect.size.width));
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat curtainHeight = (R.size.height - R.size.width)/2;
    topCurtainView.frame    = CGRectMake(0, 0, R.size.width, curtainHeight);
    bottomCurtainView.frame = CGRectMake(0, R.size.height-curtainHeight, R.size.width, curtainHeight);
    
    currentOrientationAngle = [self interfaceRotationAngleFromDeviceOrientation:orientation];
    contentView.transform = CGAffineTransformMakeRotation(-currentOrientationAngle);
    contentView.frame = Rect;
}

- (void)animateRotationToNewOrientation
{
    UIInterfaceOrientation prevOrientation = currentOrientation;
    currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(currentOrientation);
    
    [captureManager setRecordingOrientation:(AVCaptureVideoOrientation)currentOrientation];
    
    // Rotate buttons, etc.
    
    if (currentOrientation != prevOrientation) {
        CGAffineTransform t = CGAffineTransformMakeRotation(currentOrientationAngle);
        CGFloat hw1 = flashButton.bounds.size.width/2;
        CGFloat hh1 = flashButton.bounds.size.height/2;
        CGFloat hw2 = flipButton.bounds.size.width/2;
        CGFloat hh2 = flipButton.bounds.size.height/2;
        CGFloat w = contentView.bounds.size.width;
        CGFloat h = (isPortrait ? MAX(hh1, hh2)*2 : MAX(hw1, hw2)*2);
        [UIView animateWithDuration:0.25 animations:^{
            captureButton.transform = t;
            flashButton.transform   = t;
            cropButton.transform    = t;
            flipButton.transform    = t;
            closeButton.transform   = t;
            flashButton.center = (isPortrait ? CGPointMake(hw1, hh1) : CGPointMake(hh1, h/2));
            cropButton.center  = (isPortrait ? CGPointMake(w/2, h/2) : CGPointMake(w/2, h/2));
            flipButton.center  = (isPortrait ? CGPointMake(w-hw2, hh2) : CGPointMake(w-hh2, h/2));
            headerView.frame = CGRectMake(0, 0, w, h);
        }];
    }
}

- (void)dealloc {
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    //        [captureManager cleanupCaptureSession];
    //    });
    
}


#pragma mark - Actions

static BOOL prevCameraFlashEnabled = NO;

- (IBAction)close:(id)sender
{
    /*
     SharedObj.isFromCameraPicture = NO;
     SharedObj.isStopAdvertise = NO;
     */
    [captureManager cleanupCaptureSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)flash:(id)sender
{
    BOOL enabled = (captureManager.flashMode == AVCaptureFlashModeOn || captureManager.torchMode == AVCaptureTorchModeOn);
    enabled = !enabled;
    
    flashButton.selected = !flashButton.selected;
    
    if (captureMode == CaptureModePhoto)
        
        [CameraVC setFlashMode:(flashButton.selected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff) forDevice:[[self videoDeviceInput] device]];
    // [captureManager setFlashMode:(enabled ? AVCaptureFlashModeOn : AVCaptureFlashModeOff)];
    else
        [CameraVC setTorchMode:(flashButton.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff) forDevice:[[self videoDeviceInput] device]];
}

- (IBAction)flip:(id)sender
{
    self.view.userInteractionEnabled = NO;
    //  flashButton.hidden = YES;
    if (flashButton.hidden==NO)
    {
        flashButton.hidden = YES;
    }
    else
    {
        flashButton.hidden = NO;
        
    }
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                //                flashButton.hidden = NO;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                //                flashButton.hidden = YES;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                //                flashButton.hidden = NO;
                
                break;
        }
        
        AVCaptureDevice *videoDevice = [CameraVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [CameraVC setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (prevCameraFlashEnabled && [captureManager hasFlash])
            {
                flashButton.selected = YES;
                if (captureMode == CaptureModePhoto)
                    [captureManager setFlashMode:AVCaptureFlashModeOn];
                else
                    [captureManager setTorchMode:AVCaptureTorchModeOn];
            }
            //            else{
            //                flashButton.selected = NO;
            //            }
            prevCameraFlashEnabled = flashButton.selected;
            NSLog(@"%d",[captureManager hasFlash]);
            //            flashButton.hidden = [captureManager hasFlash];
            self.view.userInteractionEnabled = YES;
        });
    });
    
    //  [captureManager switchCameraWithCompletion:^{
    //    [self layoutForCurrentOrientation];
    //    if (prevCameraFlashEnabled && [captureManager hasFlash]) {
    //      flashButton.selected = YES;
    //      if (captureMode == CaptureModePhoto)
    //        [captureManager setFlashMode:AVCaptureFlashModeOn];
    //      else
    //        [captureManager setTorchMode:AVCaptureTorchModeOn];
    //    }
    //    prevCameraFlashEnabled = flashButton.selected;
    //    flashButton.hidden = ![captureManager hasFlash];
    //    self.view.userInteractionEnabled = YES;
    //  }];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = previewView.center;
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeLocked atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            if([[self movieFileOutput] isRecording]){
            //                NSTimeInterval videoDuration = floor([captureManager videoDuration]);
            //                if (fabs(videoDuration-videoDurationInSeconds) > 0.01)
            //                    recordingTimeLabel.text = [self timeStringInMMSS:videoDuration];
            //                videoDurationInSeconds = videoDuration;
            //            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)capture:(id)sender
{
    
    if (captureMode == CaptureModePhoto) {
        // Take Photo
        self.view.userInteractionEnabled = YES;
        //    [captureManager captureStillImageWithCompletion:^(UIImage *image, NSError *error) {
        //      if (image) {
        //        [self savePhoto:image];
        //      }
        //      self.view.userInteractionEnabled = YES;
        //    }];
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            
            
            AVCaptureVideoOrientation orientation = [self avOrientationForDeviceOrientation:[[UIDevice currentDevice] orientation]];
            
            
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
            
            // Flash set to Auto for Still Capture
            // [CameraVC setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (imageDataSampleBuffer)
                {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    //                  [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                    self.view.userInteractionEnabled = YES;
                    [self savePhoto:image];
                }
            }];
        });
        
    }
    else {
        closeButton.hidden = YES;
        // Start Video Recording
        self.view.userInteractionEnabled = NO;
        captureButton.enabled = NO;
        
        dispatch_async([self sessionQueue], ^{
            if (![[self movieFileOutput] isRecording])
            {
                flipButton.hidden  = YES;
                captureModeSwitch.hidden = YES;
                isRecording = YES;
                
                [self setLockInterfaceRotation:YES];
                
                if ([[UIDevice currentDevice] isMultitaskingSupported])
                {
                    // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                    [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                
                AVCaptureVideoOrientation orientation = [self avOrientationForDeviceOrientation:[[UIDevice currentDevice] orientation]];
                
                [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
                
                // Turning OFF flash for video recording
                [CameraVC setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
                
                // Start recording to a temporary file.
                
                //
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docsPath = [paths objectAtIndex:0];
                NSString *outputFilePath = [docsPath stringByAppendingPathComponent:saveFileName];
                //
                
                //              NSString *outputFilePath = [CachedDataPath stringByAppendingPathComponent:@"camera.mov"];   // commented on 15-11
                unlink([outputFilePath UTF8String]);
                [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    myCounter = 0.0;
                    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                             target:self
                                                           selector:@selector(countDown)
                                                           userInfo:nil
                                                            repeats:YES];
                    
                    self.view.userInteractionEnabled = YES;
                    captureButton.selected = YES;
                    captureButton.enabled = YES;
                    recordingTimeLabel.text = [self timeStringInMMSS:0.0];
                    recordingTimeLabel.hidden = NO;
                });
            }
            else
            {
                [[self movieFileOutput] stopRecording];
            }
        });
        
        //    if (!isRecording) {
        //      closeButton.hidden = YES;
        //      flipButton.hidden  = YES;
        //      captureModeSwitch.hidden = YES;
        //      isRecording = YES;
        //      [captureManager startRecordingToPath:recordingPath];
        //    }
        //    else {
        //      [captureManager stopRecording];
        //    }
    }
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        return  AVCaptureVideoOrientationLandscapeRight;
    
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        return AVCaptureVideoOrientationLandscapeLeft;
    
    return AVCaptureVideoOrientationPortrait;
}

-(void)countDown {
    myCounter += 0.1;
    //    if (myCounter == 60) {
    //        [timer invalidate];
    //         [[self movieFileOutput] stopRecording];
    //    }
    int seconds = floorf(myCounter);
    int da = seconds/86400;
    int hh = (seconds%86400)/3600 + da*24;
    int mm = ((seconds%86400)%3600)/60 + hh*60;
    int ss = ((seconds%86400)%3600)%60;
    
    if(mm== 1){
        [timer invalidate];
        [[self movieFileOutput] stopRecording];
    }
    recordingTimeLabel.text =  [NSString stringWithFormat:@"%0.2i : %0.2i : %0.2i",hh , mm, ss];
}
- (void)captureManagerRecordingDidStart
{
    self.view.userInteractionEnabled = YES;
    captureButton.selected = YES;
    captureButton.enabled = YES;
    recordingTimeLabel.text = [self timeStringInMMSS:0.0];
    recordingTimeLabel.hidden = NO;
}

- (void)captureManagerRecordingDidStop
{
    [self handleFinishRecording];  // update UI
    [self saveVideo:[NSURL fileURLWithPath:recordingPath]];
}

- (void)handleFinishRecording
{
    self.view.userInteractionEnabled = YES;
    recordingTimeLabel.hidden = YES;
    captureButton.selected = NO;
    captureButton.enabled = YES;
    closeButton.hidden = NO;
    flipButton.hidden = NO;
    captureModeSwitch.hidden = NO;
    isRecording = NO;
}

- (void)switchToMode:(CaptureMode)mode
{
    if (mode == captureMode)
        return;
    
    NSString *newCaptureSessionPreset;
    
    // Turn Off Flash/Torch
    //  if (flashButton.selected) {
    //    if (captureMode == CaptureModePhoto)
    //      [captureManager setFlashMode:AVCaptureFlashModeOff];
    //    else if (captureMode == CaptureModeVideo)
    //      [captureManager setTorchMode:AVCaptureTorchModeOff];
    //  }
    
    captureMode = mode;
    
    CGPoint devicePoint = previewView.center;
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
    if (captureMode == CaptureModePhoto) {
        // Set Photo Mode
        flashButton.selected = NO;
        [CameraVC setTorchMode:AVCaptureTorchModeOff forDevice:[[self videoDeviceInput] device]];
        
        NSString *strName = [[UIDevice currentDevice] platformString];
        if([strName isEqualToString:@"iPhone 4"] || [strName isEqualToString:@"iPhone 4 (CDMA)"] || [strName rangeOfString:@"iPod"].location != NSNotFound){
            newCaptureSessionPreset = AVCaptureSessionPreset640x480;
        }else{
            newCaptureSessionPreset = AVCaptureSessionPreset1280x720;
        }
        
        [captureButton setImage:[UIImage imageNamed:@"camera_photo"] forState:UIControlStateNormal];
        [captureButton setImage:nil forState:UIControlStateSelected];
        cropButton.hidden = NO;
        topCurtainView.hidden    = !photoCropEnabled;
        bottomCurtainView.hidden = !photoCropEnabled;
        if(isPad){
            previewView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }else{
            if(SCREENSIZE == 480){
                previewView.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }else{
                previewView.videoGravity = AVLayerVideoGravityResizeAspect;
            }
            
        }
        
    }
    else if (captureMode == CaptureModeVideo) {
        // Set Video Mode
        flashButton.selected = NO;
        [CameraVC setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
        NSString *strName = [[UIDevice currentDevice] platformString];
        if([strName isEqualToString:@"iPhone 4"] || [strName isEqualToString:@"iPhone 4 (CDMA)"] || [strName rangeOfString:@"iPod"].location != NSNotFound){
            newCaptureSessionPreset = AVCaptureSessionPreset640x480;
        }else{
            newCaptureSessionPreset = AVCaptureSessionPresetPhoto;
        }
        //newCaptureSessionPreset = AVCaptureSessionPresetMedium;
        [captureButton setImage:[UIImage imageNamed:@"camera_video"] forState:UIControlStateNormal];
        [captureButton setImage:[UIImage imageNamed:@"camera_video_stop"] forState:UIControlStateSelected];
        cropButton.hidden = YES;
        topCurtainView.hidden    = YES;
        bottomCurtainView.hidden = YES;
        previewView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    self.view.userInteractionEnabled = YES;
    
    //  [captureManager setupCaptureSessionWithPreset:newCaptureSessionPreset completion:^{
    //    self.view.userInteractionEnabled = YES;
    //    // Restore Flash/Torch
    //    if (flashButton.selected) {
    //      if (captureMode == CaptureModePhoto)
    //        [captureManager setFlashMode:AVCaptureFlashModeOn];
    //      else
    //        [captureManager setTorchMode:AVCaptureTorchModeOn];
    //    }
    //  }];
}

- (IBAction)crop:(id)sender
{
    photoCropEnabled = !photoCropEnabled;
    cropButton.selected = photoCropEnabled;
    
    topCurtainView.hidden    = !photoCropEnabled;
    bottomCurtainView.hidden = !photoCropEnabled;
}


#pragma mark -

- (void)savePhoto:(UIImage *)photo
{
    
    [captureManager cleanupCaptureSession];
    
    /*
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     [SharedObj showLoadingWithText:@"Processing..."];
     
     [self performAsync:^{
     
     // Fix Orientation
     
     BOOL isBackCamera = ![captureManager isFrontFacingCameraActive];
     
     UIImageOrientation imageOrientation = UIImageOrientationUp;
     if (photo.imageOrientation == UIInterfaceOrientationLandscapeLeft)
     imageOrientation = (isBackCamera ? UIImageOrientationDown : UIImageOrientationUp);
     else if (photo.imageOrientation == UIInterfaceOrientationLandscapeRight)
     imageOrientation = (isBackCamera ? UIImageOrientationUp : UIImageOrientationDown);
     
     UIImage *image = photo;//[UIImage imageWithCGImage:photo.CGImage scale:1.0 orientation:photo.imageOrientation];
     //  image = [image fixOrientation];
     
     // Crop if needed
     
     if (photoCropEnabled) {
     CGFloat maxSize = MAX(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
     // image = [image previewWithSize:CGSizeMake(maxSize, maxSize) interpolationQuality:kCGInterpolationDefault];
     
     image = [self squareImageFromImage:image scaledToSize:maxSize];
     }
     
     [captureManager cleanupCaptureSession];
     
     
     // Save image
     
     [self performInMainThread:^{
     
     SharedObj.sourceImage = image;
     SharedObj.isFromCameraPicture = YES;
     
     [self dismissViewControllerAnimated:YES completion:^{
     //[SharedObj hideLoading];
     
     
     }];
     }];
     }];
     });
     */
}

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)saveVideo:(NSURL *)videoURL
{
    // Save video
    
    BOOL needsTrim = (captureManager.videoDuration > 10.);
    
    if (needsTrim) {
        //TODO: Trim Video
    }
    
    
    [captureManager cleanupCaptureSession];
    
    /*
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     
     NSString *path = [CommonHeaders func_GetDatabasePath];
     
     FMDatabase *database1 = [FMDatabase databaseWithPath:path];
     
     [database1 open];
     
     FMResultSet *results2 = [database1 executeQuery:[NSString stringWithFormat:@"select * from Category where Name = 'com.squaresized.longVideo' AND isPurchased=1"]];
     
     BOOL filterSuccess = NO;
     while ([results2 next]) {
     filterSuccess = YES;
     }
     
     [database1 close];
     
     if(!filterSuccess){
     //  SharedObj.isFromCameraVideo = TRUE;
     
     if(captureManager.videoDuration > 60){
     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
     BOOL openInstagram = [ud boolForKey:@"OpenVideoPro"];
     if (openInstagram == NO){
     [ud setBool:YES forKey:@"OpenVideoPro"];
     [ud synchronize];
     
     [SharedObj showSingleButtonAlertWithTitle:@"In order not to push your phone's performance to the max we've limited videos to 1 minute" :^(NSInteger index) {
     [self dismissViewControllerAnimated:NO completion:^{
     [SharedObj showLoadingWithText:@"Loading..."];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     SharedObj.isFromCameraVideo = TRUE;
     [MPSettings sharedSetting].selectVideo(YES);
     });
     }];
     }];
     }else{
     [self dismissViewControllerAnimated:NO completion:^{
     [SharedObj showLoadingWithText:@"Loading..."];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     SharedObj.isFromCameraVideo = TRUE;
     [MPSettings sharedSetting].selectVideo(YES);
     });
     }];
     }
     }else{
     //            SharedObj.isFromCameraVideo = TRUE;
     //            [self dismissViewControllerAnimated:YES completion:nil];
     [self dismissViewControllerAnimated:NO completion:^{
     [self func_commonVideoInitializeMethod];
     }];
     }
     
     //        [self dismissViewControllerAnimated:YES completion:^{
     //            if(captureManager.videoDuration > 60){
     //                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
     //                BOOL openInstagram = [ud boolForKey:@"OpenVideoPro"];
     //                if (openInstagram == NO){
     //                    [ud setBool:YES forKey:@"OpenVideoPro"];
     //                    [ud synchronize];
     //
     //                    [SharedObj showSingleButtonAlertWithTitle:@"In order not to push your phone's performance to the max we've limited videos to 1 minute" :^(NSInteger index) {
     //
     //                    }];
     //                }
     //            }
     //
     //        }];
     }else{
     [self dismissViewControllerAnimated:NO completion:^{
     [self func_commonVideoInitializeMethod];
     }];
     
     // [self dismissViewControllerAnimated:YES completion:nil];
     }
     });
     
     */
    
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self func_commonVideoInitializeMethod];
    }];
    
    
    //  SharedObj.isFromCameraVideo = YES;
    //  [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)func_commonVideoInitializeMethod{
    
    /*
     
     NSString *path = [CommonHeaders func_GetDatabasePath];
     
     FMDatabase *database1 = [FMDatabase databaseWithPath:path];
     
     [database1 open];
     
     FMResultSet *results2 = [database1 executeQuery:[NSString stringWithFormat:@"select * from Category where Name = 'com.squaresized.longVideo' AND isPurchased=1"]];
     
     BOOL filterSuccess = NO;
     while ([results2 next]) {
     filterSuccess = YES;
     }
     
     [database1 close];
     
     if(!filterSuccess)
     {
     if(captureManager.videoDuration > 10){
     [SharedObj showLoadingWithText:@"Loading..."];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     SharedObj.isFromCameraVideo = TRUE;
     [MPSettings sharedSetting].selectVideo(YES);
     });
     
     }else{
     SharedObj.isStopAdvertise = NO;
     
     [SharedObj showLoadingWithText:@"Processing..."];
     SharedObj.isFromCameraVideo = YES;
     
     NSString *outputPath = [CachedDataPath stringByAppendingPathComponent:@"camera.mov"];
     NSURL *url = [[NSURL alloc] initFileURLWithPath:outputPath];
     SharedObj.strVideoUrl = url;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeNavigation" object:@"Editor"];
     
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
     [SharedObj hideLoading];
     });
     }
     }else{
     SharedObj.isStopAdvertise = NO;
     SharedObj.isFromCameraVideo = YES;
     NSString *outputPath = [CachedDataPath stringByAppendingPathComponent:@"camera.mov"];
     NSURL *url = [[NSURL alloc] initFileURLWithPath:outputPath];
     SharedObj.strVideoUrl = url;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeNavigation" object:@"Editor"];
     }
     
     */
    
   /*
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *dataPath = [docsPath stringByAppendingPathComponent:saveFileName];
    */
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenVideoEditor" object:nil];
    
    //
//     Save the video to the app directory so we can play it later
       /* NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:dataPath]];
        [videoData writeToFile:dataPath atomically:false];*/
    //
}


#pragma mark - CaptureManagerDelegate

- (void)captureManagerDidFailWithError:(NSError *)error
{
    [self handleFinishRecording];
    //  ShowAlert(error.localizedDescription, error.localizedFailureReason);
}

// Preview
- (void)captureManagerPreviewPixelBufferReadyForDisplay:(CVPixelBufferRef)previewPixelBuffer
{
    if ((int32_t)videoResolution.width != captureManager.videoDimensions.width ||
        (int32_t)videoResolution.height != captureManager.videoDimensions.height) {
        videoResolution = CGSizeMake(captureManager.videoDimensions.width, captureManager.videoDimensions.height);
        NSLog(@"videoResolution = %@", NSStringFromCGSize(videoResolution));
        [self layoutForCurrentOrientation];
    }
    
    if (isRecording) {
        NSTimeInterval videoDuration = floor([captureManager videoDuration]);
        if (fabs(videoDuration-videoDurationInSeconds) > 0.01)
            recordingTimeLabel.text = [self timeStringInMMSS:videoDuration];
        videoDurationInSeconds = videoDuration;
    }
}


#pragma mark -

- (CGFloat)interfaceRotationAngleFromDeviceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return M_PI;
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        return -M_PI_2;
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return M_PI_2;
    else
        return 0;
}

- (NSString *)timeStringInMMSS:(double)time
{
    int seconds = floorf(time);
    int da = seconds/86400;
    int hh = (seconds%86400)/3600 + da*24;
    int mm = ((seconds%86400)%3600)/60 + hh*60;
    int ss = ((seconds%86400)%3600)%60;
    
    if(mm == 1){
        
        [captureManager stopRecording];
    }
    
    NSString *s = [NSString stringWithFormat:@"%0.2i : %0.2i", mm, ss];
    return s;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!captureModeSwitch.hidden)
        [captureModeSwitch touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!captureModeSwitch.hidden)
        [captureModeSwitch touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:previewView];
    CGPoint poi = [previewView pointOfInterestForPoint:point];
    // [captureManager focusAtPoint:poi];
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[previewView layer] captureDevicePointOfInterestForPoint:poi];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeLocked atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

@end




