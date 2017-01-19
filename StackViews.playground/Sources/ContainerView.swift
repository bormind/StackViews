import Foundation
import UIKit

let titleSize = CGSize(width: 200, height: 20)
let sampleSpace: CGFloat = 50
let sampleHeight: CGFloat = 100

public class ContainerView: UIView {
    
    var nextY: CGFloat = 30
    
    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.gray
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func renderSample(sampleView: UIView, title: String) {
        
        let label = createLabel(text: title, position: CGPoint(x: 2, y: self.nextY), size: titleSize)
        
        self.addSubview(label)
        self.nextY += titleSize.height + 5
        
        sampleView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(sampleView)
        
        NSLayoutConstraint.activate([
        
            sampleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2),
            sampleView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.nextY),
            sampleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2),
//            sampleView.widthAnchor.constraint(equalToConstant: 220),
            
            sampleView.heightAnchor.constraint(equalToConstant: sampleHeight)
        ])
        
        
        self.nextY += sampleHeight + 20
    }
    

}
