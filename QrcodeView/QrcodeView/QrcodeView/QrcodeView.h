//
//  QrcodeView.h
//  QrcodeView
//
//  Created by Fangjw on 2017/12/13.
//  Copyright © 2017年 Fangjw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QrcodeView : UIView

/** 初始化 */
-(instancetype)initWithFrame:(CGRect)frame scanImg:(UIImage *)scanImg lineImg:(UIImage *)lineImg;

/** 是否创建头部 */
-(void)createTopView:(NSString *)TopStr backImg:(UIImage *)backImg;

/** 头部返回事件 */
@property (nonatomic) dispatch_block_t backBlock;

@end
