import CoreAnimationUtils
import XCTest
import simd

@testable import CoreAnimationUtils

final class CoreAnimationUtilsTests: XCTestCase {

  func testTranslation() {
    let testTransformCA = CATransform3DMakeTranslation(2.0, 3.0, 4.0)

    XCTAssertEqual(testTransformCA.translation.x, 2.0);
    XCTAssertEqual(testTransformCA.translation.y, 3.0);
    XCTAssertEqual(testTransformCA.translation.z, 4.0);

    var testTransform2 = CATransform3DIdentity
    testTransform2.translation.x = 2.0
    testTransform2.translation.y = 3.0
    testTransform2.translation.z = 4.0

    XCTAssertEqual(testTransform2, testTransformCA);

    let testTransform3 = CATransform3DIdentity.translated(by: Vector3(x: 2.0, y: 3.0, z: 4.0))

    XCTAssertEqual(testTransform3, testTransformCA)
  }

  func testScale() {
    let testTransformCA = CATransform3DMakeScale(2.0, 3.0, 4.0)

    XCTAssertEqual(testTransformCA.scale.x, 2.0);
    XCTAssertEqual(testTransformCA.scale.y, 3.0);
    XCTAssertEqual(testTransformCA.scale.z, 4.0);

    var testTransform2 = CATransform3DIdentity
    testTransform2.scale.x = 2.0
    testTransform2.scale.y = 3.0
    testTransform2.scale.z = 4.0

    XCTAssertEqual(testTransform2, testTransformCA);

    let testTransform3 = CATransform3DIdentity.scaled(by: Vector3(x: 2.0, y: 3.0, z: 4.0))
    XCTAssertEqual(testTransform3, testTransformCA)
  }

  func testRotation() {
    let testRotateXCA = CATransform3DMakeRotation(.pi / 4, 1.0, 0.0, 0.0)
    let testRotateYCA = CATransform3DMakeRotation(.pi / 4, 0.0, 1.0, 0.0)
    let testRotateZCA = CATransform3DMakeRotation(.pi / 4, 0.0, 0.0, 1.0)

    var testTransformX = CATransform3DIdentity
    testTransformX.rotation = Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(1.0, 0.0, 0.0))))

    var testTransformY = CATransform3DIdentity
    testTransformY.rotation = Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(0.0, 1.0, 0.0))))

    var testTransformZ = CATransform3DIdentity
    testTransformZ.rotation = Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(0.0, 0.0, 1.0))))

    XCTAssertEqual(testTransformX, testRotateXCA)
    XCTAssertEqual(testTransformY, testRotateYCA)
    XCTAssertEqual(testTransformZ, testRotateZCA)

    let testTransformXYCA = CATransform3DMakeRotation(.pi / 4.0, 1.0, 1.0, 0.0)
    let testTransformXY = CATransform3DIdentity.rotated(by: Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(x: 1.0, y: 1.0, z: 0.0)))))

    XCTAssertEqual(testTransformXY, testTransformXYCA)
  }

  func testSkew() {
    // CA doesn't really provide any default Skew manipulations so, just make sure that the skew works as intended.
    let transform1 = CATransform3DIdentity.skewedBy(XY: 0.25, XZ: 0.25, YZ: 0.25)
    XCTAssertEqual(transform1.m21, 0.25, accuracy: CGFloat(SupportedAccuracy))
    XCTAssertEqual(transform1.m31, 0.25, accuracy: CGFloat(SupportedAccuracy))
    XCTAssertEqual(transform1.m32, 0.25, accuracy: CGFloat(SupportedAccuracy))
  }

  func testDecompose() {
    let translationTransform = CATransform3DMakeTranslation(1.0, 2.0, 3.0)
    let decomposedTranslationTransform = translationTransform.decomposed()
    XCTAssertEqual(decomposedTranslationTransform.translation, Vector3(1.0, 2.0, 3.0))

    let scaleTransform = CATransform3DMakeScale(1.0, 2.0, 3.0)
    let decomposedScaleTransform = scaleTransform.decomposed()
    XCTAssertEqual(decomposedScaleTransform.scale, Scale(1.0, 2.0, 3.0))

    let rotationTransformQuaternion = CATransform3DMakeRotation(.pi / 4.0, 1.0, 1.0, 1.0)
    let decomposedRotationTransformQuaternion = rotationTransformQuaternion.decomposed()
    XCTAssertEqual(decomposedRotationTransformQuaternion.rotation, Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(1.0, 1.0, 1.0)))))

    var combinedTransform = CATransform3DMakeTranslation(1.0, 2.0, 3.0)
    combinedTransform = CATransform3DScale(combinedTransform, 2.0, 2.0, 2.0)
    combinedTransform = CATransform3DRotate(combinedTransform, .pi, 1.0, 0.0, 0.0)

    let decomposedCombinedTransform = combinedTransform.decomposed()
    XCTAssertEqual(decomposedCombinedTransform.translation, Vector3(1.0, 2.0, 3.0))
    XCTAssertEqual(decomposedCombinedTransform.scale, Vector3(2.0, 2.0, 2.0))
    XCTAssertEqual(decomposedCombinedTransform.rotation, Quaternion(angle: .pi, axis: Vector3(x: 1.0, y: 0.0, z: 0.0)))
  }

  func testRecompose() {
    var startTransform = CATransform3DMakeRotation(.pi / 4.0, 1.0, 0.0, 0.0)
    startTransform = CATransform3DScale(startTransform, 2.0, 2.0, 2.0)
    startTransform = CATransform3DTranslate(startTransform, 2.0, 2.0, 2.0)

    let decomposedThenRecomposedTransform = startTransform.decomposed().recomposed()
    XCTAssertEqual(startTransform, decomposedThenRecomposedTransform)

    let rotationTransform = CATransform3DMakeRotation(.pi / 4.0, 1.0, 0.0, 0.0)

    let m = CATransform3DIdentity
    var decomposed = m.decomposed()
    decomposed.rotation = Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(1.0, 0.0, 0.0))))
    let recomposedRotationTransform = decomposed.recomposed()

    XCTAssertEqual(rotationTransform, recomposedRotationTransform)

    var m2 = CATransform3DIdentity
    m2.rotation = Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(1.0, 0.0, 0.0))))
    XCTAssertEqual(rotationTransform, m2)
  }

  func testComposition() {
    var transform = CATransform3DIdentity
    transform = CATransform3DTranslate(transform, 2.0, 4.0, 6.0)
    transform = CATransform3DScale(transform, 1.0, 2.0, 3.0)
    transform = CATransform3DRotate(transform, .pi / 4.0, 1.0, 0.0, 0.0)

    let transform2 = CATransform3DIdentity
      .translated(by: Vector3(x: 2.0, y: 4.0, z: 6.0))
      .scaled(by: Vector3(x: 1.0, y: 2.0, z: 3.0))
      .rotated(by: Quaternion(angle: .pi / 4.0, axis: Vector3(normalize(simd_double3(1.0, 0.0, 0.0)))))

    XCTAssertEqual(transform, transform2)
  }

  func testLERP() {
    let a = simd_double4(1.0, 10.0, 100.0, 1000.0)
    let b = a * 2.0

    XCTAssertEqual(a.lerp(to: b, fraction: 0.0), a)
    XCTAssertEqual(a.lerp(to: b, fraction: 0.5), simd_double4(1.5, 15.0, 150.0, 1500.0))
    XCTAssertEqual(a.lerp(to: b, fraction: 1.0), b)

    // TODO: Enable these when I figure out what's wrong.
    let c = simd_quatd(angle: 0.0, axis: simd_double3(0.0, 0.0, 0.0))
    let d = simd_quatd(angle: .pi / 4.0, axis: simd_double3(0.0, 1.0, 0.0))

    XCTAssertEqual(c.lerp(to: d, fraction: 0.0), c)
    XCTAssertEqual(c.lerp(to: d, fraction: 0.5), simd_quatd(angle: d.angle * 0.5, axis: d.axis))
    XCTAssertEqual(c.lerp(to: d, fraction: 1.0), d)
  }

  static var allTests = [
    ("testTranslation", testTranslation),
    ("testScale", testScale),
    ("testRotation", testRotation),
    ("testSkew", testSkew),
    ("testDecompose", testDecompose),
    ("testRecompose", testRecompose),
    ("testComposition", testComposition),
    ("testLERP", testLERP),
  ]

}

