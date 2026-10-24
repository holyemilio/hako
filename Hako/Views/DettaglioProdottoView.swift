import SwiftUI

struct DettaglioProdottoView: View {
    @EnvironmentObject var store: HakoStore
    @Environment(\.dismiss) var dismiss

    let prodotto: Prodotto

    @State private var currentProdotto: Prodotto
    @State private var mostraModifica = false
    @State private var mostraSposta = false
    @State private var mostraConfermaElimina = false

    init(prodotto: Prodotto) {
        self.prodotto = prodotto
        _currentProdotto = State(initialValue: prodotto)
    }

    var dispensa: Dispensa? { store.dispensa(for: currentProdotto) }
    var scomparto: Scomparto? { store.scomparto(for: currentProdotto) }

    var scadenzaText: String {
        if currentProdotto.nonScade { return "Non scade" }
        guard let s = currentProdotto.scadenza else { return "—" }
        let df = DateFormatter()
        df.locale = Locale(identifier: "it_IT")
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: s)
    }

    var giorniScadenzaText: String? {
        if currentProdotto.nonScade { return nil }
        guard let s = currentProdotto.scadenza else { return nil }
        let giorni = Calendar.current.dateComponents([.day], from: Date(), to: s).day ?? 0
        if giorni < 0 { return "Scaduto da \(abs(giorni)) giorni" }
        if giorni == 0 { return "Scade oggi" }
        if giorni < 30 { return "Tra \(giorni) giorni" }
        let mesi = giorni / 30
        return "Tra \(mesi) \(mesi == 1 ? "mese" : "mesi")"
    }

    var scadenzaColore: Color {
        if currentProdotto.isScaduto { return Color(hex: "#C73A32") }
        if currentProdotto.isInScadenzaSettimana { return Color(hex: "#9A5212") }
        return .secondary
    }

    var scadenzaBg: Color {
        if currentProdotto.isScaduto { return Color(hex: "#FDECEA") }
        if currentProdotto.isInScadenzaSettimana { return Color(hex: "#FFF6EC") }
        return Color(.secondarySystemBackground)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header prodotto
                    HStack(alignment: .top, spacing: 14) {
                        ProdottoIcona(prodotto: currentProdotto, size: 80)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentProdotto.nome)
                                .font(.title2.bold())
                            HStack(spacing: 4) {
                                Circle().fill(currentProdotto.coloreCategoria).frame(width: 8, height: 8)
                                Text("\(currentProdotto.forma.nome) › \(currentProdotto.categoria.rawValue)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 8)

                    // Info cards
                    HStack(spacing: 12) {
                        // Scadenza
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scadenza").font(.caption).foregroundStyle(.secondary)
                            Text(scadenzaText).font(.subheadline.bold()).foregroundStyle(scadenzaColore)
                            if let g = giorniScadenzaText {
                                Text(g).font(.caption).foregroundStyle(scadenzaColore)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(scadenzaBg, in: RoundedRectangle(cornerRadius: 12))

                        // Scomparto
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scomparto").font(.caption).foregroundStyle(.secondary)
                            Text(scomparto?.nome ?? "—").font(.subheadline.bold())
                            Text(dispensa?.nome ?? "—").font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    }

                    // Livello
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Livello").font(.subheadline)
                            Spacer()
                            Text("\(Int(currentProdotto.livello * 100))%").font(.subheadline.bold())
                        }
                        Slider(value: Binding(
                            get: { currentProdotto.livello },
                            set: { v in
                                currentProdotto.livello = v
                                store.aggiornaProdotto(currentProdotto)
                            }
                        ), in: 0...1, step: 0.05)
                        .tint(Color(hex: "#4A9FD8"))
                        HStack {
                            Text("0").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("25").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("50").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("75").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("100%").font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    // Freezer toggle (se applicabile)
                    if let d = dispensa, d.tipo == .freezer {
                        Button {
                            store.congelaToggle(currentProdotto)
                            if let updated = store.prodotti.first(where: { $0.id == currentProdotto.id }) {
                                currentProdotto = updated
                            }
                        } label: {
                            HStack {
                                Image(systemName: currentProdotto.congelato ? "snowflake" : "snowflake")
                                    .foregroundStyle(Color(hex: "#6FB1E0"))
                                Text(currentProdotto.congelato ? "Congelato – tocca per scongelare" : "Congela prodotto")
                                    .font(.subheadline)
                                Spacer()
                                Toggle("", isOn: .constant(currentProdotto.congelato))
                                    .labelsHidden()
                                    .allowsHitTesting(false)
                            }
                            .padding(14)
                            .background(Color(hex: "#E3EEF7"), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }

                    // Azioni
                    HStack(spacing: 10) {
                        Button {
                            currentProdotto.livello = 0
                            store.eliminaProdotto(currentProdotto)
                            dismiss()
                        } label: {
                            Text("Consumato")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color(hex: "#2E7AB0"), in: RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            mostraSposta = true
                        } label: {
                            Text("Sposta")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#CFE3F2")))
                        }
                        .buttonStyle(.plain)

                        Button(role: .destructive) {
                            mostraConfermaElimina = true
                        } label: {
                            Text("Elimina")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color(hex: "#C73A32"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color(hex: "#FDECEA"), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#F1C9C5")))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mostraModifica = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $mostraModifica) {
            ModificaProdottoView(prodotto: $currentProdotto) {
                store.aggiornaProdotto(currentProdotto)
            }
        }
        .sheet(isPresented: $mostraSposta) {
            SpostaProdottoView(prodotto: currentProdotto) { nuovaDispensaID, nuovoScompartoID in
                store.spostaProducto(currentProdotto, a: nuovoScompartoID, in: nuovaDispensaID)
                dismiss()
            }
        }
        .confirmationDialog("Elimina prodotto", isPresented: $mostraConfermaElimina, titleVisibility: .visible) {
            Button("Elimina", role: .destructive) {
                store.eliminaProdotto(currentProdotto)
                dismiss()
            }
        } message: {
            Text("Vuoi eliminare \"\(currentProdotto.nome)\"?")
        }
    }
}

// MARK: - Modifica Prodotto

struct ModificaProdottoView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var prodotto: Prodotto
    let onSave: () -> Void

    @State private var nome: String = ""
    @State private var categoria: Categoria = .carboidrati
    @State private var forma: FormaConfezione = .scatola
    @State private var scadenza: Date = Date()
    @State private var nonScade: Bool = false
    @State private var hasScadenza: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Prodotto") {
                    TextField("Nome", text: $nome)
                    Picker("Categoria", selection: $categoria) {
                        ForEach(Categoria.allCases) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                    Picker("Forma", selection: $forma) {
                        ForEach(FormaConfezione.allCases) { f in
                            Text(f.nome).tag(f)
                        }
                    }
                }
                Section("Scadenza") {
                    Toggle("Non scade", isOn: $nonScade)
                    if !nonScade {
                        DatePicker("Data", selection: $scadenza, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Modifica prodotto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        prodotto.nome = nome
                        prodotto.categoria = categoria
                        prodotto.forma = forma
                        prodotto.nonScade = nonScade
                        prodotto.scadenza = nonScade ? nil : scadenza
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            nome = prodotto.nome
            categoria = prodotto.categoria
            forma = prodotto.forma
            nonScade = prodotto.nonScade
            scadenza = prodotto.scadenza ?? Date()
        }
    }
}

// MARK: - Sposta Prodotto

struct SpostaProdottoView: View {
    @EnvironmentObject var store: HakoStore
    @Environment(\.dismiss) var dismiss

    let prodotto: Prodotto
    let onSposta: (UUID, UUID) -> Void

    @State private var dispensaSelID: UUID?
    @State private var scompartoSelID: UUID?

    var scompartiDisponibili: [Scomparto] {
        store.dispense.first { $0.id == dispensaSelID }?.scomparti ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dispensa") {
                    ForEach(store.dispense) { d in
                        Button {
                            dispensaSelID = d.id
                            scompartoSelID = nil
                        } label: {
                            HStack {
                                Image(systemName: d.icona)
                                    .foregroundStyle(Color(hex: "#4A9FD8"))
                                Text(d.nome).foregroundStyle(.primary)
                                Spacer()
                                if d.id == dispensaSelID {
                                    Image(systemName: "checkmark").foregroundStyle(Color(hex: "#4A9FD8"))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                if !scompartiDisponibili.isEmpty {
                    Section("Scomparto") {
                        ForEach(scompartiDisponibili) { s in
                            Button {
                                scompartoSelID = s.id
                            } label: {
                                HStack {
                                    Text(s.nome).foregroundStyle(.primary)
                                    Spacer()
                                    if s.id == scompartoSelID {
                                        Image(systemName: "checkmark").foregroundStyle(Color(hex: "#4A9FD8"))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Sposta prodotto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sposta") {
                        guard let d = dispensaSelID, let s = scompartoSelID else { return }
                        onSposta(d, s)
                        dismiss()
                    }
                    .disabled(dispensaSelID == nil || scompartoSelID == nil)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            dispensaSelID = prodotto.dispensaID
            scompartoSelID = prodotto.scompartoID
        }
    }
}
