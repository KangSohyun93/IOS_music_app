

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    var songs: [Song] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configNavigationBar()
        configTableView()
    }
    
    //Navbar
    private func configNavigationBar() {
            title = "Musics Player"
            navigationItem.largeTitleDisplayMode = .always

            navigationController?.navigationBar.prefersLargeTitles = true
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    
    private func configTableView() {
        songs = Song.getPlaylist()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongTableViewCell")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lastSongReceived(_:)),
                                               name: NSNotification.Name("lastSong"),
                                                                         object: nil)
    }
    @objc private func lastSongReceived(_ notification: Notification) {
        print("Last song: \(String(describing: notification.userInfo))")
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as? SongTableViewCell
        else { return UITableViewCell() }
        cell.configCell(song: songs[indexPath.row])
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //chọn => điều hướng
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? ViewController else {
            return
        }
        
        playerVC.songs = self.songs
        playerVC.currentIndex = indexPath.row
        
        navigationController?.pushViewController(playerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

