#!/bin/bash

set -e  # Exit on any error

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up iOS integration...${NC}"

# Ensure we're in the correct directory structure
if [ ! -d "packages/direct_native_cli" ]; then
    echo -e "${RED}Error: Must be run from project root with existing packages/direct_native_cli${NC}"
    exit 1
fi

# Create iOS template directory
mkdir -p packages/direct_native_cli/lib/src/templates/ios

# Create DNAppDelegate.swift
cat > packages/direct_native_cli/lib/src/templates/ios/DNAppDelegate.swift << 'END'
import UIKit

@UIApplicationMain
class DNAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var bridge: DNBridge?

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = DNRootViewController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        bridge = DNBridge(rootViewController: rootViewController)
        return true
    }
}
END

# Create DNBridge.swift
cat > packages/direct_native_cli/lib/src/templates/ios/DNBridge.swift << 'END'
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
END

# Create DNRootViewController.swift
cat > packages/direct_native_cli/lib/src/templates/ios/DNRootViewController.swift << 'END'
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
END

# Create UIColor+Hex.swift
cat > packages/direct_native_cli/lib/src/templates/ios/UIColor+Hex.swift << 'END'
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
END

# Update _createIosProject method in ProjectCreator
echo "Now update _createIosProject method in packages/direct_native_cli/lib/src/templates/project_template.dart to use these template files"

echo -e "${GREEN}iOS integration setup completed!${NC}"
echo "Next steps:"
echo "1. Update the ProjectCreator class to include these iOS template files"
echo "2. Test iOS project creation"
