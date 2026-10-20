import SwiftUI

// MARK: - Birthstone Info

public struct BirthstoneInfo {
    public let month: Int
    public let name: String
    public let meaning: String
    public let gemEmoji: String
    public let color: Color
    
    public static func forMonth(_ month: Int, lang: AppLanguage = .english) -> BirthstoneInfo {
        let code = lang.resolvedCode
        switch month {
        case 1:
            let name = switch code {
            case "it": "Granato"
            case "es": "Granate"
            case "fr": "Grenat"
            case "de": "Granat"
            case "pt": "Granada"
            default: "Garnet"
            }
            let meaning = switch code {
            case "it": "Protezione, costanza e lealtà"
            case "es": "Protección, constancia y lealtad"
            case "fr": "Protection, constance et loyauté"
            case "de": "Schutz, Beständigkeit und Treue"
            case "pt": "Proteção, constância e lealdade"
            default: "Protection, constancy & loyalty"
            }
            return BirthstoneInfo(
                month: 1,
                name: name,
                meaning: meaning,
                gemEmoji: "🍷",
                color: Color(red: 0.68, green: 0.12, blue: 0.18)
            )
            
        case 2:
            let name = switch code {
            case "it": "Ametista"
            case "es": "Amatista"
            case "fr": "Améthyste"
            case "de": "Amethyst"
            case "pt": "Ametista"
            default: "Amethyst"
            }
            let meaning = switch code {
            case "it": "Saggezza, pace e lucidità mentale"
            case "es": "Sabiduría, paz y lucidez mental"
            case "fr": "Sagesse, paix et clarté d'esprit"
            case "de": "Weisheit, Frieden und Klarheit"
            case "pt": "Sabedoria, paz e clareza mental"
            default: "Wisdom, peace & mental clarity"
            }
            return BirthstoneInfo(
                month: 2,
                name: name,
                meaning: meaning,
                gemEmoji: "🔮",
                color: Color(red: 0.60, green: 0.35, blue: 0.82)
            )
            
        case 3:
            let name = switch code {
            case "it": "Acquamarina"
            case "es": "Aguamarina"
            case "fr": "Aigue-marine"
            case "de": "Aquamarin"
            case "pt": "Água-marinha"
            default: "Aquamarine"
            }
            let meaning = switch code {
            case "it": "Serenità, coraggio e speranza"
            case "es": "Serenidad, coraje y esperanza"
            case "fr": "Sérénité, courage et espoir"
            case "de": "Gelassenheit, Mut und Hoffnung"
            case "pt": "Serenidade, coragem e esperança"
            default: "Serenity, courage & hope"
            }
            return BirthstoneInfo(
                month: 3,
                name: name,
                meaning: meaning,
                gemEmoji: "🧊",
                color: Color(red: 0.28, green: 0.72, blue: 0.85)
            )
            
        case 4:
            let name = switch code {
            case "it": "Diamante"
            case "es": "Diamante"
            case "fr": "Diamant"
            case "de": "Diamant"
            case "pt": "Diamante"
            default: "Diamond"
            }
            let meaning = switch code {
            case "it": "Forza eterna, purezza e invincibilità"
            case "es": "Fuerza eterna, pureza e invencibilidad"
            case "fr": "Force éternelle, pureté et invincibilité"
            case "de": "Ewige Kraft, Reinheit und Unbesiegbarkeit"
            case "pt": "Força eterna, pureza e invencibilidade"
            default: "Eternal strength, purity & invincibility"
            }
            return BirthstoneInfo(
                month: 4,
                name: name,
                meaning: meaning,
                gemEmoji: "💎",
                color: Color(red: 0.60, green: 0.85, blue: 0.98)
            )
            
        case 5:
            let name = switch code {
            case "it": "Smeraldo"
            case "es": "Esmeralda"
            case "fr": "Émeraude"
            case "de": "Smaragd"
            case "pt": "Esmeralda"
            default: "Emerald"
            }
            let meaning = switch code {
            case "it": "Rinascita, prosperità e amore profondo"
            case "es": "Renacimiento, prosperidad y amor profundo"
            case "fr": "Renaissance, prospérité et amour profond"
            case "de": "Neubeginn, Wohlstand und tiefe Liebe"
            case "pt": "Renascimento, prosperidade e amor profundo"
            default: "Rebirth, prosperity & profound love"
            }
            return BirthstoneInfo(
                month: 5,
                name: name,
                meaning: meaning,
                gemEmoji: "🍀",
                color: Color(red: 0.15, green: 0.70, blue: 0.40)
            )
            
        case 6:
            let name = switch code {
            case "it": "Perla"
            case "es": "Perla"
            case "fr": "Perle"
            case "de": "Perle"
            case "pt": "Pérola"
            default: "Pearl"
            }
            let meaning = switch code {
            case "it": "Purezza, intuizione e armonia"
            case "es": "Pureza, intuición y armonía"
            case "fr": "Pureté, intuition et harmonie"
            case "de": "Reinheit, Intuition und Harmonie"
            case "pt": "Pureza, intuição e harmonia"
            default: "Purity, intuition & harmony"
            }
            return BirthstoneInfo(
                month: 6,
                name: name,
                meaning: meaning,
                gemEmoji: "🦪",
                color: Color(red: 0.90, green: 0.86, blue: 0.80)
            )
            
        case 7:
            let name = switch code {
            case "it": "Rubino"
            case "es": "Rubí"
            case "fr": "Rubis"
            case "de": "Rubin"
            case "pt": "Rubi"
            default: "Ruby"
            }
            let meaning = switch code {
            case "it": "Passione, vitalità ed energia vitale"
            case "es": "Pasión, vitalidad y energía"
            case "fr": "Passion, vitalité et énergie"
            case "de": "Leidenschaft, Vitalität und Lebenskraft"
            case "pt": "Paixão, vitalidade e energia"
            default: "Passion, vitality & life energy"
            }
            return BirthstoneInfo(
                month: 7,
                name: name,
                meaning: meaning,
                gemEmoji: "👑",
                color: Color(red: 0.88, green: 0.15, blue: 0.28)
            )
            
        case 8:
            let name = switch code {
            case "it": "Peridoto"
            case "es": "Peridoto"
            case "fr": "Péridot"
            case "de": "Peridot"
            case "pt": "Peridoto"
            default: "Peridot"
            }
            let meaning = switch code {
            case "it": "Luminosità, fortuna e bellezza radiosa"
            case "es": "Luminosidad, buena fortuna y belleza"
            case "fr": "Lumière, chance et éclat"
            case "de": "Strahlkraft, Glück und Schönheit"
            case "pt": "Luz, boa sorte e beleza"
            default: "Radiance, good fortune & light"
            }
            return BirthstoneInfo(
                month: 8,
                name: name,
                meaning: meaning,
                gemEmoji: "🍈",
                color: Color(red: 0.62, green: 0.78, blue: 0.20)
            )
            
        case 9:
            let name = switch code {
            case "it": "Zaffiro"
            case "es": "Zafiro"
            case "fr": "Saphir"
            case "de": "Saphir"
            case "pt": "Safira"
            default: "Sapphire"
            }
            let meaning = switch code {
            case "it": "Saggezza, nobiltà e verità interiore"
            case "es": "Sabiduría, nobleza y verdad interior"
            case "fr": "Sagesse, noblesse et vérité intérieure"
            case "de": "Weisheit, Adel und innere Wahrheit"
            case "pt": "Sabedoria, nobreza e verdade interior"
            default: "Wisdom, nobility & inner truth"
            }
            return BirthstoneInfo(
                month: 9,
                name: name,
                meaning: meaning,
                gemEmoji: "💠",
                color: Color(red: 0.15, green: 0.38, blue: 0.85)
            )
            
        case 10:
            let name = switch code {
            case "it": "Opale"
            case "es": "Ópalo"
            case "fr": "Opale"
            case "de": "Opal"
            case "pt": "Opala"
            default: "Opal"
            }
            let meaning = switch code {
            case "it": "Creatività, speranza e ispirazione"
            case "es": "Creatividad, esperanza e inspiración"
            case "fr": "Créativité, espoir et inspiration"
            case "de": "Kreativität, Hoffnung und Inspiration"
            case "pt": "Criatividade, esperança e inspiração"
            default: "Creativity, hope & inspiration"
            }
            return BirthstoneInfo(
                month: 10,
                name: name,
                meaning: meaning,
                gemEmoji: "🌈",
                color: Color(red: 0.90, green: 0.58, blue: 0.72)
            )
            
        case 11:
            let name = switch code {
            case "it": "Topazio"
            case "es": "Topacio"
            case "fr": "Topaze"
            case "de": "Topas"
            case "pt": "Topázio"
            default: "Topaz"
            }
            let meaning = switch code {
            case "it": "Calore, amicizia sincera e ottimismo"
            case "es": "Calidez, amistad sincera y optimismo"
            case "fr": "Chaleur, amitié sincère et optimisme"
            case "de": "Wärme, aufrichtige Freundschaft und Optimismus"
            case "pt": "Calor, amizade sincera e otimismo"
            default: "Warmth, sincere friendship & optimism"
            }
            return BirthstoneInfo(
                month: 11,
                name: name,
                meaning: meaning,
                gemEmoji: "🌟",
                color: Color(red: 0.94, green: 0.62, blue: 0.16)
            )
            
        case 12:
            let name = switch code {
            case "it": "Turchese"
            case "es": "Turquesa"
            case "fr": "Turquoise"
            case "de": "Türkis"
            case "pt": "Turquesa"
            default: "Turquoise"
            }
            let meaning = switch code {
            case "it": "Tranquillità, successo e protezione"
            case "es": "Tranquilidad, éxito y protección"
            case "fr": "Tranquillité, succès et protection"
            case "de": "Ruhe, Erfolg und Schutz"
            case "pt": "Tranquilidade, sucesso e proteção"
            default: "Serenity, success & protection"
            }
            return BirthstoneInfo(
                month: 12,
                name: name,
                meaning: meaning,
                gemEmoji: "🧿",
                color: Color(red: 0.20, green: 0.74, blue: 0.76)
            )
            
        default:
            return BirthstoneInfo(
                month: month,
                name: "Gemma",
                meaning: "Luce e buona sorte",
                gemEmoji: "✨",
                color: .orange
            )
        }
    }
}

// MARK: - Famous Figures & Historical Trivia

public struct FamousPerson: Identifiable {
    public var id: String { "\(name)_\(birthYear ?? 0)" }
    public let name: String
    public let birthYear: Int?
    public let role: String
    public let emoji: String
}

public struct DayTrivia {
    public let famousPeople: [FamousPerson]
    public let funFact: String
    
