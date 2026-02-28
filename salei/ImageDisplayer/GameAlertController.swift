//
//  GameAlertController.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

/// 游戏弹窗控制器，提供类似 UIAlertController 的 API，但具有游戏风格的自定义外观
class GameAlertController: UIView {
    
    // MARK: - 内部类型
    
    /// 按钮样式枚举
    enum ButtonStyle {
        case `default`    // 默认样式
        case cancel       // 取消样式
        case destructive  // 危险操作样式
        case success      // 成功样式
        
        /// 获取按钮样式对应的颜色
        var color: UIColor {
            switch self {
            case .default:
                return UIColor.systemBlue
            case .cancel:
                return UIColor.systemGray
            case .destructive:
                return UIColor.systemRed
            case .success:
                return UIColor.systemGreen
            }
        }
    }
    
    /// 按钮类，用于创建弹窗中的按钮
    class AlertButton: UIButton {
        var action: (() -> Void)?
        var style: ButtonStyle
        
        init(title: String, style: ButtonStyle, action: (() -> Void)?) {
            self.action = action
            self.style = style
            super.init(frame: .zero)
            
            setTitle(title, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            layer.cornerRadius = 10
            backgroundColor = style.color.withAlphaComponent(0.8)
            setTitleColor(.white, for: .normal)
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func buttonTapped() {
            action?()
        }
    }
    
    // MARK: - 属性
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let imageView = UIImageView()
    private let buttonsStackView = UIStackView()
    private var buttons: [AlertButton] = []
    
    // MARK: - 初始化方法
    
    /// 创建一个游戏弹窗控制器
    /// - Parameters:
    ///   - title: 弹窗标题
    ///   - message: 弹窗消息内容
    ///   - image: 可选的图片（可以是 UIImage 或 URL）
    ///   - isSuccess: 是否是成功状态（影响标题颜色）
    init(title: String, message: String? = nil, image: Any? = nil, isSuccess: Bool = true) {
        super.init(frame: .zero)
        
        // 设置自身为半透明背景
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // 添加点击手势以便用户可以点击空白区域关闭弹窗
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        
        setupView(title: title, message: message, image: image, isSuccess: isSuccess)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图设置
    
    private func setupView(title: String, message: String?, image: Any?, isSuccess: Bool) {
        // 设置容器视图
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 8
        addSubview(containerView)
        
        // 设置标题标签
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = isSuccess ? UIColor.systemGreen : UIColor.systemRed
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        // 设置消息标签
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = UIColor.label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        containerView.addSubview(messageLabel)
        
        // 设置图片视图
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        imageView.tintColor = isSuccess ? UIColor.systemYellow : UIColor.systemRed
        containerView.addSubview(imageView)
        
        // 设置图片内容
        if let imageObject = image {
            if let uiImage = imageObject as? UIImage {
                imageView.image = uiImage
            } else if let url = imageObject as? URL {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: isSuccess ? "star.fill" : "xmark.circle"))
            } else if let urlString = imageObject as? String, let url = URL(string: urlString) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: isSuccess ? "star.fill" : "xmark.circle"))
            }
        } else {
            // 没有图片时隐藏图片视图
            imageView.isHidden = true
        }
        
        // 设置按钮堆栈视图
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 10
        containerView.addSubview(buttonsStackView)
        
        // 设置约束
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        if message != nil {
            messageLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
            }
            
            if !imageView.isHidden {
                imageView.snp.makeConstraints { make in
                    make.top.equalTo(messageLabel.snp.bottom).offset(15)
                    make.centerX.equalToSuperview()
                    make.width.height.equalTo(200)
                }
                
                buttonsStackView.snp.makeConstraints { make in
                    make.top.equalTo(imageView.snp.bottom).offset(20)
                    make.leading.equalToSuperview().offset(20)
                    make.trailing.equalToSuperview().offset(-20)
                    make.bottom.equalToSuperview().offset(-20)
                    make.height.equalTo(44)
                }
            } else {
                buttonsStackView.snp.makeConstraints { make in
                    make.top.equalTo(messageLabel.snp.bottom).offset(20)
                    make.leading.equalToSuperview().offset(20)
                    make.trailing.equalToSuperview().offset(-20)
                    make.bottom.equalToSuperview().offset(-20)
                    make.height.equalTo(44)
                }
            }
        } else {
            if !imageView.isHidden {
                imageView.snp.makeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(15)
                    make.centerX.equalToSuperview()
                    make.width.height.equalTo(200)
                }
                
                buttonsStackView.snp.makeConstraints { make in
                    make.top.equalTo(imageView.snp.bottom).offset(20)
                    make.leading.equalToSuperview().offset(20)
                    make.trailing.equalToSuperview().offset(-20)
                    make.bottom.equalToSuperview().offset(-20)
                    make.height.equalTo(44)
                }
            } else {
                buttonsStackView.snp.makeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(20)
                    make.leading.equalToSuperview().offset(20)
                    make.trailing.equalToSuperview().offset(-20)
                    make.bottom.equalToSuperview().offset(-20)
                    make.height.equalTo(44)
                }
            }
        }
    }
    
    // MARK: - 公共方法
    
    /// 添加按钮到弹窗
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - style: 按钮样式
    ///   - action: 按钮点击回调
    /// - Returns: 当前弹窗控制器实例，支持链式调用
    @discardableResult
    func addButton(title: String, style: ButtonStyle = .default, action: (() -> Void)? = nil) -> Self {
        let button = AlertButton(title: title, style: style, action: { [weak self] in
            self?.dismiss()
            action?()
        })
        buttons.append(button)
        buttonsStackView.addArrangedSubview(button)
        return self
    }
    
    /// 在指定视图上显示弹窗
    /// - Parameters:
    ///   - parentView: 父视图
    ///   - centerView: 居中参考视图（可选，默认为父视图）
    ///   - animated: 是否使用动画
    func show(in parentView: UIView, centerView: UIView? = nil, animated: Bool = true) {
        // 如果没有按钮，添加一个默认的确定按钮
        if buttons.isEmpty {
            addButton(title: "确定")
        }
        
        // 添加到父视图
        parentView.addSubview(self)
        
        // 设置约束 - 覆盖整个父视图
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 设置容器视图约束 - 相对于指定视图居中
        let referenceView = centerView ?? parentView
        containerView.snp.remakeConstraints { make in
            make.centerX.equalTo(referenceView)
            make.centerY.equalTo(referenceView)
            // 添加宽度约束，确保视图大小正确
            make.width.greaterThanOrEqualTo(300)
            // 添加边缘约束，确保视图不会超出父视图
            make.leading.greaterThanOrEqualTo(parentView).offset(20)
            make.trailing.lessThanOrEqualTo(parentView).offset(-20)
            make.top.greaterThanOrEqualTo(parentView).offset(20)
            make.bottom.lessThanOrEqualTo(parentView).offset(-20)
        }
        
        if animated {
            // 设置初始状态
            self.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            containerView.alpha = 0
            
            // 添加显示动画
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.alpha = 1
            })
            
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerView.alpha = 1
            })
        } else {
            self.alpha = 1
            containerView.alpha = 1
        }
    }
    
    /// 关闭弹窗
    /// - Parameter animated: 是否使用动画
    func dismiss(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
                self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.containerView.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - 动作处理
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !containerView.frame.contains(location) {
            dismiss()
        }
    }
    
    // MARK: - 静态便捷方法
    
    /// 创建并显示一个成功弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - image: 图片（可选）
    ///   - parentView: 父视图
    ///   - centerView: 居中参考视图（可选）
    ///   - buttonTitle: 按钮标题
    ///   - action: 按钮点击回调
    /// - Returns: 创建的弹窗控制器实例
    @discardableResult
    static func showSuccess(title: String, message: String? = nil, image: Any? = nil, in parentView: UIView, centerView: UIView? = nil, buttonTitle: String = "确定", action: (() -> Void)? = nil) -> GameAlertController {
        let alert = GameAlertController(title: title, message: message, image: image, isSuccess: true)
        alert.addButton(title: buttonTitle, style: .success, action: action)
        alert.show(in: parentView, centerView: centerView)
        return alert
    }
    
    /// 创建并显示一个失败弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - image: 图片（可选）
    ///   - parentView: 父视图
    ///   - centerView: 居中参考视图（可选）
    ///   - buttonTitle: 按钮标题
    ///   - action: 按钮点击回调
    /// - Returns: 创建的弹窗控制器实例
    @discardableResult
    static func showFailure(title: String, message: String? = nil, image: Any? = nil, in parentView: UIView, centerView: UIView? = nil, buttonTitle: String = "确定", action: (() -> Void)? = nil) -> GameAlertController {
        let alert = GameAlertController(title: title, message: message, image: image, isSuccess: false)
        alert.addButton(title: buttonTitle, style: .destructive, action: action)
        alert.show(in: parentView, centerView: centerView)
        return alert
    }
    
    /// 创建并显示一个确认弹窗，带有确定和取消按钮
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - image: 图片（可选）
    ///   - parentView: 父视图
    ///   - centerView: 居中参考视图（可选）
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - confirmStyle: 确认按钮样式
    ///   - confirmAction: 确认按钮点击回调
    ///   - cancelAction: 取消按钮点击回调
    /// - Returns: 创建的弹窗控制器实例
    @discardableResult
    static func showConfirmation(title: String, message: String? = nil, image: Any? = nil, in parentView: UIView, centerView: UIView? = nil, confirmTitle: String = "确定", cancelTitle: String = "取消", confirmStyle: ButtonStyle = .default, confirmAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) -> GameAlertController {
        let alert = GameAlertController(title: title, message: message, image: image)
        alert.addButton(title: cancelTitle, style: .cancel, action: cancelAction)
        alert.addButton(title: confirmTitle, style: confirmStyle, action: confirmAction)
        alert.show(in: parentView, centerView: centerView)
        return alert
    }
}

// MARK: - UIGestureRecognizerDelegate
extension GameAlertController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 只有点击背景区域时才响应手势
        let location = touch.location(in: self)
        return !containerView.frame.contains(location)
    }
}
