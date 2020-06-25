import UIKit
import ARKit
import Cartography
import DIKit

final class ARCameraViewController: UIViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: ARCameraViewModel
    }

    static func makeInstance(dependency: Dependency) -> ARCameraViewController {
        let viewController = StoryboardScene.ARCameraViewController.arCameraViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!

    private let dataSource: ARCameraDataSource = ARCameraDataSource()

    private let session: ARSession = ARSession()

    lazy var configuration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 11.3, *) {
            configuration.planeDetection = [.vertical, .horizontal]
        }
        return configuration
    }()
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        return textField
    }()
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        view.delegate = self
        view.session = session
        view.session.delegate = self
        view.automaticallyUpdatesLighting = true
        view.scene = SCNScene()
        return view
    }()
    lazy var removeNodesButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .white
        button.backgroundColor = UIColor.lightGray
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(Asset.Assets.iconTrash.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.3
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).removeNodes), for: .touchUpInside)
        return button
    }()
    lazy var keyboardButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .white
        button.backgroundColor = UIColor.themeColor()
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(Asset.Assets.iconKeyboard.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.3
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).showKeyboard), for: .touchUpInside)
        return button
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.register(ARCameraGifCell.self, forCellWithReuseIdentifier: "ARCameraGifCell")
        return view
    }()
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: keyboardButton),
                                              UIBarButtonItem(customView: removeNodesButton)]

        view.addSubview(sceneView)
        view.addSubview(collectionView)
        view.addSubview(textField)

        dataSource.items = dependency.viewModel.sections

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        constrain(sceneView) {
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.top == $0.superview!.top
        }
        constrain(collectionView, sceneView) {
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.top == $1.bottom
            $0.bottom == $0.superview!.bottom
            $0.width == $0.superview!.width
            $0.height == 80
        }
    }
}

extension ARCameraViewController {
    @objc func removeNodes() {
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
    }
    @objc func showKeyboard() {
        textField.becomeFirstResponder()
    }
}

// MARK: ARSCNViewDelegate

extension ARCameraViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {}
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {}
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {}
}

// MARK: ARSessionDelegate

extension ARCameraViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {}
}

// MARK: UITextFieldDelegate

extension ARCameraViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let worldPosition = sceneView.pointOfView!.convertPosition(SCNVector3(x: 0, y: 0, z: -0.5), to: nil)
        let screenSpacePosition = sceneView.projectPoint(worldPosition)
        let position = sceneView.unprojectPoint(screenSpacePosition)
        let text = SCNText(string: textField.text, extrusionDepth: 0.1)
        text.font = UIFont(name: "HiraKakuProN-W6", size: 0.5)
        let textNode = SCNNode(geometry: text)
        let (min, max) = (textNode.boundingBox)
        let x = Float(max.x - min.x)
        let y = Float(max.y - min.y)
        let depth: Float = 5
        textNode.pivot = SCNMatrix4MakeTranslation((x / 2) + min.x, (y / 2) + min.y, depth)
        textNode.position = position
        textNode.eulerAngles = sceneView.pointOfView!.eulerAngles
        sceneView.scene.rootNode.addChildNode(textNode)
        textField.text = ""
    }
}

// MARK: UICollectionViewDelegate

extension ARCameraViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch dataSource.items[indexPath.section].elements[indexPath.row] {
        case .gif(let element):
            let worldPosition = sceneView.pointOfView!.convertPosition(SCNVector3(x: 0, y: 0, z: -0.5), to: nil)
            let screenSpacePosition = sceneView.projectPoint(worldPosition)
            let position = sceneView.unprojectPoint(screenSpacePosition)
            element.scene.node.position = position
            element.scene.node.eulerAngles = sceneView.pointOfView!.eulerAngles
            sceneView.scene.rootNode.addChildNode(element.scene.node)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ARCameraViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70.0, height: 70.0)
    }
}
