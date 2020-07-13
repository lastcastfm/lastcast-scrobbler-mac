//
//  ContentView.swift
//  Lastcast for Mac
//
//  Created by Philipp Defner on 23.05.20.
//  Copyright © 2020 Philipp Defner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                IconHeader().frame(height: 50).padding()
            }
            TabView {
                ApplePodcastsTab().tabItem {
                    Text("Apple Podcasts")
                }
                OvercastTab().tabItem {
                    Text("Overcast")
                }
            }
            .padding()
            VStack(alignment: .leading) {
                Text("API Endpoint")
                    .font(.headline)
                Text("This is the endpoint where the events will be sent to. The defaults are usually fine.").fixedSize(horizontal: false, vertical: true).font(.caption)
                TextField("https://lastcast.fm/api/v1/scrobbles", text: $userSettings.endpoint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.listRowInsets(EdgeInsets())
                .padding()
            VStack(alignment: .leading) {
                Text("Token")
                    .font(.headline)
                Text("Enter your personal access token here. You can find it in your User Settings on Lastcast.fm.").fixedSize(horizontal: false, vertical: true).font(.caption)
                TextField("Enter your API Token...", text: $userSettings.apiToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .listRowInsets(EdgeInsets())
            .padding()
            VStack(alignment: .leading) {
                Button("Scrobble to Lastcast", action: scrobble).padding()
            }
        }
        .frame(width: 500, height: 550)
    }
}

struct ApplePodcastsTab: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Library Location").font(.headline)
            Text("Lastcast is reading the Apple Podcasts library at the following location. If it should change this needs to be updated.").fixedSize(horizontal: false, vertical: true).font(.caption)
            TextField("some/path", text: $userSettings.applePodcastslibraryPath).textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding()
    }
}

struct OvercastTab: View {
    var body: some View {
        Text("Overcast")
    }
}

struct IconHeader: View {
    var body: some View {
        Image("lastcast-app-icon").resizable()
            .aspectRatio(contentMode: .fit)
            .scaledToFit()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
