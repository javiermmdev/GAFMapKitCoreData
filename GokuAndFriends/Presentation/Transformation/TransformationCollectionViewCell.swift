import UIKit

/// Custom collection view cell for displaying a transformation.
final class TransformationCollectionViewCell: UICollectionViewCell {
    
    // Label displaying the transformation's name or details
    @IBOutlet weak var transformationLabel: UILabel!
    // Image view displaying the transformation's associated image
    @IBOutlet weak var transformationImageView: UIImageView!
    
    // Identifier used to register and dequeue the cell
    static var identifier: String {
        String(describing: TransformationCollectionViewCell.self)
    }
    
    // Called when the cell is loaded from the nib file
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
