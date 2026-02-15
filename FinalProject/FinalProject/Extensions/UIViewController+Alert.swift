import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    func showConfirmationAlert(title: String, message: String, confirmTitle: String, confirmStyle: UIAlertAction.Style = .default, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: confirmStyle) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    func showActionSheet(title: String?, message: String? = nil, sourceView: UIView, actions: [(String, UIAlertAction.Style, () -> Void)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (actionTitle, style, handler) in actions {
            alert.addAction(UIAlertAction(title: actionTitle, style: style) { _ in
                handler()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        
        present(alert, animated: true)
    }
}
