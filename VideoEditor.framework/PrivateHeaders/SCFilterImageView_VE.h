
#import "SCImageView_VE.h"
#import "SCFilter_VE.h"

@interface SCFilterImageView : SCImageView

/**
 The filter to apply when rendering. If nil is set, no filter will be applied
 */
@property (strong, nonatomic) SCFilter *__nullable filter;

@end
