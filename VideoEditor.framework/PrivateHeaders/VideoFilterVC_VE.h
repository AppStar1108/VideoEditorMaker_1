
#import <UIKit/UIKit.h>
#import "SSMovieMaker_VE.h"
#import "SSAudioPlayer_VE.h"
#import "SSPlayerView_VE.h"
#import "SimpleEditor_VE.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SCSwipeableFilterView_VE.h"
#import "SCPlayer_VE.h"

@protocol VideoFilterDelegate <NSObject>
@required
@optional
-(void)musicDoneClicked;
@end

@interface VideoFilterVC : UIViewController <AVAudioPlayerDelegate>
{
    
    BOOL isPause;
     SSAudioPlayer *musicPlayer;
    NSTimeInterval pixelInSecond;
      NSTimeInterval videoLength, musicLength;
    BOOL isNotDone;
    BOOL isOldFileExists;
    NSURL *oldAudioFileUrl;

    AVPlayer *mainPlayer;
    NSURL *FinalVideoURL;

    NSTimer *timer;
    NSTimer *stopTimer;
    AVURLAsset* audioAsset;
}
@property (strong, nonatomic) id <VideoFilterDelegate> delegate;
@property(nonatomic,strong)SimpleEditor *objSimple;
@property (nonatomic,assign) NSURL *videoFileUrl;
@property (nonatomic) CGAffineTransform layerTransform;
@property (nonatomic,strong) UIImage *imgPattern;
@property (nonatomic,strong) NSString *strLastSelectedFilter;
@property (readwrite) int lastSelectedFilter;
@property (nonatomic,assign) SSMovieMaker_VE *movieMaker;
@property (nonatomic,strong) AVMutableComposition *composition;
@property (strong, nonatomic) IBOutlet SCSwipeableFilterView *playerView;

@property (nonatomic,strong) MPMediaItem *selectedItem;

@property (nonatomic,strong) NSString *strFrom;

@property (readwrite) BOOL isBlurBackground;
@property (nonatomic,strong)SCPlayer *player;
@end
