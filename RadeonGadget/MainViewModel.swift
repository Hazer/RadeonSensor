//
//  MainViewModel.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation
import AppKit
import Cocoa
import SwiftUI

public class MainViewModel: TemperatureViewModel {
    private var updateTimer: Timer?
    
     var temps: [Int] = []
    
    deinit {
        dismiss()
    }
    
    override init() {
        super.init()
        super.nrOfGpus = RadeonModel.shared.getNrOfGpus()
        
        // TODO: MultiGPU/NoGPU views
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
        
        if (super.nrOfGpus > 0) {
            self.update()
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true, block: { _ in
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
        // TODO: Clean this later, I'll probably mix multiGPU code here in a new data structure
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
        self.temperature = temps.first ?? -1
        self.temperatureTextUnstyled = temp
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
    
    // TODO: - Improve on those methods, probably there's a better way
    
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
