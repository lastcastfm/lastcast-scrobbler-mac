//
//  UserSettings.swift
//  Lastcast for Mac
//
//  Created by Philipp Defner on 09.06.20.
//  Copyright © 2020 Philipp Defner. All rights reserved.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var endpoint: String {
        didSet {
            UserDefaults.standard.set(endpoint, forKey: "endpoint")
        }
        willSet(newValue) {
            UserDefaults.standard.set(newValue, forKey: "endpoint")
        }
    }
    
    @Published var apiToken: String {
        didSet {
            UserDefaults.standard.set(apiToken, forKey: "api_token")
        }
        willSet(newValue) {
            UserDefaults.standard.set(newValue, forKey: "api_token")
        }
    }
    
    @Published var applePodcastslibraryPath: String {
        didSet {
            UserDefaults.standard.set(applePodcastslibraryPath, forKey: "apple_podcasts_library_path")
        }
        willSet(newValue) {
            UserDefaults.standard.set(newValue, forKey: "apple_podcasts_library_path")
        }
    }
    
    init() {
        // Set values based on what's in the UserDefaults
        self.endpoint = UserDefaults.standard.string(forKey: "endpoint") ?? "https://lastcast.fm/api/v1/scrobbles"
        self.apiToken = UserDefaults.standard.string(forKey: "api_token") ?? ""
        self.applePodcastslibraryPath = UserDefaults.standard.string(forKey: "apple_podcasts_library_path") ?? ""
    }
}
