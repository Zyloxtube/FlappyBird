import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Physics Categories
    // Bitmasks so we can identify what hit what.
    let birdCategory: UInt32 = 1 << 0   // 0001
    let pipeCategory: UInt32 = 1 << 1   // 0010
    let groundCategory: UInt32 = 1 << 2 // 0100

    // MARK: - Game Nodes
    var bird: SKSpriteNode!
    var ground: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!

    // MARK: - Game State
    var isGameOver = false
    var score = 0

    // MARK: - Tunable Constants
    let gravity: CGFloat = -8.0
    let flapImpulse: CGFloat = 22.0
    let pipeSpeed: CGFloat = 3.0
    let pipeGap: CGFloat = 180.0
    let pipeWidth: CGFloat = 70.0
    let pipeSpawnInterval: TimeInterval = 1.6

    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor(red: 0.44, green: 0.74, blue: 0.95, alpha: 1.0)

        setupGround()
        setupBird()
        setupScoreLabel()
        setupGameOverLabel()
        startSpawningPipes()
    }

    // MARK: - Ground
    func setupGround() {
        let groundHeight: CGFloat = 80
        ground = SKSpriteNode(color: SKColor(red: 0.85, green: 0.75, blue: 0.35, alpha: 1.0),
                              size: CGSize(width: size.width, height: groundHeight))
        ground.position = CGPoint(x: size.width / 2, y: groundHeight / 2)
        ground.zPosition = 1

        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = birdCategory

        addChild(ground)
    }

    // MARK: - Bird
    func setupBird() {
        let birdSize = CGSize(width: 40, height: 40)
        bird = SKSpriteNode(color: .yellow, size: birdSize)
        bird.position = CGPoint(x: size.width * 0.25, y: size.height * 0.6)
        bird.zPosition = 2

        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdSize.width / 2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = 0
        bird.physicsBody?.contactTestBitMask = pipeCategory | groundCategory

        addChild(bird)
    }

    // MARK: - Score Label
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
    }

    // MARK: - Game Over Label
    func setupGameOverLabel() {
        gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "Tap to Restart"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel.zPosition = 10
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)
    }

    // MARK: - Pipe Spawning
    func startSpawningPipes() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnPipePair()
        }
        let wait = SKAction.wait(forDuration: pipeSpawnInterval)
        let sequence = SKAction.sequence([spawn, wait])
        run(SKAction.repeatForever(sequence), withKey: "spawnPipes")
    }

    func spawnPipePair() {
        guard !isGameOver else { return }

        let minCenter = pipeGap / 2 + 100
        let maxCenter = size.height - pipeGap / 2 - 100
        let gapCenter = CGFloat.random(in: minCenter...maxCenter)

        let startX = size.width + pipeWidth / 2
        let endX = -pipeWidth

        // Top pipe
        let topHeight = size.height - (gapCenter + pipeGap / 2)
        if topHeight > 0 {
            let topPipe = makePipe(height: topHeight)
            topPipe.position = CGPoint(x: startX, y: gapCenter + pipeGap / 2 + topHeight / 2)
            movePipe(topPipe, toX: endX, scoreWhenPassing: false)
            addChild(topPipe)
        }

        // Bottom pipe (this one triggers scoring)
        let bottomHeight = gapCenter - pipeGap / 2
        if bottomHeight > 0 {
            let bottomPipe = makePipe(height: bottomHeight)
            bottomPipe.position = CGPoint(x: startX, y: bottomHeight / 2)
            movePipe(bottomPipe, toX: endX, scoreWhenPassing: true)
            addChild(bottomPipe)
        }
    }

    func makePipe(height: CGFloat) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0),
                                size: CGSize(width: pipeWidth, height: height))
        pipe.zPosition = 1

        pipe.physicsBody = SKPhysicsBody(rectangleOf: pipe.size)
        pipe.physicsBody?.isDynamic = false
        pipe.physicsBody?.categoryBitMask = pipeCategory
        pipe.physicsBody?.contactTestBitMask = birdCategory

        return pipe
    }

    func movePipe(_ pipe: SKSpriteNode, toX endX: CGFloat, scoreWhenPassing: Bool) {
        let distance = pipe.position.x - endX
        let duration = TimeInterval(distance / (pipeSpeed * 60))
        let move = SKAction.moveTo(x: endX, duration: duration)
        let remove = SKAction.removeFromParent()

        if scoreWhenPassing {
            let scoreDelay = SKAction.wait(forDuration: duration * 0.5)
            let scoreAction = SKAction.run { [weak self] in
                self?.incrementScore()
            }
            pipe.run(SKAction.sequence([move, remove]))
            run(SKAction.sequence([scoreDelay, scoreAction]))
        } else {
            pipe.run(SKAction.sequence([move, remove]))
        }
    }

    // MARK: - Scoring
    func incrementScore() {
        guard !isGameOver else { return }
        score += 1
        scoreLabel.text = "\(score)"
    }

    // MARK: - Touch Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flapImpulse))
    }

    // MARK: - Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }

        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        if (maskA == birdCategory && (maskB == pipeCategory || maskB == groundCategory)) ||
           (maskB == birdCategory && (maskA == pipeCategory || maskA == groundCategory)) {
            endGame()
        }
    }

    // MARK: - Game Over
    func endGame() {
        isGameOver = true
        removeAction(forKey: "spawnPipes")
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.isDynamic = false
        gameOverLabel.isHidden = false
        gameOverLabel.text = "Game Over - Tap to Restart"
    }

    func restartGame() {
        removeAllChildren()
        removeAllActions()

        isGameOver = false
        score = 0

        setupGround()
        setupBird()
        setupScoreLabel()
        setupGameOverLabel()
        startSpawningPipes()
    }
}