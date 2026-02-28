//
//  ViewController.swift
//  salei
//
//  Created by Andre  on 2025/4/24.
//

import UIKit
import AVFoundation
import ObjectiveC

class ViewController: UIViewController {
    
    // 游戏配置 - 使用GameModeManager管理
    private var rows: Int { return GameModeManager.shared.rows }
    private var columns: Int { return GameModeManager.shared.columns }
    private var mineCount: Int { return GameModeManager.shared.mineCount }
    private var cellSize: CGFloat { return GameModeManager.shared.cellSize }
    
    // 游戏状态
    private var game: MinesweeperGame!
    private var flagModeOn = false
    
    // UI元素 - 简化后只保留必要元素
    private var statusLabel: UILabel!
    private var flagButton: UIButton!
    private var resetButton: UIButton!
    private var pauseButton: UIButton! // 暂停按钮
    private var timerLabel: UILabel! // 计时器标签（用于显示倒计时或已用时间）
    
    // 游戏计时相关
    private var timerStarted: Bool = false // 标记计时器是否已经启动
    
    // 图片展示元素
    private var playingImageView: UIImageView! // 游戏中动画展示
    
    // 结果图片显示器
    private var resultImageDisplayer: ResultImageDisplayer!
    
    // 游戏棋盘容器
    private var boardView: BoardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupGame()
        setupUI()
        
        // 初始化结果图片显示器
        resultImageDisplayer = ResultImageDisplayer(delegate: self)
        startNewGame()
        
