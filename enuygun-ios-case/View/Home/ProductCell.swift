//
//  ProductCell.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//
import UIKit

final class ProductCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ProductCell"
    
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .tertiarySystemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let imagePlaceholderView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let imageSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let oldPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.stopAnimating()
        titleLabel.text = nil
        priceLabel.text = nil
        oldPriceLabel.attributedText = nil
        discountLabel.text = nil
    }
    
    
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.addSubview(productImageView)
        contentView.addSubview(imagePlaceholderView)
        contentView.addSubview(imageSpinner)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(oldPriceLabel)
        contentView.addSubview(discountLabel)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),
            
            
            imagePlaceholderView.topAnchor.constraint(equalTo: productImageView.topAnchor),
            imagePlaceholderView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            imagePlaceholderView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            imagePlaceholderView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),
            
            imageSpinner.centerXAnchor.constraint(equalTo: productImageView.centerXAnchor),
            imageSpinner.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),
            
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            oldPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),
            
            discountLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            discountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        
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
        
        // Image loading state
        productImageView.image = nil
        productImageView.alpha = 0
        imagePlaceholderView.alpha = 1
        imageSpinner.startAnimating()
        
        ImageLoader.shared.load(from: product.thumbnail) { [weak self] image in
            guard let self else { return }
            self.imageSpinner.stopAnimating()
            
            if let image {
                self.productImageView.image = image
                UIView.animate(withDuration: 0.2) {
                    self.productImageView.alpha = 1
                    self.imagePlaceholderView.alpha = 0
                }
            } else {
                self.productImageView.alpha = 0
                self.imagePlaceholderView.alpha = 1
            }
        }
        
        
    }
}
