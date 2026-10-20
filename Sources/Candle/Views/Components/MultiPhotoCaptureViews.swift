import SwiftUI
import UIKit
import PhotosUI
@preconcurrency import AVFoundation

// MARK: - Multi-Photo Library Picker (PHPickerViewController)

/// Modern multi-image picker using Apple's PhotosUI PHPickerViewController.
/// Supports selecting as many photos as the user wants (selectionLimit = 0).
public struct MultiPhotoPicker: UIViewControllerRepresentable {
    private let onPhotosPicked: ([UIImage]) -> Void
    private let onCancel: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    public init(
        onCancel: (() -> Void)? = nil,
        onPhotosPicked: @escaping ([UIImage]) -> Void
    ) {
        self.onCancel = onCancel
        self.onPhotosPicked = onPhotosPicked
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        // 0 signifies unlimited selection
        configuration.selectionLimit = 0
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: MultiPhotoPicker
        
        init(_ parent: MultiPhotoPicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.onCancel?()
                parent.dismiss()
                return
            }
            
            final class SafeImageCollector: @unchecked Sendable {
                private let lock = NSLock()
                private(set) var images: [UIImage] = []
                func append(_ image: UIImage) {
                    lock.lock()
                    images.append(image)
                    lock.unlock()
                }
            }
            
            let group = DispatchGroup()
            let collector = SafeImageCollector()
            
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        defer { group.leave() }
                        if let image = object as? UIImage {
                            let normalized = image.normalizedOrientation()
                            collector.append(normalized)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                let finalImages = collector.images
                if !finalImages.isEmpty {
                    self.parent.onPhotosPicked(finalImages)
                } else {
                    self.parent.onCancel?()
                }
                self.parent.dismiss()
            }
        }
    }
}

// MARK: - Multi-Shot Camera Manager

