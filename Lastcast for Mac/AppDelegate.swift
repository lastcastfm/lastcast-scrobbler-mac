//
//  AppDelegate.swift
//  Lastcast for Mac
//
//  Created by Philipp Defner on 23.05.20.
//  Copyright © 2020 Philipp Defner. All rights reserved.
//

import Cocoa
import SwiftUI
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let settings = UserSettings()      
        let contentView = ContentView().environmentObject(settings)
        
        // Create the window and set the content view. 
        window = NSWindow( 
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        SUUpdater.shared()?.checkForUpdatesInBackground()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    // applicationDidFinishLaunching is running after viewControllers are initialized, so we have to register everything here before
    override init() {
        let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
        let path = homeDirURL.relativePath + "/Library/Group Containers/243LU875E5.groups.com.apple.podcasts/Documents/MTLibrary.sqlite"
                 
        // Set default values
        UserDefaults.standard.register(defaults: ["endpoint" : "https://lastcast.fm/api/v1/scrobbles"])
        UserDefaults.standard.register(defaults: ["apple_podcasts_library_path" : path])
    }

}

extension AppDelegate {
    @IBAction func checkForUpdates(_ sender: AnyObject?) {
        SUUpdater.shared()?.checkForUpdates(nil)
    }
}
