//
//  Modifier.h
//  Allkdic
//
//  Created by 전수열 on 2/21/15.
//  Copyright (c) 2015 Joyfl. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, Modifier) {
    Shift = 1 << 0,
    Control = 1 << 1,
    Option = 1 << 2,
    Command = 1 << 3,
};
