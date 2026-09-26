import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = GameViewController()
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}

class GameViewController: UIViewController {

    private var score = 0

    private var targetButton: UIButton!
    private var scoreLabel: UILabel!
    private var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupUI()
        spawnTarget()
    }

    private func setupUI() {

        // MARK: - Title

        titleLabel = UILabel()
        titleLabel.text = "🔥 TAP ATTACK 🔥"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        // MARK: - Score

        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .systemYellow
        scoreLabel.textAlignment = .center

        scoreLabel.font = UIFont.monospacedSystemFont(
            ofSize: 28,
            weight: .bold
        )

        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scoreLabel)

        // MARK: - Target Button

        targetButton = UIButton(type: .system)

        targetButton.setTitle("TAP ME!", for: .normal)
        targetButton.setTitleColor(.white, for: .normal)

        targetButton.titleLabel?.font = UIFont.boldSystemFont(
            ofSize: 24
        )

        targetButton.backgroundColor = .systemRed
        targetButton.layer.cornerRadius = 60

        targetButton.addTarget(
            self,
            action: #selector(targetTapped),
            for: .touchUpInside
        )

        targetButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(targetButton)

        // MARK: - Constraints

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 30
            ),

            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            scoreLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 20
            ),

            scoreLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            targetButton.widthAnchor.constraint(
                equalToConstant: 120
            ),

            targetButton.heightAnchor.constraint(
                equalToConstant: 120
            ),

            targetButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            targetButton.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    // MARK: - Target Tapped

    @objc private func targetTapped() {

        score += 1

        scoreLabel.text = "Score: \(score)"

        spawnTarget()

        UIView.animate(
            withDuration: 0.1,
            animations: {

                self.targetButton.transform =
                    CGAffineTransform(
                        scaleX: 1.25,
                        y: 1.25
                    )
            },
            completion: { _ in

                UIView.animate(
                    withDuration: 0.1
                ) {

                    self.targetButton.transform = .identity
                }
            }
        )
    }

    // MARK: - Spawn Target

    private func spawnTarget() {

        let size: CGFloat = 120

        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        let safeTop =
            view.safeAreaInsets.top + 150

        let safeBottom =
            screenHeight -
            view.safeAreaInsets.bottom -
            100

        guard screenWidth > size,
              safeBottom > safeTop else {
            return
        }

        let x = CGFloat.random(
            in: (size / 2)...(screenWidth - size / 2)
        )

        let y = CGFloat.random(
            in: safeTop...safeBottom
        )

        targetButton.center = CGPoint(
            x: x,
            y: y
        )
    }
}
