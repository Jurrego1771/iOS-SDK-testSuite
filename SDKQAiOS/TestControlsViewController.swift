//
//  TestControlsViewController.swift
//  SDKQAiOS
//
//  Controles ocultos para tests UI (botón para adjuntar spy, etc.).
//

import UIKit

/// Controles ocultos para tests UI (botón para adjuntar spy, reset, etc.).
class TestControlsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHiddenControls()
    }

    private func setupHiddenControls() {
        // Botón para adjuntar el spy (oculto, accesible por accessibilityIdentifier)
        let attachSpyButton = UIButton(type: .system)
        attachSpyButton.setTitle("Attach Spy", for: .normal)
        attachSpyButton.accessibilityIdentifier = "test.attachSpy"
        attachSpyButton.addTarget(self, action: #selector(attachSpyTapped), for: .touchUpInside)
        attachSpyButton.isHidden = true
        attachSpyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(attachSpyButton)

        NSLayoutConstraint.activate([
            attachSpyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            attachSpyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        ])

        // Botón para resetear el spy (oculto)
        let resetSpyButton = UIButton(type: .system)
        resetSpyButton.setTitle("Reset Spy", for: .normal)
        resetSpyButton.accessibilityIdentifier = "test.resetSpy"
        resetSpyButton.addTarget(self, action: #selector(resetSpyTapped), for: .touchUpInside)
        resetSpyButton.isHidden = true
        resetSpyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetSpyButton)

        NSLayoutConstraint.activate([
            resetSpyButton.topAnchor.constraint(equalTo: attachSpyButton.bottomAnchor, constant: 8),
            resetSpyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        ])
    }

    @objc private func attachSpyTapped() {
        // Intentar obtener el EventManager del SDK actual.
        // Nota: Necesitamos acceso al SDK. Si cada pantalla expone su sdk, podemos usar el último activo.
        // Por ahora, asumimos que hay un singleton o global.
        if let events = getCurrentSDKEvents() {
            TestEventSpyBridge.shared.attachSpy(to: events)
        } else {
            print("TestEventSpyBridge: no se encontró EventManager del SDK.")
        }
    }

    @objc private func resetSpyTapped() {
        TestEventSpyBridge.shared.resetSpy()
    }

    // MARK: - Helper para obtener EventManager del SDK

    /// Intenta obtener el EventManager del SDK activo.
    /// Busca en el ViewController visible y en los conocidos que exponen sdk.
    private func getCurrentSDKEvents() -> EventManager? {
        // Buscar el ViewController visible que tenga un sdk expuesto
        if let nav = UIApplication.shared.windows.first?.rootViewController as? UINavigationController,
           let topVC = nav.topViewController {
            // Intentar con las clases conocidas que tienen sdk: MediastreamPlatformSDK
            if let vc = topVC as? VideoLiveDvrViewController {
                return vc.sdk?.events
            }
            if let vc = topVC as? VideoVodSimpleViewController {
                return vc.sdk?.events
            }
            if let vc = topVC as? AudioLiveViewController {
                return vc.sdk?.events
            }
            // Agregar más casos según sea necesario...
        }
        return nil
    }
}
