import simd

struct FoldParameters {
    var perspective: Double
    var variableBlur: Double
    var shadow: Double
    var tint: SIMD4<Float>
}

struct FoldUniforms {
    var foldAngle: Float
    var perspective: Float
    var blurStrength: Float
    var shadowStrength: Float
    var tint: SIMD4<Float>
    var texelSize: SIMD2<Float>
    var reserved: SIMD2<Float> = .zero

    init(parameters: FoldParameters, foldAngleRadians: Double, textureSize: SIMD2<Float>) {
        foldAngle = Float(foldAngleRadians)
        perspective = Float(parameters.perspective)
        blurStrength = Float(parameters.variableBlur)
        shadowStrength = Float(parameters.shadow)
        tint = parameters.tint
        texelSize = SIMD2(1 / max(textureSize.x, 1), 1 / max(textureSize.y, 1))
    }
}