    public static func forDate(month: Int, day: Int, lang: AppLanguage = .english) -> DayTrivia {
        let code = lang.resolvedCode
        
        // Rich database of prominent worldwide historical and contemporary figures across all 366 days
        let database: [(m: Int, d: Int, name: String, year: Int, roleIt: String, roleEn: String, emoji: String)] = [
            // January
            (1, 1, "Pierre de Coubertin", 1863, "Fondatore dei Giochi Olimpici moderni", "Founder of Modern Olympic Games", "🏅"),
            (1, 1, "J.D. Salinger", 1919, "Scrittore de 'Il giovane Holden'", "Author of The Catcher in the Rye", "📖"),
            (1, 2, "Isaac Asimov", 1920, "Scrittore visionario di fantascienza (Fondazione)", "Visionary Science Fiction Legend (Foundation)", "🚀"),
            (1, 3, "J.R.R. Tolkien", 1892, "Autore de 'Il Signore degli Anelli'", "Author of The Lord of the Rings", "🧙‍♂️"),
            (1, 3, "Michael Schumacher", 1969, "7 volte Campione del Mondo di Formula 1", "7-Time Formula 1 World Champion", "🏎️"),
            (1, 4, "Isaac Newton", 1643, "Fisico e scopritore della gravità (cal. gregoriano)", "Physicist & Gravitation Pioneer", "🍎"),
            (1, 5, "Hayao Miyazaki", 1941, "Maestro dell'animazione premio Oscar (Studio Ghibli)", "Oscar-Winning Animation Titan (Studio Ghibli)", "✨"),
            (1, 6, "Giovanna d'Arco", 1412, "Eroina nazionale e santa francese", "French Heroine & Saint", "⚔️"),
            (1, 7, "Nicolas Cage", 1964, "Attore premio Oscar", "Oscar-Winning Actor", "🎬"),
            (1, 7, "Lewis Hamilton", 1985, "7 volte Campione del Mondo di Formula 1", "7-Time Formula 1 World Champion", "🏎️"),
            (1, 8, "Elvis Presley", 1935, "Il Re del Rock and Roll", "The King of Rock and Roll", "🎸"),
            (1, 8, "Stephen Hawking", 1942, "Fisico teorico e cosmologo geniale", "Theoretical Physicist & Cosmologist", "🌌"),
            (1, 8, "David Bowie", 1947, "Leggenda della musica & Visionario", "Musical Icon & Visionary", "⚡️"),
            (1, 9, "Simone de Beauvoir", 1908, "Filosofa, scrittrice e femminista", "Philosopher, Author & Feminist", "✒️"),
            (1, 10, "Rod Stewart", 1945, "Leggenda della musica rock britannica", "British Rock Music Legend", "🎤"),
            (1, 11, "Alexander Hamilton", 1757, "Padre fondatore degli Stati Uniti", "US Founding Father", "📜"),
            (1, 12, "Jack London", 1876, "Scrittore de 'Il richiamo della foresta'", "Author of The Call of the Wild", "🐺"),
            (1, 13, "Orlando Bloom", 1977, "Attore celebre (Il Signore degli Anelli, Pirati dei Caraibi)", "Acclaimed Actor (Lord of the Rings, Pirates)", "🏹"),
            (1, 14, "Albert Schweitzer", 1875, "Medico e Premio Nobel per la Pace", "Physician & Nobel Peace Prize Laureate", "🕊️"),
            (1, 15, "Martin Luther King Jr.", 1929, "Premio Nobel per la Pace", "Nobel Peace Prize Laureate", "🕊️"),
            (1, 16, "Lin-Manuel Miranda", 1980, "Compositore e autore di 'Hamilton'", "Composer & Creator of Hamilton", "🎭"),
            (1, 17, "Benjamin Franklin", 1706, "Scienziato, inventore e statista", "Scientist, Inventor & Statesman", "🪁"),
            (1, 17, "Muhammad Ali", 1942, "Campione del Mondo dei Pesi Massimi", "World Heavyweight Champion", "🥊"),
            (1, 18, "A.A. Milne", 1882, "Creatore di 'Winnie the Pooh'", "Creator of Winnie the Pooh", "🧸"),
            (1, 19, "Edgar Allan Poe", 1809, "Maestro del mistero e del racconto gotico", "Master of Mystery & Macabre", "🦅"),
            (1, 19, "Paul Cézanne", 1839, "Pioniere della pittura moderna", "Pioneer of Modern Painting", "🎨"),
            (1, 20, "Federico Fellini", 1920, "Leggendario regista 5 volte premio Oscar", "Legendary 5-Time Oscar Winning Director", "🎬"),
            (1, 21, "Christian Dior", 1905, "Pioniere e maestro dell'alta moda", "Master French Fashion Designer", "👗"),
            (1, 22, "Lord Byron", 1788, "Poeta romantico inglese", "Romantic English Poet", "🖋️"),
            (1, 23, "Édouard Manet", 1832, "Maestro dell'Impressionismo moderno", "Pioneering Modern Painter", "🎨"),
            (1, 24, "Neil Diamond", 1941, "Cantautore celebre ('Sweet Caroline')", "Legendary Singer-Songwriter (Sweet Caroline)", "🎸"),
            (1, 25, "Virginia Woolf", 1882, "Grande romanziera e saggista modernista", "Iconic Modernist Novelist", "📚"),
            (1, 26, "Paul Newman", 1925, "Icona del cinema e attore premio Oscar", "Oscar-Winning Actor & Cinema Icon", "🏎️"),
            (1, 27, "Wolfgang Amadeus Mozart", 1756, "Compositore e Genio Musicale", "Composer & Musical Genius", "🎼"),
            (1, 27, "Lewis Carroll", 1832, "Autore di 'Alice nel Paese delle Meraviglie'", "Author of Alice in Wonderland", "🐇"),
            (1, 28, "Jackson Pollock", 1912, "Maestro dell'action painting astratta", "Master of Abstract Action Painting", "🎨"),
            (1, 29, "Anton Čechov", 1860, "Maestro del teatro e del racconto", "Master Playwright & Storyteller", "🎭"),
            (1, 29, "Oprah Winfrey", 1954, "Icona mondiale dei media e filantropa", "Global Media Mogul & Philanthropist", "🌟"),
            (1, 30, "Franklin D. Roosevelt", 1882, "32° Presidente USA (New Deal)", "32nd US President (New Deal)", "🏛️"),
            (1, 31, "Franz Schubert", 1797, "Grande compositore romantico viennese", "Viennese Romantic Composer", "🎻"),
            (1, 31, "Jackie Robinson", 1919, "Leggenda del baseball e dei diritti civili", "Baseball Legend & Civil Rights Pioneer", "⚾️"),
            // February
            (2, 1, "Clark Gable", 1901, "Il Re di Hollywood (Via col Vento)", "The King of Hollywood (Gone with the Wind)", "🎩"),
            (2, 2, "James Joyce", 1882, "Autore rivoluzionario di 'Ulisse'", "Revolutionary Author of Ulysses", "📖"),
            (2, 2, "Shakira", 1977, "Pop star mondiale e filantropa", "Global Music Superstar & Philanthropist", "💃"),
            (2, 3, "Felix Mendelssohn", 1809, "Grande compositore romantico", "Great Romantic Composer", "🎼"),
            (2, 4, "Rosa Parks", 1913, "Icona dei diritti civili", "Civil Rights Movement Pioneer", "🚌"),
            (2, 5, "Cristiano Ronaldo", 1985, "5 volte Pallone d'Oro e icona globale del calcio", "5-Time Ballon d'Or Winner & Football Icon", "⚽️"),
            (2, 6, "Bob Marley", 1945, "Icona mondiale del reggae e della pace", "Global Reggae & Peace Icon", "🕊️"),
            (2, 7, "Charles Dickens", 1812, "Grande romanziere dell'epoca vittoriana", "Master Victorian Novelist", "🖋️"),
            (2, 7, "Chris Rock", 1965, "Celebre comico e attore", "Acclaimed Comedian & Actor", "🎙️"),
            (2, 8, "Jules Verne", 1828, "Padre della fantascienza d'avventura", "Father of Adventure Sci-Fi", "🚀"),
            (2, 9, "Joe Pesci", 1943, "Attore premio Oscar (Quei bravi ragazzi)", "Oscar-Winning Actor (Goodfellas)", "🎬"),
            (2, 10, "Boris Pasternak", 1890, "Autore del 'Dottor Živago' e Premio Nobel", "Nobel Author of Doctor Zhivago", "📖"),
            (2, 11, "Thomas Edison", 1847, "Inventore di lampadina e fonografo", "Inventor of Phonograph & Light Bulb", "💡"),
            (2, 11, "Jennifer Aniston", 1969, "Attrice celebre nel mondo (Friends)", "Beloved World Star & Actress", "☕️"),
            (2, 12, "Charles Darwin", 1809, "Padre della teoria dell'evoluzione", "Father of Evolutionary Theory", "🐢"),
            (2, 12, "Abraham Lincoln", 1809, "16° Presidente degli Stati Uniti", "16th US President", "🎩"),
            (2, 13, "Chuck Yeager", 1923, "Pioniere dell'aviazione, primo oltre il muro del suono", "Aviation Pioneer, First to Break Sound Barrier", "✈️"),
            (2, 14, "Frederick Douglass", 1818, "Leader abolizionista e grande oratore", "Abolitionist Leader & Orator", "📜"),
            (2, 15, "Galileo Galilei", 1564, "Padre della scienza moderna e astronomo", "Father of Modern Science & Astronomer", "🔭"),
            (2, 16, "John McEnroe", 1959, "Leggenda del tennis e 7 volte campione Slam", "Tennis Legend & 7-Time Grand Slam Winner", "🎾"),
            (2, 17, "Michael Jordan", 1963, "La più grande leggenda del basket", "Greatest Basketball Legend", "🏀"),
            (2, 18, "Alessandro Volta", 1745, "Inventore della prima pila elettrica", "Inventor of the Electric Battery", "⚡️"),
            (2, 18, "John Travolta", 1954, "Icona del cinema e ballerino (Grease, Pulp Fiction)", "Iconic Film Star & Dancer", "🕺"),
            (2, 19, "Niccolò Copernico", 1473, "Astronomo della teoria eliocentrica", "Heliocentric Astronomer", "🪐"),
            (2, 20, "Kurt Cobain", 1967, "Frontman dei Nirvana e icona grunge", "Nirvana Frontman & Grunge Icon", "🎸"),
            (2, 20, "Rihanna", 1988, "Cantante pop mondiale e imprenditrice", "Global Pop Icon & Entrepreneur", "👑"),
            (2, 21, "Nina Simone", 1933, "Sacerdotessa della musica soul e jazz", "High Priestess of Soul & Jazz", "🎹"),
            (2, 22, "George Washington", 1732, "1° Presidente degli Stati Uniti", "1st US President", "🦅"),
            (2, 22, "Arthur Schopenhauer", 1788, "Filosofo celebre del pensiero moderno", "Celebrated German Philosopher", "🧠"),
            (2, 23, "Georg Friedrich Händel", 1685, "Gigante della musica barocca (Messiah)", "Baroque Titan (Messiah)", "🎼"),
            (2, 24, "Wilhelm Grimm", 1786, "Favolista dei celebri Fratelli Grimm", "Grimm Brothers Timeless Storyteller", "🏰"),
            (2, 24, "Steve Jobs", 1955, "Co-fondatore di Apple & Visionario", "Apple Co-founder & Visionary", "💻"),
            (2, 25, "George Harrison", 1943, "Chitarrista leggendario dei The Beatles", "Legendary Beatles Guitarist", "🎸"),
            (2, 26, "Victor Hugo", 1802, "Autore de 'I Miserabili' e 'Notre-Dame'", "Author of Les Misérables", "🏰"),
            (2, 27, "John Steinbeck", 1902, "Premio Nobel per la Letteratura", "Nobel Laureate in Literature", "🌾"),
            (2, 28, "Michel de Montaigne", 1533, "Filosofo e padre del saggio moderno", "Father of Modern Essay", "📖"),
            (2, 29, "Gioachino Rossini", 1792, "Grande compositore lirico (Il barbiere di Siviglia)", "Great Operatic Composer (Barber of Seville)", "🎼"),
            // March
            (3, 1, "Frédéric Chopin", 1810, "Poeta immortale del pianoforte", "Immortal Poet of the Piano", "🎹"),
            (3, 1, "Justin Bieber", 1994, "Superstar della musica pop mondiale", "Global Pop Superstar", "🎤"),
            (3, 2, "Dr. Seuss", 1904, "Autore amato di classici per l'infanzia", "Beloved Children's Author", "🎩"),
            (3, 2, "Jon Bon Jovi", 1962, "Rockstar e cantautore leggendario", "Legendary Rock Icon & Singer", "🎤"),
            (3, 3, "Alexander Graham Bell", 1847, "Pioniere del telefono e scienziato", "Telephone Pioneer & Scientist", "☎️"),
            (3, 4, "Antonio Vivaldi", 1678, "Compositore de 'Le Quattro Stagioni'", "Composer of The Four Seasons", "🎻"),
            (3, 5, "Pier Paolo Pasolini", 1922, "Scrittore e intellettuale visionario", "Visionary Writer & Thinker", "🖋️"),
            (3, 6, "Michelangelo Buonarroti", 1475, "Genio del Rinascimento (Cappella Sistina)", "Renaissance Titan (Sistine Chapel)", "🎨"),
            (3, 6, "Gabriel García Márquez", 1927, "Premio Nobel (Cent'anni di solitudine)", "Nobel Author (One Hundred Years of Solitude)", "🦋"),
            (3, 7, "Maurice Ravel", 1875, "Grande compositore francese (Boléro)", "Master French Composer (Boléro)", "🎻"),
            (3, 8, "Cyd Charisse", 1922, "Attrice e ballerina celebre dell'Età dell'Oro", "Hollywood Golden Age Dance Legend", "💃"),
            (3, 9, "Amerigo Vespucci", 1454, "Navigatore che diede il nome all'America", "Explorer who Named America", "⛵️"),
            (3, 9, "Yuri Gagarin", 1934, "Primo essere umano nello spazio", "First Human in Space", "🚀"),
            (3, 10, "Chuck Norris", 1940, "Icona pop e campione di arti marziali", "Martial Arts Champion & Pop Icon", "🥋"),
            (3, 11, "Douglas Adams", 1952, "Autore di 'Guida galattica per gli autostoppisti'", "Author of The Hitchhiker's Guide to the Galaxy", "🌌"),
            (3, 12, "Jack Kerouac", 1922, "Scrittore di 'Sulla Strada' e icona Beat", "Author of On the Road & Beat Icon", "🚗"),
            (3, 13, "William Herschel", 1738, "Astronomo scopritore del pianeta Urano", "Astronomer who Discovered Planet Uranus", "🔭"),
            (3, 14, "Albert Einstein", 1879, "Premio Nobel, padre della Relatività", "Nobel Physicist (Relativity)", "🌌"),
            (3, 14, "Stephen Curry", 1988, "4 volte campione NBA e tiratore leggendario", "4-Time NBA Champion & 3-Point Legend", "🏀"),
            (3, 15, "Andrew Jackson", 1767, "7° Presidente degli Stati Uniti", "7th US President", "🏛️"),
            (3, 16, "James Madison", 1751, "4° Presidente USA e Padre della Costituzione", "4th US President & Father of Constitution", "📜"),
            (3, 17, "Nat King Cole", 1919, "Voce vellutata e pianista jazz leggendario", "Legendary Velvet Vocalist & Jazz Pianist", "🎙️"),
            (3, 18, "Rudolf Diesel", 1858, "Ingegnere e inventore del motore diesel", "Engineer & Inventor of the Diesel Engine", "⚙️"),
            (3, 19, "Bruce Willis", 1955, "Superstar del cinema d'azione (Die Hard)", "Action Cinema Superstar", "💥"),
            (3, 20, "Spike Lee", 1957, "Regista premio Oscar e pioniere del cinema", "Oscar-Winning Visionary Director", "🎥"),
            (3, 21, "Johann Sebastian Bach", 1685, "Gigante della musica barocca", "Baroque Music Titan", "🎹"),
            (3, 21, "Ayrton Senna", 1960, "Tre volte Campione del Mondo di Formula 1", "3-Time Formula 1 World Champion", "🏎️"),
            (3, 22, "Marcel Marceau", 1923, "Il più celebre maestro dell'arte mimica", "The World's Greatest Mime", "🎭"),
            (3, 23, "Akira Kurosawa", 1910, "Maestro del cinema mondiale (I sette samurai)", "Legendary Cinematic Master (Seven Samurai)", "🎬"),
            (3, 24, "Harry Houdini", 1874, "Il più leggendario illusionista della storia", "The Most Legendary Illusionist", "🗝️"),
            (3, 25, "Elton John", 1947, "Icona mondiale della musica e pianista", "Global Music Legend & Pianist", "👓"),
            (3, 26, "Robert Frost", 1874, "Quattro volte premio Pulitzer per la poesia", "Four-Time Pulitzer Winning Poet", "❄️"),
            (3, 27, "Quentin Tarantino", 1963, "Regista e sceneggiatore visionario", "Visionary Director & Screenwriter", "🎬"),
            (3, 27, "Mariah Carey", 1969, "Superstar della musica con oltre 200 milioni di dischi", "Chart-Topping Music Legend", "🦋"),
            (3, 28, "Raffaello Sanzio", 1483, "Maestro supremo del Rinascimento", "Supreme Renaissance Master", "🎨"),
            (3, 28, "Lady Gaga", 1986, "Icona pop globale e attrice premiata Oscar", "Pop Icon & Oscar-Winning Artist", "🌟"),
            (3, 29, "Vangelis", 1943, "Compositore premio Oscar (Momenti di gloria, Blade Runner)", "Oscar-Winning Composer (Blade Runner)", "🎹"),
            (3, 30, "Vincent van Gogh", 1853, "Pittore post-impressionista (Notte Stellata)", "Post-Impressionist Painter (Starry Night)", "🌻"),
            (3, 30, "Céline Dion", 1968, "Voce leggendaria della musica mondiale", "Legendary Vocalist & Pop Icon", "🎤"),
            (3, 31, "René Descartes", 1596, "Filosofo e matematico ('Cogito ergo sum')", "Philosopher ('Cogito ergo sum')", "📐"),
            // April
            (4, 1, "Sergej Rachmaninov", 1873, "Virtuoso leggendario del pianoforte", "Virtuoso Pianist & Composer", "🎹"),
            (4, 2, "Hans Christian Andersen", 1805, "Scrittore celebre di favole immortali", "Master of Timeless Fairy Tales", "🧜‍♀️"),
            (4, 3, "Marlon Brando", 1924, "Gigante indiscusso del cinema (Il Padrino)", "Cinema Legend (The Godfather)", "🎬"),
            (4, 4, "Maya Angelou", 1928, "Poetessa iconica e attivista dei diritti civili", "Iconic Poet & Civil Rights Activist", "🕊️"),
            (4, 5, "Bette Davis", 1908, "Due volte premio Oscar e icona del cinema classico", "Two-Time Oscar Winner & Cinema Legend", "🎭"),
            (4, 6, "James Watson", 1928, "Biologo premio Nobel, scopritore della struttura del DNA", "Nobel Biologist, Co-Discoverer of DNA Structure", "🧬"),
            (4, 7, "Francis Ford Coppola", 1939, "Regista premio Oscar (Apocalypse Now)", "Oscar-Winning Director", "🎥"),
            (4, 8, "Vivienne Westwood", 1941, "Stilista rivoluzionaria e pioniera del punk fashion", "Revolutionary Fashion Designer & Punk Icon", "👗"),
            (4, 9, "Charles Baudelaire", 1821, "Poeta de 'I fiori del male'", "Poet of The Flowers of Evil", "🥀"),
            (4, 10, "Joseph Pulitzer", 1847, "Editore fondatore del celebre Premio Pulitzer", "Publisher & Founder of Pulitzer Prizes", "📰"),
            (4, 11, "Vincent Gallo", 1961, "Regista, attore e artista d'avanguardia", "Avant-Garde Filmmaker & Actor", "🎬"),
            (4, 12, "Montserrat Caballé", 1933, "Soprano leggendaria della lirica mondiale (Barcelona)", "Legendary Operatic Soprano (Barcelona)", "🎶"),
            (4, 13, "Thomas Jefferson", 1743, "3° Presidente USA e autore Dichiarazione Indipendenza", "3rd US President & Founding Father", "📜"),
            (4, 14, "Christiaan Huygens", 1629, "Fisico, astronomo e inventore dell'orologio a pendolo", "Pioneering Physicist & Astronomer", "🪐"),
            (4, 15, "Leonardo da Vinci", 1452, "Genio universale del Rinascimento", "Universal Renaissance Genius", "📜"),
            (4, 16, "Charlie Chaplin", 1889, "Icona mondiale del cinema", "Global Cinema Icon", "🎬"),
            (4, 17, "Karen Blixen", 1885, "Autrice de 'La mia Africa'", "Author of Out of Africa", "🦁"),
            (4, 18, "Leopold Stokowski", 1882, "Celebre direttore d'orchestra (Fantasia di Walt Disney)", "Legendary Conductor (Disney's Fantasia)", "🎼"),
            (4, 19, "Fernando Botero", 1932, "Celebre pittore e scultore colombiano", "Celebrated Painter & Sculptor", "🎨"),
            (4, 20, "Joan Miró", 1893, "Maestro del surrealismo e pioniere dell'arte", "Master Surrealist Artist", "🎨"),
            (4, 21, "Charlotte Brontë", 1816, "Autrice del capolavoro 'Jane Eyre'", "Author of Jane Eyre", "📖"),
            (4, 21, "Regina Elisabetta II", 1926, "Monarca storica del Regno Unito", "Longest-Reigning British Monarch", "👑"),
            (4, 22, "Immanuel Kant", 1724, "Filosofo della ragion pura", "Philosopher of Pure Reason", "💡"),
            (4, 22, "J. Robert Oppenheimer", 1904, "Fisico teorico e padre dell'era atomica", "Theoretical Physicist (Manhattan Project)", "⚛️"),
            (4, 23, "William Shakespeare", 1564, "Il più grande drammaturgo della storia", "The Greatest Playwright in History", "🎭"),
            (4, 23, "Max Planck", 1858, "Fisico fondatore della teoria quantistica", "Founder of Quantum Theory", "🔬"),
            (4, 24, "Barbra Streisand", 1942, "Icona mondiale della musica e del cinema (EGOT)", "Legendary EGOT Superstar", "🌟"),
            (4, 25, "Guglielmo Marconi", 1874, "Inventore della radio e Nobel per la Fisica", "Radio Pioneer & Nobel Physicist", "📻"),
            (4, 25, "Ella Fitzgerald", 1917, "La First Lady del Jazz mondiale", "The First Lady of Song (Jazz)", "🎺"),
            (4, 26, "Eugène Delacroix", 1798, "Maestro del Romanticismo ('La Libertà che guida il popolo')", "Master Romantic Painter", "🎨"),
            (4, 27, "Samuel Morse", 1791, "Inventore del telegrafo e del Codice Morse", "Inventor of Telegraph & Morse Code", "⚡️"),
            (4, 28, "Harper Lee", 1926, "Autrice de 'Il buio oltre la siepe'", "Author of To Kill a Mockingbird", "📚"),
            (4, 29, "Duke Ellington", 1899, "Leggenda e compositore del jazz", "Jazz Legend & Composer", "🎷"),
            (4, 30, "Carl Friedrich Gauss", 1777, "Il 'Principe dei Matematici'", "The Prince of Mathematicians", "📐"),
            // May
            (5, 1, "Wes Anderson", 1969, "Regista dallo stile visivo inconfondibile", "Visionary Stylist Director", "🎬"),
            (5, 2, "David Beckham", 1975, "Icona globale del calcio e dello stile", "Global Football & Style Icon", "⚽️"),
            (5, 3, "Niccolò Machiavelli", 1469, "Autore de 'Il Principe' e padre della scienza politica", "Father of Modern Political Science", "📜"),
            (5, 4, "Audrey Hepburn", 1929, "Icona di eleganza, attrice e filantropa", "Actress, Style Icon & Philanthropist", "👑"),
            (5, 5, "Karl Marx", 1818, "Filosofo ed economista politico", "Philosopher & Economist", "📕"),
            (5, 5, "Adele", 1988, "Superstar della musica mondiale vincitrice di 16 Grammy", "Global Music Superstar & 16-Time Grammy Winner", "🎤"),
            (5, 6, "Sigmund Freud", 1856, "Padre fondatore della psicoanalisi", "Father of Psychoanalysis", "🛋️"),
            (5, 6, "George Clooney", 1961, "Attore premio Oscar e regista", "Oscar-Winning Actor & Filmmaker", "🎬"),
            (5, 7, "Johannes Brahms", 1833, "Maestro della musica classica tedesca", "Master Classical Composer", "🎼"),
            (5, 7, "Pëtr Čajkovskij", 1840, "Compositore de 'Il lago dei cigni'", "Composer of Swan Lake & Nutcracker", "🩰"),
            (5, 8, "Harry S. Truman", 1884, "33° Presidente degli Stati Uniti", "33rd US President", "🏛️"),
            (5, 9, "Howard Carter", 1874, "Archeologo scopritore della tomba di Tutankhamon", "Archaeologist who Discovered King Tut's Tomb", "🏺"),
            (5, 10, "Fred Astaire", 1899, "Il più grande ballerino della storia del cinema", "Greatest Dancer of Film History", "🎩"),
            (5, 11, "Salvador Dalí", 1904, "Maestro del surrealismo", "Master Surrealist Artist", "🕰️"),
            (5, 11, "Richard Feynman", 1918, "Fisico geniale e divulgatore Nobel", "Genius Nobel Physicist", "🌌"),
            (5, 12, "Florence Nightingale", 1820, "Fondatrice dell'assistenza infermieristica moderna", "Founder of Modern Nursing", "🕯️"),
            (5, 13, "Stevie Wonder", 1950, "Leggenda della musica soul e R&B", "Soul & Motown Music Legend", "🎹"),
            (5, 14, "George Lucas", 1944, "Creatore della saga di Star Wars", "Creator of Star Wars Saga", "🪐"),
            (5, 14, "Mark Zuckerberg", 1984, "Fondatore di Facebook e Meta", "Founder of Facebook & Meta", "💻"),
            (5, 15, "Claudio Monteverdi", 1567, "Padre dell'opera lirica moderna", "Father of Modern Opera", "🎻"),
            (5, 16, "Pierce Brosnan", 1953, "Attore celebre per James Bond", "Beloved 007 Cinema Star", "🍸"),
            (5, 17, "Enya", 1961, "Cantautrice irlandese e icona della musica celtica", "Grammy-Winning Celtic Music Icon", "✨"),
            (5, 18, "Papa Giovanni Paolo II", 1920, "Pontefice storico e guida spirituale", "Historic Pope & Global Peacemaker", "🕊️"),
            (5, 19, "Malcolm X", 1925, "Leader per i diritti civili", "Human Rights Leader", "✊"),
            (5, 20, "Honoré de Balzac", 1799, "Autore della 'Commedia umana'", "Master Realist Novelist", "🖋️"),
            (5, 21, "Albrecht Dürer", 1471, "Maestro dell'incisione rinascimentale", "Renaissance Master Printmaker", "🎨"),
            (5, 22, "Richard Wagner", 1813, "Compositore d'opera titanico", "Titan of Epic Opera", "🎭"),
            (5, 22, "Arthur Conan Doyle", 1859, "Creatore di Sherlock Holmes", "Creator of Sherlock Holmes", "🔍"),
            (5, 23, "Carl Linnaeus", 1707, "Padre della moderna classificazione botanica e zoologica", "Father of Modern Biological Taxonomy", "🌿"),
            (5, 24, "Regina Vittoria", 1819, "Sovrana dell'Impero Britannico", "Monarch of the British Victorian Era", "👑"),
            (5, 24, "Bob Dylan", 1941, "Poeta della musica e Premio Nobel", "Music Legend & Nobel Laureate", "🎸"),
            (5, 25, "Ralph Waldo Emerson", 1803, "Filosofo dell'autosufficienza e poeta", "Philosopher of Self-Reliance", "🍃"),
            (5, 25, "Cillian Murphy", 1976, "Attore premio Oscar (Oppenheimer, Peaky Blinders)", "Oscar-Winning Actor (Oppenheimer)", "🎭"),
            (5, 26, "Miles Davis", 1926, "Trombettista e innovatore del jazz", "Jazz Innovator & Trumpeter", "🎺"),
            (5, 27, "Isadora Duncan", 1877, "Pioniera rivoluzionaria della danza moderna", "Pioneer of Modern Dance", "💃"),
            (5, 28, "Kylie Minogue", 1968, "Superstar della musica pop mondiale", "Global Pop Music Superstar", "✨"),
            (5, 29, "John F. Kennedy", 1917, "35° Presidente degli Stati Uniti", "35th US President", "🇺🇸"),
            (5, 30, "Peter Fabergé", 1846, "Maestro orafo delle leggendarie Uova Imperiali", "Jeweler of Imperial Fabergé Eggs", "💎"),
            (5, 31, "Walt Whitman", 1819, "Poeta celebre di 'Foglie d'erba'", "Poet of Leaves of Grass", "🌿"),
            (5, 31, "Clint Eastwood", 1930, "Attore leggendario e regista 4 volte Oscar", "Legendary Actor & 4-Time Oscar Director", "🤠"),
            // June
            (6, 1, "Marilyn Monroe", 1926, "Icona senza tempo del cinema", "Timeless Cinema Icon", "🌟"),
            (6, 1, "Morgan Freeman", 1937, "Attore premio Oscar dalla voce inconfondibile", "Oscar-Winning Actor with Iconic Voice", "🎬"),
            (6, 2, "Thomas Hardy", 1840, "Grande romanziere e poeta vittoriano", "Great Victorian Novelist & Poet", "📖"),
            (6, 3, "Rafael Nadal", 1986, "Leggenda del tennis e 22 volte Slam", "Tennis Legend & 22-Time Grand Slam Winner", "🎾"),
            (6, 4, "Angelina Jolie", 1975, "Attrice premio Oscar e filantropa", "Oscar-Winning Actress & Humanitarian", "✨"),
            (6, 5, "Federico García Lorca", 1898, "Grande poeta e drammaturgo spagnolo", "Celebrated Spanish Poet & Playwright", "🌹"),
            (6, 6, "Diego Velázquez", 1599, "Maestro barocco (Las Meninas)", "Baroque Master Painter", "🎨"),
            (6, 6, "Alexander Pushkin", 1799, "Padre della moderna letteratura russa", "Father of Modern Russian Literature", "✍️"),
            (6, 7, "Paul Gauguin", 1848, "Maestro post-impressionista", "Post-Impressionist Master", "🌺"),
            (6, 8, "Frank Lloyd Wright", 1867, "Pioniere dell'architettura moderna", "Pioneer of Modern Organic Architecture", "🏛️"),
            (6, 9, "Johnny Depp", 1963, "Attore versatile e iconico (Pirati dei Caraibi)", "Versatile Actor & Cinema Star", "🏴‍☠️"),
            (6, 10, "Judy Garland", 1922, "Indimenticabile Dorothy ne 'Il mago di Oz'", "Legendary Star of The Wizard of Oz", "👠"),
            (6, 11, "Jacques Cousteau", 1910, "Esploratore degli abissi e oceanografo", "Ocean Explorer & Conservationist", "🌊"),
            (6, 12, "Anna Frank", 1929, "Simbolo universale di speranza (Diario)", "Universal Symbol of Hope (The Diary)", "📔"),
            (6, 13, "William Butler Yeats", 1865, "Poeta premio Nobel per la Letteratura", "Nobel Laureate Poet", "🍀"),
            (6, 14, "Che Guevara", 1928, "Figura storica e rivoluzionario", "Historic Revolutionary Leader", "⭐️"),
            (6, 15, "Edvard Grieg", 1843, "Compositore di Peer Gynt", "Composer of Peer Gynt", "⛰️"),
            (6, 16, "Roberto Durán", 1951, "Leggenda della boxe e 4 volte campione del mondo", "Four-Weight World Boxing Champion", "🥊"),
            (6, 17, "Igor Stravinskij", 1882, "Rivoluzionario compositore della musica moderna", "Revolutionary Modern Composer", "🎼"),
            (6, 18, "Paul McCartney", 1942, "Leggenda dei The Beatles", "The Beatles Legend", "🎸"),
            (6, 19, "Blaise Pascal", 1623, "Matematico, fisico e filosofo", "Mathematician & Philosopher", "📐"),
            (6, 20, "Nicole Kidman", 1967, "Attrice premio Oscar", "Oscar-Winning Acting Star", "🎭"),
            (6, 21, "Jean-Paul Sartre", 1905, "Filosofo capofila dell'esistenzialismo", "Leader of Existentialist Philosophy", "☕️"),
            (6, 22, "Meryl Streep", 1949, "Attrice 3 volte premio Oscar", "3-Time Oscar-Winning Acting Legend", "🏆"),
            (6, 23, "Alan Turing", 1912, "Padre dell'informatica moderna e crittografo", "Father of Modern Computer Science", "💻"),
            (6, 24, "Lionel Messi", 1987, "Campione del mondo e 8 volte Pallone d'Oro", "World Champion & 8-Time Ballon d'Or", "⚽️"),
            (6, 25, "Antoni Gaudí", 1852, "Geniale architetto (Sagrada Família)", "Visionary Architect of Sagrada Família", "🏰"),
            (6, 25, "George Orwell", 1903, "Autore di '1984' e 'La fattoria degli animali'", "Author of 1984 & Animal Farm", "👁️"),
            (6, 26, "Pearl S. Buck", 1892, "Premio Nobel per la Letteratura", "Nobel Laureate in Literature", "🌏"),
            (6, 26, "Ariana Grande", 1993, "Pop star globale vincitrice di Grammy", "Global Pop Superstar & Grammy Winner", "🌟"),
            (6, 27, "Helen Keller", 1880, "Scrittrice e attivista per i disabili", "Inspiring Author & Advocate", "🌻"),
            (6, 27, "Vera Wang", 1949, "Iconica stilista di alta moda mondiale", "Iconic Fashion Designer", "👗"),
            (6, 28, "Jean-Jacques Rousseau", 1712, "Filosofo politico dell'Illuminismo", "Enlightenment Political Philosopher", "📜"),
            (6, 28, "Elon Musk", 1971, "Imprenditore aerospaziale e tecnologico", "Tech & Aerospace Entrepreneur", "🚀"),
            (6, 29, "Antoine de Saint-Exupéry", 1900, "Aviatore e autore de 'Il Piccolo Principe'", "Aviator & Author of The Little Prince", "👑"),
            (6, 30, "Mike Tyson", 1966, "Il più giovane campione mondiale dei pesi massimi", "Youngest World Heavyweight Boxing Champion", "🥊"),
            // July
            (7, 1, "Lady Diana", 1961, "Principessa di Galles e icona umanitaria", "Princess of Wales & Humanitarian Icon", "💖"),
            (7, 2, "Hermann Hesse", 1877, "Autore premio Nobel (Siddhartha)", "Nobel Author of Siddhartha", "🧘"),
            (7, 2, "Margot Robbie", 1990, "Attrice acclamata e produttrice (Barbie)", "Acclaimed Actress & Producer (Barbie)", "🎀"),
            (7, 3, "Franz Kafka", 1883, "Autore visionario ('Le Metamorfosi')", "Visionary Author (The Metamorphosis)", "🪲"),
            (7, 3, "Tom Cruise", 1962, "Superstar mondiale del cinema d'azione", "Global Cinema Action Superstar", "🎬"),
            (7, 4, "Giuseppe Garibaldi", 1807, "L'Eroe dei Due Mondi", "Hero of the Two Worlds", "🗡️"),
            (7, 5, "Jean Cocteau", 1889, "Poeta, drammaturgo e artista d'avanguardia", "Avant-Garde Artist & Poet", "🎨"),
            (7, 6, "Frida Kahlo", 1907, "Rivoluzionaria pittrice messicana", "Revolutionary Mexican Painter", "🌺"),
            (7, 6, "Dalai Lama (14°)", 1935, "Guida spirituale e Nobel per la Pace", "Spiritual Leader & Nobel Laureate", "🕊️"),
            (7, 7, "Gustav Mahler", 1860, "Compositore e direttore d'orchestra", "Composer & Master Conductor", "🎼"),
            (7, 7, "Ringo Starr", 1940, "Batterista dei The Beatles", "The Beatles Drummer & Musician", "🥁"),
            (7, 8, "John D. Rockefeller", 1839, "Industriale e grande filantropo", "Industrialist & Philanthropist", "🏛️"),
            (7, 9, "Tom Hanks", 1956, "Attore due volte premio Oscar (Forrest Gump)", "Two-Time Oscar-Winning Actor", "🍫"),
            (7, 10, "Nikola Tesla", 1856, "Pioniere dell'elettricità e corrente alternata", "Electrical Pioneer & AC Inventor", "⚡️"),
            (7, 10, "Marcel Proust", 1871, "Autore de 'Alla ricerca del tempo perduto'", "Author of In Search of Lost Time", "☕️"),
            (7, 11, "Giorgio Armani", 1934, "Stilista leggendario e icona della moda", "Legendary Fashion Designer & Icon", "👔"),
            (7, 12, "Giulio Cesare", -100, "Condottiero e statista dell'antica Roma", "Statesman & General of Ancient Rome", "🏛️"),
            (7, 12, "Malala Yousafzai", 1997, "Attivista per l'istruzione e Nobel per la Pace", "Education Activist & Youngest Nobel Laureate", "📖"),
            (7, 13, "Harrison Ford", 1942, "Icona del cinema (Indiana Jones, Han Solo)", "Cinema Legend (Indiana Jones)", "🤠"),
            (7, 14, "Gustav Klimt", 1862, "Maestro dell'Art Nouveau (Il Bacio)", "Art Nouveau Master (The Kiss)", "✨"),
            (7, 15, "Rembrandt", 1606, "Maestro olandese del chiaro-scuro", "Dutch Master Painter", "🎨"),
            (7, 16, "Roald Amundsen", 1872, "Primo esploratore a raggiungere il Polo Sud", "First Explorer to Reach the South Pole", "🧭"),
            (7, 17, "Angela Merkel", 1954, "Storica Cancelliera della Germania", "Historic Chancellor of Germany", "🇩🇪"),
            (7, 18, "Nelson Mandela", 1918, "Leader anti-apartheid e Nobel per la Pace", "Anti-Apartheid Leader & Nobel Laureate", "🇿🇦"),
            (7, 19, "Edgar Degas", 1834, "Maestro impressionista delle ballerine", "Impressionist Master of Dancers", "🩰"),
            (7, 20, "Francesco Petrarca", 1304, "Poeta umanista de 'Il Canzoniere'", "Renaissance Humanist Poet", "📜"),
            (7, 21, "Ernest Hemingway", 1899, "Premio Nobel (Il vecchio e il mare)", "Nobel Author (The Old Man and the Sea)", "🎣"),
            (7, 21, "Robin Williams", 1951, "Attore premio Oscar e genio della comicità", "Beloved Oscar-Winning Actor & Comedian", "🎭"),
            (7, 22, "Alessandro Magno", -356, "Uno dei più grandi conquistatori della storia", "One of History's Greatest Conquerors", "👑"),
            (7, 23, "Raymond Chandler", 1888, "Maestro della narrativa noir poliziesca", "Master of Noir Fiction", "🕵️‍♂️"),
            (7, 24, "Amelia Earhart", 1897, "Pioniera leggendaria dell'aviazione", "Pioneering Aviation Legend", "✈️"),
            (7, 25, "Rosalind Franklin", 1920, "Chimica fondamentale per la scoperta del DNA", "Pioneering Chemist Behind DNA Discovery", "🔬"),
            (7, 26, "Carl Gustav Jung", 1875, "Padre della psicologia analitica", "Founder of Analytical Psychology", "🧠"),
            (7, 26, "Stanley Kubrick", 1928, "Regista capolavoro (2001 Odissea nello spazio)", "Visionary Master Director", "📽️"),
            (7, 27, "Giosuè Carducci", 1835, "Primo italiano premio Nobel per la Letteratura", "First Italian Nobel Laureate in Literature", "📜"),
            (7, 28, "Beatrix Potter", 1866, "Creatrice di 'Peter Coniglio' e naturalista", "Creator of Peter Rabbit & Author", "🐰"),
            (7, 29, "Peter O'Toole", 1932, "Leggenda del cinema (Lawrence d'Arabia)", "Cinema Legend (Lawrence of Arabia)", "🏜️"),
            (7, 30, "Emily Brontë", 1818, "Autrice di 'Cime Tempestose'", "Author of Wuthering Heights", "🌪️"),
            (7, 30, "Henry Ford", 1863, "Pioniere della moderna industria automobilistica", "Pioneer of Modern Automobile Industry", "🚗"),
            (7, 30, "Christopher Nolan", 1970, "Regista visionario premio Oscar (Oppenheimer, Inception)", "Oscar-Winning Visionary Director (Inception)", "🎬"),
            (7, 31, "J.K. Rowling", 1965, "Autrice della saga di Harry Potter", "Author of the Harry Potter Saga", "⚡️"),
            // August
            (8, 1, "Yves Saint Laurent", 1936, "Pioniere dell'alta moda e del pret-a-porter", "High Fashion Pioneer", "👗"),
            (8, 2, "James Baldwin", 1924, "Grande scrittore e voce dei diritti civili", "Master Essayist & Civil Rights Voice", "✍️"),
            (8, 3, "Martin Sheen", 1940, "Attore acclamato (Apocalypse Now, The West Wing)", "Acclaimed Actor (Apocalypse Now, West Wing)", "🎬"),
            (8, 3, "Tom Brady", 1977, "Leggenda assoluta dell'NFL e 7 volte campione Super Bowl", "NFL Legend & 7-Time Super Bowl Champion", "🏈"),
            (8, 4, "Louis Armstrong", 1901, "Il re indiscusso della tromba e del jazz", "Legendary King of Jazz & Trumpet", "🎺"),
            (8, 4, "Barack Obama", 1961, "44° Presidente USA e Nobel per la Pace", "44th US President & Nobel Laureate", "🇺🇸"),
            (8, 5, "Neil Armstrong", 1930, "Primo essere umano a camminare sulla Luna", "First Human to Walk on the Moon", "🌕"),
            (8, 6, "Alexander Fleming", 1881, "Scopritore della penicillina e Nobel per la Medicina", "Discoverer of Penicillin & Nobel Laureate", "🔬"),
            (8, 6, "Andy Warhol", 1928, "Padre fondatore della Pop Art", "Father of Pop Art Movement", "🥫"),
            (8, 7, "Charlize Theron", 1975, "Attrice premio Oscar e filantropa", "Oscar-Winning Actress & Humanitarian", "🌟"),
            (8, 8, "Dustin Hoffman", 1937, "Due volte premio Oscar come miglior attore", "Two-Time Oscar-Winning Actor", "🎬"),
            (8, 8, "Roger Federer", 1981, "Maestro del tennis mondiale (20 Slam)", "Master of World Tennis (20 Slams)", "🎾"),
            (8, 9, "Whitney Houston", 1963, "Voce ineguagliabile della musica mondiale", "Iconic & Unrivaled Vocalist", "🎤"),
            (8, 10, "Antonio Banderas", 1960, "Celebre attore internazionale", "Celebrated International Actor", "🎭"),
            (8, 11, "Chris Hemsworth", 1983, "Attore acclamato (Thor)", "Acclaimed Actor & Star (Thor)", "⚡️"),
            (8, 12, "Pete Sampras", 1971, "Leggenda del tennis e 14 volte campione del Grande Slam", "Tennis Legend & 14-Time Grand Slam Champion", "🎾"),
            (8, 13, "Alfred Hitchcock", 1899, "Il Maestro indiscusso della suspense", "The Master of Suspense", "🔪"),
            (8, 14, "Magic Johnson", 1959, "5 volte campione NBA e icona mondiale", "5-Time NBA Champion & Global Icon", "🏀"),
            (8, 15, "Napoleone Bonaparte", 1769, "Imperatore dei francesi e grande condottiero", "French Emperor & Legendary Military Leader", "👑"),
            (8, 16, "Charles Bukowski", 1920, "Scrittore e poeta della controcultura", "Underground Poet & Novelist", "🍺"),
            (8, 16, "Madonna", 1958, "La Regina indiscussa del Pop", "The Undisputed Queen of Pop", "👑"),
            (8, 17, "Robert De Niro", 1943, "Due volte premio Oscar e icona del cinema", "Two-Time Oscar-Winning Acting Legend", "🎬"),
            (8, 18, "Patrick Swayze", 1952, "Attore indimenticabile (Ghost, Dirty Dancing)", "Beloved Actor & Star", "💃"),
            (8, 19, "Orville Wright", 1871, "Pioniere dell'aviazione a motore", "Pioneer of Powered Flight", "✈️"),
            (8, 19, "Coco Chanel", 1883, "Rivoluzionaria stilista francese", "Revolutionary Fashion Designer", "👗"),
            (8, 20, "H.P. Lovecraft", 1890, "Maestro del terrore cosmico e fantastico", "Master of Cosmic Horror Fiction", "🐙"),
            (8, 21, "Usain Bolt", 1986, "L'uomo più veloce della storia (8 ori olimpici)", "Fastest Human in History (8 Olympic Golds)", "⚡️"),
            (8, 22, "Claude Debussy", 1862, "Compositore impressionista (Clair de Lune)", "Impressionist Classical Composer", "🌙"),
            (8, 22, "Dua Lipa", 1995, "Superstar della musica pop mondiale vincitrice di Grammy", "Global Pop Music Superstar & Grammy Winner", "✨"),
            (8, 23, "Kobe Bryant", 1978, "Leggenda dei Los Angeles Lakers (5 anelli NBA)", "Legendary NBA Champion & Icon", "🐍"),
            (8, 24, "Jorge Luis Borges", 1899, "Gigante della letteratura universale", "Titan of Universal Literature", "📚"),
            (8, 25, "Leonard Bernstein", 1918, "Compositore (West Side Story) e direttore", "Master Composer & Conductor", "🎼"),
            (8, 25, "Sean Connery", 1930, "L'inimitabile James Bond e premio Oscar", "The Iconic James Bond & Oscar Winner", "🍸"),
            (8, 25, "Tim Burton", 1958, "Regista visionario e animatore", "Visionary Director & Storyteller", "🦇"),
            (8, 26, "Madre Teresa di Calcutta", 1910, "Premio Nobel per la Pace e umanitaria", "Nobel Peace Prize Laureate & Humanitarian", "🕊️"),
            (8, 27, "G.W.F. Hegel", 1770, "Massimo filosofo dell'idealismo tedesco", "Giant of German Idealist Philosophy", "🧠"),
            (8, 28, "Johann Wolfgang von Goethe", 1749, "Genio della letteratura universale (Faust)", "Universal Literary Titan (Faust)", "📖"),
            (8, 28, "David Fincher", 1962, "Regista capolavoro (Fight Club, Se7en)", "Visionary Master Director", "🎬"),
            (8, 29, "John Locke", 1632, "Padre dell'empirismo e del liberalismo moderno", "Father of Modern Liberalism", "📜"),
            (8, 29, "Michael Jackson", 1958, "Re del Pop mondiale", "The King of Pop", "🕺"),
            (8, 30, "Mary Shelley", 1797, "Autrice del capolavoro 'Frankenstein'", "Author of Frankenstein", "⚡️"),
            (8, 30, "Warren Buffett", 1930, "Celebre investitore e filantropo", "Legendary Investor & Philanthropist", "📈"),
            (8, 31, "Maria Montessori", 1870, "Pioniera della pedagogia moderna", "Pioneer of Child-Centered Education", "🏫"),
            // September
            (9, 1, "Zendaya", 1996, "Attrice vincitrice di Emmy e icona contemporanea", "Emmy-Winning Actress & Fashion Icon", "🌟"),
            (9, 2, "Keanu Reeves", 1964, "Attore amato nel mondo (Matrix, John Wick)", "Beloved Film Icon (Matrix, John Wick)", "🕶️"),
            (9, 3, "Ferdinand Porsche", 1875, "Pioniere dell'automobile e fondatore di Porsche", "Automotive Pioneer & Founder of Porsche", "🏎️"),
            (9, 4, "Beyoncé", 1981, "Superstar musicale record di Grammy", "Record-Breaking Music Superstar", "👑"),
            (9, 5, "Freddie Mercury", 1946, "Voce leggendaria dei Queen", "Legendary Frontman of Queen", "👑"),
            (9, 6, "Jane Addams", 1860, "Pioniera sociale e Nobel per la Pace", "Pioneering Social Worker & Nobel Laureate", "🕊️"),
            (9, 7, "Regina Elisabetta I", 1533, "Monarca dell'Età dell'Oro d'Inghilterra", "Monarch of England's Golden Age", "👑"),
            (9, 8, "Peter Sellers", 1925, "Genio della commedia e maestro del travestimento", "Comic Genius & Actor", "🎩"),
            (9, 9, "Lev Tolstoj", 1828, "Autore di 'Guerra e Pace' e 'Anna Karenina'", "Author of War and Peace", "📚"),
            (9, 10, "Karl Lagerfeld", 1933, "Icona e maestro dell'alta moda", "Visionary Fashion Designer", "🕶️"),
            (9, 11, "D.H. Lawrence", 1885, "Autore celebre de 'L'amante di Lady Chatterley'", "Author of Lady Chatterley's Lover", "📖"),
            (9, 12, "Jesse Owens", 1913, "Eroe delle Olimpiadi del 1936 a Berlino", "Track & Field Legend (4 Olympic Golds)", "🥇"),
            (9, 13, "Roald Dahl", 1916, "Autore de 'La fabbrica di cioccolato'", "Beloved Children's Author", "🍫"),
            (9, 14, "Alexander von Humboldt", 1769, "Naturalista, geografo ed esploratore universale", "Universal Naturalist & Explorer", "🗺️"),
            (9, 15, "Agatha Christie", 1890, "La Regina del Giallo e dei romanzi polizieschi", "The Queen of Mystery", "🔍"),
            (9, 16, "B.B. King", 1925, "Il Re del Blues mondiale", "The King of the Blues", "🎸"),
            (9, 17, "Ken Kesey", 1935, "Autore celebre di 'Qualcuno volò sul nido del cuculo'", "Author of One Flew Over the Cuckoo's Nest", "🦅"),
            (9, 18, "Greta Garbo", 1905, "La Divina di Hollywood", "The Divine Cinema Legend", "🌟"),
            (9, 19, "Jeremy Irons", 1948, "Attore premio Oscar", "Oscar-Winning English Actor", "🎭"),
            (9, 20, "Sophia Loren", 1934, "Attrice premio Oscar e diva del cinema", "Oscar-Winning Cinema Icon", "🌹"),
            (9, 20, "George R.R. Martin", 1948, "Autore della saga letteraria 'Cronache del ghiaccio e del fuoco'", "Author of A Song of Ice and Fire (Game of Thrones)", "🐉"),
            (9, 21, "H.G. Wells", 1866, "Pioniere della fantascienza (La macchina del tempo)", "Pioneer of Science Fiction", "⏳"),
            (9, 21, "Stephen King", 1947, "Maestro della narrativa contemporanea", "Master of Suspense & Fiction", "📚"),
            (9, 22, "Michael Faraday", 1791, "Fisico scopritore dell'induzione elettromagnetica", "Father of Electromagnetism", "⚡️"),
            (9, 22, "Andrea Bocelli", 1958, "Celebre tenore e ambasciatore del belcanto", "World-Renowned Italian Tenor", "🎶"),
            (9, 23, "Cesare Augusto", -63, "Primo imperatore di Roma", "First Roman Emperor", "🏛️"),
            (9, 23, "Bruce Springsteen", 1949, "The Boss, leggenda del rock americano", "The Boss, American Rock Legend", "🎸"),
            (9, 24, "F. Scott Fitzgerald", 1896, "Autore de 'Il Grande Gatsby'", "Author of The Great Gatsby", "🍸"),
            (9, 25, "Will Smith", 1968, "Attore premio Oscar e musicista", "Oscar-Winning Actor & Star", "🎬"),
            (9, 26, "T.S. Eliot", 1888, "Poeta premio Nobel ('La terra desolata')", "Nobel Poet (The Waste Land)", "📜"),
            (9, 26, "Serena Williams", 1981, "23 volte campionessa Slam e icona mondiale del tennis", "23-Time Grand Slam Champion & Tennis Legend", "🎾"),
            (9, 27, "Gwyneth Paltrow", 1972, "Attrice premio Oscar e imprenditrice", "Oscar-Winning Actress & Entrepreneur", "💐"),
            (9, 28, "Confucio", -551, "Filosofo e maestro di saggezza", "Philosopher & Teacher of Wisdom", "🏮"),
            (9, 28, "Marcello Mastroianni", 1924, "Icona mondiale del cinema (La Dolce Vita)", "Iconic Italian Cinema Star", "🕶️"),
            (9, 28, "Brigitte Bardot", 1934, "Attrice e icona di stile francese", "French Cinema & Style Icon", "✨"),
            (9, 29, "Miguel de Cervantes", 1547, "Autore del 'Don Chisciotte'", "Author of Don Quixote", "🛡️"),
            (9, 29, "Caravaggio", 1571, "Maestro rivoluzionario della luce e dell'ombra", "Revolutionary Master of Light & Shadow", "🎨"),
            (9, 30, "Truman Capote", 1924, "Autore di 'Colazione da Tiffany' e 'A sangue freddo'", "Author of Breakfast at Tiffany's", "💎"),
            // October
            (10, 1, "Jimmy Carter", 1924, "39° Presidente USA e Nobel per la Pace", "39th US President & Nobel Peace Prize", "🕊️"),
            (10, 2, "Mahatma Gandhi", 1869, "Guida della nonviolenza e libertà", "Leader of Nonviolent Movement", "🕊️"),
            (10, 2, "Sting", 1951, "Cantautore e frontman dei The Police", "Singer-Songwriter & Frontman of The Police", "🎸"),
            (10, 3, "Stevie Ray Vaughan", 1954, "Chitarrista leggendario del blues rock", "Legendary Blues Guitar Virtuoso", "🎸"),
            (10, 4, "Buster Keaton", 1895, "Pioniere della commedia cinematografica muta", "Pioneer of Physical Silent Comedy", "🎩"),
            (10, 5, "Kate Winslet", 1975, "Attrice premio Oscar (Titanic)", "Oscar-Winning Actress", "🚢"),
            (10, 6, "Le Corbusier", 1887, "Maestro e pioniere dell'architettura moderna", "Pioneer of Modern Architecture", "🏛️"),
            (10, 7, "Desmond Tutu", 1931, "Arcivescovo e Premio Nobel per la Pace", "Archbishop & Nobel Peace Laureate", "🕊️"),
            (10, 8, "Matt Damon", 1970, "Attore premio Oscar e sceneggiatore", "Oscar-Winning Actor & Screenwriter", "🎬"),
            (10, 9, "John Lennon", 1940, "Cantautore per la pace & The Beatles", "Peace Songwriter & The Beatles", "☮️"),
            (10, 10, "Giuseppe Verdi", 1813, "Gigante dell'opera lirica italiana (Aida, Nabucco)", "Giant of Italian Opera", "🎭"),
            (10, 11, "Eleanor Roosevelt", 1884, "First Lady e pioniera dei Diritti Umani", "First Lady & Universal Human Rights Leader", "📜"),
            (10, 12, "Luciano Pavarotti", 1935, "Tenore supremo del belcanto", "Supreme Operatic Tenor", "🎶"),
            (10, 12, "Hugh Jackman", 1968, "Attore acclamato (Wolverine, The Greatest Showman)", "Celebrated Actor & Stage Performer", "🐺"),
            (10, 13, "Margaret Thatcher", 1925, "La 'Lady di Ferro', primo ministro britannico", "The Iron Lady, British Prime Minister", "🇬🇧"),
            (10, 14, "Dwight D. Eisenhower", 1890, "34° Presidente USA e generale", "34th US President & 5-Star General", "🎖️"),
            (10, 15, "Friedrich Nietzsche", 1844, "Filosofo rivoluzionario ('Così parlò Zarathustra')", "Revolutionary German Philosopher", "⚡️"),
            (10, 16, "Oscar Wilde", 1854, "Scrittore e drammaturgo dal geniale umorismo", "Genius Playwright & Author", "🌹"),
            (10, 17, "Arthur Miller", 1915, "Drammaturgo supremo ('Morte di un commesso viaggiatore')", "Master Playwright (Death of a Salesman)", "🎭"),
            (10, 18, "Chuck Berry", 1926, "Padre fondatore del Rock and Roll", "Father of Rock and Roll", "🎸"),
            (10, 19, "Subrahmanyan Chandrasekhar", 1910, "Astrofisico premio Nobel (Limite di Chandrasekhar)", "Nobel Astrophysicist (Chandrasekhar Limit)", "⭐"),
            (10, 20, "Arthur Rimbaud", 1854, "Poeta maledetto e ribelle", "Visionary Symbolist French Poet", "✍️"),
            (10, 20, "Snoop Dogg", 1971, "Icona della cultura hip-hop mondiale", "Global Hip-Hop Icon", "🎤"),
            (10, 21, "Alfred Nobel", 1833, "Inventore e fondatore del Premio Nobel", "Inventor & Founder of Nobel Prizes", "🏅"),
            (10, 21, "Ursula K. Le Guin", 1929, "Grande autrice di fantascienza e fantasy", "Master Author of Sci-Fi & Fantasy", "🐉"),
            (10, 22, "Franz Liszt", 1811, "Virtuoso supremo del pianoforte romantico", "Supreme Piano Virtuoso & Composer", "🎹"),
            (10, 23, "Pelé", 1940, "Tre volte Campione del Mondo di Calcio", "3-Time World Cup Soccer Legend", "⚽️"),
            (10, 24, "Drake", 1986, "Superstar della musica rap e R&B", "Chart-Topping Music Superstar", "🦉"),
            (10, 25, "Pablo Picasso", 1881, "Pioniere del Cubismo e gigante dell'arte", "Pioneer of Cubism & Master of Art", "🎨"),
            (10, 26, "Hillary Clinton", 1947, "Segretario di Stato e First Lady USA", "US Secretary of State & First Lady", "🏛️"),
            (10, 27, "Theodore Roosevelt", 1858, "26° Presidente USA e Nobel per la Pace", "26th US President & Nobel Laureate", "🦁"),
            (10, 27, "Sylvia Plath", 1932, "Poetessa intensa e autrice ('La campana di vetro')", "Influential Poet & Novelist", "🖋️"),
            (10, 28, "Bill Gates", 1955, "Co-fondatore di Microsoft & filantropo", "Microsoft Co-Founder & Philanthropist", "🖥️"),
            (10, 28, "Julia Roberts", 1967, "Attrice premio Oscar (Pretty Woman, Erin Brockovich)", "Oscar-Winning Actress", "💐"),
            (10, 28, "Joaquin Phoenix", 1974, "Attore premio Oscar (Joker, Il Gladiatore)", "Oscar-Winning Actor", "🃏"),
            (10, 29, "Winona Ryder", 1971, "Attrice iconica degli anni '90 e Stranger Things", "Iconic Film & TV Actress", "🎬"),
            (10, 30, "Diego Maradona", 1960, "Leggenda assoluta della storia del calcio", "Legendary Argentine Football Genius", "🔟"),
            (10, 31, "John Keats", 1795, "Grande poeta del Romanticismo inglese", "Great English Romantic Poet", "📜"),
            // November
            (11, 1, "Gary Player", 1935, "Leggenda del golf mondiale e 9 volte vincitore di Major", "Golf Legend & Career Grand Slam Winner", "⛳️"),
            (11, 1, "Tim Cook", 1960, "CEO di Apple Inc.", "CEO of Apple Inc.", "💻"),
            (11, 2, "Maria Antonietta", 1755, "Regina di Francia all'epoca della Rivoluzione", "Queen of France", "👑"),
            (11, 3, "Anna Wintour", 1949, "La più influente direttrice dell'alta moda (Vogue)", "Iconic Editor-in-Chief of Vogue", "🕶️"),
            (11, 4, "Matthew McConaughey", 1969, "Attore premio Oscar", "Oscar-Winning Actor", "🎬"),
            (11, 5, "Vivien Leigh", 1913, "Due volte premio Oscar (Via col Vento)", "Two-Time Oscar Winner (Gone with the Wind)", "🌹"),
            (11, 6, "Adolphe Sax", 1814, "Inventore del sassofono", "Inventor of the Saxophone", "🎷"),
            (11, 7, "Marie Curie", 1867, "Pioniera della radioattività, due Premi Nobel", "Pioneer in Radioactivity, Dual Nobel Winner", "🧪"),
            (11, 7, "Albert Camus", 1913, "Scrittore e filosofo Nobel ('Lo straniero')", "Nobel Author & Thinker (The Stranger)", "🌊"),
            (11, 8, "Bram Stoker", 1847, "Autore del capolavoro 'Dracula'", "Author of Dracula", "🧛‍♂️"),
            (11, 9, "Carl Sagan", 1934, "Astronomo e grande divulgatore del cosmo", "Astronomer & Cosmos Communicator", "🪐"),
            (11, 10, "Martin Lutero", 1483, "Teologo e iniziatore della Riforma protestante", "Leader of the Protestant Reformation", "📖"),
            (11, 10, "Friedrich Schiller", 1759, "Poeta dell'Inno alla Gioia", "Poet of the Ode to Joy", "🕊️"),
            (11, 11, "Fëdor Dostoevskij", 1821, "Scrittore di 'Delitto e Castigo'", "Author of Crime and Punishment", "📚"),
            (11, 11, "Kurt Vonnegut", 1922, "Autore satirico ('Mattatoio n. 5')", "Master Satirical Novelist", "🛸"),
            (11, 11, "Leonardo DiCaprio", 1974, "Attore premio Oscar e produttore (Titanic, The Revenant)", "Oscar-Winning Actor & Film Star (Titanic, Revenant)", "🎬"),
            (11, 12, "Auguste Rodin", 1840, "Scultore de 'Il Pensatore'", "Master Sculptor (The Thinker)", "🗿"),
            (11, 12, "Ryan Gosling", 1980, "Attore acclamato (Drive, La La Land)", "Acclaimed Actor & Star", "🎬"),
            (11, 13, "Robert Louis Stevenson", 1850, "Autore de 'L'isola del tesoro'", "Author of Treasure Island", "🏴‍☠️"),
            (11, 14, "Claude Monet", 1840, "Padre dell'Impressionismo pittorico", "Father of French Impressionism", "🪷"),
            (11, 15, "Georgia O'Keeffe", 1887, "Pioniera dell'arte moderna americana", "Mother of American Modernism", "🌺"),
            (11, 16, "José Saramago", 1922, "Scrittore premio Nobel per la Letteratura ('Cecità')", "Nobel Author (Blindness)", "📚"),
            (11, 17, "Martin Scorsese", 1942, "Maestro supremo del cinema mondiale (Oscar)", "Supreme Cinematic Master & Oscar Winner", "🎥"),
            (11, 18, "Margaret Atwood", 1939, "Autrice de 'Il racconto dell'ancella'", "Author of The Handmaid's Tale", "📚"),
            (11, 19, "Indira Gandhi", 1917, "Prima donna Primo Ministro dell'India", "First Female Prime Minister of India", "🇮🇳"),
            (11, 19, "Calvin Klein", 1942, "Iconico stilista e designer di moda", "Iconic Fashion Designer", "🕶️"),
            (11, 20, "Robert F. Kennedy", 1925, "Statista e procuratore generale USA", "US Attorney General & Senator", "🇺🇸"),
            (11, 21, "Voltaire", 1694, "Filosofo e scrittore simbolo dell'Illuminismo", "Enlightenment Philosopher & Writer", "🕯️"),
            (11, 22, "Charles de Gaulle", 1890, "Statista e generale francese", "French Statesman & General", "🇫🇷"),
            (11, 23, "Billy the Kid", 1859, "Celebre pistolero e leggenda del Far West", "Iconic Legend of the American Old West", "🤠"),
            (11, 24, "Baruch Spinoza", 1632, "Filosofo cardine dell'Illuminismo e della libertà di pensiero", "Master Enlightenment Philosopher", "💡"),
            (11, 25, "Andrew Carnegie", 1835, "Magnate dell'acciaio e filantropo delle biblioteche", "Industrialist & Great Philanthropist", "🏛️"),
            (11, 26, "Charles M. Schulz", 1922, "Creatore dei Peanuts e di Snoopy", "Creator of Peanuts & Snoopy", "🐶"),
            (11, 27, "Bruce Lee", 1940, "Leggenda delle arti marziali e del cinema", "Martial Arts & Cinema Legend", "🥋"),
            (11, 27, "Jimi Hendrix", 1942, "Il più innovativo chitarrista rock", "Most Innovative Rock Guitarist", "🎸"),
            (11, 28, "William Blake", 1757, "Poeta, pittore e visionario mistico", "Visionary Mystic Poet & Painter", "🐅"),
            (11, 29, "C.S. Lewis", 1898, "Autore de 'Le Cronache di Narnia'", "Author of The Chronicles of Narnia", "🦁"),
            (11, 30, "Mark Twain", 1835, "Grande autore di Tom Sawyer e Huckleberry Finn", "Legendary American Humorist & Author", "📖"),
            (11, 30, "Winston Churchill", 1874, "Statista britannico e Nobel per la Letteratura", "British Prime Minister & Nobel Laureate", "🇬🇧"),
            // December
            (12, 1, "Woody Allen", 1935, "Regista, sceneggiatore e 4 volte premio Oscar", "4-Time Oscar-Winning Filmmaker", "👓"),
            (12, 2, "Maria Callas", 1923, "La Divina, soprano immortale della lirica", "The Divine Immortal Opera Diva", "🎶"),
            (12, 2, "Gianni Versace", 1946, "Stilista rivoluzionario dell'alta moda", "Visionary Fashion Icon", "🏛️"),
            (12, 3, "Jean-Luc Godard", 1930, "Padre della Nouvelle Vague cinematografica", "Father of the French New Wave", "🎥"),
            (12, 4, "Jay-Z", 1969, "Magnate della musica e vincitore di 24 Grammy", "Music Mogul & 24-Time Grammy Winner", "👑"),
            (12, 5, "Walt Disney", 1901, "Pioniere dell'animazione e fantasia", "Animation Pioneer & Dreamer", "🏰"),
            (12, 5, "Werner Heisenberg", 1901, "Fisico del principio di indeterminazione (Nobel)", "Nobel Physicist (Uncertainty Principle)", "🔬"),
            (12, 6, "Dave Brubeck", 1920, "Pianista e compositore rivoluzionario del jazz", "Jazz Pianist & Icon (Take Five)", "🎹"),
            (12, 7, "Noam Chomsky", 1928, "Linguista teorico e filosofo contemporaneo", "Father of Modern Linguistics", "🗣️"),
            (12, 8, "Diego Rivera", 1886, "Pioniere del muralismo messicano", "Master Mexican Muralist", "🎨"),
            (12, 9, "John Milton", 1608, "Poeta universale ('Paradiso Perduto')", "Epic Poet of Paradise Lost", "📖"),
            (12, 10, "Ada Lovelace", 1815, "Prima programmatrice di computer al mondo", "World's First Computer Programmer", "💻"),
            (12, 10, "Emily Dickinson", 1830, "Grande e misteriosa poetessa americana", "Profound American Poet", "🕊️"),
            (12, 11, "Hector Berlioz", 1803, "Grande compositore romantico francese", "French Romantic Master Composer", "🎻"),
            (12, 12, "Edvard Munch", 1863, "Pittore espressionista ('L'urlo')", "Expressionist Master (The Scream)", "😱"),
            (12, 12, "Frank Sinatra", 1915, "The Voice, leggenda immortale della canzone", "The Voice, Immortal Music Legend", "🎙️"),
            (12, 13, "Taylor Swift", 1989, "Superstar della musica mondiale e 4 volte Album of the Year", "Record-Breaking Global Music Icon", "✨"),
            (12, 14, "Nostradamus", 1503, "Celebre astrologo e profeta rinascimentale", "Renaissance Astrologer & Writer", "🔮"),
            (12, 15, "Gustave Eiffel", 1832, "Ingegnere progettista della Torre Eiffel", "Designer of the Eiffel Tower", "🗼"),
            (12, 16, "Ludwig van Beethoven", 1770, "Gigante immortale della musica classica", "Immortal Titan of Classical Music", "🎻"),
            (12, 16, "Jane Austen", 1775, "Autrice di 'Orgoglio e Pregiudizio'", "Author of Pride and Prejudice", "🫖"),
            (12, 16, "Arthur C. Clarke", 1917, "Scrittore visionario di '2001 Odissea nello spazio'", "Author of 2001: A Space Odyssey", "🪐"),
            (12, 17, "Papa Francesco", 1936, "Pontefice e promotore della pace e fratellanza", "Historic Pope & Champion of Universal Peace", "🕊️"),
            (12, 18, "Steven Spielberg", 1946, "Regista leggendario (Jurassic Park, E.T.)", "Legendary Master Filmmaker", "🦖"),
            (12, 18, "Brad Pitt", 1963, "Due volte premio Oscar e superstar", "Two-Time Oscar-Winning Actor", "🎬"),
            (12, 18, "Billie Eilish", 2001, "Cantautrice due volte premio Oscar e superstar mondiale", "Two-Time Oscar & Grammy-Winning Global Star", "🥑"),
            (12, 19, "Édith Piaf", 1915, "La voce iconica di 'La Vie en Rose'", "Iconic Voice of La Vie en Rose", "🌹"),
            (12, 20, "Harvey Firestone", 1868, "Pioniere dell'industria moderna degli pneumatici", "Industrialist Pioneer of Rubber & Tires", "🛞"),
            (12, 21, "Samuel L. Jackson", 1948, "Attore iconico del cinema contemporaneo", "Legendary Cinema Actor", "🕶️"),
            (12, 22, "Giacomo Puccini", 1858, "Compositore d'opera immortale (La Bohème, Turandot)", "Immortal Opera Composer", "🎭"),
            (12, 23, "Imperatore Akihito", 1933, "125° Imperatore del Giappone", "125th Emperor of Japan", "🇯🇵"),
            (12, 24, "Howard Hughes", 1905, "Pioniere dell'aviazione e produttore", "Aviation Pioneer & Tycoon", "✈️"),
            (12, 25, "Humphrey Bogart", 1899, "Leggenda del cinema noir (Casablanca)", "Cinema Legend (Casablanca)", "🎩"),
            (12, 26, "Charles Babbage", 1791, "Padre dell'elaboratore meccanico e dell'informatica", "Father of the Mechanical Computer", "⚙️"),
            (12, 27, "Louis Pasteur", 1822, "Pioniere della microbiologia e vaccini", "Father of Microbiology & Vaccines", "🧪"),
            (12, 27, "Marlene Dietrich", 1901, "Icona del cinema e dello stile", "Legendary Cinema & Style Icon", "🌟"),
            (12, 28, "Stan Lee", 1922, "Creatore dell'Universo Marvel (Spider-Man, Avengers)", "Creator of Marvel Universe (Spider-Man, Avengers)", "🦸‍♂️"),
            (12, 28, "Denzel Washington", 1954, "Due volte premio Oscar come miglior attore", "Two-Time Oscar-Winning Actor", "🏆"),
            (12, 29, "Jude Law", 1972, "Attore cinematografico e teatrale acclamato", "Celebrated Actor & Stage Performer", "🎬"),
            (12, 30, "Rudyard Kipling", 1865, "Autore de 'Il libro della giungla' e Nobel", "Author of The Jungle Book & Nobel Laureate", "🐅"),
            (12, 30, "LeBron James", 1984, "Miglior marcatore di sempre nella NBA", "NBA All-Time Leading Scorer", "👑"),
            (12, 31, "Henri Matisse", 1869, "Maestro dei Fauves e del colore puro", "Master of Modern Color & Fauvism", "🎨"),
            (12, 31, "Anthony Hopkins", 1937, "Due volte premio Oscar (Il silenzio degli innocenti)", "Two-Time Oscar-Winning Acting Legend", "🎭")
        ]
        
        // Find exact matches for the specific day
        let exactMatches = database.filter { $0.m == month && $0.d == day }
        
        let people: [FamousPerson] = exactMatches.map { match in
            let roleText = (code == "it") ? match.roleIt : match.roleEn
            return FamousPerson(name: match.name, birthYear: match.year, role: roleText, emoji: match.emoji)
        }
        
        // Historical trivia / fun fact for the day or season
        let fact = historicalFact(month: month, day: day, lang: lang)
        
        return DayTrivia(famousPeople: people, funFact: fact)
    }
    
