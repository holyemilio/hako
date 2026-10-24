import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: HakoStore
    @State private var tabSelezionata: Tab = .dispense
    @State private var mostraAggiungi = false

    enum Tab: String {
        case dispense, scadenze, inventario, impostazioni
    }

    var scadutiCount: Int { store.scadutiCount + store.inScadenzaSettimanaCount }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Schermata benvenuto
            if store.primoAvvio {
                BenvenutoView()
            } else {
                // Contenuto tab
                Group {
                    switch tabSelezionata {
                    case .dispense:
                        DispensaView()
                    case .scadenze:
                        ScadenzeView()
                    case .inventario:
                        InventarioView()
                    case .impostazioni:
                        ImpostazioniView()
                    }
                }
                .padding(.bottom, 84) // spazio tab bar

                // Tab bar personalizzata
                VStack(spacing: 0) {
                    Spacer()
                    tabBar
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $mostraAggiungi) {
            AggiungiProdottoView()
        }
    }

    // MARK: - Tab Bar

    var tabBar: some View {
        ZStack {
            // Sfondo
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color(.systemBackground).opacity(0.8))
                )
                .overlay(alignment: .top) {
                    Divider()
                }
                .frame(height: 83)

            HStack(spacing: 0) {
                TabBarItem(icona: "square.grid.2x2", etichetta: "Dispense",
                           selezionato: tabSelezionata == .dispense) {
                    tabSelezionata = .dispense
                }

                TabBarItem(icona: "calendar", etichetta: "Scadenze",
                           selezionato: tabSelezionata == .scadenze,
                           badge: scadutiCount > 0 ? "\(scadutiCount)" : nil) {
                    tabSelezionata = .scadenze
                }

                // Pulsante + centrale
                Button {
                    mostraAggiungi = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(hex: "#4A9FD8"), in: Circle())
                        .shadow(color: Color(hex: "#4A9FD8").opacity(0.4), radius: 8, y: 4)
                }
                .frame(maxWidth: .infinity)
                .offset(y: -12)

                TabBarItem(icona: "list.bullet", etichetta: "Inventario",
                           selezionato: tabSelezionata == .inventario) {
                    tabSelezionata = .inventario
                }

                TabBarItem(icona: "slider.horizontal.3", etichetta: "Impostazioni",
                           selezionato: tabSelezionata == .impostazioni) {
                    tabSelezionata = .impostazioni
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - TabBar Item

struct TabBarItem: View {
    let icona: String
    let etichetta: String
    let selezionato: Bool
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icona)
                        .font(.system(size: 22))
                        .foregroundStyle(selezionato ? Color(hex: "#4A9FD8") : Color(.tertiaryLabel))

                    if let b = badge {
                        Text(b)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.red, in: Capsule())
                            .offset(x: 10, y: -6)
                    }
                }
                Text(etichetta)
                    .font(.system(size: 10))
                    .foregroundStyle(selezionato ? Color(hex: "#4A9FD8") : Color(.tertiaryLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .buttonStyle(.plain)
    }
}
