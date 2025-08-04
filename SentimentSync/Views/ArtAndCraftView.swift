import SwiftUI

// A struct to represent a single line in the drawing.
struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

struct ArtAndCraftView: View {
    @State private var lines: [Line] = []
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 5
    @State private var showConfirmation = false
    @State private var confirmationMessage = ""
    @State private var canvasRect: CGRect = .zero // To store canvas size for saving

    private let availableColors: [Color] = [.black, .red, .blue, .green, .yellow, .orange, .purple, .brown, .white]

    var body: some View {
        VStack(spacing: 0) {
            // The main drawing canvas
            canvas
                .background(Color.white)
                .gesture(drawingGesture)
                .background(GeometryReader { geometry in // Capture the canvas size
                    Color.clear.preference(key: CanvasRectPreferenceKey.self, value: geometry.frame(in: .local))
                })
                .onPreferenceChange(CanvasRectPreferenceKey.self) { rect in
                    self.canvasRect = rect
                }

            // Control panel for colors and brush size
            controlPanel
        }
        .navigationTitle("Art & Craft")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: undoLastLine) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(lines.isEmpty)

                Button("Clear", action: clearDrawing)
                Button("Save", action: saveDrawing)
            }
        }
        .alert(confirmationMessage, isPresented: $showConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: - View Components

    private var canvas: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
            }
        }
    }

    private var controlPanel: some View {
        VStack(spacing: 15) {
            // Color Palette
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(availableColors, id: \.self) { color in
                        colorCircle(color: color)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 50)

            // Brush Size Slider
            HStack {
                Image(systemName: "paintbrush.pointed")
                Slider(value: $selectedLineWidth, in: 1...30) {
                    Text("Line Width")
                }
                Text("\(Int(selectedLineWidth))")
            }
            .padding(.horizontal)

        }
        .padding(.vertical)
        .background(.thinMaterial)
    }

    private func colorCircle(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 35, height: 35)
            .overlay(
                Circle()
                    .stroke(selectedColor == color ? Color.accentColor : Color.clear, lineWidth: 3)
            )
            .onTapGesture {
                selectedColor = color
            }
    }

    // MARK: - Gestures and Actions

    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let newPoint = value.location
                if value.translation.width + value.translation.height == 0 {
                    // Start of a new line
                    lines.append(Line(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                } else {
                    // Continue the current line
                    let index = lines.count - 1
                    lines[index].points.append(newPoint)
                }
            }
    }

    private func undoLastLine() {
        _ = lines.popLast()
    }

    private func clearDrawing() {
        lines.removeAll()
    }

    @MainActor
    private func saveDrawing() {
        // Define the view to be rendered for saving
        let viewToRender = canvas
            .frame(width: canvasRect.width, height: canvasRect.height)
            .background(Color.white)

        let renderer = ImageRenderer(content: viewToRender)
        renderer.scale = UIScreen.main.scale // Use screen scale for high resolution

        if let image = renderer.uiImage {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: image)
            imageSaver.onSuccess = {
                confirmationMessage = "Your artwork has been saved to your Photos."
                showConfirmation = true
            }
            imageSaver.onError = { error in
                confirmationMessage = "Oops! Could not save image. Please ensure you have granted photo library access in Settings. \(error.localizedDescription)"
                showConfirmation = true
            }
        } else {
            confirmationMessage = "Failed to create an image of your drawing."
            showConfirmation = true
        }
    }
}

// PreferenceKey to get the size of the canvas
struct CanvasRectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// Helper class to save an image to the photo library and handle callbacks.
class ImageSaver: NSObject {
    var onSuccess: (() -> Void)?
    var onError: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            onError?(error)
        } else {
            onSuccess?()
        }
    }
}

#Preview {
    NavigationView {
        ArtAndCraftView()
    }
}