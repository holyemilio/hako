import Foundation
import SwiftUI

// MARK: - Color from Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Enums

enum TipoDispensa: String, CaseIterable, Codable, Identifiable {
    case dispensa = "Dispensa"
    case frigo = "Frigo"
    case freezer = "Freezer"
    case cantina = "Cantina"
    case magazzino = "Magazzino"
    case bagno = "Bagno"

    var id: String { rawValue }

    var icona: String {
        switch self {
        case .dispensa: return "square.grid.2x2"
        case .frigo: return "refrigerator"
        case .freezer: return "snowflake"
        case .cantina: return "house"
        case .magazzino: return "shippingbox"
        case .bagno: return "drop.fill"
        }
    }

    var categorieAmmesse: [Categoria] {
        switch self {
        case .dispensa: return [.carboidrati, .proteine, .latticini, .conserveESalse, .bevande, .fruttaEVerdura]
        case .frigo: return [.latticini, .proteine, .fruttaEVerdura, .conserveESalse, .bevande]
        case .freezer: return [.proteine, .fruttaEVerdura, .carboidrati, .latticini]
        case .cantina: return [.bevande, .conserveESalse, .fruttaEVerdura, .proteine]
        case .magazzino: return [.puliziaCasa, .igiene, .bevande, .carboidrati, .conserveESalse]
        case .bagno: return [.igiene, .puliziaCasa]
        }
    }
}

enum Categoria: String, CaseIterable, Codable, Identifiable {
    case carboidrati = "Carboidrati"
    case proteine = "Proteine"
    case latticini = "Latticini"
    case fruttaEVerdura = "Frutta e verdura"
    case conserveESalse = "Conserve e salse"
    case bevande = "Bevande"
    case puliziaCasa = "Pulizia casa"
    case igiene = "Igiene persona"

    var id: String { rawValue }

    var colore: Color {
        switch self {
        case .carboidrati: return Color(hex: "#D9B35A")
        case .proteine: return Color(hex: "#E8826F")
        case .latticini: return Color(hex: "#6FB1E0")
        case .fruttaEVerdura: return Color(hex: "#8DB38B")
        case .conserveESalse: return Color(hex: "#EBA25A")
        case .bevande: return Color(hex: "#A58FD6")
        case .puliziaCasa: return Color(hex: "#4FB7A8")
        case .igiene: return Color(hex: "#E39AB0")
        }
    }

    var formaPredefinita: FormaConfezione {
        switch self {
        case .carboidrati: return .scatola
        case .proteine: return .lattina
        case .latticini: return .bottiglia
        case .fruttaEVerdura: return .busta
        case .conserveESalse: return .vasetto
        case .bevande: return .bottiglia
        case .puliziaCasa: return .flacone
        case .igiene: return .flacone
        }
    }
}

enum FormaConfezione: String, CaseIterable, Codable, Identifiable {
    case pasta = "pasta"
    case barattolo = "barattolo"
    case bottiglia = "bottiglia"
    case lattina = "lattina"
    case scatola = "scatola"
    case busta = "busta"
    case vasetto = "vasetto"
    case flacone = "flacone"
    case rotolo = "rotolo"

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .pasta: return "Pacco pasta"
        case .barattolo: return "Barattolo"
        case .bottiglia: return "Bottiglia"
        case .lattina: return "Lattina"
        case .scatola: return "Scatola"
        case .busta: return "Busta"
        case .vasetto: return "Vasetto"
        case .flacone: return "Flacone"
        case .rotolo: return "Rotolo"
        }
    }

    var sfSymbol: String {
        switch self {
        case .pasta: return "rectangle.compress.vertical"
        case .barattolo: return "cylinder"
        case .bottiglia: return "drop.fill"
        case .lattina: return "cylinder.fill"
        case .scatola: return "cube.box"
        case .busta: return "bag.fill"
        case .vasetto: return "jar"
        case .flacone: return "flask.fill"
        case .rotolo: return "toilet.fill"
        }
    }
}

