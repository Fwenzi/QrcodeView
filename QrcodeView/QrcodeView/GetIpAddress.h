//
//  GetIpAddress.h
//  QrcodeView
//
//  Created by Fangjw on 2018/1/3.
//  Copyright © 2018年 Fangjw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetIpAddress : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (BOOL)isValidatIP:(NSString *)ipAddress;

+ (NSDictionary *)getIPAddresses;

@end
