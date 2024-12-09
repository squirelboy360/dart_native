import UIKit

class DNRootViewController: UIViewController {
    private var mainView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
    }

    private func setupMainView() {
        mainView = UIView(frame: view.bounds)
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mainView)
    }

    func addView(_ view: UIView) {
        mainView.addSubview(view)
    }
}
