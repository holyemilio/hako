import SwiftUI

struct BenvenutoView: View {
    @EnvironmentObject var store: HakoStore
    @State private var mostraCreazione = false

    var categoriePreviw: [(Categoria, FormaConfezione)] = [
        (.carboidrati, .pasta),
        (.conserveESalse, .vasetto),
        (.bevande, .bottiglia),
        (.proteine, .lattina),
        (.puliziaCasa, .flacone)
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Anteprima dispensa
                previewDispensa
                    .padding(.bottom, 28)

                // Logo + titolo
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#4A9FD8"))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "cube.box.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        )
                    Text("Hako")
                        .font(.title.bold())
                }
                .padding(.bottom, 20)

                Text("Tutto ciò che hai in casa,\na colpo d'occhio")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Crea una dispensa, disegna i suoi scomparti e aggiungi i prodotti. Il tutto direttamente sul telefono.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)

                Spacer()

                // CTA primaria
                Button {
                    mostraCreazione = true
                } label: {
                    Text("Crea la tua prima dispensa")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#2E7AB0"), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                // Demo link
                Button {
                    store.caricaDemo()
                } label: {
                    Text("Oppure apri la demo con dati di esempio")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#2E7AB0"))
                }
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $mostraCreazione) {
            CreaDispensaView(isFirstLaunch: true)
        }
    }

    @ViewBuilder
    var previewDispensa: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color(hex: "#CFE3F2"), lineWidth: 1.5)
            )
            .overlay(
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        ForEach(0..<3) { i in
                            let pair = categoriePreviw[i]
                            let p = fakeProducto(pair)
                            ProdottoCella(prodotto: p)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)

                    Divider()

                    HStack(spacing: 20) {
                        ForEach(3..<5) { i in
                            let pair = categoriePreviw[i]
                            let p = fakeProducto(pair)
                            ProdottoCella(prodotto: p)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
            )
            .frame(height: 180)
            .padding(.horizontal, 40)
    }

    func fakeProducto(_ pair: (Categoria, FormaConfezione)) -> Prodotto {
        let dID = UUID()
        let sID = UUID()
        return Prodotto(nome: "", categoria: pair.0, forma: pair.1, dispensaID: dID, scompartoID: sID)
    }
}
