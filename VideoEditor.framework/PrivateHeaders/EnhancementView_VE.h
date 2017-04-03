//
//  EnhancementView.h
//  VideoFilter
//
//  Created by Admin on 17/12/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalData_VE.h"

typedef void(^EnhanceHandler)(UIView *EnhanceView, NSInteger buttonIndex);

@protocol EnhancementViewViewDelegate <NSObject>
@required
@optional
-(void)EnhancementDidSelectFilterAtIndex:(int)index;
@end

@interface EnhancementView : UIView
- (void)showInView:(UIView *)view withhandler:(EnhanceHandler)handler;

@property (strong,nonatomic)NSMutableArray *arrFilter;
@property (strong, nonatomic) id <EnhancementViewViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) UIImage *img;
@property (assign,nonatomic) int index;
@property (weak, nonatomic) IBOutlet UIButton *btnHiDef;
@property (weak, nonatomic) IBOutlet UIButton *btnPortrait;
@property (weak, nonatomic) IBOutlet UIButton *btnScenery;
@property (weak, nonatomic) IBOutlet UIButton *btnFood;
@property (weak, nonatomic) IBOutlet UIButton *btnNight;
@end
