//
//  MainNavigationController.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 10/3/21.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    var musicPlayerWidget: MusicPlayerWidget!
    var fadeView: UIView!
    
    var bottomConstraintToMusicPlayer: NSLayoutConstraint!
    var heightAnchorToMusicPlayer: NSLayoutConstraint!
    
    var bottomConstraintToFadeView: NSLayoutConstraint!
    var heightAnchorToFadeView: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        bottomConstraintToMusicPlayer.constant = -self.view.safeAreaInsets.bottom
    }
}

//MARK: Initialization
extension MainNavigationController {
    func initialize() {
        self.isToolbarHidden = false
        
        musicPlayerWidget = MusicPlayerWidget(frame: self.toolbar.frame)
        musicPlayerWidget.stackView.axis = .horizontal
        
        fadeView = UIView(frame: self.toolbar.frame)
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        fadeView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.view.addSubview(fadeView)
        
        bottomConstraintToFadeView = fadeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        heightAnchorToFadeView = fadeView.heightAnchor.constraint(equalToConstant: self.toolbar.frame.height)
        
        NSLayoutConstraint.activate([
            fadeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            fadeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            fadeView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            bottomConstraintToFadeView,
            heightAnchorToFadeView
            ])
        
        fadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fadeView_didTap)))
        
        musicPlayerWidget.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(musicPlayerWidget)
        
        bottomConstraintToMusicPlayer = musicPlayerWidget.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        heightAnchorToMusicPlayer = musicPlayerWidget.heightAnchor.constraint(equalToConstant: self.toolbar.frame.height)
        
        NSLayoutConstraint.activate([
            musicPlayerWidget.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            musicPlayerWidget.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            musicPlayerWidget.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            heightAnchorToMusicPlayer,
            bottomConstraintToMusicPlayer
            ])
        
        musicPlayerWidget.labelContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(musicPlayerWidget_didTap)))
    }
    
    @objc func musicPlayerWidget_didTap() {
        showMusicPlayer()
    }
    
    @objc func fadeView_didTap() {
        UIView.animate(withDuration: 0.4) {
            self.heightAnchorToFadeView.constant = self.toolbar.frame.height
            self.heightAnchorToMusicPlayer.constant = self.toolbar.frame.height
            self.musicPlayerWidget.sliderContainer.isHidden = true
            self.musicPlayerWidget.stackView.axis = .horizontal
        }
    }
    
    func showMusicPlayer() {
        UIView.animate(withDuration: 0.4) {
            self.heightAnchorToFadeView.constant = self.view.frame.height
            self.heightAnchorToMusicPlayer.constant = 4*self.view.frame.height/5
            self.musicPlayerWidget.sliderContainer.isHidden = false
            self.musicPlayerWidget.stackView.axis = .vertical
        }
    }
}
