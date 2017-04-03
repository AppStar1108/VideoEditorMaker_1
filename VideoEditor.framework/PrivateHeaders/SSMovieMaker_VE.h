
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Common-header.h"
#import "GlobalData_VE.h"
#import "Sticker_VE.h"
#import "Text_VE.h"

@interface SSMovieMaker_VE : NSObject
{
  NSURL   *videoURL, *audioURL;
  float   audioVolume, musicVolume;
  UIImage *overlayImage;
  
  AVMutableAudioMix *audioMix;
  
  AVAssetExportSession *exportSession;
  float exportProgress;
}
@property(nonatomic, strong) NSURL *videoURL, *audioURL;
@property(nonatomic, assign) float audioVolume;
@property(nonatomic, assign) BOOL isColor;
@property(nonatomic, assign) NSTimeInterval audioOffset;
@property(nonatomic, strong) UIImage *overlayImage;
@property(nonatomic, readonly) AVMutableAudioMix *audioMix;
@property(nonatomic, strong) UIImage *markImage;
@property(nonatomic, strong) UIFont *markFont;
@property(nonatomic, strong) UIColor *markColor;
@property (nonatomic,strong) UIImage *patternImage;
@property (nonatomic,assign) CGAffineTransform layerTransform;

+ (void)imagePreviewFromVideoURL:(NSURL *)videoURL
                      completion:(void (^)(UIImage *image))completion;

- (AVMutableComposition *)makeComposition;

- (CGAffineTransform)transformFromOrientationWithVideoSize:(CGSize)naturalSize scale:(float)scale;

+ (void)makeVideoFromImage:(UIImage *)image
            toVideoURL:(NSURL *)videoURL
                  size:(CGSize)size
              duration:(CMTime)duration;

- (void)saveToFile:(NSString *)filePath
            preset:(NSString *)presetName
          progress:(void (^)(float value))progress
        completion:(void (^)(BOOL success))completion;

- (void)saveToFilewithoutWatermark:(NSString *)filePath
            preset:(NSString *)presetName
          progress:(void (^)(float value))progress
        completion:(void (^)(BOOL success))completion;

- (void)saveToSquareFile:(NSString *)filePath
                  preset:(NSString *)presetName
                progress:(void (^)(float value))progress
              completion:(void (^)(BOOL success))completion;

-(void)saveToFileForOrientation:(NSString *)filePath preset:(NSString *)presetName progress:(void (^)(float))progress completion:(void (^)(BOOL))completion;

- (void)saveToFile:(NSString *)filePath
            preset:(NSString *)presetName
       composition:(AVMutableComposition*)composition
          progress:(void (^)(float value))progress
        completion:(void (^)(BOOL success))completion;

@end




