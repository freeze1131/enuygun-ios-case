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
    
    private let cartStore = CartStore.shared

    private let bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let addToCartButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Add to Cart", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .label
        b.setTitleColor(.systemBackground, for: .normal)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tagStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
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

        // 1) Bottom bar önce
        view.addSubview(bottomBar)
        bottomBar.addSubview(addToCartButton)

        // 2) ScrollView sonra
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 3) Bottom bar constraints
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addToCartButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            addToCartButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            addToCartButton.bottomAnchor.constraint(equalTo: bottomBar.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 4) Scroll constraints (artık bottomBar aynı hierarchy’de)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Subviews
        contentView.addSubview(pageControl)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(oldPriceLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(tagStack)
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

            ratingLabel.topAnchor.constraint(equalTo: discountLabel.bottomAnchor, constant: 12),
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            tagStack.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            tagStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            tagStack.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: 14),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }


    private func setupGallery() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(GalleryImageCell.self, forCellWithReuseIdentifier: GalleryImageCell.reuseIdentifier)

        self.galleryCollectionView = cv

        contentView.addSubview(cv)

        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cv.heightAnchor.constraint(equalToConstant: 260),

            pageControl.topAnchor.constraint(equalTo: cv.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])

        contentView.bringSubviewToFront(pageControl)
        pageControl.isHidden = false
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.numberOfPages = galleryURLs.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        
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
    
    private func makeTag(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = "  \(text)  "
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .label
        l.backgroundColor = .secondarySystemGroupedBackground
        l.layer.cornerRadius = 12
        l.layer.masksToBounds = true
        return l
    }


    private func bind() {
        navigationItem.title = product.title
        titleLabel.text = product.title
        descriptionLabel.text = product.description

//        let categoryText = product.category.capitalized
//        let brandText = (product.brand ?? "").isEmpty ? "-" : (product.brand ?? "-")

        navigationItem.title = product.title

        ratingLabel.text = "★ \(String(format: "%.2f", product.rating))"

        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tagStack.addArrangedSubview(makeTag(product.category.capitalized))
        if let brand = product.brand, !brand.isEmpty {
            tagStack.addArrangedSubview(makeTag(brand))
        }

        
        
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
    
    @objc private func addToCartTapped() {
        cartStore.add(product)
        // küçük feedback
        let alert = UIAlertController(title: "Added to Cart", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            alert.dismiss(animated: true)
        }
    }
    
    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let index = sender.currentPage
        let indexPath = IndexPath(item: index, section: 0)
        galleryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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

extension ProductDetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
       
        return true
    }
}

