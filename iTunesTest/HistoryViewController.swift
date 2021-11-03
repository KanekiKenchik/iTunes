//
//  HistoryViewController.swift
//  iTunesTest
//
//  Created by Афанасьев Александр Иванович on 01.11.2021.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    static var shared = HistoryViewController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var albums = [Album]()
    
    @IBAction func clearHistoryClicked(_ sender: UIButton) {
        clearHistory()
    }
    @IBOutlet weak var searchController: UISearchBar!
    
    @IBOutlet weak var albumTable: UITableView!
    
    private var timer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.albumTable.rowHeight = 60.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AlbumData")
        request.returnsObjectsAsFaults = false
        
        do {
            albums.removeAll()
            self.albumTable.reloadData()
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]{
                fetchAlbums(idAlbum: data.value(forKey: "collectionId")! as! Int)
            }
        } catch {
            print("Retrieval failed")
        }
    }
    
    private func clearHistory() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        
        if let tasks = try? context.fetch(fetchRequest) {
            for task in tasks {
                context.delete(task)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        self.albums.removeAll(keepingCapacity: false)
        albumTable.reloadData()
    }
    
    private func fetchAlbums(idAlbum: Int) {
        
        let urlString = "https://itunes.apple.com/lookup?id=\(idAlbum)&entity=song"
        Parser.shared.parseAlbum(urlString: urlString) { [weak self] albumModel, error in
            if error == nil {
                guard let albumModel = albumModel else { return }
                
                if albumModel.results != [] {
                    self?.albums.insert(albumModel.results[0], at: 0)
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

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "showInfo") as! ShowInfoViewController
        viewController.album = album
        self.present(viewController, animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchController.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.endEditing(true)
    }
}

