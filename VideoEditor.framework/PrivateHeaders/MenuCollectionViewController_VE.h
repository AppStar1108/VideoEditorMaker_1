
#import <UIKit/UIKit.h>
#import "MenuCollectionViewCell_VE.h"

@protocol MenuDelegate <NSObject>
@optional
-(void)getSelectedMenu:(int)menuIndex;
-(void)getSelectedCategoryName:(NSString*)categoryName;
@end

@interface MenuCollectionViewController : UICollectionViewController
@property (nonatomic, weak) id<MenuDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *menuCollectionView;
@property (nonatomic) CGFloat musicX, musicY;

-(void)func_refreshCategories;
@end
