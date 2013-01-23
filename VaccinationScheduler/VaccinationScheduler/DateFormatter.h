//
//  DateFormatter.h
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/23.
//
//

#import <Foundation/Foundation.h>

@interface DateFormatter : NSObject

+(NSDate *)dateFormatWithString:(NSString *)string;
+(NSString *)dateFormatWithDate:(NSDate *)date;
@end
