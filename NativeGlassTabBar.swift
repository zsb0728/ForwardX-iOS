import UIKit
import WebKit
import Capacitor

final class NativeGlassTabBarController: CAPBridgeViewController {
    private let bar = UIVisualEffectView()
    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    private let items = [
        ("square.grid.2x2.fill", "仪表盘", "dashboard"),
        ("arrow.left.arrow.right", "转发", "forward"),
        ("square.grid.3x3.fill", "管理", "manage"),
        ("person.crop.circle.fill", "我的", "me")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGlass()
        configureItems()
        select(0)
    }

    private func configureGlass() {
        if #available(iOS 26.0, *) {
            bar.effect = UIGlassEffect(style: .regular)
        } else {
            bar.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        bar.layer.cornerRadius = 28
        bar.layer.cornerCurve = .continuous
        bar.clipsToBounds = true
        bar.layer.borderWidth = 0.5
        bar.layer.borderColor = UIColor.white.withAlphaComponent(0.38).cgColor
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            bar.heightAnchor.constraint(equalToConstant: 66)
        ])
        stack.axis = .horizontal; stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        bar.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: bar.contentView.leadingAnchor, constant: 5),
            stack.trailingAnchor.constraint(equalTo: bar.contentView.trailingAnchor, constant: -5),
            stack.topAnchor.constraint(equalTo: bar.contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bar.contentView.bottomAnchor, constant: -4)
        ])
    }

    private func configureItems() {
        for (index, item) in items.enumerated() {
            var c = UIButton.Configuration.plain()
            c.image = UIImage(systemName: item.0)
            c.title = item.1
            c.imagePlacement = .top
            c.imagePadding = 2
            c.baseForegroundColor = .secondaryLabel
            c.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming; out.font = .systemFont(ofSize: 10, weight: .semibold); return out
            }
            let b = UIButton(configuration: c); b.tag = index
            b.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b); buttons.append(b)
        }
    }

    @objc private func tapped(_ sender: UIButton) {
        select(sender.tag)
        let key = items[sender.tag].2
        let js: String
        if key == "dashboard" {
            js = "document.querySelector('#fx-ios-tabbar [data-tab=dashboard]')?.click()"
        } else {
            js = "document.querySelector('#fx-ios-tabbar [data-tab=\(key)]')?.click()"
        }
        bridge?.webView?.evaluateJavaScript(js)
    }

    private func select(_ index: Int) {
        for (i, b) in buttons.enumerated() {
            var c = b.configuration
            c?.baseForegroundColor = i == index ? .systemBlue : .secondaryLabel
            b.configuration = c
        }
    }
}
