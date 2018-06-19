//
//  DriveScore.h
//  AvaCar
//
//  Created by ethan on 17/01/2018.
//  Copyright © 2018 WanGaoJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriveScoreModel: NSObject
/**
 * 正常个数
 */
@property (assign, nonatomic) double positive;
/**
 * 不正常个数
 */
@property (assign, nonatomic) double negative;
/**
 * 总个数（正常个数+不正常个数）
 */
@property (assign, nonatomic) int count;
/**
 * 得分
 */
@property (assign, nonatomic) double score;

- (instancetype)initWithPositive:(double)pos
                        negative:(double)neg
                           count:(int)cou
                           score:(double)sco;

@end


@interface DriveScore : NSObject
/**
 * 驾驶行为分析API
 *
 * return dictionary
 * acc 加速分模型
 * brake 刹车分模型
 * speed 车速分模型
 * aggregated 驾驶行为分值
 */
+ (NSDictionary *)aggregated:(NSArray *)speedArray accArray:(NSArray *)accArray;

/**
 * 数据转换API
 * 位置数组 -> 加速度数组
 */
+ (NSArray *)transAccelerationWithLocation:(NSArray *)array;

@end











