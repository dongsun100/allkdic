// The MIT License (MIT)
//
// Copyright (c) 2013 Suyeol Jeon (http://xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Carbon/Carbon.h>

#import "Allkdic-Swift.h"
#import "HotkeyUtil.h"
#import "Notifications.h"

@implementation HotkeyUtil

EventHotKeyRef eventRef;

+ (Hotkey *)savedHotkey
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKey.HotKey];
    if (!data) {
        return nil;
    }
    return [[Hotkey alloc] initWithDictionary:data];
}

+ (void)registerHotkeyEventHandler
{
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(&globalHotkeyEventHandler, 1, &eventType, NULL, NULL);

    Hotkey *hotkey = [self savedHotkey];
    if (!hotkey) {
        NSLog(@"No saved hotkey.");
        hotkey = [[Hotkey alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:hotkey.dictionaryValue forKey:UserDefaultsKey.HotKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSLog(@"Register hotkey: %@", hotkey);

    EventHotKeyID eventId;
    eventId.signature = 'allk'; // 4byte character
    eventId.id = 0;

    RegisterEventHotKey(hotkey.keyCode,
                        hotkey.CarbonEventModifier,
                        eventId,
                        GetApplicationEventTarget(),
                        0,
                        &eventRef);
    [[NSNotificationCenter defaultCenter] postNotificationName:HotkeyDidRegisterNotification object:hotkey];
}

+ (void)unregisterHotkeyEventHandler
{
    NSLog(@"Unregister Hotkey");
    UnregisterEventHotKey(eventRef);
}

OSStatus globalHotkeyEventHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    Hotkey *hotkey = [HotkeyUtil savedHotkey];
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalHotkeyDidPressNotification object:hotkey];
    return noErr;
}


#pragma mark -

+ (NSString *)stringForKeyCode:(CGKeyCode)keyCode
{
//    TISCopyCurrentASCIICapableKeyboardInputSource()
    TISInputSourceRef currentKeyboard = TISCopyCurrentASCIICapableKeyboardInputSource();
    CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);

    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount length;

    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &length,
                   chars);
    CFRelease(currentKeyboard);
    return [NSString stringWithCharacters:chars length:length];
}

+ (CGKeyCode)keyCodeForString:(NSString *)string
{
    static NSMutableDictionary *keyMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyMap = [NSMutableDictionary dictionaryWithCapacity:128];
        @autoreleasepool {
            for (int i = 0; i < 128; i++) {
                NSString *str = [self stringForKeyCode:i];
                if (str) {
                    keyMap[str] = @(i);
                }
            }
        }
    });

    NSNumber *keyCode = keyMap[string];
    if (keyCode) {
        return [keyCode intValue];
    }
    return UINT16_MAX;
}

@end
