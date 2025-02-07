//
// Copyright © 2025 Alexander Romanov
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
        // North America
        case .usa, .can, .umi:
            self = .unitedStatesAndCanada

        // Europe (including associated territories)
        case .gbr, .fra, .deu, .ita, .esp, .nld, .bel, .swe, .nor, .dnk,
             .fin, .irl, .che, .aut, .grc, .prt, .pol, .cze, .hun, .rou,
             .svk, .svn, .bgr, .hrv, .est, .lva, .ltu, .isl, .mlt, .lux,
             .cyp, .ukr, .blr, .mda, .and, .mco, .smr, .vat, .lie, .alb,
             .bih, .mkd, .mne, .rus, .srb, .xks,
             // European territories and dependencies
             .ggy, .jey, .imn, .fro, .gib, .shn:
            self = .europe

        // Africa, Middle East, and India
        case .are, .sau, .isr, .egy, .ind, .zaf, .ken, .nga, .gha, .mar,
             .tur, .qat, .bhr, .omn, .kwt, .jor, .lbn, .irq, .pak, .afg,
             .dza, .ago, .arm, .aze, .ben, .bwa, .bfa, .bdi, .cmr, .cpv,
             .tcd, .com, .cog, .cod, .civ, .dji, .gab, .gmb, .geo, .gnb,
             .gnq, .eri, .swz, .eth, .lby, .mdg, .mwi, .mli, .mrt, .mus,
             .moz, .nam, .ner, .rwa, .stp, .sen, .syc, .sle, .som, .ssd,
             .tza, .tgo, .tun, .uga, .yem, .zmb, .zwe,
             // Associated territories
             .reu, .myt:
            self = .africaMiddleEastIndia

        // Latin America and Caribbean
        case .mex, .bra, .arg, .chl, .col, .per, .ven, .ury, .pry, .bol,
             .ecu, .guy, .sur, .pan, .cri, .slv, .gtm, .hnd, .nic, .blz,
             .hti, .dom, .cub, .jam, .tto, .bhs, .brb, .atg, .vct, .grd,
             .dma, .kna, .lca, .aia, .msr, .tca, .vgb, .cym, .guf, .flk,
             .spm, .bmu,
             // Additional Caribbean territories
             .abw, .cuw, .sxm, .bes, .glp, .mtq, .pri, .vir, .ant:
            self = .latinAmericaCaribbean

        // Asia Pacific
        case .chn, .jpn, .kor, .aus, .nzl, .sgp, .hkg, .twn, .mys, .idn,
             .tha, .phl, .vnm, .khm, .lao, .mmr, .brn, .fji, .png, .plw,
             .fsm, .nru, .wsm, .ton, .vut, .slb, .mdv, .lka, .btn, .mng,
             .kaz, .kgz, .mac, .npl, .tjk, .tkm, .uzb,
             // Additional Pacific territories
             .asm, .cok, .cxr, .gum, .kir, .mhl, .mnp, .ncl, .nfk, .niu,
             .pyf, .tuv, .wlf:
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
