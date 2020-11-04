//
//  ViewController.swift
//  SelectorScrollStackView
//
//  Created by Dmitriy Polyakov on 11/04/2020.
//  Copyright (c) 2020 Dmitriy Polyakov. All rights reserved.
//

import UIKit
import SelectorScrollStackView

class ViewController: UIViewController {
    
    let horizontalSelector = SelectorScrollStackView(axis: .horizontal)
    let verticalSelector = SelectorScrollStackView(axis: .vertical)
    
    let horizontalAdapter = SelectorScrollStackAdapter<TestSelectorItemModel>()
    let verticalAdapter = SelectorScrollStackAdapter<TestSelectorItemModel>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        [self.horizontalSelector, self.verticalSelector].forEach({
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.scrollView.showsHorizontalScrollIndicator = false
            $0.scrollView.showsVerticalScrollIndicator = false
            $0.spacing = 10
        })
        
        NSLayoutConstraint.activate([
            self.horizontalSelector.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            self.horizontalSelector.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.horizontalSelector.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.horizontalSelector.heightAnchor.constraint(equalToConstant: 50),
            
            self.verticalSelector.topAnchor.constraint(equalTo: self.horizontalSelector.bottomAnchor, constant: 20),
            self.verticalSelector.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.verticalSelector.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.verticalSelector.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.horizontalSelector.backgroundColor = .blue
        self.horizontalSelector.mode = .controlsSizeFromDelegateOrSelfSize
        self.horizontalSelector.selectMode = .multiple
        
        self.horizontalAdapter.selector = self.horizontalSelector
        self.horizontalAdapter.models = TestSelectorItemModel.allCases
        
        self.verticalSelector.backgroundColor = .cyan
        self.verticalSelector.mode = .controlFillEquallyAndParentWidth
        self.verticalSelector.selectMode = .multiple
        
        self.verticalAdapter.selector = self.verticalSelector
        self.verticalAdapter.models = TestSelectorItemModel.allCases
    }

}

enum TestSelectorItemModel: String, SelectorScrollStackControlCreatable, CaseIterable {
    case test1 = "test1"
    case test2 = "test2"
    case test3 = "test3"
    case test4 = "test4"
    case test5 = "test5"
    case test6 = "test6"
    case test7 = "test7"
    
    func createControl(_ models: [SelectorScrollStackControlCreatable], index: Int) -> UIControl {
        let btn = UIButton()
        btn.setTitle(self.rawValue, for: .normal)
        return btn
    }
    
    func sizeForControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) -> CGSize? {
        isSelected ? .init(width: 100, height: 60) : nil
    }
    
    func willDisplayControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) {
        if isSelected {
            control.backgroundColor = .red
        } else {
            control.backgroundColor = .green
        }
    }
}
