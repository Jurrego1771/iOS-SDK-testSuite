//
//  TestEventSpyBridge.swift
//  SDKQAiOS
//
//  Puente para exponer SDKEventSpy a tests UI vía botón oculto y label.
//

import UIKit

/// Puente para que los tests UI adjunten un spy al SDK y lean eventos.
class TestEventSpyBridge {

    static let shared = TestEventSpyBridge()

    private var spy: SDKEventSpy?

    private init() {}

    /// Adjunta un spy al EventManager del SDK y lo expone.
    /// - Parameter events: EventManager del SDK (ej. MediastreamPlatformSDK.shared.events)
    func attachSpy(to events: EventManager) {
        spy = SDKEventSpy()
        spy?.attach(to: events)
        updateSpyLabel()
    }

    /// Reinicia el spy (útil entre tests).
    func resetSpy() {
        spy?.reset()
        updateSpyLabel()
    }

    /// Devuelve los eventos acumulados como string (para asserts en tests).
    var eventsString: String {
        return spy?.events.joined(separator: ",") ?? ""
    }

    /// Devuelve el último currentTime conocido.
    var lastCurrentTime: Double {
        return spy?.lastCurrentTime ?? 0
    }

    /// Devuelve la última duración conocida.
    var lastDuration: Double {
        return spy?.lastDuration ?? 0
    }

    /// Devuelve el último error (si lo hay).
    var lastError: String? {
        return spy?.lastError
    }

    // MARK: - UI helpers (usados por tests)

    /// Actualiza una label oculta con los eventos para que XCUITest los lea.
    private func updateSpyLabel() {
        DispatchQueue.main.async {
            if let label = self.spyLabel {
                label.text = self.eventsString
                label.accessibilityIdentifier = "test.spyEvents"
            }
        }
    }

    /// Label oculta para exponer eventos a tests UI.
    private var spyLabel: UILabel? {
        // Buscar en la ventana principal una label con identifier específico
        return UIApplication.shared.windows.first?.viewWithTag(9999) as? UILabel
    }

    /// Crea y añade la label oculta a la ventana principal (llamar al arrancar la app).
    func setupHiddenSpyLabel() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first,
                  window.viewWithTag(9999) == nil else { return }

            let label = UILabel()
            label.tag = 9999
            label.accessibilityIdentifier = "test.spyEvents"
            label.isHidden = true // No visible para el usuario
            window.addSubview(label)
        }
    }
}
