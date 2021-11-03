//
//  Parser.swift
//  iTunesTest
//
//  Created by Афанасьев Александр Иванович on 28.10.2021.
//

import Foundation

class Parser {
    static let shared = Parser()
    
    private init() {}
    
    func parseAlbum(urlString: String, response: @escaping(AlbumModel?, Error?) -> Void) {
        Request.shared.requestData(urlString: urlString) { result in
            switch result {
            case .success(let data):
                do {
                    let albums = try JSONDecoder().decode(AlbumModel.self, from: data)
                    response(albums, nil)
                }
                catch let jsonError {
                    print("JSON decoding error", jsonError)
                }
            case .failure(let error):
                print("Data retrieval error: \(error.localizedDescription)")
                response(nil, error)
            }
        }
    }
    
    func parseSongs(urlString: String, response: @escaping(SongModel?, Error?) -> Void) {
        Request.shared.requestData(urlString: urlString) { result in
            switch result {
            case .success(let data):
                do {
                    let songs = try JSONDecoder().decode(SongModel.self, from: data)
                    response(songs, nil)
                }
                catch let jsonError {
                    print("JSON decoding error", jsonError)
                }
            case .failure(let error):
                print("Data retrieval error: \(error.localizedDescription)")
                response(nil, error)
            }
        }
    }
    
}
