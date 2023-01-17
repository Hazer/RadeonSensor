//
//  AppDelegate.swift
//  RadeonGadget
//
//  Created by Aluveitie on 24.09.21.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainViewModel: MainViewModel = MainViewModel()
    
    var statusBar: StatusBarController?
    
    static var shared: AppDelegate {
        NSApp.delegate as! AppDelegate
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("launching")
        NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        statusBar = StatusBarController.init()
        
        // listInstalledFonts()
    }
    func listInstalledFonts() {
          let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()
          for family in fontFamilies {
              print(family)
              let familyFonts = NSFontManager.shared.availableMembers(ofFontFamily: family)
              if let fonts = familyFonts {
                  for font in fonts {
                    print("\t\(font)")
                  }
              }
          }
      }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

