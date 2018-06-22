//
//  DriveScore.m
//  AvaCar
//
//  Created by ethan on 17/01/2018.
//  Copyright © 2018 WanGaoJie. All rights reserved.
//

#import "DriveScore.h"
#import <CoreLocation/CoreLocation.h>

@implementation DriveScoreModel

- (instancetype)initWithPositive:(double)pos negative:(double)neg count:(int)cou score:(double)sco {
    
    if (self = [super init]) {
        _positive = pos;
        _negative = neg;
        _count = cou;
        _score = sco;
    }
    return self;
}

@end


@implementation DriveScore

#define kAccelerationErrorCode (-1000)

#pragma mark - API

/**
 * 驾驶行为分析API
 *
 * return dictionary
 * acc 加速分模型
 * brake 刹车分模型
 * speed 车速分模型
 * aggregated 驾驶行为分值
 */
+ (NSDictionary *)aggregated:(NSArray *)speedArray accArray:(NSArray *)accArray {
    
    DriveScoreModel *accModel = [DriveScore accScore:accArray];
    DriveScoreModel *brakeModel = [DriveScore brakeScore:accArray];
    DriveScoreModel *speedModel = [DriveScore speedScore:speedArray];
    
    double acceleration = accModel.score;
    double brakeResult = brakeModel.score;
    double speedResult = speedModel.score;
    
    double accFactor = [DriveScore accFactor];
    double brakeFactor = [DriveScore brakeFactor];
    double speedFactor = [DriveScore speedFactor];
    
    double aggregated = acceleration * accFactor + brakeResult * brakeFactor + speedResult * speedFactor;
    
    return @{@"acc" : accModel,
             @"brake" : brakeModel,
             @"speed" : speedModel,
             @"aggregated" : @(aggregated)};
}

/**
 * 数据转换API
 * 位置数组 -> 加速度数组
 */
+ (NSArray *)transAccelerationWithLocation:(NSArray *)array {
    
    NSMutableArray *accArray = [@[] mutableCopy];
    for (int i = 1; i < array.count; i ++) {
        CLLocation *preLocation = [array objectAtIndex:i - 1];
        CLLocation *curLocation = [array objectAtIndex:i];
        
        double acceleration = [DriveScore getAcceleration:preLocation location:curLocation];
        [accArray addObject:@(acceleration)];
    }
    
    return accArray;
}

#pragma mark - 加速度值计算

/**
 * 计算 加速度值
 * 注意：两次速度的时间戳不正确时，返回kAccelerationErrorCode
 */
+ (double)getAcceleration:(CLLocation *)loc1 location:(CLLocation *)loc2 {
    
    NSTimeInterval time1 = [loc1.timestamp timeIntervalSince1970];
    NSTimeInterval time2 = [loc2.timestamp timeIntervalSince1970];
    if (time2 - time1 <= 0) return kAccelerationErrorCode;
    return (loc2.speed - loc1.speed) * 0.277777777778 / (time2 - time1);
}

#pragma mark - 驾驶行为正常判断

/**
 * 是否为 加速（非刹车）
 * (acceleration > 0)
 */
+ (BOOL)isAcceleration:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration > 0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 正常加速
 * acceleration >= 0 && acceleration <= 2
 */
+ (BOOL)isAccPositive:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration >= 0 && acceleration <= 1.0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 不正常加速
 * acceleration > 2
 */
+ (BOOL)isAccNegative:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration > 1) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 正常刹车
 * acceleration >= -2.0 && acceleration <=0.0
 */
+ (BOOL)isBrakePositive:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration >= -1.0 && acceleration <= 0.0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 不正常刹车
 * acceleration < -2.0
 */
+ (BOOL)isBrakeNegative:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration < -1.0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 正常车速
 * speed <= 100 && speed >= 0
 */
+ (BOOL)isSpeedPositive:(double)speed {
    
    if (speed <= 100 && speed >= 0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 不正常车速
 * speed >= 120
 */
+ (BOOL)isSpeedNegative:(double)speed {
    
    if (speed >= 120) {
        return YES;
    }
    return NO;
}

#pragma mark - 驾驶行为分数计算

/**
 * 加速得分
 */
+ (DriveScoreModel *)accScore:(NSArray *)accArray {
    
    double accPositive = 0;
    double accNegative = 0;
    for (int i=0; i<accArray.count; i++) {
        double acc = [accArray[i] doubleValue];
        accPositive += [DriveScore isAccPositive:acc];
        accNegative += [DriveScore isAccNegative:acc];
    }
    double accCount = accPositive + accNegative;
    double accScore = accCount ? accPositive / accCount * 100 : 0;
    
    return [[DriveScoreModel alloc] initWithPositive:accPositive
                                       negative:accNegative
                                          count:accCount
                                          score:accScore];
}

/**
 * 刹车得分
 */
+ (DriveScoreModel *)brakeScore:(NSArray *)accArray {
    
    double brakePositive = 0;
    double brakeNegative = 0;
    for (int i=0; i<accArray.count; i++) {
        double acc = [accArray[i] doubleValue];
        brakePositive += [DriveScore isBrakePositive:acc];
        brakeNegative += [DriveScore isBrakeNegative:acc];
    }
    double brakeCount = brakePositive + brakeNegative;
    double brakeScore = brakeCount ? brakePositive / brakeCount * 100 : 0;
    
    return [[DriveScoreModel alloc] initWithPositive:brakePositive
                                       negative:brakeNegative
                                          count:brakeCount
                                          score:brakeScore];
}

/**
 * 车速得分
 */
+ (DriveScoreModel *)speedScore:(NSArray *)speedArray {
    
    double speedPositive = 0;
    double speedNegative = 0;
    for (int i=0; i<speedArray.count; i++) {
        double speed = [speedArray[i] doubleValue];
        speedPositive += [DriveScore isSpeedPositive:speed];
        speedNegative += [DriveScore isSpeedNegative:speed];
    }
    double speedCount = speedPositive + speedNegative;
    double speedScore = speedCount ? speedPositive / speedCount * 100 : 0;
    
    return [[DriveScoreModel alloc] initWithPositive:speedPositive
                                       negative:speedNegative
                                          count:speedCount
                                          score:speedScore];
}

#pragma mark - 驾驶行为权重

/**
 * 加速分 权重
 */
+ (double)accFactor {
    return 0.4;
}

/**
 * 刹车分 权重
 */
+ (double)brakeFactor {
    return 0.4;
}

/**
 * 车速分 权重
 */
+ (double)speedFactor {
    return 0.2;
}

@end








