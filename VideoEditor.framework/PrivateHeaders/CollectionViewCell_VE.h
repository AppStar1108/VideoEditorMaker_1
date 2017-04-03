
#import <UIKit/UIKit.h>
#import "KNCirclePercentView.h"

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;

@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *stickerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *patternImageView;

@property (weak, nonatomic) IBOutlet UILabel *lblTextName;
@property (weak, nonatomic) IBOutlet UIImageView *DownloadImageView;
@property (weak, nonatomic) IBOutlet KNCirclePercentView *ProgressHud;

@property (weak, nonatomic) IBOutlet UILabel *lblFilterName;

@end
