import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = GameViewController()

        self.window = window

        window.makeKeyAndVisible()

        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .all
    }
}


// MARK: - Game

final class GameViewController: UIViewController {

    private let scoreLabel = UILabel()
    private let targetButton = UIButton(type: .system)
    private let messageLabel = UILabel()

    private var score = 0
    private var targetSize: CGFloat = 90

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupGame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        moveTarget()
    }

    private func setupGame() {

        // Score
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "SCORE: 0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.monospacedBoldSystemFont(
            ofSize: 28
        )
        scoreLabel.textAlignment = .center

        view.addSubview(scoreLabel)

        // Message
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "TAP THE RED TARGET!"
        messageLabel.textColor = .white
        messageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        messageLabel.textAlignment = .center

        view.addSubview(messageLabel)

        // Target
        targetButton.translatesAutoresizingMaskIntoConstraints = true

        targetButton.frame = CGRect(
            x: 0,
            y: 0,
            width: targetSize,
            height: targetSize
        )

        targetButton.backgroundColor = .systemRed
        targetButton.layer.cornerRadius = targetSize / 2
        targetButton.layer.borderWidth = 5
        targetButton.layer.borderColor = UIColor.white.cgColor

        targetButton.setTitle("💥", for: .normal)
        targetButton.titleLabel?.font = UIFont.systemFont(ofSize: 35)

        targetButton.addTarget(
            self,
            action: #selector(targetTapped),
            for: .touchUpInside
        )

        view.addSubview(targetButton)

        NSLayoutConstraint.activate([

            scoreLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),

            scoreLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            messageLabel.topAnchor.constraint(
                equalTo: scoreLabel.bottomAnchor,
                constant: 10
            ),

            messageLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }

    @objc
    private func targetTapped() {

        score += 1

        scoreLabel.text = "SCORE: \(score)"

        // Make it progressively smaller.
        targetSize = max(
            45,
            90 - CGFloat(score) * 2
        )

        targetButton.bounds = CGRect(
            x: 0,
            y: 0,
            width: targetSize,
            height: targetSize
        )

        targetButton.layer.cornerRadius = targetSize / 2

        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.targetButton.transform =
                    CGAffineTransform(scaleX: 1.4, y: 1.4)
            },
            completion: { _ in

                UIView.animate(
                    withDuration: 0.12
                ) {
                    self.targetButton.transform = .identity
                }
            }
        )

        moveTarget()
    }

    private func moveTarget() {

        let safeFrame = view.bounds.insetBy(
            dx: 20,
            dy: 20
        )

        let topReserved: CGFloat = 150

        let minX = safeFrame.minX
        let maxX = safeFrame.maxX - targetSize

        let minY = safeFrame.minY + topReserved
        let maxY = safeFrame.maxY - targetSize

        guard maxX >= minX, maxY >= minY else {
            return
        }

        let x = CGFloat.random(
            in: minX...maxX
        )

        let y = CGFloat.random(
            in: minY...maxY
        )

        UIView.animate(
            withDuration: 0.2,
            animations: {

                self.targetButton.frame = CGRect(
                    x: x,
                    y: y,
                    width: self.targetSize,
                    height: self.targetSize
                )
            }
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if targetButton.frame == .zero {
            moveTarget()
        }
    }
}
