//
//  AccountAppointmentService.h
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/27.
//
//

#import <Foundation/Foundation.h>
@class VaccinationDto;
@interface AccountAppointmentService : NSObject

-(id)init;
- (NSArray *)appointmentsDtoWithAccountId:(NSInteger)accountid;
- (void)saveAppointmentWithAccountId:(NSInteger)accountid times:(NSInteger)times  appointmentDate:(NSString *)appointmentDate  consultationDate:(NSString *)consultationDate vaccinationDto:(VaccinationDto *)vcDto;
@end
