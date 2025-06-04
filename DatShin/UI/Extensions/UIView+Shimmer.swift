//
//  UIView+Shimmer.swift
//  DatShin
//
//  Created by Cascade on [Current Date].
//

import UIKit

extension UIView {

    private enum AssociatedKeys {
        static var shimmerGradientLayer = "shimmerGradientLayer"
    }

    private var shimmerGradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shimmerGradientLayer) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shimmerGradientLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func startShimmering(animationSpeed: Float = 1.5, 
                         gradientColorOne: UIColor = UIColor(white: 0.85, alpha: 1.0),
                         gradientColorTwo: UIColor = UIColor(white: 0.95, alpha: 1.0)) {
        // Ensure we don't add multiple shimmer layers
        stopShimmering()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [
            gradientColorOne.cgColor,
            gradientColorTwo.cgColor,
            gradientColorOne.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0] // Color stops

        // Add a mask to make the shimmer only appear on non-transparent parts of the view
        // This is more effective if the view itself has a complex shape or clear background.
        // For simple rectangular skeleton views, this might be overkill but good practice.
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.white.cgColor // Content of mask determines what's visible
        maskLayer.frame = self.bounds
        maskLayer.cornerRadius = self.layer.cornerRadius // Match corner radius
        gradientLayer.mask = maskLayer

        self.layer.addSublayer(gradientLayer)
        self.shimmerGradientLayer = gradientLayer

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = CFTimeInterval(animationSpeed)
        animation.fromValue = -self.bounds.width
        animation.toValue = self.bounds.width
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false // Keep animation state

        gradientLayer.add(animation, forKey: "shimmerAnimation")
        
        // Ensure the layer resizes with the view if using Auto Layout
        // A more robust way is to update layer frames in layoutSubviews() of the view itself.
        // For now, this assumes initial frame is correct.
        // Consider adding a way to update the shimmer layer's frame if the view's bounds change.
    }

    func stopShimmering() {
        self.shimmerGradientLayer?.removeAllAnimations()
        self.shimmerGradientLayer?.removeFromSuperlayer()
        self.shimmerGradientLayer = nil
    }
    
    // Call this if the view's layout changes to update the shimmer frame
    func updateShimmerFrame() {
        shimmerGradientLayer?.frame = self.bounds
        shimmerGradientLayer?.mask?.frame = self.bounds
    }
}
