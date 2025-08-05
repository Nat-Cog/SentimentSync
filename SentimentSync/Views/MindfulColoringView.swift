import SwiftUI

/// Represents a single, colorable segment of the artwork.
struct ColoringSegment: Identifiable {
    let id = UUID()
    var path: Path
    var color: Color
}

struct MindfulColoringView: View {
    @State private var segments: [ColoringSegment] = []
    @State private var selectedColor: Color = .cyan
    @State private var canvasSize: CGSize = .zero

    private let colorPalette: [Color] = [
        .pink, .red, .orange, .yellow, .mint, .green,
        .cyan, .blue, .indigo, .purple, .brown, .white
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Tap a shape to color it")
                .font(.system(.headline, design: .rounded))
                .padding()

            // Use GeometryReader to get the available size for the canvas
            GeometryReader { geometry in
                Canvas { context, size in
                    // Draw each segment with its current color and a border
                    for segment in segments {
                        context.fill(segment.path, with: .color(segment.color))
                        context.stroke(segment.path, with: .color(.black.opacity(0.4)), lineWidth: 1.5)
                    }
                }
                .gesture(
                    // Use a DragGesture to detect tap locations
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            // Find which segment was tapped, searching from top to bottom
                            if let index = segments.lastIndex(where: { $0.path.contains(value.location) }) {
                                segments[index].color = selectedColor
                            }
                        }
                )
                .onAppear {
                    // Create the artwork when the view first appears
                    if segments.isEmpty {
                        self.canvasSize = geometry.size
                        segments = createMandala(size: geometry.size)
                    }
                }
            }
            .background(Color(.systemGray5))

            // Color selection palette
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(colorPalette, id: \.self) { color in
                        ColorSwatch(color: color, isSelected: color == selectedColor)
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                .padding()
            }
            .background(.thinMaterial)
        }
        .navigationTitle("Coloring")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    segments = createMandala(size: canvasSize)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color(.systemGray6))
    }

    /// Creates the mandala paths based on the available canvas size.
    private func createMandala(size: CGSize) -> [ColoringSegment] {
        var createdSegments: [ColoringSegment] = []
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2.2
        let initialColor = Color.white

        // Center circle
        var centerPath = Path()
        centerPath.addEllipse(in: CGRect(x: center.x - radius * 0.2, y: center.y - radius * 0.2, width: radius * 0.4, height: radius * 0.4))
        createdSegments.append(ColoringSegment(path: centerPath, color: initialColor))

        // Petals
        let petalStartRadius = radius * 0.2
        let petalEndRadius = radius * 0.65
        for i in 0..<8 {
            let angle = Angle(degrees: Double(i) * 45)
            var path = Path()
            path.move(to: center)
            let control1 = CGPoint(x: center.x + CGFloat(cos(angle.radians - 0.4)) * petalStartRadius, y: center.y + CGFloat(sin(angle.radians - 0.4)) * petalStartRadius)
            let tip = CGPoint(x: center.x + CGFloat(cos(angle.radians)) * petalEndRadius, y: center.y + CGFloat(sin(angle.radians)) * petalEndRadius)
            let control2 = CGPoint(x: center.x + CGFloat(cos(angle.radians + 0.4)) * petalStartRadius, y: center.y + CGFloat(sin(angle.radians + 0.4)) * petalStartRadius)
            path.addQuadCurve(to: tip, control: control1)
            path.addQuadCurve(to: center, control: control2)
            path.closeSubpath()
            createdSegments.append(ColoringSegment(path: path, color: initialColor))
        }

        // Outer ring segments
        let outerRadius = radius
        let innerRadius = radius * 0.7
        for i in 0..<16 {
            let startAngle = Angle(degrees: Double(i) * 22.5)
            let endAngle = Angle(degrees: Double(i + 1) * 22.5 - 1.5)
            var path = Path()
            path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
            path.closeSubpath()
            createdSegments.append(ColoringSegment(path: path, color: initialColor))
        }

        return createdSegments
    }
}

/// A view for a single color swatch in the palette.
struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 45, height: 45)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

            if isSelected {
                Circle()
                    .stroke(Color.primary.opacity(0.8), lineWidth: 3)
                    .frame(width: 50, height: 50)
            }
        }
        .padding(3)
    }
}

#Preview {
    NavigationView {
        MindfulColoringView()
    }
}
