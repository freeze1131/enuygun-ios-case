//
//  ProductListViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class ProductListViewController: UIViewController {

    private let viewModel = ProductListViewModel()

    private var collectionView: UICollectionView!

    private let headerContainer = UIView()
    private let searchField = UITextField()
    private let filterButton = UIButton(type: .system)
    private let sortButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigationTitle(title: "Ürünler", count: 0, total: 0)
        setupHeader()
        setupCollectionView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)


        // ViewModel -> UI
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.setupNavigationTitle(
                title: "Ürünler",
                count: self.viewModel.products.count,
                total: self.viewModel.totalFromAPI
            )
            self.collectionView.reloadData()
        }

        // UI -> ViewModel
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)

        Task { await viewModel.loadProducts() }
    }


    // MARK: - Nav title (Ürünler + sayı)
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
        view.addSubview(headerContainer)

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Ara"
        searchField.backgroundColor = .secondarySystemBackground
        searchField.layer.cornerRadius = 12
        searchField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.delegate = self

        // sol icon padding düzeltmesi
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

    // MARK: - CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.itemSize = CGSize(width: view.bounds.width - 24, height: 100)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

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
        return cell
    }
    
    
    
    
    @objc private func searchChanged() {
        viewModel.setSearchQuery(searchField.text ?? "")
    }

    @objc private func filterTapped() {
        let sheet = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "All", style: .default) { [weak self] _ in
            self?.viewModel.setCategory(nil)
        })

        for category in viewModel.availableCategories() {
            sheet.addAction(UIAlertAction(title: category.capitalized, style: .default) { [weak self] _ in
                self?.viewModel.setCategory(category)
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func sortTapped() {
        let sheet = UIAlertController(title: "Sort", message: nil, preferredStyle: .actionSheet)
        
        for option in ProductListViewModel.SortOption.allCases {
            sheet.addAction(UIAlertAction(title: option.title, style: .default) { [weak self] _ in
                self?.viewModel.setSortOption(option)
            })
        }
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

}


extension ProductListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.products[indexPath.item]
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

