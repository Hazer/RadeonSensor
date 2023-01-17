//
//  StatusView.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation
import SwiftUI

struct StatusView: View {
    @StateObject var viewModel: TemperatureViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            Text("GPU")
            Text("T\nE\nM").font(.custom("PixeloidSans-Bold", size: 6.3)).multilineTextAlignment(.center)
            Text(viewModel.temperatureTextUnstyled)
                .updateStyles(fromTemperature: viewModel.temperature)
        }
    }
}

class DummyStatusViewModel: TemperatureViewModel {
    override init() {
        super.init()
        self.temperature = 33
        self.temperatureText = AttributedString("33")
        self.temperatureTextUnstyled = "33"
        self.nrOfGpus = 1
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(viewModel: DummyStatusViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
            .previewDisplayName("StatusBar Icon")
    }
}
