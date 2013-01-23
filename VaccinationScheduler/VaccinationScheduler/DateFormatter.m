//
//  DateFormatter.m
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/23.
//
//

#import "DateFormatter.h"

@implementation DateFormatter

+(NSDate *)dateFormatWithString:(NSString *)string
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd"];

    return [df dateFromString:string];
}

+(NSString *)dateFormatWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy/MM/dd";
    return [df stringFromDate:date];
}

@end
