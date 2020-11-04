import Foundation

open class SelectorScrollStackAdapter<ControlModel: SelectorScrollStackControlCreatable>: NSObject, SelectorScrollStackViewDelegate {

    public weak var selector: SelectorScrollStackView? {
        didSet {
            self.setup()
        }
    }

    public var models: [ControlModel] = [] {
        didSet {
            self.setup()
        }
    }

    public var didSelectControls: (([ControlModel]) -> Void)?
    
    public init(models: [ControlModel] = []) {
        super.init()
        self.models = models
    }

    open func setup() {
        self.selector?.delegate = self
        let controls = self.models.enumerated().map({ $0.element.createControl(self.models, index: $0.offset) })
        self.selector?.controls = controls
    }

    // MARK: - SelectorViewDelegate
    public func sizeForControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) -> CGSize? {
        guard self.models.indices.contains(index) else { return nil }
        return self.models[index].sizeForControl(selector, control: control, index: index, isSelected: isSelected)
    }
    
    public func willDisplayControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) {
        guard self.models.indices.contains(index) else { return }
        self.models[index].willDisplayControl(selector, control: control, index: index, isSelected: isSelected)
    }
    
    public func tapControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) { }
    
    public func didSelectControls(_ selector: SelectorScrollStackView, controlsSelected: [UIControl], indexesControlsSelected: [Int]) {
        var modelsSelected: [ControlModel] = []
        indexesControlsSelected.forEach({ index in
            if self.models.indices.contains(index) {
                modelsSelected.append(self.models[index])
            }
        })
        self.didSelectControls?(modelsSelected)
    }

}
