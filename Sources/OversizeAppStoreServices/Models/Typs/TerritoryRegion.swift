//
// Copyright © 2025 Aleksandr Romanov
// Region.swift, created on 27.01.2025
//

public enum TerritoryRegion: String, Sendable, CaseIterable, Identifiable {
    public var id: String {
        rawValue
    }

    public static let allCases: [TerritoryRegion] = [.unitedStatesAndCanada, .europe, .africaMiddleEastIndia, .latinAmericaCaribbean, .asiaPacific]

    case unitedStatesAndCanada = "The United States and Canada"
    case europe = "Europe"
    case africaMiddleEastIndia = "Africa, Middle East, and India"
    case latinAmericaCaribbean = "Latin America and the Caribbean"
    case asiaPacific = "Asia Pacific"
    case unknown = "Unknown Region"

    public init?(territoryCode: TerritoryCode) {
        switch territoryCode {
        case .usa, .can:
            self = .unitedStatesAndCanada

        case .gbr, .fra, .deu, .ita, .esp, .nld, .bel, .swe, .nor, .dnk,
             .fin, .irl, .che, .aut, .grc, .prt, .pol, .cze, .hun, .rou,
             .svk, .svn, .bgr, .hrv, .est, .lva, .ltu, .isl, .mlt, .lux,
             .cyp, .ukr, .blr, .mda, .and, .mco, .smr, .vat, .lie, .alb,
             .bih, .mkd, .mne, .rus, .srb, .tur, .xks:
            self = .europe

        case .are, .sau, .isr, .egy, .ind, .zaf, .ken, .nga, .gha, .mar,
             .tur, .qat, .bhr, .omn, .kwt, .jor, .lbn, .irq, .pak, .afg,
             .dza, .ago, .arm, .aze, .ben, .bwa, .bfa, .cmr, .cpv, .tcd,
             .cog, .cod, .civ, .gab, .gmb, .geo, .gnb, .gnq, .lbr, .swz,
             .lby, .mdg, .mwi, .mli, .mrt, .mus, .moz, .nam, .ner, .rwa,
             .stp, .sen, .syc, .sle, .tza, .tun, .uga, .yem, .zmb, .zwe:
            self = .africaMiddleEastIndia

        case .mex, .bra, .arg, .chl, .col, .per, .ven, .ury, .pry, .bol,
             .ecu, .guy, .sur, .pan, .cri, .slv, .gtm, .hnd, .nic, .blz,
             .hti, .dom, .cub, .jam, .tto, .bhs, .brb, .atg, .vct, .grd,
             .dma, .kna, .lca, .aia, .msr, .tca, .vgb, .cym, .guf, .flk,
             .spm, .bmu:
            self = .latinAmericaCaribbean

        case .chn, .jpn, .kor, .aus, .nzl, .sgp, .hkg, .twn, .mys, .idn,
             .tha, .phl, .vnm, .khm, .lao, .mmr, .brn, .fji, .png, .plw,
             .fsm, .nru, .wsm, .ton, .vut, .slb, .mdv, .lka, .btn, .mng,
             .kaz, .kgz, .mac, .npl, .tjk, .tkm, .uzb:
            self = .asiaPacific

        default:
            self = .unknown
        }
    }

    public init?(countryID: String) {
        guard let territoryCode = TerritoryCode(rawValue: countryID) else {
            self = .unknown
            return
        }
        self.init(territoryCode: territoryCode)
    }
}
