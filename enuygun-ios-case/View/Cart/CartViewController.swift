//
//  CartViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class CartViewController: UIViewController {

    private let cartStore = CartStore.shared

    private var collectionView: UICollectionView!
    private var items: [CartItem] = []

    // Bottom bar
    private let bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let subtotalLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtotalValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let checkoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Checkout", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Empty state
    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your cart is empty."
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptySubtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "You can go to home to add products to the cart."
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
        navigationItem.title = "Cart"
        navigationItem.largeTitleDisplayMode = .never
        
        setupBottomBar()
        setupCollectionView()
        setupEmptyState()

        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        goHomeButton.addTarget(self, action: #selector(goHomeTapped), for: .touchUpInside)

        cartStore.onChange = { [weak self] in
            self?.reloadData()
        }

        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func reloadData() {
        items = cartStore.items

        print("🛒 Cart items count:", items.count)

        collectionView.reloadData()

        subtotalLabel.text = "Subtotal"
        subtotalValueLabel.text = String(format: "$%.2f", cartStore.subtotal)

        let hasItems = !items.isEmpty
        bottomBar.isHidden = !hasItems
        emptyStateView.isHidden = hasItems
    }


    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.itemSize = CGSize(width: view.bounds.width - 24, height: 110)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CartItemCell.self, forCellWithReuseIdentifier: CartItemCell.reuseIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
    }

    private func setupBottomBar() {
        view.addSubview(bottomBar)
        bottomBar.addSubview(subtotalLabel)
        bottomBar.addSubview(subtotalValueLabel)
        bottomBar.addSubview(checkoutButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // ✅ BU SATIRLAR KRİTİK: bar yüksekliği sabit/limitli olsun
            bottomBar.heightAnchor.constraint(equalToConstant: 92),

            subtotalLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            subtotalLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),

            subtotalValueLabel.topAnchor.constraint(equalTo: subtotalLabel.bottomAnchor, constant: 2),
            subtotalValueLabel.leadingAnchor.constraint(equalTo: subtotalLabel.leadingAnchor),

            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            checkoutButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 140),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func confirmRemove(productTitle: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Remove item?",
            message: "\(productTitle) will be removed from your cart.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            onConfirm()
        })
        present(alert, animated: true)
    }


    @objc private func goHomeTapped() {
        tabBarController?.selectedIndex = 0
    }

    @objc private func checkoutTapped() {
        let vc = CheckoutViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CartViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CartItemCell.reuseIdentifier,
            for: indexPath
        ) as? CartItemCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        cell.configure(with: item)

        cell.onIncrease = { [weak self] in
            self?.cartStore.increase(productId: item.product.id)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        cell.onDecrease = { [weak self] in
            guard let self else { return }

            if item.quantity <= 1 {
                self.confirmRemove(productTitle: item.product.title) {
                    self.cartStore.remove(productId: item.product.id)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } else {
                self.cartStore.decrease(productId: item.product.id)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }

        cell.onRemove = { [weak self] in
            guard let self else { return }

            self.confirmRemove(productTitle: item.product.title) {
                self.cartStore.remove(productId: item.product.id)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }


        return cell
    }
}

extension CartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // İstersen cart’tan da detail’e gidebilir
        let product = items[indexPath.item].product
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

