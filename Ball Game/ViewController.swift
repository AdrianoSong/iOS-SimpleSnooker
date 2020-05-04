//
//  ViewController.swift
//  Ball Game
//
//  Created by Song on 15/04/20.
//  Copyright © 2020 Adriano Song. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

/**
 Reference1: https://www.youtube.com/watch?v=8l3J9lwaecY&t=1178s
 Reference2: https://www.youtube.com/watch?v=xXX2s-cWJNw
 */
class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!

    var stickModel: ModelEntity?

    fileprivate let usageLabel: UILabel = {
        let view = UILabel()
        view.text = "Ache uma superficie plana (ex: uma mesa) e espera a cena ser criada"
        view.numberOfLines = 0
        view.textColor = .systemBlue
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 32)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupArViewConfig()

        setupUsageLabel()

        addPoolToTheScene()
    }

    fileprivate func setupArViewConfig() {
        arView.session.delegate = self
        arView.automaticallyConfigureSession = false
        arView.addCoaching(plane: .horizontalPlane)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)

        arView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(didTapArView(recognizer:))))
    }

    fileprivate func setupUsageLabel() {
        view.addSubview(usageLabel)

        usageLabel.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        usageLabel.leadingAnchor.constraint(
            equalTo: view.leadingAnchor, constant: 20).isActive = true
        usageLabel.trailingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: -20).isActive = true
    }

    @objc
    fileprivate func didTapArView(recognizer: UITapGestureRecognizer) {

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.usageLabel.alpha = 0
        })

//        addTreeToTheScene()
    }

    fileprivate func addPoolToTheScene() {
        guard let poolAnchor = try? Sinuca.loadPoolScene() else {
            print("fail to load Sinuca")
            return
        }
        
        arView.scene.addAnchor(poolAnchor)
    }

    fileprivate func addTreeToTheScene() {
        guard let treeAnchor = try? ArvoreV3.loadArvore() else {
            print("fail to load Arvore")
            return
        }

        //custom notification made on reality composer
        treeAnchor.actions.startTalkNotification.onAction = { [weak self] _ in

            self?.startTreeTalking()
        }

        arView.scene.addAnchor(treeAnchor)
    }

    fileprivate func startTreeTalking() {
        let speechSynthesizer = AVSpeechSynthesizer()
        //Create an instance of AVSpeechUtterance and pass in a String to be spoken.
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "Olá mineiro, se esqueceu de mim? Aqui quem fala é a sua Árvore. Beijo na bunda, tchau tchau")
        //Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.5
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        speechSynthesizer.speak(speechUtterance)
    }
}

extension ViewController: ARSessionDelegate {

}

extension ARView: ARCoachingOverlayViewDelegate {
    ///CouchView to your scene
    func addCoaching(plane: ARCoachingOverlayView.Goal) {

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.frame = CGRect(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2,
            width: coachingOverlay.frame.width,
            height: coachingOverlay.frame.height)

        coachingOverlay.goal = plane

        self.addSubview(coachingOverlay)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //Ready to add entities next?
    }
}
