
#import <AVFoundation/AVFoundation.h>

@interface SSAudioPlayer : AVAudioPlayer

- (void)playAtTime:(NSTimeInterval)time withDuration:(NSTimeInterval)duration;
- (void)stop;

@end