        // 注册主题变更通知
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: NSNotification.Name("ThemeDidChangeNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        // 设置返回按钮不显示标题
        navigationItem.backButtonTitle = ""
        
        // 设置导航栏右侧按钮 - 游戏设置
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
        
        // 设置导航栏左侧按钮 - 游戏记录
        let recordsButton = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .plain, target: self, action: #selector(openRecords))
        
        // 添加到导航栏
//        navigationItem.rightBarButtonItem = settingsButton
        navigationItem.leftBarButtonItem = recordsButton
        
        // 创建积分商店按钮
        let storeButton = UIBarButtonItem(
            image: UIImage(systemName: "gift"),
            style: .plain,
            target: self,
            action: #selector(openPointsStore)
        )
        
        // 设置积分商店按钮的提示文本
        storeButton.accessibilityLabel = "积分商店"
        navigationItem.rightBarButtonItems = [settingsButton, storeButton]
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func openRecords() {
        let recordsVC = RecordViewController()
        navigationController?.pushViewController(recordsVC, animated: true)
    }
    
    @objc func openPointsStore() {
        // 确保PointsManager已初始化
//        _ = PointsManager.shared
        
        let storeVC = PointsStoreViewController()
        navigationController?.pushViewController(storeVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 检查游戏模式是否已更改，如果更改则重新开始游戏
        if game.rows != rows || game.columns != columns || game.mineCount != mineCount {
            boardView.reset(rows: rows, columns: columns, cellSize: cellSize)
            
            let maxBoardSize = calculateMaxBoardSize()
            let actualRows = min(rows, maxBoardSize.maxRows)
            let actualColumns = min(columns, maxBoardSize.maxColumns)
            boardView.snp.updateConstraints { make in
                make.width.equalTo(CGFloat(actualColumns) * cellSize)
                make.height.equalTo(CGFloat(actualRows) * cellSize)
            }
            
            startNewGame()
        }
        
        // 更新状态标签显示当前难度
        statusLabel.text = "\(GameModeManager.shared.currentDifficulty.title)模式"
    }

    private func setupGame() {
        game = MinesweeperGame(rows: rows, columns: columns, mineCount: mineCount)
    }
    
    private func setupUI() {
        // 设置导航栏标题 - 显示地雷数量
        updateNavigationTitle()
        
        // 应用背景主题
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        
        // 状态标签
        statusLabel = UILabel()
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.boldSystemFont(ofSize: 20)
        statusLabel.text = "\(GameModeManager.shared.currentDifficulty.title)模式"
        view.addSubview(statusLabel)
                
        // 旗帜模式按钮
        flagButton = UIButton(type: .system)
        flagButton.setTitle("🚩 标记关", for: .normal)
        flagButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        MinesweeperTheme.shared.applyButtonTheme(to: flagButton, color: .systemBlue)
        flagButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        flagButton.addTarget(self, action: #selector(toggleFlagMode), for: .touchUpInside)
        view.addSubview(flagButton)
        
        // 重置按钮
        resetButton = UIButton(type: .system)
        resetButton.setTitle("重新开始", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        MinesweeperTheme.shared.applyButtonTheme(to: resetButton, color: .systemGreen)
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        resetButton.addTarget(self, action: #selector(resetGameAction), for: .touchUpInside)
        view.addSubview(resetButton)
        
        // 暂停按钮
        pauseButton = UIButton(type: .system)
        pauseButton.setTitle("⏸ 暂停", for: .normal)
        pauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        MinesweeperTheme.shared.applyButtonTheme(to: pauseButton, color: .systemOrange)
        pauseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        pauseButton.addTarget(self, action: #selector(togglePauseGame), for: .touchUpInside)
        view.addSubview(pauseButton)
        
        // 计时器标签（用于显示倒计时或已用时间）
        timerLabel = UILabel()
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        timerLabel.text = "00:00"
        timerLabel.textColor = UIColor.systemOrange
        MinesweeperTheme.shared.applyTimerTheme(to: timerLabel)
        view.addSubview(timerLabel)
        
        // 计算最大可显示的行列数
        let maxBoardSize = calculateMaxBoardSize()
        // 确定实际使用的行列数（不超过最大值）
        let actualRows = min(rows, maxBoardSize.maxRows)
        let actualColumns = min(columns, maxBoardSize.maxColumns)
        // 创建游戏棋盘容器，使用实际行列数
        boardView = BoardView(frame: CGRect.zero, rows: rows, columns: columns, cellSize: cellSize)
        boardView.boardDelegate = self
        boardView.layer.borderWidth = 1.0
        boardView.layer.borderColor = UIColor.lightGray.cgColor
        boardView.layer.cornerRadius = 8.0
        boardView.clipsToBounds = true
        view.addSubview(boardView)
        
        // 游戏中动画图片视图
        playingImageView = UIImageView()
        playingImageView.contentMode = .scaleAspectFit
        playingImageView.clipsToBounds = true
        playingImageView.backgroundColor = UIColor.clear
        view.addSubview(playingImageView)
        
        // 设置约束 - 优化布局
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(view)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        
        // 计时器标签位于状态标签下方
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        // 旗帜按钮、暂停按钮和重置按钮并排
        flagButton.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(15)
            make.leading.equalTo(view).offset(20)
            make.width.equalTo((view.frame.width - 80) / 3) // 三等分宽度减去边距
        }
        
        pauseButton.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(15)
            make.centerX.equalTo(view)
            make.width.equalTo((view.frame.width - 80) / 3) // 三等分宽度减去边距
            make.height.equalTo(flagButton)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(15)
            make.trailing.equalTo(view).offset(-20)
            make.width.equalTo((view.frame.width - 80) / 3) // 三等分宽度减去边距
            make.height.equalTo(flagButton)
        }
        
        // 游戏棋盘位置调整 - 根据实际行列数设置大小
        boardView.snp.makeConstraints { make in
            make.top.equalTo(flagButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(CGFloat(actualColumns) * cellSize)
            make.height.equalTo(CGFloat(actualRows) * cellSize)
        }
        
        // 游戏中动画图片视图位于棋盘下方
        playingImageView.snp.makeConstraints { make in
            make.top.equalTo(boardView.snp.bottom).offset(15)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-10)
        }
    }
    
    private func startNewGame() {
        // 使用当前难度设置创建游戏
        game = MinesweeperGame(rows: rows, columns: columns, mineCount: mineCount)
        updateUI()
        AudioManager.shared.playStartSound()
        startPlayingAnimation()
        
        // 设置计时器模式并重置
        let timerMode: TimerMode = SpecialGameMode.shared.isTimeChallengeMode ? .timeChallenge : .normal
        TimerManager.shared.setMode(timerMode)
        TimerManager.shared.resetTimer()
        
        // 重置计时器启动标志
        timerStarted = false
        
        // 重置暂停按钮状态
        pauseButton.setTitle("⏸ 暂停", for: .normal)
        MinesweeperTheme.shared.applyButtonTheme(to: pauseButton, color: .systemOrange)
        
        // 确保游戏棋盘可交互
        boardView.isUserInteractionEnabled = true
        flagButton.isEnabled = true
        
        // 更新计时器显示 - 等待第一次点击
        updateTimerDisplay()
    }
    
    // 启动计时器
    private func startElapsedTimer() {
        // 使用TimerManager启动计时器
        TimerManager.shared.startTimer { [weak self] (time, mode) in
            guard let self = self, !self.game.isGameOver else { return }
            
            // 更新计时器显示
            self.updateTimerDisplay()
            
            // 如果是限时挑战模式且时间用完，处理游戏结束
            if mode == .timeChallenge && time == 0 {
                self.handleTimeUp()
            }
        }
    }
    
    // 更新计时器显示
    private func updateTimerDisplay() {
        // 获取计时器图标和格式化的时间
        let icon = TimerManager.shared.getModeIcon()
        let formattedTime = TimerManager.shared.getFormattedTime()
        
        // 更新计时器标签文本，添加图标
        timerLabel.text = "\(icon) \(formattedTime)"
        
        // 更新计时器颜色
        timerLabel.textColor = TimerManager.shared.getTimeColor()
    }
    
    // MARK: - Game Logic
    
    private func revealAllMines() {
        for row in 0..<rows {
            for column in 0..<columns {
                if case .mine = game.gameBoard[row][column] {
                    game.cellStates[row][column] = .revealed
                }
            }
        }
        boardView.updateUI()
    }

    private func handleTimeUp() {
        game.isGameOver = true
        updateUI()
        statusLabel.text = "时间到！游戏结束！"
    }
    
    // 更新导航栏标题显示地雷数量
    private func updateNavigationTitle() {
        title = "💣 剩余地雷:\(mineCount - game.flagsPlaced)"
    }
    
    private func updateUI() {
        statusLabel.text = "\(GameModeManager.shared.currentDifficulty.title)模式"
        updateNavigationTitle()
        
        boardView.updateUI()
        
        if game.isGameOver {
            if game.isWin {
                statusLabel.text = "恭喜你赢了！"
                AudioManager.shared.playSuccessSound()
                
                // 停止计时器
                TimerManager.shared.stopTimer()
                
                // 记录游戏统计数据
                GameRecordManager.shared.addRecord(
                    difficulty: GameModeManager.shared.currentDifficulty.rawValue,
                    specialMode: SpecialGameMode.shared.currentMode.rawValue,
                    isWin: true,  // 或 false，取决于游戏结果
                    timeUsed: TimerManager.shared.elapsedTime,  // 游戏用时
                    minesFound: game.flagsPlaced,  // 找到的地雷数
                    totalMines: game.mineCount  // 总地雷数
                )
                
                // 计算并添加积分奖励
                let earnedPoints = PointsCalculator.shared.calculatePoints(
                    isWin: true,
                    difficulty: GameModeManager.shared.currentDifficulty.rawValue,
                    specialMode: SpecialGameMode.shared.currentMode.rawValue,
                    timeUsed: TimerManager.shared.elapsedTime,
                    minesFound: game.flagsPlaced,
                    totalMines: game.mineCount)
                
                PointsManager.shared.addPoints(earnedPoints)
                
                // 显示胜利图片和积分奖励
                resultImageDisplayer.showVictoryImage(points: earnedPoints)
            } else {
                statusLabel.text = "游戏结束！"
                revealAllMines()
                AudioManager.shared.playFailureSound()
                
                // 停止计时器
                TimerManager.shared.stopTimer()
                
                // 记录游戏统计数据
                GameRecordManager.shared.addRecord(
                    difficulty: GameModeManager.shared.currentDifficulty.rawValue,
                    specialMode: SpecialGameMode.shared.currentMode.rawValue,
                    isWin: false,  // 或 false，取决于游戏结果
                    timeUsed: TimerManager.shared.elapsedTime,  // 游戏用时
                    minesFound: game.flagsPlaced,  // 找到的地雷数
                    totalMines: game.mineCount  // 总地雷数
                )
                
                // 计算并添加积分奖励（失败时也有少量积分）
                let earnedPoints = PointsCalculator.shared.calculatePoints(
                    isWin: false,
                    difficulty: GameModeManager.shared.currentDifficulty.rawValue,
                    specialMode: SpecialGameMode.shared.currentMode.rawValue,
                    timeUsed: TimerManager.shared.elapsedTime,
                    minesFound: game.flagsPlaced,
                    totalMines: game.mineCount)
                
                PointsManager.shared.addPoints(earnedPoints)
                
                // 显示失败图片和积分奖励
                resultImageDisplayer.showDefeatImage(points: earnedPoints)
            }
        }
    }
        
    // 为旗帜模式切换添加动画效果
    @objc private func toggleFlagMode() {
        flagModeOn.toggle()
        
        // 更新按钮文本和外观
        if flagModeOn {
            flagButton.setTitle("🚩 标记开", for: .normal)
            flagButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        } else {
            flagButton.setTitle("🚩 标记关", for: .normal)
            flagButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        }
        
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.flagButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.flagButton.transform = CGAffineTransform.identity
            }
        }
        
        // 更新导航栏标题
        updateNavigationTitle()
    }
    
    // 为重置按钮添加动画效果
    @objc private func resetGameAction() {
        UIView.animate(withDuration: 0.1, animations: {
            self.resetButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.resetButton.transform = CGAffineTransform.identity
            }
            
            // 停止计时器
            TimerManager.shared.stopTimer()
            
            self.boardView.reset()
            self.startNewGame()
            // 确保在重置游戏时更新导航栏标题
            self.updateNavigationTitle()
        }
    }
    
    // 暂停/恢复游戏
    @objc private func togglePauseGame() {
        // 如果游戏已结束或计时器未启动，不执行任何操作
        if game.isGameOver || !timerStarted {
            return
        }
        
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.pauseButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.pauseButton.transform = CGAffineTransform.identity
            }
        }
        
        let timerManager = TimerManager.shared
        
        if timerManager.isTimerPaused {
            // 恢复游戏
            timerManager.resumeTimer()
            pauseButton.setTitle("⏸ 暂停", for: .normal)
            MinesweeperTheme.shared.applyButtonTheme(to: pauseButton, color: .systemOrange)
            
            // 恢复游戏棋盘交互
            boardView.isUserInteractionEnabled = true
            flagButton.isEnabled = true
            
            // 更新状态标签
            statusLabel.text = "\(GameModeManager.shared.currentDifficulty.title)模式"
        } else {
            // 暂停游戏
            timerManager.pauseTimer()
            pauseButton.setTitle("▶️ 继续", for: .normal)
            MinesweeperTheme.shared.applyButtonTheme(to: pauseButton, color: .systemGreen)
            
            // 禁用游戏棋盘交互，防止在暂停时操作
            boardView.isUserInteractionEnabled = false
            flagButton.isEnabled = false
            
            // 更新状态标签
            statusLabel.text = "游戏已暂停"
        }
    }
    
