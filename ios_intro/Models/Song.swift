import Foundation

struct Song {
    let name: String
    let fileName: String
    let performer: String
    let thumbnail: String
    
    static func getPlaylist() -> [Song] {
        var songs: [Song] = []
        songs.append(Song(name: "Mic Drop", fileName: "micdrop", performer: "BTS", thumbnail: "micdrop"))
        songs.append(Song(name: "Fake Love", fileName: "fakelove", performer: "BTS", thumbnail: "fakelove"))
        songs.append(Song(name: "song 3", fileName: "micdrop", performer: "BTS", thumbnail: "micdrop"))
        songs.append(Song(name: "song 4", fileName: "fakelove", performer: "BTS", thumbnail: "fakelove"))
        songs.append(Song(name: "song 5", fileName: "micdrop", performer: "BTS", thumbnail: "micdrop"))
        songs.append(Song(name: "song 6", fileName: "fakelove", performer: "BTS", thumbnail: "fakelove"))
        return songs
    }
}

