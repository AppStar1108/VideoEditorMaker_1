
#import <UIKit/UIKit.h>
typedef void (^VoidBlock)();

typedef void (^dismissBlock)(int buttonIndex);
typedef void (^CancelBlock)();
typedef void (^PhotoPickedBlock)(UIImage *chosenImage);

#define kPhotoActionSheetTag 10000