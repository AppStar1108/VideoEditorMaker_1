
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SSMediaExporter : NSObject

- (id)initWithMediaItem:(MPMediaItem *)mediaItem;

-(void)exportToFilePath:(NSString *)filePath
             completion:(void (^)(NSURL *exportFileURL))handler;

@end