    // 难度选择和特殊模式选择方法已移至SettingsViewController
    
    // MARK: - 图片动画相关方法
    
    // 开始播放游戏中动画
    private func startPlayingAnimation() {
        // 设置初始图片
        updatePlayingImage()
    }
    
    // 更新讨伐中动画
    private func updatePlayingImage() {
        let imageUrl = ImageManager.shared.getRandomPlayingImageUrl()
        playingImageView.sd_setImage(with: imageUrl)
    }
    
    // 计算屏幕可显示的最大行列数
    private func calculateMaxBoardSize() -> (maxRows: Int, maxColumns: Int) {
        // 获取可用于显示棋盘的空间
        let topOffset: CGFloat = 255 // 状态标签、计时器和按钮的大致高度
        let bottomOffset: CGFloat = 230 // 动画图片视图的高度加上边距
        let sideOffset: CGFloat = 40 // 左右边距
        
        // 计算可用空间
        let availableHeight = view.frame.height - topOffset - bottomOffset
        let availableWidth = view.frame.width - sideOffset
        
        // 根据单元格大小计算最大行列数
        let maxRows = Int(availableHeight / cellSize)
        let maxColumns = Int(availableWidth / cellSize)
        
        return (maxRows, maxColumns)
    }
    
    // 主题变更通知处理
    @objc private func themeDidChange() {
        // 更新UI元素的主题
        MinesweeperTheme.shared.applyBackgroundTheme(to: view)
        MinesweeperTheme.shared.applyTimerTheme(to: timerLabel)
        
        // 更新棋盘主题
        boardView.updateTheme()
    }
    
}

