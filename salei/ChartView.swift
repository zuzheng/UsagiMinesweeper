//
//  ChartView.swift
//  salei
//
//  Created for Minesweeper Game
//

import UIKit

// 简单的图表视图组件
class ChartView: UIView {
    
    // 图表类型枚举
    enum ChartType {
        case bar    // 柱状图
        case pie    // 饼图
    }
    
    // 数据项结构
    struct DataItem {
        let value: Double
        let label: String
        let color: UIColor
        
        init(value: Double, label: String, color: UIColor = .systemBlue) {
            self.value = value
            self.label = label
            self.color = color
        }
    }
    
    // 属性
    private var chartType: ChartType = .bar
    private var dataItems: [DataItem] = []
    private var title: String = ""
    
    // 图表绘制区域的内边距
    private let padding: CGFloat = 20
    private let bottomPadding: CGFloat = 40  // 底部留出更多空间用于标签
    
    // 初始化方法
    init(frame: CGRect, type: ChartType) {
        super.init(frame: frame)
        self.chartType = type
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    // 设置图表数据
    func setData(items: [DataItem], title: String) {
        self.dataItems = items
        self.title = title
        setNeedsDisplay()
    }
    
    // 绘制图表
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext(), !dataItems.isEmpty else { return }
        
        // 绘制标题
        drawTitle(in: rect, context: context)
        
        // 根据图表类型绘制
        switch chartType {
        case .bar:
            drawBarChart(in: rect, context: context)
        case .pie:
            drawPieChart(in: rect, context: context)
        }
    }
    
    // 绘制标题
    private func drawTitle(in rect: CGRect, context: CGContext) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (rect.width - titleSize.width) / 2,
            y: padding / 2,
            width: titleSize.width,
            height: titleSize.height
        )
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    // 绘制柱状图
    private func drawBarChart(in rect: CGRect, context: CGContext) {
        // 计算图表区域
        let chartRect = CGRect(
            x: padding,
            y: padding + 20, // 标题下方
            width: rect.width - padding * 2,
            height: rect.height - padding - bottomPadding - 20 // 减去标题高度
        )
        
        // 找出最大值用于缩放
        let maxValue = dataItems.map { $0.value }.max() ?? 1.0
        
        // 计算每个柱子的宽度和间距
        let barCount = dataItems.count
        let barSpacing: CGFloat = 10
        let totalBarWidth = chartRect.width - (barSpacing * CGFloat(barCount - 1))
        let barWidth = totalBarWidth / CGFloat(barCount)
        
        // 绘制每个柱子
        for (index, item) in dataItems.enumerated() {
            let barHeight = CGFloat(item.value / maxValue) * chartRect.height
            let barX = chartRect.minX + CGFloat(index) * (barWidth + barSpacing)
            let barY = chartRect.maxY - barHeight
            
            let barRect = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
            
            // 绘制柱子
            context.setFillColor(item.color.cgColor)
            context.fill(barRect)
            
            // 绘制数值
            let valueString = String(format: "%.1f", item.value)
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            let valueSize = valueString.size(withAttributes: valueAttributes)
            let valueRect = CGRect(
                x: barX + (barWidth - valueSize.width) / 2,
                y: barY - valueSize.height - 4,
                width: valueSize.width,
                height: valueSize.height
            )
            
            valueString.draw(in: valueRect, withAttributes: valueAttributes)
            
            // 绘制标签
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            let labelSize = item.label.size(withAttributes: labelAttributes)
            let labelRect = CGRect(
                x: barX + (barWidth - labelSize.width) / 2,
                y: chartRect.maxY + 4,
                width: labelSize.width,
                height: labelSize.height
            )
            
            item.label.draw(in: labelRect, withAttributes: labelAttributes)
        }
    }
    
    // 绘制饼图
    private func drawPieChart(in rect: CGRect, context: CGContext) {
        // 计算图表区域
        let chartSize = min(rect.width, rect.height) - padding * 2 - 20 // 减去标题高度
        let chartRect = CGRect(
            x: (rect.width - chartSize) / 2,
            y: padding + 20, // 标题下方
            width: chartSize,
            height: chartSize
        )
        
        let center = CGPoint(x: chartRect.midX, y: chartRect.midY)
        let radius = chartSize / 2
        
        // 计算总和
        let total = dataItems.reduce(0) { $0 + $1.value }
        
        // 绘制饼图扇区
        var startAngle: CGFloat = -.pi / 2 // 从12点钟方向开始
        
        for (index, item) in dataItems.enumerated() {
            let endAngle = startAngle + CGFloat(item.value / total) * .pi * 2
            
            // 绘制扇区
            context.setFillColor(item.color.cgColor)
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
            
            // 计算标签位置（在扇区中间）
            let midAngle = (startAngle + endAngle) / 2
            let labelDistance = radius * 0.7
            let labelX = center.x + cos(midAngle) * labelDistance
            let labelY = center.y + sin(midAngle) * labelDistance
            
            // 绘制百分比标签
            let percentage = (item.value / total) * 100
            let percentString = String(format: "%.1f%%", percentage)
            let percentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.white
            ]
            
            let percentSize = percentString.size(withAttributes: percentAttributes)
            let percentRect = CGRect(
                x: labelX - percentSize.width / 2,
                y: labelY - percentSize.height / 2,
                width: percentSize.width,
                height: percentSize.height
            )
            
            percentString.draw(in: percentRect, withAttributes: percentAttributes)
            
            startAngle = endAngle
        }
        
        // 绘制图例
        drawLegend(in: rect, context: context, chartRect: chartRect)
    }
    
    // 绘制图例
    private func drawLegend(in rect: CGRect, context: CGContext, chartRect: CGRect) {
        let legendSpacing: CGFloat = 20
        let legendItemHeight: CGFloat = 20
        let legendMarkerSize: CGFloat = 12
        
        var legendY = chartRect.maxY + 10
        
        for item in dataItems {
            // 绘制颜色标记
            let markerRect = CGRect(
                x: padding,
                y: legendY + (legendItemHeight - legendMarkerSize) / 2,
                width: legendMarkerSize,
                height: legendMarkerSize
            )
            
            context.setFillColor(item.color.cgColor)
            context.fill(markerRect)
            
            // 绘制标签
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            let labelRect = CGRect(
                x: padding + legendMarkerSize + 8,
                y: legendY,
                width: rect.width - padding * 2 - legendMarkerSize - 8,
                height: legendItemHeight
            )
            
            item.label.draw(in: labelRect, withAttributes: labelAttributes)
            
            legendY += legendItemHeight + 4
        }
    }
}