enum VisibilitaDispensa: String, Codable {
    case tuttaLaCasa = "Tutta la casa"
    case soloMia = "Solo mia"
}

// MARK: - Models

struct Persona: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var nome: String
    var iniziale: String { String(nome.prefix(1)).uppercased() }
}

struct Scomparto: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var nome: String
    var proprietarioID: UUID?
    var isPrivato: Bool { proprietarioID != nil }
}

struct Dispensa: Identifiable, Codable {
    var id: UUID = UUID()
    var nome: String
    var tipo: TipoDispensa
    var visibilita: VisibilitaDispensa = .tuttaLaCasa
    var scomparti: [Scomparto] = []
    var proprietarioID: UUID?

    var isCondivisa: Bool { visibilita == .tuttaLaCasa }
    var icona: String { tipo.icona }
}

struct Prodotto: Identifiable, Codable {
    var id: UUID = UUID()
    var nome: String
    var categoria: Categoria
    var forma: FormaConfezione
    var dispensaID: UUID
    var scompartoID: UUID
    var scadenza: Date?
    var nonScade: Bool = false
    var livello: Double = 1.0
    var congelato: Bool = false
    var scadenzaOriginale: Date?
    var scadenzaFreezer: Date?
    var dataAggiunta: Date = Date()
    var proprietarioID: UUID?

    var isScaduto: Bool {
        guard let s = scadenza, !nonScade else { return false }
        return s < Date()
    }

    var isInScadenzaSettimana: Bool {
        guard let s = scadenza, !nonScade else { return false }
        let giorni = Calendar.current.dateComponents([.day], from: Date(), to: s).day ?? 0
        return giorni >= 0 && giorni <= 7
    }

    var coloreCategoria: Color { categoria.colore }

    var badgeColore: Color? {
        if isScaduto { return .red }
        if isInScadenzaSettimana { return .orange }
        return nil
    }
}

// MARK: - Demo Data

extension Dispensa {
    static func demo(persone: [Persona]) -> [Dispensa] {
        let emilioID = persone.first?.id ?? UUID()

        var d1 = Dispensa(nome: "Cucina", tipo: .dispensa)
        d1.scomparti = [
            Scomparto(nome: "Ripiano alto"),
            Scomparto(nome: "Ripiano sinistro"),
            Scomparto(nome: "Ripiano destro"),
            Scomparto(nome: "Cassetto basso", proprietarioID: emilioID)
        ]

        var d2 = Dispensa(nome: "Frigo", tipo: .frigo)
        d2.scomparti = [
            Scomparto(nome: "Ripiano alto"),
            Scomparto(nome: "Ripiano basso"),
            Scomparto(nome: "Cassetto verdure")
        ]

        var d3 = Dispensa(nome: "Freezer", tipo: .freezer)
        d3.scomparti = [
            Scomparto(nome: "Cassetto 1"),
            Scomparto(nome: "Cassetto 2"),
            Scomparto(nome: "Cassetto 3")
        ]

        var d4 = Dispensa(nome: "Bagno", tipo: .bagno, visibilita: .soloMia, proprietarioID: emilioID)
        d4.scomparti = [Scomparto(nome: "Mensola doccia"), Scomparto(nome: "Cassetto")]

        var d5 = Dispensa(nome: "Cantina", tipo: .cantina)
        d5.scomparti = [Scomparto(nome: "Scaffale destro"), Scomparto(nome: "Scaffale sinistro")]

        return [d1, d2, d3, d4, d5]
    }
}

