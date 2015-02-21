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

import AppKit
import SimpleCocoaAnalytics

private let _sharedInstance = AllkdicManager()

class AllkdicManager: NSObject {

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
    let popover = NSPopover()

    let contentViewController = ContentViewController()
    let preferenceWindowController = PreferenceWindowController()
    let aboutWindowController = AboutWindowController()

    class func sharedInstance() -> AllkdicManager {
        return _sharedInstance
    }

    override init() {
        super.init()
        NSEvent.addGlobalMonitorForEventsMatchingMask(.LeftMouseUpMask | .LeftMouseDownMask) { _ in self.close() }
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { event in
            let hotkey = Hotkey(event: event)
            NSNotificationCenter.defaultCenter().postNotificationName(LocalHotkeyDidPressNotification, object: hotkey)
            return event
        }
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "open",
            name: GlobalHotkeyDidPressNotification,
            object: nil
        )
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func attachToStatusBar() {
        let icon = NSImage(named: "statusicon_default")
        icon?.setTemplate(true)
        self.statusItem.image = icon

        self.statusItem.target = self
        self.statusItem.action = "open"

        let button = self.statusItem.valueForKey("_button") as NSButton
        button.focusRingType = .None
        button.setButtonType(.PushOnPushOffButton)

        self.popover.contentViewController = self.contentViewController
    }

    func open() {
        if self.popover.shown {
            self.close()
            return
        }

        let button = self.statusItem.valueForKey("_button") as NSButton
        button.state = NSOnState

        NSApp.activateIgnoringOtherApps(true)
        self.popover.showRelativeToRect(NSZeroRect, ofView: button, preferredEdge: NSMaxYEdge)
        self.contentViewController.updateHotKeyLabel()
        self.contentViewController.focusOnTextArea()

        NSNotificationCenter.defaultCenter().postNotificationName(PopoverDidOpenNotification, object: nil)

        AnalyticsHelper.sharedInstance().recordScreenWithName("AllkdicWindow")
        AnalyticsHelper.sharedInstance().recordCachedEventWithCategory(
            AnalyticsCategory.Allkdic,
            action: AnalyticsAction.Open,
            label: nil,
            value: nil
        )
    }

    func close() {
        if !self.popover.shown {
            return
        }

        let button = self.statusItem.valueForKey("_button") as NSButton
        button.state = NSOffState

        self.popover.close()

        AnalyticsHelper.sharedInstance().recordCachedEventWithCategory(
            AnalyticsCategory.Allkdic,
            action: AnalyticsAction.Close,
            label: nil,
            value: nil
        )
    }
}
