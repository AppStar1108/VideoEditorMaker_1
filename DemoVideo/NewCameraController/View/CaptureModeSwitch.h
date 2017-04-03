

#import <UIKit/UIKit.h>


@interface CaptureModeSwitch : UIView
{
  UIView          *slideView;
  NSMutableArray  *titleLabels;
  
  CGFloat         slideValue, minSlideValue, slideValueAccum;
  BOOL            sliding;
}
@property(nonatomic, strong) NSArray *titles;  // array of NSString to set
@property(nonatomic, strong) UIFont  *titlesFont;
@property(nonatomic, strong) UIColor *titlesColor;
@property(nonatomic, assign) CGFloat distanceBetweenTitles;  // default 24.

@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, copy) void (^selectBlock)(NSInteger index, NSString *title);

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end
