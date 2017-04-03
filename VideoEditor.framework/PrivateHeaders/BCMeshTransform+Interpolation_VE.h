
#import "BCMeshTransform_VE.h"

@interface BCMeshTransform (PrivateInterpolation)

- (BOOL)isCompatibleWithTransform:(BCMeshTransform *)otherTransform error:(NSError **)error;
- (BCMeshTransform *)interpolateToTransform:(BCMeshTransform *)otherTransform withProgress:(double)progress;

@end
