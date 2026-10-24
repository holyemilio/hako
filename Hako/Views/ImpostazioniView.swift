import SwiftUI

struct ImpostazioniView: View {
    @EnvironmentObject var store: HakoStore
    @State private var nuovaPersona: String = ""
    @State private var mostraCreazione = false
    @State private var mostraConfermaReset = false

    var body: some View {
        NavigationStack {
            List {
                // Casa e famiglia
                Section {
                    // Header casa
                    HStack(spacing: 14) {
                        Image(systemName: "house.fill")
                            .font(.title3)
                            .foregroundStyle(Color(hex: "#4A9FD8"))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "#EAF4FC"), in: RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("La nostra casa")
                                .font(.headline)
                            Text("\(store.persone.count) person\(store.persone.count == 1 ? "a" : "e") · \(store.dispense.filter { $0.visibilita == .tuttaLaCasa }.count) dispense visibili")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    // Persone
                    ForEach(store.persone) { persona in
                        HStack(spacing: 12) {
                            Text(persona.iniziale)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(colorePersona(persona), in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(persona.nome).font(.subheadline)
                                let nd = store.dispense.filter { $0.proprietarioID == persona.id && $0.visibilita == .soloMia }.count
                                Text(nd == 0 ? "Membro della casa" : "\(nd) dispensa privata")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if persona.id == store.persone.first?.id {
                                Text("Tu")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color(hex: "#2E7AB0"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "#EAF4FC"), in: Capsule())
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if persona.id != store.persone.first?.id {
                                Button(role: .destructive) {
                                    store.rimuoviPersona(persona)
                                } label: {
                                    Label("Rimuovi", systemImage: "trash")
                                }
                            }
                        }
                    }

                    // Aggiungi persona
                    HStack {
                        TextField("Nome di una persona", text: $nuovaPersona)
                            .textFieldStyle(.plain)
                        Button("Aggiungi") {
                            store.aggiungiPersona(nuovaPersona)
                            nuovaPersona = ""
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(nuovaPersona.isEmpty ? .secondary : Color(hex: "#2E7AB0"))
                        .disabled(nuovaPersona.isEmpty)
                    }

                } header: {
                    Text("Casa e famiglia")
                } footer: {
                    Text("Per ora c'è una sola casa. Chi ne fa parte vede le dispense comuni e quelle condivise con lui.")
                }

                // Dispense e permessi
                Section("Dispense e permessi") {
                    ForEach(store.dispense) { d in
                        NavigationLink {
                            PermessiDispensaView(dispensa: d)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: d.icona)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "#4A9FD8"))
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(d.nome).font(.subheadline)
                                    let proprioText = d.visibilita == .tuttaLaCasa ? "Comune · la modifica tutta la casa" : "Privata"
                                    Text(proprioText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Button {
                        mostraCreazione = true
                    } label: {
                        Label("Aggiungi dispensa", systemImage: "plus")
                            .foregroundStyle(Color(hex: "#2E7AB0"))
                    }
                }

                // Dati
                Section("Dati") {
                    Button(role: .destructive) {
                        mostraConfermaReset = true
                    } label: {
                        Label("Ripristina dati demo", systemImage: "arrow.counterclockwise")
                    }
                }

                // Info
                Section {
                    HStack {
                        Text("Versione")
                        Spacer()
                        Text("V1")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Dispositivo")
                        Spacer()
                        Text("iPhone")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Info")
                } footer: {
                    VStack(spacing: 4) {
                        Text("Hako V1")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text("Gestione scorte e dispense")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $mostraCreazione) { CreaDispensaView() }
        .confirmationDialog("Ripristina dati demo?", isPresented: $mostraConfermaReset, titleVisibility: .visible) {
            Button("Ripristina", role: .destructive) { store.caricaDemo() }
        } message: {
            Text("Tutti i dati attuali verranno sostituiti con i dati di esempio.")
        }
    }

    func colorePersona(_ p: Persona) -> Color {
        let colori: [Color] = [Color(hex: "#4A9FD8"), Color(hex: "#E39AB0"), Color(hex: "#8DB38B")]
        let idx = store.persone.firstIndex(where: { $0.id == p.id }) ?? 0
        return colori[idx % colori.count]
    }
}

// MARK: - Permessi Dispensa

struct PermessiDispensaView: View {
    @EnvironmentObject var store: HakoStore
    let dispensa: Dispensa

    @State private var visibilita: VisibilitaDispensa

    init(dispensa: Dispensa) {
        self.dispensa = dispensa
        _visibilita = State(initialValue: dispensa.visibilita)
    }

    var body: some View {
        Form {
            Section("Accesso") {
                Picker("Di chi è", selection: $visibilita) {
                    Text("Tutta la casa").tag(VisibilitaDispensa.tuttaLaCasa)
                    Text("Solo mia").tag(VisibilitaDispensa.soloMia)
                }
                .pickerStyle(.segmented)
                .onChange(of: visibilita) { _, v in
                    if let idx = store.dispense.firstIndex(where: { $0.id == dispensa.id }) {
                        store.dispense[idx].visibilita = v
                        store.save()
                    }
                }
            }
            Section("Scomparti privati") {
                let privati = dispensa.scomparti.filter { $0.isPrivato }
                if privati.isEmpty {
                    Text("Nessuno scomparto privato").foregroundStyle(.secondary)
                } else {
                    ForEach(privati) { s in
                        HStack {
                            Image(systemName: "lock.fill").foregroundStyle(.secondary)
                            Text(s.nome)
                            Spacer()
                            if let p = store.persona(id: s.proprietarioID) {
                                Text(p.nome).foregroundStyle(.secondary).font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(dispensa.nome)
        .navigationBarTitleDisplayMode(.inline)
    }
}