/// Service managing the live camera session and multiple shot captures
final class MultiCameraManager: NSObject, ObservableObject, @unchecked Sendable, AVCapturePhotoCaptureDelegate {
    @Published var capturedImages: [UIImage] = []
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto
    @Published var isFrontCamera: Bool = false
    @Published var isCameraAvailable: Bool = true
    @Published var isAuthorized: Bool = true
    @Published var isSessionRunning: Bool = false
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.candle.camera.sessionQueue")
    private var currentDeviceInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        checkAuthorization()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            isAuthorized = false
            isCameraAvailable = false
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // Default to rear camera
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.isCameraAvailable = false
                }
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.currentDeviceInput = input
            } else {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.isCameraAvailable = false
                }
                return
            }
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.maxPhotoQualityPrioritization = .balanced
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isCameraAvailable = true
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }
    
    func toggleCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let newPosition: AVCaptureDevice.Position = self.isFrontCamera ? .back : .front
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
                return
            }
            
            self.session.beginConfiguration()
            if let current = self.currentDeviceInput {
                self.session.removeInput(current)
            }
            
            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.currentDeviceInput = newInput
                DispatchQueue.main.async {
                    self.isFrontCamera = (newPosition == .front)
                }
            } else if let current = self.currentDeviceInput {
                self.session.addInput(current)
            }
            
            self.session.commitConfiguration()
        }
    }
    
    func cycleFlash() {
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
    }
    
    func capturePhoto() {
        guard isCameraAvailable else {
            // Generate simulated snapshot on simulator
            simulateCapture()
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            if self.photoOutput.supportedFlashModes.contains(self.flashMode) {
                settings.flashMode = self.flashMode
            }
            settings.photoQualityPrioritization = .balanced
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func simulateCapture() {
        // Fallback for Simulator testing so it produces real photos
        let size = CGSize(width: 1080, height: 1440)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            // Beautiful background gradient
            let colors = [UIColor.systemIndigo.cgColor, UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
            ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Timestamp and Candle branding
            let text = "✨ Candle Memory Snapshot\n\(Date().formatted(date: .abbreviated, time: .standard))"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 42, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let string = NSAttributedString(string: text, attributes: attrs)
            string.draw(in: CGRect(x: 60, y: size.height - 200, width: size.width - 120, height: 150))
        }
        
        DispatchQueue.main.async {
            self.capturedImages.append(image)
        }
    }
    
    func removeImage(at index: Int) {
        guard capturedImages.indices.contains(index) else { return }
        capturedImages.remove(at: index)
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        
        let normalized = image.normalizedOrientation()
        DispatchQueue.main.async {
            self.capturedImages.append(normalized)
        }
    }
}

// MARK: - Camera Preview Layer

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Multi-Shot Camera View (SwiftUI)

/// High-speed continuous camera view. Allows the user to shoot as many photos as they want,
/// preview them in real time in a bottom tray, and save all captured photos in one batch.
public struct MultiShotCameraView: View {
    @ObservedObject var store: BirthdayStore
    var onPhotosCaptured: ([UIImage]) -> Void
    
    @StateObject private var cameraManager = MultiCameraManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var shutterFlashOpacity: Double = 0.0
    @State private var showingDiscardConfirmation: Bool = false
    
    public init(
        store: BirthdayStore,
        onPhotosCaptured: @escaping ([UIImage]) -> Void
    ) {
        self.store = store
        self.onPhotosCaptured = onPhotosCaptured
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 1. Live Camera Preview or Simulator Mockup
            if cameraManager.isCameraAvailable && cameraManager.isAuthorized {
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
            } else {
                simulatorFallbackView
            }
            
            // 2. Tactile Shutter Flash overlay
            Color.white
                .ignoresSafeArea()
                .opacity(shutterFlashOpacity)
                .allowsHitTesting(false)
            
            // 3. Camera Interface Controls
            VStack {
                topToolbar
                Spacer()
                bottomControls
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .statusBarHidden(true)
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .confirmationDialog(
            store.tr(.deletePhotoConfirm),
            isPresented: $showingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button(store.tr(.savePhotosCount(cameraManager.capturedImages.count))) {
                finishAndSave()
            }
            Button(store.tr(.delete), role: .destructive) {
                dismiss()
            }
            Button(store.tr(.cancel), role: .cancel) {}
        }
    }
    
    // MARK: - Subviews
    
    private var topToolbar: some View {
        HStack(spacing: 16) {
            // Close / Dismiss button
            Button {
                CandleTheme.hapticSelection()
                if cameraManager.capturedImages.isEmpty {
                    dismiss()
                } else {
                    showingDiscardConfirmation = true
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Flash Mode button
            Button {
                CandleTheme.hapticSelection()
                cameraManager.cycleFlash()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: flashIconName)
                        .font(.system(size: 14, weight: .bold))
                    Text(flashTitle)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(cameraManager.flashMode == .off ? .white : .yellow)
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(Color.black.opacity(0.55))
                .clipShape(Capsule())
            }
            
            // Camera Rotate button
            Button {
                CandleTheme.hapticSelection()
                cameraManager.toggleCamera()
            } label: {
                Image(systemName: "camera.rotate.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 10)
    }
    
    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Horizontal preview strip of captured photos
            if !cameraManager.capturedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(cameraManager.capturedImages.enumerated()), id: \.offset) { index, img in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 58, height: 58)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                    )
                                
                                Button {
                                    CandleTheme.hapticSelection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        cameraManager.removeImage(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6).clipShape(Circle()))
                                }
                                .offset(x: 5, y: -5)
                            }
                            .padding(.top, 6)
                            .padding(.trailing, 4)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 72)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Bottom Action Bar: Thumbnails Count, Shutter Button, and Finish Button
            HStack(spacing: 24) {
                // Left: Photo counter badge
                HStack(spacing: 6) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 15))
                    Text("\(cameraManager.capturedImages.count)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(width: 70, height: 44)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                .opacity(cameraManager.capturedImages.isEmpty ? 0.3 : 1.0)
                
                Spacer()
                
                // Center: Shutter Button
                Button {
                    triggerShutter()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 76, height: 76)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 62, height: 62)
                    }
                }
                .buttonStyle(ShutterPressButtonStyle())
                
                Spacer()
                
                // Right: Done / Save Button
                Button {
                    finishAndSave()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text(store.tr(.savePhotosCount(cameraManager.capturedImages.count)))
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(cameraManager.capturedImages.isEmpty ? Color.white.opacity(0.2) : store.accentPrimary)
                    .clipShape(Capsule())
                }
                .disabled(cameraManager.capturedImages.isEmpty)
                .opacity(cameraManager.capturedImages.isEmpty ? 0.4 : 1.0)
            }
        }
    }
    
    private var simulatorFallbackView: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(store.accentPrimary)
            
            VStack(spacing: 6) {
                Text(store.tr(.cameraTitle))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(store.tr(.cameraUnavailable))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                CandleTheme.hapticSelection()
                cameraManager.simulateCapture()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text(store.tr(.simulateShot))
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(store.accentGradient)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .darkGray).opacity(0.35))
    }
    
    // MARK: - Actions
    
    private func triggerShutter() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Shutter flash animation
        shutterFlashOpacity = 0.6
        withAnimation(.easeOut(duration: 0.18)) {
            shutterFlashOpacity = 0.0
        }
        
        // Capture photo
        cameraManager.capturePhoto()
    }
    
    private func finishAndSave() {
        guard !cameraManager.capturedImages.isEmpty else { return }
        CandleTheme.hapticNotification(type: .success)
        onPhotosCaptured(cameraManager.capturedImages)
        dismiss()
    }
    
    private var flashIconName: String {
        switch cameraManager.flashMode {
        case .auto: return "bolt.badge.automatic.fill"
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        @unknown default: return "bolt.slash.fill"
        }
    }
    
    private var flashTitle: String {
        switch cameraManager.flashMode {
        case .auto: return store.tr(.flashAuto)
        case .on: return store.tr(.flashOn)
        case .off: return store.tr(.flashOff)
        @unknown default: return store.tr(.flashOff)
        }
    }
}

// MARK: - Shutter Button Style with Spring Scale

private struct ShutterPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - UIImage Orientation Normalizer

extension UIImage {
    /// Normalizes image orientation (converting EXIF orientations like .right into standard .up)
    fileprivate func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}
