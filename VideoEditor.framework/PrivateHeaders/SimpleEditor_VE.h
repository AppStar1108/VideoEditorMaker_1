
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import "Range_VE.h"
#import "Common-header.h"
#import "GlobalData_VE.h"

@interface SimpleEditor : NSObject 
{	
	// Configuration
	
	NSArray *_clips;			// array of AVURLAssets
	NSArray *_clipTimeRanges;	// array of CMTimeRanges stored in NSValues.
	
	AVURLAsset *_commentary;
	CMTime _commentaryStartTime;
	CMTime _transitionDuration;
	
	NSString *_titleText;
	
	// Composition objects.
	
	AVComposition *_composition;
	AVVideoComposition *_videoComposition;
	AVAudioMix *_audioMix;
	
	AVPlayerItem *_playerItem;
	AVSynchronizedLayer *_synchronizedLayer;
    BOOL isPlayBack,isPortarait;
}

// Set these properties before building the composition objects.
@property (nonatomic, retain) NSArray *clips;
@property (nonatomic, retain) NSArray *clipTimeRanges;

@property (nonatomic, retain) AVURLAsset *commentary;
@property (nonatomic) CMTime commentaryStartTime,commentaryEndTime;
@property (nonatomic, retain) NSArray *audioClips;

@property (nonatomic, retain) NSString *titleText;


// Build the composition, videoComposition, and audioMix. 
// If the composition is being built for playback then a synchronized layer and player item are also constructed.
// All of these objects can be retrieved all of these objects with the accessors below.
// Calling buildCompositionObjectsForPlayback: will get rid of any previously created composition objects.
- (void)buildCompositionObjectsForPlayback:(BOOL)forPlayback;

@property (nonatomic, readonly, retain) AVComposition *composition;
@property (nonatomic, readonly, retain) AVVideoComposition *videoComposition;
@property (nonatomic, readonly, retain) AVAudioMix *audioMix;

- (void)getPlayerItem:(AVPlayerItem**)playerItemOut andSynchronizedLayer:(AVSynchronizedLayer**)synchronizedLayerOut;
// The synchronized layer contains a layer tree which is synchronized with the provided player item.
// Inside the layer tree there is a playerLayer along with other layers related to titling.

- (AVAssetImageGenerator*)assetImageGenerator;
- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName;


@end
