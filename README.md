# Hako

App iOS (SwiftUI, iOS 17+) per tenere traccia di dispensa, scadenze e freezer, anche condivisa tra persone.

Stato del progetto e analisi: vedi [PROGRESS.md](PROGRESS.md).

## Struttura

- `Hako/`: codice Swift (modelli, store, viste, asset)
- `Hako_UX/`: mockup e tabelle di dati di riferimento
- `Hako.xcodeproj/`: progetto Xcode

## Build

Richiede Xcode (non solo i Command Line Tools):

```sh
xcodebuild -project Hako.xcodeproj -scheme Hako \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```
