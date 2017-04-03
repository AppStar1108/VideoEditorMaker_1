
#import <UIKit/UIKit.h>
#import "SPGripViewBorderView_VE.h"
#import "BCMeshTransformView_VE.h"

typedef enum {
    ZDSTICKERVIEW_BUTTON_NULL,
    ZDSTICKERVIEW_BUTTON_DEL,
    ZDSTICKERVIEW_BUTTON_RESIZE,
    ZDSTICKERVIEW_BUTTON_CUSTOM,
    ZDSTICKERVIEW_BUTTON_MAX
} ZDSTICKERVIEW_BUTTONS;

@protocol ZDStickerViewDelegate;

@interface ZDStickerView : BCMeshTransformView
{
    SPGripViewBorderView *borderView;
   // AppDelegate *appDelegate;
}
@property (nonatomic) float deltaAngle;
@property (assign, nonatomic) UIView *contentView1;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) BOOL preventsCustomButton; //default = YES
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (readwrite) BOOL isPurchased;

+ (void)setActiveStickerView:(ZDStickerView*)view;

@property (weak, nonatomic) id <ZDStickerViewDelegate> delegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustmomHandle;
- (void)hideCustomHandle;
- (void)setButton:(ZDSTICKERVIEW_BUTTONS)type image:(UIImage*)image;

@end

@protocol ZDStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidEndEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidClose:(ZDStickerView *)sticker;
- (void)stickerViewDidStartTextEditing:(ZDStickerView *)sticker;
#ifdef ZDSTICKERVIEW_LONGPRESS
- (void)stickerViewDidLongPressed:(ZDStickerView *)sticker;
#endif
- (void)stickerViewDidCustomButtonTap:(ZDStickerView *)sticker;
@end


