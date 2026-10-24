import SwiftUI

struct AggiungiProdottoView: View {
    @EnvironmentObject var store: HakoStore
    @Environment(\.dismiss) var dismiss

    // Campi
    @State private var nome: String = ""
    @State private var categoria: Categoria = .carboidrati
    @State private var forma: FormaConfezione = .scatola
    @State private var livello: Double = 1.0
    @State private var nonScade: Bool = false
    @State private var scadenza: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
    @State private var dispensaSelID: UUID?
    @State private var scompartoSelID: UUID?

    var scompartiDisponibili: [Scomparto] {
        store.dispense.first { $0.id == dispensaSelID }?.scomparti ?? []
    }

    var canSave: Bool {
        !nome.isEmpty && dispensaSelID != nil && scompartoSelID != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Prodotto
                Section {
                    TextField("Nome prodotto", text: $nome)
                    Picker("Categoria", selection: $categoria) {
                        ForEach(Categoria.allCases) { c in
                            HStack {
                                Circle().fill(c.colore).frame(width: 10, height: 10)
                                Text(c.rawValue)
                            }
                            .tag(c)
                        }
                    }
                    .onChange(of: categoria) { _, newCat in
                        forma = newCat.formaPredefinita
                    }
                    Picker("Forma confezione", selection: $forma) {
                        ForEach(FormaConfezione.allCases) { f in
                            Text(f.nome).tag(f)
                        }
                    }
                } header: {
                    Text("Prodotto")
                } footer: {
                    // Anteprima icona
                    let fakeProd = Prodotto(nome: nome.isEmpty ? "Anteprima" : nome,
                                           categoria: categoria, forma: forma,
                                           dispensaID: UUID(), scompartoID: UUID())
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            ProdottoIcona(prodotto: fakeProd, size: 60)
                            Text(nome.isEmpty ? "Anteprima" : nome)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        Spacer()
                    }
                    .padding(.top, 8)
                }

                // Quantità
                Section("Quantità") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Livello")
                            Spacer()
                            Text("\(Int(livello * 100))%").fontWeight(.semibold)
                        }
                        Slider(value: $livello, in: 0...1, step: 0.05)
                            .tint(categoria.colore)
                    }
                }

                // Scadenza
                Section("Scadenza") {
                    Toggle("Non scade", isOn: $nonScade)
                    if !nonScade {
                        DatePicker("Data di scadenza", selection: $scadenza, displayedComponents: .date)
                    }
                }

                // Posizione
                Section("Posizione") {
                    Picker("Dispensa", selection: $dispensaSelID) {
                        Text("Scegli…").tag(UUID?.none)
                        ForEach(store.dispense) { d in
                            Label(d.nome, systemImage: d.icona).tag(Optional(d.id))
                        }
                    }
                    .onChange(of: dispensaSelID) { _, _ in scompartoSelID = nil }

                    if !scompartiDisponibili.isEmpty {
                        Picker("Scomparto", selection: $scompartoSelID) {
                            Text("Scegli…").tag(UUID?.none)
                            ForEach(scompartiDisponibili) { s in
                                Text(s.nome).tag(Optional(s.id))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Aggiungi prodotto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aggiungi") {
                        salva()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            dispensaSelID = store.dispensaSelezionataID
            scompartoSelID = store.dispense.first { $0.id == dispensaSelID }?.scomparti.first?.id
        }
    }

    func salva() {
        guard let dID = dispensaSelID, let sID = scompartoSelID else { return }
        let p = Prodotto(
            nome: nome,
            categoria: categoria,
            forma: forma,
            dispensaID: dID,
            scompartoID: sID,
            scadenza: nonScade ? nil : scadenza,
            nonScade: nonScade,
            livello: livello
        )
        store.aggiungiProdotto(p)
        dismiss()
    }
}
