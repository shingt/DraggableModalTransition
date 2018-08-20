import UIKit

final class SecondViewController: UIViewController {
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.sizeToFit()
        button.center = view.center
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(closeButton)
    }

    @objc internal func close() {
        dismiss(animated: true, completion: nil)
    }
}
