//
//  UILabel+Masonry.m
//  NER
//
//  Created by Fangjw on 2017/12/7.
//  Copyright © 2017年 New Energy. All rights reserved.
//

#import "UILabel+Masonry.h"

@implementation UILabel(Masonry)

+(UILabel *)labelWithFont:(UIFont *)font textClolr:(UIColor *)textClolr superView:(UIView *)superView{
    UILabel *label = [UILabel new];
    label.font = font;
    label.numberOfLines=0;
    label.textColor = textClolr;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:label];
    return label;
}

@end
