//
//  PointsStoreViewController.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit
import SnapKit

class PointsStoreViewController: UIViewController {
    
    // MARK: - UI元素
    private var contentView: UIView!
    private var pointsLabel: UILabel!
    private var cardPacksTableView: UITableView!
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 注册主题变更通知
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: NSNotification.Name("ThemeDidChangeNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePointsLabel()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        title = "积分商店"
        
        // 应用背景主题
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        
        // 内容视图
        contentView = UIView()
        contentView.backgroundColor = .clear
        view.addSubview(contentView)
        
        // 积分标签
        pointsLabel = UILabel()
        pointsLabel.textAlignment = .center
        pointsLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        contentView.addSubview(pointsLabel)
        
        // 卡包表格视图
        cardPacksTableView = UITableView()
        cardPacksTableView.delegate = self
        cardPacksTableView.dataSource = self
        cardPacksTableView.register(CardPackCell.self, forCellReuseIdentifier: "CardPackCell")
        cardPacksTableView.backgroundColor = .clear
        cardPacksTableView.separatorStyle = .none
        cardPacksTableView.rowHeight = 120
        contentView.addSubview(cardPacksTableView)
        
        // 设置约束
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pointsLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.leading.trailing.equalTo(contentView).inset(20)
            make.height.equalTo(40)
        }
        
        cardPacksTableView.snp.makeConstraints { make in
            make.top.equalTo(pointsLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalTo(contentView)
        }
    }
    
    // MARK: - 更新UI
    
    private func updatePointsLabel() {
        let points = PointsManager.shared.currentPoints
        pointsLabel.text = "当前积分: \(points) 💎"
    }
    
    // MARK: - 主题变更
    
    @objc private func themeDidChange() {
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        cardPacksTableView.reloadData()
    }
    
    // MARK: - 抽卡操作
    
    private func drawCard(packId: Int) {
        let result = PointsManager.shared.drawCard(packId: packId)
        
        if result.success {
            // 更新积分显示
            updatePointsLabel()
            
            // 显示抽卡结果
            if let cardId = result.cardId {
                showCardDrawResult(packId: packId, cardId: cardId)
            } else {
                showAlert(title: "抽卡成功", message: "恭喜！您已经解锁了该卡包的所有图片！")
            }
        } else {
            // 积分不足
            showAlert(title: "积分不足", message: "您的积分不足以抽取此卡包，请继续游戏获取更多积分！")
        }
    }
    
    private func showCardDrawResult(packId: Int, cardId: Int) {
        // 根据卡包ID和卡片ID获取对应的图片类型
        let cardType: ImageManager.ImageCategory
        let typeName: String
        
        switch packId {
        case 1:
            cardType = .playing
            typeName = "游戏中"
        case 2:
            cardType = .victory
            typeName = "胜利"
        case 3:
            cardType = .defeat
            typeName = "失败"
        default:
            cardType = .playing
            typeName = "游戏中"
        }
        
        // 获取图片URL
        let imageUrl = ImageManager.shared.getImageUrlByTypeAndIndex(type: getImageType(from: cardType), index: cardId)
        
        // 显示抽卡结果弹窗
        GameAlertController.showSuccess(
            title: "抽卡成功！",
            message: "恭喜获得新的\(typeName)表情：#\(cardId)",
            image: imageUrl,
            in: view,
            buttonTitle: "太棒了",
            action: nil
        )
    }
    
    private func getImageType(from category: ImageManager.ImageCategory) -> ImageManager.ImageType {
        switch category {
        case .playing:
            return .playing
        case .victory:
            return .victory
        case .defeat:
            return .defeat
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PointsStoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PointsManager.shared.cardPacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardPackCell", for: indexPath) as! CardPackCell
        let cardPack = PointsManager.shared.cardPacks[indexPath.row]
        cell.configure(with: cardPack)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cardPack = PointsManager.shared.cardPacks[indexPath.row]
        
        // 显示抽卡确认弹窗
        let alert = UIAlertController(
            title: "抽取卡包",
            message: "确定要花费 \(cardPack.cost) 积分抽取「\(cardPack.name)」吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.drawCard(packId: cardPack.id)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - 卡包单元格

class CardPackCell: UITableViewCell {
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let costLabel = UILabel()
    private let iconLabel = UILabel()
    private let progressView = UIProgressView()
    private let progressLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 容器视图
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4
        contentView.addSubview(containerView)
        
        // 图标标签
        iconLabel.font = UIFont.systemFont(ofSize: 36)
        iconLabel.textAlignment = .center
        containerView.addSubview(iconLabel)
        
        // 名称标签
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        containerView.addSubview(nameLabel)
        
        // 描述标签
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2
        containerView.addSubview(descriptionLabel)
        
        // 价格标签
        costLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        costLabel.textAlignment = .right
        containerView.addSubview(costLabel)
        
        // 进度条
        progressView.progressTintColor = UIColor.systemBlue
        progressView.trackTintColor = UIColor.systemGray5
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        containerView.addSubview(progressView)
        
        // 进度标签
        progressLabel.font = UIFont.systemFont(ofSize: 12)
        progressLabel.textColor = .gray
        progressLabel.textAlignment = .right
        containerView.addSubview(progressLabel)
        
        // 设置约束
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        iconLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
            make.width.height.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(16)
            make.leading.equalTo(iconLabel.snp.trailing).offset(12)
            make.trailing.equalTo(containerView).offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(containerView).offset(-16)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(containerView).offset(-16)
            make.height.equalTo(4)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
        }
        
        costLabel.snp.makeConstraints { make in
            make.trailing.equalTo(containerView).offset(-16)
            make.top.equalTo(progressView.snp.bottom).offset(4)
        }
    }
    
    func configure(with cardPack: CardPack) {
        // 设置卡包图标
        switch cardPack.cardType {
        case .playing:
            iconLabel.text = "🎮"
        case .victory:
            iconLabel.text = "🏆"
        case .defeat:
            iconLabel.text = "😢"
        }
        
        // 设置卡包信息
        nameLabel.text = cardPack.name
        descriptionLabel.text = cardPack.description
        costLabel.text = "\(cardPack.cost) 💎"
        
        // 设置解锁进度
        let unlockedCount: Int
        let totalCount: Int
        
        switch cardPack.cardType {
        case .playing:
            unlockedCount = ImageManager.shared.getUnlockedImageIndices(category: .playing).count
            totalCount = ImageManager.shared.getImageTotalCount(category: .playing)
        case .victory:
            unlockedCount = ImageManager.shared.getUnlockedImageIndices(category: .victory).count
            totalCount = ImageManager.shared.getImageTotalCount(category: .victory)
        case .defeat:
            unlockedCount = ImageManager.shared.getUnlockedImageIndices(category: .defeat).count
            totalCount = ImageManager.shared.getImageTotalCount(category: .defeat)
        }
        
        let progress = Float(unlockedCount) / Float(totalCount)
        progressView.progress = progress
        progressLabel.text = "已解锁: \(unlockedCount)/\(totalCount)"
        
        // 应用主题
        MinesweeperTheme.shared.applyCardTheme(to: containerView)
    }
}

// MARK: - 主题扩展

extension MinesweeperTheme {
    func applyCardTheme(to view: UIView) {
        switch currentTheme {
        case .cute:
            view.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.96, alpha: 1.0)
        case .grass:
            view.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        }
    }
}
