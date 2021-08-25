//
//  LaunchScreenViewController.swift
//  LaunchScreenViewController
//
//  Created by Benjamin Nakiwala on 8/25/21.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    let colors = [UIColor(red: 244, green: 26, blue: 35, alpha: 1.0).cgColor, UIColor(red: 181, green: 9, blue: 18, alpha: 1).cgColor]
    let gradient = CAGradientLayer()
    let startPoint = CGPoint(x: 0, y: 0)
    let stopPoint = CGPoint(x: 1, y: 1)
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // View Setup
        imageView.layer.cornerRadius = 5
        imageView.layer.shadowRadius = 3
        imageView.layer.shadowOpacity = 1
        gradient.colors = colors
        gradient.bounds = view.bounds
        gradient.startPoint = startPoint
        gradient.endPoint = stopPoint
        view.layer.addSublayer(gradient)
        // AnimationSetup
        let anim = CASpringAnimation(keyPath: "colors")
        anim.mass = 3
        anim.initialVelocity = 1
        anim.stiffness = 90
        anim.fromValue = colors
        anim.toValue = colors.reversed
        anim.duration = 1
        anim.autoreverses = true
        anim.repeatDuration = 10
        gradient.add(anim, forKey: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        // image animation group
        let animGroup = CAAnimationGroup()
        // scale animation
        let scaleAnim = CABasicAnimation(keyPath: "transform")
        scaleAnim.fromValue = CGAffineTransform.identity
        scaleAnim.toValue = CGAffineTransform(scaleX: 10, y: 10)
        scaleAnim.duration = 0.5
        // opacity animation
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = 0
        opacityAnim.duration = 0.5
        // combining them
        animGroup.animations = [scaleAnim, opacityAnim]
        animGroup.duration = 0.5
        imageView.layer.add(animGroup, forKey: nil)
        super.viewWillDisappear(animated)
    }
}
