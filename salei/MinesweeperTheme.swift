//
//  MinesweeperTheme.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

// 主题类型枚举
enum ThemeType: Int, CaseIterable {
    case cute = 0      // 可爱风格
    case grass = 1     // 草地风格
    
    var title: String {
        switch self {
        case .cute: return "可爱风格"
        case .grass: return "草地风格"
        }
    }
    
    var description: String {
        switch self {
        case .cute: 
            return "粉色系可爱风格主题。"
        case .grass: 
            return "绿色系草地风格主题。"
        }
    }
}

// 扫雷游戏主题管理器
class MinesweeperTheme {
    static let shared = MinesweeperTheme()
    
    // 当前选择的主题
    private(set) var currentTheme: ThemeType = .grass
    
    // 用户默认设置的键
    private let themeKey = "selectedGameTheme"
    
    private init() {
        // 从用户默认设置加载保存的主题
        if let savedTheme = UserDefaults.standard.object(forKey: themeKey) as? Int,
           let theme = ThemeType(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    // 设置主题
    func setTheme(_ theme: ThemeType) {
        currentTheme = theme
        // 保存到用户默认设置
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
        
        // 发送主题变更通知
        NotificationCenter.default.post(name: NSNotification.Name("ThemeDidChangeNotification"), object: nil)
    }
    
    // 主题颜色
    struct Colors {
        // 可爱风格颜色
        struct Cute {
            // 背景色 - 淡粉色背景
            static let background = UIColor(red: 1.0, green: 0.92, blue: 0.93, alpha: 1.0)
            
            // 棋盘背景色 - 更淡的粉色
            static let boardBackground = UIColor(red: 1.0, green: 0.95, blue: 0.96, alpha: 1.0)
            
            // 棋盘边框色 - 深粉色
            static let boardBorder = UIColor(red: 0.95, green: 0.61, blue: 0.73, alpha: 1.0)
            
            // 单元格颜色
            static let cellCovered = UIColor(red: 0.98, green: 0.87, blue: 0.89, alpha: 1.0) // 覆盖状态 - 粉色
            static let cellRevealed = UIColor(red: 1.0, green: 0.95, blue: 0.96, alpha: 1.0) // 揭示状态 - 更淡的粉色
            
            // 单元格边框色 - 淡紫色
            static let cellBorder = UIColor(red: 0.85, green: 0.75, blue: 0.85, alpha: 1.0)

            // 按钮颜色
            static let buttonBackground = UIColor(red: 0.95, green: 0.75, blue: 0.85, alpha: 1.0) // 粉色按钮
        }
        
        // 草地风格颜色
        struct Grass {
            // 背景色 - 淡绿色背景
            static let background = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)
            
            // 棋盘背景色 - 草地绿色
            static let boardBackground = UIColor(red: 0.8, green: 0.95, blue: 0.8, alpha: 1.0)
            
            // 棋盘边框色 - 深绿色
            static let boardBorder = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
            
            // 单元格颜色
            static let cellCovered = UIColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1.0) // 覆盖状态 - 草绿色
            static let cellRevealed = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0) // 揭示状态 - 浅草绿色
            
            // 单元格边框色 - 深绿色
            static let cellBorder = UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)
            