    private static func historicalFact(month: Int, day: Int, lang: AppLanguage) -> String {
        let code = lang.resolvedCode
        
        switch (month, day) {
        case (1, 1):
            return code == "it" ? "Nel 45 a.C. entra in vigore per la prima volta il calendario giuliano a Roma." : "In 45 BC, the Julian calendar takes effect for the very first time in Rome."
        case (2, 14):
            return code == "it" ? "Giorno di San Valentino, festa degli innamorati celebrata fin dall'epoca romana." : "Valentine's Day, celebrated as a festival of love since ancient Roman times."
        case (3, 14):
            return code == "it" ? "Si celebra a livello mondiale il Pi Day (π = 3.14), festa della matematica e delle scienze." : "World Pi Day is celebrated worldwide (π = 3.14), honoring math and sciences."
        case (4, 22):
            return code == "it" ? "Si celebra l'Earth Day (Giornata Mondiale della Terra) in oltre 190 Paesi." : "Earth Day is celebrated globally across more than 190 countries."
        case (7, 20):
            return code == "it" ? "Nel 1969 la missione Apollo 11 atterra sulla Luna: l'umanità tocca il suolo lunare." : "In 1969, Apollo 11 lands on the Moon: humankind touches lunar soil for the first time."
        case (10, 4):
            return code == "it" ? "Nel 1957 viene lanciato lo Sputnik 1, inaugurando ufficialmente l'era spaziale." : "In 1957, Sputnik 1 is launched into orbit, inaugurating the Space Age."
        case (11, 9):
            return code == "it" ? "Nel 1989 cade lo storico Muro di Berlino, simbolo di unione e libertà." : "In 1989, the historic Berlin Wall falls, symbol of unity and freedom."
        default:
            switch month {
            case 1:
                return code == "it" ? "Mese intitolato al dio romano Giano, custode delle nuove porte e degli inizi." : "Named after Janus, the Roman god of gates, transitions, and new beginnings."
            case 2:
                return code == "it" ? "Il mese più corto dell'anno, simbolo di purificazione e rinnovamento naturale." : "The shortest month of the year, historically devoted to purification and renewal."
            case 3:
                return code == "it" ? "Segna il risveglio della primavera e l'equinozio boreale, tripudio di luce." : "Brings the arrival of Spring and the vernal equinox, a burst of warmth and light."
            case 4:
                return code == "it" ? "Il mese della piena fioritura, storicamente legato alla dea dell'amore e della bellezza." : "The month of flowers in full bloom, dedicated to rebirth and nature's elegance."
            case 5:
                return code == "it" ? "Il mese più splendente della primavera, intitolato alla dea Maia, nutrice della terra." : "The vibrant peak of spring, named after Maia, goddess of growth and nurturing."
            case 6:
                return code == "it" ? "Inizia l'estate con il solstizio: il giorno con il maggior numero di ore di luce dell'anno." : "Brings the summer solstice, celebrating the longest days of sunlight in the year."
            case 7:
                return code == "it" ? "Mese ribattezzato in onore di Giulio Cesare; tempo di calore dorato e viaggi." : "Named in honor of Julius Caesar, characterized by golden sunny days and journeys."
            case 8:
                return code == "it" ? "Mese delle stelle cadenti (Perseidi) e delle notti d'estate cariche di desideri." : "Month of the Perseid meteor showers and unforgettable warm starry nights."
            case 9:
                return code == "it" ? "Mese del raccolto e dell'equinozio d'autunno: equilibrio perfetto tra giorno e notte." : "Harvest season and autumn equinox, bringing perfect balance between day and night."
            case 10:
                return code == "it" ? "Mese dalle calde sfumature foliage, castagne e atmosfere accoglienti." : "Brings colorful autumn foliage, cozy fireside evenings, and warm golden tones."
            case 11:
                return code == "it" ? "Mese della riflessione, delle sciarpe morbide e del tempo trascorso in famiglia." : "A serene month of contemplation, warm sweaters, and quality time with family."
            case 12:
                return code == "it" ? "Mese delle feste, delle candele accese e della generosità in tutto il mondo." : "Month of global festivities, glowing candles, warmth, and generous hearts."
            default:
                return "Un giorno speciale per festeggiare la vita!"
            }
        }
    }
}
