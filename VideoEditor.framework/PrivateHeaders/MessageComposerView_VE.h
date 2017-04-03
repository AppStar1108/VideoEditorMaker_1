
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol MessageComposerViewDelegate <NSObject>
// delegate method executed after the user clicks the send button. Message is the message contained within the
// text view when send is pressed
- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;
@optional
// executed whenever the MessageComposerView's frame changes. Provides the frame it is changing to and the animation duration
- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;
// executed whenever the user is typing in the text view
- (void)messageComposerUserTyping:(NSString*)text;
@end

@interface MessageComposerView : UIView<UITextViewDelegate>
@property(nonatomic, weak) id<MessageComposerViewDelegate> delegate;
@property(nonatomic, strong) UITextView *messageTextView;
// alternative initializer that allows the setting of the offset that the MessageComposerView will have
// fromt the keyboard and the bottom of the screen.
- (id)initWithFrame:(CGRect)frame andKeyboardOffset:(NSInteger)offset;
- (id)initWithFrame:(CGRect)frame andKeyboardOffset:(NSInteger)offset andMaxHeight:(CGFloat)maxTVHeight;
- (IBAction)sendClicked:(id)sender;
- (void)scrollTextViewToBottom;
-(void)func_currentTextInputChagned;
-(void)func_changeHeight;

// To avoid exposing the UITextView and attempt to prevent bad practice, startEditing and finishEditing
// are available to become and resign first responder. This means you shouldn't have an excuse to
// do [messageComposerView.messageTextView resignFirstResponder] etc.
- (void)startEditing;
- (void)finishEditing;
@end

