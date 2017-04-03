
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BCMeshTexture : NSObject

@property (nonatomic, readonly) GLuint texture;

- (void)setupOpenGL;
- (void)renderView:(UIView *)view;

@end
