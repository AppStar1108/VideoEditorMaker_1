
#import <UIKit/UIKit.h>
#import "CLCircleView_VE.h"
#import "UIView+Frame_VE.h"
#import "SPGripViewBorderView_VE.h"

@protocol CLStickerToolDelegate;

@interface CLStickerView : UIView{
    SPGripViewBorderView *borderView;
}
@property (readwrite) CGFloat scaleValue;
+ (void)setActiveStickerView:(CLStickerView*)view;
-(UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame transparentInsets:(UIEdgeInsets)insets;
- (UIImageView*)imageView;
- (id)initWithImage:(UIImage *)image;
- (void)setScale:(CGFloat)scale;
@property (strong, nonatomic) id <CLStickerToolDelegate> delegate;
@end

@protocol CLStickerToolDelegate <NSObject>
@required
@optional
- (void)CLStickerToolDidBeginEditing:(CLStickerView *)sticker;
- (void)CLStickerToolDidClose:(CLStickerView *)sticker;
-(void)CLStickerToolDidEndEditing:(CLStickerView*)sticker;
@end

