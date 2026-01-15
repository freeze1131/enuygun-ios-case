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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        title = "Favoriler"
        navigationItem.largeTitleDisplayMode = .never

        setupCollectionView()
        bindStores()
        reloadData()
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
        navigationItem.title = "Favoriler (\(items.count))"
        collectionView.reloadData()
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
