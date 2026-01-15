//
//  FavoritesViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private let viewModel = FavoritesViewModel()
    private var collectionView: UICollectionView!

    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No favorites yet."
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Favorites"

        setupCollectionView()
        setupEmptyState()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.emptyStateLabel.isHidden = !self.viewModel.isEmpty
        }

        viewModel.load()
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        emptyStateLabel.isHidden = true
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let sideInset: CGFloat = 12
        let availableWidth = view.bounds.width - (sideInset * 2) - 12
        let itemWidth = floor(availableWidth / 2)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 54)
        layout.sectionInset = UIEdgeInsets(top: 12, left: sideInset, bottom: 12, right: sideInset)

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
        viewModel.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoriteCell.reuseIdentifier,
            for: indexPath
        ) as? FavoriteCell else { return UICollectionViewCell() }

        let vd = viewModel.cellViewData(at: indexPath.item)
        cell.configure(viewData: vd)

        cell.onRemove = { [weak self] in
            self?.confirmRemove(index: indexPath.item)
        }

        cell.onAddToCart = { [weak self] in
            guard let self else { return }
            self.animateCellAction(cell)
            self.viewModel.addToCart(at: indexPath.item)
            ToastPresenter.show(on: self, message: "Added to Cart")
        }


        return cell
    }
    

    private func confirmRemove(index: Int) {
        ToastPresenter.show(
            on: self,
            title: "Remove Favorite",
            message: "Remove this item from favorites?",
            primaryAction: .init(title: "Remove", style: .destructive) { [weak self] in
                self?.viewModel.remove(at: index)
            },
            secondaryAction: .init(title: "Cancel", style: .cancel)
        )
    }


    private func animateCellAction(_ cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.12, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12) {
                cell.transform = .identity
            }
        })
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.product(at: indexPath.item)
        let vc = ProductDetailViewController(product: product)
        navigationController?.pushViewController(vc, animated: true)
    }
}
