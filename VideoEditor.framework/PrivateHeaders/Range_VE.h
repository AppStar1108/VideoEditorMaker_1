
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Range : NSObject

@property(assign)Float64 StartPos;
@property(assign)Float64 EndPos;
@property(assign)Float64 StartTime;
@property(assign)Float64 EndTime;
@property(assign)BOOL isSlow;
@property(assign)Float64 SlowTime;
@property(nonatomic,retain)UIView *viewRange;
@end
