import SwiftUI

public struct UserGuideView: View {
    @ObservedObject var store: BirthdayStore
    @State private var searchText = ""
    @State private var selectedFilter: GuideCategory = .all
    @State private var expandedTopicId: String? = nil
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    public enum GuideCategory: String, CaseIterable, Identifiable {
        case all
        case basics
        case events
        case giftsAndVenues
        case insightsAndCalendar
        case privacyAndBackup
        case customization
        
        public var id: String { rawValue }
        
        public func localizedName(for lang: AppLanguage) -> String {
            switch lang {
            case .italian:
                switch self {
                case .all: return "Tutti"
                case .basics: return "🌟 Base"
                case .events: return "🎂 Ricorrenze & Feste"
                case .giftsAndVenues: return "🎁 Regali & Luoghi"
                case .insightsAndCalendar: return "📊 Calendario & Dati"
                case .privacyAndBackup: return "🔒 Privacy & Sync"
                case .customization: return "🎨 Stile & Widget"
                }
            case .english:
                switch self {
                case .all: return "All"
                case .basics: return "🌟 Basics"
                case .events: return "🎂 Events & Parties"
                case .giftsAndVenues: return "🎁 Gifts & Venues"
                case .insightsAndCalendar: return "📊 Calendar & Data"
                case .privacyAndBackup: return "🔒 Privacy & Sync"
                case .customization: return "🎨 Style & Widgets"
                }
            case .spanish:
                switch self {
                case .all: return "Todos"
                case .basics: return "🌟 Básicos"
                case .events: return "🎂 Eventos y Fiestas"
                case .giftsAndVenues: return "🎁 Regalos y Lugares"
                case .insightsAndCalendar: return "📊 Calendario y Datos"
                case .privacyAndBackup: return "🔒 Privacidad y Sync"
                case .customization: return "🎨 Estilo y Widgets"
                }
            case .french:
                switch self {
                case .all: return "Tout"
                case .basics: return "🌟 Essentiels"
                case .events: return "🎂 Événements & Fêtes"
                case .giftsAndVenues: return "🎁 Cadeaux & Lieux"
                case .insightsAndCalendar: return "📊 Calendrier & Données"
                case .privacyAndBackup: return "🔒 Sécurité & Sync"
                case .customization: return "🎨 Style & Widgets"
                }
            case .german:
                switch self {
                case .all: return "Alle"
                case .basics: return "🌟 Grundlagen"
                case .events: return "🎂 Ereignisse & Feiern"
                case .giftsAndVenues: return "🎁 Geschenke & Orte"
                case .insightsAndCalendar: return "📊 Kalender & Daten"
                case .privacyAndBackup: return "🔒 Datenschutz & Sync"
                case .customization: return "🎨 Design & Widgets"
                }
            case .portuguese:
                switch self {
                case .all: return "Todos"
                case .basics: return "🌟 Básico"
                case .events: return "🎂 Eventos & Festas"
                case .giftsAndVenues: return "🎁 Presentes & Locais"
                case .insightsAndCalendar: return "📊 Calendário & Dados"
                case .privacyAndBackup: return "🔒 Privacidade & Sync"
                case .customization: return "🎨 Estilo & Widgets"
                }
            }
        }
    }
    
    public struct GuideTopic: Identifiable {
        public let id: String
        public let category: GuideCategory
        public let icon: String
        public let iconColor: Color
        public let title: String
        public let subtitle: String
        public let bulletPoints: [String]
        public let proTip: String?
    }
    
    private var lang: AppLanguage {
        store.currentLanguage
    }
    
    private var topics: [GuideTopic] {
        switch lang {
        case .italian:
            return italianTopics()
        case .english:
            return englishTopics()
        case .spanish:
            return spanishTopics()
        case .french:
            return frenchTopics()
        case .german:
            return germanTopics()
        case .portuguese:
            return portugueseTopics()
        }
    }
    
