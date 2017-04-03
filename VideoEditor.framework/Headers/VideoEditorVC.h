
#define VEFilter        @"VEFilter"
#define VEAdjust        @"VEAdjust"
#define VECrop          @"VECrop"
#define VEMusic         @"VEMusic"
#define VERecord        @"VERecord"
#define VETrim          @"VETrim"
#define VEText          @"VEText"
#define VEEnhance       @"VEEnhance"
#define VEOrientation   @"VEOrientation"
#define VEBorder        @"VEBorder"
#define VESticker       @"VESticker"
#define VEFrames        @"VEFrames"
#define VESpeed         @"VESpeed"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@protocol VideoEditorSDKDelegate <NSObject>
@optional
-(void)videoEditorSDKFinishedWithUrl:(NSURL *)url;
-(void)videoEditorSDKCanceled;
-(void)videoEditorSDKDidSelectCategory:(NSString*)category;
@end

@interface VideoEditorVC : UIViewController
{
    UIButton *btnCancelStickers;
    int  globalStickerTag;
    int  mainStickerTag;
    int  globalTextTag;
    int  mainTextTag;
    int  globalMusicTag;
    int  mainMusicTag;
    AVMutableAudioMix *audioMix;

    IBOutlet UIButton *btnSticker;
    IBOutlet UIImageView *imgAlpha;
    
    IBOutlet UILabel *lblRange;
    IBOutlet UILabel *lblTextRange;
    UITapGestureRecognizer *gestureSingleTap,*gestureDoubleTap;
    BOOL isFromLabel;
    UITextView *textView;


}
@property (nonatomic,strong) NSString* showStickers;
@property (strong, nonatomic) UIActivityIndicatorView *stickerActivity;
@property (nonatomic, weak) id<VideoEditorSDKDelegate> delegate;
@property (nonatomic,strong) NSURL *videoPath;
@property (nonatomic,strong) NSString *clientKey;
@property (nonatomic,strong) NSString *clientSecretKey;
@property (nonatomic,strong) NSArray *excludedFunctionalities;
@property (nonatomic,strong) NSMutableArray *arrShapesTags;
@property (nonatomic,strong) NSMutableArray *arrArtworkTags;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imojiViewBottomContant;

@end
