//
//  MainWindowController.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 15/12/22.
//

import Cocoa

class MainWindowController: NSWindowController {
    @IBOutlet weak var temperatureLabel: NSTextField!
    
    private var updateTimer: Timer?
    
    private var nrOfGpus: Int = 0
    
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
    
    func drawCompactSingle(label: String, value: String, x: CGFloat, range: TemperatureRange) {
        
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
        temperatureLabel.attributedStringValue = value
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        nrOfGpus = RadeonModel.shared.getNrOfGpus()
        /*if (nrOfGpus < 1) {
            view = NoGpuStatusbarView()
        } else if (nrOfGpus == 1) {
            view = SingleGpuStatusbarView()
        } else {
            let multiview = MultiGpuStatusbarView()
            multiview.nrOfGpus = nrOfGpus
            view = multiview
        }*/
        setup()
        
        if (nrOfGpus > 0) {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
                self.update()
            })
        }
        
    }
    
    
    func update() {
        let temps = RadeonModel.shared.getTemps(nrOfGpus: nrOfGpus)
        
        self.temps = temps

        temperatureLabel.setNeedsDisplay(temperatureLabel.frame)
        //view.setNeedsDisplay(view.frame)
    }
    
    func dismiss() {
        updateTimer?.invalidate()
    }
    
}
