//
//  ResultImageDisplayer.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

// 定义委托协议，用于与主视图控制器通信
protocol ResultImageDisplayerDelegate: AnyObject {
    // 获取父视图，用于添加结果图片视图
    var parentView: UIView { get }
    // 获取棋盘视图，用于将弹窗显示在棋盘中心
    var gameBoardView: UIView { get }
    // 重置游戏方法
    func resetGame()
}

class ResultImageDisplayer {
    // 委托对象
    weak var delegate: ResultImageDisplayerDelegate?
    
    // 初始化方法
    init(delegate: ResultImageDisplayerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - 公共方法
    
    // 显示胜利图片
    func showVictoryImage(points: Int) {
        // 获取胜利图片URL
        let imageUrl = ImageManager.shared.getRandomVictoryImageUrl()
        // 在游戏界面中显示胜利图片
        self.displayResultImage(imageURL: imageUrl, isVictory: true, points: points)
    }
    
    // 显示失败图片
    func showDefeatImage(points: Int) {
        guard let boardView = delegate?.gameBoardView else { return }
        
        // 保存原始位置
        let originalFrame = boardView.frame
        
        // 添加屏幕震动效果
        UIView.animate(withDuration: 0.05, animations: {
            boardView.frame.origin.x -= 10
        }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: {
                boardView.frame.origin.x += 20
            }, completion: { _ in
                UIView.animate(withDuration: 0.05, animations: {
                    boardView.frame.origin.x -= 20
                }, completion: { _ in
                    UIView.animate(withDuration: 0.05, animations: {
                        boardView.frame.origin.x += 10
                        boardView.frame = originalFrame
                    }, completion: { _ in
                        // 获取失败图片URL
                        let imageUrl = ImageManager.shared.getRandomDefeatImageUrl()
                        // 在游戏界面中显示失败图片
                        self.displayResultImage(imageURL: imageUrl, isVictory: false, points: points)
                    })
                })
            })
        })
    }
    
    // MARK: - 私有方法
    
    // 显示游戏结果图片 - 使用更流畅的体验方式
    private func displayResultImage(imageURL: URL?, isVictory: Bool, points: Int) {
        guard let parentView = delegate?.parentView, let boardView = delegate?.gameBoardView else { return }
        
        // 创建并显示结果图片视图
        let resultTitle = isVictory ? "讨伐胜利！" : "讨伐失败！"
        let resultMessage = isVictory ? "恭喜你获得 \(points) 积分！💎" : "获得了 \(points) 积分作为安慰！💎"

        if isVictory {
            GameAlertController.showSuccess(title: resultTitle, message: resultMessage, image: imageURL, in: parentView, centerView: boardView, buttonTitle: "乘胜追击", action: { [weak self] in
                // 点击按钮时开始新游戏
                self?.delegate?.resetGame()
            })
        } else {
            GameAlertController.showFailure(
                title: resultTitle,
                message: resultMessage,
                image: imageURL,
                in: parentView,
                centerView: boardView,
                buttonTitle: "知难而进",
                action: { [weak self] in
                    // 点击按钮时开始新游戏
                    self?.delegate?.resetGame()
                }
            )
        }
    }
    
}
