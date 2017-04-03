
#import <Foundation/Foundation.h>

@interface SCProcessingQueue : NSObject

@property (assign, nonatomic) NSUInteger maxQueueSize;

- (void)startProcessingWithBlock:(id(^)())processingBlock;

- (void)stopProcessing;

- (id)dequeue;

@end
