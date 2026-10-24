import SwiftUI

struct DispensaView: View {
    @EnvironmentObject var store: HakoStore
    @State private var mostraSelettore = false
    @State private var mostraLegenda = false
    @State private var mostraCreazione = false
    @State private var prodottoSelezionato: Prodotto?

    var dispensa: Dispensa? { store.dispensaSelezionata }

    var prodottiDispensa: [Prodotto] {
        guard let d = dispensa else { return [] }
        return store.prodotti(in: d)
    }

    var scadutiText: String? {
        guard let d = dispensa else { return nil }
        let ps = store.prodotti(in: d)
        let sc = ps.filter { $0.isScaduto }.count
        let si = ps.filter { $0.isInScadenzaSettimana && !$0.isScaduto }.count
        if sc == 0 && si == 0 { return nil }
        var parts: [String] = []
        if sc > 0 { parts.append("\(sc) scadut\(sc == 1 ? "o" : "i")") }
        if si > 0 { parts.append("\(si) in scadenza questa settimana") }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.dispense.isEmpty {
                    emptyState
                } else if let dispensa {
                    dispensaContent(dispensa)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $mostraSelettore) { SelettoreDispenseView() }
            .sheet(isPresented: $mostraLegenda) { LegendaView() }
            .sheet(isPresented: $mostraCreazione) { CreaDispensaView() }
            .sheet(item: $prodottoSelezionato) { p in
                DettaglioProdottoView(prodotto: p)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if let d = dispensa {
                Button {
                    mostraSelettore = true
                } label: {
                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(d.tipo.rawValue) · \(prodottiDispensa.count) prodott\(prodottiDispensa.count == 1 ? "o" : "i")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(d.nome)
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                        }
                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundStyle(Color(hex: "#4A9FD8"))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                mostraLegenda = true
            } label: {
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Circle().fill(Color(hex: "#D9B35A")).frame(width: 8, height: 8)
                        Circle().fill(Color(hex: "#E8826F")).frame(width: 8, height: 8)
                        Circle().fill(Color(hex: "#6FB1E0")).frame(width: 8, height: 8)
                        Circle().fill(Color(hex: "#8DB38B")).frame(width: 8, height: 8)
                    }
                    Text("Legenda")
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color(.secondarySystemBackground), in: Capsule())
                .overlay(Capsule().strokeBorder(Color(hex: "#CFE3F2")))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Empty State

    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cube.box")
                .font(.system(size: 52))
                .foregroundStyle(Color(hex: "#4A9FD8").opacity(0.5))
            Text("Nessuna dispensa")
                .font(.title3.bold())
            Text("Crea la tua prima dispensa per iniziare.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                mostraCreazione = true
            } label: {
                Text("Crea dispensa")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 13)
                    .background(Color(hex: "#2E7AB0"), in: RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
        }
    }

    // MARK: - Dispensa Content

    @ViewBuilder
    func dispensaContent(_ dispensa: Dispensa) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Banner scadenze
                if let testo = scadutiText {
                    NavigationLink(destination: ScadenzeView()) {
                        HStack {
                            Circle().fill(.red).frame(width: 10, height: 10)
                            Text(testo).font(.subheadline).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#FFF6EC"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#EBA25A").opacity(0.3)))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }

                // Scomparti
                ForEach(dispensa.scomparti) { scomp in
                    ScompartoSection(
                        scomparto: scomp,
                        prodotti: store.prodotti(in: scomp),
                        onProdottoTap: { p in prodottoSelezionato = p }
                    )
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
    }
}

// MARK: - Scomparto Section

struct ScompartoSection: View {
    let scomparto: Scomparto
    let prodotti: [Prodotto]
    let onProdottoTap: (Prodotto) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if scomparto.isPrivato {
                    Image(systemName: "lock.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                Text(scomparto.nome.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }

            if prodotti.isEmpty {
                emptyPlaceholder
            } else {
                gridProdotti
            }
        }
        .padding(14)
        .background(Color(hex: "#F0F5FA"), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(scomparto.isPrivato ? Color(hex: "#CFE3F2").opacity(0.5) : Color(hex: "#E6F0F8"), lineWidth: 1)
                .opacity(scomparto.isPrivato ? 1 : 1)
        )
        .overlay(
            scomparto.isPrivato ?
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "#CFE3F2"), lineWidth: 1, antialiased: true)
                .opacity(1) : nil
        )
    }

    var emptyPlaceholder: some View {
        Color.clear.frame(height: 60)
    }

    var gridProdotti: some View {
        let columns = [GridItem(.adaptive(minimum: 52), spacing: 12)]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(prodotti) { p in
                ProdottoCella(prodotto: p) {
                    onProdottoTap(p)
                }
            }
        }
    }
}

// MARK: - Selettore Dispense

struct SelettoreDispenseView: View {
    @EnvironmentObject var store: HakoStore
    @Environment(\.dismiss) var dismiss
    @State private var mostraCreazione = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.dispense) { d in
                    Button {
                        store.dispensaSelezionataID = d.id
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: d.icona)
                                .font(.title3)
                                .foregroundStyle(Color(hex: "#4A9FD8"))
                                .frame(width: 36, height: 36)
                                .background(Color(hex: "#EAF4FC"), in: RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(d.nome).font(.headline)
                                Text("\(d.tipo.rawValue) · \(store.prodotti(in: d).count) prodotti")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                            if d.id == store.dispensaSelezionataID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: "#4A9FD8"))
                                    .font(.subheadline.bold())
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            store.eliminaDispensa(d)
                        } label: {
                            Label("Elimina", systemImage: "trash")
                        }
                    }
                }

                Button {
                    mostraCreazione = true
                } label: {
                    Label("Nuova dispensa", systemImage: "plus")
                        .foregroundStyle(Color(hex: "#2E7AB0"))
                }
            }
            .navigationTitle("Le tue dispense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $mostraCreazione) { CreaDispensaView() }
    }
}

// MARK: - Legenda

struct LegendaView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Categorie e colori") {
                    ForEach(Categoria.allCases) { cat in
                        HStack(spacing: 12) {
                            Circle().fill(cat.colore).frame(width: 14, height: 14)
                            Text(cat.rawValue).font(.subheadline)
                        }
                    }
                }
                Section("Icone speciali") {
                    HStack(spacing: 12) {
                        Image(systemName: "snowflake")
                            .foregroundStyle(Color(hex: "#6FB1E0"))
                        Text("Prodotto congelato nel freezer")
                            .font(.subheadline)
                    }
                    HStack(spacing: 12) {
                        Circle().fill(.red).frame(width: 10, height: 10)
                        Text("Scaduto")
                            .font(.subheadline)
                    }
                    HStack(spacing: 12) {
                        Circle().fill(.orange).frame(width: 10, height: 10)
                        Text("In scadenza entro 7 giorni")
                            .font(.subheadline)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                        Text("Scomparto privato")
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Legenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }
}