extension Prodotto {
    static func demo(dispense: [Dispensa]) -> [Prodotto] {
        guard dispense.count >= 3 else { return [] }
        let cucina = dispense[0], frigo = dispense[1], freezer = dispense[2]
        let cal = Calendar.current
        let oggi = Date()
        func data(_ giorni: Int) -> Date { cal.date(byAdding: .day, value: giorni, to: oggi)! }

        var prodotti: [Prodotto] = []
        let rialto = cucina.scomparti[0]
        let rsinistro = cucina.scomparti[1]
        let rdestro = cucina.scomparti[2]

        prodotti += [
            Prodotto(nome: "Biscotti frollini", categoria: .carboidrati, forma: .scatola, dispensaID: cucina.id, scompartoID: rialto.id, scadenza: data(3), livello: 1.0),
            Prodotto(nome: "Penne Rigate Barilla", categoria: .carboidrati, forma: .pasta, dispensaID: cucina.id, scompartoID: rsinistro.id, scadenza: data(200), livello: 0.5),
            Prodotto(nome: "Spaghetti n.5", categoria: .carboidrati, forma: .pasta, dispensaID: cucina.id, scompartoID: rsinistro.id, scadenza: data(180), livello: 1.0),
            Prodotto(nome: "Riso Carnaroli", categoria: .carboidrati, forma: .scatola, dispensaID: cucina.id, scompartoID: rsinistro.id, scadenza: data(300), livello: 0.25),
            Prodotto(nome: "Pesto alla genovese", categoria: .conserveESalse, forma: .vasetto, dispensaID: cucina.id, scompartoID: rdestro.id, scadenza: data(-2), livello: 0.8),
            Prodotto(nome: "Tonno all'olio d'oliva", categoria: .proteine, forma: .lattina, dispensaID: cucina.id, scompartoID: rdestro.id, scadenza: data(400), livello: 1.0),
            Prodotto(nome: "Passata di pomodoro", categoria: .conserveESalse, forma: .barattolo, dispensaID: cucina.id, scompartoID: rdestro.id, scadenza: data(500), livello: 1.0),
            Prodotto(nome: "Latte UHT intero", categoria: .latticini, forma: .bottiglia, dispensaID: cucina.id, scompartoID: rialto.id, scadenza: data(12), livello: 1.0),
        ]

        let frialto = frigo.scomparti[0]
        let fribbasso = frigo.scomparti[1]
        prodotti += [
            Prodotto(nome: "Yogurt greco", categoria: .latticini, forma: .vasetto, dispensaID: frigo.id, scompartoID: frialto.id, scadenza: data(5), livello: 0.75),
            Prodotto(nome: "Mozzarella", categoria: .latticini, forma: .busta, dispensaID: frigo.id, scompartoID: fribbasso.id, scadenza: data(2), livello: 1.0),
            Prodotto(nome: "Succo di arancia", categoria: .bevande, forma: .bottiglia, dispensaID: frigo.id, scompartoID: frialto.id, scadenza: data(10), livello: 0.6),
        ]

        var pizzaMarg = Prodotto(nome: "Pizza margherita", categoria: .carboidrati, forma: .busta, dispensaID: freezer.id, scompartoID: freezer.scomparti[0].id, scadenza: data(70), livello: 1.0)
        pizzaMarg.congelato = true
        var piselli = Prodotto(nome: "Piselli surgelati", categoria: .fruttaEVerdura, forma: .busta, dispensaID: freezer.id, scompartoID: freezer.scomparti[0].id, scadenza: data(20), livello: 0.75)
        piselli.congelato = true
        var pollo = Prodotto(nome: "Petto di pollo", categoria: .proteine, forma: .busta, dispensaID: freezer.id, scompartoID: freezer.scomparti[1].id, scadenza: data(90), livello: 1.0)
        pollo.congelato = true
        var gelato = Prodotto(nome: "Gelato alla vaniglia", categoria: .latticini, forma: .scatola, dispensaID: freezer.id, scompartoID: freezer.scomparti[2].id, scadenza: data(52), livello: 0.5)
        gelato.congelato = true

        prodotti += [pizzaMarg, piselli, pollo, gelato]
        return prodotti
    }
}
