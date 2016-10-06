//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NSString+RandomNumber.h"

@implementation NSString (RandomNumber)

+ (NSString *)randomNumberString
{
    return [NSString stringWithFormat:@"%u", arc4random() % UINT32_MAX];
}

+ (int32_t)secureRandom {
    int32_t randomNumber = 0;
    return SecRandomCopyBytes(kSecRandomDefault, 4, (uint8_t*) &randomNumber);
    //return randomNumber;
}

+ (NSString *)secureRandomString {
    return [NSString stringWithFormat:@"%i",[NSString secureRandom]];
}

@end
