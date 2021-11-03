//
//  ShowInfoViewController.swift
//  iTunesTest
//
//  Created by Афанасьев Александр Иванович on 31.10.2021.
//

import UIKit

class ShowInfoViewController: UIViewController {
    
    var songs = [Song]()
    var album: Album?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var albumPic: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artName: UILabel!
    @IBOutlet weak var trCount: UILabel!
    @IBOutlet weak var date: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfo()
        fetchSongs(album: album)
    }

    
    private func setupInfo() {
        albumPic.layer.cornerRadius = albumPic.frame.width / 2
        if let urlString = album?.artworkUrl100 {
            Request.shared.requestData(urlString: urlString) { [weak self] result in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data)
                    self!.albumPic.image = image
                case .failure(let error):
                    self!.albumPic.image  = nil
                    print("No album logo\n" + error.localizedDescription)
                }
            }
        } else {
            albumPic.image =  nil
        }
        albumName.text = "Name of album: \(album?.collectionName ?? "")"
        artName.text = "Artist name: \(album?.artistName ?? "")"
        trCount.text = "Tracks: \(album?.trackCount ?? 0)"
        date.text = "Release date: \(convertDate(date: album?.releaseDate ?? ""))"
    }

    private func convertDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        guard let backendDate = dateFormatter.date(from: date) else { return "" }
        
        let formatDate = DateFormatter()
        formatDate.dateFormat = "dd-MM-yyy"
        let date = formatDate.string(from: backendDate)
        return date
    }
    
    private func fetchSongs(album: Album?) {
        
        guard let album = album else { return }
        let idAlbum = album.collectionId
        let urlString = "https://itunes.apple.com/lookup?id=\(idAlbum)&entity=song"
        print(urlString)
        Parser.shared.parseSongs(urlString: urlString) { [weak self] songModel, error in
            if error == nil {
                guard let songModel = songModel else { return }
                self!.songs = songModel.results
                self!.songs.removeFirst()
                self!.collectionView.reloadData()
            }
            else {
                print(error!.localizedDescription)
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                self?.present(alert, animated: true)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
        }
        
    }

}

extension ShowInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SongsCollectionViewCell
        cell.songName.text = self.songs[indexPath.row].trackName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(
            width: 300,
            height: 30
        )
    }

}
