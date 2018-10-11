import UIKit
import WebKit
import Turbolinks

class ApplicationController: UINavigationController {
    
    var url: Foundation.URL {
        return Foundation.URL(string: "http://localhost:8000/?hybrid=true")!
    }
    
    fileprivate let webViewProcessPool = WKProcessPool()

    fileprivate var application: UIApplication {
        return UIApplication.shared
    }

    fileprivate lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = self.webViewProcessPool
        return configuration
    }()

    fileprivate lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Switching this to false will prevent content from sitting beneath scrollbar
        navigationBar.isTranslucent = false

        presentVisitableForSession(session, url: url)
        
    }

    fileprivate func presentVisitableForSession(_ session: Session, url: URL, action: Action = .Advance) {
        let visitable = VisitableViewController(url: url)

        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewController(animated: false)
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }

    fileprivate func presentAuthenticationController() {
        let authenticationController = AuthenticationController()
        authenticationController.delegate = self
        authenticationController.webViewConfiguration = webViewConfiguration
        authenticationController.url = url.appendingPathComponent("sign-in")
        authenticationController.title = "Sign in"

        let authNavigationController = UINavigationController(rootViewController: authenticationController)
        present(authNavigationController, animated: true, completion: nil)
    }
    
}

extension ApplicationController: SessionDelegate {
    func session(_ session: Session, didProposeVisitToURL URL: Foundation.URL, withAction action: Action) {

        presentVisitableForSession(session, url: URL, action: action)
    
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        
        NSLog("ERROR: %@", error)
        guard let errorCode = ErrorCode(rawValue: error.code) else { return }

        switch errorCode {
        case .httpFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 401:
                presentAuthenticationController()
            case 404:
                //presentError(.HTTPNotFoundError)
                print("no internet connection error happened")
            default:
                //presentError(Error(HTTPStatusCode: statusCode))
                print("no internet connection error happened")
            }
        case .networkFailure:
            print("no internet connection error happened")
            //presentError(.NetworkError)
        }
    }
    
    func sessionDidStartRequest(_ session: Session) {
        application.isNetworkActivityIndicatorVisible = true
    }

    func sessionDidFinishRequest(_ session: Session) {
        application.isNetworkActivityIndicatorVisible = false
    }
}

extension ApplicationController: AuthenticationControllerDelegate {
    func authenticationControllerDidAuthenticate(_ authenticationController: AuthenticationController) {
        session.reload()
        dismiss(animated: true, completion: nil)
    }
}

extension ApplicationController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let message = message.body as? String {
            let alertController = UIAlertController(title: "Turbolinks", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}
