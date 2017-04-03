
#import <Foundation/Foundation.h>
#import "UIView+Frame_VE.h"

@protocol ImageToolDelegate;

@interface MyNewImage : UIImageView <UIGestureRecognizerDelegate>{
    UIButton *deleteControl;
}

@property (nonatomic,strong) UIImageView *imgMain;

@property (nonatomic,strong) UIButton *deleteControl;

@property (retain, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (retain, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationRecognizer;
@property (retain, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchRecognizer;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;

@property(nonatomic,assign) NSUInteger gestureCount;
@property(nonatomic,assign) CGPoint touchCenter;
@property(nonatomic,assign) CGPoint rotationCenter;
@property(nonatomic,assign) CGPoint scaleCenter;
@property(nonatomic,assign) CGFloat scale;

@property(nonatomic,assign) CGSize cropSize;
@property(nonatomic,assign) CGFloat outputWidth;
@property(nonatomic,assign) CGFloat minimumScale;
@property(nonatomic,assign) CGFloat maximumScale;
@property (readwrite) BOOL isPurchased;

+ (void)setActiveImage:(MyNewImage*)view;

- (id)initWithImage:(UIImage *)image;

@property (weak, nonatomic) id <ImageToolDelegate> delegate;

@property (nonatomic) CGPoint prevPoint;

@end

@protocol ImageToolDelegate <NSObject>
@required
@optional
- (void)ImageToolDidBeginEditing:(MyNewImage *)sticker;
- (void)ImageToolDidClose:(MyNewImage *)sticker;
-(void)ImageToolDidEndEditing:(MyNewImage*)sticker;


@end

