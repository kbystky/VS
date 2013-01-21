//
//  AccountSettingCell.m
//  VaccinationScheduler
//
//  Created by  on 12/12/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountSettingCell.h"

@implementation AccountSettingCell
@synthesize accountInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
