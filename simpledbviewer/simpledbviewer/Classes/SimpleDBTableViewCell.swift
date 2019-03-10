//
//  SimpleDBTableViewCell.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/27/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit
import AWSSimpleDB

class SimpleDBTableViewCell: UITableViewCell {
    var itemName: UILabel!
    var otherAttributes: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let labelHeight: CGFloat = 30
        itemName = UILabel(frame: CGRect.zero)
        self.contentView.addSubview(itemName)
        itemName.translatesAutoresizingMaskIntoConstraints = false
        itemName.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0).isActive = true
        itemName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0).isActive = true
        itemName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0).isActive = true
        itemName.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
        itemName.minimumScaleFactor = 0.4
        itemName.adjustsFontSizeToFitWidth = true
        itemName.numberOfLines = 1
        itemName.lineBreakMode = .byTruncatingMiddle
        
        otherAttributes = UILabel(frame: CGRect.zero)
        otherAttributes.numberOfLines = 0
        otherAttributes.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(otherAttributes)
        otherAttributes.translatesAutoresizingMaskIntoConstraints = false
        otherAttributes.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0).isActive = true
        otherAttributes.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0).isActive = true
        otherAttributes.topAnchor.constraint(equalTo: itemName.bottomAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: otherAttributes.bottomAnchor, constant: 8.0).isActive = true
    }
    
    func getText() -> String{
        return "\(itemName.text ?? "ITEMNAME:")\n\(otherAttributes.text ?? "")"
    }
    
    func setup(items: AWSSimpleDBItem, numberOfRow: Int, highlight: Bool){

        self.itemName.text = "Item #\(numberOfRow): \(items.name ?? "")"
        if let attributes = items.attributes {
            let boldText = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3),
                            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue] as [NSAttributedString.Key : Any]
            let regularText = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
            let attributedText = NSMutableAttributedString()
            
            for attribute in attributes {
                let _name = NSAttributedString(string: "\(attribute.name ?? ""): ", attributes: boldText)
                attributedText.append(_name)
                let _value = NSAttributedString(string: "\(attribute.value ?? "")\n", attributes: regularText)
                attributedText.append(_value)
            }
            self.otherAttributes.attributedText = attributedText
            if highlight {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }else{
                self.backgroundColor = UIColor.white
            }
        }
    }

}
