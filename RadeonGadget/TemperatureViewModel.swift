//
//  TemperatureViewModel.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation
import SwiftUI

open class TemperatureViewModel: ObservableObject {
    @Published var temperature: Int = -1
    @Published var temperatureText: AttributedString = AttributedString("-") // TODO: This should be here?? Maybe in UI, but not sure in VM
    @Published var temperatureTextUnstyled: String = "-"
    
    @Published var nrOfGpus: Int = 0
}
