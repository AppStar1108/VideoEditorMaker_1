
#import <Foundation/Foundation.h>
#import "ATIAPHelper_VE.h"
@interface ATIAPShare : NSObject
@property (nonatomic,strong) ATIAPHelper *iap;

+ (ATIAPShare *) sharedHelper;
+(id)toJSON:(NSString*)json;
@end
