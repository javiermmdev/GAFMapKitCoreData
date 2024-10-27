// HeroDetailController.swift
import UIKit
import MapKit
import Kingfisher

class HeroDetailController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionHeroe: UILabel!
    @IBOutlet weak var transformationCollectionView: UICollectionView!
    
    private var viewModel: HeroViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Int, Transformation>?
    private var locationManager = CLLocationManager()
    
    init(viewModel: HeroViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroDetailController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        viewModel.loadData()
        setBinding()
        configureCollectionView()
        checkLocationAuthorizationStatus()
    }
    
    private func configureMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true
    }
    
    private func configureCollectionView() {
        transformationCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        transformationCollectionView.collectionViewLayout = layout
        
        transformationCollectionView.register(UINib(nibName: TransformationCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TransformationCollectionViewCell.identifier)
        
        let cellRegistration = UICollectionView.CellRegistration<TransformationCollectionViewCell, Transformation>(cellNib: UINib(nibName: TransformationCollectionViewCell.identifier, bundle: nil)) { cell, indexPath, transformation in
            cell.transformationLabel.text = transformation.name
            
            if let imageUrl = URL(string: transformation.photo) {
                cell.transformationImageView.kf.setImage(with: imageUrl)
            } else {
                cell.transformationImageView.image = nil
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Transformation>(collectionView: transformationCollectionView) { (collectionView, indexPath, transformation) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: transformation)
        }
    }
    
    func setBinding() {
        viewModel.status.bind {[weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .locationUpdated:
                    self?.updateMapAnnotations()
                    self?.descriptionHeroe.text = self?.viewModel.heroDescription
                case .transformationsUpdated:
                    self?.descriptionHeroe.text = self?.viewModel.heroDescription
                    self?.reloadTransformations()
                case .error(msh: let msg):
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                case .none:
                    break
                }
            }
        }
    }
    
    private func reloadTransformations() {
        guard viewModel.hasTransformations else {
            transformationCollectionView.isHidden = true
            return
        }
        
        transformationCollectionView.isHidden = false

        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Transformation>()
            snapshot.appendSections([0])
            snapshot.appendItems(self.viewModel.heroTransformations)
            self.dataSource?.apply(snapshot)
        }
    }
    
    private func updateMapAnnotations() {
        let oldAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(oldAnnotations)
        self.mapView.addAnnotations(viewModel.annotations)
        
        if let annotation = viewModel.annotations.first {
            mapView.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
        }
    }
    
    private func checkLocationAuthorizationStatus() {
        let authorizationStatus = locationManager.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            mapView.showsUserLocation = false
            mapView.showsUserTrackingButton = false
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
}

extension HeroDetailController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transformation = viewModel.transformationAt(index: indexPath.row) else {
            return
        }
        
        let modalVC = TransformationDetailModalController(nibName: "TransformationDetailModalController", bundle: nil)
        modalVC.transformation = transformation
        
        let navController = UINavigationController(rootViewController: modalVC)
        navController.modalPresentationStyle = .automatic
        present(navController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.bounds.size.height)
    }
}
