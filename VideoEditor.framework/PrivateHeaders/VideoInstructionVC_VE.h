
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GlobalData_VE.h"

@interface VideoInstructionVC : UIViewController{
    UIView *mainView;
    UIImageView *imageView;
    NSURLConnection *connection;
    NSMutableData *data;
}

-(void)initWithImageAtURL:(NSURL*)url;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData* data;
@end
