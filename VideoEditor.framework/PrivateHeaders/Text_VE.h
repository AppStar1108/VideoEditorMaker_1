
#import <Foundation/Foundation.h>
#import "ZDStickerView_VE.h"
@class ZDStickerView;
@interface Text : NSObject

@property(assign,nonatomic)CGFloat startTime ,stopTime;
@property(assign,nonatomic)int tag;
@property(strong,nonatomic)ZDStickerView *textImage;
@property(strong,nonatomic)UIImageView *snapImage;

- (id)initWithDictionary:(NSDictionary *)dict;
@end
