//
//  TabBarViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 11/3/21.
//

import UIKit

class AnimatedTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.image)
//        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1, let imageView = tabBar.subviews[idx + 1].subviews.first as? UIImageView else {
//            return
//        }

//        imageView.layer.add(bounceAnimation, forKey: nil)
        item.image!.add(bounceAnimation, forKey: nil)
    }
}
