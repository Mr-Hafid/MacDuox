import SwiftUI

struct FoldPreviewView: View {
    let parameters: FoldParameters
    let lidAngle: Double
    let clearAngle: Double

    private let stripCount = 56

    var body: some View {
        Canvas { context, size in
            drawFlatPanel(in: &context, size: size)
            drawFoldedPanel(in: &context, size: size)
            drawCrease(in: &context, size: size)
        }
        .background(.black)
    }

    private var geometry: FoldGeometry {
        FoldGeometry(
            foldAngleRadians: FoldGeometry.foldAngleRadians(lidAngle: lidAngle, clearAngle: clearAngle),
            perspective: parameters.perspective
        )
    }

    private func drawFlatPanel(in context: inout GraphicsContext, size: CGSize) {
        context.drawLayer { layer in
            layer.clip(to: Path(CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2)))
            DesktopScene.draw(in: &layer, size: size)
        }
    }

    private func drawFoldedPanel(in context: inout GraphicsContext, size: CGSize) {
        let fold = geometry
        let hinge = size.height / 2
        let stripHeight = hinge / CGFloat(stripCount)

        for index in 0..<stripCount {
            let destinationTop = CGFloat(index) * stripHeight
            let destinationBottom = destinationTop + stripHeight

            guard let sourceTop = sourceY(for: destinationTop, fold: fold, size: size),
                  let sourceBottom = sourceY(for: destinationBottom, fold: fold, size: size),
                  sourceBottom - sourceTop > 0.0001 else { continue }

            let normalizedDistance = (hinge - destinationTop) / size.height
            guard let sourceDistance = fold.sourceDistance(screenDistance: normalizedDistance) else { continue }
            let scale = fold.perspectiveScale(sourceDistance: sourceDistance)

            let destinationRect = CGRect(x: 0, y: destinationTop, width: size.width, height: stripHeight + 1)
            let blurRadius = parameters.variableBlur * sourceDistance * sin(fold.foldAngleRadians) * 26

            context.drawLayer { layer in
                layer.clip(to: Path(destinationRect))
                if blurRadius > 0.3 {
                    layer.addFilter(.blur(radius: blurRadius))
                }
                layer.translateBy(x: size.width / 2, y: destinationTop)
                layer.scaleBy(x: scale, y: stripHeight / (sourceBottom - sourceTop))
                layer.translateBy(x: -size.width / 2, y: -sourceTop)
                DesktopScene.draw(in: &layer, size: size)
            }
        }

        let shading = parameters.shadow * (1 - cos(fold.foldAngleRadians))
        context.fill(
            Path(CGRect(x: 0, y: 0, width: size.width, height: hinge)),
            with: .color(.black.opacity(shading))
        )
    }

    private func drawCrease(in context: inout GraphicsContext, size: CGSize) {
        let fold = geometry
        let intensity = parameters.shadow * sin(fold.foldAngleRadians)
        guard intensity > 0.001 else { return }

        let creaseHeight = size.height * 0.12
        let creaseRect = CGRect(x: 0, y: size.height / 2 - creaseHeight, width: size.width, height: creaseHeight)
        context.fill(
            Path(creaseRect),
            with: .linearGradient(
                Gradient(colors: [.black.opacity(0), .black.opacity(intensity * 0.7)]),
                startPoint: CGPoint(x: 0, y: creaseRect.minY),
                endPoint: CGPoint(x: 0, y: creaseRect.maxY)
            )
        )
    }

    private func sourceY(for destinationY: CGFloat, fold: FoldGeometry, size: CGSize) -> CGFloat? {
        let hinge = size.height / 2
        let normalizedDistance = (hinge - destinationY) / size.height
        guard normalizedDistance >= 0,
              let sourceDistance = fold.sourceDistance(screenDistance: normalizedDistance) else { return nil }
        return hinge - sourceDistance * size.height
    }
}

enum DesktopScene {
    static func draw(in context: inout GraphicsContext, size: CGSize) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [Color(red: 0.35, green: 0.41, blue: 0.50),
                                  Color(red: 0.62, green: 0.68, blue: 0.76)]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        context.fill(
            Path(ellipseIn: CGRect(x: size.width * 0.72, y: size.height * 0.14,
                                   width: size.width * 0.09, height: size.width * 0.09)),
            with: .color(.white.opacity(0.85))
        )

        drawRidge(in: &context, size: size, baseline: 0.60, amplitude: 0.10, opacity: 0.55)
        drawRidge(in: &context, size: size, baseline: 0.72, amplitude: 0.07, opacity: 0.75)
        drawRidge(in: &context, size: size, baseline: 0.84, amplitude: 0.05, opacity: 0.95)

        let clock = Text("9:41")
            .font(.system(size: size.height * 0.16, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
        context.draw(clock, at: CGPoint(x: size.width / 2, y: size.height * 0.22))

        let date = Text("Wednesday, September 9")
            .font(.system(size: size.height * 0.045, weight: .semibold))
            .foregroundStyle(.white.opacity(0.9))
        context.draw(date, at: CGPoint(x: size.width / 2, y: size.height * 0.10))
    }

    private static func drawRidge(in context: inout GraphicsContext,
                                  size: CGSize,
                                  baseline: CGFloat,
                                  amplitude: CGFloat,
                                  opacity: Double) {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height * baseline))

        let steps = 24
        for step in 0...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            let wave = sin(progress * .pi * 2 + baseline * 12) * amplitude
            path.addLine(to: CGPoint(x: size.width * progress,
                                     y: size.height * (baseline + wave)))
        }

        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()

        context.fill(path, with: .color(.white.opacity(opacity * 0.55)))
    }
}
