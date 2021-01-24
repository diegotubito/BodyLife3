//
//  StockTableView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 23/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class StockTableView: XibViewBlurBackground {
    @IBOutlet weak var tableView: NSTableView!
    var viewModel: StockTableViewModelProtocol!
    @IBOutlet weak var indicator: NSProgressIndicator!
    override func commonInit() {
        super .commonInit()
        viewModel = StockTableViewModel(withView: self)
        tableView.delegate = self
        tableView.dataSource = self
        createBackgroundGradient()
        viewModel.loadProducts()
        NotificationCenter.default.addObserver(self, selector: #selector(articleDidChangeHandler), name: .needUpdateArticleList, object: nil)
    }
    
    @objc func articleDidChangeHandler() {
        viewModel.loadProducts()
    }
    
    func createBackgroundGradient() {
        self.layer?.backgroundColor = NSColor.black.cgColor
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.5, 1]
        gradient.colors = [NSColor(hex: 0x020707).cgColor,
                           NSColor(hex: 0x1A3B78).withAlphaComponent(0.7).cgColor,
                           NSColor(hex: 0x020707).cgColor]
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        self.layer?.addSublayer(gradient)
    }
}

extension StockTableView: StockTableViewProtocol {
    func showSavingStock() {
        DispatchQueue.main.async {
            self.tableView.isEnabled = false
            self.indicator.startAnimation(nil)
        }
    }
    
    func hideSavingStock() {
        DispatchQueue.main.async {
            self.tableView.isEnabled = true
            self.indicator.stopAnimation(nil)
        }

    }
    
    func showLoadingProducts() {
        DispatchQueue.main.async {
            self.indicator.startAnimation(nil)
        }

    }
    
    func hideLoadingProducts() {
        DispatchQueue.main.async {
            self.indicator.stopAnimation(nil)
        }

    }
    
    func showProductList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}

extension StockTableView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel.model.articles == nil {return 0}
        return viewModel.model.articles.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard viewModel.model.articles != nil else {
            return ""
        }
        switch tableColumn?.identifier.rawValue {
        case "stock":
            return String(viewModel.model.articles[row].stock)
        case "description":
            return viewModel.model.articles[row].description
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let stringValue = object as? String,
              let intValue = Int(stringValue) else {
            return
        }
        if intValue < 1000 {
            self.viewModel.saveNewStockValue(value: intValue, row: row)
        }
    }
    
}
