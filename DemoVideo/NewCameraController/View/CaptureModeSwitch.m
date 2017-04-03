

#import "CaptureModeSwitch.h"


@implementation CaptureModeSwitch
@synthesize titles, titlesFont, titlesColor, distanceBetweenTitles, selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self initialyze];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initialyze];
  }
  return self;
}

- (void)initialyze
{
  self.multipleTouchEnabled = NO;
  
  slideView = [[UIView alloc] initWithFrame:self.bounds];
  slideView.backgroundColor = [UIColor clearColor];
  [self addSubview:slideView];
  
  titleLabels = [[NSMutableArray alloc] initWithCapacity:5];
  titlesFont  = [UIFont systemFontOfSize:13];
  titlesColor = [UIColor yellowColor];
  
  distanceBetweenTitles = 24.;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self updateTitles];
}

- (void)setTitles:(NSArray *)titles_
{
  titles = titles_;
  [self updateTitles];
}

- (void)setTitlesFont:(UIFont *)titlesFont_
{
  titlesFont = titlesFont_;
  [self updateTitles];
}

- (void)setTitlesColor:(UIColor *)titlesColor_
{
  titlesColor = titlesColor_;
  for (UILabel *label in titleLabels)
    label.textColor = titlesColor;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex_ animated:(BOOL)animated {
  [self setSelectedIndex:selectedIndex_ animated:animated completion:nil];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex_ animated:(BOOL)animated completion:(void (^)(void))completion
{
  selectedIndex = selectedIndex_;
  
  for (NSInteger i = 0; i < [titleLabels count]; i++)
    if (i == selectedIndex)
    {
      UILabel *label = titleLabels[i];
      CGFloat px = label.frame.origin.x + 0.5*label.frame.size.width;
      
      CGRect r = slideView.bounds;
      r.origin.x = self.bounds.size.width/2 - px;
      
      if (!animated) {
        slideView.frame = r;
        if (completion)
          completion();
      }
      else {
        [UIView animateWithDuration:0.25 animations:^{
          slideView.frame = r;
        } completion:^(BOOL finished) {
          if (completion)
            completion();
        }];
      }
    }
}

- (CGRect)calculateBoundsForTitle:(NSString *)text withFont:(UIFont *)font
{
  if ([text length] == 0 || font == nil)
    return CGRectZero;
  else {
    CGSize size = [text sizeWithFont:font];
    return CGRectMake(0, 0, ceil(size.width), ceil(size.height));
  }
}

- (void)updateTitles
{
  for (UILabel *label in titleLabels) {
    [label removeFromSuperview];
  }
  [titleLabels removeAllObjects];
  
  minSlideValue = 32.;
  
  // Calculate slideView's rect
  
  CGRect rect = self.bounds;
  slideView.frame = rect;
  
  // Update title labels
  
  CGFloat x0 = 0.0;
  
  for (NSInteger i = 0; i < (NSInteger)[titles count]; i++)
  {
    CGRect r = [self calculateBoundsForTitle:titles[i] withFont:titlesFont];
    r.size.width += distanceBetweenTitles;
    r.size.height = rect.size.height;
    r.origin.x = x0;
    
    UILabel *label = [[UILabel alloc] initWithFrame:r];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font      = titlesFont;
    label.textColor = titlesColor;
    label.text      = titles[i];
    [titleLabels addObject:label];
    [slideView addSubview:label];
    
    x0 += r.size.width;
    
    minSlideValue = MIN(minSlideValue, r.size.width*0.5);
  }
  rect.size.width = x0;
  slideView.frame = rect;
  
  [self setSelectedIndex:selectedIndex animated:NO];  // update selection
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  sliding    = YES;
  slideValue = 0.0;
  slideValueAccum = 0.0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (!sliding)
    return;
  
  UITouch *t = [touches anyObject];
  CGPoint p0 = [t previousLocationInView:slideView];
  CGPoint p1 = [t locationInView:slideView];
  
  slideValue += p0.x-p1.x;
  slideValueAccum = MAX(slideValueAccum, MAX(fabs(p1.x-p0.x), fabs(p1.y-p0.y)));
  
  if (fabs(slideValue) > minSlideValue) {
    NSInteger newIndex = selectedIndex;
    if (slideValue > 0.0) {
      if (selectedIndex < titleLabels.count-1)
        newIndex++;
    }
    else {
      if (selectedIndex > 0)
        newIndex--;
    }
    
    __weak id weakSelf = self;
    
    if (newIndex != selectedIndex) {
      sliding = NO;
      [weakSelf setSelectedIndex:newIndex animated:YES completion:^{
        if (self.selectBlock)
          self.selectBlock(selectedIndex, titles[selectedIndex]);
      }];
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  sliding = NO;
  
  // Check for the Tap
  
  if (slideValueAccum < 4.0) {
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:slideView];
    
    // check if point is NOT inside slideView's frame
    if (!CGRectContainsPoint(slideView.bounds, p))
      return;
    
    __weak id weakSelf = self;
    
    for (UILabel *label in titleLabels)
      if (CGRectContainsPoint(label.frame, p)) {
        NSInteger newIndex = [titleLabels indexOfObject:label];
        if (newIndex != selectedIndex) {
          [weakSelf setSelectedIndex:newIndex animated:YES completion:^{
            if (self.selectBlock)
              self.selectBlock(selectedIndex, titles[selectedIndex]);
          }];
        }
        return;
      }
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

@end