extension ViewController: BoardViewDelegate {
    func boardView(_ boardView: BoardView, didTapCellAt row: Int, column: Int, withFlagMode flagMode: Bool) {
        // 如果游戏已结束，不处理点击
        if game.isGameOver { return }
        
        // 如果是第一次点击，启动计时器
        if !timerStarted {
            startElapsedTimer()
            timerStarted = true
        }
        
        if flagModeOn || flagMode {
            let wasAlreadyFlagged = game.cellStates[row][column] == .flagged
            game.toggleFlag(at: row, at: column)
            
            if wasAlreadyFlagged {
                AudioManager.shared.playFlagOffSound()
            } else {
                AudioManager.shared.playFlagOnSound()
            }
            // 确保在标记地雷时更新导航栏标题
            updateNavigationTitle()
        } else {
            if game.cellStates[row][column] != .flagged {
                _ = game.revealCell(at: row, at: column)
                AudioManager.shared.playClickSound()
            }
        }
        
        updateUI()
    }
    
    func getCellDisplayContent(at row: Int, at column: Int) -> String? {
        return game.getCellDisplayContent(at: row, at: column)
    }
    
    var isGameOver: Bool {
        return game.isGameOver
    }
    
    var cellStates: [[CellState]] {
        return game.cellStates
    }
}

extension ViewController: ResultImageDisplayerDelegate {
    
    var parentView: UIView {
        return navigationController!.view
    }
    
    var gameBoardView: UIView {
        return boardView
    }
    
    func resetGame() {
        resetGameAction()
    }
}
