//
//  PopupMenuView.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation
import SwiftUI

struct PopupView: View {
    private let onDismissAction: (() -> Void)?
    init(dismiss: @escaping () -> Void) {
        onDismissAction = dismiss
    }
    
    var body: some View {
        VStack {
            Button(action: {
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
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(dismiss: {})
            .previewLayout(PreviewLayout.sizeThatFits)
            .previewDisplayName("Popop Menu")
    }
}
