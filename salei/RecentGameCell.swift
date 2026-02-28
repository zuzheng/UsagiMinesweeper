//
//  RecentGameCell.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

class RecentGameCell: UITableViewCell {
    
    // MARK: - UI元素
    private let dateLabel = UILabel()
    private let difficultyLabel = UILabel()
    private let specialModeLabel = UILabel()
    private let timeLabel = UILabel()
    private let minesLabel = UILabel()
    private let resultLabel = UILabel()
    private let containerView = UIView()
    
    // MARK: - 初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 清除之前的内容
        dateLabel.text = nil
        difficultyLabel.text = nil
        specialModeLabel.text = nil
        timeLabel.text = nil
        minesLabel.text = nil
        resultLabel.text = nil
        specialModeLabel.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI() {
        // 设置基本样式
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 添加容器视图
        contentView.addSubview(containerView)
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        // 添加UI元素到容器视图
        containerView.addSubview(dateLabel)
        containerView.addSubview(difficultyLabel)
        containerView.addSubview(specialModeLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(minesLabel)
        containerView.addSubview(resultLabel)
        
        // 配置标签样式
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .label
        
        difficultyLabel.font = UIFont.systemFont(ofSize: 14)
        difficultyLabel.textColor = .label
        
        specialModeLabel.font = UIFont.systemFont(ofSize: 14)
        specialModeLabel.textColor = .secondaryLabel
        specialModeLabel.isHidden = true
        
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .label
        
        minesLabel.font = UIFont.systemFont(ofSize: 14)
        minesLabel.textColor = .label
        
        resultLabel.font = UIFont.boldSystemFont(ofSize: 14)
        resultLabel.textAlignment = .right
        
        // 设置约束
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualTo(resultLabel.snp.leading).offset(-8)
        }
        
        difficultyLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
        }
        
        specialModeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(difficultyLabel)
            make.leading.equalTo(difficultyLabel.snp.trailing).offset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(difficultyLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        minesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.leading.equalTo(timeLabel.snp.trailing).offset(12)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
            make.width.equalTo(40)
        }
    }
    
    // MARK: - 配置方法
    func configure(with gameRecord: GameRecordManager.GameRecord) {
        // 设置日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateLabel.text = dateFormatter.string(from: gameRecord.date)
        
        // 设置难度
        let difficulty = GameDifficulty(rawValue: gameRecord.difficulty)?.title ?? "未知"
        difficultyLabel.text = "\(difficulty)难度"
        
        // 设置特殊模式（如果有）
        if gameRecord.specialMode != SpecialGameModeType.normal.rawValue {
            let specialMode = SpecialGameModeType(rawValue: gameRecord.specialMode)?.title ?? "特殊模式"
            specialModeLabel.text = specialMode
            specialModeLabel.isHidden = false
        } else {
            specialModeLabel.isHidden = true
        }
        
        // 设置用时
        if let timeUsed = gameRecord.timeUsed {
            timeLabel.text = "用时: \(formatTime(timeUsed))"
        } else {
            timeLabel.text = "用时: --:--"
        }
        
        // 设置地雷数
        minesLabel.text = "地雷: \(gameRecord.minesFound)/\(gameRecord.totalMines)"
        
        // 设置结果
        resultLabel.text = gameRecord.isWin ? "胜利" : "失败"
        resultLabel.textColor = gameRecord.isWin ? .systemGreen : .systemRed
        
        // 设置背景颜色
        updateTheme()
    }
    
    // 更新主题
    func updateTheme() {
        let cardColor = MinesweeperTheme.shared.currentTheme == .cute ?
            MinesweeperTheme.Colors.Cute.cellCovered.withAlphaComponent(0.7) :
            MinesweeperTheme.Colors.Grass.cellCovered.withAlphaComponent(0.7)
        
        let selectedColor = MinesweeperTheme.shared.currentTheme == .cute ?
            MinesweeperTheme.Colors.Cute.cellCovered :
            MinesweeperTheme.Colors.Grass.cellCovered
        
        containerView.backgroundColor = cardColor
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = selectedColor
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    // 格式化时间
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}