    private var filteredTopics: [GuideTopic] {
        topics.filter { topic in
            let matchesCategory = (selectedFilter == .all || topic.category == selectedFilter)
            let matchesQuery = searchText.isEmpty ||
                topic.title.localizedCaseInsensitiveContains(searchText) ||
                topic.subtitle.localizedCaseInsensitiveContains(searchText) ||
                topic.bulletPoints.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            return matchesCategory && matchesQuery
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Banner
                headerBanner
                
                // Category Filter Pills
                filterPillsScrollView
                
                // Topics List
                if filteredTopics.isEmpty {
                    emptySearchState
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredTopics) { topic in
                            topicCard(topic)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(CandleTheme.background.ignoresSafeArea())
        .navigationTitle(store.tr(.guideSectionTitle))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: localizedSearchPrompt)
    }
    
    // MARK: - Subviews
    
    private var headerBanner: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(store.accentGradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: store.accentPrimary.opacity(0.35), radius: 10, y: 4)
                
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(localizedHeaderTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(store.tr(.guideSectionSubtitle))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
    
    private var filterPillsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GuideCategory.allCases) { cat in
                    let isSelected = (selectedFilter == cat)
                    Button {
                        CandleTheme.hapticSelection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedFilter = cat
                        }
                    } label: {
                        Text(cat.localizedName(for: lang))
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                isSelected
                                    ? store.accentPrimary
                                    : Color.primary.opacity(0.05)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func topicCard(_ topic: GuideTopic) -> some View {
        let isExpanded = (expandedTopicId == topic.id)
        
        return VStack(alignment: .leading, spacing: 12) {
            // Card Header
            Button {
                CandleTheme.hapticSelection()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedTopicId = nil
                    } else {
                        expandedTopicId = topic.id
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(topic.iconColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: topic.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(topic.iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(topic.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(topic.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .font(.system(size: 20))
                        .foregroundColor(isExpanded ? store.accentPrimary : .secondary.opacity(0.6))
                }
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .padding(.vertical, 2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(topic.bulletPoints, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(topic.iconColor)
                                Text(bullet)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.primary.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    if let tip = topic.proTip {
                        HStack(alignment: .top, spacing: 8) {
                            Text("💡")
                                .font(.system(size: 14))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(localizedProTipLabel)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(store.accentPrimary)
                                Text(tip)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(store.accentPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.top, 4)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    private var emptySearchState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 38))
                .foregroundColor(.secondary)
                .padding(.top, 30)
            Text(localizedEmptyTitle)
                .font(.system(size: 16, weight: .semibold))
            Text(localizedEmptyDesc)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Localized Helpers
    
    private var localizedHeaderTitle: String {
        switch lang {
        case .italian: return "Tutto su Candle"
        case .english: return "All About Candle"
        case .spanish: return "Todo sobre Candle"
        case .french: return "Tout sur Candle"
        case .german: return "Alles über Candle"
        case .portuguese: return "Tudo sobre o Candle"
        }
    }
    
    private var localizedSearchPrompt: String {
        switch lang {
        case .italian: return "Cerca nelle istruzioni..."
        case .english: return "Search guide..."
        case .spanish: return "Buscar en la guía..."
        case .french: return "Rechercher dans le guide..."
        case .german: return "In der Anleitung suchen..."
        case .portuguese: return "Buscar no guia..."
        }
    }
    
    private var localizedProTipLabel: String {
        switch lang {
        case .italian: return "Consiglio utile:"
        case .english: return "Pro Tip:"
        case .spanish: return "Consejo útil:"
        case .french: return "Astuce pro :"
        case .german: return "Praxistipp:"
        case .portuguese: return "Dica útil:"
        }
    }
    
    private var localizedEmptyTitle: String {
        switch lang {
        case .italian: return "Nessun argomento trovato"
        case .english: return "No topics found"
        case .spanish: return "No se encontraron temas"
        case .french: return "Aucun sujet trouvé"
        case .german: return "Keine Themen gefunden"
        case .portuguese: return "Nenhum tópico encontrado"
        }
    }
    
    private var localizedEmptyDesc: String {
        switch lang {
        case .italian: return "Prova a cercare un'altra parola chiave (es. notifiche, regali, calendario)"
        case .english: return "Try searching for another term (e.g. notifications, gifts, calendar)"
        case .spanish: return "Intenta buscar otro término (ej. notificaciones, regalos, calendario)"
        case .french: return "Essayez de rechercher un autre terme (ex. rappels, cadeaux, calendrier)"
        case .german: return "Versuche einen anderen Begriff (z. B. Erinnerungen, Geschenke, Kalender)"
        case .portuguese: return "Tente pesquisar outro termo (ex. notificações, presentes, calendário)"
        }
    }
    
    // MARK: - Complete Language Topics
    
    private func italianTopics() -> [GuideTopic] {
        [
            GuideTopic(
                id: "dashboard",
                category: .basics,
                icon: "sparkles",
                iconColor: store.accentPrimary,
                title: "Dashboard & Hero Card",
                subtitle: "La panoramica principale per avere sempre sott'occhio i prossimi festeggiamenti.",
                bulletPoints: [
                    "Hero Card in primo piano: mostra la persona più vicina a compiere gli anni con foto, conto alla rovescia ed età in arrivo.",
                    "Anello di avanzamento: il cerchio attorno all'avatar si completa man mano che la data si avvicina.",
                    "Pulsante Festeggia ✨: esplosione immediata di coriandoli festosi con feedback aptico per celebrare all'istante.",
                    "Filtri temporali rapidi: seleziona 'Tutti', 'Questo mese' o 'Entro fine anno' per pianificare i tuoi auguri.",
                    "Gesti veloci: trascina verso destra per aprire le Impostazioni o verso sinistra per visualizzare le Statistiche."
                ],
                proTip: "Tocca qualsiasi scheda per aprire i dettagli completi, i ricordi, le idee regalo e i luoghi di festa."
            ),
            GuideTopic(
                id: "event_types",
                category: .events,
                icon: "calendar.badge.clock",
                iconColor: .orange,
                title: "Tipi di Ricorrenze & Frequenze",
                subtitle: "Gestisci compleanni, anniversari, onomastici e date speciali.",
                bulletPoints: [
                    "Compleanni 🎂: calcolo automatico dell'età, del compleanno successivo e del giorno della settimana.",
                    "Anniversari ❤️: supporto per anniversari annuali e 'Mesiversari' mensili per festeggiare ogni mese.",
                    "Onomastici 🌟: festeggia il nome delle persone care senza dover necessariamente conoscere l'anno di nascita.",
                    "Eventi Speciali ✨: ricorrenze una-tantum (es. laurea, festa) o eventi che si ripetono periodicamente.",
                    "Opzione 'Anno di nascita sconosciuto': permette di memorizzare solo giorno e mese senza visualizzare l'età."
                ],
                proTip: "Nei dettagli degli anniversari puoi visualizzare quale traguardo o mese di coppia viene raggiunto."
            ),
            GuideTopic(
                id: "categories",
                category: .basics,
                icon: "tag.fill",
                iconColor: .purple,
                title: "Categorie & Cerchie Sociali",
                subtitle: "Organizza e raggruppa i contatti secondo i tuoi cerchi di vita.",
                bulletPoints: [
                    "Categorie predefinite: Famiglia 🏡, Amici 🎉, Lavoro 💼, Partner ❤️, Altro 🎈.",
                    "Categorie personalizzate infinite: premi il tasto '+' a destra nella barra per creare categorie su misura (es. Calcetto, Università, Parenti).",
                    "Ordinamento Drag & Drop: personalizza l'ordine delle categorie trascinandole nella schermata 'Ordina Categorie' in Impostazioni.",
                    "Filtro istantaneo: toccando una categoria nella barra superiore, l'elenco si aggiorna mostrando solo i contatti di quel gruppo."
                ],
                proTip: "Le categorie personalizzate possono essere eliminate o riordinate tenendole premute a lungo."
            ),
            GuideTopic(
                id: "zodiac_trivia",
                category: .events,
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Astrologia, Pietre di Nascita & Curiosità",
                subtitle: "Dettagli affascinanti e curiosità storiche calcolati automaticamente.",
                bulletPoints: [
                    "Segno Zodiacale Occidentale ♈: calcolato automaticamente da giorno e mese con simbolo ed elemento.",
                    "Zodiaco Cinese 🐉: ricavato dall'anno di nascita per scoprire l'animale dell'oroscopo orientale.",
                    "Pietra di Nascita (Birthstone) 💎: ogni mese ha la sua gemma portafortuna con significato tradizionale.",
                    "Personaggi celebri e fatti storici: scopri chi è nato lo stesso giorno e gli avvenimenti storici di quella data."
                ],
                proTip: "Queste curiosità sono perfette per rompere il ghiaccio o scrivere auguri unici e originali!"
            ),
            GuideTopic(
                id: "blow_candle",
                category: .events,
                icon: "flame.fill",
                iconColor: .red,
                title: "Spegni la Candela (Giorno del Compleanno)",
                subtitle: "Un rito magico e interattivo che prende vita il giorno della festa.",
                bulletPoints: [
                    "Attivazione automatica: se un contatto compie gli anni oggi, nella sua scheda appare una candela accesa animata.",
                    "Esprimi un desiderio: tocca il pulsante per spegnere la candela.",
                    "Animazione realistica: la fiamma si spegne con fumo leggero, vibrazione aptica e un'esplosione di coriandoli festosi."
                ],
                proTip: "Puoi rivivere l'esperienza e spegnere la candela tutte le volte che vuoi durante la giornata."
            ),
            GuideTopic(
                id: "gifts_tracker",
                category: .giftsAndVenues,
                icon: "gift.fill",
                iconColor: .pink,
                title: "Tracker Idee Regalo & Budget",
                subtitle: "Appunta idee, monitora le spese e non farti mai cogliere impreparato.",
                bulletPoints: [
                    "Scheda regalo completa: aggiungi titolo, prezzo indicativo, note, data (mese.anno) e link al negozio online.",
                    "Modifica rapida con matita: tocca l'icona della matita accanto al cestino per aggiornare qualsiasi dettaglio del regalo.",
                    "Data mese.anno: assegna mese e anno a ogni dono per ricordare esattamente quando è stato pianificato o donato.",
                    "Stato d'acquisto: segna i regali come 'Acquistati' con una spunta verde per tenere traccia delle idee da comprare.",
                    "Regali Riservati: attiva l'opzione 'Regalo Privato' per proteggere le sorprese con Face ID/Touch ID affinché nessuno possa sbirciare.",
                    "Controllo del budget: visualizza il totale della spesa e tocca per espandere tutti i doni nelle Statistiche dell'app."
                ],
                proTip: "Toccando il link web del regalo puoi aprire direttamente la pagina del negozio per completare l'acquisto."
            ),
            GuideTopic(
                id: "smart_wishes",
                category: .events,
                icon: "wand.and.stars",
                iconColor: .teal,
                title: "Auguri Intelligenti (Smart Wishes)",
                subtitle: "Trova sempre le parole perfette per ogni occasione e personalità.",
                bulletPoints: [
                    "Toni di voce diversificati: seleziona auguri Affettuosi, Divertenti, Formali o Brevi & Diretti.",
                    "Personalizzazione dinamica: il testo include automaticamente il nome del festeggiato e l'età raggiunta.",
                    "Copia con 1 tap: copia istantaneamente il testo per incollarlo su WhatsApp, Instagram, Telegram o Messaggi.",
                    "Modelli personalizzati: salva e conserva i tuoi messaggi preferiti per riutilizzarli negli anni futuri."
                ],
                proTip: "Puoi modificare il testo generato prima di inviarlo per aggiungere un tocco ancora più personale."
            ),
            GuideTopic(
                id: "celebration_map",
                category: .giftsAndVenues,
                icon: "map.fill",
                iconColor: .green,
                title: "Mappa dei Festeggiamenti & Ristoranti",
                subtitle: "Conserva il ricordo dei locali e delle location dove hai festeggiato.",
                bulletPoints: [
                    "Salvataggio locali: per ogni persona puoi salvare ristoranti, parchi, pub o location preferite.",
                    "Celebration Map: apri la mappa interattiva a schermo intero (icona mappa in home) per vedere tutti i luoghi su Apple Maps.",
                    "Geolocalizzazione GPS: usa il tasto 'Posizione Attuale' quando sei al locale per salvare le coordinate esatte.",
                    "Indicazioni stradali: tocca 'Apri in Mappe' per avviare il navigatore verso il locale scelto."
                ],
                proTip: "I luoghi possono essere filtrati sulla mappa per compleanni, anniversari o prossimi eventi."
            ),
            GuideTopic(
                id: "memory_photos",
                category: .events,
                icon: "photo.stack.fill",
                iconColor: .blue,
                title: "Foto Ricordo in Stile Polaroid & Avatar",
                subtitle: "Collezione visiva orizzontale di fotografie delle feste con didascalie ed espansione a schermo intero.",
                bulletPoints: [
                    "Galleria Polaroid orizzontale 📸: sfoglia gli scatti più belli delle feste passate direttamente nella scheda del contatto.",
                    "Didascalie e Date ✍️: assegna ad ogni scatto un pensiero o ricordo speciale e vedi la data di aggiunta.",
                    "Anteprima a Schermo Intero: tocca qualsiasi foto per ammirarla ingrandita a tutto schermo.",
                    "Avatar Ingrandibile: tocca l'avatar principale del contatto per visualizzarlo in alta definizione."
                ],
                proTip: "Puoi scattare una foto al momento o sceglierne più di una insieme dal rullino fotografico!"
            ),
            GuideTopic(
                id: "calendar",
                category: .insightsAndCalendar,
                icon: "calendar",
                iconColor: .indigo,
                title: "Calendario dei Compleanni Integrato",
                subtitle: "Una panoramica visiva completa mese per mese o su tutto l'anno.",
                bulletPoints: [
                    "Vista a griglia mensile: i giorni con ricorrenze hanno un indicatore colorato; toccando il giorno vedi tutti gli eventi in programma.",
                    "Vista panoramica annuale: visualizza tutti i 12 mesi contemporaneamente per individuare i periodi più carichi.",
                    "Aggiunta rapida: tocca qualsiasi data sul calendario per creare direttamente un nuovo evento in quel giorno.",
                    "Navigazione fluida tra gli anni per pianificare vacanze e celebrazioni future."
                ],
                proTip: "Dalla vista mensile puoi vedere i giorni mancanti a ciascun compleanno del mese selezionato."
            ),
            GuideTopic(
                id: "insights",
                category: .insightsAndCalendar,
                icon: "chart.bar.xaxis",
                iconColor: .purple,
                title: "Statistiche & Analisi (Candle Insights)",
                subtitle: "Esplora metriche, trend e statistiche affascinanti sulla tua cerchia.",
                bulletPoints: [
                    "Progresso Annuale: visualizza la percentuale di celebrazioni passate e rimanenti dell'anno con il countdown al prossimo evento.",
                    "Grafico Mensile Interattivo: istogramma a 12 mesi con il mese corrente in evidenza; tocca una barra per espandere gli eventi.",
                    "Orizzonte Stagionale: scopri la stagione più ricca di feste ed espandi Primavera, Estate, Autunno e Inverno.",
                    "Esploratore Zodiacale: tocca il riquadro zodiacale per analizzare tutti i 12 segni suddivisi nei 4 elementi astrologici.",
                    "Traguardi d'Età: tieni d'occhio chi compirà cifre tonde (18, 30, 40, 50+) con un foglio dedicato.",
                    "Budget Regali & Spesa: tocca il totale speso o le idee in attesa per esplorare tutti i doni acquistati o pianificati, con sblocco Face ID / Touch ID per quelli riservati."
                ],
                proTip: "Tocca qualsiasi persona o evento per aprire direttamente i dettagli. I contatti privati rimangono protetti e si ribloccano quando lasci gli Insights."
            ),
            GuideTopic(
                id: "notifications_widgets",
                category: .customization,
                icon: "bell.badge.fill",
                iconColor: .yellow,
                title: "Notifiche Intelligenti & Widget iOS",
                subtitle: "Promemoria precisi e widget per avere sempre le date in vista.",
                bulletPoints: [
                    "Notifiche lo stesso giorno: promemoria al mattino (all'orario che preferisci) per non dimenticare mai di fare gli auguri.",
                    "Promemoria anticipati: ricevi avvisi con 1, 2, 3 giorni, 1 settimana o 2 settimane di anticipo per preparare il regalo con calma.",
                    "Widget per Schermata Home: widget compatti e medi con i prossimi festeggiati e il conto alla rovescia.",
                    "Widget per Schermata di Blocco e StandBy: tieni d'occhio i compleanni anche a telefono bloccato o in carica.",
                    "Test notifiche: invia una notifica di prova dalle Impostazioni per verificare il funzionamento dei permessi."
                ],
                proTip: "Nelle Impostazioni puoi personalizzare l'orario predefinito in cui ricevere tutti i promemoria."
            ),
            GuideTopic(
                id: "privacy_biometrics",
                category: .privacyAndBackup,
                icon: "lock.shield.fill",
                iconColor: .green,
                title: "Cassaforte Privacy & Face ID / Touch ID",
                subtitle: "Massima riservatezza per contatti sensibili e regali a sorpresa.",
                bulletPoints: [
                    "Contatti Riservati: attiva l'opzione 'Contatto Riservato' per mascherare nome e dettagli sulla schermata principale.",
                    "Sblocco biometrico o con codice: accedi ai dati oscurati tramite Face ID, Touch ID o codice di sblocco dell'iPhone.",
                    "Regali privati: nascondi le idee regalo a sorpresa in modo che nessuno possa vederle usando il tuo telefono.",
                    "Archiviazione 100% locale: i tuoi dati non vengono mai inviati a server di terze parti o tracciati."
                ],
                proTip: "Tocca l'icona del lucchetto in qualsiasi momento per bloccare nuovamente la cassaforte all'istante."
            ),
            GuideTopic(
                id: "sync_backup",
                category: .privacyAndBackup,
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Rubrica, Backup & Sincronizzazione iCloud",
                subtitle: "I tuoi dati sempre al sicuro, esportabili e trasferibili ovunque.",
                bulletPoints: [
                    "Importazione Rubrica: importa con un solo tocco tutti i compleanni già presenti nei contatti del tuo iPhone.",
                    "Backup JSON completo: esporta e condividi l'archivio completo per ripristinarlo su qualsiasi altro dispositivo.",
                    "Esportazione CSV: genera un foglio di calcolo formattato per aprirlo in Excel, Numbers o Google Fogli.",
                    "File Calendario (.ics): esporta un file compatibile con Google Calendar, Apple Calendar e Outlook.",
                    "iCloud Sync: sincronizzazione automatica in background su tutti i tuoi dispositivi Apple collegati allo stesso ID."
                ],
                proTip: "Esegui un backup periodico per conservare in sicurezza le tue note, i regali e i ricordi salvati."
            ),
            GuideTopic(
                id: "customization",
                category: .customization,
                icon: "paintpalette.fill",
                iconColor: store.accentPrimary,
                title: "Palette di Colori & Aspetto dell'App",
                subtitle: "Personalizza Candle per renderlo unico e perfettamente adatto ai tuoi gusti.",
                bulletPoints: [
                    "16 Colori d'Accento: seleziona tra Candle Amber, Sunset Coral, Emerald Mint, Royal Purple, Sapphire Blue, e molti altri.",
                    "Modalità Chiara, Scura o Automatica: Candle si adatta all'aspetto di sistema o alle tue preferenze manuali.",
                    "Colori avatar dedicati: assegna un colore specifico o un gradiente personalizzato a ciascun contatto per riconoscerlo a colpo d'occhio.",
                    "Design nativo e raffinato: animazioni fluide, forme ergonomiche e feedback tattile integrato in ogni interazione."
                ],
                proTip: "Il colore d'accento scelto colora dinamicamente le icone, i pulsanti, i grafici e i widget di Candle."
            )
        ]
    }
    
    private func englishTopics() -> [GuideTopic] {
        [
            GuideTopic(
                id: "dashboard",
                category: .basics,
                icon: "sparkles",
                iconColor: store.accentPrimary,
                title: "Dashboard & Hero Card",
                subtitle: "Your main hub to always keep upcoming celebrations front and center.",
                bulletPoints: [
                    "Prominent Hero Card: showcases the next person celebrating, with their photo, countdown, and upcoming age.",
                    "Progress Ring: the ring around the avatar fills up smoothly as the special day draws closer.",
                    "Celebrate Button ✨: trigger instant celebratory confetti with haptic feedback to celebrate on the spot.",
                    "Quick Timeline Filters: switch between 'All', 'This Month', or 'This Year' to plan ahead.",
                    "Quick Navigation Gestures: swipe right to open Settings or swipe left to access Insights & Analytics."
                ],
                proTip: "Tap any card to view detailed notes, memories, gift ideas, and celebration venues."
            ),
            GuideTopic(
                id: "event_types",
                category: .events,
                icon: "calendar.badge.clock",
                iconColor: .orange,
                title: "Event Types & Recurrences",
                subtitle: "Manage birthdays, anniversaries, name days, and special milestones.",
                bulletPoints: [
                    "Birthdays 🎂: automatic calculation of age, upcoming birthday date, and weekday.",
                    "Anniversaries ❤️: supports both annual anniversaries and monthly 'Mesiversaries' to celebrate every month.",
                    "Name Days 🌟: celebrate someone's patron saint day without having to track birth years.",
                    "Special Events ✨: one-time events (graduation, party) or custom recurring milestones.",
                    "'Unknown Birth Year' Option: track the day and month while keeping age private."
                ],
                proTip: "Anniversary details highlight exactly which monthly or annual milestone is being reached."
            ),
            GuideTopic(
                id: "categories",
                category: .basics,
                icon: "tag.fill",
                iconColor: .purple,
                title: "Categories & Social Circles",
                subtitle: "Organize and filter contacts according to your circles of life.",
                bulletPoints: [
                    "Standard categories: Family 🏡, Friends 🎉, Work 💼, Partner ❤️, Other 🎈.",
                    "Unlimited custom categories: tap the '+' button on the right to create custom groups (e.g. Sports, College, Neighbors).",
                    "Drag & Drop Reordering: customize category order via Settings > 'Reorder Categories' or by tapping the reorder icon.",
                    "Instant Filter: tap any category pill in the top bar to filter the list immediately."
                ],
                proTip: "Long-press any custom category chip to edit, delete, or reorder it."
            ),
            GuideTopic(
                id: "zodiac_trivia",
                category: .events,
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Zodiac, Birthstones & Trivia",
                subtitle: "Fascinating astrological details and historical facts calculated automatically.",
                bulletPoints: [
                    "Western Zodiac Sign ♈: calculated automatically from day and month with symbol and element.",
                    "Chinese Zodiac 🐉: derived from birth year to reveal their Eastern horoscope animal.",
                    "Monthly Birthstone 💎: discover each month's traditional gemstone and its symbolic meaning.",
                    "Famous Birthdays & Historical Trivia: discover which historical figures and celebrities share the exact same birthday."
                ],
                proTip: "These trivia details are great conversation starters and help write unique, memorable wishes!"
            ),
            GuideTopic(
                id: "blow_candle",
                category: .events,
                icon: "flame.fill",
                iconColor: .red,
                title: "Blow the Candle (Birthday Day)",
                subtitle: "A delightful interactive ritual that comes alive on their birthday.",
                bulletPoints: [
                    "Automatic activation: when today is someone's birthday, an animated burning candle appears on their card.",
                    "Make a wish: tap the button to blow out the candle.",
                    "Realistic animation: the flame extinguishes with smooth smoke, haptic feedback, and festive confetti."
                ],
                proTip: "You can replay the experience and blow the candle as many times as you like throughout the day."
            ),
            GuideTopic(
                id: "gifts_tracker",
                category: .giftsAndVenues,
                icon: "gift.fill",
                iconColor: .pink,
                title: "Gift Ideas & Budget Tracker",
                subtitle: "Jot down ideas, track expenses, and never get caught unprepared.",
                bulletPoints: [
                    "Comprehensive gift card: record titles, estimated prices, notes, date (month.year), and store links.",
                    "Quick edit pencil: tap the pencil icon next to the trash bin to modify any detail of an existing gift.",
                    "Month.year date tracking: specify month and year for each gift to remember when it was planned or purchased.",
                    "Purchase status: mark gifts as 'Purchased' with a green checkmark to track pending ideas.",
                    "Private Gifts: enable 'Private Gift' to lock surprise ideas behind Face ID / Touch ID.",
                    "Budget tracking: monitor total spent and tap to expand all gifts directly in Candle Insights."
                ],
                proTip: "Tap the store link on any gift item to open the web page and purchase it directly."
            ),
            GuideTopic(
                id: "smart_wishes",
                category: .events,
                icon: "wand.and.stars",
                iconColor: .teal,
                title: "Smart AI Wishes Generator",
                subtitle: "Always find the right words for every personality and occasion.",
                bulletPoints: [
                    "Diverse tones: choose from Warm & Caring, Funny, Formal, or Short & Sweet.",
                    "Dynamic personalization: messages automatically incorporate the person's name and new age.",
                    "1-Tap Copy: instantly copy the message to paste into WhatsApp, Messages, Instagram, or Telegram.",
                    "Custom templates: save your own wish templates to reuse in future years."
                ],
                proTip: "You can edit generated text before sending to add personal inside jokes or memories."
            ),
            GuideTopic(
                id: "celebration_map",
                category: .giftsAndVenues,
                icon: "map.fill",
                iconColor: .green,
                title: "Celebration Venues & Apple Maps",
                subtitle: "Remember restaurants, venues, and party spots where you celebrated.",
                bulletPoints: [
                    "Save venues: record favourite restaurants, parks, or party locations for each contact.",
                    "Celebration Map: open the full-screen interactive map to view all party locations on Apple Maps.",
                    "GPS Geolocation: use 'Current Location' while at the venue to save exact coordinates instantly.",
                    "Turn-by-turn directions: tap 'Open in Maps' to get instant directions to any saved venue."
                ],
                proTip: "Filter venues on the map by birthdays, anniversaries, or upcoming celebrations."
            ),
            GuideTopic(
                id: "memory_photos",
                category: .events,
                icon: "photo.stack.fill",
                iconColor: .blue,
                title: "Polaroid Memory Photos & Avatar Zoom",
                subtitle: "Horizontal gallery of celebration snapshots with captions and full-screen view.",
                bulletPoints: [
                    "Horizontal Polaroid Gallery 📸: swipe through favorite celebration photos directly on the contact card.",
                    "Captions & Timestamps ✍️: add a heartfelt note or memories to each photo with its celebration date.",
                    "Full-Screen Photo Viewer: tap any photo card to view it in full screen.",
                    "Expandable Avatar: tap the main contact avatar to view it in high resolution."
                ],
                proTip: "Capture live photos using the camera or select multiple pictures at once from your photo library!"
            ),
            GuideTopic(
                id: "calendar",
                category: .insightsAndCalendar,
                icon: "calendar",
                iconColor: .indigo,
                title: "Integrated Celebration Calendar",
                subtitle: "A comprehensive visual overview month by month or across the full year.",
                bulletPoints: [
                    "Monthly grid view: days with celebrations show a colored indicator dot; tap to view all scheduled events.",
                    "Annual overview: see all 12 months at once to spot busy celebration seasons at a glance.",
                    "Quick Add: tap any date in the calendar to create a celebration directly for that day.",
                    "Effortless year navigation to plan ahead for future holidays and trips."
                ],
                proTip: "From the monthly view, check remaining days for each birthday happening that month."
            ),
            GuideTopic(
                id: "insights",
                category: .insightsAndCalendar,
                icon: "chart.bar.xaxis",
                iconColor: .purple,
                title: "Candle Insights & Analytics",
                subtitle: "Discover fascinating trends, patterns, and metrics across your circle.",
                bulletPoints: [
                    "Annual Progress: track the percentage of completed and remaining celebrations with a next-event countdown.",
                    "Interactive 12-Month Chart: tap any month column to expand celebrations and jump directly to details.",
                    "Seasonal Horizon: see your busiest season and explore celebrations across Spring, Summer, Autumn, and Winter.",
                    "Zodiac Explorer: tap the zodiac box to reveal all 12 signs organized into the 4 astrological elements.",
                    "Milestones & Age: track who turns milestone ages (18, 30, 40, 50+) with a dedicated breakdown sheet.",
                    "Gift Budget & Spending: tap total spent or pending ideas to explore all purchased gifts or planned inspirations, with Face ID / Touch ID for private items."
                ],
                proTip: "Tap any person or event to jump straight to their details. Private contacts stay shielded and automatically re-lock upon exit."
            ),
            GuideTopic(
                id: "notifications_widgets",
                category: .customization,
                icon: "bell.badge.fill",
                iconColor: .yellow,
                title: "Smart Reminders & iOS Widgets",
                subtitle: "Timely notifications and glanceable widgets so you never miss a date.",
                bulletPoints: [
                    "Same-day notifications: morning reminders (at your preferred hour) so you wish people well on time.",
                    "Advance reminders: get alerts 1, 2, 3 days, 1 week, or 2 weeks ahead to buy gifts in advance.",
                    "Home Screen Widgets: compact and medium widgets showcasing upcoming celebrations and countdowns.",
                    "Lock Screen & StandBy Widgets: keep dates glanceable even while your phone is locked or charging.",
                    "Test notification: send a sample alert from Settings to verify notification permissions."
                ],
                proTip: "In Settings, customize your preferred reminder delivery time."
            ),
            GuideTopic(
                id: "privacy_biometrics",
                category: .privacyAndBackup,
                icon: "lock.shield.fill",
                iconColor: .green,
                title: "Face ID / Touch ID Biometric Vault",
                subtitle: "Top-tier privacy for sensitive dates and surprise gifts.",
                bulletPoints: [
                    "Private Contacts: toggle 'Private Contact' to mask names and dates on the main dashboard.",
                    "Biometric & Passcode unlock: access masked details instantly using Face ID, Touch ID, or iPhone passcode.",
                    "Private gifts: keep surprise gift ideas hidden from anyone holding your phone.",
                    "100% local storage: your data is never uploaded to third-party servers or tracked."
                ],
                proTip: "Tap the lock icon anytime to re-lock the private vault immediately."
            ),
            GuideTopic(
                id: "sync_backup",
                category: .privacyAndBackup,
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Contacts Import, Backup & iCloud",
                subtitle: "Your celebrations are always safe, portable, and synced.",
                bulletPoints: [
                    "Address Book import: import all birthdays from iOS Contacts with a single tap.",
                    "Full JSON backup: export and share complete backups to restore on another device.",
                    "CSV spreadsheet export: open your birthdays in Excel, Apple Numbers, or Google Sheets.",
                    "iCalendar (.ics) export: export standard calendar files to sync with Google Calendar and Outlook.",
                    "iCloud Sync: background sync across all your Apple devices sharing the same Apple ID."
                ],
                proTip: "Export periodic backups to keep gift notes and memory albums safe."
            ),
            GuideTopic(
                id: "customization",
                category: .customization,
                icon: "paintpalette.fill",
                iconColor: store.accentPrimary,
                title: "Color Themes & Appearance",
                subtitle: "Personalize Candle to match your aesthetic and style.",
                bulletPoints: [
                    "16 Accent Colors: choose from Candle Amber, Sunset Coral, Emerald Mint, Royal Purple, Sapphire Blue, and more.",
                    "Light, Dark, or System Mode: matches your iOS system appearance or custom preference.",
                    "Custom avatar hues: assign specific accent colors or gradients to contacts for quick visual recognition.",
                    "Refined native design: fluid animations, ergonomic cards, and tactile feedback throughout."
                ],
                proTip: "Your chosen accent color dynamically styles app buttons, icons, charts, and widgets."
            )
        ]
    }
    
    private func spanishTopics() -> [GuideTopic] {
        [
            GuideTopic(
                id: "dashboard",
                category: .basics,
                icon: "sparkles",
                iconColor: store.accentPrimary,
                title: "Panel de Control y Hero Card",
                subtitle: "Tu vista principal para tener siempre presentes las próximas celebraciones.",
                bulletPoints: [
                    "Hero Card destacada: muestra al próximo cumpleañero con su foto, cuenta atrás y edad.",
                    "Anillo de progreso: se completa progresivamente conforme se acerca la fecha especial.",
                    "Botón Celebrar ✨: lanza confeti animado con vibración háptica al instante.",
                    "Filtros de tiempo: selecciona 'Todos', 'Este mes' o 'Este año' para planificar.",
                    "Gestos rápidos: desliza a la derecha para Ajustes o a la izquierda para Estadísticas."
                ],
                proTip: "Toca cualquier tarjeta para ver notas, recuerdos, regalos y lugares de celebración."
            ),
            GuideTopic(
                id: "event_types",
                category: .events,
                icon: "calendar.badge.clock",
                iconColor: .orange,
                title: "Tipos de Eventos y Frecuencias",
                subtitle: "Organiza cumpleaños, aniversarios, santos y fechas memorables.",
                bulletPoints: [
                    "Cumpleaños 🎂: cálculo automático de la edad, próxima fecha y día de la semana.",
                    "Aniversarios ❤️: soporte para aniversarios anuales y 'Mesiversarios' mensuales.",
                    "Santos 🌟: felicita el santo de tus personas cercanas sin necesidad de saber el año de nacimiento.",
                    "Eventos Especiales ✨: citas únicas (graduaciones, fiestas) o hitos periódicos.",
                    "Opción 'Año de nacimiento desconocido': guarda el día y el mes manteniendo la edad privada."
                ],
                proTip: "En los aniversarios puedes ver qué mes o año de pareja se celebra."
            ),
            GuideTopic(
                id: "categories",
                category: .basics,
                icon: "tag.fill",
                iconColor: .purple,
                title: "Categorías y Círculos Sociales",
                subtitle: "Organiza y filtra tus contactos según tus círculos personales.",
                bulletPoints: [
                    "Categorías estándar: Familia 🏡, Amigos 🎉, Trabajo 💼, Pareja ❤️, Otro 🎈.",
                    "Categorías personalizadas ilimitadas: pulsa el '+' para crear grupos a medida (ej. Fútbol, Universidad).",
                    "Reordenación Arrastrar y Soltar: personaliza el orden en Ajustes > 'Ordenar Categorías'.",
                    "Filtro instantáneo: toca una categoría en la barra superior para ver solo ese grupo."
                ],
                proTip: "Mantén pulsada cualquier categoría personalizada para editarla, moverla o eliminarla."
            ),
            GuideTopic(
                id: "zodiac_trivia",
                category: .events,
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Zodíaco, Piedras de Nacimiento y Curiosidades",
                subtitle: "Detalles astrológicos y hechos históricos calculados al instante.",
                bulletPoints: [
                    "Signo del Zodíaco Occidental ♈: calculado según el día y mes con símbolo y elemento.",
                    "Zodíaco Chino 🐉: basado en el año de nacimiento para descubrir su animal.",
                    "Piedra del Mes 💎: descubre la gema tradicional y su significado simbólico.",
                    "Famosos y Efemérides: averigua qué personajes históricos y celebridades nacieron el mismo día."
                ],
                proTip: "¡Estos datos son ideales para enviar felicitaciones originales e inolvidables!"
            ),
            GuideTopic(
                id: "blow_candle",
                category: .events,
                icon: "flame.fill",
                iconColor: .red,
                title: "Soplar la Vela (Día del Cumpleaños)",
                subtitle: "Un ritual interactivo que cobra vida en el día de la celebración.",
                bulletPoints: [
                    "Activación automática: el día del cumpleaños aparece una vela encendida en la tarjeta.",
                    "Pide un deseo: pulsa el botón para apagar la vela.",
                    "Animación realista: la llama se extingue con humo suave, vibración y confeti festivo."
                ],
                proTip: "Puedes revivir el ritual y soplar la vela tantas veces como desees durante el día."
            ),
            GuideTopic(
                id: "gifts_tracker",
                category: .giftsAndVenues,
                icon: "gift.fill",
                iconColor: .pink,
                title: "Ideas de Regalos y Presupuesto",
                subtitle: "Apunta ideas, controla gastos y ten todo listo con antelación.",
                bulletPoints: [
                    "Ficha de regalo: añade título, precio orientativo, notas, fecha (mes.año) y enlace a la tienda.",
                    "Edición rápida con lápiz: toca el lápiz junto a la papelera para modificar cualquier detalle del regalo.",
                    "Fecha en formato mes.año: asigna mes y año a cada regalo para saber exactamente cuándo se planificó.",
                    "Estado de compra: marca regalos como 'Comprados' para saber qué te falta adquirir.",
                    "Regalos Secretos: activa 'Regalo Privado' para bloquearlo tras Face ID / Touch ID.",
                    "Control de presupuesto: revisa el total gastado y toca para desplegar los regalos en Estadísticas."
                ],
                proTip: "Toca el enlace web para acceder a la tienda online y comprar el regalo directamente."
            ),
            GuideTopic(
                id: "smart_wishes",
                category: .events,
                icon: "wand.and.stars",
                iconColor: .teal,
                title: "Felicitaciones Inteligentes (Smart Wishes)",
                subtitle: "Encuentra siempre las palabras idóneas para cada ocasión.",
                bulletPoints: [
                    "Tonos variados: elige entre Cariñoso, Divertido, Formal o Breve y emotivo.",
                    "Personalización dinámica: incluye automáticamente el nombre y la nueva edad del homenajeado.",
                    "Copia con 1 toque: pega directamente en WhatsApp, Instagram, Telegram o Mensajes.",
                    "Plantillas guardadas: conserva tus mensajes favoritos para reutilizarlos en el futuro."
                ],
                proTip: "Puedes retocar el texto antes de enviarlo para añadir toques personales."
            ),
            GuideTopic(
                id: "celebration_map",
                category: .giftsAndVenues,
                icon: "map.fill",
                iconColor: .green,
                title: "Lugares de Celebración y Apple Maps",
                subtitle: "Guarda restaurantes y sitios memorables de cada celebración.",
                bulletPoints: [
                    "Guarda locales: añade restaurantes, parques o sitios preferidos para cada persona.",
                    "Celebration Map: abre el mapa interactivo para ver todas las ubicaciones en Apple Maps.",
                    "GPS en 1 toque: pulsa 'Ubicación Actual' cuando estés en el sitio para guardar las coordenadas.",
                    "Indicaciones paso a paso: pulsa 'Abrir en Mapas' para iniciar la ruta en el navegador."
                ],
                proTip: "Filtra sitios en el mapa por cumpleaños, aniversarios o eventos cercanos."
            ),
            GuideTopic(
                id: "memory_photos",
                category: .events,
                icon: "photo.stack.fill",
                iconColor: .blue,
                title: "Fotos de Recuerdos Polaroid y Avatar",
                subtitle: "Galería horizontal de fotografías de las fiestas con leyendas y vista a pantalla completa.",
                bulletPoints: [
                    "Galería Polaroid horizontal 📸: navega por las fotos de las celebraciones directamente en los detalles del contacto.",
                    "Leyendas y Fechas ✍️: añade notas o recuerdos especiales a cada imagen con su fecha de guardado.",
                    "Vista a Pantalla Completa: toca cualquier foto para ampliarla en pantalla completa.",
                    "Avatar ampliable: toca la foto de perfil principal para verla en alta definición."
                ],
                proTip: "¡Puedes tomar una foto al instante con la cámara o seleccionar varias fotos a la vez desde tu fototeca!"
            ),
            GuideTopic(
                id: "calendar",
                category: .insightsAndCalendar,
                icon: "calendar",
                iconColor: .indigo,
                title: "Calendario de Cumpleaños Integrado",
                subtitle: "Planificación visual completa mes a mes o del año entero.",
                bulletPoints: [
                    "Vista de cuadrícula mensual: los días con fechas tienen un punto de color; toca para ver los eventos.",
                    "Vista anual panorámica: examina los 12 meses juntos para identificar los meses más ocupados.",
                    "Añadir rápido: toca cualquier fecha en el calendario para crear un evento directamente ese día.",
                    "Navega cómodamente entre años para planificar escapadas y celebraciones futuras."
                ],
                proTip: "Desde la vista mensual puedes ver los días restantes para cada evento del mes."
            ),
            GuideTopic(
                id: "insights",
                category: .insightsAndCalendar,
                icon: "chart.bar.xaxis",
                iconColor: .purple,
                title: "Estadísticas y Análisis (Candle Insights)",
                subtitle: "Descubre patrones, métricas y curiosidades sobre tu círculo social.",
                bulletPoints: [
                    "Progreso Anual: comprueba el porcentaje de eventos completados y restantes del año con cuenta atrás al próximo evento.",
                    "Gráfico Mensual Interactivo: toca las columnas de los 12 meses para desplegar las celebraciones de cada mes.",
                    "Distribución Estacional: descubre tu estación más festiva y explora Primavera, Verano, Otoño e Invierno.",
                    "Explorador Zodiacal: toca la tarjeta del zodíaco para ver los 12 signos organizados en los 4 elementos astrológicos.",
                    "Fechas Clave y Edad: consulta quiénes cumplen cifras redondas (18, 30, 40, 50+) en una vista detallada.",
                    "Presupuesto y Gastos en Regalos: toca el gasto total o las ideas pendientes para explorar los regalos comprados o planificados, con Face ID / Touch ID si son privados."
                ],
                proTip: "Toca cualquier persona o evento para ver sus detalles. Los datos privados permanecen protegidos y se bloquean al salir de Insights."
            ),
            GuideTopic(
                id: "notifications_widgets",
                category: .customization,
                icon: "bell.badge.fill",
                iconColor: .yellow,
                title: "Avisos Inteligentes y Widgets de iOS",
                subtitle: "Recordatorios oportunos y widgets para tener todo siempre a la vista.",
                bulletPoints: [
                    "Avisos el mismo día: recordatorios por la mañana a la hora que tú elijas para felicitar a tiempo.",
                    "Recordatorios con antelación: recibe alertas con días o semanas de margen para comprar el regalo.",
                    "Widgets de Pantalla de Inicio: widgets compactos y medianos con cuentas atrás.",
                    "Widgets de Pantalla de Bloqueo y StandBy: consulta fechas con el móvil bloqueado o cargando.",
                    "Prueba de notificaciones: envía una notificación de prueba desde Ajustes para validar permisos."
                ],
                proTip: "En Ajustes puedes definir la hora habitual para recibir tus recordatorios."
            ),
            GuideTopic(
                id: "privacy_biometrics",
                category: .privacyAndBackup,
                icon: "lock.shield.fill",
                iconColor: .green,
                title: "Caja Fuerte Face ID / Touch ID",
                subtitle: "Máxima privacidad para fechas sensibles y regalos sorpresa.",
                bulletPoints: [
                    "Contactos Privados: activa 'Contacto Privado' para enmascarar nombres y datos en la pantalla principal.",
                    "Desbloqueo biométrico o con código: accede a los datos al instante mediante Face ID, Touch ID o código del iPhone.",
                    "Regalos secretos: oculta ideas para que nadie pueda verlas usando tu teléfono.",
                    "Almacenamiento 100% local: tus datos nunca salen de tu dispositivo hacia servidores externos."
                ],
                proTip: "Toca el candado en cualquier momento para bloquear la caja fuerte de inmediato."
            ),
            GuideTopic(
                id: "sync_backup",
                category: .privacyAndBackup,
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Contactos, Copia de Seguridad e iCloud",
                subtitle: "Tus fechas siempre a salvo, transferibles y sincronizadas.",
                bulletPoints: [
                    "Importar Contactos: añade con un solo toque todos los cumpleaños de tu agenda de iOS.",
                    "Copia de seguridad JSON: exporta y comparte el archivo completo para restaurarlo en otro dispositivo.",
                    "Exportar en CSV: genera una hoja de cálculo compatible con Excel, Numbers o Google Sheets.",
                    "Exportar a Calendario (.ics): sincroniza tus fechas con Google Calendar o Outlook.",
                    "Sincronización con iCloud: sincroniza en segundo plano entre todos tus dispositivos de Apple."
                ],
                proTip: "Exporta copias periódicas para conservar notas de regalos y fotos a buen recaudo."
            ),
            GuideTopic(
                id: "customization",
                category: .customization,
                icon: "paintpalette.fill",
                iconColor: store.accentPrimary,
                title: "Paletas de Colores y Apariencia",
                subtitle: "Personaliza Candle para adaptarlo a tu estilo personal.",
                bulletPoints: [
                    "16 Colores de Acento: Candle Amber, Sunset Coral, Emerald Mint, Royal Purple, Sapphire Blue y más.",
                    "Modo Claro, Oscuro o Automático: sigue el aspecto del sistema o el que elijas.",
                    "Colores de avatar a medida: asigna colores o gradientes a cada contacto para reconocerlos de un vistazo.",
                    "Diseño nativo y pulido: animaciones fluidas, tarjetas ergonómicas y respuesta táctil integrada."
                ],
                proTip: "El color de acento elegido decora botones, iconos, gráficos y widgets de la aplicación."
            )
        ]
    }
    
    private func frenchTopics() -> [GuideTopic] {
        [
            GuideTopic(
                id: "dashboard",
                category: .basics,
                icon: "sparkles",
                iconColor: store.accentPrimary,
                title: "Tableau de Bord & Hero Card",
                subtitle: "Votre vue principale pour garder un œil sur les prochains anniversaires.",
                bulletPoints: [
                    "Hero Card en vedette : met en valeur le prochain événement avec photo, compte à rebours et âge.",
                    "Anneau de progression : le cercle se remplit progressivement à mesure que le jour J approche.",
                    "Bouton Célébrer ✨ : lancez des confettis festifs avec retour haptique en un instant.",
                    "Filtres de temps rapides : affichez 'Tout', 'Ce mois-ci' ou 'Cette année' pour anticiper.",
                    "Gestes rapides : glissez vers la droite pour les Réglages ou vers la gauche pour les Statistiques."
                ],
                proTip: "Touchez n'importe quelle carte pour ouvrir les détails, idées cadeaux et souvenirs."
            ),
            GuideTopic(
                id: "event_types",
                category: .events,
                icon: "calendar.badge.clock",
                iconColor: .orange,
                title: "Types d'Événements & Récurrences",
                subtitle: "Gérez anniversaires, fêtes de couple, fêtes patronales et dates clés.",
                bulletPoints: [
                    "Anniversaires 🎂 : calcul automatique de l'âge, de la date exacte et du jour de la semaine.",
                    "Anniversaires de couple ❤️ : prise en charge des anniversaires annuels et 'Mois-versaires' mensuels.",
                    "Fêtes du prénom 🌟 : célébrez la fête de vos proches sans avoir besoin de connaître leur année de naissance.",
                    "Occasions spéciales ✨ : événements uniques (remise de diplôme, fête) ou jalons périodiques.",
                    "Option 'Année de naissance inconnue' : conserve le jour et le mois tout en gardant l'âge privé."
                ],
                proTip: "Dans les détails d'anniversaire, découvrez le jalon ou le mois de couple célébré."
            ),
            GuideTopic(
                id: "categories",
                category: .basics,
                icon: "tag.fill",
                iconColor: .purple,
                title: "Catégories & Cercles Sociaux",
                subtitle: "Organisez et filtrez vos contacts selon vos cercles de vie.",
                bulletPoints: [
                    "Catégories par défaut : Famille 🏡, Amis 🎉, Travail 💼, Partenaire ❤️, Autre 🎈.",
                    "Catégories personnalisées illimitées : appuyez sur '+' pour créer vos propres groupes (ex. Sport, Université).",
                    "Glisser-Déposer : personnalisez l'ordre des catégories dans Réglages > 'Réorganiser les Catégories'.",
                    "Filtre immédiat : touchez une catégorie dans la barre supérieure pour n'afficher que ce groupe."
                ],
                proTip: "Maintenez le doigt sur une catégorie personnalisée pour la modifier, la déplacer ou la supprimer."
            ),
            GuideTopic(
                id: "zodiac_trivia",
                category: .events,
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Zodiaque, Pierres de Naissance & Anecdotes",
                subtitle: "Détails astrologiques et repères historiques calculés automatiquement.",
                bulletPoints: [
                    "Signe du Zodiaque Occidental ♈ : calculé d'après le jour et le mois avec symbole et élément.",
                    "Zodiaque Chinois 🐉 : déterminé d'après l'année de naissance pour révéler l'animal associé.",
                    "Pierre de Naissance 💎 : découvrez la gemme traditionnelle du mois et sa symbolique.",
                    "Personnalités et faits historiques : découvrez quelles célébrités partagent exactement la même date."
                ],
                proTip: "Ces anecdotes sont idéales pour engager la conversation et personnaliser vos vœux !"
            ),
            GuideTopic(
                id: "blow_candle",
                category: .events,
                icon: "flame.fill",
                iconColor: .red,
                title: "Souffler la Bougie (Jour de Fête)",
                subtitle: "Un rituel interactif et magique qui s'anime le jour de l'anniversaire.",
                bulletPoints: [
                    "Activation automatique : le jour de l'anniversaire, une bougie animée s'allume sur la fiche.",
                    "Faites un vœu : touchez le bouton pour souffler la bougie.",
                    "Animation immersive : la flamme s'éteint avec fumée douce, vibration et pluie de confettis."
                ],
                proTip: "Vous pouvez rejouer l'animation et souffler la bougie autant de fois que vous le souhaitez."
            ),
            GuideTopic(
                id: "gifts_tracker",
                category: .giftsAndVenues,
                icon: "gift.fill",
                iconColor: .pink,
                title: "Idées Cadeaux & Suivi du Budget",
                subtitle: "Notez des idées, suivez vos dépenses et soyez toujours prêt à temps.",
                bulletPoints: [
                    "Fiche cadeau détaillée : ajoutez titre, prix indicatif, notes, date (mois.année) et lien boutique.",
                    "Modification au crayon : touchez l'icône de crayon à côté de la corbeille pour ajuster n'importe quel détail.",
                    "Date au format mois.année : précisez le mois et l'année pour suivre précisément l'historique de chaque présent.",
                    "Statut d'achat : cochez les cadeaux comme 'Achetés' pour voir ce qu'il vous reste à trouver.",
                    "Cadeaux Secrets : activez 'Cadeau Privé' pour masquer les surprises derrière Face ID / Touch ID.",
                    "Suivi du budget : consultez vos dépenses totales et touchez pour explorer tous vos cadeaux dans les Statistiques."
                ],
                proTip: "Touchez le lien web d'un cadeau pour ouvrir la page de la boutique et passer commande."
            ),
            GuideTopic(
                id: "smart_wishes",
                category: .events,
                icon: "wand.and.stars",
                iconColor: .teal,
                title: "Générateur de Vœux Intelligents",
                subtitle: "Trouvez toujours les mots justes pour chaque personnalité.",
                bulletPoints: [
                    "Styles variés : choisissez parmi Chaleureux, Drôle, Formel ou Court & Percutant.",
                    "Personnalisation dynamique : intègre automatiquement le prénom et l'âge de la personne.",
                    "Copie en 1 geste : collez le message directement dans WhatsApp, Messages ou Instagram.",
                    "Modèles enregistrés : conservez vos messages favoris pour les réutiliser d'une année sur l'autre."
                ],
                proTip: "Ajustez le texte généré avant l'envoi pour y glisser un souvenir personnel."
            ),
            GuideTopic(
                id: "celebration_map",
                category: .giftsAndVenues,
                icon: "map.fill",
                iconColor: .green,
                title: "Lieux de Fête & Apple Maps",
                subtitle: "Gardez en mémoire les restaurants et endroits où vous avez célébré.",
                bulletPoints: [
                    "Enregistrez des lieux : notez les restaurants, parcs ou lieux préférés pour chaque contact.",
                    "Celebration Map : ouvrez la carte interactive pour visualiser tous les lieux sur Apple Maps.",
                    "GPS en 1 touche : utilisez 'Position Actuelle' sur place pour enregistrer les coordonnées.",
                    "Itinéraire guidé : touchez 'Ouvrir dans Plans' pour lancer la navigation vers le lieu."
                ],
                proTip: "Filtrez les lieux sur la carte par anniversaires ou événements à venir."
            ),
            GuideTopic(
                id: "memory_photos",
                category: .events,
                icon: "photo.stack.fill",
                iconColor: .blue,
                title: "Photos Souvenirs Style Polaroid & Avatar",
                subtitle: "Galerie horizontale de photos des fêtes avec légendes et affichage plein écran.",
                bulletPoints: [
                    "Galerie Polaroid horizontale 📸 : faites défiler les plus beaux clichés des fêtes directement sur la fiche du contact.",
                    "Légendes et Dates ✍️ : ajoutez une note personnelle à chaque photo ainsi que la date de la célébration.",
                    "Visualisation Plein Écran : touchez n'importe quelle photo pour l'admirer en plein écran.",
                    "Avatar Agrandissable : touchez l'avatar principal du contact pour l'afficher en haute définition."
                ],
                proTip: "Prenez une photo en direct ou sélectionnez-en plusieurs à la fois depuis votre photothèque !"
            ),
            GuideTopic(
                id: "calendar",
                category: .insightsAndCalendar,
                icon: "calendar",
                iconColor: .indigo,
                title: "Calendrier Intégré des Anniversaires",
                subtitle: "Vue d'ensemble visuelle mois par mois ou sur l'année entière.",
                bulletPoints: [
                    "Grille mensuelle : les jours festifs affichent un repère coloré ; touchez pour voir les événements.",
                    "Vue annuelle globale : visualisez les 12 mois ensemble pour repérer les saisons chargées.",
                    "Ajout rapide : touchez n'importe quel jour du calendrier pour créer un événement à cette date.",
                    "Navigation fluide d'une année à l'autre pour planifier voyages et fêtes futures."
                ],
                proTip: "Depuis la vue mensuelle, observez le décompte des jours pour chaque événement du mois."
            ),
            GuideTopic(
                id: "insights",
                category: .insightsAndCalendar,
                icon: "chart.bar.xaxis",
                iconColor: .purple,
                title: "Statistiques & Analyses (Candle Insights)",
                subtitle: "Découvrez des tendances, métriques et faits passionnants sur votre cercle de proches.",
                bulletPoints: [
                    "Progression Annuelle : suivez le pourcentage de fêtes passées et restantes avec le compte à rebours du prochain événement.",
                    "Graphique Mensuel Interactif : touchez chaque mois pour afficher la liste de ses célébrations et ouvrir leurs détails.",
                    "Horizons Saisonniers : découvrez votre saison la plus animée et explorez le Printemps, l'Été, l'Automne et l'Hiver.",
                    "Explorateur Zodiacal : touchez le cadre astrologique pour parcourir les 12 signes répartis selon les 4 éléments.",
                    "Étapes de Vie : observez qui célèbre un âge rond (18, 30, 40, 50+) grâce à une fiche dédiée.",
                    "Budget & Dépenses Cadeaux : touchez les dépenses totales ou les idées en attente pour explorer tous les cadeaux achetés ou prévus, avec Face ID / Touch ID pour les cadeaux privés."
                ],
                proTip: "Touchez n'importe quel contact pour ouvrir sa fiche. Les données privées restent verrouillées et sont resécurisées dès que vous quittez Insights."
            ),
            GuideTopic(
                id: "notifications_widgets",
                category: .customization,
                icon: "bell.badge.fill",
                iconColor: .yellow,
                title: "Rappels Intelligents & Widgets iOS",
                subtitle: "Notifications ponctuelles et widgets pour garder vos dates à portée d'œil.",
                bulletPoints: [
                    "Rappels le jour même : notifications le matin à l'heure souhaitée pour souhaiter vos vœux à temps.",
                    "Rappels anticipés : recevez une alerte 1, 2, 3 jours, 1 ou 2 semaines avant pour préparer le cadeau.",
                    "Widgets Écran d'accueil : formats compacts et moyens avec compte à rebours.",
                    "Widgets Écran verrouillé & StandBy : consultez vos dates même quand l'iPhone est verrouillé.",
                    "Test de rappel : envoyez une notification test depuis les Réglages pour vérifier les autorisations."
                ],
                proTip: "Dans les Réglages, configurez l'heure précise à laquelle vous souhaitez recevoir les rappels."
            ),
            GuideTopic(
                id: "privacy_biometrics",
                category: .privacyAndBackup,
                icon: "lock.shield.fill",
                iconColor: .green,
                title: "Coffre-fort Face ID / Touch ID",
                subtitle: "Confidentialité absolue pour dates privées et surprises.",
                bulletPoints: [
                    "Contacts Privés : activez 'Contact Privé' pour masquer les noms et dates sur l'écran d'accueil.",
                    "Déverrouillage biométrique et code : accédez aux informations via Face ID, Touch ID ou code de l'iPhone.",
                    "Cadeaux cachés : gardez vos idées secrètes même si quelqu'un manipule votre téléphone.",
                    "Stockage 100 % local : vos données ne sont jamais transmises à des serveurs tiers."
                ],
                proTip: "Touchez l'icône du cadenas à tout moment pour reverrouiller le coffre immédiatement."
            ),
            GuideTopic(
                id: "sync_backup",
                category: .privacyAndBackup,
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Contacts, Sauvegardes & iCloud",
                subtitle: "Vos dates en sécurité, portables et synchronisées partout.",
                bulletPoints: [
                    "Importation Contacts : importez en 1 geste tous les anniversaires de votre carnet d'adresses.",
                    "Sauvegarde JSON complète : exportez l'archive intégrale pour la restaurer sur un autre appareil.",
                    "Exportation CSV : générez une feuille de calcul lisible dans Excel, Numbers ou Google Sheets.",
                    "Fichier Calendrier (.ics) : synchronisez vos dates avec Google Calendar et Outlook.",
                    "iCloud Sync : synchronisation automatique en arrière-plan sur tous vos appareils Apple."
                ],
                proTip: "Exportez des sauvegardes régulières pour protéger vos notes de cadeaux et vos albums."
            ),
            GuideTopic(
                id: "customization",
                category: .customization,
                icon: "paintpalette.fill",
                iconColor: store.accentPrimary,
                title: "Thèmes de Couleurs & Apparence",
                subtitle: "Personnalisez Candle pour qu'il s'accorde parfaitement à vos goûts.",
                bulletPoints: [
                    "16 Couleurs d'accent : Candle Amber, Sunset Coral, Emerald Mint, Royal Purple, Sapphire Blue et plus.",
                    "Modes Clair, Sombre ou Automatique : suit l'apparence de votre système ou votre préférence.",
                    "Couleurs de profil personnalisées : attribuez des teintes et dégradés uniques à vos contacts.",
                    "Conception native soignée : animations fluides, cartes ergonomiques et retour haptique intégré."
                ],
                proTip: "La couleur d'accent choisie habille harmonieusement boutons, icônes, graphiques et widgets."
            )
        ]
    }
    
    private func germanTopics() -> [GuideTopic] {
        [
            GuideTopic(
                id: "dashboard",
                category: .basics,
                icon: "sparkles",
                iconColor: store.accentPrimary,
                title: "Dashboard & Hero Card",
                subtitle: "Deine zentrale Übersicht, um anstehende Feiertage immer im Blick zu behalten.",
                bulletPoints: [
                    "Hero Card im Fokus: zeigt das nächste Geburtstagskind mit Foto, Countdown und Alter.",
                    "Fortschrittsring: füllt sich harmonisch auf, je näher der Ehrentag rückt.",
                    "Feiern-Taste ✨: zündet animiertes Konfetti mit haptischem Feedback auf Knopfdruck.",
                    "Schnellfilter: schalte zwischen 'Alle', 'Dieser Monat' oder 'Dieses Jahr' um.",
                    "Wischgesten: nach rechts wischen für Einstellungen, nach links für Statistiken."
                ],
                proTip: "Tippe auf eine Karte, um Notizen, Geschenkideen, Erinnerungen und Orte aufzurufen."
            ),
            GuideTopic(
                id: "event_types",
                category: .events,
                icon: "calendar.badge.clock",
                iconColor: .orange,
                title: "Ereignisarten & Wiederholungen",
                subtitle: "Verwalte Geburtstage, Jahrestage, Namenstage und besondere Anlässe.",
                bulletPoints: [
                    "Geburtstage 🎂: automatische Berechnung von Alter, Wochentag und Zieldatum.",
                    "Jahrestage ❤️: unterstützt jährliche Jahrestage und monatliche Monatstage.",
                    "Namenstage 🌟: ehre Namenstage, ohne ein Geburtsjahr kennen zu müssen.",
                    "Besondere Anlässe ✨: einmalige Termine (Abschlussfeier, Party) oder wiederkehrende Meilensteine.",
                    "Option 'Unbekanntes Geburtsjahr': speichere Tag und Monat, während das Alter diskret bleibt."
                ],
                proTip: "In den Jahrestagsdetails siehst du genau, welches Jubiläum gefeiert wird."
            ),
            GuideTopic(
                id: "categories",
                category: .basics,
                icon: "tag.fill",
                iconColor: .purple,
                title: "Kategorien & Soziale Kreise",
                subtitle: "Strukturiere deine Kontakte nach deinen Lebensbereichen.",
                bulletPoints: [
                    "Standardkategorien: Familie 🏡, Freunde 🎉, Arbeit 💼, Partner ❤️, Andere 🎈.",
                    "Unbegrenzte eigene Kategorien: tippe auf '+' rechts in der Leiste für neue Gruppen (z. B. Sport, Uni, Verein).",
                    "Drag & Drop Sortierung: passe die Reihenfolge unter Einstellungen > 'Kategorien sortieren' an.",
                    "Sofortfilter: tippe auf eine Kategorieleiste, um nur die Kontakte dieser Gruppe zu sehen."
                ],
                proTip: "Halte eine eigene Kategorie gedrückt, um sie zu bearbeiten, zu verschieben oder zu löschen."
            ),
            GuideTopic(
                id: "zodiac_trivia",
                category: .events,
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Sternzeichen, Geburtssteine & Wissen",
                subtitle: "Faszinierende astrologische Details und historische Meilensteine automatisch berechnet.",
                bulletPoints: [
                    "Westliches Sternzeichen ♈: berechnet aus Tag und Monat mit Symbol und Element.",
                    "Chinesisches Sternzeichen 🐉: ermittelt aus dem Geburtsjahr für das Tierkreiszeichen.",
                    "Monatsgeburtsstein 💎: entdecke den traditionellen Edelstein des Monats und seine Symbolik.",
                    "Berühmtheiten & historische Ereignisse: erfahre, welche Persönlichkeiten am selben Tag geboren wurden."
                ],
                proTip: "Perfekt als Aufhänger für originelle und persönliche Glückwünsche!"
            ),
            GuideTopic(
                id: "blow_candle",
                category: .events,
                icon: "flame.fill",
                iconColor: .red,
                title: "Kerze Ausblasen (Am Geburtstag)",
                subtitle: "Ein magisches interaktives Ritual, das am Geburtstag zum Leben erwacht.",
                bulletPoints: [
                    "Automatische Aktivierung: hat ein Kontakt heute Geburtstag, brennt eine animierte Kerze auf der Karte.",
                    "Wünsch dir was: tippe auf die Taste, um die Kerze auszupusten.",
                    "Realistische Animation: die Flamme erlischt mit sanftem Rauch, Vibration und buntem Konfetti."
                ],
                proTip: "Du kannst das Ritual am Ehrentag so oft wiederholen, wie du möchtest."
            ),
            GuideTopic(
                id: "gifts_tracker",
                category: .giftsAndVenues,
                icon: "gift.fill",
                iconColor: .pink,
                title: "Geschenkideen & Budgetplaner",
                subtitle: "Ideen notieren, Ausgaben überwachen und rechtzeitig vorbereitet sein.",
                bulletPoints: [
                    "Umfassende Geschenkkarte: Titel, Richtpreis, Notizen, Datum (Monat.Jahr) und Onlineshop-Link.",
                    "Bearbeiten per Stift: tippe auf das Stiftsymbol neben dem Papierkorb, um Details jederzeit anzupassen.",
                    "Datum im Format Monat.Jahr: weise jedem Geschenk Monat und Jahr zu, um Anschaffungen zeitlich einzuordnen.",
                    "Kaufstatus: hake besorgte Geschenke mit einem grünen Haken ab, um offene Ideen zu sehen.",
                    "Geheime Geschenke: aktiviere 'Privates Geschenk', um Überraschungen mit Face ID zu sperren.",
                    "Budgetüberwachung: behalte Gesamtausgaben im Blick und tippe in den Statistiken, um Geschenke aufzuklappen."
                ],
                proTip: "Tippe auf den Shop-Link, um die Artikelseite im Browser zu öffnen und zu bestellen."
            ),
            GuideTopic(
                id: "smart_wishes",
                category: .events,
                icon: "wand.and.stars",
                iconColor: .teal,
                title: "Smarte Glückwunschtexte",
                subtitle: "Finde immer die treffenden Worte für jeden Anlass und Charakter.",
                bulletPoints: [
                    "Vielseitige Tonalitäten: wähle zwischen Herzlich, Lustig, Formell oder Kurz & Knackig.",
                    "Dynamische Personalisierung: bindet automatisch den Vornamen und das neue Alter ein.",
                    "1-Tap Kopieren: füge den Text direkt in WhatsApp, Messages oder Social Media ein.",
                    "Eigene Textvorlagen: speichere Lieblingsformulierungen für kommende Jahre."
                ],
                proTip: "Passe den Text vor dem Absenden an, um persönliche Erinnerungen einzufügen."
            ),
            GuideTopic(
                id: "celebration_map",
                category: .giftsAndVenues,
                icon: "map.fill",
                iconColor: .green,
                title: "Orte & Restaurantkarte (Apple Maps)",
                subtitle: "Halte Restaurants und Lieblingsorte früherer Feiern fest.",
                bulletPoints: [
                    "Orte festhalten: speichere Restaurants, Parks oder Partylocations zu jedem Kontakt.",
                    "Celebration Map: öffne die interaktive Vollbildkarte für alle Feierorte auf Apple Maps.",
                    "GPS-Standort mit 1 Fingertipp: nutze 'Aktueller Standort', um Koordinaten direkt vor Ort zu sichern.",
                    "Routenführung: tippe auf 'In Karten öffnen', um die Navigation zum Lokal zu starten."
                ],
                proTip: "Filtere Orte auf der Karte nach Geburtstagen, Jubiläen oder anstehenden Terminen."
            ),
            GuideTopic(
                id: "memory_photos",
                category: .events,
                icon: "photo.stack.fill",
                iconColor: .blue,
                title: "Polaroid-Erinnerungsfotos & Avatar-Zoom",
                subtitle: "Horizontale Galerie von Festfotos mit Bildunterschriften und Vollbildansicht.",
                bulletPoints: [
                    "Horizontale Polaroid-Galerie 📸: durchstöbere die schönsten Partyfotos direkt auf der Kontaktkarte.",
                    "Bildunterschriften & Datum ✍️: versehe jedes Foto mit einer persönlichen Notiz und dem Speicherdatum.",
                    "Vollbild-Vorschau: tippe auf ein Foto, um es im Vollbildmodus anzuzeigen.",
                    "Vergrößerbarer Avatar: tippe auf das Hauptprofilbild, um es hochauflösend anzuzeigen."
                ],
                proTip: "Nimm spontan Fotos mit der Kamera auf oder wähle mehrere Bilder gleichzeitig aus deiner Fotomediathek!"
            ),
            GuideTopic(
                id: "calendar",
                category: .insightsAndCalendar,
                icon: "calendar",
                iconColor: .indigo,
                title: "Integrierter Geburtstagskalender",
                subtitle: "Vollständige visuelle Übersicht Monat für Monat oder für das gesamte Jahr.",
                bulletPoints: [
                    "Monatsraster: Tage mit Festen haben einen Farbfleck; tippe darauf für alle Termine.",
                    "Jahresüberblick: überblicke alle 12 Monate gleichzeitig, um intensive Phasen zu erkennen.",
                    "Schnell anlegen: tippe auf ein beliebiges Datum im Kalender, um direkt ein Ereignis zu erstellen.",
                    "Bequeme Navigation durch Jahre, um Urlaube und Partys vorausschauend zu planen."
                ],
                proTip: "In der Monatsansicht siehst du die Resttage für alle Geburtstage des Monats."
            ),
            GuideTopic(
                id: "insights",
                category: .insightsAndCalendar,
                icon: "chart.bar.xaxis",
                iconColor: .purple,
                title: "Statistiken & Analysen (Candle Insights)",
                subtitle: "Entdecke spannende Muster, Trends und Kennzahlen über deinen Bekanntenkreis.",
                bulletPoints: [
                    "Jahresfortschritt: verfolge den Prozentsatz vergangener und verbleibender Feste mit Countdown zum nächsten Ereignis.",
                    "Interaktives 12-Monats-Diagramm: tippe auf Monatsbalken, um Feiern aufzuklappen und direkt zu Details zu springen.",
                    "Jahreszeiten-Horizont: sieh deine aktivste Jahreszeit und entdecke Frühling, Sommer, Herbst und Winter.",
                    "Sternzeichen-Übersicht: tippe auf die Tierkreiskarte für alle 12 Sternzeichen aufgeteilt nach den 4 Elementen.",
                    "Runde Geburtstage: erfahre auf einen Blick, wer Meilensteine (18, 30, 40, 50+) feiert.",
                    "Geschenkbudget & Gesamtausgaben: tippe auf die Ausgaben oder offenen Ideen, um alle gekauften oder geplanten Geschenke zu sehen, mit Face ID / Touch ID für vertrauliche Präsente."
                ],
                proTip: "Tippe auf Personen oder Feste, um direkt ihre Detailansicht zu öffnen. Private Kontakte bleiben geschützt und sperren sich beim Verlassen automatisch."
            ),
            GuideTopic(
                id: "notifications_widgets",
                category: .customization,
                icon: "bell.badge.fill",
                iconColor: .yellow,
                title: "Smarte Erinnerungen & iOS Widgets",
                subtitle: "Pünktliche Benachrichtigungen und praktische Widgets für den schnellen Überblick.",
                bulletPoints: [
                    "Erinnerung am selben Tag: morgendliche Hinweise zur Wunschuhrzeit, um pünktlich zu gratulieren.",
                    "Voraberinnerungen: erhalte Mitteilungen 1, 2, 3 Tage oder 1 bis 2 Wochen im Voraus für Geschenke.",
                    "Home-Bildschirm Widgets: kompakte und mittlere Widgets mit Countdowns.",
                    "Sperrbildschirm & StandBy: sieh wichtige Daten auch bei gesperrtem oder ladendem iPhone.",
                    "Testbenachrichtigung: sende einen Probelauf aus den Einstellungen, um Berechtigungen zu prüfen."
                ],
                proTip: "Lege in den Einstellungen deine bevorzugte Uhrzeit für Erinnerungen fest."
            ),
            GuideTopic(
                id: "privacy_biometrics",
                category: .privacyAndBackup,
                icon: "lock.shield.fill",
                iconColor: .green,
                title: "Face ID / Touch ID Tresor",
                subtitle: "Maximale Diskretion für vertrauliche Termine und Geschenküberraschungen.",
                bulletPoints: [
                    "Private Kontakte: aktiviere 'Privater Kontakt', um Namen und Daten auf dem Dashboard zu maskieren.",
                    "Biometrische Freigabe & Code: greife per Face ID, Touch ID oder iPhone-Code sicher zu.",
                    "Geheime Geschenke: halte Überraschungen vor neugierigen Blicken auf deinem Gerät verborgen.",
                    "100 % lokale Speicherung: deine Daten werden niemals an fremde Server gesendet."
                ],
                proTip: "Tippe jederzeit auf das Schloss-Symbol, um den Tresor sofort wieder zu verriegeln."
            ),
            GuideTopic(
                id: "sync_backup",
                category: .privacyAndBackup,
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Kontakte, Backups & iCloud",
                subtitle: "Deine Daten jederzeit sicher, exportierbar und synchron.",
                bulletPoints: [
                    "Adressbuch-Import: lade mit 1 Antippen alle Geburtstage aus deinen iOS-Kontakten.",
                    "Vollständiges JSON-Backup: exportiere das Archiv, um es auf einem anderen Gerät wiederherzustellen.",
                    "CSV-Export: erstelle eine Tabelle, die sich in Excel, Numbers oder Google Tabellen öffnen lässt.",
                    "Kalenderdatei (.ics): synchronisiere deine Termine mit Google Calendar und Outlook.",
                    "iCloud Sync: automatische Hintergrund-Synchronisation auf all deinen Apple-Geräten."
                ],
                proTip: "Erstelle regelmäßige Backups, um Geschenkideen und Fotoalben abzusichern."
            ),
            GuideTopic(
                id: "customization",
                category: .customization,
                icon: "paintpalette.fill",
                iconColor: store.accentPrimary,
                title: "Farbthemen & Erscheinungsbild",
                subtitle: "Passe Candle an deinen persönlichen Stil und Geschmack an.",
                bulletPoints: [
                    "16 Akzentfarben: Candle Amber, Sunset Coral, Emerald Mint, Royal Purple, Sapphire Blue und viele mehr.",
                    "Hell-, Dunkel- oder Systemmodus: orientiert sich an deiner Systemeinstellung oder Vorgabe.",
                    "Eigene Profilfarben: weise Kontakten individuelle Farbtöne oder Farbverläufe zu.",
                    "Edles natives Design: flüssige Animationen, ergonomische Karten und integriertes Tastatur-Feedback."
                ],
                proTip: "Die gewählte Akzentfarbe färbt Tasten, Symbole, Diagramme und Widgets ein."
            )
        ]
    }
    
    private func portugueseTopics() -> [GuideTopic] {
        [
            GuideTopic(
                id: "dashboard",
                category: .basics,
                icon: "sparkles",
                iconColor: store.accentPrimary,
                title: "Painel & Hero Card",
                subtitle: "Sua visão geral para manter as próximas comemorações sempre no radar.",
                bulletPoints: [
                    "Hero Card em destaque: exibe o próximo aniversariante com foto, contagem regressiva e idade.",
                    "Anel de progresso: preenche-se conforme a data especial vai se aproximando.",
                    "Botão Celebrar ✨: solte confetes festivos com resposta tátil instantânea.",
                    "Filtros de período: alterne entre 'Todos', 'Este mês' ou 'Este ano' para planejar com calma.",
                    "Gestos rápidos: deslize para a direita para Ajustes ou para a esquerda para Estatísticas."
                ],
                proTip: "Toque em qualquer cartão para ver detalhes completos, ideias de presentes e locais."
            ),
            GuideTopic(
                id: "event_types",
                category: .events,
                icon: "calendar.badge.clock",
                iconColor: .orange,
                title: "Tipos de Eventos & Recorrências",
                subtitle: "Gerencie aniversários, bodas, dias do nome e datas marcantes.",
                bulletPoints: [
                    "Aniversários 🎂: cálculo automático da idade, dia da semana e próxima comemoração.",
                    "Aniversários de Namoro/Casamento ❤️: suporte a datas anuais e 'Mesversários' mensais.",
                    "Dias do Nome 🌟: comemore santos e onomásticos sem precisar saber o ano de nascimento.",
                    "Eventos Especiais ✨: datas únicas (formatura, festa) ou marcos periódicos.",
                    "Opção 'Ano de nascimento desconhecido': guarde dia e mês mantendo a idade privada."
                ],
                proTip: "Nos detalhes de aniversário de casal, veja qual marco de união está sendo celebrado."
            ),
            GuideTopic(
                id: "categories",
                category: .basics,
                icon: "tag.fill",
                iconColor: .purple,
                title: "Categorias & Círculos Sociais",
                subtitle: "Organize seus contatos de acordo com seus círculos de convivência.",
                bulletPoints: [
                    "Categorias padrão: Família 🏡, Amigos 🎉, Trabalho 💼, Parceiro ❤️, Outro 🎈.",
                    "Categorias personalizadas ilimitadas: toque em '+' para criar grupos sob medida (ex. Futebol, Faculdade, Vizinhos).",
                    "Organização por Drag & Drop: personalize a ordem em Ajustes > 'Reordenar Categorias'.",
                    "Filtro instantâneo: toque em uma categoria na barra superior para exibir apenas os contatos daquele grupo."
                ],
                proTip: "Pressione e segure qualquer categoria personalizada para editar, mover ou excluir."
            ),
            GuideTopic(
                id: "zodiac_trivia",
                category: .events,
                icon: "moon.stars.fill",
                iconColor: .indigo,
                title: "Zodíaco, Pedras do Mês & Curiosidades",
                subtitle: "Detalhes astrológicos e fatos históricos calculados automaticamente.",
                bulletPoints: [
                    "Signo do Zodíaco Ocidental ♈: calculado pelo dia e mês com símbolo e elemento.",
                    "Zodíaco Chinês 🐉: revelado pelo ano de nascimento para descobrir o animal do horóscopo.",
                    "Pedra do Mês (Birthstone) 💎: descubra a gema tradicional do mês e seu significado.",
                    "Famosos e fatos históricos: veja quais celebridades e figuras históricas nasceram no mesmo dia."
                ],
                proTip: "Essas curiosidades são ótimas para quebrar o gelo e escrever mensagens inesquecíveis!"
            ),
            GuideTopic(
                id: "blow_candle",
                category: .events,
                icon: "flame.fill",
                iconColor: .red,
                title: "Apagar a Vela (Dia do Aniversário)",
                subtitle: "Um ritual mágico e interativo que ganha vida no dia da festa.",
                bulletPoints: [
                    "Ativação automática: no dia do aniversário, uma vela acesa animada surge no cartão.",
                    "Faça um pedido: toque no botão para apagar a vela.",
                    "Animação realista: a chama se apaga com fumaça suave, vibração e chuva de confetes."
                ],
                proTip: "Você pode reviver o ritual e apagar a vela quantas vezes quiser durante o dia."
            ),
            GuideTopic(
                id: "gifts_tracker",
                category: .giftsAndVenues,
                icon: "gift.fill",
                iconColor: .pink,
                title: "Ideias de Presentes & Orçamento",
                subtitle: "Anote ideias, monitore gastos e nunca seja pego de surpresa.",
                bulletPoints: [
                    "Ficha de presente completa: adicione título, valor estimado, notas, data (mês.ano) e link da loja.",
                    "Edição com lápis: toque no ícone de lápis ao lado da lixeira para editar qualquer detalhe do presente.",
                    "Data mês.ano: defina mês e ano para cada presente para acompanhar quando foi planejado ou comprado.",
                    "Status de compra: marque presentes como 'Comprados' para ver o que ainda falta adquirir.",
                    "Presentes Secretos: ative 'Presente Privado' para trancá-lo com Face ID / Touch ID.",
                    "Acompanhamento financeiro: visualize o gasto total e toque para ver todos os presentes nas Estatísticas."
                ],
                proTip: "Toque no link da loja para abrir a página web e concluir a compra rapidamente."
            ),
            GuideTopic(
                id: "smart_wishes",
                category: .events,
                icon: "wand.and.stars",
                iconColor: .teal,
                title: "Mensagens Inteligentes (Smart Wishes)",
                subtitle: "Encontre sempre as palavras certas para qualquer ocasião.",
                bulletPoints: [
                    "Tons diversificados: escolha entre Afetuoso, Divertido, Formal ou Curto & Marcante.",
                    "Personalização dinâmica: inclui automaticamente o nome e a nova idade da pessoa.",
                    "Cópia em 1 toque: cole diretamente no WhatsApp, Mensagens, Instagram ou Telegram.",
                    "Modelos salvos: guarde seus textos favoritos para reutilizar nos próximos anos."
                ],
                proTip: "Você pode ajustar o texto antes de enviar para adicionar piadas internas ou lembranças."
            ),
            GuideTopic(
                id: "celebration_map",
                category: .giftsAndVenues,
                icon: "map.fill",
                iconColor: .green,
                title: "Locais de Festa & Apple Maps",
                subtitle: "Guarde restaurantes e espaços onde você comemorou momentos especiais.",
                bulletPoints: [
                    "Salve locais: anote restaurantes, parques ou locais favoritos para cada contato.",
                    "Celebration Map: abra o mapa interativo para ver todas as localizações no Apple Maps.",
                    "GPS em 1 toque: use 'Localização Atual' no local para salvar as coordenadas na hora.",
                    "Itinerário passo a passo: toque em 'Abrir no Mapas' para iniciar a navegação até o local."
                ],
                proTip: "Filtre locais no mapa por aniversários, bodas ou próximas comemorações."
            ),
            GuideTopic(
                id: "memory_photos",
                category: .events,
                icon: "photo.stack.fill",
                iconColor: .blue,
                title: "Fotos de Lembrança em Estilo Polaroid & Avatar",
                subtitle: "Galeria horizontal de fotos das comemorações com legendas e visualização em tela cheia.",
                bulletPoints: [
                    "Galeria Polaroid horizontal 📸: navegue pelas fotos mais marcantes das festas diretamente no perfil do contato.",
                    "Legendas e Datas ✍️: dê uma nota de carinho a cada foto junto com a data registrada.",
                    "Visualização em Tela Cheia: toque em qualquer foto para ampliá-la na tela inteira.",
                    "Avatar com zoom: toque no avatar principal do contato para vê-lo em alta definição."
                ],
                proTip: "Tire fotos na hora com a câmera ou selecione várias de uma vez na sua biblioteca de fotos!"
            ),
            GuideTopic(
                id: "calendar",
                category: .insightsAndCalendar,
                icon: "calendar",
                iconColor: .indigo,
                title: "Calendário Integrado de Aniversários",
                subtitle: "Visão geral visual mês a mês ou do ano completo.",
                bulletPoints: [
                    "Grade mensal: dias com eventos exibem um ponto colorido; toque para ver os detalhes.",
                    "Visão anual panorâmica: veja os 12 meses juntos para identificar os períodos mais agitados.",
                    "Adição rápida: toque em qualquer dia do calendário para criar um evento diretamente naquela data.",
                    "Navegação simples entre anos para planejar viagens e festas futuras."
                ],
                proTip: "Na visão mensal, confira os dias restantes para cada aniversário daquele mês."
            ),
            GuideTopic(
                id: "insights",
                category: .insightsAndCalendar,
                icon: "chart.bar.xaxis",
                iconColor: .purple,
                title: "Estatísticas & Análises (Candle Insights)",
                subtitle: "Descubra padrões, métricas e curiosidades fascinantes sobre o seu círculo social.",
                bulletPoints: [
                    "Progresso Anual: veja a porcentagem de eventos realizados e restantes com contagem regressiva para a próxima comemoração.",
                    "Gráfico Mensal Interativo: toque nas barras dos 12 meses para expandir aniversários e navegar diretamente aos detalhes.",
                    "Divisão por Estações: identifique sua estação mais comemorada e explore Primavera, Verão, Outono e Inverno.",
                    "Explorador Zodiacal: toque no quadro zodiacal para ver todos os 12 signos divididos nos 4 elementos astrológicos.",
                    "Marcos de Idade: acompanhe quem completa idades marcantes (18, 30, 40, 50+) em uma lista dedicada.",
                    "Orçamento & Despesas de Presentes: toque no total gasto ou nas ideias pendentes para explorar todos os presentes comprados ou planejados, com Face ID / Touch ID para itens privados."
                ],
                proTip: "Toque em qualquer pessoa para abrir seus detalhes. Contatos privados permanecem mascarados e são bloqueados automaticamente ao sair do Insights."
            ),
            GuideTopic(
                id: "notifications_widgets",
                category: .customization,
                icon: "bell.badge.fill",
                iconColor: .yellow,
                title: "Lembretes Inteligentes & Widgets iOS",
                subtitle: "Notificações pontuais e widgets para nunca deixar passar uma data.",
                bulletPoints: [
                    "Lembretes no próprio dia: notificações matinais no horário escolhido para parabenizar a tempo.",
                    "Lembretes com antecedência: receba avisos com dias ou semanas de margem para comprar presentes.",
                    "Widgets da Tela de Início: opções compactas e médias com contagens regressivas.",
                    "Widgets de Tela Bloqueada & StandBy: consulte datas mesmo com o iPhone bloqueado ou carregando.",
                    "Teste de notificação: envie um alerta de teste em Ajustes para validar permissões."
                ],
                proTip: "Em Ajustes você pode configurar o horário padrão para receber todos os seus lembretes."
            ),
            GuideTopic(
                id: "privacy_biometrics",
                category: .privacyAndBackup,
                icon: "lock.shield.fill",
                iconColor: .green,
                title: "Cofre com Face ID / Touch ID",
                subtitle: "Privacidade absoluta para datas reservadas e presentes surpresa.",
                bulletPoints: [
                    "Contatos Privados: ative 'Contato Privado' para ocultar nomes e datas no painel principal.",
                    "Desbloqueio biométrico e código: acesse os dados via Face ID, Touch ID ou código do iPhone.",
                    "Presentes secretos: esconda ideias para que ninguém as veja mexendo no seu celular.",
                    "Armazenamento 100% local: seus dados nunca são enviados para servidores externos."
                ],
                proTip: "Toque no cadeado a qualquer momento para trancar o cofre novamente na hora."
            ),
            GuideTopic(
                id: "sync_backup",
                category: .privacyAndBackup,
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                title: "Contatos, Backup & iCloud",
                subtitle: "Suas datas sempre protegidas, transferíveis e sincronizadas.",
                bulletPoints: [
                    "Importar Contatos: adicione com 1 toque todos os aniversários da sua agenda do iOS.",
                    "Backup JSON completo: exporte o arquivo integral para restaurar em qualquer outro aparelho.",
                    "Exportação CSV: gere uma planilha formatada para abrir no Excel, Numbers ou Google Planilhas.",
                    "Arquivo de Calendário (.ics): sincronize suas datas com o Google Calendar ou Outlook.",
                    "Sincronização com iCloud: sincronização automática em segundo plano em todos os seus aparelhos Apple."
                ],
                proTip: "Exporte backups periódicos para manter notas de presentes e álbuns protegidos."
            ),
            GuideTopic(
                id: "customization",
                category: .customization,
                icon: "paintpalette.fill",
                iconColor: store.accentPrimary,
                title: "Temas de Cores & Aparência",
                subtitle: "Personalize o Candle para deixá-lo com a sua cara e preferência visual.",
                bulletPoints: [
                    "16 Cores de Destaque: Candle Amber, Sunset Coral, Emerald Mint, Royal Purple, Sapphire Blue e mais.",
                    "Modo Claro, Escuro ou Automático: acompanha o visual do sistema ou sua preferência manual.",
                    "Cores de avatar exclusivas: atribua tons e gradientes próprios para identificar contatos na hora.",
                    "Design nativo impecável: animações fluidas, cartões ergonômicos e resposta tátil em cada ação."
                ],
                proTip: "A cor de destaque escolhida colore dinamicamente botões, ícones, gráficos e widgets."
            )
        ]
    }
}
