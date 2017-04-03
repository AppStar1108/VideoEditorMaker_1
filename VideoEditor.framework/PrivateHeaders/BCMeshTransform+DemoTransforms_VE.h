
#import "BCMeshTransform_VE.h"

@interface BCMeshTransform (DemoTransforms)

+ (instancetype)curtainMeshTransformAtPoint:(CGPoint)point
                                 boundsSize:(CGSize)boundsSize;

+ (instancetype)buldgeMeshTransformAtPoint:(CGPoint)point
                                withRadius:(CGFloat)radius
                                boundsSize:(CGSize)size;

+ (instancetype)shiverTransformWithPhase:(CGFloat)phase magnitude:(CGFloat)magnitude;

+ (instancetype)ellipseMeshTransform;

+ (instancetype)rippleMeshTransform;

@end
