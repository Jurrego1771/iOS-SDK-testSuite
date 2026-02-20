//
//  AudioAodWithServiceViewController.swift
//  SDKQAiOS
//
//  Audio AOD con “servicio” en iOS = mismo contenido que AOD Simple pero con
//  Now Playing (Control Center / pantalla de bloqueo) para reproducir en segundo plano
//  y controlar desde la notificación. Equivalente funcional a Android “AOD with Service”.
//

import UIKit
import MediastreamPlatformSDKiOS

class AudioAodWithServiceViewController: UIViewController {

    private var sdk: MediastreamPlatformSDK?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio: AOD with Service"
        view.backgroundColor = .black

        let playerConfig = MediastreamPlayerConfig()
        playerConfig.id = "696c625d32ce0ef08ca5ef9d"
        playerConfig.type = .VOD
        playerConfig.videoFormat = .MP3
        playerConfig.debug = true
        playerConfig.customUI = true
        // Now Playing = Control Center / Lock Screen (equivalente a “servicio”/notificación en Android)
        playerConfig.updatesNowPlayingInfoCenter = true
        // Descomentar para entorno de desarrollo:
        // playerConfig.environment = .DEV

        let mdstrm = MediastreamPlatformSDK()
        addChild(mdstrm)
        view.addSubview(mdstrm.view)
        mdstrm.didMove(toParent: self)

        mdstrm.setup(playerConfig)
        SDKEventListeners.attachAll(to: mdstrm)
        mdstrm.play()
        sdk = mdstrm
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sdk?.view.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sdk?.releasePlayer()
    }

    deinit {
        sdk?.releasePlayer()
    }
}
