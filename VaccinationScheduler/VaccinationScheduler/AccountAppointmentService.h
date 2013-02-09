//
//  AccountAppointmentService.h
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/27.
//
//

#import <Foundation/Foundation.h>
@class VaccinationDto,AccountAppointmentDto;
@interface AccountAppointmentService : NSObject

-(id)init;
- (NSArray *)appointmentsDtoWithAccountId:(NSInteger)accountid;
- (void)saveAppointmentWithAccountId:(NSInteger)accountid times:(NSInteger)times  appointmentDate:(NSString *)appointmentDate  consultationDate:(NSString *)consultationDate vaccinationDto:(VaccinationDto *)vcDto;
- (void)updateAppointmentWithCurrentAppointmentDto:(AccountAppointmentDto *)dto newAppointmentDate:(NSString *)appointmentDate  newConsultationDate:(NSString *)consultationDate;
- (void)removeAppointmentWithAppointmentDto:(AccountAppointmentDto *)dto;
- (void)removeAppointmentWithAccountId:(NSInteger)accountId;

// for cal
- (NSArray *)monthDataWithStartYMD:(NSString *)startYmd endYM:(NSString *)endYmd;
@end
