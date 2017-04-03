

#import "CapturePreviewView.h"


@implementation CapturePreviewView

+ (Class)layerClass {
  return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
  return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setSession:(AVCaptureSession *)session {
  [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (NSString *)videoGravity {
  return [(AVCaptureVideoPreviewLayer *)self.layer videoGravity];
}

- (void)setVideoGravity:(NSString *)videoGravity {
  [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:videoGravity];
}

- (CGPoint)pointOfInterestForPoint:(CGPoint)point {
  return [(AVCaptureVideoPreviewLayer *)self.layer captureDevicePointOfInterestForPoint:point];
}

@end
