//
//  AutoCompleteTextField.swift
//  Pods
//
//  Created by Neil Francis Hipona on 19/03/2016.
//  Copyright (c) 2016 Neil Francis Ramirez Hipona. All rights reserved.
//

import Foundation
import UIKit


open class AutoCompleteTextField: UITextField {
    
    /// AutoCompleteTextField data source
    open weak var autoCompleteTextFieldDataSource: AutoCompleteTextFieldDataSource?
    
    /// AutoCompleteTextField data source accessible through IB
    @IBOutlet weak internal var dataSource: AnyObject! {
        didSet {
            autoCompleteTextFieldDataSource = dataSource as? AutoCompleteTextFieldDataSource
        }
    }
    
    /// AutoCompleteTextField delegate
    open weak var autoCompleteTextFieldDelegate: AutoCompleteTextFieldDelegate!
    
    /// AutoCompleteTextField delegate accessible through IB
    weak open override var delegate: UITextFieldDelegate? {
        set (x) { autoCompleteTextFieldDelegate = x as? AutoCompleteTextFieldDelegate }
        get { return autoCompleteTextFieldDelegate }
    }
    
    fileprivate var autoCompleteLbl: ACTFLabel!
    fileprivate var delimiter: CharacterSet?
    
    fileprivate var xOffsetCorrection: CGFloat {
        get {
            switch borderStyle {
            case .bezel, .roundedRect:
                return 6.0
            case .line:
                return 1.0
                
            default:
                return 0.0
            }
        }
    }
    
    fileprivate var yOffsetCorrection: CGFloat {
        get {
            switch borderStyle {
            case .line, .roundedRect:
                return 0.5
                
            default:
                return 0.0
            }
        }
    }
    
    /// Auto completion flag
    open var autoCompleteDisabled: Bool = false
    
    /// Case search
    open var ignoreCase: Bool = true
    
    /// Randomize suggestion flag. Default to ``false, will always use first found suggestion
    open var isRandomSuggestion: Bool = false
    
    /// Supported domain names
    static open let domainNames: [ACTFWeightedDomain] = {
        return SupportedDomainNames
    }()
    
    /// Text font settings
    override open var font: UIFont? {
        didSet { autoCompleteLbl.font = font }
    }
    
    override open var textColor: UIColor? {
        didSet {
            autoCompleteLbl.textColor = textColor?.withAlphaComponent(0.5)
        }
    }
    
