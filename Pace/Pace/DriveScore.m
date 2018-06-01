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
 * rpm 转速分模型
 * acc 加速分模型
 * brake 刹车分模型
 * speed 车速分模型
 * coolant 冷却液分模型
 * aggregated 驾驶行为分值
 */
+ (NSDictionary *)aggregated:(NSArray *)rpmArray acc:(NSArray *)accArray coolant:(NSArray *)coolantArray speed:(NSArray *)speedArray {
    
    DriveScoreModel *rpmModel = [DriveScore rpmScore:rpmArray];
    DriveScoreModel *accModel = [DriveScore accScore:accArray];
    DriveScoreModel *brakeModel = [DriveScore brakeScore:accArray];
    DriveScoreModel *speedModel = [DriveScore speedScore:speedArray];
    DriveScoreModel *coolantModel = [DriveScore coolantScore:coolantArray];
    
    double rpm = rpmModel.score;
    double acceleration = accModel.score;
    double brakeResult = brakeModel.score;
    double speedResult = speedModel.score;
    double coolantResult = coolantModel.score;
    
    double rpmFactor = [DriveScore rpmFactor];
    double accFactor = [DriveScore accFactor];
    double brakeFactor = [DriveScore brakeFactor];
    double speedFactor = [DriveScore speedFactor];
    double coolantFactor = [DriveScore coolantFactor];
    
    double aggregated = rpm * rpmFactor + acceleration * accFactor + brakeResult * brakeFactor + speedResult * speedFactor + coolantResult * coolantFactor;
    
    return @{@"rpm" : rpmModel,
             @"acc" : accModel,
             @"brake" : brakeModel,
             @"speed" : speedModel,
             @"coolant" : coolantModel,
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
 * acceleration >= 0 && acceleration <= 1
 */
+ (BOOL)isAccPositive:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration >= 0 && acceleration <= 1) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 不正常加速
 * acceleration > 1
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
 * acceleration >= -1.0 && acceleration <=0.0
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
 * acceleration < -1.0
 */
+ (BOOL)isBrakeNegative:(double)acceleration {
    
    if (kAccelerationErrorCode == acceleration) return NO;
    if (acceleration < -1.0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 正常转速
 * rpm <= 2250 && rpm >= 0
 */
+ (BOOL)isRpmPositive:(double)rpm {
    
    if (rpm <= 2250 && rpm >= 0) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 不正常转速
 * rpm > 2250
 */
+ (BOOL)isRpmNegative:(double)rpm {
    
    if (rpm > 2250) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 正常温度（冷却液）
 * coolant <= 200 && coolant >= 80
 */
+ (BOOL)isCoolantPositive:(double)coolant {
    
    if (coolant <= 200 && coolant >= 80) {
        return YES;
    }
    return NO;
}

/**
 * 是否为 不正常温度（冷却液）
 * coolant < 80 && coolant >= -200
 */
+ (BOOL)isCoolantNegative:(double)coolant {
    
    if (coolant < 80 && coolant >= -200) {
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
 * 转速得分
 */
+ (DriveScoreModel *)rpmScore:(NSArray *)rpmArray {
    
    double rpmPositive = 0;
    double rpmNegative = 0;
    for (int i=0; i<rpmArray.count; i++) {
        double rpm = [rpmArray[i] doubleValue];
        rpmPositive += [DriveScore isRpmPositive:rpm];
        rpmNegative += [DriveScore isRpmNegative:rpm];
    }
    double rpmCount = rpmPositive + rpmNegative;
    double rpmScore = rpmPositive / rpmCount * 100;
    
    return [[DriveScoreModel alloc] initWithPositive:rpmPositive
                                       negative:rpmNegative
                                          count:rpmCount
                                          score:rpmScore];
}

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
    double accScore = accPositive / accCount * 100;
    
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
    double brakeScore = brakePositive / brakeCount * 100;
    
    return [[DriveScoreModel alloc] initWithPositive:brakePositive
                                       negative:brakeNegative
                                          count:brakeCount
                                          score:brakeScore];
}

/**
 * 冷却液得分
 */
+ (DriveScoreModel *)coolantScore:(NSArray *)coolantArray {
    
    double coolantPositive = 0;
    double coolantNegative = 0;
    for (int i=0; i<coolantArray.count; i++) {
        double coolant = [coolantArray[i] doubleValue];
        coolantPositive += [DriveScore isCoolantPositive:coolant];
        coolantNegative += [DriveScore isCoolantNegative:coolant];
    }
    double coolantCount = coolantPositive + coolantNegative;
    double coolantScore = coolantPositive / coolantCount * 100;
    
    return [[DriveScoreModel alloc] initWithPositive:coolantPositive
                                       negative:coolantNegative
                                          count:coolantCount
                                          score:coolantScore];
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
    double speedScore = speedPositive / speedCount * 100;
    
    return [[DriveScoreModel alloc] initWithPositive:speedPositive
                                       negative:speedNegative
                                          count:speedCount
                                          score:speedScore];
}

#pragma mark - 驾驶行为权重

/**
 * 转速分 权重
 */
+ (double)rpmFactor {
    return 0.3;
}

/**
 * 加速分 权重
 */
+ (double)accFactor {
    return 0.2;
}

/**
 * 刹车分 权重
 */
+ (double)brakeFactor {
    return 0.2;
}

/**
 * 车速分 权重
 */
+ (double)speedFactor {
    return 0.2;
}

/**
 * 冷却液分 权重
 */
+ (double)coolantFactor {
    return 0.1;
}

@end








