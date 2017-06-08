//
//  GiftComboNumView.h
//  liveDemo
//
//  Created by Calvin on 17/5/31.
//  Copyright © 2017年 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftComboNumView : UIView

@property (nonatomic ,assign) NSInteger number;/**< 初始化数字 */

/**
 改变数字显示
 
 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger )numberStr;


/**
 获取显示的数字
 
 @return 显示的数字
 */
- (NSInteger)getLastNumber;

@end
