//
//  ProductDetailViewController.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class ProductDetailViewController: UIViewController {

    private let viewModel: ProductDetailViewModel

    // MARK: - Init
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }


    // Convenience init (istersen eski çağrıları bozmamak için)
    convenience init(product: Product) {
        let vm = ProductDetailViewModel(product: product)
        self.init(viewModel: vm)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var galleryCollectionView: UICollectionView!

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.hidesForSinglePage = false
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let oldPriceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let discountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .systemRed
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let metaLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupLayout()
        setupGallery()
        bindViewModel()

        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)

        viewModel.onUpdate = { [weak self] in
            self?.configureFavoriteButton()
        }
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        view.addSubview(bottomBar)
        bottomBar.addSubview(addToCartButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 92),

            addToCartButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 48),
            addToCartButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            addToCartButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -12),

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

        contentView.addSubview(pageControl)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(tagStack)
        contentView.addSubview(priceLabel)
        contentView.addSubview(oldPriceLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            tagStack.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            tagStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            priceLabel.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),

            discountLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
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

        galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.isPagingEnabled = true
        galleryCollectionView.showsHorizontalScrollIndicator = false

        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.register(GalleryImageCell.self, forCellWithReuseIdentifier: GalleryImageCell.reuseIdentifier)
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)

        contentView.addSubview(galleryCollectionView)

        NSLayoutConstraint.activate([
            galleryCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            galleryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            galleryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            galleryCollectionView.heightAnchor.constraint(equalToConstant: 280),

            pageControl.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = galleryCollectionView.bounds.size
        }
    }

    private func bindViewModel() {
        navigationItem.title = viewModel.titleText

        titleLabel.text = viewModel.titleText
        descriptionLabel.text = viewModel.descriptionText
        ratingLabel.text = viewModel.ratingText

        priceLabel.text = viewModel.displayPriceText
        oldPriceLabel.attributedText = viewModel.oldPriceText
        discountLabel.text = viewModel.discountText
        discountLabel.isHidden = viewModel.discountText == nil

        metaLabel.text = viewModel.metaText

        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tagStack.addArrangedSubview(makeTag(viewModel.categoryTag))
        if let brand = viewModel.brandTag {
            tagStack.addArrangedSubview(makeTag(brand))
        }

        pageControl.numberOfPages = viewModel.galleryImages.count

        configureFavoriteButton()
        galleryCollectionView.reloadData()
    }

    @objc private func pageControlChanged() {
        let index = pageControl.currentPage
        let indexPath = IndexPath(item: index, section: 0)
        galleryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    @objc private func addToCartTapped() {
        viewModel.addToCart()
        ToastPresenter.show(on: self, message: "Added to Cart")
    }

    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }

    private func configureFavoriteButton() {
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
    }

    private func makeTag(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = "  \(text)  "
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.backgroundColor = .secondarySystemGroupedBackground
        l.layer.cornerRadius = 12
        l.layer.masksToBounds = true
        return l
    }
}

extension ProductDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.galleryImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryImageCell.reuseIdentifier,
            for: indexPath
        ) as? GalleryImageCell else {
            return UICollectionViewCell()
        }

        cell.configure(urlString: viewModel.galleryImages[indexPath.item])
        return cell
    }
}

extension ProductDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        pageControl.currentPage = page
    }
}
