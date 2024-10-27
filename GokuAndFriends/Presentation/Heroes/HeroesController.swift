import UIKit
import Kingfisher

// MARK: - Sections
/// Enum representing the sections in the hero list, currently only one section.
enum SectionsHeroes {
    case main
}

/// Controller to display heroes fetched with the `HeroesViewModel`.
class HeroesController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: HeroesViewModel
    
    // Diffable Data Source with section type and hero item.
    private var dataSource: UICollectionViewDiffableDataSource<SectionsHeroes, Hero>?
    
    // Initializer with injected ViewModel for testing purposes.
    init(viewModel: HeroesViewModel = HeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = "Heroes"  // Adds title to the navigation bar.
        
        configureLogoutButton()  // Sets up the logout button.
        configureCollectionView()
        setBinding()
        viewModel.loadData(filter: nil)
    }
    
    // MARK: - Configure Logout Button
    /// Sets up the logout button using SF Symbols.
    private func configureLogoutButton() {
        let logoutImage = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        let logoutButton = UIBarButtonItem(image: logoutImage, style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = logoutButton
    }

    // MARK: - Logout Action
    /// Handles the logout action when the logout button is tapped.
    @objc private func handleLogout() {
        clearDataAndLogout()  // Clears data and redirects to login.
    }
    
    // MARK: - Clear Data and Logout
    /// Clears database, deletes token, and redirects to the login screen.
    private func clearDataAndLogout() {
        StoreDataProvider.shared.clearBBDD()  // Clears database.
        SecureDataStore.shared.deleteToken()  // Deletes token from Keychain.
        redirectToLogin()
    }
    
    /// Redirects the user to the login screen, replacing the root view controller.
    private func redirectToLogin() {
        let loginVC = LoginController()  // Instantiates login controller.
        let navigationController = UINavigationController(rootViewController: loginVC)  // New navigation controller with login.
        navigationController.modalPresentationStyle = .fullScreen
        
        // Replaces the current root view controller with LoginController.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Bind ViewModel
    /// Sets up bindings with ViewModel to be notified on state changes.
    func setBinding() {
        viewModel.statusHeroes.bind {[weak self] status in
            switch status {
            case .dataUpdated:
                // Creates and applies snapshot to update data on the collection view.
                var snapshot = NSDiffableDataSourceSnapshot<SectionsHeroes, Hero>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self?.viewModel.heroes ?? [], toSection: .main)
                self?.dataSource?.apply(snapshot)
                
            case .error(msg: let msg):
                // Shows errors as an alert on the screen.
                let alert = UIAlertController(title: "G & F", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            case .none:
                break
            }
        }
    }
    
    // MARK: - Configure Collection View
    /// Sets up the collection view with delegate, cell registration, and data source.
    func configureCollectionView() {
        collectionView.delegate = self
        
        // Registers the cell and configures it for a given hero.
        let cellRegister = UICollectionView.CellRegistration<HeroCell, Hero>(cellNib: UINib(nibName: HeroCell.identifier, bundle: nil)) { cell, indexPath, hero in
            cell.lbHeroName.text = hero.name
            
            // Uses Kingfisher to load hero image from URL.
            if let imageUrl = URL(string: hero.photo) {
                cell.imageHero.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholderImage"))
            } else {
                cell.imageHero.image = UIImage(named: "placeholderImage")
            }
            
            // Rounds the image.
            cell.imageHero.layer.cornerRadius = cell.imageHero.frame.size.width / 2
            cell.imageHero.clipsToBounds = true
        }
        
        // Sets up data source with the cell registration.
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: hero)
        })
    }
}

// MARK: - UICollectionView Delegate Methods
extension HeroesController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let hero = viewModel.heroAt(index: indexPath.row) else {
            return
        }
        let viewModel = HeroViewModel(hero: hero)
        let heroDetailVC = HeroDetailController(viewModel: viewModel)
        
        // Shows the detail controller; pushes if in navigation controller, otherwise presents modally.
        self.show(heroDetailVC, sender: self)
    }
    
    // Sets the cell size in the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 80)
    }
}
