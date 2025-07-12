import Foundation
import LeavnCore

// Note: SearchQuery is defined in LeavnCore/Architecture/Protocols/SearchProtocols.swift
// Note: SearchFilter is defined in LeavnCore/SearchModels.swift
// Note: SearchResult and HighlightRange are defined in LeavnCore/SearchModels.swift

// This extension adds the books property to SearchFilter
public extension SearchFilter {
    var books: [String]? {
        switch self {
        case .all:
            return nil
        case .oldTestament:
            return ["GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA", "1KI", "2KI", "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO", "ECC", "SNG", "ISA", "JER", "LAM", "EZK", "DAN", "HOS", "JOL", "AMO", "OBA", "JON", "MIC", "NAH", "HAB", "ZEP", "HAG", "ZEC", "MAL"]
        case .newTestament:
            return ["MAT", "MRK", "LUK", "JHN", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH", "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAS", "1PE", "2PE", "1JN", "2JN", "3JN", "JUD", "REV"]
        case .gospels:
            return ["MAT", "MRK", "LUK", "JHN"]
        case .psalms:
            return ["PSA"]
        case .proverbs:
            return ["PRO"]
        }
    }
}