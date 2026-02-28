//
//  MainNavigationController.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        
        // 注册主题变更通知
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: NSNotification.Name("ThemeDidChangeNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigation() {
        updateNavigationBarTheme()
        
        // 设置根视图控制器为游戏主界面
        let gameVC = ViewController()
        setViewControllers([gameVC], animated: false)
    }
    
    // 更新导航栏主题
    private func updateNavigationBarTheme() {
        // 设置导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: MinesweeperTheme.shared.boardBorderColor]
        navigationBar.tintColor = MinesweeperTheme.shared.boardBorderColor
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    // 主题变更通知处理
    @objc private func themeDidChange() {
        updateNavigationBarTheme()
    }
}
