import Foundation
import UIKit

let titleSize = CGSize(width: 400, height: 20)
let sampleSpace: CGFloat = 50
let sampleHeight: CGFloat = 100

public class ContainerView: UIView {
    
    var nextY: CGFloat = 30
    
    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.lightGray
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func renderSample(sampleView: UIView,
                             title: String,
                             y: CGFloat? = nil,
                             width: CGFloat? = nil,
                             height: CGFloat? = 0) {
        
        let label = UILabel(frame: CGRect(x: 2, y: self.nextY, size: titleSize))
        label.text = title
        self.addSubview(label)
        self.nextY += titleSize.height + 5
        
        sampleView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(sampleView)
        
        var constrains: [NSLayoutConstraint] = []
        
        let yToUse = y ?? self.nextY
        
        constrains.append(sampleView.topAnchor.constraint(equalTo: self.topAnchor, constant: yToUse))
        
        if let width = width {
            constrains += [
                sampleView.widthAnchor.constraint(equalToConstant: width),
                sampleView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ]
        }
        else {
            constrains += [
                sampleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
                sampleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
            ]
        }
        
        let heightToUse = height ?? sampleHeight
        constrains.append(sampleView.heightAnchor.constraint(equalToConstant: heightToUse))
        
        NSLayoutConstraint.activate(constrains)
        
        
        self.nextY = yToUse + heightToUse + 20
    }
    

}
