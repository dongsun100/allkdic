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

import Carbon

func == (left: Hotkey, right: Hotkey) -> Bool {
    return left.keyCode == right.keyCode && left.modifier == right.modifier
}

func == (left: Modifier, right: Modifier) -> Bool {
    return left.rawValue == right.rawValue
}

@objc class Hotkey: NSObject {

    var keyCode: CGKeyCode = HotkeyUtil.keyCodeForString(" ")
    var modifier: Modifier = .Option | .Command

    var shift: Bool { return self.modifier & Modifier.Shift != nil }
    var control: Bool { return self.modifier & Modifier.Control != nil }
    var option: Bool { return self.modifier & Modifier.Option != nil }
    var command: Bool { return self.modifier & Modifier.Command != nil }

    var dictionaryValue: NSDictionary {
        return [
            "keyCode": NSNumber(unsignedShort: self.keyCode),
            "modifier": self.modifier.rawValue
        ]
    }
    var tupleValue: (Bool, Bool, Bool, Bool, CGKeyCode) {
        return (self.shift, self.control, self.option, self.command, self.keyCode)
    }

    override var description: String {
        var keys = [String]()
        if self.shift { keys.append("Shift") }
        if self.control { keys.append("Control") }
        if self.option { keys.append("Option") }
        if self.command { keys.append("Command") }
        if let string = HotkeyUtil.stringForKeyCode(self.keyCode) {
            keys.append(string)
        }
        return " + ".join(keys)
    }

    convenience init(keyCode: CGKeyCode, modifier: Modifier) {
        self.init()
        self.keyCode = keyCode
        self.modifier = modifier
    }

    convenience init(event: NSEvent) {
        self.init()
        self.keyCode = event.keyCode
        self.NSEventModifier = event.modifierFlags
    }

    convenience init(dictionary: NSDictionary!) {
        self.init()
        if dictionary == nil {
            return
        }
        if let keyCode = dictionary["keyCode"] as? Int {
            self.keyCode = CGKeyCode(keyCode)
        }
        if let modifier = dictionary["modifier"] as? UInt {
            self.modifier = Modifier(rawValue: modifier)
        } else {
            // migrate from legacy versions
            var modifier = Modifier.allZeros
            if let shift = dictionary["shift"] as? Bool {
                modifier |= .Shift
            }
            if let control = dictionary["control"] as? Bool {
                modifier |= .Control
            }
            if let option = dictionary["option"] as? Bool {
                modifier |= .Option
            }
            if let command = dictionary["command"] as? Bool {
                modifier |= .Command
            }
            self.modifier = modifier
        }
    }
}


// MARK: -

extension Modifier {
    static var allValues: [Modifier] {
        return [.Shift, .Control, .Option, .Command]
    }
}

extension EventModifiers {
    static var allValues: [Int] {
        return [shiftKey, controlKey, optionKey, cmdKey]
    }
}

extension NSEventModifierFlags {
    static var allValues: [NSEventModifierFlags] {
        return [.ShiftKeyMask, .ControlKeyMask, .AlternateKeyMask, .CommandKeyMask]
    }
}


// MARK: -

extension Hotkey {

    var CarbonEventModifier: EventModifiers {
        get {
            var flag = 0
            for (i, modifier) in enumerate(Modifier.allValues) {
                if self.modifier & modifier != nil {
                    flag |= EventModifiers.allValues[i]
                }
            }
            return EventModifiers(flag)
        }
        set {
            var flag = Modifier.allZeros
            let raw = Int(newValue)
            for (i, modifier) in enumerate(EventModifiers.allValues) {
                if raw & modifier > 0 {
                    flag |= Modifier.allValues[i]
                }
            }
            self.modifier = flag
        }
    }

    var NSEventModifier: NSEventModifierFlags {
        get {
            var flag = NSEventModifierFlags.allZeros
            for (i, modifier) in enumerate(Modifier.allValues) {
                if self.modifier & modifier != nil {
                    flag |= NSEventModifierFlags.allValues[i]
                }
            }
            return flag
        }
        set {
            var flag = Modifier.allZeros
            for (i, modifier) in enumerate(NSEventModifierFlags.allValues) {
                if newValue & modifier != nil {
                    flag |= Modifier.allValues[i]
                }
            }
            self.modifier = flag
        }
    }

}