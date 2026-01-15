//
//  ProductListViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class ProductListViewController: UIViewController {

    private let viewModel: ProductListViewModel

    private let refreshControl = UIRefreshControl()
    private var collectionView: UICollectionView!
    private let headerContainer = UIView()
    private let searchField = UITextField()
    private let filterButton = UIButton(type: .system)
    private let sortButton = UIButton(type: .system)

    init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setPillSelected(filterButton, selected: false)
        setPillSelected(sortButton, selected: false)

        setupNavigationTitle(title: "Products", count: 0, total: 0)
        setupHeader()
        setupCollectionView()
        updateFilterSortTitles()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // ViewModel -> UI
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.setupNavigationTitle(
                title: "Products",
                count: self.viewModel.products.count,
                total: self.viewModel.totalFromAPI
            )
            self.updateFilterSortTitles()
            self.collectionView.reloadData()
        }

        // UI -> ViewModel
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)

        Task { await viewModel.loadProducts() }
    }

    // MARK: - Nav title (Products + sayı)
    private func setupNavigationTitle(title: String, count: Int, total: Int) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)

        let countLabel = UILabel()
        countLabel.text = total > 0 ? "\(count)/\(total)" : "\(count)"
        countLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        countLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        stack.axis = .horizontal
        stack.alignment = .lastBaseline
        stack.spacing = 8

        navigationItem.titleView = stack
    }

    // MARK: - Header (search + filter + sort)
    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = .clear
        view.addSubview(headerContainer)

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Ara"
        searchField.backgroundColor = .systemBackground
        searchField.layer.cornerRadius = 12
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor.separator.cgColor
        searchField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.delegate = self

        if let iv = searchField.leftView as? UIImageView {
            iv.tintColor = .secondaryLabel
            iv.contentMode = .center
            iv.widthAnchor.constraint(equalToConstant: 36).isActive = true
        }

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filterButton.tintColor = .label
        filterButton.backgroundColor = .secondarySystemBackground
        filterButton.layer.cornerRadius = 12
        filterButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down.circle"), for: .normal)
        sortButton.tintColor = .label
        sortButton.backgroundColor = .secondarySystemBackground
        sortButton.layer.cornerRadius = 12
        sortButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let hStack = UIStackView(arrangedSubviews: [searchField, filterButton, sortButton])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 10

        headerContainer.addSubview(hStack)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            hStack.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -12),

            searchField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func updateFilterSortTitles() {
        let isFilterSelected = viewModel.currentCategory() != nil
        setPillSelected(filterButton, selected: isFilterSelected)

        let isSortSelected = viewModel.currentSortOption() != .relevance
        setPillSelected(sortButton, selected: isSortSelected)
    }

    private func setPillSelected(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = .label
            button.tintColor = .systemBackground
        } else {
            button.backgroundColor = .secondarySystemBackground
            button.tintColor = .label
        }
    }

    // MARK: - CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.itemSize = CGSize(width: view.bounds.width - 24, height: 100)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func didPullToRefresh() {
        Task {
            await viewModel.loadProducts()
            refreshControl.endRefreshing()
        }
    }

    @objc private func searchChanged() {
        viewModel.setSearchQuery(searchField.text ?? "")
    }

    @objc private func filterTapped() {
        let sheet = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)

        let current = viewModel.currentCategory() // nil = All

        let allTitle = (current == nil) ? "✓ All" : "All"
        sheet.addAction(UIAlertAction(title: allTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            self.viewModel.setCategory(nil)
            self.setPillSelected(self.filterButton, selected: false)
        })

        for category in viewModel.availableCategories() {
            let isSelected = (current == category)
            let title = isSelected ? "✓ \(category.capitalized)" : category.capitalized

            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                self.viewModel.setCategory(category)
                self.setPillSelected(self.filterButton, selected: true)
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func sortTapped() {
        let sheet = UIAlertController(title: "Sort", message: nil, preferredStyle: .actionSheet)

        let current = viewModel.currentSortOption()

        for option in ProductListViewModel.SortOption.allCases {
            let title = (option == current) ? "✓ \(option.title)" : option.title

            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                self.viewModel.setSortOption(option)
                self.setPillSelected(self.sortButton, selected: option != .relevance)
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UICollectionViewDataSource
extension ProductListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as? ProductCell else {
            return UICollectionViewCell()
        }

        let product = viewModel.products[indexPath.item]
        cell.configure(with: product)

        if viewModel.shouldLoadMore(currentIndex: indexPath.item) {
            Task { await viewModel.loadMoreIfNeeded() }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.products[indexPath.item]
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ProductListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