    // MARK: - Initialization
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareLayers()
        setupTargetObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLayers()
        setupTargetObserver()
    }
    
    /// Initialize `AutoCompleteTextField` with `AutoCompleteTextFieldDataSource` and optional `AutoCompleteTextFieldDelegate`
    convenience public init(frame: CGRect, autoCompleteTextFieldDataSource dataSource: AutoCompleteTextFieldDataSource, autoCompleteTextFieldDelegate delegate: AutoCompleteTextFieldDelegate! = nil) {
        self.init(frame: frame)
        
        autoCompleteTextFieldDataSource = dataSource
        autoCompleteTextFieldDelegate = delegate
        
        prepareLayers()
        setupTargetObserver()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        prepareLayers()
        setupTargetObserver()
    }
    
    
    // MARK: - R
    override open func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        
        if !autoCompleteDisabled {
            autoCompleteLbl.isHidden = false
            
            if clearsOnBeginEditing {
                autoCompleteLbl.text = ""
            }
            
            processAutoCompleteEvent()
        }
        
        return becomeFirstResponder
    }
    
    override open func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        
        if !autoCompleteDisabled {
            autoCompleteLbl.isHidden = true
            
            commitAutocompleteText()
        }
        
        return resignFirstResponder
    }
    
    
    // MARK: - Private Funtions
    fileprivate func prepareLayers() {
        
        autoCompleteLbl = ACTFLabel(frame: .zero)
        addSubview(autoCompleteLbl)
        
        autoCompleteLbl.font = font
        autoCompleteLbl.backgroundColor = .clear
        autoCompleteLbl.textColor = .lightGray
        autoCompleteLbl.lineBreakMode = .byClipping
        autoCompleteLbl.baselineAdjustment = .alignCenters
        autoCompleteLbl.isHidden = true
        
    }
    
    fileprivate func setupTargetObserver() {
        
        removeTarget(self, action: #selector(AutoCompleteTextField.autoCompleteTextFieldDidChanged(_:)), for: .editingChanged)
        addTarget(self, action: #selector(AutoCompleteTextField.autoCompleteTextFieldDidChanged(_:)), for: .editingChanged)
        
        super.delegate = self
    }
    
    fileprivate func performDomainSuggestionsSearch(_ queryString: String) -> ACTFWeightedDomain! {
        
        guard let autoCompleteTextFieldDataSource = autoCompleteTextFieldDataSource else { return processDataSource(SupportedDomainNames, queryString: queryString) }
        
        let dataSource = autoCompleteTextFieldDataSource.autoCompleteTextFieldDataSource(self)
        
        return processDataSource(dataSource, queryString: queryString)
    }
    
    fileprivate func processDataSource(_ dataSource: [ACTFWeightedDomain], queryString: String) -> ACTFWeightedDomain! {
        
        let stringFilter = ignoreCase ? queryString.lowercased() : queryString
        let suggestedDomains = dataSource.filter { (domain) -> Bool in
            if ignoreCase {
                return domain.text.lowercased().contains(stringFilter)
            }else{
                return domain.text.contains(stringFilter)
            }
        }
        
        if suggestedDomains.isEmpty {
            return nil
        }
        
        if isRandomSuggestion {
            let maxCount = suggestedDomains.count
            let randomIdx = arc4random_uniform(UInt32(maxCount))
            let suggestedDomain = suggestedDomains[Int(randomIdx)]
            
            return suggestedDomain
        }else{
            
            guard let suggestedDomain = suggestedDomains.sorted(by: { (domain1, domain2) -> Bool in
                return domain1.weight > domain2.weight && domain1.text < domain2.text
            }).first else { return nil }
            
            return suggestedDomain
        }
    }
    
    fileprivate func performTextCull(domain: ACTFWeightedDomain, stringFilter: String) -> String {
        guard let filterRange = ignoreCase ? domain.text.lowercased().range(of: stringFilter) : domain.text.range(of: stringFilter) else { return "" }
        
        let culledString = domain.text.replacingCharacters(in: filterRange, with: "")
        return culledString
    }
    
    fileprivate func actfBoundingRect(_ autocompleteString: String) -> CGRect {
        
        // get bounds for whole text area
        let textRectBounds = textRect(forBounds: bounds)
        
        // get rect for actual text
        guard let textRange = textRange(from: beginningOfDocument, to: endOfDocument) else { return .zero }
        
        let tRect = firstRect(for: textRange).integral
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let textAttributes: [String: AnyObject] = [NSFontAttributeName: font!, NSParagraphStyleAttributeName: paragraphStyle]
        
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let prefixTextRect = (text ?? "").boundingRect(with: textRectBounds.size, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let autoCompleteRectSize = CGSize(width: textRectBounds.width - prefixTextRect.width, height: textRectBounds.height)
        let autoCompleteTextRect = autocompleteString.boundingRect(with: autoCompleteRectSize, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let xOrigin = tRect.maxX + xOffsetCorrection
        let autoCompleteLblFrame = autoCompleteLbl.frame
        let finalX = xOrigin + autoCompleteTextRect.width
        let finalY = textRectBounds.minY + ((textRectBounds.height - autoCompleteLblFrame.height) / 2) - yOffsetCorrection
        
        if finalX >= textRectBounds.width {
            let autoCompleteRect = CGRect(x: textRectBounds.width, y: finalY, width: 0, height: autoCompleteLblFrame.height)
            
            return autoCompleteRect
            
        }else{
            let autoCompleteRect = CGRect(x: xOrigin, y: finalY, width: autoCompleteTextRect.width, height: autoCompleteLblFrame.height)
            
            return autoCompleteRect
        }
    }
    
    fileprivate func processAutoCompleteEvent() {
        if autoCompleteDisabled {
            return
        }
        
        guard let textString = text else { return }
        
        if let delimiter = delimiter {
            guard let _ = textString.rangeOfCharacter(from: delimiter) else { return }
            
            let textComponents = textString.components(separatedBy: delimiter)
            
            if textComponents.count > 2 { return }
            
            guard let textToLookFor = textComponents.last else { return }
            
            let domain = performDomainSuggestionsSearch(textToLookFor)
            updateAutocompleteLabel(domain: domain, originalString: textToLookFor)
        }else{
            let domain = performDomainSuggestionsSearch(textString)
            updateAutocompleteLabel(domain: domain, originalString: textString)
        }
    }
    
    fileprivate func updateAutocompleteLabel(domain: ACTFWeightedDomain!, originalString stringFilter: String) {
        
        guard let domain = domain else {
            autoCompleteLbl.text = ""
            autoCompleteLbl.sizeToFit()
            
            return
        }
        
        let culledString = performTextCull(domain: domain, stringFilter: stringFilter)
        
        autoCompleteLbl.domain = domain
        autoCompleteLbl.text = culledString
        autoCompleteLbl.sizeToFit()
        autoCompleteLbl.frame = actfBoundingRect(culledString)
    }
    
    fileprivate func commitAutocompleteText() {
        guard let autoCompleteString = autoCompleteLbl.text , !autoCompleteString.isEmpty else { return }
        let originalInputString = text ?? ""
        
        autoCompleteLbl.text = ""
        autoCompleteLbl.sizeToFit()
        autoCompleteLbl.domain.updateWeightUsage()
        autoCompleteLbl.domain = nil
        
        text = originalInputString + autoCompleteString
        sendActions(for: .valueChanged)
    }
    
    // MARK: - Internal Controls
    
    internal func autoCompleteButtonDidTapped(_ sender: UIButton) {
        endEditing(true)
        
        commitAutocompleteText()
    }
    
    internal func autoCompleteTextFieldDidChanged(_ textField: UITextField) {
        
        processAutoCompleteEvent()
    }
    
    // MARK: - Public Controls
    
    /// Set delimiter. Will perform search if delimiter is found
    open func setDelimiter(_ delimiterString: String) {
        delimiter = CharacterSet(charactersIn: delimiterString)
    }
    
    /// Show completion button with custom image
    open func showAutoCompleteButtonWithImage(_ image: UIImage? = UIImage(named: "checked", in: Bundle(for: AutoCompleteTextField.self), compatibleWith: nil), viewMode: AutoCompleteButtonViewMode) {
        
        var buttonFrameH: CGFloat = 0.0
        var buttonOriginY: CGFloat = 0.0
        
        if frame.height > defaultAutoCompleteButtonHeight {
            buttonFrameH = defaultAutoCompleteButtonHeight
            buttonOriginY = (frame.height - defaultAutoCompleteButtonHeight) / 2
        }else{
            buttonFrameH = frame.height
            buttonOriginY = 0
        }
        
        let autoCompleteButton = UIButton(frame: CGRect(x: 0, y: buttonOriginY, width: defaultAutoCompleteButtonWidth, height: buttonFrameH))
        autoCompleteButton.setImage(image, for: .normal)
        autoCompleteButton.addTarget(self, action: #selector(AutoCompleteTextField.autoCompleteButtonDidTapped(_:)), for: .touchUpInside)
        
        let containerFrame = CGRect(x: 0, y: 0, width: defaultAutoCompleteButtonWidth, height: frame.height)
        let autoCompleteButtonContainerView = UIView(frame: containerFrame)
        autoCompleteButtonContainerView.addSubview(autoCompleteButton)
        
        rightView = autoCompleteButtonContainerView
        rightViewMode = viewMode
    }
    
    /// Force text completion event
    open func forceRefresh() {
        
        processAutoCompleteEvent()
    }
    
}
