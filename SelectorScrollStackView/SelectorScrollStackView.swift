import Foundation
import UIKit
import ScrollStackView

// MARK: - SelectorScrollStackViewDelegate
public protocol SelectorScrollStackViewDelegate: NSObjectProtocol {
    func sizeForControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) -> CGSize?
    func willDisplayControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool)
    func tapControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool)
    func didSelectControls(_ selector: SelectorScrollStackView, controlsSelected: [UIControl], indexesControlsSelected: [Int])
}

public extension SelectorScrollStackViewDelegate {
    func sizeForControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) -> CGSize? { nil }
    func willDisplayControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) {}
    func tapControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) {}
    func didSelectControls(_ selector: SelectorScrollStackView, controlsSelected: [UIControl], indexesControlsSelected: [Int]) {}
}

// MARK: - SelectorScrollStackView
open class SelectorScrollStackView: ScrollStackView {
    
    public enum Mode {
        case controlFillEquallyAndParentWidth
        case controlsSizeFromDelegateOrSelfSize
    }
    
    public enum SelectMode {
        case single
        case multiple
    }
    
    public weak var delegate: SelectorScrollStackViewDelegate?
    
    public var controls: [UIControl] = [] {
        didSet {
            self.setupViews()
        }
    }
    
    private(set) var controlsSelected: [UIControl] = []
    private(set) var indexesControlsSelected: [Int] = []
    
    public var selectMode: SelectMode = .single
    public var minSelectedCount: Int?
    public var maxSelectedCount: Int?
    
    private var controlsContaints: [NSLayoutConstraint] = []
    
    public var mode: Mode = .controlFillEquallyAndParentWidth {
        didSet {
            self.setupViews()
        }
    }
    
    public func controlIsSelected(_ control: UIControl) -> Bool {
        self.controlsSelected.contains(control)
    }
    
    public func setupControlsSelected(_ controlsSelected: [UIControl]) {
        var controlsAllowed: [UIControl] = []
        controlsSelected.forEach({ control in
            if self.controls.contains(control) {
                controlsAllowed.append(control)
            }
        })
        self.controlsSelected = controlsAllowed
        
        self.indexesControlsSelected.removeAll()
        self.controls.enumerated().forEach({ index, control in
            if self.controlsSelected.contains(control) {
                self.indexesControlsSelected.append(index)
            }
        })
        self.setupViews()
    }
    
    public func setupIndexesControlsSelected(_ indexesControlsSelected: [Int]) {
        var indexesControlsAllowed: [Int] = []
        indexesControlsSelected.forEach({ index in
            if self.controls.indices.contains(index) {
                indexesControlsAllowed.append(index)
            }
        })
        self.indexesControlsSelected = indexesControlsAllowed
        
        self.controlsSelected.removeAll()
        self.indexesControlsSelected.forEach({ index in
            if self.controls.indices.contains(index) {
                self.controlsSelected.append(self.controls[index])
            }
        })
        self.setupViews()
    }
    
    open override func setupViews() {
        super.setupViews()
        self.setupControls()
    }
    
    open func setupControls() {
        self.controlsContaints.forEach({ $0.isActive = false })
        self.controlsContaints.removeAll()
        
        self.stackView.subviews.forEach({ subview in self.stackView.removeArrangedSubview(subview) })

        self.controls.enumerated().forEach({ index, control in
            self.delegate?.willDisplayControl(self, control: control, index: index, isSelected: self.controlIsSelected(control))
            self.stackView.addArrangedSubview(control)
            control.addTarget(self, action: #selector(self.tapControl(_:)), for: .touchUpInside)
        })
        
        switch self.mode {
        case .controlFillEquallyAndParentWidth:
            self.stackView.distribution = .fillEqually
            switch self.stackView.axis {
            case .horizontal:
                let constant = -(self.stackInsets.left + self.stackInsets.right)
                NSLayoutConstraint.activate([
                    self.scrollView.widthAnchor.constraint(equalTo: self.widthAnchor),
                    self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: constant)
                ])
            case .vertical:
                let constant = -(self.stackInsets.top + self.stackInsets.bottom)
                NSLayoutConstraint.activate([
                    self.scrollView.heightAnchor.constraint(equalTo: self.heightAnchor),
                    self.stackView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: constant)
                ])
            @unknown default:
                break
            }
        case .controlsSizeFromDelegateOrSelfSize:
            self.stackView.distribution = .fill
            self.controls.enumerated().forEach({ index, control in
                if let size = self.delegate?.sizeForControl(self, control: control, index: index, isSelected: self.controlIsSelected(control)) {
                    switch self.stackView.axis {
                    case .horizontal:
                        let constraint = control.widthAnchor.constraint(equalToConstant: size.width)
                        constraint.isActive = true
                        self.controlsContaints.append(constraint)
                    case .vertical:
                        let constraint = control.heightAnchor.constraint(equalToConstant: size.height)
                        constraint.isActive = true
                        self.controlsContaints.append(constraint)
                    @unknown default:
                        break
                    }
                }
            })
        }
    }
    
    @objc
    open func tapControl(_ control: UIControl) {
        guard let index = self.controls.firstIndex(of: control) else { return }
        self.delegate?.tapControl(self, control: control, index: index, isSelected: self.controlIsSelected(control))
        
        var needInformFromDelegate: Bool
        
        switch self.selectMode {
        case .single:
            if self.minSelectedCount ?? 0 > 0 {
                if !self.controlIsSelected(control) {
                    self.setupControlsSelected([control])
                    needInformFromDelegate = true
                } else {
                    needInformFromDelegate = false
                }
            } else {
                self.setupControlsSelected(self.controlIsSelected(control) ? [] : [control])
                needInformFromDelegate = true
            }
        case .multiple:
            if self.controlIsSelected(control), self.controlsSelected.count - 1 >= self.minSelectedCount ?? 0 {
                var controlsSelectedNew = self.controlsSelected
                controlsSelectedNew.removeAll(where: { $0 == control })
                self.setupControlsSelected(controlsSelectedNew)
                needInformFromDelegate = true
            }
            else if !self.controlIsSelected(control), self.controlsSelected.count + 1 <= self.maxSelectedCount ?? self.controls.count {
                var controlsSelectedNew = self.controlsSelected
                controlsSelectedNew.append(control)
                self.setupControlsSelected(controlsSelectedNew)
                needInformFromDelegate = true
            } else {
                needInformFromDelegate = false
            }
        }
        
        guard needInformFromDelegate else { return }
        self.delegate?.didSelectControls(self, controlsSelected: self.controlsSelected, indexesControlsSelected: self.indexesControlsSelected)
    }
    
}
