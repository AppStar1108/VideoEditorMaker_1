
#import <UIKit/UIKit.h>

/*
 * Completion handler invoked when user taps a button.
 *
 * @param alertView The alert view being shown.
 * @param buttonIndex The index of the button tapped.
 */
typedef void(^UIAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);

typedef enum {
	UIAlertViewActivityNone = 0,
	UIAlertViewActivityThrobber,
	UIAlertViewActivityProgress,
} UIAlertViewActivityStyle;

/**
 * Category of `UIAlertView` that offers a completion handler to listen to interaction. This avoids the need of the implementation of the delegate pattern.
 *
 * @warning Completion handler: Invoked when user taps a button.
 *
 * typedef void(^UIAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);
 *
 * - *alertView* The alert view being shown.
 * - *buttonIndex* The index of the button tapped.
 */
@interface UIAlertView (Blocks)

/**
 * Shows the receiver alert with the given handler.
 *
 * @param handler The handler that will be invoked in user interaction.
 */
- (void)showWithHandler:(UIAlertViewHandler)handler;


@property (nonatomic) UIAlertViewActivityStyle activityStyle;
@property (nonatomic,readonly) UIActivityIndicatorView *throbberView;
@property (nonatomic,readonly) UIProgressView *progressView;

@end

#define UIALERTVIEW_DISMISS		@[NSLocalizedString(@"Dismiss",nil)]
#define UIALERTVIEW_RETRY			@[NSLocalizedString(@"Cancel",nil),NSLocalizedString(@"Retry",nil)]
#define UIALERTVIEW_CONFIRM		@[NSLocalizedString(@"Cancel",nil),NSLocalizedString(@"Confirm",nil)]

// Shows Alert view with specified type
UIAlertView *UIAlertViewShow(NSString *title,
                             NSString *message,
                             NSArray *buttons,
                             NSInteger cancelIndex,
                             UIAlertViewHandler block);

UIAlertView *UIAlertViewErrorShow(NSError *error,NSArray *buttons,UIAlertViewHandler block);

BOOL UIAlertViewShowOnce(NSString *title, NSString *message, NSArray *buttons,NSString *key, UIAlertViewHandler handler);
