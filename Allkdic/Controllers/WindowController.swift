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

class WindowController: NSWindowController, NSWindowDelegate {

    var contentView: NSView {
        get {
            return self.window!.contentView as NSView
        }
        set {
            self.window!.contentView = newValue
        }
    }

    init(windowSize: CGSize = CGSizeZero) {
        let screenSize = NSScreen.mainScreen()!.frame.size
        let rect = CGRectMake(
            (screenSize.width - windowSize.width) / 2,
            (screenSize.height - windowSize.height) / 2,
            windowSize.width,
            windowSize.height
        )
        let mask = NSTitledWindowMask | NSClosableWindowMask
        let window = NSWindow(contentRect: rect, styleMask: mask, backing: .Buffered, defer: false)
        super.init(window: window)

        window.delegate = self
        window.hasShadow = true
        window.contentView = NSView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(sender: AnyObject?) {
        AllkdicManager.sharedInstance().close()
        self.window?.level = Int(CGWindowLevelForKey(Int32(kCGScreenSaverWindowLevelKey))) // NSScreenSaverWindowLevel
        super.showWindow(sender)
    }

}
