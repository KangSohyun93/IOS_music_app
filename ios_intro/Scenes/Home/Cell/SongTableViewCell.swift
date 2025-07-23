import UIKit

final class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var thunbnailImageView: UIImageView!
   
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var performerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
    }

    func configCell(song: Song) {
        thunbnailImageView.image = UIImage(named: song.thumbnail)
        titleLabel.text = song.name
        performerLabel.text = song.performer
    }
    
}
