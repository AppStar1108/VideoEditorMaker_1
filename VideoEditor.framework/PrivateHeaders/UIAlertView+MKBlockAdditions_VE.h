
#import <Foundation/Foundation.h>
#import "MKBlockAdditions_VE.h"

@interface UIAlertView (Block) <UIAlertViewDelegate> 
+ (UIAlertView*) alertViewWithTitle:(NSString*) title 
                            message:(NSString*) message;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title 
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title                    
                            message:(NSString*) message 
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(dismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled;

@property (nonatomic, copy) dismissBlock dismissBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;

@end
