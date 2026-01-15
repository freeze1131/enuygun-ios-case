//
//  CartViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class CartViewController: UIViewController {

    private let viewModel: CartViewModel
    private let container: AppContainerProtocol

    private var collectionView: UICollectionView!

    init(viewModel: CartViewModel, container: AppContainerProtocol) {
        self.viewModel = viewModel
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Bottom Bar
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
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.numberOfLines = 2
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let checkoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Checkout", for: .normal)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Empty State
    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let emptyIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "cart"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your cart is empty"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptySubtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Add items from Home to see them here."
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
        title = "Cart"

        setupBottomBar()
        setupCollectionView()
        setupEmptyState()
        bindViewModel()

        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
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
            self.subtotalLabel.text = "Subtotal\n\(self.viewModel.subtotalText)"
            self.collectionView.reloadData()
            self.applyEmptyState()
        }

        viewModel.load()
        subtotalLabel.text = "Subtotal\n\(viewModel.subtotalText)"
        applyEmptyState()
    }

    private func applyEmptyState() {
        let isEmpty = viewModel.items.isEmpty
        bottomBar.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = false
    }

    // MARK: - UI Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width - 24, height: 110)
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(CartItemCell.self, forCellWithReuseIdentifier: CartItemCell.reuseIdentifier)

        collectionView.dataSource = self
        collectionView.delegate = self

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
        bottomBar.addSubview(checkoutButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 96),

            subtotalLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            subtotalLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            checkoutButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 140),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

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
    }

    // MARK: - Actions
    @objc private func checkoutTapped() {
        let vm = CheckoutViewModel(cartStore: container.cartStore)
        let vc = CheckoutViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }


    @objc private func goHomeTapped() {
        tabBarController?.selectedIndex = 0
        if let nav = tabBarController?.viewControllers?.first as? UINavigationController {
            nav.popToRootViewController(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CartViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CartItemCell.reuseIdentifier,
            for: indexPath
        ) as? CartItemCell else {
            return UICollectionViewCell()
        }

        let vd = viewModel.cellViewData(at: indexPath.item)
        cell.configure(viewData: vd)

        cell.onIncrease = { [weak self] in
            self?.viewModel.increaseQuantity(at: indexPath.item)
        }

        cell.onDecrease = { [weak self] in
            guard let self else { return }

            if self.viewModel.shouldConfirmRemove(at: indexPath.item) {
                self.confirmRemove(index: indexPath.item)
            } else {
                self.viewModel.decreaseQuantity(at: indexPath.item)
            }
        }

        cell.onRemove = { [weak self] in
            self?.confirmRemove(index: indexPath.item)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate + Remove Confirmation
extension CartViewController: UICollectionViewDelegate {

    private func confirmRemove(index: Int) {
        ToastPresenter.show(
            on: self,
            title: "Remove Item",
            message: "Remove this item from your cart?",
            primaryAction: .init(title: "Remove", style: .destructive) { [weak self] in
                self?.viewModel.removeItem(at: index)
            },
            secondaryAction: .init(title: "Cancel", style: .cancel)
        )
    }
}
