//
// Copyright © 2024 Alexander Romanov
// TerritoryCode.swift, created on 22.11.2024
//

import Foundation

public enum TerritoryCode: String, CaseIterable, Codable, Sendable {
    case abw = "ABW"
    case afg = "AFG"
    case ago = "AGO"
    case aia = "AIA"
    case alb = "ALB"
    case and = "AND"
    case ant = "ANT"
    case are = "ARE"
    case arg = "ARG"
    case arm = "ARM"
    case asm = "ASM"
    case atg = "ATG"
    case aus = "AUS"
    case aut = "AUT"
    case aze = "AZE"
    case bdi = "BDI"
    case bel = "BEL"
    case ben = "BEN"
    case bes = "BES"
    case bfa = "BFA"
    case bgd = "BGD"
    case bgr = "BGR"
    case bhr = "BHR"
    case bhs = "BHS"
    case bih = "BIH"
    case blr = "BLR"
    case blz = "BLZ"
    case bmu = "BMU"
    case bol = "BOL"
    case bra = "BRA"
    case brb = "BRB"
    case brn = "BRN"
    case btn = "BTN"
    case bwa = "BWA"
    case caf = "CAF"
    case can = "CAN"
    case che = "CHE"
    case chl = "CHL"
    case chn = "CHN"
    case civ = "CIV"
    case cmr = "CMR"
    case cod = "COD"
    case cog = "COG"
    case cok = "COK"
    case col = "COL"
    case com = "COM"
    case cpv = "CPV"
    case cri = "CRI"
    case cub = "CUB"
    case cuw = "CUW"
    case cxr = "CXR"
    case cym = "CYM"
    case cyp = "CYP"
    case cze = "CZE"
    case deu = "DEU"
    case dji = "DJI"
    case dma = "DMA"
    case dnk = "DNK"
    case dom = "DOM"
    case dza = "DZA"
    case ecu = "ECU"
    case egy = "EGY"
    case eri = "ERI"
    case esp = "ESP"
    case est = "EST"
    case eth = "ETH"
    case fin = "FIN"
    case fji = "FJI"
    case flk = "FLK"
    case fra = "FRA"
    case fro = "FRO"
    case fsm = "FSM"
    case gab = "GAB"
    case gbr = "GBR"
    case geo = "GEO"
    case ggy = "GGY"
    case gha = "GHA"
    case gib = "GIB"
    case gin = "GIN"
    case glp = "GLP"
    case gmb = "GMB"
    case gnb = "GNB"
    case gnq = "GNQ"
    case grc = "GRC"
    case grd = "GRD"
    case grl = "GRL"
    case gtm = "GTM"
    case guf = "GUF"
    case gum = "GUM"
    case guy = "GUY"
    case hkg = "HKG"
    case hnd = "HND"
    case hrv = "HRV"
    case hti = "HTI"
    case hun = "HUN"
    case idn = "IDN"
    case imn = "IMN"
    case ind = "IND"
    case irl = "IRL"
    case irq = "IRQ"
    case isl = "ISL"
    case isr = "ISR"
    case ita = "ITA"
    case jam = "JAM"
    case jey = "JEY"
    case jor = "JOR"
    case jpn = "JPN"
    case kaz = "KAZ"
    case ken = "KEN"
    case kgz = "KGZ"
    case khm = "KHM"
    case kir = "KIR"
    case kna = "KNA"
    case kor = "KOR"
    case kwt = "KWT"
    case lao = "LAO"
    case lbn = "LBN"
    case lbr = "LBR"
    case lby = "LBY"
    case lca = "LCA"
    case lie = "LIE"
    case lka = "LKA"
    case lso = "LSO"
    case ltu = "LTU"
    case lux = "LUX"
    case lva = "LVA"
    case mac = "MAC"
    case mar = "MAR"
    case mco = "MCO"
    case mda = "MDA"
    case mdg = "MDG"
    case mdv = "MDV"
    case mex = "MEX"
    case mhl = "MHL"
    case mkd = "MKD"
    case mli = "MLI"
    case mlt = "MLT"
    case mmr = "MMR"
    case mne = "MNE"
    case mng = "MNG"
    case mnp = "MNP"
    case moz = "MOZ"
    case mrt = "MRT"
    case msr = "MSR"
    case mtq = "MTQ"
    case mus = "MUS"
    case mwi = "MWI"
    case mys = "MYS"
    case myt = "MYT"
    case nam = "NAM"
    case ncl = "NCL"
    case ner = "NER"
    case nfk = "NFK"
    case nga = "NGA"
    case nic = "NIC"
    case niu = "NIU"
    case nld = "NLD"
    case nor = "NOR"
    case npl = "NPL"
    case nru = "NRU"
    case nzl = "NZL"
    case omn = "OMN"
    case pak = "PAK"
    case pan = "PAN"
    case per = "PER"
    case phl = "PHL"
    case plw = "PLW"
    case png = "PNG"
    case pol = "POL"
    case pri = "PRI"
    case prt = "PRT"
    case pry = "PRY"
    case pse = "PSE"
    case pyf = "PYF"
    case qat = "QAT"
    case reu = "REU"
    case rou = "ROU"
    case rus = "RUS"
    case rwa = "RWA"
    case sau = "SAU"
    case sen = "SEN"
    case sgp = "SGP"
    case shn = "SHN"
    case slb = "SLB"
    case sle = "SLE"
    case slv = "SLV"
    case smr = "SMR"
    case som = "SOM"
    case spm = "SPM"
    case srb = "SRB"
    case ssd = "SSD"
    case stp = "STP"
    case sur = "SUR"
    case svk = "SVK"
    case svn = "SVN"
    case swe = "SWE"
    case swz = "SWZ"
    case sxm = "SXM"
    case syc = "SYC"
    case tca = "TCA"
    case tcd = "TCD"
    case tgo = "TGO"
    case tha = "THA"
    case tjk = "TJK"
    case tkm = "TKM"
    case tls = "TLS"
    case ton = "TON"
    case tto = "TTO"
    case tun = "TUN"
    case tur = "TUR"
    case tuv = "TUV"
    case twn = "TWN"
    case tza = "TZA"
    case uga = "UGA"
    case ukr = "UKR"
    case umi = "UMI"
    case ury = "URY"
    case usa = "USA"
    case uzb = "UZB"
    case vat = "VAT"
    case vct = "VCT"
    case ven = "VEN"
    case vgb = "VGB"
    case vir = "VIR"
    case vnm = "VNM"
    case vut = "VUT"
    case wlf = "WLF"
    case wsm = "WSM"
    case yem = "YEM"
    case zaf = "ZAF"
    case zmb = "ZMB"
    case zwe = "ZWE"
}

