
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class BCMeshTransform;

@interface BCMeshBuffer : NSObject

@property (nonatomic, readonly) GLuint VAO;
@property (nonatomic, readonly) GLsizei indiciesCount;

- (void)setupOpenGL;

- (void)fillWithMeshTransform:(BCMeshTransform *)transform
                positionScale:(GLKVector3)positionScale;

@end
