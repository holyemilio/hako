import SwiftUI

/// Icona colorata di un prodotto con eventuale badge scadenza e fiocco freezer
struct ProdottoIcona: View {
    let prodotto: Prodotto
    var size: CGFloat = 52

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(prodotto.coloreCategoria.opacity(prodotto.congelato ? 0.18 : 0.15))
                .frame(width: size, height: size)

            Image(systemName: prodotto.forma.sfSymbol)
                .resizable()
                .scaledToFit()
                .padding(size * 0.18)
                .foregroundStyle(prodotto.congelato ? Color(hex: "#6FB1E0") : prodotto.coloreCategoria)
                .frame(width: size, height: size)

            // Badge scadenza
            if let colore = prodotto.badgeColore {
                Circle()
                    .fill(colore)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .overlay(
                        Circle().strokeBorder(.white, lineWidth: 1.2)
                    )
                    .offset(x: size * 0.06, y: -(size * 0.06))
            }

            // Fiocco freezer
            if prodotto.congelato {
                Image(systemName: "snowflake")
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundStyle(Color(hex: "#6FB1E0"))
                    .frame(width: size * 0.3, height: size * 0.3)
                    .background(.white.opacity(0.85))
                    .clipShape(Circle())
                    .offset(x: -(size * 0.04), y: -(size * 0.04))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(width: size, height: size)
    }
}

/// Livello-barra sotto l'icona nella dispensa
struct LivelloBar: View {
    let livello: Double
    let colore: Color
    var width: CGFloat = 44

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(colore.opacity(0.18))
                Capsule().fill(colore)
                    .frame(width: max(4, geo.size.width * livello))
            }
        }
        .frame(width: width, height: 4)
    }
}

/// Cella prodotto nella griglia della dispensa
struct ProdottoCella: View {
    let prodotto: Prodotto
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ProdottoIcona(prodotto: prodotto, size: 52)
                LivelloBar(livello: prodotto.livello, colore: prodotto.coloreCategoria)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Legenda Pill

struct LegendaPill: View {
    let categoria: Categoria

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(categoria.colore).frame(width: 10, height: 10)
            Text(categoria.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
