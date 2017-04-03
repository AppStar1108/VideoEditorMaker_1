
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SCIOPixelBuffers : NSObject

@property (readonly, nonatomic) CMTime time;

@property (readonly, nonatomic) CVPixelBufferRef inputPixelBuffer;

@property (readonly, nonatomic) CVPixelBufferRef outputPixelBuffer;

+ (SCIOPixelBuffers *)IOPixelBuffersWithInputPixelBuffer:(CVPixelBufferRef)inputPixelBuffer outputPixelBuffer:(CVPixelBufferRef)outputPixelBuffer time:(CMTime)time;

@end
