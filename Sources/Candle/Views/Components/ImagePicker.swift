import SwiftUI
import UIKit

/// Custom touch pass-through view for the camera overlay so default controls (shutter, cancel, flip) work unimpeded.
final class CameraTouchPassThroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        // If the tap is on the container overlay itself, pass it down to the native camera controls
        return (hitView == self) ? nil : hitView
    }
}

/// Fully interactive flash button placed over the top toolbar to guarantee responsive toggling.
final class CameraFlashOverlayButton: UIButton {
    weak var picker: UIImagePickerController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 17
        layer.masksToBounds = true
        addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    }
    
    @objc private func toggleFlash() {
        guard let picker = picker else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        switch picker.cameraFlashMode {
        case .auto:
            picker.cameraFlashMode = .on
        case .on:
            picker.cameraFlashMode = .off
        case .off:
            picker.cameraFlashMode = .auto
        @unknown default:
            picker.cameraFlashMode = .auto
        }
        
        updateAppearance()
    }
    
    func updateAppearance() {
        guard let picker = picker else { return }
        
        if !UIImagePickerController.isFlashAvailable(for: picker.cameraDevice) {
            self.isHidden = true
            return
        }
        self.isHidden = false
        
        let mode = picker.cameraFlashMode
        let iconName: String
        let titleText: String
        let tint: UIColor
        
        let store = BirthdayStore.shared
        switch mode {
        case .auto:
            iconName = "bolt.badge.automatic.fill"
            titleText = store.tr(.flashAuto)
            tint = .systemYellow
        case .on:
            iconName = "bolt.fill"
            titleText = store.tr(.flashOn)
            tint = .systemYellow
        case .off:
            iconName = "bolt.slash.fill"
            titleText = store.tr(.flashOff)
            tint = .white
        @unknown default:
            iconName = "bolt.slash.fill"
            titleText = store.tr(.flashOff)
            tint = .white
        }
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor.black.withAlphaComponent(0.65)
        config.baseForegroundColor = tint
        config.image = UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold))
        config.imagePadding = 5
        config.imagePlacement = .leading
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        config.attributedTitle = AttributedString(titleText, attributes: container)
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        self.configuration = config
        self.layer.borderWidth = 1
        self.layer.borderColor = tint.withAlphaComponent(0.4).cgColor
    }
}

public final class NativeCameraPickerController: UIImagePickerController {
    private var flashOverlayButton: CameraFlashOverlayButton?
    private var passThroughOverlay: CameraTouchPassThroughView?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var childForStatusBarHidden: UIViewController? {
        return nil
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = true
        view.backgroundColor = .black
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFlashOverlayIfNeeded()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let overlay = passThroughOverlay {
            overlay.frame = view.bounds
        }
        flashOverlayButton?.updateAppearance()
    }
    
    private func setupFlashOverlayIfNeeded() {
        guard sourceType == .camera, passThroughOverlay == nil else { return }
        
        let overlay = CameraTouchPassThroughView(frame: view.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = .clear
        
        let button = CameraFlashOverlayButton(type: .system)
        button.picker = self
        button.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            button.topAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.topAnchor, constant: 12),
            button.heightAnchor.constraint(equalToConstant: 34),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        self.cameraOverlayView = overlay
        self.passThroughOverlay = overlay
        self.flashOverlayButton = button
        
        button.updateAppearance()
    }
}

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var allowsEditing: Bool = true
    var onImagePicked: ((UIImage) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    public init(
        selectedImage: Binding<UIImage?>,
        sourceType: UIImagePickerController.SourceType = .photoLibrary,
        allowsEditing: Bool = true,
        onImagePicked: ((UIImage) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
        self.allowsEditing = allowsEditing
        self.onImagePicked = onImagePicked
        self.onCancel = onCancel
    }
    
    public init(
        sourceType: UIImagePickerController.SourceType = .camera,
        allowsEditing: Bool = false,
        onCancel: (() -> Void)? = nil,
        onImagePicked: @escaping (UIImage) -> Void
    ) {
        self._selectedImage = .constant(nil)
        self.sourceType = sourceType
        self.allowsEditing = allowsEditing
        self.onImagePicked = onImagePicked
        self.onCancel = onCancel
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = NativeCameraPickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        picker.modalPresentationStyle = .fullScreen
        picker.view.isOpaque = true
        picker.view.backgroundColor = .black
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
            if sourceType == .camera {
                if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                    picker.cameraDevice = .rear
                }
                picker.showsCameraControls = true
                if UIImagePickerController.isFlashAvailable(for: picker.cameraDevice) {
                    picker.cameraFlashMode = .auto
                }
            }
        } else {
            picker.sourceType = .photoLibrary
        }
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            let resultImage: UIImage? = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let img = resultImage {
                parent.selectedImage = img
                parent.onImagePicked?(img)
            }
            parent.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel?()
            parent.dismiss()
        }
    }
}
