//
//  ViewController.swift
//  iTunesTest
//
//  Created by Афанасьев Александр Иванович on 28.10.2021.
//

import UIKit
import CoreData

class SearchPageController: UIViewController {
    
    static let shared = SearchPageController()
    
    var albums = [Album]()
    
    @IBOutlet weak var searchController: UISearchBar!
    @IBOutlet weak var albumTable: UITableView!
    private var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.albumTable.rowHeight = 60.0
    }
    
    
    private func fetchAlbums(albumName: String) {
        
        let urlString = "https://itunes.apple.com/search?term=\(albumName)&entity=album&attribute=albumTerm"
        Parser.shared.parseAlbum(urlString: urlString) { [weak self] albumModel, error in
            if error == nil {
                guard let albumModel = albumModel else { return }
                
                if albumModel.results != [] {
                    self?.albums = albumModel.results
                    let sortedAlbums = albumModel.results.sorted { first, second in
                        return first.collectionName.compare(second.collectionName) == ComparisonResult.orderedAscending
                    }
                    self?.albums = sortedAlbums
                    self?.albumTable.reloadData()
                }
                else {
                    let alert = UIAlertController(title: "Error", message: "Album's not found. Try entering more letters", preferredStyle: .alert)
                    self!.present(alert, animated: true)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    

}

extension SearchPageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! AlbumTableViewCell
        let album = albums[indexPath.row]
        if let urlString = album.artworkUrl100 {
            Request.shared.requestData(urlString: urlString) { result in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data)
                    cell.img.image = image
                case .failure(let error):
                    cell.img.image  = nil
                    print("No album logo\n" + error.localizedDescription)
                }
            }
        } else {
            cell.img.image =  nil
        }
        cell.albumName.text = album.collectionName
        cell.artistName.text = album.artistName
        cell.img.layer.cornerRadius = cell.img.frame.width / 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let album = albums[indexPath.row]
        
        let infoController =  self.storyboard!.instantiateViewController(withIdentifier: "showInfo") as! ShowInfoViewController
        infoController.album = album
        self.present(infoController, animated: true, completion: nil)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "AlbumData", in: context)
        let newAlbum = NSManagedObject(entity: entity!, insertInto: context)
        newAlbum.setValue(album.collectionId, forKey: "collectionId")
        
        do {
            try context.save()
        } catch let error {
            print("Saiving Failed \(error.localizedDescription)")
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchController.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.endEditing(true)
    }
}

extension SearchPageController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let text = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if text != "" {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _  in
                self?.fetchAlbums(albumName: text!)
            })
        }
        else {
            albums.removeAll()
            self.albumTable.reloadData()
        }
    }
    
}
