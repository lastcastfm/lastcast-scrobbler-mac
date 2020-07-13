//
//  Submitting.swift
//  Lastcast for Mac
//
//  Created by Philipp Defner on 23.05.20.
//  Copyright © 2020 Philipp Defner. All rights reserved.
//

import Foundation

struct ScrobbleAPIResponse: Codable {
    var success: [Int64]?
    var error: [String]?
    var unmatched: [Event]?
}

struct ScrobbleModel: Codable {
    var client: String
    var events: [Event]
}

struct Event: Codable {
    var percentage: Int64
    var timestamp: Date
    var matching_hints: MatchingHints
}

struct MatchingHints: Codable {
    var itunes: String?
    var episode_url: String?
}

struct Episode: Codable {
    var external_id: String
    var percentage: Int64
    var timestamp: String
}

func postToAPI(episodes: [Episode]) {
    // Unwrap endpoint
    let configEndpoint: String? = UserDefaults.standard.string(forKey: "endpoint")
    let endpoint: String
    guard configEndpoint != nil else { return }
    endpoint = configEndpoint!
    
    // Unwrap api token
    let configApiToken: String? = UserDefaults.standard.string(forKey: "api_token")
    let apiToken: String
    guard configApiToken != nil else { return }
    apiToken = configApiToken!
    
    let url = URL(string: endpoint)
    //    let url = URL(string: "http://localhost:80/post")
    //    let url = URL(string: "http://localhost:3000/api/v1/scrobbles")
    guard let requestUrl = url else { fatalError() }
    
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    
    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("ApiKey-v1 " + apiToken, forHTTPHeaderField: "Lastcast-Api-Token")
    
    // Set Basic Auth
    let loginString = String(format: "%@:%@", "lastcast", "last2020cast")
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    
    
    let RFC3339DateFormatter = DateFormatter()
    RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
    RFC3339DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    var eventsToSubmit = [Event]();
    for episode in episodes {
        let date = RFC3339DateFormatter.date(from: episode.timestamp)
        guard let eventTimestamp = date else {
            print("error converting timestamp")
            continue
        }
        
        let matchingHints = MatchingHints(itunes: episode.external_id);
        eventsToSubmit.append(Event(
            percentage: episode.percentage,
            timestamp: eventTimestamp,
            matching_hints: matchingHints
        ))
    }
    
    
    let newScrobble = ScrobbleModel(client: "Lastcast for Mac",
                                    events: eventsToSubmit)
       
    // Custom encoder so the Date can be unmarshalled in the backend
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    encoder.dateEncodingStrategy = .formatted(RFC3339DateFormatter)
    decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)
    let jsonData = try! encoder.encode(newScrobble)
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error took place \(error)")
            return
        }
        if data == nil {
            print("Error data empty")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            if httpResponse.statusCode == 200 {
                guard let data = data else { return }
                do {
                    let resp = try decoder.decode(ScrobbleAPIResponse.self, from: data)
                    print("Success", resp.success!.count)
                    print(resp.unmatched!.count)
                    print(resp.error!.count)
                } catch {
                    print(error)
                }
            } else {
                print(httpResponse.statusCode)
            }
        }
    }
    task.resume()
}
