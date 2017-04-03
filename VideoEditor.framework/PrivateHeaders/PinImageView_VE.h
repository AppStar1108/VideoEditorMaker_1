
#import <UIKit/UIKit.h>

struct PinTransform {
  float rotation;
  float scale;
  CGPoint translate;
};
typedef struct PinTransform PinTransform;

@interface PinImageView : UIImageView

@property (nonatomic,assign) float rotation;
@property (nonatomic,assign) float scale;
@property (nonatomic,assign) CGPoint translate;

- (void)setPinEnable:(BOOL)enable;
- (void)applyTrasformation;
- (void)reset;

@end
