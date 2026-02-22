import UIKit

class QuWanViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = QuWanHomeViewController()
        addChild(homeVC)
        view.addSubview(homeVC.view)
        homeVC.view.frame = view.bounds
        homeVC.didMove(toParent: self)
        
        title = "趣玩"
    }
}
