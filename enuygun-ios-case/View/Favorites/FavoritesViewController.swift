//
//  FavoritesViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private let favoritesStore = FavoritesStore.shared
    private let cartStore = CartStore.shared

    private var collectionView: UICollectionView!

    private var items: [Product] = []
    
    // Empty state
    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your favorites are empty."
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptySubtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "You can go to home to add products to the favorites."
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let goHomeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Go to Home", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        b.backgroundColor = .secondarySystemGroupedBackground
        b.setTitleColor(.label, for: .normal)
        b.layer.cornerRadius = 14
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.separator.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        title = "Favorites"
        navigationItem.largeTitleDisplayMode = .never

        setupCollectionView()
        setupEmptyState()
        bindStores()
        reloadData()
        
        
        goHomeButton.addTarget(self, action: #selector(goHomeTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func bindStores() {
        favoritesStore.onChange = { [weak self] in
            self?.reloadData()
        }
    }

    private func reloadData() {
        items = favoritesStore.favorites
        navigationItem.title = "Favorites (\(items.count))"
        
        collectionView.reloadData()
        
        
        let hasItems = !items.isEmpty
        emptyStateView.isHidden = hasItems
        
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.reuseIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptySubtitleLabel)
        emptyStateView.addSubview(goHomeButton)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            emptyTitleLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyTitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),

            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 8),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),

            goHomeButton.topAnchor.constraint(equalTo: emptySubtitleLabel.bottomAnchor, constant: 16),
            goHomeButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            goHomeButton.heightAnchor.constraint(equalToConstant: 44),
            goHomeButton.widthAnchor.constraint(equalToConstant: 160),
            goHomeButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    @objc private func goHomeTapped() {
        tabBarController?.selectedIndex = 0
    }
}

extension FavoritesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoriteCell.reuseIdentifier,
            for: indexPath
        ) as? FavoriteCell else {
            return UICollectionViewCell()
        }

        let product = items[indexPath.item]
        cell.configure(with: product)

        cell.onAddToCart = { [weak self] in
            guard let self else { return }
            self.cartStore.add(product)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        cell.onRemove = { [weak self] in
            guard let self else { return }
            self.favoritesStore.toggle(product)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = items[indexPath.item]
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let inset: CGFloat = 12
        let spacing: CGFloat = 12
        let totalHorizontal = inset * 2 + spacing
        let width = (collectionView.bounds.width - totalHorizontal) / 2

        let height = width * 1.55
        return CGSize(width: floor(width), height: floor(height))
    }
}
