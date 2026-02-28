//
//  RecordViewController.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

class RecordViewController: UIViewController {
    
    // MARK: - UI元素
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var segmentedControl: UISegmentedControl!
    
    // 统计概览视图
    private var overviewContainerView: UIView!
    private var statsCardsStackView: UIStackView!
    private var winRateChartView: PieChartView!
    private var monthlyStatsChartView: BarChartView!
    
    // 难度统计视图
    private var difficultyContainerView: UIView!
    private var difficultySegmentedControl: UISegmentedControl!
    private var difficultyStatsStackView: UIStackView!
    private var difficultyChartView: BarChartView!
    
    // 特殊模式统计视图
    private var specialModeContainerView: UIView!
    private var specialModeSegmentedControl: UISegmentedControl!
    private var specialModeStatsStackView: UIStackView!
    private var specialModeChartView: BarChartView!
    
    // 最近游戏记录视图
    private var recentGamesContainerView: UIView!
    private var recentGamesTableView: UITableView!
    private var exportButton: UIButton! // 新增：导出按钮
    
    // 数据源
    private var currentSection: Int = 0 // 0: 总览, 1: 难度统计, 2: 特殊模式统计, 3: 最近游戏
    private var currentDifficultyIndex: Int = 0
    private var currentSpecialModeIndex: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 注册主题变更通知
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: NSNotification.Name("ThemeDidChangeNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData() // 每次视图出现时更新数据
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        // 应用主题背景
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        title = "游戏记录"
        
        // 添加导出按钮到导航栏
        let exportBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportData))
        navigationItem.rightBarButtonItem = exportBarButton
        
        // 创建滚动视图
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        // 创建内容视图
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        // 创建分段控制器
        segmentedControl = UISegmentedControl(items: ["总览", "难度统计", "特殊模式", "最近游戏"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        contentView.addSubview(segmentedControl)
        
        // 创建各个部分的容器视图
        setupOverviewContainer()
        setupDifficultyContainer()
        setupSpecialModeContainer()
        setupRecentGamesContainer()
        
        // 设置约束
        setupConstraints()
        
        // 默认显示总览部分
        showSelectedSection()
    }
    
    private func setupOverviewContainer() {
        overviewContainerView = UIView()
        overviewContainerView.isHidden = false
        contentView.addSubview(overviewContainerView)
        
        // 创建统计卡片堆栈视图
        statsCardsStackView = UIStackView()
        statsCardsStackView.axis = .vertical
        statsCardsStackView.spacing = 16
        statsCardsStackView.distribution = .fillEqually
        overviewContainerView.addSubview(statsCardsStackView)
        
        // 添加统计卡片
        let totalGamesCard = createStatCard(title: "总游戏场数", value: "0")
        let winRateCard = createStatCard(title: "胜率", value: "0%")
        let maxStreakCard = createStatCard(title: "最大连胜", value: "0")
        let currentStreakCard = createStatCard(title: "当前连胜", value: "0")
        let bestTimeCard = createStatCard(title: "最佳时间", value: "--:--")
        let totalPlayTimeCard = createStatCard(title: "总游戏时长", value: "--:--") // 新增：总游戏时长
        let longestGameCard = createStatCard(title: "最长游戏", value: "--:--") // 新增：最长游戏
        let avgMinesCard = createStatCard(title: "平均找到地雷", value: "0") // 新增：平均找到地雷
        let totalMinesCard = createStatCard(title: "总找到地雷", value: "0") // 新增：总找到地雷
        
        statsCardsStackView.addArrangedSubview(createHorizontalCardStack(cards: [totalGamesCard, winRateCard]))
        statsCardsStackView.addArrangedSubview(createHorizontalCardStack(cards: [maxStreakCard, currentStreakCard]))
        statsCardsStackView.addArrangedSubview(createHorizontalCardStack(cards: [bestTimeCard, totalPlayTimeCard]))
        statsCardsStackView.addArrangedSubview(createHorizontalCardStack(cards: [longestGameCard, avgMinesCard]))
        statsCardsStackView.addArrangedSubview(createHorizontalCardStack(cards: [totalMinesCard]))
        
        // 创建胜率饼图
        let winRateChartContainer = createChartContainer(title: "胜率分布")
        overviewContainerView.addSubview(winRateChartContainer)
        
        winRateChartView = PieChartView()
        winRateChartView.legend.enabled = true
        winRateChartView.legend.horizontalAlignment = .center
        winRateChartView.legend.verticalAlignment = .bottom
        winRateChartView.legend.orientation = .horizontal
        winRateChartView.legend.drawInside = false
        winRateChartView.legend.form = .circle
        winRateChartView.drawHoleEnabled = true
        winRateChartView.holeColor = .clear
        winRateChartView.holeRadiusPercent = 0.5
        winRateChartView.rotationEnabled = false
        winRateChartView.highlightPerTapEnabled = false
        winRateChartView.entryLabelColor = .white
        winRateChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .bold)
        winRateChartContainer.addSubview(winRateChartView)
        
        // 创建月度统计柱状图
        let monthlyStatsChartContainer = createChartContainer(title: "月度游戏统计")
        overviewContainerView.addSubview(monthlyStatsChartContainer)
        
        monthlyStatsChartView = BarChartView()
        monthlyStatsChartView.legend.enabled = true
        monthlyStatsChartView.legend.horizontalAlignment = .center
        monthlyStatsChartView.legend.verticalAlignment = .bottom
        monthlyStatsChartView.legend.orientation = .horizontal
        monthlyStatsChartView.legend.drawInside = false
        monthlyStatsChartView.xAxis.labelPosition = .bottom
        monthlyStatsChartView.xAxis.granularity = 1
        monthlyStatsChartView.leftAxis.axisMinimum = 0
        monthlyStatsChartView.rightAxis.enabled = false
        monthlyStatsChartView.doubleTapToZoomEnabled = false
        monthlyStatsChartView.pinchZoomEnabled = false
        monthlyStatsChartContainer.addSubview(monthlyStatsChartView)
        
        // 设置约束
        statsCardsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        winRateChartView.snp.makeConstraints { make in
            make.top.equalTo(winRateChartContainer).offset(40) // 标题高度
            make.leading.equalTo(winRateChartContainer).offset(16)
            make.trailing.equalTo(winRateChartContainer).offset(-16)
            make.bottom.equalTo(winRateChartContainer).offset(-16)
        }
        
        winRateChartContainer.snp.makeConstraints { make in
            make.top.equalTo(statsCardsStackView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(240)
        }
        
        monthlyStatsChartView.snp.makeConstraints { make in
            make.top.equalTo(monthlyStatsChartContainer).offset(40) // 标题高度
            make.leading.equalTo(monthlyStatsChartContainer).offset(16)
            make.trailing.equalTo(monthlyStatsChartContainer).offset(-16)
            make.bottom.equalTo(monthlyStatsChartContainer).offset(-16)
        }
        
        monthlyStatsChartContainer.snp.makeConstraints { make in
            make.top.equalTo(winRateChartContainer.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(240)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupDifficultyContainer() {
        difficultyContainerView = UIView()
        difficultyContainerView.isHidden = true
        contentView.addSubview(difficultyContainerView)
        
        // 创建难度分段控制器
        difficultySegmentedControl = UISegmentedControl(items: ["简单", "中等", "困难"])
        difficultySegmentedControl.selectedSegmentIndex = 0
        difficultySegmentedControl.addTarget(self, action: #selector(difficultySegmentChanged(_:)), for: .valueChanged)
        difficultyContainerView.addSubview(difficultySegmentedControl)
        
        // 创建统计卡片堆栈视图
        difficultyStatsStackView = UIStackView()
        difficultyStatsStackView.axis = .vertical
        difficultyStatsStackView.spacing = 16
        difficultyStatsStackView.distribution = .fillEqually
        difficultyContainerView.addSubview(difficultyStatsStackView)
        
        // 添加统计卡片
        let totalGamesCard = createStatCard(title: "总游戏场数", value: "0")
        let winRateCard = createStatCard(title: "胜率", value: "0%")
        let bestTimeCard = createStatCard(title: "最佳时间", value: "--:--")
        let totalPlayTimeCard = createStatCard(title: "总游戏时长", value: "--:--") // 新增：总游戏时长
        let longestGameCard = createStatCard(title: "最长游戏", value: "--:--") // 新增：最长游戏
        let avgMinesCard = createStatCard(title: "平均找到地雷", value: "0") // 新增：平均找到地雷
        
        difficultyStatsStackView.addArrangedSubview(createHorizontalCardStack(cards: [totalGamesCard, winRateCard]))
        difficultyStatsStackView.addArrangedSubview(createHorizontalCardStack(cards: [bestTimeCard, totalPlayTimeCard]))
        difficultyStatsStackView.addArrangedSubview(createHorizontalCardStack(cards: [longestGameCard, avgMinesCard]))
        
        // 创建难度统计柱状图
        let difficultyChartContainer = createChartContainer(title: "难度统计")
        difficultyContainerView.addSubview(difficultyChartContainer)
        
        difficultyChartView = BarChartView()
        difficultyChartView.legend.enabled = true
        difficultyChartView.legend.horizontalAlignment = .center
        difficultyChartView.legend.verticalAlignment = .bottom
        difficultyChartView.legend.orientation = .horizontal
        difficultyChartView.legend.drawInside = false
        difficultyChartView.xAxis.labelPosition = .bottom
        difficultyChartView.xAxis.granularity = 1
        difficultyChartView.leftAxis.axisMinimum = 0
        difficultyChartView.rightAxis.enabled = false
        difficultyChartView.doubleTapToZoomEnabled = false
        difficultyChartView.pinchZoomEnabled = false
        difficultyChartContainer.addSubview(difficultyChartView)
        
        // 设置约束
        difficultySegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        difficultyStatsStackView.snp.makeConstraints { make in
            make.top.equalTo(difficultySegmentedControl.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        difficultyChartView.snp.makeConstraints { make in
            make.top.equalTo(difficultyChartContainer).offset(40) // 标题高度
            make.leading.equalTo(difficultyChartContainer).offset(16)
            make.trailing.equalTo(difficultyChartContainer).offset(-16)
            make.bottom.equalTo(difficultyChartContainer).offset(-16)
        }
        
        difficultyChartContainer.snp.makeConstraints { make in
            make.top.equalTo(difficultyStatsStackView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(240)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupSpecialModeContainer() {
        specialModeContainerView = UIView()
        specialModeContainerView.isHidden = true
        contentView.addSubview(specialModeContainerView)
        
        // 创建特殊模式分段控制器
        specialModeSegmentedControl = UISegmentedControl(items: ["普通模式", "限时挑战", "盲模式", "移动地雷"])
        specialModeSegmentedControl.selectedSegmentIndex = 0
        specialModeSegmentedControl.addTarget(self, action: #selector(specialModeSegmentChanged(_:)), for: .valueChanged)
        specialModeContainerView.addSubview(specialModeSegmentedControl)
        
        // 创建统计卡片堆栈视图
        specialModeStatsStackView = UIStackView()
        specialModeStatsStackView.axis = .vertical
        specialModeStatsStackView.spacing = 16
        specialModeStatsStackView.distribution = .fillEqually
        specialModeContainerView.addSubview(specialModeStatsStackView)
        
        // 添加统计卡片
        let totalGamesCard = createStatCard(title: "总游戏场数", value: "0")
        let winRateCard = createStatCard(title: "胜率", value: "0%")
        let bestTimeCard = createStatCard(title: "最佳时间", value: "--:--")
        let totalPlayTimeCard = createStatCard(title: "总游戏时长", value: "--:--") // 新增：总游戏时长
        let longestGameCard = createStatCard(title: "最长游戏", value: "--:--") // 新增：最长游戏
        let avgMinesCard = createStatCard(title: "平均找到地雷", value: "0") // 新增：平均找到地雷
        
        specialModeStatsStackView.addArrangedSubview(createHorizontalCardStack(cards: [totalGamesCard, winRateCard]))
        specialModeStatsStackView.addArrangedSubview(createHorizontalCardStack(cards: [bestTimeCard, totalPlayTimeCard]))
        specialModeStatsStackView.addArrangedSubview(createHorizontalCardStack(cards: [longestGameCard, avgMinesCard]))
        
        // 创建特殊模式统计柱状图
        let specialModeChartContainer = createChartContainer(title: "特殊模式统计")
        specialModeContainerView.addSubview(specialModeChartContainer)
        
        specialModeChartView = BarChartView()
        specialModeChartView.legend.enabled = true
        specialModeChartView.legend.horizontalAlignment = .center
        specialModeChartView.legend.verticalAlignment = .bottom
        specialModeChartView.legend.orientation = .horizontal
        specialModeChartView.legend.drawInside = false
        specialModeChartView.xAxis.labelPosition = .bottom
        specialModeChartView.xAxis.granularity = 1
        specialModeChartView.leftAxis.axisMinimum = 0
        specialModeChartView.rightAxis.enabled = false
        specialModeChartView.doubleTapToZoomEnabled = false
        specialModeChartView.pinchZoomEnabled = false
        specialModeChartContainer.addSubview(specialModeChartView)
        
        // 设置约束
        specialModeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        specialModeStatsStackView.snp.makeConstraints { make in
            make.top.equalTo(specialModeSegmentedControl.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        specialModeChartView.snp.makeConstraints { make in
            make.top.equalTo(specialModeChartContainer).offset(40) // 标题高度
            make.leading.equalTo(specialModeChartContainer).offset(16)
            make.trailing.equalTo(specialModeChartContainer).offset(-16)
            make.bottom.equalTo(specialModeChartContainer).offset(-16)
        }
        
        specialModeChartContainer.snp.makeConstraints { make in
            make.top.equalTo(specialModeStatsStackView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(240)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupRecentGamesContainer() {
        recentGamesContainerView = UIView()
        recentGamesContainerView.isHidden = true
        contentView.addSubview(recentGamesContainerView)
        
        // 创建标题标签
        let titleLabel = UILabel()
        titleLabel.text = "最近游戏记录"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        recentGamesContainerView.addSubview(titleLabel)
        
        // 创建表格视图
        recentGamesTableView = UITableView(frame: .zero, style: .plain)
        recentGamesTableView.delegate = self
        recentGamesTableView.dataSource = self
        recentGamesTableView.register(RecentGameCell.self, forCellReuseIdentifier: "RecentGameCell")
        recentGamesTableView.isScrollEnabled = false // 禁用表格滚动，使用外部滚动视图
        recentGamesTableView.separatorStyle = .none
        recentGamesTableView.backgroundColor = .clear
        recentGamesContainerView.addSubview(recentGamesTableView)
        
        // 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        recentGamesTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(400) // 固定高度，显示最近10条记录
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        overviewContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        difficultyContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        specialModeContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        recentGamesContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    // MARK: - 辅助UI方法
    
    private func createStatCard(title: String, value: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = MinesweeperTheme.shared.currentTheme == .cute ? 
            MinesweeperTheme.Colors.Cute.cellCovered : MinesweeperTheme.Colors.Grass.cellCovered
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        cardView.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.textColor = .label
        valueLabel.tag = 100 // 用于后续更新值
        cardView.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        return cardView
    }
    
    private func createHorizontalCardStack(cards: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: cards)
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private func createChartContainer(title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = MinesweeperTheme.shared.currentTheme == .cute ? 
            MinesweeperTheme.Colors.Cute.cellCovered : MinesweeperTheme.Colors.Grass.cellCovered
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        return containerView
    }
    
    // MARK: - 事件处理
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentSection = sender.selectedSegmentIndex
        showSelectedSection()
    }
    
    @objc private func difficultySegmentChanged(_ sender: UISegmentedControl) {
        currentDifficultyIndex = sender.selectedSegmentIndex
        updateDifficultyStats()
    }
    
    @objc private func specialModeSegmentChanged(_ sender: UISegmentedControl) {
        currentSpecialModeIndex = sender.selectedSegmentIndex
        updateSpecialModeStats()
    }
    
    private func showSelectedSection() {
        overviewContainerView.isHidden = currentSection != 0
        difficultyContainerView.isHidden = currentSection != 1
        specialModeContainerView.isHidden = currentSection != 2
        recentGamesContainerView.isHidden = currentSection != 3
        
        // 更新当前选中部分的数据
        updateData()
    }
    
    // MARK: - 数据更新
    
    private func updateData() {
        switch currentSection {
        case 0:
            updateOverviewStats()
        case 1:
            updateDifficultyStats()
        case 2:
            updateSpecialModeStats()
        case 3:
            recentGamesTableView.reloadData()
        default:
            break
        }
    }
    
    private func updateOverviewStats() {
        let recordManager = GameRecordManager.shared
        let stats = recordManager.getOverallStatsSummary()
        
        // 更新统计卡片
        if let stackView = statsCardsStackView.arrangedSubviews[0] as? UIStackView {
            let totalGamesCard = stackView.arrangedSubviews[0]
            if let totalGamesLabel = totalGamesCard.viewWithTag(100) as? UILabel {
                totalGamesLabel.text = "\(stats.totalGames)"
            }
        }
        
        if let stackView = statsCardsStackView.arrangedSubviews[0] as? UIStackView {
            let winRateCard = stackView.arrangedSubviews[1]
            if let winRateLabel = winRateCard.viewWithTag(100) as? UILabel {
                winRateLabel.text = String(format: "%.1f%%", stats.winRate)
            }
        }
        
        if let stackView = statsCardsStackView.arrangedSubviews[1] as? UIStackView {
            let maxStreakCard = stackView.arrangedSubviews[0]
            if let maxStreakLabel = maxStreakCard.viewWithTag(100) as? UILabel {
                maxStreakLabel.text = "\(stats.maxWinStreak)"
            }
        }
        
        if let stackView = statsCardsStackView.arrangedSubviews[1] as? UIStackView {
            let currentStreakCard = stackView.arrangedSubviews[1]
            if let currentStreakLabel = currentStreakCard.viewWithTag(100) as? UILabel {
                currentStreakLabel.text = "\(stats.currentWinStreak)"
            }
        }
        
        if let stackView = statsCardsStackView.arrangedSubviews[2] as? UIStackView {
            let bestTimeCard = stackView.arrangedSubviews[0]
            if let bestTimeLabel = bestTimeCard.viewWithTag(100) as? UILabel {
                if let bestTime = stats.bestTime {
                    bestTimeLabel.text = formatTime(bestTime)
                } else {
                    bestTimeLabel.text = "--:--"
                }
            }
        }
        
        // 更新总游戏时长
        if let stackView = statsCardsStackView.arrangedSubviews[2] as? UIStackView {
            let totalPlayTimeCard = stackView.arrangedSubviews[1]
            if let totalPlayTimeLabel = totalPlayTimeCard.viewWithTag(100) as? UILabel {
                let hours = stats.totalPlayTime / 3600
                let minutes = (stats.totalPlayTime % 3600) / 60
                let seconds = stats.totalPlayTime % 60
                
                if hours > 0 {
                    totalPlayTimeLabel.text = String(format: "%d:%02d:%02d", hours, minutes, seconds)
                } else {
                    totalPlayTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
                }
            }
        }
        
        // 更新最长游戏时间
        if let stackView = statsCardsStackView.arrangedSubviews[3] as? UIStackView {
            let longestGameCard = stackView.arrangedSubviews[0]
            if let longestGameLabel = longestGameCard.viewWithTag(100) as? UILabel {
                if let longestGame = stats.longestGame {
                    longestGameLabel.text = formatTime(longestGame)
                } else {
                    longestGameLabel.text = "--:--"
                }
            }
        }
        
        // 更新平均找到地雷数
        if let stackView = statsCardsStackView.arrangedSubviews[3] as? UIStackView {
            let avgMinesCard = stackView.arrangedSubviews[1]
            if let avgMinesLabel = avgMinesCard.viewWithTag(100) as? UILabel {
                avgMinesLabel.text = String(format: "%.1f", stats.averageMinesFound)
            }
        }
        
        // 更新总找到地雷数
        if let stackView = statsCardsStackView.arrangedSubviews[4] as? UIStackView {
            let totalMinesCard = stackView.arrangedSubviews[0]
            if let totalMinesLabel = totalMinesCard.viewWithTag(100) as? UILabel {
                totalMinesLabel.text = "\(stats.totalMinesFound)"
            }
        }
        
        // 更新胜率饼图
        updateWinRateChart(wins: stats.totalWins, total: stats.totalGames)
        
        // 更新月度统计图表
        updateMonthlyStatsChart()
    }
    
    private func updateDifficultyStats() {
        let recordManager = GameRecordManager.shared
        let difficulty = GameDifficulty.allCases[currentDifficultyIndex]
        let stats = recordManager.getDifficultyStatsSummary(difficulty: difficulty.rawValue)
        
        // 更新统计卡片
        if let stackView = difficultyStatsStackView.arrangedSubviews[0] as? UIStackView {
            let totalGamesCard = stackView.arrangedSubviews[0]
            if let totalGamesLabel = totalGamesCard.viewWithTag(100) as? UILabel {
                totalGamesLabel.text = "\(stats.totalGames)"
            }
        }
        
        if let stackView = difficultyStatsStackView.arrangedSubviews[0] as? UIStackView {
            let winRateCard = stackView.arrangedSubviews[1]
            if let winRateLabel = winRateCard.viewWithTag(100) as? UILabel {
                winRateLabel.text = String(format: "%.1f%%", stats.winRate)
            }
        }
        
        if let stackView = difficultyStatsStackView.arrangedSubviews[1] as? UIStackView {
            let bestTimeCard = stackView.arrangedSubviews[0]
            if let bestTimeLabel = bestTimeCard.viewWithTag(100) as? UILabel {
                if let bestTime = stats.bestTime {
                    bestTimeLabel.text = formatTime(bestTime)
                } else {
                    bestTimeLabel.text = "--:--"
                }
            }
        }
        
        if let stackView = difficultyStatsStackView.arrangedSubviews[1] as? UIStackView {
            let avgTimeCard = stackView.arrangedSubviews[1]
            if let avgTimeLabel = avgTimeCard.viewWithTag(100) as? UILabel {
                if let avgTime = stats.averageTime {
                    avgTimeLabel.text = formatTime(avgTime)
                } else {
                    avgTimeLabel.text = "--:--"
                }
            }
        }
        
        // 更新难度统计图表
        updateDifficultyChart(wins: stats.totalWins, losses: stats.totalGames - stats.totalWins)
    }
    
    private func updateSpecialModeStats() {
        let recordManager = GameRecordManager.shared
        let specialMode = SpecialGameModeType.allCases[currentSpecialModeIndex]
        let stats = recordManager.getSpecialModeStatsSummary(specialMode: specialMode.rawValue)
        
        // 更新统计卡片
        if let stackView = specialModeStatsStackView.arrangedSubviews[0] as? UIStackView {
            let totalGamesCard = stackView.arrangedSubviews[0]
            if let totalGamesLabel = totalGamesCard.viewWithTag(100) as? UILabel {
                totalGamesLabel.text = "\(stats.totalGames)"
            }
        }
        
        if let stackView = specialModeStatsStackView.arrangedSubviews[0] as? UIStackView {
            let winRateCard = stackView.arrangedSubviews[1]
            if let winRateLabel = winRateCard.viewWithTag(100) as? UILabel {
                winRateLabel.text = String(format: "%.1f%%", stats.winRate)
            }
        }
        
        if let stackView = specialModeStatsStackView.arrangedSubviews[1] as? UIStackView {
            let bestTimeCard = stackView.arrangedSubviews[0]
            if let bestTimeLabel = bestTimeCard.viewWithTag(100) as? UILabel {
                if let bestTime = stats.bestTime {
                    bestTimeLabel.text = formatTime(bestTime)
                } else {
                    bestTimeLabel.text = "--:--"
                }
            }
        }
        
        if let stackView = specialModeStatsStackView.arrangedSubviews[1] as? UIStackView {
            let modeDescCard = stackView.arrangedSubviews[1]
            if let modeDescLabel = modeDescCard.viewWithTag(100) as? UILabel {
                modeDescLabel.text = specialMode.description
                modeDescLabel.font = UIFont.systemFont(ofSize: 14) // 描述文字小一点
                modeDescLabel.numberOfLines = 0 // 允许多行
            }
        }
        
        // 更新特殊模式统计图表
        updateSpecialModeChart(wins: stats.totalWins, losses: stats.totalGames - stats.totalWins)
    }
    
    // MARK: - 图表更新
    
    private func updateWinRateChart(wins: Int, total: Int) {
        let losses = total - wins
        
        // 创建饼图数据
        let entries = [
            PieChartDataEntry(value: Double(wins), label: "胜利"),
            PieChartDataEntry(value: Double(losses), label: "失败")
        ]
        
        let dataSet = PieChartDataSet(entries: entries, label: "游戏结果")
        dataSet.colors = [UIColor.systemGreen, UIColor.systemRed]
        dataSet.valueTextColor = .white
        dataSet.valueFont = .systemFont(ofSize: 14)
        dataSet.valueFormatter = DefaultValueFormatter(formatter: NumberFormatter())
        
        let data = PieChartData(dataSet: dataSet)
        winRateChartView.data = data
        winRateChartView.animate(xAxisDuration: 1.0)
    }
    
    private func updateMonthlyStatsChart() {
        let monthlyStats = GameRecordManager.shared.getMonthlyStats(months: 6)
        
        // 创建柱状图数据
        var winEntries: [BarChartDataEntry] = []
        var lossEntries: [BarChartDataEntry] = []
        var xLabels: [String] = []
        
        for (index, stat) in monthlyStats.enumerated() {
            winEntries.append(BarChartDataEntry(x: Double(index), y: Double(stat.wins)))
            lossEntries.append(BarChartDataEntry(x: Double(index), y: Double(stat.losses)))
            
            // 格式化月份标签 (yyyy-MM -> MM月)
            let components = stat.month.split(separator: "-")
            if components.count == 2 {
                xLabels.append("\(components[1])月")
            } else {
                xLabels.append(stat.month)
            }
        }
        
        let winDataSet = BarChartDataSet(entries: winEntries, label: "胜利")
        winDataSet.setColor(UIColor.systemGreen)
        winDataSet.valueTextColor = .label
        winDataSet.valueFont = .systemFont(ofSize: 10)
        
        let lossDataSet = BarChartDataSet(entries: lossEntries, label: "失败")
        lossDataSet.setColor(UIColor.systemRed)
        lossDataSet.valueTextColor = .label
        lossDataSet.valueFont = .systemFont(ofSize: 10)
        
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        
        let data = BarChartData(dataSets: [winDataSet, lossDataSet])
        data.barWidth = barWidth
        data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        monthlyStatsChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
        monthlyStatsChartView.xAxis.granularity = 1
        monthlyStatsChartView.data = data
        monthlyStatsChartView.animate(yAxisDuration: 1.0)
    }
    
    private func updateDifficultyChart(wins: Int, losses: Int) {
        // 创建柱状图数据
        let entries = [
            BarChartDataEntry(x: 0, y: Double(wins)),
            BarChartDataEntry(x: 1, y: Double(losses))
        ]
        
        let dataSet = BarChartDataSet(entries: entries, label: "游戏结果")
        dataSet.colors = [UIColor.systemGreen, UIColor.systemRed]
        dataSet.valueTextColor = .label
        dataSet.valueFont = .systemFont(ofSize: 14)
        
        let data = BarChartData(dataSet: dataSet)
        
        difficultyChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["胜利", "失败"])
        difficultyChartView.xAxis.granularity = 1
        difficultyChartView.data = data
        difficultyChartView.animate(yAxisDuration: 1.0)
    }
    
    private func updateSpecialModeChart(wins: Int, losses: Int) {
        // 创建柱状图数据
        let entries = [
            BarChartDataEntry(x: 0, y: Double(wins)),
            BarChartDataEntry(x: 1, y: Double(losses))
        ]
        
        let dataSet = BarChartDataSet(entries: entries, label: "游戏结果")
        dataSet.colors = [UIColor.systemGreen, UIColor.systemRed]
        dataSet.valueTextColor = .label
        dataSet.valueFont = .systemFont(ofSize: 14)
        
        let data = BarChartData(dataSet: dataSet)
        
        specialModeChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["胜利", "失败"])
        specialModeChartView.xAxis.granularity = 1
        specialModeChartView.data = data
        specialModeChartView.animate(yAxisDuration: 1.0)
    }
    
    // MARK: - 辅助方法
    
    // 格式化时间显示
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // 主题变更通知处理
    @objc private func themeDidChange() {
        // 更新UI元素的主题
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        
        // 更新卡片背景色
        let cardColor = MinesweeperTheme.shared.currentTheme == .cute ? 
            MinesweeperTheme.Colors.Cute.cellCovered : MinesweeperTheme.Colors.Grass.cellCovered
        
        // 更新总览卡片
        for stackView in statsCardsStackView.arrangedSubviews {
            if let horizontalStack = stackView as? UIStackView {
                for card in horizontalStack.arrangedSubviews {
                    card.backgroundColor = cardColor
                }
            } else {
                stackView.backgroundColor = cardColor
            }
        }
        
        // 更新难度统计卡片
        for stackView in difficultyStatsStackView.arrangedSubviews {
            if let horizontalStack = stackView as? UIStackView {
                for card in horizontalStack.arrangedSubviews {
                    card.backgroundColor = cardColor
                }
            } else {
                stackView.backgroundColor = cardColor
            }
        }
        
        // 更新特殊模式统计卡片
        for stackView in specialModeStatsStackView.arrangedSubviews {
            if let horizontalStack = stackView as? UIStackView {
                for card in horizontalStack.arrangedSubviews {
                    card.backgroundColor = cardColor
                }
            } else {
                stackView.backgroundColor = cardColor
            }
        }
        
        // 更新图表容器
        for view in overviewContainerView.subviews {
            if view != statsCardsStackView {
                view.backgroundColor = cardColor
            }
        }
        
        for view in difficultyContainerView.subviews {
            if view != difficultyStatsStackView && view != difficultySegmentedControl {
                view.backgroundColor = cardColor
            }
        }
        
        for view in specialModeContainerView.subviews {
            if view != specialModeStatsStackView && view != specialModeSegmentedControl {
                view.backgroundColor = cardColor
            }
        }
        
        // 刷新表格
        recentGamesTableView.visibleCells.forEach { cell in
            if let gameCell = cell as? RecentGameCell {
                gameCell.updateTheme()
            }
        }
        recentGamesTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameRecordManager.shared.getRecentGames().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentGameCell", for: indexPath) as? RecentGameCell else {
            return UITableViewCell()
        }
        
        let recentGames = GameRecordManager.shared.getRecentGames()
        
        if indexPath.row < recentGames.count {
            let game = recentGames[indexPath.row]
            cell.configure(with: game)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // 增加高度以适应自定义Cell的内容
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 显示游戏详情
        let recentGames = GameRecordManager.shared.getRecentGames()
        if indexPath.row < recentGames.count {
            let game = recentGames[indexPath.row]
            
            // 创建详情视图控制器
            let detailVC = UIViewController()
            detailVC.view.backgroundColor = .systemBackground
            detailVC.modalPresentationStyle = .formSheet
            detailVC.preferredContentSize = CGSize(width: 350, height: 450)
            
            // 创建详情容器视图
            let containerView = UIView()
            containerView.backgroundColor = MinesweeperTheme.shared.currentTheme == .cute ?
            MinesweeperTheme.Colors.Cute.cellCovered :
            MinesweeperTheme.Colors.Grass.cellCovered
            containerView.layer.cornerRadius = 16
            detailVC.view.addSubview(containerView)
            
            containerView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(320)
                make.height.equalTo(400)
            }
            
            // 标题标签
            let titleLabel = UILabel()
            titleLabel.text = "游戏详情"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
            titleLabel.textAlignment = .center
            titleLabel.textColor = .label
            containerView.addSubview(titleLabel)
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(20)
            }
            
            // 结果图标
            let resultIconView = UIImageView()
            resultIconView.contentMode = .scaleAspectFit
            resultIconView.image = game.isWin ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "xmark.circle.fill")
            resultIconView.tintColor = game.isWin ? .systemGreen : .systemRed
            containerView.addSubview(resultIconView)
            
            resultIconView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(15)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(60)
            }
            
            // 结果标签
            let resultLabel = UILabel()
            resultLabel.text = game.isWin ? "胜利" : "失败"
            resultLabel.font = UIFont.boldSystemFont(ofSize: 18)
            resultLabel.textAlignment = .center
            resultLabel.textColor = game.isWin ? .systemGreen : .systemRed
            containerView.addSubview(resultLabel)
            
            resultLabel.snp.makeConstraints { make in
                make.top.equalTo(resultIconView.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
            }
            
            // 详情堆栈视图
            let detailsStackView = UIStackView()
            detailsStackView.axis = .vertical
            detailsStackView.spacing = 12
            detailsStackView.alignment = .fill
            detailsStackView.distribution = .fillEqually
            containerView.addSubview(detailsStackView)
            
            detailsStackView.snp.makeConstraints { make in
                make.top.equalTo(resultLabel.snp.bottom).offset(20)
                make.left.right.equalToSuperview().inset(25)
            }
            
            // 格式化日期
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: game.date)
            
            // 添加详情项
            addDetailItem(to: detailsStackView, title: "日期", value: dateString)
            addDetailItem(to: detailsStackView, title: "难度", value: GameDifficulty(rawValue: game.difficulty)?.title ?? "未知")
            addDetailItem(to: detailsStackView, title: "模式", value: SpecialGameModeType(rawValue: game.specialMode)?.title ?? "普通模式")
            
            if let timeUsed = game.timeUsed {
                addDetailItem(to: detailsStackView, title: "用时", value: formatTime(timeUsed))
            }
            
            addDetailItem(to: detailsStackView, title: "找到地雷", value: "\(game.minesFound)/\(game.totalMines)")
            
            // 添加按钮容器
            let buttonStackView = UIStackView()
            buttonStackView.axis = .horizontal
            buttonStackView.spacing = 15
            buttonStackView.distribution = .fillEqually
            containerView.addSubview(buttonStackView)
            
            buttonStackView.snp.makeConstraints { make in
                make.top.equalTo(detailsStackView.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(25)
                make.bottom.equalToSuperview().offset(-25)
                make.height.equalTo(44)
            }
            
            // 关闭按钮
            let closeButton = UIButton(type: .system)
            closeButton.setTitle("关闭", for: .normal)
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            closeButton.backgroundColor = .systemGray5
            closeButton.layer.cornerRadius = 10
            closeButton.addTarget(self, action: #selector(dismissDetailVC(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(closeButton)
            
            // 分享按钮
            let shareButton = UIButton(type: .system)
            shareButton.setTitle("分享", for: .normal)
            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            shareButton.backgroundColor = .systemBlue
            shareButton.setTitleColor(.white, for: .normal)
            shareButton.layer.cornerRadius = 10
            shareButton.tag = indexPath.row // 存储索引以便在点击时获取游戏记录
            shareButton.addTarget(self, action: #selector(shareGameRecord(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(shareButton)
            
            present(detailVC, animated: true)
        }
    }
    
    private func addDetailItem(to stackView: UIStackView, title: String, value: String) {
        let itemView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        itemView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        itemView.addSubview(valueLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
        }
        
        stackView.addArrangedSubview(itemView)
    }
    
    @objc private func dismissDetailVC(_ sender: UIButton) {
        // 关闭当前显示的详情视图控制器
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func shareGameRecord(_ sender: UIButton) {
        let index = sender.tag
        let recentGames = GameRecordManager.shared.getRecentGames()
        
        guard index < recentGames.count else { return }
        
        let game = recentGames[index]
        
        // 格式化日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: game.date)
        
        // 构建分享文本
        var shareText = "扫雷游戏记录分享\n\n"
        shareText += "日期: \(dateString)\n"
        shareText += "难度: \(GameDifficulty(rawValue: game.difficulty)?.title ?? "未知")\n"
        shareText += "模式: \(SpecialGameModeType(rawValue: game.specialMode)?.title ?? "普通模式")\n"
        shareText += "结果: \(game.isWin ? "胜利 🎉" : "失败 😢")\n"
        
        if let timeUsed = game.timeUsed {
            shareText += "用时: \(formatTime(timeUsed))\n"
        }
        
        shareText += "找到地雷: \(game.minesFound)/\(game.totalMines)\n"
        
        // 分享文本
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // 获取当前呈现的视图控制器
        if let presentedVC = self.presentedViewController {
            presentedVC.present(activityVC, animated: true)
        } else {
            present(activityVC, animated: true)
        }
    }
    
    
    // MARK: - 导出功能
    
    @objc private func exportData() {
        let actionSheet = UIAlertController(title: "导出游戏记录", message: "选择导出格式", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "导出为CSV", style: .default) { [weak self] _ in
            self?.exportAsCSV()
        })
        
        actionSheet.addAction(UIAlertAction(title: "分享统计摘要", style: .default) { [weak self] _ in
            self?.shareStatsSummary()
        })
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad支持
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(actionSheet, animated: true)
    }
    
    private func exportAsCSV() {
        let recordManager = GameRecordManager.shared
        let records = recordManager.gameRecords
        
        // 创建CSV内容
        var csvString = "日期,难度,特殊模式,结果,用时(秒),找到地雷数,总地雷数\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for record in records {
            let dateStr = dateFormatter.string(from: record.date)
            let difficultyStr = GameDifficulty(rawValue: record.difficulty)?.title ?? "未知"
            let modeStr = SpecialGameModeType(rawValue: record.specialMode)?.title ?? "普通模式"
            let resultStr = record.isWin ? "胜利" : "失败"
            let timeStr = record.timeUsed != nil ? "\(record.timeUsed!)" : "N/A"
            
            let line = "\"\(dateStr)\",\"\(difficultyStr)\",\"\(modeStr)\",\"\(resultStr)\",\"\(timeStr)\",\"\(record.minesFound)\",\"\(record.totalMines)\"\n"
            csvString.append(line)
        }
        
        // 创建临时文件
        let fileName = "扫雷游戏记录_\(Date()).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            
            // 分享文件
            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            
            // iPad支持
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.barButtonItem = navigationItem.rightBarButtonItem
            }
            
            present(activityVC, animated: true)
            
        } catch {
            let alert = UIAlertController(title: "导出失败", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func shareStatsSummary() {
        let recordManager = GameRecordManager.shared
        let stats = recordManager.getOverallStatsSummary()
        
        // 创建统计摘要文本
        var summaryText = "扫雷游戏统计摘要\n\n"
        summaryText += "总游戏场数: \(stats.totalGames)\n"
        summaryText += "胜利场数: \(stats.totalWins)\n"
        summaryText += "胜率: \(String(format: "%.1f%%", stats.winRate))\n"
        summaryText += "最大连胜: \(stats.maxWinStreak)\n"
        summaryText += "当前连胜: \(stats.currentWinStreak)\n"
        
        if let bestTime = stats.bestTime {
            summaryText += "最佳时间: \(formatTime(bestTime))\n"
        }
        
        if let avgTime = stats.averageTime {
            summaryText += "平均用时: \(formatTime(avgTime))\n"
        }
        
        // 添加总游戏时长
        let hours = stats.totalPlayTime / 3600
        let minutes = (stats.totalPlayTime % 3600) / 60
        let seconds = stats.totalPlayTime % 60
        
        if hours > 0 {
            summaryText += "总游戏时长: \(String(format: "%d:%02d:%02d", hours, minutes, seconds))\n"
        } else {
            summaryText += "总游戏时长: \(String(format: "%02d:%02d", minutes, seconds))\n"
        }
        
        // 分享文本
        let activityVC = UIActivityViewController(activityItems: [summaryText], applicationActivities: nil)
        
        // iPad支持
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
    
}

