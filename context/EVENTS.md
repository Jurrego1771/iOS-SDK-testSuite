# MediastreamPlatformSDKiOS — Eventos

Documentación de todos los **eventos** que el SDK dispara. Tu app puede suscribirse a ellos con `mdstrm.events.listenTo(eventName:action:)` para reaccionar al estado del reproductor, anuncios, fullscreen, errores, etc.

---

## Índice

1. [Cómo suscribirse a eventos](#cómo-suscribirse-a-eventos)
2. [Lista completa de eventos por categoría](#lista-completa-de-eventos-por-categoría)
3. [Referencia rápida (tabla única)](#referencia-rápida-tabla-única)
4. [Ejemplos por caso de uso](#ejemplos-por-caso-de-uso)

---

## Cómo suscribirse a eventos

El SDK expone un `EventManager` en `mdstrm.events`. Debes suscribirte **después** de crear el reproductor y **antes** (o justo después) de llamar a `setup(config)`.

### Sin información

```swift
mdstrm.events.listenTo(eventName: "ready", action: {
    print("Reproductor listo para reproducir")
})
```

### Con información (el evento envía datos)

```swift
mdstrm.events.listenTo(eventName: "error", action: { (information: Any?) in
    if let message = information as? String {
        print("Error: \(message)")
    }
})

mdstrm.events.listenTo(eventName: "seek", action: { (information: Any?) in
    if let dict = information as? [String: Int64], let from = dict["from"] {
        print("Seek desde posición: \(from)")
    }
})
```

### Quitar listeners

```swift
// Solo de un evento
mdstrm.events.removeListeners(eventNameToRemoveOrNil: "play")

// Todos los listeners
mdstrm.events.removeListeners(eventNameToRemoveOrNil: nil)
```

> **Nota:** Al llamar a `releasePlayer()`, el SDK elimina todos los listeners automáticamente.

---

## Lista completa de eventos por categoría

---

### Reproducción

Eventos del ciclo de reproducción del contenido principal (vídeo/audio).

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`ready`** | — | El reproductor está listo para reproducir (recurso cargado, puede llamar a `play()`). |
| **`play`** | `nil` o `String`: `"seek"`, `"buffering"` | Reproducción iniciada o reanudada. Si viene `"seek"` o `"buffering"` indica el motivo. |
| **`pause`** | — | El usuario o el SDK pausó la reproducción. |
| **`finish`** | — | El contenido llegó al final. |
| **`seek`** | `[String: Int64]`: `["from": lastPosition]` | El usuario realizó un seek; `from` es la posición anterior en la unidad que use el SDK. |
| **`buffering`** | `Date` | El reproductor entró en buffering; la fecha indica el inicio. |
| **`durationUpdated`** | `String` | Se conoció la duración del contenido (ej. `"01:23:45"`). |
| **`currentTimeUpdate`** | `String` | Actualización del tiempo actual (ej. para actualizar un slider o label). |

---

### Errores y carga de fuentes

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`error`** | `String` (mensaje de error) | Error de reproducción, de la API de Mediastream o de configuración (ej. token inválido). |
| **`failedToPlayToEndTime`** | `String` (descripción) | El reproductor no pudo reproducir hasta el final (fallo de AVPlayer). |
| **`newsourceadded`** | — | Se cargó una nueva fuente de contenido **remota** (streaming). |
| **`localsourceadded`** | — | Se cargó una fuente **local** (archivo), típicamente tras `setup(config)` con `config.src` asignado. |

---

### Fullscreen

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`onFullscreen`** | — | El reproductor entró en modo fullscreen. |
| **`offFullscreen`** | — | El reproductor salió de fullscreen. |

---

### Conectividad

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`conectionStablished`** | — | Se detectó que la conexión de red está disponible. |
| **`conectionLost`** | — | Se perdió la conexión de red. |

---

### Anuncios (Google IMA — VAST/VMAP)

Eventos del flujo de anuncios clásico (pre/mid/post roll).

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`onAdsLoaderInitialize`** | datos del loader | El cargador de anuncios IMA se inicializó. |
| **`onAdLoadingError`** | `String` (mensaje) | Falló la carga de la configuración o del anuncio. |
| **`onAdEvent`** | tipo de evento IMA | Cualquier evento del reproductor de anuncios (loaded, start, complete, etc.). |
| **`onAdLoaded`** | — | Un anuncio se cargó correctamente. |
| **`onAdPlay`** | datos | El anuncio empezó a reproducirse. |
| **`onAdPause`** | — | El anuncio se pausó. |
| **`onAdResume`** | — | El anuncio se reanudó. |
| **`onAdEnded`** | — | El anuncio terminó. |
| **`onAdSkipped`** | — | El usuario saltó el anuncio (si está permitido). |
| **`onAdError`** | `String` (mensaje) | Error durante la reproducción del anuncio. |

---

### Anuncios DAI (Dynamic Ad Insertion)

Stream con anuncios insertados dinámicamente (Google IMA DAI).

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`onDAIAdEvent`** | tipo de evento IMA | Cualquier evento de un anuncio DAI (además se dispara `onAdEvent` con el mismo tipo). |

---

### Audio en vivo

Para streams de audio en vivo (radio, etc.) con metadatos de “canción actual”.

| Evento | Información | Cuándo se dispara |
|--------|-------------|-------------------|
| **`onLiveAudioCurrentSongChanged`** | `[String: Any]` o `[String: Any]()` | Cambió la canción/pista actual; el diccionario puede contener metadatos (nombre, artista, etc.) según lo que envíe el stream. |

---

## Referencia rápida (tabla única)

| Evento | Información | Categoría |
|--------|-------------|-----------|
| `ready` | — | Reproducción |
| `play` | `String?` (`"seek"`, `"buffering"`) | Reproducción |
| `pause` | — | Reproducción |
| `finish` | — | Reproducción |
| `seek` | `["from": Int64]` | Reproducción |
| `buffering` | `Date` | Reproducción |
| `durationUpdated` | `String` | Reproducción |
| `currentTimeUpdate` | `String` | Reproducción |
| `error` | `String` | Errores |
| `failedToPlayToEndTime` | `String` | Errores |
| `newsourceadded` | — | Fuentes |
| `localsourceadded` | — | Fuentes |
| `onFullscreen` | — | Fullscreen |
| `offFullscreen` | — | Fullscreen |
| `conectionStablished` | — | Conectividad |
| `conectionLost` | — | Conectividad |
| `onAdsLoaderInitialize` | datos | Anuncios |
| `onAdLoadingError` | `String` | Anuncios |
| `onAdEvent` | tipo IMA | Anuncios |
| `onAdLoaded` | — | Anuncios |
| `onAdPlay` | datos | Anuncios |
| `onAdPause` | — | Anuncios |
| `onAdResume` | — | Anuncios |
| `onAdEnded` | — | Anuncios |
| `onAdSkipped` | — | Anuncios |
| `onAdError` | `String` | Anuncios |
| `onDAIAdEvent` | tipo IMA | Anuncios DAI |
| `onLiveAudioCurrentSongChanged` | `[String: Any]` | Audio en vivo |

---

## Ejemplos por caso de uso

### Ocultar loader cuando esté listo

```swift
mdstrm.events.listenTo(eventName: "ready", action: {
    self.hideLoadingIndicator()
})
```

### Actualizar UI de play/pause

```swift
mdstrm.events.listenTo(eventName: "play", action: {
    self.playButton.setImage(UIImage(named: "pause"), for: .normal)
})
mdstrm.events.listenTo(eventName: "pause", action: {
    self.playButton.setImage(UIImage(named: "play"), for: .normal)
})
```

### Mostrar errores al usuario

```swift
mdstrm.events.listenTo(eventName: "error", action: { (information: Any?) in
    guard let message = information as? String else { return }
    self.showAlert(title: "Error", message: message)
})
```

### Ajustar layout al entrar/salir de fullscreen

```swift
mdstrm.events.listenTo(eventName: "onFullscreen", action: {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
})
mdstrm.events.listenTo(eventName: "offFullscreen", action: {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
})
```

### Mostrar estado de anuncio

```swift
mdstrm.events.listenTo(eventName: "onAdPlay", action: {
    self.statusLabel.text = "Reproduciendo anuncio"
})
mdstrm.events.listenTo(eventName: "onAdEnded", action: {
    self.statusLabel.text = ""
})
```

### Actualizar tiempo en pantalla

```swift
mdstrm.events.listenTo(eventName: "currentTimeUpdate", action: { (information: Any?) in
    if let timeString = information as? String {
        self.timeLabel.text = timeString
    }
})
mdstrm.events.listenTo(eventName: "durationUpdated", action: { (information: Any?) in
    if let durationString = information as? String {
        self.durationLabel.text = durationString
    }
})
```

### Canción actual en audio en vivo

```swift
mdstrm.events.listenTo(eventName: "onLiveAudioCurrentSongChanged", action: { (information: Any?) in
    if let data = information as? [String: Any],
       let title = data["title"] as? String {
        self.nowPlayingLabel.text = title
    }
})
```

---

*Documentación de eventos de MediastreamPlatformSDKiOS. Para métodos y propiedades, ver [API.md](API.md).*
