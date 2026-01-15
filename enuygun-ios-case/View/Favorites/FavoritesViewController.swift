//
//  FavoritesViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class FavoritesViewController: UIViewController {

    private let viewModel: FavoritesViewModel
    private let container: AppContainerProtocol
    private var collectionView: UICollectionView!

    init(viewModel: FavoritesViewModel, container: AppContainerProtocol) {
        self.viewModel = viewModel
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Empty State
    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let emptyIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "No favorites yet"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptySubtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Browse Home and tap the heart to save items here."
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let goHomeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Go to Home", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
        b.layer.cornerRadius = 14
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Favorites"

        setupCollectionView()
        setupEmptyState()
        bindViewModel()

        goHomeButton.addTarget(self, action: #selector(goHomeTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
        applyEmptyState()
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.applyEmptyState()
        }

        viewModel.load()
        applyEmptyState()
    }

    private func applyEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    // MARK: - UI Setup
    private func setupEmptyState() {
        view.addSubview(emptyStateView)

        let stack = UIStackView(arrangedSubviews: [
            emptyIconView,
            emptyTitleLabel,
            emptySubtitleLabel,
            goHomeButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView.addSubview(stack)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            emptyIconView.heightAnchor.constraint(equalToConstant: 54),
            emptyIconView.widthAnchor.constraint(equalToConstant: 54),

            stack.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])

        emptyStateView.isHidden = true
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

    // MARK: - Actions
    @objc private func goHomeTapped() {
        tabBarController?.selectedIndex = 0
        if let nav = tabBarController?.viewControllers?.first as? UINavigationController {
            nav.popToRootViewController(animated: true)
        }
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

// MARK: - UICollectionViewDataSource
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
}

// MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.product(at: indexPath.item)

        let detailVM = ProductDetailViewModel(
            product: product,
            favoritesStore: container.favoritesStore,
            cartStore: container.cartStore
        )
        let vc = ProductDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(vc, animated: true)
    }
}
