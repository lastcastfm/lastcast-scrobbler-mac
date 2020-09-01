//
//  Collecting.swift
//  Lastcast for Mac
//
//  Created by Philipp Defner on 23.05.20.
//  Copyright © 2020 Philipp Defner. All rights reserved.
//

import Foundation
import SQLite

//func printConfiguration() {
//    print(UserDefaults.standard.string(forKey: "endpoint"))
//    print(UserDefaults.standard.string(forKey: "api_token"))
//}

func scrobble() {
    // Create temporary directory
    let fileManager = FileManager.default
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                    isDirectory: true)
    
    // Source URL, should later be the Podcasts.app container
    let libraryPath = UserDefaults.standard.string(forKey: "apple_podcasts_library_path")
    let fileURL = URL(fileURLWithPath: libraryPath!)
        
    let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
    let tempFilePath = temporaryDirectoryURL.appendingPathComponent("MTLibrary_lastcast_copy.sqlite")
    if fileExists{
        do {
            try FileManager.default.removeItem(at: tempFilePath)
        } catch {
            print("couldn't find file, so don't have to remove anything")
        }
        do {
            try fileManager.copyItem(at: fileURL, to: tempFilePath)
        }
        catch let error as NSError {
            print("something went wrong when copying to temp directory \(error)")
        }
    }
    let tempFileExists = FileManager.default.fileExists(atPath: tempFilePath.path)
    if tempFileExists{
        do {
            // https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#executing-arbitrary-sql
            let db = try Connection(tempFilePath.absoluteString)
            let stmt = try db.prepare("""
            WITH played_episodes AS (
                SELECT (
                    CASE
                        WHEN (episode.ZPLAYHEAD / episode.ZDURATION) * 100 > 96
                            THEN 100
                        WHEN ((episode.ZPLAYHEAD / episode.ZDURATION) * 100 = 0 AND episode.ZPLAYCOUNT > 0)
                            THEN 100
                        WHEN episode.ZDURATION = 0
                            THEN 100
                        ELSE (episode.ZPLAYHEAD / episode.ZDURATION) * 100 END)   AS percentage
                     , datetime(episode.ZLASTDATEPLAYED, 'unixepoch', '31 years') AS last_listened_timestamp
                     , episode.ZSTORETRACKID + 1000000000000 AS external_id
                FROM ZMTEPISODE episode
                         JOIN ZMTPODCAST podcast ON (episode.ZPODCASTUUID = podcast.ZUUID)
                WHERE (episode.ZPLAYCOUNT > 0 OR episode.ZPLAYSTATE = 1)
                  AND (episode.ZSTORETRACKID IS NOT NULL AND episode.ZSTORETRACKID <> 0)
                  AND strftime('%Y', datetime(episode.ZLASTDATEPLAYED, 'unixepoch', '31 years')) <= strftime('%Y', DATE('now')) > 0
            )
            SELECT cast(e.external_id as text) AS external_id, cast(e.last_listened_timestamp as text) AS last_listened_timestamp, cast(e.percentage as integer) AS percentage
            FROM played_episodes e
            ORDER BY e.last_listened_timestamp DESC
            ;
            """
            )
            var episodesToSubmit = [Episode]();
            for row in stmt {
                let externalID = row[0] as! String
                let eventTimestamp = row[1]! as! String
                let percentage = row[2] as! Int64
                episodesToSubmit.append(Episode(external_id: externalID,
                                                percentage: percentage,
                                                timestamp: eventTimestamp
                ))
            }
            if episodesToSubmit.count > 0 {
                postToAPI(episodes: episodesToSubmit)
            } else {
                print("no episode to submit")
            }
        } catch {
            print("there was an error", error)
        }
    } else {
        print("library db not found")
    }
}

