
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SCSampleBufferHolder : NSObject

@property (assign, nonatomic) CMSampleBufferRef sampleBuffer;

+ (SCSampleBufferHolder *)sampleBufferHolderWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
