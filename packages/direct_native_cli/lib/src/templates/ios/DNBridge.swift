import UIKit

@objc public class DNBridge: NSObject {
    private weak var rootViewController: DNRootViewController?
    private var viewRegistry: [String: UIView] = [:]
    private let mainQueue = DispatchQueue.main

    init(rootViewController: DNRootViewController) {
        self.rootViewController = rootViewController
        super.init()
    }

    @objc public func createView(_ viewId: String, properties: [String: Any], callback: @escaping (Bool) -> Void) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }

            let view = self.createUIView(from: properties)
            self.viewRegistry[viewId] = view
            self.rootViewController?.addView(view)
            callback(true)
        }
    }

    private func createUIView(from properties: [String: Any]) -> UIView {
        let view = UIView()
        updateUIView(view, with: properties)
        return view
    }

    private func updateUIView(_ view: UIView, with properties: [String: Any]) {
        if let style = properties["style"] as? [String: Any] {
            applyStyle(to: view, style: style)
        }
    }

    private func applyStyle(to view: UIView, style: [String: Any]) {
        if let backgroundColor = style["backgroundColor"] as? String {
            view.backgroundColor = UIColor(hexString: backgroundColor)
        }

        if let width = style["width"] as? CGFloat {
            view.frame.size.width = width
        }

        if let height = style["height"] as? CGFloat {
            view.frame.size.height = height
        }

        if let cornerRadius = style["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = cornerRadius
        }
    }
}
