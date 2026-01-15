//
//  ProductDetailViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    private let product: Product
    private let galleryURLs: [String]
    
    private let favoritesStore = FavoritesStore.shared

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private var galleryCollectionView: UICollectionView!
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.hidesForSinglePage = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let oldPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(product: Product) {
        self.product = product

        // Eğer images boşsa thumbnail ile fallback yapıyoruz
        if !product.images.isEmpty {
            self.galleryURLs = product.images
        } else {
            self.galleryURLs = [product.thumbnail]
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        setupGallery()
        bind()
        configureFavoriteButton()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Gallery collection view placeholder - setupGallery() içinde eklenecek
        // PageControl
        contentView.addSubview(pageControl)

        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(oldPriceLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 10),

            discountLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 6),
            discountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            metaLabel.topAnchor.constraint(equalTo: discountLabel.bottomAnchor, constant: 12),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupGallery() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.backgroundColor = .clear
        galleryCollectionView.isPagingEnabled = true
        galleryCollectionView.showsHorizontalScrollIndicator = false

        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.register(
            GalleryImageCell.self,
            forCellWithReuseIdentifier: GalleryImageCell.reuseIdentifier
        )

        contentView.addSubview(galleryCollectionView)

        NSLayoutConstraint.activate([
            galleryCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            galleryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            galleryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            galleryCollectionView.heightAnchor.constraint(equalToConstant: 260),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)

        ])

        contentView.bringSubviewToFront(pageControl)
        pageControl.isHidden = false
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.numberOfPages = galleryURLs.count
        pageControl.currentPage = 0
    }
    
    private func configureFavoriteButton() {
        let imageName = favoritesStore.isFavorite(product) ? "heart.fill" : "heart"
        let button = UIBarButtonItem(image: UIImage(systemName: imageName),
                                     style: .plain,
                                     target: self,
                                     action: #selector(favoriteTapped))
        button.tintColor = .systemRed
        navigationItem.rightBarButtonItem = button
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Sayfa genişliği doğru olsun diye itemSize burada ayarlanır
        if let layout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = galleryCollectionView.bounds.width
            let height = galleryCollectionView.bounds.height
            if layout.itemSize.width != width || layout.itemSize.height != height {
                layout.itemSize = CGSize(width: width, height: height)
                layout.invalidateLayout()
            }
        }
    }

    private func bind() {
        navigationItem.title = product.title
        titleLabel.text = product.title
        descriptionLabel.text = product.description

        let categoryText = product.category.capitalized
        let brandText = (product.brand ?? "").isEmpty ? "-" : (product.brand ?? "-")
        metaLabel.text = "Category: \(categoryText)\nBrand: \(brandText)\nRating: \(String(format: "%.2f", product.rating))"

        let price = product.price

        if let discount = product.discountPercentage {
            let discountedPrice = price * (1 - discount / 100)
            priceLabel.text = String(format: "$%.2f", discountedPrice)

            let old = String(format: "$%.2f", price)
            oldPriceLabel.attributedText = NSAttributedString(
                string: old,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )

            discountLabel.text = "%\(Int(discount)) OFF"
        } else {
            priceLabel.text = String(format: "$%.2f", price)
            oldPriceLabel.attributedText = nil
            discountLabel.text = nil
        }

        galleryCollectionView.reloadData()
    }

    @objc private func favoriteTapped() {
        favoritesStore.toggle(product)
        configureFavoriteButton()
    }
}

// MARK: - Gallery DataSource
extension ProductDetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        galleryURLs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryImageCell.reuseIdentifier,
            for: indexPath
        ) as? GalleryImageCell else {
            return UICollectionViewCell()
        }

        cell.configure(urlString: galleryURLs[indexPath.item])
        return cell
    }
}

// MARK: - Gallery Delegate
extension ProductDetailViewController: UICollectionViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        pageControl.currentPage = max(0, min(page, galleryURLs.count - 1))
    }
}
