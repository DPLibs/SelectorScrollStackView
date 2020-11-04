import Foundation

public protocol SelectorScrollStackControlCreatable {
    func createControl(_ models: [SelectorScrollStackControlCreatable], index: Int) -> UIControl
    func sizeForControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool) -> CGSize?
    func willDisplayControl(_ selector: SelectorScrollStackView, control: UIControl, index: Int, isSelected: Bool)
}
