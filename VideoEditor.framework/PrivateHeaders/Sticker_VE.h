
#import <Foundation/Foundation.h>
#import "MyNewImage_VE.h"

@interface Sticker : NSObject<NSCoding>

@property(strong,nonatomic)UIImage *snapImage;
@property(assign,nonatomic)CGFloat startTime ,stopTime;
@property(assign,nonatomic)int tag;
@property(strong,nonatomic)MyNewImage *stickerImage;

- (id)initWithDictionary:(NSDictionary *)dict;
+(NSMutableDictionary *)getDict:(Sticker *)sticker;

@end
