
#import <UIKit/UIKit.h>

//define this handler outside the declaration as in category we cannot add instance variables, in .m file we will associate this with self
typedef void(^UIAlertViewCallBackHandler)(UIAlertView *alertView, NSInteger buttonIndex);

//@interface AlertViewBlocks : NSObject
@interface UIAlertView (AddBlockCallBacksAlertView) <UIAlertViewDelegate>
- (void)showAlerViewFromButtonActionHandler:(UIAlertViewCallBackHandler)handler;
@end

typedef void(^UIActionSheetCallBackHandler) (UIActionSheet *actionSheet, NSInteger buttonIndex);
@interface UIActionSheet (AddBlockCallBacksActionSheet)<UIActionSheetDelegate>
-(void)showActionSheetFromButtonActionHandler:(UIActionSheetCallBackHandler)handler withView:(id)viewID;
@end

typedef void(^UIPickerCallBackHandler) (UIImagePickerController *pickerV, id buttonIndex,BOOL YesOrNo);
@interface UIImagePickerController (AddBlockCallBacksUIImagePicker)<UIImagePickerControllerDelegate>
-(void)showPickerSheetFromButtonActionHandler:(UIPickerCallBackHandler)handler withView:(id)viewID;
@end