            // 按钮颜色
            static let buttonBackground = UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0) // 绿色按钮
        }
        
        // 数字颜色 - 两种主题共用
        static let number1 = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0) // 淡蓝色
        static let number2 = UIColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0) // 深绿色
        static let number3 = UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 1.0) // 红色
        static let number4 = UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0) // 紫色
        static let number5 = UIColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 1.0) // 棕色
        static let number6 = UIColor(red: 0.3, green: 0.7, blue: 0.7, alpha: 1.0) // 青色
        static let number7 = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0) // 深棕色
        static let number8 = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // 灰色
        
        // 按钮文本颜色 - 两种主题共用
        static let buttonText = UIColor.white
    }
    
    // 主题尺寸和圆角
    struct Dimensions {
        // 单元格圆角
        static let cellCornerRadius: CGFloat = 4.0
        
        // 棋盘圆角
        static let boardCornerRadius: CGFloat = 12.0
        
        // 按钮圆角
        static let buttonCornerRadius: CGFloat = 15.0
        
        // 单元格边框宽度
        static let cellBorderWidth: CGFloat = 1.0
        
        // 棋盘边框宽度
        static let boardBorderWidth: CGFloat = 3.0
    }
    
    // 主题图标
    struct Icons {
        // 可爱风格图标
        struct Cute {
            // 旗帜图标
            static let flag = "🚩"
            
            // 地雷图标
            static let mine = "💣"
            
            // 覆盖图标
            static let covered = ""
        }
        
        // 草地风格图标
        struct Grass {
            // 旗帜图标
            static let flag = "🚩"
            
            // 地雷图标
            static let mine = "💣"
            
            // 草图标
            static let covered = "🌱"
        }
    }
    
    // 获取当前主题的背景颜色
    var backgroundColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.background
        case .grass: return Colors.Grass.background
        }
    }
    
    // 获取当前主题的棋盘背景颜色
    var boardBackgroundColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.boardBackground
        case .grass: return Colors.Grass.boardBackground
        }
    }
    
    // 获取当前主题的棋盘边框颜色
    var boardBorderColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.boardBorder
        case .grass: return Colors.Grass.boardBorder
        }
    }
    
    // 获取当前主题的覆盖单元格颜色
    var cellCoveredColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.cellCovered
        case .grass: return Colors.Grass.cellCovered
        }
    }
    
    // 获取当前主题的揭示单元格颜色
    var cellRevealedColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.cellRevealed
        case .grass: return Colors.Grass.cellRevealed
        }
    }
    
    // 获取当前主题的单元格边框颜色
    var cellBorderColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.cellBorder
        case .grass: return Colors.Grass.cellBorder
        }
    }
    
    // 获取当前主题的按钮背景颜色
    var buttonBackgroundColor: UIColor {
        switch currentTheme {
        case .cute: return Colors.Cute.buttonBackground
        case .grass: return Colors.Grass.buttonBackground
        }
    }
    
    // 获取当前主题的覆盖图标
    var coveredIcon: String {
        switch currentTheme {
        case .cute: return Icons.Cute.covered
        case .grass: return Icons.Grass.covered
        }
    }
    
    // 获取当前主题的旗帜图标
    var flagIcon: String {
        switch currentTheme {
        case .cute: return Icons.Cute.flag
        case .grass: return Icons.Grass.flag
        }
    }
    
    // 获取当前主题的地雷图标
    var mineIcon: String {
        switch currentTheme {
        case .cute: return Icons.Cute.mine
        case .grass: return Icons.Grass.mine
        }
    }
    
    // 应用主题到单元格
    func applyCellTheme(to button: UIButton, state: CellState) {
        // 设置圆角
        button.layer.cornerRadius = Dimensions.cellCornerRadius
        button.clipsToBounds = true
        
        // 设置边框
        button.layer.borderWidth = Dimensions.cellBorderWidth
        button.layer.borderColor = cellBorderColor.cgColor
        
        // 根据状态设置背景色和图标
        switch state {
        case .covered:
            button.backgroundColor = cellCoveredColor
            button.setTitle(coveredIcon, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        case .flagged:
            button.backgroundColor = cellCoveredColor
            button.setTitle(flagIcon, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        case .revealed:
            button.backgroundColor = cellRevealedColor
//            button.setTitle("", for: .normal)
        }
    }
    
    // 应用主题到数字
    func applyNumberTheme(to button: UIButton, number: Int) {
        let color: UIColor
        switch number {
        case 1: color = Colors.number1
        case 2: color = Colors.number2
        case 3: color = Colors.number3
        case 4: color = Colors.number4
        case 5: color = Colors.number5
        case 6: color = Colors.number6
        case 7: color = Colors.number7
        case 8: color = Colors.number8
        default: color = UIColor.black
        }
        
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    // 应用主题到棋盘
    func applyBoardTheme(to boardView: UIView) {
        boardView.backgroundColor = boardBackgroundColor
        boardView.layer.cornerRadius = Dimensions.boardCornerRadius
        boardView.layer.borderWidth = Dimensions.boardBorderWidth
        boardView.layer.borderColor = boardBorderColor.cgColor
        boardView.clipsToBounds = true
    }
    
    // 应用主题到按钮
    func applyButtonTheme(to button: UIButton, color: UIColor? = nil) {
        button.backgroundColor = color?.withAlphaComponent(0.8) ?? buttonBackgroundColor
        button.setTitleColor(Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Dimensions.buttonCornerRadius
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        // 添加阴影效果
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 3
    }
    
    // 应用主题到计时器
    func applyTimerTheme(to label: UILabel) {
        label.backgroundColor = cellCoveredColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
    }
    
    // 应用主题到视图控制器背景
    func applyBackgroundTheme(to view: UIView) {
        view.backgroundColor = backgroundColor
    }
}
