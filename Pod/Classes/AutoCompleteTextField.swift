//
//  AutoCompleteTextField.swift
//  Pods
//
//  Created by Neil Francis Hipona on 19/03/2016.
//  Copyright (c) 2016 Neil Francis Ramirez Hipona. All rights reserved.
//

import Foundation
import UIKit

private let defaultAutoCompleteButtonWidth: CGFloat = 30.0
private let defaultAutoCompleteButtonHeight: CGFloat = 30.0

public typealias AutoCompleteButtonViewMode = UITextFieldViewMode

public protocol AutoCompleteTextFieldDataSource: NSObjectProtocol {
    
    func autoCompleteTextFieldDataSource(autoCompleteTextField: AutoCompleteTextField) -> [String]
}

public class AutoCompleteTextField: UITextField {
    
    private var autoCompleteLbl: UILabel!
    private var delimiter: NSCharacterSet?
    private let xOffsetCorrection: CGFloat = 6.0

    /// Data source
    public weak var autoCompleteTextFieldDataSource: AutoCompleteTextFieldDataSource?

    @IBOutlet weak public var dataSource: AnyObject! {
        didSet {
            autoCompleteTextFieldDataSource = dataSource as? AutoCompleteTextFieldDataSource
        }
    }
    
    /// Auto completion flag
    var autoCompleteDisabled: Bool = false
    
    /// Case search
    var ignoreCase: Bool = true
    
    /// Randomize suggestion flag. Default to ``false, will always use first found suggestion
    var isRandomSuggestion: Bool = false
    
    /// Text font settings
    override public var font: UIFont? {
        didSet {
            autoCompleteLbl.font = font
        }
    }
    
