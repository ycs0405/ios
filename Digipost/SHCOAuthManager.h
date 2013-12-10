//
//  SHCOAuthManager.h
//  Digipost
//
//  Created by Eivind Bohler on 10.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCOAuthManager : NSObject

+ (instancetype)sharedManager;

- (void)authenticateWithCode:(NSString *)code success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
