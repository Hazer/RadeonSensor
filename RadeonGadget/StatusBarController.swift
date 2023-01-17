//
//  StatusBarController.swift
//  Aureal
//
//  Copyright © 2021 Aluveitie All rights reserved.
//

import Foundation
import AppKit
import Cocoa
import SwiftUI
import CoreGraphics

protocol StatusbarView {
    var temps: [Int] { get set }
    func setup ()

}

// TODO: remove it when fully unused
@available(*, deprecated, message: "Migrate this to MainViewModel and SwiftUI rendering")
fileprivate class StatusbarNSView: NSView, StatusbarView {
    private var normalLabel: [NSAttributedString.Key : NSObject]?
    private var compactLabel: [NSAttributedString.Key : NSObject]?
    private var normalValue: [NSAttributedString.Key : NSObject]?
    private var coolTempValue: [NSAttributedString.Key : NSObject]?
    private var normalTempValue: [NSAttributedString.Key : NSObject]?
    private var highTempValue: [NSAttributedString.Key : NSObject]?
    private var dangerousTempValue: [NSAttributedString.Key : NSObject]?
    private var compactValue: [NSAttributedString.Key : NSObject]?
    
    var temps: [Int] = []
    
    
    func setup() {
        let compactLH: CGFloat = 6
        
        let p = NSMutableParagraphStyle()
        p.minimumLineHeight = compactLH
        p.maximumLineHeight = compactLH
        
        compactLabel = [
            NSAttributedString.Key.font: NSFont.init(name: "Monaco", size: 7.3)!,
            NSAttributedString.Key.foregroundColor: NSColor.labelColor,
            NSAttributedString.Key.paragraphStyle: p
        ]
        
        normalValue = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.regular),
            NSAttributedString.Key.foregroundColor: NSColor.labelColor,
        ]
        
        coolTempValue = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.regular),
            NSAttributedString.Key.foregroundColor: NSColor(hex: "#1EA4FF", alpha: 1.0)
        ]
        
        normalTempValue = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.regular),
            NSAttributedString.Key.foregroundColor: NSColor(hex: "#45B795", alpha: 1.0)
        ]
        
        highTempValue = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.semibold),
            NSAttributedString.Key.foregroundColor: NSColor.orange
        ]
        
        dangerousTempValue = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.bold),
            NSAttributedString.Key.foregroundColor: NSColor.red
        ]
        
        compactValue = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: NSFont.Weight.semibold),
            NSAttributedString.Key.foregroundColor: NSColor.labelColor,
        ]
        
        normalLabel = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13, weight: NSFont.Weight.regular),
            NSAttributedString.Key.foregroundColor: NSColor.labelColor,
        ]
    }
    
    func drawTitle(label: String, x: CGFloat) {
        let attributedString = NSAttributedString(string: label, attributes: normalLabel)
        attributedString.draw(at: NSPoint(x: 0, y: 2.5))
    }
    
    func drawCompactSingle(label: String, value: String, x: CGFloat, range: TemperatureRange) {
        let attributedString = NSAttributedString(string: label, attributes: compactLabel)
        attributedString.draw(in: NSRect(x: x, y: -4.5, width: 7, height: frame.height))
        
        let attrs: [NSAttributedString.Key : NSObject]?
        switch range {
        case .cool:
            attrs = coolTempValue
        case .normal:
            attrs = normalTempValue
        case .high:
            attrs = highTempValue
        case .dangerous:
            attrs = dangerousTempValue
        case .unknown:
            attrs = normalValue
        }
        
        let value = NSAttributedString(string: value, attributes: attrs)
        value.draw(at: NSPoint(x: x + 10, y: 2.5))
    }
}

@available(*, deprecated, message: "Migrate this to MainViewModel and SwiftUI rendering")
fileprivate class ASingleGpuStatusbarView: NSHostingView<StatusView>, StatusbarView {
    // TODO: This already uses internally SwiftUI, but we can improve things further and remove this whole class if we rewrite the calling code
    
    var temps: [Int] {
        get {
            return AppDelegate.shared.mainViewModel.temps
        }
        set {
            
        }
    }
    
    func setup() {
        
    }
    
    convenience init() {
        self.init(rootView: StatusView(viewModel: AppDelegate.shared.mainViewModel))
    }
}

