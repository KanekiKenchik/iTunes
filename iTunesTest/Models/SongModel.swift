//
//  SongModel.swift
//  iTunesTest
//
//  Created by Афанасьев Александр Иванович on 01.11.2021.
//

import Foundation

struct SongModel: Decodable {
    let results: [Song]
}

struct Song: Decodable {
    let trackName: String?
}
