//
//  GameResultImageView.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

class GameResultImageView: UIView {
    
    // MARK: - 属性
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private var onClose: (() -> Void)?
    
    // MARK: - 初始化方法
    
    init(title: String, imageURL: URL?, isVictory: Bool, onClose: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.onClose = onClose
        
        setupView(title: title, imageURL: imageURL, isVictory: isVictory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图设置
    
    private func setupView(title: String, imageURL: URL?, isVictory: Bool) {
        // 设置容器视图
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 8
        
        // 设置标题标签
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = isVictory ? UIColor.systemGreen : UIColor.systemRed
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        // 设置图片视图
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        addSubview(imageView)
        
        // 设置图片内容
        if let url = imageURL {
            print("结果图片将尝试加载URL: \(url)")
            // 使用 SDWebImage 加载图片
            imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: isVictory ? "star.fill" : "xmark.circle"))
        } else {
            // 没有图片URL时显示默认图标
            print("警告：结果图片没有可用的图片URL，显示默认图标")
            imageView.image = UIImage(systemName: isVictory ? "star.fill" : "xmark.circle")
            imageView.tintColor = isVictory ? UIColor.systemYellow : UIColor.systemRed
        }
        
        // 设置关闭按钮
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor.systemGray
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        addSubview(closeButton)
        
        // 设置约束
        // 标题标签约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // 图片视图约束
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 关闭按钮约束
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(30)
        }
    }
    
    // MARK: - 动作处理
    
    @objc private func closeButtonTapped() {
        removeFromSuperview()
        onClose?()
    }
    
    // MARK: - 公共方法
    
    // 显示在父视图上，并相对于指定视图居中
    func show(in parentView: UIView, centerView: UIView) {
        // 设置初始状态
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // 添加到父视图
        parentView.addSubview(self)
        
        // 设置约束 - 相对于指定视图居中
        self.snp.makeConstraints { make in
            make.centerX.equalTo(centerView)
            make.centerY.equalTo(centerView)
            make.width.equalTo(300)
        }
        
        // 添加显示动画
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        })
    }
}
