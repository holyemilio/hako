# Hako — stato del progetto

Stato al 2026-10-24.

## Cos'è

Hako è un'app iOS (SwiftUI, iOS 17+, solo iPhone) per tenere traccia di cosa c'è in dispensa: prodotti, scomparti, scadenze, freezer, dispense condivise tra persone e notifiche.

## Cosa è fatto

**Codice** (`Hako/`, circa 2.300 righe di Swift):

- Modelli dati: dispensa, scomparto, prodotto, persona, ambiente, forma, categoria (`Models/Models.swift`).
- Store centrale `HakoStore` con persistenza in JSON su disco, dati demo, gestione dispense e prodotti, spostamento tra scomparti, toggle freezer e notifiche locali per le scadenze.
- Schermate: benvenuto, creazione dispensa, dispensa (con legenda), dettaglio prodotto, sposta prodotto, aggiunta prodotto, scadenze, inventario con filtri, impostazioni, componente icona prodotto.
- Asset SVG per le forme dei contenitori (barattolo, bottiglia, busta, flacone, lattina, pasta, rotolo, scatola, vasetto).

**Design** (`Hako_UX/`):

- `Mockup.md`: 39 schermate raggruppate per flusso (primo avvio, prodotto, scadenze, permessi, freezer, notifiche, modalità scura).
- `Tabelle/`: tabelle di dati di riferimento (categorie, forme, ambienti, colori, dizionario, freezer, alimenti che non scadono).

**Verifica**: il progetto compila per iOS Simulator con Xcode 27 (`BUILD SUCCEEDED`). Il build è stato fatto con `DEVELOPER_DIR` puntato a Xcode.app.

## Cosa manca

- **Fotocamera e riconoscimento del codice a barre**: presenti nei mockup (schermate 10–13), ma nel codice non c'è nessuna implementazione (nessun uso di `AVFoundation`, `Vision` o `VisionKit`).
- **Dizionario parole → categoria**: la tabella esiste nei documenti ma è segnaposto (`kw | sub | cat | shape`), quindi non è ancora compilata.
- **Mesi di conservazione in freezer**: tabella vuota, valore standard +3 mesi ancora da decidere.
- **Test**: nessun target di test nel progetto Xcode.
- **Git**: il progetto non era un repository.

## Problemi noti

- **Simulatore non parte da terminale o da Xcode**: `xcode-select` punta a `/Library/Developer/CommandLineTools` invece che a `/Applications/Xcode.app`. Per correggere: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`. Da lì `xcodebuild` e `simctl` funzionano.
- Nel codice c'è un refuso nel nome della funzione `spostaProducto` (in `HakoStore.swift`).

## Perché il progetto è fermo

Dal feedback degli utenti è emerso un problema di fondo, non tecnico:

- Le persone non vogliono fotografare e impostare la scadenza di ogni prodotto.
- Il codice a barre, anche se letto, non dà la scadenza del prodotto: serve comunque un inserimento manuale.

Quindi la parte che avrebbe dovuto ridurre il lavoro (scansione) non lo riduce, e il resto richiede lo stesso sforzo di un'app di inventario manuale.

## Cosa ne ricavo

- Il lavoro di analisi (scomparti, freezer, ambienti, permessi condivisi, dati di conservazione) è riutilizzabile anche fuori da Hako.
- Il codice compila e la struttura è pulita abbastanza da riprenderla.
- Il limite è il modello d'uso, non l'implementazione.

## Opzioni

1. **Archiviare su GitHub come repo privato** con questo file e il codice, senza andare avanti. Costa poco, conserva il lavoro e può diventare materiale per la candidatura (case study del processo di discovery e del feedback).
2. **Eliminare** il progetto locale. Irreversibile: per questo consiglio prima l'opzione 1.
3. **Ripartire con un'idea più piccola**, per esempio solo scadenze e dispensa condivisa senza scansione e senza foto, riusando modelli e tabelle.

Decisione: da prendere.
