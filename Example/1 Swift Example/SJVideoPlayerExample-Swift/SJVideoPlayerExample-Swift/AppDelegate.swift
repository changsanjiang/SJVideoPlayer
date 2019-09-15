//
//  AppDelegate.swift
//  SJVideoPlayerExample-Swift
//
//  Created by BlueDancer on 2019/9/15.
//  Copyright © 2019 SanJiang. All rights reserved.
//

import UIKit
import SJVideoPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        SJVideoPlayer.update { (settings) in
            settings.progress_thumbSize = 12;
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    var player: SJVideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = SJVideoPlayer()
        containerView.addSubview(player.view)
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        player.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        player.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        player.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        // Do any additional setup after loading the view.
    }
}

