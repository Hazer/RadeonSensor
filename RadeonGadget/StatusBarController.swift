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


fileprivate class StatusbarView: NSView {
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

enum TemperatureRange {
    case unknown
    case cool
    case normal
    case high
    case dangerous
}

fileprivate class SingleGpuStatusbarView: StatusbarView {
    
    override func draw(_ dirtyRect: NSRect) {
        guard (NSGraphicsContext.current?.cgContext) != nil else { return }
        
        let tempRange: TemperatureRange
        let temp: String
        if (temps.count == 0) {
            temp = "-"
            tempRange = TemperatureRange.unknown
        } else if (temps[0] > 125) {
            temp = "INV"
            tempRange = TemperatureRange.dangerous
            NSLog("Found invalid temperature: %u", temps[0])
        } else {
            temp = "\(temps[0])º"
            tempRange = range(forTemperature: temps[0])
        }
        
        drawTitle(label: "GPU", x: 0)
        drawCompactSingle(label: "TEM", value: (temp), x: 35, range: tempRange)
    }
}

func range(forTemperature temp: Int) -> TemperatureRange {
    let range: TemperatureRange
    switch temp {
    case 0...37:
        range = .cool
    case 38...77:
        range = .normal
    case 78...87:
        range = .high
    default:
        range = .dangerous
    }
    return range
}

fileprivate class MultiGpuStatusbarView: StatusbarView {
    
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

fileprivate class NoGpuStatusbarView: StatusbarView {
    
    override func draw(_ dirtyRect: NSRect) {
        guard (NSGraphicsContext.current?.cgContext) != nil else { return }
        
        drawTitle(label: "GPU NOT FOUND", x: 0)
    }
}

class StatusBarController {
    private var statusItem: NSStatusItem!
    fileprivate var view: StatusbarView!
    
    private var popover: NSPopover
    
    private var updateTimer: Timer?
    
    private var nrOfGpus: Int
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.isVisible = true

        nrOfGpus = RadeonModel.shared.getNrOfGpus()
        if (nrOfGpus < 1) {
            view = NoGpuStatusbarView()
            statusItem.length = 110
        } else if (nrOfGpus == 1) {
            view = SingleGpuStatusbarView()
            statusItem.length = 70
        } else {
            let multiview = MultiGpuStatusbarView()
            multiview.nrOfGpus = nrOfGpus
            view = multiview
            statusItem.length = CGFloat((35 + (nrOfGpus * 40) - 5))
        }
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
            view.frame = statusBarButton.bounds
            statusBarButton.wantsLayer = true
            statusBarButton.addSubview(view)
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
        
        if (nrOfGpus > 0) {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
                self.update()
            })
        }
    }
    
    func update() {
        let temps = RadeonModel.shared.getTemps(nrOfGpus: nrOfGpus)
        
        view.temps = temps

        view.setNeedsDisplay(view.frame)
    }
    
    func dismiss() {
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

struct PopupView: View {
    private let onDismissAction: (() -> Void)?
    init(dismiss: @escaping () -> Void) {
        onDismissAction = dismiss
    }
    
    var body: some View {
        Button(action: {
            /*let windowController = MainWindowController(window: NSWindow(
                contentRect: NSMakeRect(100, 100, NSScreen.main!.frame.width/2, NSScreen.main!.frame.height/2),
                styleMask: [.titled, .resizable, .miniaturizable, .closable],
                backing: .buffered,
                defer: false
            ))
                                   
            windowController.showWindow(AppDelegate.shared)*/
            MainView.showWindow()
            if let dismiss = onDismissAction {
                dismiss()
            }
        }) {
            Text("Show panel").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Button(action: {
            exit(0)
            //NSApplication.shared.terminate(self)
        }) {
            Text("Exit").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
            
    }
}

var viewController: NSHostingController<MainView>? = nil

var windowController: NSWindowController? = nil

struct MainView: View {
    @StateObject var viewModel: MainViewModel  = MainViewModel()
    
    var body: some View {
        Text(viewModel.temperatureText).frame(width: 300, height: 300, alignment: .center)
    }
    
    static func showWindow() {
        if let window = windowController?.window {
            window.makeKeyAndOrderFront(self)
            return
        }
        
        viewController = NSHostingController(rootView: MainView())
        windowController = NSWindowController(window: NSWindow(contentViewController: viewController!))
        
        if let window = windowController!.window {
            window.title = "GPU Info"
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.animationBehavior = .utilityWindow
            window.styleMask = [.titled, .resizable, .miniaturizable, .closable]
        }
        windowController!.window?.makeKeyAndOrderFront(nil)
        windowController!.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

public class MainViewModel: ObservableObject {
  @Published var temperature: Int = -1
  @Published var temperatureText = AttributedString("-")
    
    @Published var nrOfGpus: Int = 0
    
    private var updateTimer: Timer?
    
    private var temps: [Int] = []
    
    deinit {
        dismiss()
    }
    
    
    init() {
        nrOfGpus = RadeonModel.shared.getNrOfGpus()
        
        /*if (nrOfGpus < 1) {
            view = NoGpuStatusbarView()
            statusItem.length = 110
        } else if (nrOfGpus == 1) {
            view = SingleGpuStatusbarView()
            statusItem.length = 70
        } else {
            let multiview = MultiGpuStatusbarView()
            multiview.nrOfGpus = nrOfGpus
            view = multiview
            statusItem.length = CGFloat((35 + (nrOfGpus * 40) - 5))
        }*/
        
        if (nrOfGpus > 0) {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
                self.update()
            })
        }
    }
    
    func update() {
        let temps = RadeonModel.shared.getTemps(nrOfGpus: nrOfGpus)
        
        self.temps = temps

        updateTempText()
    }
    
    func updateTempText() {
        let tempRange: TemperatureRange
        let temp: String
        if (temps.count == 0) {
            temp = "-"
            tempRange = TemperatureRange.unknown
        } else if (temps[0] > 125) {
            temp = "INV"
            tempRange = TemperatureRange.dangerous
            NSLog("Found invalid temperature: %u", temps[0])
        } else {
            temp = "\(temps[0])º"
            tempRange = range(forTemperature: temps[0])
        }
        self.temperatureText = AttributedString(temp)
        updateFontStyle(range: tempRange)
    }
    
    func dismiss() {
        updateTimer?.invalidate()
    }
    
    func updateFontStyle(range: TemperatureRange) {
        switch range {
        case .cool:
            coolTempFont()
        case .normal:
            normalTempFont()
        case .high:
            highTempFont()
        case .dangerous:
            dangerousTempFont()
        case .unknown:
            regularFont()
        }
    }
    
    func regularFont() {
        temperatureText.font = Font.system(size: 14, weight: .regular)
        temperatureText.foregroundColor = NSColor.labelColor
    }
    
    func coolTempFont() {
        temperatureText.font = Font.system(size: 14, weight: .regular)
        temperatureText.foregroundColor = NSColor(hex: "#1EA4FF", alpha: 1.0)
    }
    
    func normalTempFont() {
        temperatureText.font = Font.system(size: 14, weight: .regular)
        temperatureText.foregroundColor = NSColor(hex: "#45B795", alpha: 1.0)
    }
    
    func highTempFont() {
        temperatureText.font = Font.system(size: 14, weight: .semibold)
        temperatureText.foregroundColor = .orange
    }
    
    func dangerousTempFont() {
        temperatureText.font = Font.system(size: 14, weight: .bold)
        temperatureText.foregroundColor = .red
    }
}
