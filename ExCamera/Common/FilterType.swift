import Foundation

enum FilterType: String, CaseIterable {
    case sepiaTone = "CISepiaTone"
    case colorMonochrome = "CIColorMonochrome"
    case falseColor = "CIFalseColor"
    case colorControls = "CIColorControls"
    case toneCurve = "CIToneCurve"
    case hueAdjust = "CIHueAdjust"
    case pixellate = "CIPixellate"
}
