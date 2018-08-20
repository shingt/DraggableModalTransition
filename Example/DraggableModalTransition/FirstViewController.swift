import UIKit

final class FirstViewController: UIViewController {
    private var modalTransition: DraggableModalTransition!

    private lazy var presentButton: UIButton = {
        let button = UIButton()
        button.setTitle("Present", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(presentModalView), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
        view.addSubview(presentButton)
        presentButton.center = view.center
    }

    @objc internal func presentModalView() {
        let controller = ModalViewController()
        let navigationController = UINavigationController(rootViewController: controller)

        modalTransition = DraggableModalTransition(with: controller)
        navigationController.transitioningDelegate = modalTransition
        controller.modalViewControllerDelegate = modalTransition
        present(navigationController, animated: true, completion: nil)
    }
}