public extension TerritoryCode {
    var displayName: String {
        switch self {
        case .abw: "Aruba"
        case .afg: "Afghanistan"
        case .ago: "Angola"
        case .aia: "Anguilla"
        case .alb: "Albania"
        case .and: "Andorra"
        case .ant: "Netherlands Antilles"
        case .are: "United Arab Emirates"
        case .arg: "Argentina"
        case .arm: "Armenia"
        case .asm: "American Samoa"
        case .atg: "Antigua and Barbuda"
        case .aus: "Australia"
        case .aut: "Austria"
        case .aze: "Azerbaijan"
        case .bdi: "Burundi"
        case .bel: "Belgium"
        case .ben: "Benin"
        case .bes: "Bonaire, Sint Eustatius and Saba"
        case .bfa: "Burkina Faso"
        case .bgd: "Bangladesh"
        case .bgr: "Bulgaria"
        case .bhr: "Bahrain"
        case .bhs: "Bahamas"
        case .bih: "Bosnia and Herzegovina"
        case .blr: "Belarus"
        case .blz: "Belize"
        case .bmu: "Bermuda"
        case .bol: "Bolivia"
        case .bra: "Brazil"
        case .brb: "Barbados"
        case .brn: "Brunei Darussalam"
        case .btn: "Bhutan"
        case .bwa: "Botswana"
        case .caf: "Central African Republic"
        case .can: "Canada"
        case .che: "Switzerland"
        case .chl: "Chile"
        case .chn: "China"
        case .civ: "Côte d'Ivoire"
        case .cmr: "Cameroon"
        case .cod: "Congo, Democratic Republic of the"
        case .cog: "Congo"
        case .cok: "Cook Islands"
        case .col: "Colombia"
        case .com: "Comoros"
        case .cpv: "Cabo Verde"
        case .cri: "Costa Rica"
        case .cub: "Cuba"
        case .cuw: "Curaçao"
        case .cxr: "Christmas Island"
        case .cym: "Cayman Islands"
        case .cyp: "Cyprus"
        case .cze: "Czechia"
        case .deu: "Germany"
        case .dji: "Djibouti"
        case .dma: "Dominica"
        case .dnk: "Denmark"
        case .dom: "Dominican Republic"
        case .dza: "Algeria"
        case .ecu: "Ecuador"
        case .egy: "Egypt"
        case .eri: "Eritrea"
        case .esp: "Spain"
        case .est: "Estonia"
        case .eth: "Ethiopia"
        case .fin: "Finland"
        case .fji: "Fiji"
        case .flk: "Falkland Islands (Malvinas)"
        case .fra: "France"
        case .fro: "Faroe Islands"
        case .fsm: "Micronesia"
        case .gab: "Gabon"
        case .gbr: "United Kingdom"
        case .geo: "Georgia"
        case .ggy: "Guernsey"
        case .gha: "Ghana"
        case .gib: "Gibraltar"
        case .gin: "Guinea"
        case .glp: "Guadeloupe"
        case .gmb: "Gambia"
        case .gnb: "Guinea-Bissau"
        case .gnq: "Equatorial Guinea"
        case .grc: "Greece"
        case .grd: "Grenada"
        case .grl: "Greenland"
        case .gtm: "Guatemala"
        case .guf: "French Guiana"
        case .gum: "Guam"
        case .guy: "Guyana"
        case .hkg: "Hong Kong"
        case .hnd: "Honduras"
        case .hrv: "Croatia"
        case .hti: "Haiti"
        case .hun: "Hungary"
        case .idn: "Indonesia"
        case .imn: "Isle of Man"
        case .ind: "India"
        case .irl: "Ireland"
        case .irq: "Iraq"
        case .isl: "Iceland"
        case .isr: "Israel"
        case .ita: "Italy"
        case .jam: "Jamaica"
        case .jey: "Jersey"
        case .jor: "Jordan"
        case .jpn: "Japan"
        case .kaz: "Kazakhstan"
        case .ken: "Kenya"
        case .kgz: "Kyrgyzstan"
        case .khm: "Cambodia"
        case .kir: "Kiribati"
        case .kna: "Saint Kitts and Nevis"
        case .kor: "South Korea"
        case .kwt: "Kuwait"
        case .lao: "Lao People's Democratic Republic"
        case .lbn: "Lebanon"
        case .lbr: "Liberia"
        case .lby: "Libya"
        case .lca: "Saint Lucia"
        case .lie: "Liechtenstein"
        case .lka: "Sri Lanka"
        case .lso: "Lesotho"
        case .ltu: "Lithuania"
        case .lux: "Luxembourg"
        case .lva: "Latvia"
        case .mac: "Macao"
        case .mar: "Morocco"
        case .mco: "Monaco"
        case .mda: "Moldova"
        case .mdg: "Madagascar"
        case .mdv: "Maldives"
        case .mex: "Mexico"
        case .mhl: "Marshall Islands"
        case .mkd: "North Macedonia"
        case .mli: "Mali"
        case .mlt: "Malta"
        case .mmr: "Myanmar"
        case .mne: "Montenegro"
        case .mng: "Mongolia"
        case .mnp: "Northern Mariana Islands"
        case .moz: "Mozambique"
        case .mrt: "Mauritania"
        case .msr: "Montserrat"
        case .mtq: "Martinique"
        case .mus: "Mauritius"
        case .mwi: "Malawi"
        case .mys: "Malaysia"
        case .myt: "Mayotte"
        case .nam: "Namibia"
        case .ncl: "New Caledonia"
        case .ner: "Niger"
        case .nfk: "Norfolk Island"
        case .nga: "Nigeria"
        case .nic: "Nicaragua"
        case .niu: "Niue"
        case .nld: "Netherlands"
        case .nor: "Norway"
        case .npl: "Nepal"
        case .nru: "Nauru"
        case .nzl: "New Zealand"
        case .omn: "Oman"
        case .pak: "Pakistan"
        case .pan: "Panama"
        case .per: "Peru"
        case .phl: "Philippines"
        case .plw: "Palau"
        case .png: "Papua New Guinea"
        case .pol: "Poland"
        case .pri: "Puerto Rico"
        case .prt: "Portugal"
        case .pry: "Paraguay"
        case .pse: "Palestine"
        case .pyf: "French Polynesia"
        case .qat: "Qatar"
        case .reu: "Réunion"
        case .rou: "Romania"
        case .rus: "Russia"
        case .rwa: "Rwanda"
        case .sau: "Saudi Arabia"
        case .sen: "Senegal"
        case .sgp: "Singapore"
        case .shn: "Saint Helena"
        case .slb: "Solomon Islands"
        case .sle: "Sierra Leone"
        case .slv: "El Salvador"
        case .smr: "San Marino"
        case .som: "Somalia"
        case .spm: "Saint Pierre and Miquelon"
        case .srb: "Serbia"
        case .ssd: "South Sudan"
        case .stp: "São Tomé and Príncipe"
        case .sur: "Suriname"
        case .svk: "Slovakia"
        case .svn: "Slovenia"
        case .swe: "Sweden"
        case .swz: "Eswatini"
        case .sxm: "Sint Maarten"
        case .syc: "Seychelles"
        case .tca: "Turks and Caicos Islands"
        case .tcd: "Chad"
        case .tgo: "Togo"
        case .tha: "Thailand"
        case .tjk: "Tajikistan"
        case .tkm: "Turkmenistan"
        case .tls: "Timor-Leste"
        case .ton: "Tonga"
        case .tto: "Trinidad and Tobago"
        case .tun: "Tunisia"
        case .tur: "Turkey"
        case .tuv: "Tuvalu"
        case .twn: "Taiwan"
        case .tza: "Tanzania"
        case .uga: "Uganda"
        case .ukr: "Ukraine"
        case .umi: "United States Minor Outlying Islands"
        case .ury: "Uruguay"
        case .usa: "United States"
        case .uzb: "Uzbekistan"
        case .vat: "Vatican City"
        case .vct: "Saint Vincent and the Grenadines"
        case .ven: "Venezuela"
        case .vgb: "British Virgin Islands"
        case .vir: "U.S. Virgin Islands"
        case .vnm: "Vietnam"
        case .vut: "Vanuatu"
        case .wlf: "Wallis and Futuna"
        case .wsm: "Samoa"
        case .yem: "Yemen"
        case .zaf: "South Africa"
        case .zmb: "Zambia"
        case .zwe: "Zimbabwe"
        }
    }

    var flagEmoji: String {
        let baseScalar: UInt32 = 127_397
        return String(rawValue.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(baseScalar + $0.value).map(Character.init)
        })
    }
}