import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let skView = SKView(frame: window!.bounds)
        skView.ignoresSiblingOrder = true

        let scene = GameScene(size: window!.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        let viewController = UIViewController()
        viewController.view = skView

        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}