    override public var textColor: UIColor? {
        didSet {
            autoCompleteLbl.textColor = textColor?.colorWithAlphaComponent(0.5)
        }
    }
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTargetObserver()
        prepareAutoCompleteTextFieldLayers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupTargetObserver()
        prepareAutoCompleteTextFieldLayers()
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        prepareAutoCompleteTextFieldLayers()
        setupTargetObserver()
        
    }
    
    
    // MARK: - R
    override public func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        
        if !autoCompleteDisabled {
            autoCompleteLbl.hidden = false
            
            if clearsOnBeginEditing {
                autoCompleteLbl.text = ""
            }
            
            processAutoCompleteEvent()
        }
        
        return becomeFirstResponder
    }
    
    override public func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        
        if !autoCompleteDisabled {
            autoCompleteLbl.hidden = true
            
            processAutoCompleteEvent()
            commitAutocompleteText()
        }
        
        return resignFirstResponder
    }
    
    
    // MARK: - Private Funtions
    private func prepareAutoCompleteTextFieldLayers() {
        
        autoCompleteLbl = UILabel(frame: CGRectZero)
        addSubview(autoCompleteLbl)
        
        autoCompleteLbl.font = font
        autoCompleteLbl.backgroundColor = UIColor.clearColor()
        autoCompleteLbl.textColor = UIColor.lightGrayColor()
        autoCompleteLbl.lineBreakMode = .ByClipping
        autoCompleteLbl.baselineAdjustment = .AlignCenters
        autoCompleteLbl.hidden = true
        
    }
    
    private func setupTargetObserver() {
        
        removeTarget(self, action: "autoCompleteTextFieldDidChanged:", forControlEvents: .EditingChanged)
        addTarget(self, action: "autoCompleteTextFieldDidChanged:", forControlEvents: .EditingChanged)
    }
    
    private func performStringSuggestionsSearch(textToLookFor: String) -> String {
        
        // handle nil data source
        guard let autoCompleteTextFieldDataSource = autoCompleteTextFieldDataSource else { return "" }
        
        let dataSource = autoCompleteTextFieldDataSource.autoCompleteTextFieldDataSource(self)
        
        var suggestionStrings: [String] = []
        
        if ignoreCase {
            suggestionStrings = dataSource.filter({ (stringToCompare) -> Bool in
                return stringToCompare.lowercaseString.hasPrefix(textToLookFor.lowercaseString)
            })
        }else{
            suggestionStrings = dataSource.filter({ (stringToCompare) -> Bool in
                return stringToCompare.hasPrefix(textToLookFor)
            })
        }
        
        if suggestionStrings.isEmpty {
            return ""
        }
        
        if isRandomSuggestion {
            let maxSuggestionCount = suggestionStrings.count
            let randomIdx = arc4random_uniform(UInt32(maxSuggestionCount))
            let suggestedString = suggestionStrings[Int(randomIdx)]
            
            return suggestedString.stringByReplacingCharactersInRange(suggestedString.rangeOfString(textToLookFor)!, withString: "")
        }else{
            let suggestedString = suggestionStrings.first ?? ""
            return suggestedString.stringByReplacingCharactersInRange(suggestedString.rangeOfString(textToLookFor)!, withString: "")
        }
    }
    
    private func autocompleteBoundingRect(autocompleteString: String) -> CGRect {
        
        // get bounds for whole text area
        let textRectBounds = textRectForBounds(bounds)
        
        // get rect for actual text
        guard let textRange = textRangeFromPosition(beginningOfDocument, toPosition: endOfDocument) else { return CGRectZero }
        
        let textRect = CGRectIntegral(firstRectForRange(textRange))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByCharWrapping
        
        let textAttributes: [String: AnyObject] = [NSFontAttributeName: font!, NSParagraphStyleAttributeName: paragraphStyle]
        
        let drawingOptions: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        
        let prefixTextRect = (text ?? "" as NSString).boundingRectWithSize(textRectBounds.size, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let autoCompleteRectSize = CGSizeMake(textRectBounds.width - prefixTextRect.width, textRectBounds.height)
        let autocompleteTextRect = (autocompleteString as NSString).boundingRectWithSize(autoCompleteRectSize, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let xOrigin = CGRectGetMaxX(textRect) + xOffsetCorrection
        let finalX = xOrigin + autocompleteTextRect.width
        
        if finalX >= textRectBounds.width {
            let autoCompleteRect = CGRectMake(textRectBounds.width, CGRectGetMinY(textRectBounds), 0, textRectBounds.height)
            
            return autoCompleteRect
            
        }else{
            let autoCompleteRect = CGRectMake(xOrigin, CGRectGetMinY(textRectBounds), autocompleteTextRect.width, textRectBounds.height)
            
            return autoCompleteRect
        }
    }
    
    
    private func processAutoCompleteEvent() {
        if autoCompleteDisabled {
            return
        }
        
        guard let textString = text else { return }
        
        if let delimiter = delimiter {
            guard let _ = textString.rangeOfCharacterFromSet(delimiter) else { return }
            
            let textComponents = textString.componentsSeparatedByCharactersInSet(delimiter)
            
            if textComponents.count > 2 { return }
            
            guard let textToLookFor = textComponents.last else { return }
            
            let autocompleteString = performStringSuggestionsSearch(textToLookFor)
            updateAutocompleteLabel(autocompleteString)
        }else{
            let autocompleteString = performStringSuggestionsSearch(textString)
            updateAutocompleteLabel(autocompleteString)
        }
    }
    
    private func updateAutocompleteLabel(autocompleteString: String) {
        autoCompleteLbl.text = autocompleteString
        autoCompleteLbl.frame = autocompleteBoundingRect(autocompleteString)
    }
    
    private func commitAutocompleteText() {
        guard let autocompleteString = autoCompleteLbl.text where !autocompleteString.isEmpty else { return }
        let originalInputString = text ?? ""
        
        autoCompleteLbl.text = ""
        text = originalInputString + autocompleteString
    }
    
    // MARK: - Internal Controls
    
    func autoCompleteButtonDidTapped(sender: UIButton) {
        endEditing(true)
        
        processAutoCompleteEvent()
        commitAutocompleteText()
    }
    
    func autoCompleteTextFieldDidChanged(textField: UITextField) {
        
        processAutoCompleteEvent()
    }
    
    
    // MARK: - Public Controls
    
    /// Set delimiter. Will perform search if delimiter is found
    public func setDelimiter(delimiterString: String) {
        delimiter = NSCharacterSet(charactersInString: delimiterString)
    }
    
    /// Show completion button
    public func showAutoCompleteButtonWithViewMode(autoCompleteButtonViewMode: AutoCompleteButtonViewMode) {
        
        var buttonFrameH: CGFloat = 0.0
        var buttonOriginY: CGFloat = 0.0
        
        if frame.height > defaultAutoCompleteButtonHeight {
            buttonFrameH = defaultAutoCompleteButtonHeight
            buttonOriginY = (frame.height - defaultAutoCompleteButtonHeight) / 2
        }else{
            buttonFrameH = frame.height
            buttonOriginY = 0
        }
        
        let autoCompleteButton = UIButton(type: .DetailDisclosure)
        autoCompleteButton.frame = CGRectMake(0, buttonOriginY, defaultAutoCompleteButtonWidth, buttonFrameH)
        autoCompleteButton.addTarget(self, action: "autoCompleteButtonDidTapped:", forControlEvents: .TouchUpInside)
        
        let containerFrame = CGRectMake(0, 0, defaultAutoCompleteButtonWidth, frame.height)
        let autoCompleteButtonContainerView = UIView(frame: containerFrame)
        autoCompleteButtonContainerView.addSubview(autoCompleteButton)
        
        rightView = autoCompleteButtonContainerView
        rightViewMode = autoCompleteButtonViewMode
    }
    
    /// Show completion button with custom image
    public func showAutoCompleteButtonWithImage(buttonImage: UIImage, autoCompleteButtonViewMode: AutoCompleteButtonViewMode) {
        
        var buttonFrameH: CGFloat = 0.0
        var buttonOriginY: CGFloat = 0.0
        
        if frame.height > defaultAutoCompleteButtonHeight {
            buttonFrameH = defaultAutoCompleteButtonHeight
            buttonOriginY = (frame.height - defaultAutoCompleteButtonHeight) / 2
        }else{
            buttonFrameH = frame.height
            buttonOriginY = 0
        }
        
        let autoCompleteButton = UIButton(frame: CGRectMake(0, buttonOriginY, defaultAutoCompleteButtonWidth, buttonFrameH))
        autoCompleteButton.setImage(buttonImage, forState: .Normal)
        autoCompleteButton.addTarget(self, action: "autoCompleteButtonDidTapped:", forControlEvents: .TouchUpInside)
        
        let containerFrame = CGRectMake(0, 0, defaultAutoCompleteButtonWidth, frame.height)
        let autoCompleteButtonContainerView = UIView(frame: containerFrame)
        autoCompleteButtonContainerView.addSubview(autoCompleteButton)
        
        rightView = autoCompleteButtonContainerView
        rightViewMode = autoCompleteButtonViewMode
    }
    
    /// Force text completion event
    public func forceRefreshAutocompleteText() {
        
        processAutoCompleteEvent()
    }
    
}