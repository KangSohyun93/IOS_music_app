import UIKit
import AVFoundation
import MediaPlayer

final class ViewController: UIViewController {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    private var player: AVAudioPlayer?
    var songs = [Song]()
    var currentIndex = 0
    private var isPlaying = true
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if songs.isEmpty {
                songs = Song.getPlaylist()
            }
        setupAudioSession()
        configure()
        player?.play()
        syncState()
        UIApplication.shared.beginReceivingRemoteControlEvents()
                becomeFirstResponder()
                setupRemoteTransportControls()
    }
    
    /*override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
        UIApplication.shared.endReceivingRemoteControlEvents()
        resignFirstResponder()
    }*/
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("ERROR setting up audio session: \(error)")
        }
    }
    
    private func configure() {
        let currentSong = songs[currentIndex]
        
        titleLabel.text = currentSong.name
        performerLabel.text = currentSong.performer
        thumbnailView.image = UIImage(named: currentSong.thumbnail)
        
        guard let urlPath = Bundle.main.path(forResource: currentSong.fileName, ofType: "mp3") else {
            print("ERROR: File not found for \(currentSong.fileName)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPath))
            player?.prepareToPlay()
            
            setupSlider()
            
            setupNowPlayingInfo()
            
        } catch {
            print("ERROR creating player: \(error)")
        }
    }
    
    private func setupSlider() {
        slider.maximumValue = Float(player?.duration ?? 0)
        
        slider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        
        startTimer()
    }
    
    private func syncState() {
        guard let player = player else { return }
        self.isPlaying = player.isPlaying
        let imageName = self.isPlaying ? "pause" : "play"
        playPauseButton.setImage(UIImage(named: imageName), for: .normal)
        
        if self.isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
        setupNowPlayingInfo()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setupRemoteTransportControls() {
            let commandCenter = MPRemoteCommandCenter.shared()

            commandCenter.playCommand.addTarget { [unowned self] event in
                if self.player?.isPlaying == false {
                    self.player?.play()
                    self.syncState()
                    return .success
                }
                return .commandFailed
            }

            commandCenter.pauseCommand.addTarget { [unowned self] event in
                if self.player?.isPlaying == true {
                    self.player?.pause()
                    self.syncState()
                    return .success
                }
                return .commandFailed
            }

            commandCenter.nextTrackCommand.addTarget { [unowned self] event in
                self.playNextTrack()
                return .success
            }

            commandCenter.previousTrackCommand.addTarget { [unowned self] event in
                self.playPreviousTrack()
                return .success
            }
        }
        
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        syncState()
        
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        playNextTrack()
    }
    
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        playPreviousTrack()
    }
    
    private func playNextTrack() {
        if currentIndex < songs.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        configure()
        player?.play()
        syncState()
    }
    
    private func playPreviousTrack() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = songs.count - 1
        }
        configure()
        player?.play()
        syncState()
    }
    
    @objc private func didSlideSlider(_ slider: UISlider) {
        player?.currentTime = TimeInterval(slider.value)
        setupNowPlayingInfo()
    }
    
    @objc private func updateSlider() {
        guard let player = player else { return }
        slider.value = Float(player.currentTime)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
    }
    private func setupNowPlayingInfo() {
            var nowPlayingInfo = [String: Any]()
            let currentSong = songs[currentIndex]
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = currentSong.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = currentSong.performer
            
            if let image = UIImage(named: currentSong.thumbnail) {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                    return image
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            
            if let player = player {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
}
