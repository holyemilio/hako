import SwiftUI

struct InventarioView: View {
    @EnvironmentObject var store: HakoStore
    @State private var ricerca: String = ""
    @State private var filtroCategoriaID: String? = nil
    @State private var filtroDispensaID: UUID? = nil
    @State private var mostraFiltri = false
    @State private var prodottoSelezionato: Prodotto?

    var prodottiFiltrati: [Prodotto] {
        store.prodotti.filter { p in
            let matchRicerca = ricerca.isEmpty || p.nome.localizedCaseInsensitiveContains(ricerca)
            let matchCat = filtroCategoriaID == nil || p.categoria.id == filtroCategoriaID
            let matchDisp = filtroDispensaID == nil || p.dispensaID == filtroDispensaID
            return matchRicerca && matchCat && matchDisp
        }
    }

    var prodottiPerCategoria: [(Categoria, [Prodotto])] {
        let categorie = Categoria.allCases
        return categorie.compactMap { cat in
            let ps = prodottiFiltrati.filter { $0.categoria == cat }
            return ps.isEmpty ? nil : (cat, ps)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("\(store.prodotti.count) prodotti in \(store.dispense.count) dispense")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Inventario")
                    .font(.largeTitle.bold())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            // Barra cerca + filtri
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Cerca", text: $ricerca)
                        .textFieldStyle(.plain)
                    if !ricerca.isEmpty {
                        Button { ricerca = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#CFE3F2")))

                Button {
                    mostraFiltri = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("Filtri")
                            .font(.subheadline)
                    }
                    .foregroundStyle(hasFiltriAttivi ? Color(hex: "#2E7AB0") : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        hasFiltriAttivi ? Color(hex: "#EAF4FC") : Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(hasFiltriAttivi ? Color(hex: "#4A9FD8") : Color(hex: "#CFE3F2"))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            Divider()

            if prodottiPerCategoria.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(prodottiPerCategoria, id: \.0) { (cat, ps) in
                        Section {
                            ForEach(ps) { p in
                                InventarioRiga(prodotto: p)
                                    .onTapGesture { prodottoSelezionato = p }
                                    .listRowSeparator(ps.last?.id == p.id ? .hidden : .visible)
                                    .listRowBackground(Color(.systemBackground))
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Circle().fill(cat.colore).frame(width: 8, height: 8)
                                Text(cat.rawValue.uppercased())
                                    .font(.caption.bold())
                                    .foregroundStyle(.primary)
                                Text("\(ps.count)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .listSectionSpacing(12)
            }
        }
        .sheet(item: $prodottoSelezionato) { p in
            DettaglioProdottoView(prodotto: p)
        }
        .sheet(isPresented: $mostraFiltri) {
            FiltriInventarioView(
                filtroCategoriaID: $filtroCategoriaID,
                filtroDispensaID: $filtroDispensaID
            )
        }
    }

    var hasFiltriAttivi: Bool {
        filtroCategoriaID != nil || filtroDispensaID != nil
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: ricerca.isEmpty ? "archivebox" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(ricerca.isEmpty ? "Nessun prodotto" : "Nessun risultato")
                .font(.title3.bold())
            if !ricerca.isEmpty {
                Button { ricerca = "" } label: {
                    Text("Cancella ricerca")
                        .foregroundStyle(Color(hex: "#2E7AB0"))
                }
            }
            Spacer()
        }
    }
}

// MARK: - Inventario Riga

struct InventarioRiga: View {
    @EnvironmentObject var store: HakoStore
    let prodotto: Prodotto

    var dispensa: Dispensa? { store.dispensa(for: prodotto) }
    var scomparto: Scomparto? { store.scomparto(for: prodotto) }

    var locazione: String {
        var parts: [String] = []
        if let d = dispensa { parts.append(d.nome) }
        if let s = scomparto { parts.append(s.nome) }
        return parts.joined(separator: " › ")
    }

    var body: some View {
        HStack(spacing: 12) {
            ProdottoIcona(prodotto: prodotto, size: 44)
                .padding(.leading, 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(prodotto.nome)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(locazione)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(prodotto.livello * 100))%")
                    .font(.subheadline.bold())
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(prodotto.coloreCategoria.opacity(0.15))
                        Capsule().fill(prodotto.coloreCategoria)
                            .frame(width: max(4, geo.size.width * prodotto.livello))
                    }
                }
                .frame(width: 60, height: 4)
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Filtri

struct FiltriInventarioView: View {
    @EnvironmentObject var store: HakoStore
    @Environment(\.dismiss) var dismiss
    @Binding var filtroCategoriaID: String?
    @Binding var filtroDispensaID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Categoria") {
                    Button {
                        filtroCategoriaID = nil
                    } label: {
                        HStack {
                            Text("Tutte").foregroundStyle(.primary)
                            Spacer()
                            if filtroCategoriaID == nil {
                                Image(systemName: "checkmark").foregroundStyle(Color(hex: "#4A9FD8"))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    ForEach(Categoria.allCases) { cat in
                        Button {
                            filtroCategoriaID = cat.id
                        } label: {
                            HStack {
                                Circle().fill(cat.colore).frame(width: 10, height: 10)
                                Text(cat.rawValue).foregroundStyle(.primary)
                                Spacer()
                                if filtroCategoriaID == cat.id {
                                    Image(systemName: "checkmark").foregroundStyle(Color(hex: "#4A9FD8"))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section("Dispensa") {
                    Button {
                        filtroDispensaID = nil
                    } label: {
                        HStack {
                            Text("Tutte").foregroundStyle(.primary)
                            Spacer()
                            if filtroDispensaID == nil {
                                Image(systemName: "checkmark").foregroundStyle(Color(hex: "#4A9FD8"))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    ForEach(store.dispense) { d in
                        Button {
                            filtroDispensaID = d.id
                        } label: {
                            HStack {
                                Image(systemName: d.icona).foregroundStyle(Color(hex: "#4A9FD8"))
                                Text(d.nome).foregroundStyle(.primary)
                                Spacer()
                                if filtroDispensaID == d.id {
                                    Image(systemName: "checkmark").foregroundStyle(Color(hex: "#4A9FD8"))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section {
                    Button(role: .destructive) {
                        filtroCategoriaID = nil
                        filtroDispensaID = nil
                        dismiss()
                    } label: {
                        Text("Azzera filtri")
                    }
                }
            }
            .navigationTitle("Filtri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fine") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