@available(*, deprecated, message: "Migrate this to MainViewModel and SwiftUI rendering")
fileprivate class MultiGpuStatusbarView: StatusbarNSView {
    
    var nrOfGpus: Int = 0;
    
    override func draw(_ dirtyRect: NSRect) {
        guard (NSGraphicsContext.current?.cgContext) != nil else { return }
               
        drawTitle(label: "GPU", x: 0)
        
        for i in 1...nrOfGpus {
            let tempRange: TemperatureRange
            let temp: String
            if (i > temps.count || temps[i-1] == 255) {
                temp = "-"
                tempRange = TemperatureRange.unknown
            } else if temps[i-1] > 125 {
                temp = "INV"
                tempRange = TemperatureRange.dangerous
                NSLog("Found invalid temperature for GPU %u: %u", i, temps[0])
            } else {
                temp = "\(temps[i-1])º"
                tempRange = range(forTemperature: temps[i-1])
            }
            drawCompactSingle(label: String(format:"GP%d", i), value: temp, x: CGFloat(35 + (i-1)*40), range: tempRange)
        }
    }
}

@available(*, deprecated, message: "Migrate this to SwiftUI rendering")
fileprivate class NoGpuStatusbarView: StatusbarNSView {
    
    override func draw(_ dirtyRect: NSRect) {
        guard (NSGraphicsContext.current?.cgContext) != nil else { return }
        
        drawTitle(label: "GPU NOT FOUND", x: 0)
    }
}

class StatusBarController {
    private var statusItem: NSStatusItem!
    fileprivate var view: StatusbarView!
    
    private var popover: NSPopover
    
    @available(*, deprecated, message: "Remove when fully migrated to SwiftUI")
    private var updateTimer: Timer?
    
    @available(*, deprecated, message: "Remove when fully migrated to SwiftUI")
    private var nrOfGpus: Int
    
    private var displayUpdator: DisplayUpdator?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.isVisible = true

        nrOfGpus = RadeonModel.shared.getNrOfGpus()
        if (nrOfGpus < 1) {
            //view = NoGpuStatusbarView()
            statusItem.length = 110
        } else if (nrOfGpus == 1) {
            //view = ASingleGpuStatusbarView()
            statusItem.length = 76
        } else {
            //let multiview = MultiGpuStatusbarView()
            //multiview.nrOfGpus = nrOfGpus
            //view = multiview
            statusItem.length = CGFloat((35 + (nrOfGpus * 40) - 5))
        }
        view = ASingleGpuStatusbarView()
        // TODO: Implement multigpu and error StatusViews in SwiftUI, but let the UI switch the components itself, don't do it externally
        view.setup()
        
        popover = NSPopover.init()
        let popupView = PopupView(dismiss: {
            if (self.popover.isShown) {
                self.popover.performClose(self)
            }
        })
        popover.contentSize = NSSize(width: 120, height: 32)
        popover.contentViewController = NSHostingController(rootView: popupView)
        
        if let statusBarButton = statusItem.button {
            (view as! NSView).frame = statusBarButton.bounds
            statusBarButton.wantsLayer = true
            statusBarButton.addSubview(view as! NSView)
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
        
        if (nrOfGpus > 0) {
            //displayUpdator = DisplayUpdator(target: self, updateCallback: #selector(step)) // TODO: Use it to fetch data fast once in main app? Or just timer?
            self.updateView()
            self.updateData()
            //updateTimer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true, block: { _ in
            //    self.updateData()
            //    self.updateView()
            //})
        }
    }
    
    @objc func step(displaylink: DisplayLink) {
        updateData()
    }
    
    @available(*, deprecated, message: "Migrate this to MainViewModel and SwiftUI rendering")
    func updateData() {
        let temps = RadeonModel.shared.getTemps(nrOfGpus: nrOfGpus)
        view.temps = temps
    }
    
    func updateView() {
        let view = self.view as! NSView
        view.setNeedsDisplay(view.frame)
    }
    
    func dismiss() {
        displayUpdator?.invalidate()
        updateTimer?.invalidate()
        NSStatusBar.system.removeStatusItem(statusItem!)
        statusItem = nil
    }
    
    @objc func togglePopover(sender: AnyObject) {
        if (popover.isShown) {
            popover.performClose(sender)
        } else {
            if let statusBarButton = statusItem.button {
                popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            }
        }
    }
}

@objc class DisplayUpdator: NSObject {
    var updateCallback: Selector?
    let displayLink: DisplayLink
    
    init(target: AnyObject, updateCallback: Selector) {
        self.updateCallback = updateCallback
        displayLink = DisplayLink(target: target,
                                        selector: updateCallback)
        
        displayLink.add(to: RunLoop.current,
                        forMode: RunLoop.Mode.default)
     
    }
    
    @objc func invalidate() {
        displayLink.invalidate()
        updateCallback = nil
    }
    
}
