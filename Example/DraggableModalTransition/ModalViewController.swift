import UIKit

final class ModalViewController: UIViewController {
    private struct Constants {
        static let verticalOffset: CGFloat = 20
        static let cornerRadius: CGFloat = 10
        static let sectionHeaderHeight: CGFloat = 52
        static let rowHeight: CGFloat = 40
        static let numberOfRows: Int = 50
        static let cellIdentifier = "Cell"
        static let dummyFooterHeight: CGFloat = 200
    }

    private enum RowType: Int {
        case close
        case push
        case present

        static var count: Int { return RowType.present.rawValue + 1 }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: Constants.verticalOffset, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        tableView.backgroundColor = .clear
        tableView.tableFooterView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.dummyFooterHeight))
            view.backgroundColor = .white
            return view
        }()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -Constants.dummyFooterHeight + Constants.verticalOffset, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: tableView.sectionHeaderHeight, left: 0, bottom: Constants.verticalOffset, right: 0)
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.layer.masksToBounds = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    weak var modalViewControllerDelegate: ModalViewControllerDelegate?

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

extension ModalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.sectionHeaderHeight))
        view.backgroundColor = .white
        view.roundsTopCorners(radius: Constants.cornerRadius)
        let label = UILabel()
        label.text = "Awesome Header"
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType(rawValue: indexPath.row % RowType.count)!
        switch rowType {
        case .close:
            dismiss(animated: true, completion: nil)
        case .push:
            let con = SecondViewController()
            navigationController?.pushViewController(con, animated: true)
        case .present:
            let con = SecondViewController()
            present(con, animated: true, completion: nil)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        modalViewControllerDelegate?.modalViewDidScroll(scrollView)
    }
}

extension ModalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfRows
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        let rowType = RowType(rawValue: indexPath.row % RowType.count)!
        let text: String = {
            switch rowType {
            case .close: return "Close"
            case .push: return  "Push"
            case .present: return "Present"
            }
        }()
        cell.textLabel?.text = text
        cell.backgroundColor = .white
        return cell
    }
}

private extension UIView {
    func roundsTopCorners(radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
