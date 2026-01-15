//
//  GalleryImageCell.swift
//  enuygun-ios-case
//
//  Created by Ahmet Ozen on 15.01.2026.
//

import UIKit

final class GalleryImageCell: UICollectionViewCell {

    static let reuseIdentifier = "GalleryImageCell"

    private let placeholderView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(placeholderView)
        contentView.addSubview(imageView)
        contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.alpha = 0
        placeholderView.alpha = 1
        spinner.stopAnimating()
    }

    func configure(urlString: String) {
        // Başlangıç state: soft placeholder + küçük spinner
        imageView.image = nil
        imageView.alpha = 0
        placeholderView.alpha = 1
        spinner.startAnimating()

        ImageLoader.shared.load(from: urlString) { [weak self] image in
            guard let self else { return }
            self.spinner.stopAnimating()

            if let image {
                self.imageView.image = image
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1
                    self.placeholderView.alpha = 0
                }
            } else {
                // image gelmezse placeholder kalsın (kocaman photo icon yok)
                self.imageView.alpha = 0
                self.placeholderView.alpha = 1
            }
        }
    }
}
