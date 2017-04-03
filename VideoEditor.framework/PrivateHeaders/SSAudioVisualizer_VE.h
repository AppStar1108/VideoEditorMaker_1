
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SSAudioVisualizer : NSObject

- (id)initWithAudioURL:(NSURL *)url;
- (void)renderToPngPath:(NSString *)pngPath;

@property (nonatomic,strong) UIColor *wavesColor;

@end
