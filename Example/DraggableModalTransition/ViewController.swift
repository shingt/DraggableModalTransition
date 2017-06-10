import UIKit

final class ViewController: UIViewController {
    private var modalTransition: DraggableModalTransition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
       
        let button: UIButton = {
            let button = UIButton()
            button.setTitle("Pop", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.sizeToFit()
            button.center = view.center
            button.addTarget(self, action: #selector(presentModalView), for: .touchUpInside)
            return button
        }()
        view.addSubview(button)
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

final class ModalViewController: UIViewController {
    weak var modalViewControllerDelegate: ModalViewControllerDelegate?
    
    private var tableView: UITableView {
        let tableView = UITableView()
        let verticalOffset: CGFloat = 20
        tableView.frame = CGRect(x: 0, y: verticalOffset, width: self.view.frame.size.width, height: self.view.frame.size.height)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 40
        tableView.delegate = self
        tableView.dataSource = self
        let dummyFooterView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200))
            view.backgroundColor = .white
            return view
        }()
        tableView.tableFooterView = dummyFooterView
        tableView.sectionHeaderHeight = 44
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -dummyFooterView.frame.height + verticalOffset, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: tableView.sectionHeaderHeight, left: 0, bottom: verticalOffset, right: 0)
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }
}

extension ModalViewController: UITableViewDelegate, UITableViewDataSource {
    private enum RowType: Int {
        case close = 0
        case push = 1
        case present = 2
        static var count: Int { return RowType.present.rawValue + 1 }
    }
    
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        view.backgroundColor = .white
        view.roundsTopCorners(radius: 10)
        let label = UILabel()
        label.text = "Awesome Header"
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let rowType = RowType(rawValue: indexPath.row % RowType.count)!
        let text: String
        switch rowType {
        case .close:
            text = "Close"
        case .push:
            text = "Push"
        case .present:
            text = "Present"
        }
        cell.textLabel?.text = text
        cell.backgroundColor = .white
        return cell
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType(rawValue: indexPath.row % RowType.count)!
        switch rowType {
        case .close:
            dismiss(animated: true, completion: nil)
        case .push:
            let con = NextViewController()
            navigationController?.pushViewController(con, animated: true)
        case .present:
            let con = NextViewController()
            present(con, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        modalViewControllerDelegate?.modalViewDidScroll(scrollView)
    }
}

final class NextViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .white
       
        let button: UIButton = {
            let button = UIButton()
            button.setTitle("close", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.sizeToFit()
            button.center = view.center
            button.addTarget(self, action: #selector(close), for: .touchUpInside)
            return button
        }()
        view.addSubview(button)
    }
    
    @objc internal func close() {
        dismiss(animated: true, completion: nil)
    }
}

private extension UIView {
    func roundsTopCorners(radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer 
    }
}