// Equality with Accuracy Checks

internal func XCTAssertEqual(_ lhs: simd_double3, _ rhs: simd_double3, accuracy: Double = SupportedAccuracy) {
  XCTAssertEqual(lhs[0], rhs[0], accuracy: accuracy)
  XCTAssertEqual(lhs[1], rhs[1], accuracy: accuracy)
  XCTAssertEqual(lhs[2], rhs[2], accuracy: accuracy)
}

internal func XCTAssertEqual(_ lhs: simd_double4, _ rhs: simd_double4, accuracy: Double = SupportedAccuracy) {
  XCTAssertEqual(lhs[0], rhs[0], accuracy: accuracy)
  XCTAssertEqual(lhs[1], rhs[1], accuracy: accuracy)
  XCTAssertEqual(lhs[2], rhs[2], accuracy: accuracy)
  XCTAssertEqual(lhs[3], rhs[3], accuracy: accuracy)
}

internal func XCTAssertEqual(_ lhs: simd_quatd, _ rhs: simd_quatd, accuracy: Double = SupportedAccuracy) {
  XCTAssertEqual(lhs.vector, rhs.vector, accuracy: accuracy)
}

internal func XCTAssertEqual(_ lhs: CATransform3D, _ rhs: CATransform3D, accuracy: CGFloat = CGFloat(SupportedAccuracy)) {
  XCTAssertEqual(lhs.m11, rhs.m11, accuracy: accuracy)
  XCTAssertEqual(lhs.m12, rhs.m12, accuracy: accuracy)
  XCTAssertEqual(lhs.m13, rhs.m13, accuracy: accuracy)
  XCTAssertEqual(lhs.m14, rhs.m14, accuracy: accuracy)

  XCTAssertEqual(lhs.m21, rhs.m21, accuracy: accuracy)
  XCTAssertEqual(lhs.m22, rhs.m22, accuracy: accuracy)
  XCTAssertEqual(lhs.m23, rhs.m23, accuracy: accuracy)
  XCTAssertEqual(lhs.m24, rhs.m24, accuracy: accuracy)

  XCTAssertEqual(lhs.m31, rhs.m31, accuracy: accuracy)
  XCTAssertEqual(lhs.m32, rhs.m32, accuracy: accuracy)
  XCTAssertEqual(lhs.m33, rhs.m33, accuracy: accuracy)
  XCTAssertEqual(lhs.m34, rhs.m34, accuracy: accuracy)

  XCTAssertEqual(lhs.m41, rhs.m41, accuracy: accuracy)
  XCTAssertEqual(lhs.m42, rhs.m42, accuracy: accuracy)
  XCTAssertEqual(lhs.m43, rhs.m43, accuracy: accuracy)
  XCTAssertEqual(lhs.m44, rhs.m44, accuracy: accuracy)
}
