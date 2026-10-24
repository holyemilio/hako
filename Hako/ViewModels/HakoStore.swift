import SwiftUI
import Combine
import UserNotifications

@MainActor
final class HakoStore: ObservableObject {

    // MARK: - Stato

    @Published var dispense: [Dispensa] = []
    @Published var prodotti: [Prodotto] = []
    @Published var persone: [Persona] = []
    @Published var dispensaSelezionataID: UUID?
    @Published var primoAvvio: Bool = true

    private let storeKey = "hako_store_v1"

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Computed

    var dispensaSelezionata: Dispensa? {
        dispense.first { $0.id == dispensaSelezionataID }
    }

    func prodotti(in dispensa: Dispensa) -> [Prodotto] {
        prodotti.filter { $0.dispensaID == dispensa.id }
    }

    func prodotti(in scomparto: Scomparto) -> [Prodotto] {
        prodotti.filter { $0.scompartoID == scomparto.id }
    }

    func dispensa(for prodotto: Prodotto) -> Dispensa? {
        dispense.first { $0.id == prodotto.dispensaID }
    }

    func scomparto(for prodotto: Prodotto) -> Scomparto? {
        dispense.flatMap { $0.scomparti }.first { $0.id == prodotto.scompartoID }
    }

    func persona(id: UUID?) -> Persona? {
        guard let id else { return nil }
        return persone.first { $0.id == id }
    }

    var scadutiCount: Int { prodotti.filter { $0.isScaduto }.count }
    var inScadenzaSettimanaCount: Int { prodotti.filter { $0.isInScadenzaSettimana }.count }

    // MARK: - Prodotti per Scadenze

    var prodottiScaduti: [Prodotto] {
        prodotti.filter { $0.isScaduto }.sorted { ($0.scadenza ?? .distantPast) < ($1.scadenza ?? .distantPast) }
    }

    var prodottiQuestaSett: [Prodotto] {
        prodotti.filter { $0.isInScadenzaSettimana && !$0.isScaduto }
            .sorted { ($0.scadenza ?? .distantFuture) < ($1.scadenza ?? .distantFuture) }
    }

    var prodottiPiuAvanti: [Prodotto] {
        prodotti.filter {
            guard let s = $0.scadenza else { return $0.nonScade }
            let giorni = Calendar.current.dateComponents([.day], from: Date(), to: s).day ?? 0
            return giorni > 7 && !$0.isScaduto
        }.sorted { ($0.scadenza ?? .distantFuture) < ($1.scadenza ?? .distantFuture) }
    }

    // MARK: - Actions - Dispensa

    func aggiungiDispensa(_ dispensa: Dispensa) {
        dispense.append(dispensa)
        if dispense.count == 1 { dispensaSelezionataID = dispensa.id }
        save()
    }

    func eliminaDispensa(_ dispensa: Dispensa) {
        prodotti.removeAll { $0.dispensaID == dispensa.id }
        dispense.removeAll { $0.id == dispensa.id }
        if dispensaSelezionataID == dispensa.id {
            dispensaSelezionataID = dispense.first?.id
        }
        save()
    }

    func aggiornaScomparti(_ scomparti: [Scomparto], in dispensaID: UUID) {
        guard let idx = dispense.firstIndex(where: { $0.id == dispensaID }) else { return }
        dispense[idx].scomparti = scomparti
        save()
    }

    // MARK: - Actions - Prodotto

    func aggiungiProdotto(_ prodotto: Prodotto) {
        prodotti.append(prodotto)
        save()
        scheduleNotifica(per: prodotto)
    }

    func aggiornaProdotto(_ prodotto: Prodotto) {
        guard let idx = prodotti.firstIndex(where: { $0.id == prodotto.id }) else { return }
        prodotti[idx] = prodotto
        save()
    }

    func eliminaProdotto(_ prodotto: Prodotto) {
        prodotti.removeAll { $0.id == prodotto.id }
        save()
    }

    func congelaToggle(_ prodotto: Prodotto) {
        guard let idx = prodotti.firstIndex(where: { $0.id == prodotto.id }) else { return }
        var p = prodotti[idx]
        if p.congelato {
            p.congelato = false
            p.scadenza = p.scadenzaOriginale
            p.scadenzaOriginale = nil
            p.scadenzaFreezer = nil
        } else {
            p.congelato = true
            p.scadenzaOriginale = p.scadenza
            if let s = p.scadenza {
                p.scadenzaFreezer = Calendar.current.date(byAdding: .month, value: 3, to: s)
                p.scadenza = p.scadenzaFreezer
            }
        }
        prodotti[idx] = p
        save()
    }

    func spostaProducto(_ prodotto: Prodotto, a scompartoID: UUID, in dispensaID: UUID) {
        guard let idx = prodotti.firstIndex(where: { $0.id == prodotto.id }) else { return }
        prodotti[idx].scompartoID = scompartoID
        prodotti[idx].dispensaID = dispensaID
        save()
    }

    // MARK: - Actions - Persone

    func aggiungiPersona(_ nome: String) {
        guard !nome.isEmpty else { return }
        persone.append(Persona(nome: nome))
        save()
    }

    func rimuoviPersona(_ persona: Persona) {
        persone.removeAll { $0.id == persona.id }
        save()
    }

    // MARK: - Demo Data

    func caricaDemo() {
        persone = [Persona(nome: "Emilio"), Persona(nome: "Anna"), Persona(nome: "Luca")]
        let d = Dispensa.demo(persone: persone)
        dispense = d
        prodotti = Prodotto.demo(dispense: d)
        dispensaSelezionataID = d.first?.id
        primoAvvio = false
        save()
    }

    func completaPrimoAvvio() {
        primoAvvio = false
        save()
    }

    // MARK: - Persistence

    private struct StoreData: Codable {
        var dispense: [Dispensa]
        var prodotti: [Prodotto]
        var persone: [Persona]
        var dispensaSelezionataID: UUID?
        var primoAvvio: Bool
    }

    func save() {
        let data = StoreData(
            dispense: dispense,
            prodotti: prodotti,
            persone: persone,
            dispensaSelezionataID: dispensaSelezionataID,
            primoAvvio: primoAvvio
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storeKey)
        }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storeKey),
              let decoded = try? JSONDecoder().decode(StoreData.self, from: data) else {
            primoAvvio = true
            return
        }
        dispense = decoded.dispense
        prodotti = decoded.prodotti
        persone = decoded.persone
        dispensaSelezionataID = decoded.dispensaSelezionataID
        primoAvvio = decoded.primoAvvio
    }

    // MARK: - Notifications

    func richiediPermessoNotifiche() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func scheduleNotifica(per prodotto: Prodotto) {
        guard let scadenza = prodotto.scadenza else { return }
        let center = UNUserNotificationCenter.current()

        // Notifica 3 giorni prima
        let avviso = Calendar.current.date(byAdding: .day, value: -3, to: scadenza)!
        if avviso > Date() {
            let content = UNMutableNotificationContent()
            content.title = "In scadenza"
            content.body = "\(prodotto.nome) scade tra 3 giorni."
            content.sound = .default
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: avviso)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "avviso_\(prodotto.id)", content: content, trigger: trigger)
            center.add(req)
        }

        // Notifica il giorno della scadenza
        if scadenza > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Scaduto oggi"
            content.body = "\(prodotto.nome) scade oggi."
            content.sound = .default
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scadenza)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "scadenza_\(prodotto.id)", content: content, trigger: trigger)
            center.add(req)
        }
    }
}
