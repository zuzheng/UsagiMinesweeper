import UIKit

protocol BoardViewDelegate: AnyObject {
    func boardView(_ boardView: BoardView, didTapCellAt row: Int, column: Int, withFlagMode flagMode: Bool)
    func getCellDisplayContent(at row: Int, at column: Int) -> String?
    var isGameOver: Bool { get }
    var cellStates: [[CellState]] { get }
}

class BoardView: UIScrollView {
    private var buttons: [[UIButton]] = []
    private var rows: Int
    private var columns: Int
    private var cellSize: CGFloat
    weak var boardDelegate: BoardViewDelegate?
    
    // 添加内容视图来容纳所有按钮
    private var contentContainerView: UIView!
    
    // 最小和最大缩放比例
    private let minZoomScale: CGFloat = 0.5
    private let maxZoomScale: CGFloat = 2.0
    
    init(frame: CGRect, rows: Int, columns: Int, cellSize: CGFloat) {
        self.rows = rows
        self.columns = columns
        self.cellSize = cellSize
        super.init(frame: frame)
        setupScrollView()
        setupBoard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        // 配置滚动视图
        self.showsHorizontalScrollIndicator = true
        self.showsVerticalScrollIndicator = true
        self.bounces = true
        self.decelerationRate = UIScrollView.DecelerationRate.normal
        
        // 创建内容容器视图
        contentContainerView = UIView()
        addSubview(contentContainerView)
    }
    
    private func setupBoard() {
        MinesweeperTheme.shared.applyBoardTheme(to: contentContainerView)
        
        // 设置内容容器视图的大小
        let contentWidth = CGFloat(columns) * cellSize
        let contentHeight = CGFloat(rows) * cellSize
        contentContainerView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        
        // 设置滚动视图的内容大小
        self.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        // 创建单元格
        createCells()
    }
    
    private func createCells() {
        buttons = []
        
        for row in 0..<rows {
            var rowButtons: [UIButton] = []
            
            for column in 0..<columns {
                let button = UIButton()
                button.frame = CGRect(
                    x: CGFloat(column) * cellSize,
                    y: CGFloat(row) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                MinesweeperTheme.shared.applyCellTheme(to: button, state: .covered)
                button.tag = row * columns + column
                button.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)
                configureLongPress(for: button)

                contentContainerView.addSubview(button)
                rowButtons.append(button)
            }
            
            buttons.append(rowButtons)
        }
    }
    
    @objc private func cellTapped(_ sender: UIButton) {
        let tag = sender.tag
        let row = tag / columns
        let column = tag % columns
        boardDelegate?.boardView(self, didTapCellAt: row, column: column, withFlagMode: false)
    }
    
    // 长按手势识别器
    private func configureLongPress(for button: UIButton) {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        button.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let button = gesture.view as? UIButton else { return }
        
        let tag = button.tag
        let row = tag / columns
        let column = tag % columns
        boardDelegate?.boardView(self, didTapCellAt: row, column: column, withFlagMode: true)
        
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.impactOccurred()
    }
    
    func updateUI() {
        for row in 0..<rows {
            for column in 0..<columns {
                updateCellUI(at: row, column: column)
            }
        }
    }
    
    // 更新单元格UI
    private func updateCellUI(at row: Int, column: Int) {
        guard let boardDelegate = boardDelegate else { return }
        
        let button = buttons[row][column]
        let state = boardDelegate.cellStates[row][column]
        
        MinesweeperTheme.shared.applyCellTheme(to: button, state: state)
        
        switch state {
        case .covered, .flagged:
            button.isEnabled = !boardDelegate.isGameOver
            
        case .revealed:
            button.isEnabled = false
    
            if let displayContent = boardDelegate.getCellDisplayContent(at: row, at: column) {
                button.setTitle(displayContent, for: .normal)
                
                if let number = Int(displayContent), number > 0 {
                    MinesweeperTheme.shared.applyNumberTheme(to: button, number: number)
                } else if displayContent == MinesweeperTheme.shared.mineIcon {
                    button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7) // 红色背景表示地雷
                }
            } else {
                button.setTitle("", for: .normal)
            }
        }
    }
    
    func reset(rows: Int? = nil, columns: Int? = nil, cellSize: CGFloat? = nil) {
        // 移除所有子视图
        for subview in contentContainerView.subviews {
            subview.removeFromSuperview()
        }
        
        // 更新参数（如果提供）
        if let rows = rows, let columns = columns, let cellSize = cellSize {
            self.rows = rows
            self.columns = columns
            self.cellSize = cellSize
            
            // 更新内容容器视图的大小
            let contentWidth = CGFloat(columns) * cellSize
            let contentHeight = CGFloat(rows) * cellSize
            contentContainerView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
            
            // 更新滚动视图的内容大小
            self.contentSize = CGSize(width: contentWidth, height: contentHeight)
        }
        
        // 重新创建单元格
        createCells()
    }
    
    // 更新主题
    func updateTheme() {
        guard let boardDelegate = boardDelegate else { return }

        // 更新棋盘容器的主题
        MinesweeperTheme.shared.applyBoardTheme(to: contentContainerView)
        
        // 更新所有单元格的主题
        for row in 0..<rows {
            for column in 0..<columns {
                let button = buttons[row][column]
                let state = boardDelegate.cellStates[row][column]
                
                MinesweeperTheme.shared.applyCellTheme(to: button, state: state)
                
                if case .revealed = state {
                    if let title = button.titleLabel?.text, title == MinesweeperTheme.shared.mineIcon {
                        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7) // 红色背景表示地雷
                    }
                }
            }
        }
        
        // 更新滚动视图的背景色
        backgroundColor = MinesweeperTheme.shared.backgroundColor
    }
}
