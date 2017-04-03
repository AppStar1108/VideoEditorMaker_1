
#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVAsset.h>

@interface Video : NSObject

@property(nonatomic,strong)NSURL *videoURL;
@property(strong,nonatomic)NSMutableArray *arryRange;
@property(strong,nonatomic)NSMutableArray *arryClips;
@property (nonatomic)CMTime StartTimeAudio,EndTimeAudio;
@property (readwrite) NSTimeInterval musicTimeInterval;
@property (readwrite) NSTimeInterval musicTime;
@property(assign)NSURL *AudioURL;
@property(assign)AVURLAsset *AudioAsset;
@property(strong,nonatomic)NSMutableDictionary *dictAudio;
@end
