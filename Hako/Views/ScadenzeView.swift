import SwiftUI

struct ScadenzeView: View {
    @EnvironmentObject var store: HakoStore
    @State private var filtroDispensa: UUID? = nil  // nil = tutte
    @State private var prodottoSelezionato: Prodotto?

    var dispenseNomi: [(id: UUID?, nome: String)] {
        [( id: nil, nome: "Tutte" )] + store.dispense.map { (id: $0.id, nome: $0.nome) }
    }

    var prodottiScadutiFiltered: [Prodotto] {
        filtroDispensa == nil ? store.prodottiScaduti : store.prodottiScaduti.filter { $0.dispensaID == filtroDispensa }
    }

    var prodottiSettFiltered: [Prodotto] {
        filtroDispensa == nil ? store.prodottiQuestaSett : store.prodottiQuestaSett.filter { $0.dispensaID == filtroDispensa }
    }

    var prodottiAvatiFiltered: [Prodotto] {
        filtroDispensa == nil ? store.prodottiPiuAvanti : store.prodottiPiuAvanti.filter { $0.dispensaID == filtroDispensa }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("Ordinate per data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Scadenze")
                    .font(.largeTitle.bold())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            // Filtri dispense
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dispenseNomi, id: \.nome) { item in
                        Button {
                            withAnimation(.spring(duration: 0.2)) { filtroDispensa = item.id }
                        } label: {
                            Text(item.nome)
                                .font(.subheadline)
                                .fontWeight(filtroDispensa == item.id ? .semibold : .regular)
                                .foregroundStyle(filtroDispensa == item.id ? .white : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    filtroDispensa == item.id ? Color(hex: "#4A9FD8") : Color(.secondarySystemBackground),
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule().strokeBorder(filtroDispensa == item.id ? Color.clear : Color(hex: "#CFE3F2"))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)

            Divider()

            // Lista
            if prodottiScadutiFiltered.isEmpty && prodottiSettFiltered.isEmpty && prodottiAvatiFiltered.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundStyle(Color(hex: "#8DB38B"))
                    Text("Nessuna scadenza")
                        .font(.title3.bold())
                    Text("Tutti i prodotti sono in ordine.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                List {
                    if !prodottiScadutiFiltered.isEmpty {
                        Section {
                            ForEach(prodottiScadutiFiltered) { p in
                                ScadenzaRiga(prodotto: p)
                                    .onTapGesture { prodottoSelezionato = p }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Circle().fill(.red).frame(width: 8, height: 8)
                                Text("SCADUTI").font(.caption.bold()).foregroundStyle(.primary)
                                Text("\(prodottiScadutiFiltered.count)").font(.caption.bold()).foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !prodottiSettFiltered.isEmpty {
                        Section {
                            ForEach(prodottiSettFiltered) { p in
                                ScadenzaRiga(prodotto: p)
                                    .onTapGesture { prodottoSelezionato = p }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Circle().fill(.orange).frame(width: 8, height: 8)
                                Text("QUESTA SETTIMANA").font(.caption.bold()).foregroundStyle(.primary)
                                Text("\(prodottiSettFiltered.count)").font(.caption.bold()).foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !prodottiAvatiFiltered.isEmpty {
                        Section {
                            ForEach(prodottiAvatiFiltered) { p in
                                ScadenzaRiga(prodotto: p)
                                    .onTapGesture { prodottoSelezionato = p }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Circle().fill(Color(hex: "#6FB1E0")).frame(width: 8, height: 8)
                                Text("PIÙ AVANTI").font(.caption.bold()).foregroundStyle(.primary)
                                Text("\(prodottiAvatiFiltered.count)").font(.caption.bold()).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .listSectionSpacing(8)
            }
        }
        .sheet(item: $prodottoSelezionato) { p in
            DettaglioProdottoView(prodotto: p)
        }
    }
}

// MARK: - Scadenza Riga

struct ScadenzaRiga: View {
    @EnvironmentObject var store: HakoStore
    let prodotto: Prodotto

    var dispensa: Dispensa? { store.dispensa(for: prodotto) }
    var scomparto: Scomparto? { store.scomparto(for: prodotto) }

    var scadenzaText: String {
        guard let s = prodotto.scadenza else { return "Non scade" }
        let df = DateFormatter()
        df.locale = Locale(identifier: "it_IT")
        df.dateFormat = "d MMM yyyy"
        return df.string(from: s)
    }

    var giorniText: String {
        guard let s = prodotto.scadenza else { return "" }
        let giorni = Calendar.current.dateComponents([.day], from: Date(), to: s).day ?? 0
        if giorni < 0 { return "Scaduto da \(abs(giorni)) giorni" }
        if giorni == 0 { return "Scade oggi" }
        if giorni < 30 { return "Tra \(giorni) giorni" }
        let mesi = giorni / 30
        return "Tra \(mesi) \(mesi == 1 ? "mese" : "mesi")"
    }

    var tagColore: Color {
        if prodotto.isScaduto { return Color(hex: "#C73A32") }
        if prodotto.isInScadenzaSettimana { return Color(hex: "#9A5212") }
        return .secondary
    }

    var tagBg: Color {
        if prodotto.isScaduto { return Color(hex: "#FDECEA") }
        if prodotto.isInScadenzaSettimana { return Color(hex: "#FFF6EC") }
        return Color(.secondarySystemBackground)
    }

    var locazione: String {
        var parts: [String] = []
        if let d = dispensa { parts.append(d.nome) }
        if let s = scomparto { parts.append(s.nome) }
        let livString = "\(Int(prodotto.livello * 100))%"
        parts.append(livString)
        return parts.joined(separator: " › ")
    }

    var body: some View {
        HStack(spacing: 12) {
            ProdottoIcona(prodotto: prodotto, size: 44)

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

            VStack(alignment: .trailing, spacing: 2) {
                Text(scadenzaText).font(.caption.bold())
                Text(giorniText)
                    .font(.caption.bold())
                    .foregroundStyle(tagColore)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tagBg, in: Capsule())
            }
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#E6F0F8")))
    }
}
