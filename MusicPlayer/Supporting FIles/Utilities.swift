//
//  Utilities.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import UIKit

extension String {
    static func isNilOrEmpty(string: String?) -> Bool {
        if string == nil { return true }
        if string!.count <= 0 { return true }
        return false
    }
}

extension UIView {
    func loadViewFromNib(_ nibName:String, forClass aClass: AnyClass! = nil, atIndex index:Int = 0) {
        let bundle:Bundle! = aClass != nil ? Bundle(for: aClass) : nil
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[index] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        addSubview(view)
        
        view.layoutIfNeeded()
        view.layoutSubviews()
    }
    
    func addSubViewToBottom(subview: UIView, withHeight height: CGFloat, withOffset offset: CGFloat = 0) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: offset),
            subview.widthAnchor.constraint(equalTo: self.widthAnchor),
            subview.heightAnchor.constraint(equalToConstant: height)
            ])
    }
}
