# Siguiente y anterior episodio

Documentación del uso de la funcionalidad **siguiente episodio** y **episodio anterior** en MediastreamPlatformSDKiOS. Permite reproducir el siguiente o el episodio previo de una serie (o lista) sin cambiar de pantalla, ya sea por botones, controles del sistema o de forma automática al terminar el contenido.

---

## Índice

1. [Requisitos](#requisitos)
2. [Configuración](#configuración)
3. [Respuesta del backend (prev/next)](#respuesta-del-backend-prevnext)
4. [Uso desde código](#uso-desde-código)
5. [Comportamiento automático](#comportamiento-automático)
6. [UI incluida en el SDK](#ui-incluida-en-el-sdk)
7. [Controles del sistema (Control Center / CarPlay)](#controles-del-sistema-control-center--carplay)
8. [Ejemplo completo](#ejemplo-completo)
9. [Referencias en el código](#referencias-en-el-código)

---

## Requisitos

- Tipo de contenido: **episodio** (`MediastreamPlayerConfig.VideoTypes.EPISODE`) o flujo donde el backend devuelva `prev` y/o `next` en el JSON de metadatos.
- La API de Mediastream debe incluir en la respuesta del recurso los campos opcionales `prev` y `next` con el **ID** del episodio anterior y siguiente (si existen).

---

## Configuración

Para que el SDK cargue y use los episodios siguiente y anterior, hay que activar la opción en la config:

```swift
let config = MediastreamPlayerConfig()
config.accountID = "tu-account-id"
config.id = "id-del-episodio-actual"
config.type = MediastreamPlayerConfig.VideoTypes.EPISODE
config.environment = MediastreamPlayerConfig.Environments.PRODUCTION

// Activar carga de prev/next
config.loadNextAutomatically = true

// Opcional: UI custom para mostrar botones siguiente/anterior
config.customUI = true

mdstrm.setup(config)
mdstrm.play()
```

| Propiedad | Descripción |
|-----------|-------------|
| `loadNextAutomatically` | Si es `true`, el SDK pide el JSON del contenido y, si vienen `prev`/`next`, rellena internamente `prevEpisodeConfig` y `nextEpisodeConfig` y habilita la lógica de siguiente/anterior (botones, autoplay y controles del sistema). |

---

## Respuesta del backend (prev/next)

El SDK obtiene los metadatos del contenido desde la API de Mediastream:

```
GET {environment}/{type}/{id}.json
```

Por ejemplo: `https://mdstrm.com/episode/5d4a071c37beb90719a41611.json`

La respuesta JSON debe poder incluir (además de `src`, `title`, etc.):

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `prev` | string (ID) | ID del episodio anterior. Si no existe, el SDK deshabilita “anterior”. |
| `next` | string (ID) | ID del episodio siguiente. Si no existe, el SDK deshabilita “siguiente” y no hará autoplay al terminar. |

Ejemplo de fragmento de respuesta:

```json
{
  "title": "Episodio 3",
  "src": { "hls": "...", "mp4": "..." },
  "prev": "5d4a071c37beb90719a41610",
  "next": "5d4a071c37beb90719a41612"
}
```

- Si `loadNextAutomatically == true` y el JSON tiene `prev` o `next`, el SDK crea `prevEpisodeConfig` y/o `nextEpisodeConfig` con ese ID y tipo `EPISODE`, mismo `environment` y opciones necesarias para llamar a `reloadPlayer` con ese episodio.

---

## Uso desde código

### Reproducir siguiente episodio

```swift
mdstrm.playNext()
```

- Si hay episodio siguiente (`nextEpisodeConfig != nil`), hace `reloadPlayer(nextEpisodeConfig)` y carga ese episodio.
- Si no hay siguiente, no hace nada.

### Reproducir episodio anterior

```swift
mdstrm.playPrev()
```

- Si hay episodio anterior (`prevEpisodeConfig != nil`), hace `reloadPlayer(prevEpisodeConfig)`.
- Si no hay anterior, no hace nada.

### Comprobar si hay siguiente o anterior

El SDK no expone getters públicos de `nextEpisodeConfig` / `prevEpisodeConfig`. En la práctica:

- Con **custom UI** (`customUI = true`), los botones siguiente/anterior se habilitan o deshabilitan según haya o no config (ver [UI incluida en el SDK](#ui-incluida-en-el-sdk)).
- Si implementas tu propia UI, puedes llamar `playNext()` / `playPrev()` y, si no hay episodio, la llamada no tendrá efecto.

---

## Comportamiento automático

### Autoplay al terminar el episodio

Cuando el contenido llega al final:

1. Se dispara el evento `finish`.
2. Si `config.loadNextAutomatically == true` y existe `nextEpisodeConfig`, el SDK llama automáticamente a `playNext()` y luego `play()`.
3. Si no hay siguiente pero `config.showReplayView == true`, se muestra la vista de “repetir”.
4. Si no hay siguiente ni replay view, el reproductor se queda al final.

No hace falta suscribirse al evento `finish` para que el siguiente episodio se reproduzca; el SDK ya lo hace por dentro cuando aplican las condiciones anteriores.

---

## UI incluida en el SDK

Con `config.customUI = true` el SDK muestra su vista personalizada, que incluye:

- **Botón anterior** (`previousButton`): llama a `playPrev()`.
- **Botón siguiente** (`nextButton`): llama a `playNext()`.

El SDK habilita o deshabilita estos botones según exista o no `prevEpisodeConfig` y `nextEpisodeConfig` (que dependen de que el backend envíe `prev` y `next` en el JSON).

No es necesario añadir código extra para que estos botones funcionen; basta con `loadNextAutomatically = true`, `customUI = true` y que la API devuelva `prev`/`next`.

---

## Controles del sistema (Control Center / CarPlay)

El SDK se integra con los comandos de “siguiente pista” y “anterior pista” de iOS (Control Center, auriculares, CarPlay):

- **Siguiente pista** → `playNext()`
- **Anterior pista** → `playPrev()`

Así, el usuario puede pasar al siguiente o al anterior episodio desde fuera de la app cuando `loadNextAutomatically` está activado y el backend proporciona `next`/`prev`.

---

## Ejemplo completo

```swift
let mdstrm = MediastreamPlatformSDK()
let config = MediastreamPlayerConfig()

config.accountID = "5c58a34e176c2c0813b22e4b"
config.id = "5d4a071c37beb90719a41611"
config.type = MediastreamPlayerConfig.VideoTypes.EPISODE
config.videoFormat = MediastreamPlayerConfig.AudioVideoFormat.MP3
config.environment = MediastreamPlayerConfig.Environments.PRODUCTION

// Activar siguiente/anterior episodio
config.loadNextAutomatically = true

// UI con botones siguiente/anterior
config.customUI = true
config.updatesNowPlayingInfoCenter = true

mdstrm.view.frame = containerView.bounds
containerView.addSubview(mdstrm.view)
mdstrm.setup(config)
mdstrm.play()

// Opcional: control programático desde tu propia UI
// myNextButton.addTarget(...) { mdstrm.playNext() }
// myPrevButton.addTarget(...) { mdstrm.playPrev() }
```

Al salir de pantalla, recuerda llamar a `mdstrm.releasePlayer()`.

---

## Referencias en el código

| Concepto | Archivo | Líneas (aprox.) |
|---------|---------|------------------|
| `loadNextAutomatically` | `MediastreamPlayerConfig.swift` | 100, 321–323 |
| `nextEpisodeConfig` / `prevEpisodeConfig` | `MediastreamPlatformSDK.swift` | 20–21, 395–396 |
| Relleno de `prev`/`next` desde JSON | `MediastreamPlatformSDK.swift` | 1980–2011 |
| Autoplay al terminar (playNext) | `MediastreamPlatformSDK.swift` | 741–744 |
| `playNext()` / `playPrev()` | `MediastreamPlatformSDK.swift` | 2687–2697 |
| Habilitar botones next/previous en custom UI | `MediastreamPlatformSDK.swift` | 1526–1527 |
| Acción botón siguiente | `MediastreamPlatformSDK.swift` | 2734–2736 |
| Acción botón anterior | `MediastreamPlatformSDK.swift` | 2722–2724 |
| Next/Previous track (sistema) | `MediastreamPlatformSDK.swift` | 3390–3396 |
| Ejemplo en app Example | `Example/.../TopViewController.swift` | 116 (`configureEpisode`) |

---

Para la API general del reproductor y eventos, ver [API.md](API.md) y [EVENTS.md](EVENTS.md).
