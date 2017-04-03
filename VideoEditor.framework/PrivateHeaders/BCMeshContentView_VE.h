
#import <UIKit/UIKit.h>

@interface BCMeshContentView : UIView

@property (nonatomic, copy) void (^changeBlock)(void);
@property (nonatomic, copy) void (^tickBlock)(CADisplayLink *);

- (instancetype)initWithFrame:(CGRect)frame
                  changeBlock:(void (^)(void))changeBlock
                    tickBlock:(void (^)(CADisplayLink *))tickBlock;
- (void)displayLinkTick:(CADisplayLink *)displayLink;

@end
