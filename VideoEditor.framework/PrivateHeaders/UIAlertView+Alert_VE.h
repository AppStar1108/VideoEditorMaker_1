
#import <UIKit/UIKit.h>

@interface UIAlertView (Alert)

+ (void)showAlertString:(NSString*)string;
+ (void)showAlertString:(NSString *)message withCompletion:(void (^)(void))completion;
+ (void)showAlertString:(NSString*)string delegate:(id <UIAlertViewDelegate>)delegate;
+ (void)showAlertError:(NSError *)error;

@end
