//
//  MainView.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation
import AppKit
import Cocoa
import SwiftUI

// TODO: Move those vars to a better place
var viewController: NSHostingController<MainView>? = nil
var windowController: NSWindowController? = nil

struct MainView: View {
    @StateObject var viewModel: TemperatureViewModel
    
    var body: some View {
        Text(viewModel.temperatureText)
            .frame(
                minWidth: 200, idealWidth: 300, maxWidth: 650,
                minHeight: 150, idealHeight: 200, maxHeight: 400,
                alignment: .center
            )
    }
    
    static func showWindow() {
        if let window = windowController?.window {
            window.makeKeyAndOrderFront(self)
            return
        }
        
        let mainView = MainView(viewModel: AppDelegate.shared.mainViewModel)
        viewController = NSHostingController(rootView: mainView)
        windowController = NSWindowController(window: NSWindow(contentViewController: viewController!))
        
        if let window = windowController!.window {
            window.title = "GPU Info"
            window.titleVisibility = .visible
            window.titlebarAppearsTransparent = true
            window.animationBehavior = .utilityWindow
            window.styleMask = [.titled, .resizable, .miniaturizable, .closable]
        }
        windowController!.window?.makeKeyAndOrderFront(nil)
        windowController!.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: DummyStatusViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
            .previewDisplayName("MainView")
    }
}
