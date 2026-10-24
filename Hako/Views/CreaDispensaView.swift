import SwiftUI

struct CreaDispensaView: View {
    @EnvironmentObject var store: HakoStore
    @Environment(\.dismiss) var dismiss

    var isFirstLaunch: Bool = false

    // Step 1
    @State private var nome: String = ""
    @State private var tipo: TipoDispensa = .dispensa
    @State private var visibilita: VisibilitaDispensa = .tuttaLaCasa
    @State private var step = 1

    // Step 2 – scomparti
    @State private var scomparti: [Scomparto] = [
        Scomparto(nome: "Scomparto 1")
    ]
    @State private var scompartoSelezionatoID: UUID?
    @State private var nuovoNomeScomparto: String = ""
    @FocusState private var focusNome: Bool

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if step == 1 {
                    step1
                } else {
                    step2
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if step == 2 {
                            withAnimation { step = 1 }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color(hex: "#2E7AB0"))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(step == 1 ? "Passo 1 di 2" : "Passo 2 di 2 · \(nome)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Step 1

    @ViewBuilder
    var step1: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(isFirstLaunch ? "La tua prima dispensa" : "Nuova dispensa")
                    .font(.largeTitle.bold())
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome").font(.subheadline).foregroundStyle(.secondary)
                    TextField("es. Cucina, Frigo, Bagno…", text: $nome)
                        .textFieldStyle(.plain)
                        .padding(14)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#CFE3F2")))
                        .focused($focusNome)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Tipo").font(.subheadline).foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(TipoDispensa.allCases) { t in
                            TipoCell(tipo: t, selezionato: tipo == t) {
                                withAnimation(.spring(duration: 0.2)) { tipo = t }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Di chi è").font(.subheadline).foregroundStyle(.secondary)
                    HStack(spacing: 0) {
                        ForEach([VisibilitaDispensa.tuttaLaCasa, .soloMia], id: \.rawValue) { v in
                            Button(v.rawValue) {
                                withAnimation { visibilita = v }
                            }
                            .font(.subheadline)
                            .fontWeight(visibilita == v ? .semibold : .regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(visibilita == v ? Color(.systemBackground) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(3)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    Text(visibilita == .tuttaLaCasa ? "Tutti i membri della casa potranno vederla e modificarla." : "Solo tu potrai vederla e modificarla.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 20)

                Button {
                    withAnimation { step = 2 }
                } label: {
                    Text("Avanti: disegna gli scomparti")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(nome.isEmpty ? Color.gray : Color(hex: "#2E7AB0"), in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(nome.isEmpty)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 2

    @ViewBuilder
    var step2: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scomparti")
                            .font(.largeTitle.bold())
                            .padding(.top, 8)
                        Text("Tocca + per aggiungere uno scomparto.\nRinominalo nel campo in basso.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Griglia scomparti
                    ScompartiGridEditor(
                        scomparti: $scomparti,
                        selezionato: $scompartoSelezionatoID
                    )
                    .frame(height: 260)

                    // Editing scomparto selezionato
                    if let selID = scompartoSelezionatoID,
                       let idx = scomparti.firstIndex(where: { $0.id == selID }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome dello scomparto selezionato")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack {
                                TextField("Nome", text: $scomparti[idx].nome)
                                    .textFieldStyle(.plain)
                                    .padding(13)
                                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#CFE3F2")))

                                Button(role: .destructive) {
                                    withAnimation {
                                        scomparti.removeAll { $0.id == selID }
                                        scompartoSelezionatoID = scomparti.last?.id
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "#F1C9C5")))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            Divider()

            Button {
                salva()
            } label: {
                Text("Salva dispensa · \(scomparti.count) scompart\(scomparti.count == 1 ? "o" : "i")")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#2E7AB0"), in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(20)
        }
    }

    // MARK: - Save

    func salva() {
        var d = Dispensa(nome: nome, tipo: tipo, visibilita: visibilita)
        d.scomparti = scomparti.isEmpty ? [Scomparto(nome: "Principale")] : scomparti
        store.aggiungiDispensa(d)
        store.completaPrimoAvvio()
        dismiss()
    }
}

// MARK: - TipoCell

struct TipoCell: View {
    let tipo: TipoDispensa
    let selezionato: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: tipo.icona)
                    .font(.title2)
                    .foregroundStyle(selezionato ? Color(hex: "#2E7AB0") : .secondary)
                Text(tipo.rawValue)
                    .font(.caption)
                    .fontWeight(selezionato ? .semibold : .regular)
                    .foregroundStyle(selezionato ? Color(hex: "#2E7AB0") : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                selezionato ? Color(hex: "#EAF4FC") : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selezionato ? Color(hex: "#4A9FD8") : Color(hex: "#CFE3F2"), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Scomparti Grid Editor

struct ScompartiGridEditor: View {
    @Binding var scomparti: [Scomparto]
    @Binding var selezionato: UUID?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#F0F5FA"))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex: "#CFE3F2")))

            if scomparti.isEmpty {
                Button {
                    aggiungi()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .foregroundStyle(Color(hex: "#4A9FD8"))
                        Text("Aggiungi scomparto")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "#4A9FD8"))
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(scomparti) { scomp in
                                ScompartoRiga(
                                    scomparto: scomp,
                                    selezionato: selezionato == scomp.id,
                                    onTap: { selezionato = scomp.id }
                                )
                            }
                        }
                        .padding(12)
                    }
                }

                // Pulsante aggiungi in basso a destra
                Button {
                    aggiungi()
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#4A9FD8"), in: Circle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(12)
            }
        }
    }

    func aggiungi() {
        let nuovo = Scomparto(nome: "Scomparto \(scomparti.count + 1)")
        scomparti.append(nuovo)
        selezionato = nuovo.id
    }
}

struct ScompartoRiga: View {
    let scomparto: Scomparto
    let selezionato: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: scomparto.isPrivato ? "lock.fill" : "rectangle.split.3x1")
                    .foregroundStyle(selezionato ? Color(hex: "#2E7AB0") : .secondary)
                    .font(.subheadline)
                Text(scomparto.nome)
                    .font(.subheadline)
                    .fontWeight(selezionato ? .semibold : .regular)
                    .foregroundStyle(selezionato ? Color(hex: "#2E7AB0") : .primary)
                Spacer()
                if selezionato {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color(hex: "#2E7AB0"))
                        .font(.caption.bold())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                selezionato ? Color(hex: "#E3F1FB") : Color(.systemBackground),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(selezionato ? Color(hex: "#4A9FD8") : Color(hex: "#E6F0F8"), lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
    }
}
