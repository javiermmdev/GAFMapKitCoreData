import UIKit

/// Custom UICollectionViewCell to display hero information.
class HeroCell: UICollectionViewCell {

    /// Identifier for reusing cells in the collection view.
    static var identifier: String {
        String(describing: HeroCell.self)
    }
    
    @IBOutlet weak var lbHeroName: UILabel!      // Label to show hero's name.
    @IBOutlet weak var imageHero: UIImageView!   // ImageView to show hero's image.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional setup after cell's view is loaded can be added here if needed.
    }
}
