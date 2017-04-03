
#import <UIKit/UIKit.h>

@interface UIImage (Utility)

+ (UIImage*)fastImageWithData:(NSData*)data;
+ (UIImage*)fastImageWithContentsOfFile:(NSString*)path;

- (UIImage*)deepCopy;

- (UIImage*)resize:(CGSize)size;
- (UIImage*)aspectFit:(CGSize)size;
- (UIImage*)aspectFill:(CGSize)size;
- (UIImage*)aspectFill:(CGSize)size offset:(CGFloat)offset;
-(UIImage*)aspectFillRound:(CGSize)size;

- (UIImage*)crop:(CGRect)rect;

- (UIImage*)maskedImage:(UIImage*)maskImage;

- (UIImage*)gaussBlur:(CGFloat)blurLevel;       //  {blurLevel | 0 ≤ t ≤ 1}

+ (UIImage *)snapshotOfView:(UIView *)view scale:(float)scaleFactor;
+ (UIImage *)snapshotOfView:(UIView *)view rect:(CGRect)contentRect scale:(float)scaleFactor;
+ (UIImage *)snapshotOfLayer:(CALayer *)layer rect:(CGRect)contentRect scale:(float)scaleFactor;

@end
