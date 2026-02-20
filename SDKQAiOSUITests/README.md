# Tests UI + Eventos SDK

## Estructura

- `SDKEventSpy.swift` – Helper para capturar eventos del SDK (`ready`, `play`, `pause`, `seek`, `currentTimeUpdate`, etc.).
- `VideoLiveDvrUITests.swift` – Test de UI para Video Live DVR con asserts de eventos.
- (Próximamente) `AudioLiveUITests.swift`, `VideoVODUITests.swift`, etc.

## Cómo integrar el spy en la app

Para que los tests lean eventos del SDK, la app debe:

1. **Exponer un `EventManager`** global o un punto de acceso.
2. **Tener un botón/trigger oculto** para tests (`test.attachSpy`) que adjunte el spy y opcionalmente muestre eventos en una label (`test.spyEvents`).

Ejemplo en la app:

```swift
// En algún ViewController accesible
@objc private func attachSpyForTests() {
    let spy = SDKEventSpy()
    spy.attach(to: MediastreamPlatformSDK.shared.events)
    // Opcional: mostrar eventos en una label para que XCUITest los lea
    eventSpyLabel.text = spy.events.joined(separator: ",")
}
```

## Flujo del test

1. Lanza la app.
2. Toca el caso de prueba (Live DVR).
3. Adjunta el spy (`test.attachSpy`).
4. Realiza interacciones (play/pause/seek).
5. Valida:
   - UI: elementos visibles y labels de estado.
   - SDK: eventos ocurrieron (`ready`, `play`, `pause`, `seek` opcional).

## Extender a más casos

- Copia `VideoLiveDvrUITests.swift` y ajusta:
  - Celda de la tabla (`testCase.videoVod`, `testCase.audioLive`, etc.).
  - Controles específicos (segmented, botones, sliders).
  - Eventos esperados (ej. sin `seek` si no hay timeline).

## Notas

- Los asserts de eventos son más estables que solo UI.
- Si un evento desaparece, el test fallará aunque la UI parezca bien.
- El spy se puede resetear entre tests con `spy.reset()`.
