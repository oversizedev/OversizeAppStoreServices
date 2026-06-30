import CodableCSV
import Foundation

public struct FinanceReports: Sendable {
    public let reports: [Report]
    public let totalRows: Int?
    public let totalAmount: Double?
    public let totalUnits: Int?

    public struct Report: Sendable {
        public let startDate: String
        public let endDate: String
        public let upc: String?
        public let isrcIsbn: String?
        public let vendorIdentifier: String
        public let quantity: String?
        public let partnerShare: String?
        public let extendedPartnerShare: String?
        public let partnerShareCurrency: String?
        public let salesOrReturn: String?
        public let appleIdentifier: String?
        public let artistShowDeveloperAuthor: String?
        public let title: String?
        public let labelStudioNetworkPublisher: String?
        public let grid: String?
        public let productTypeIdentifier: String?
        public let isanOtherIdentifier: String?
        public let countryOfSale: String?
        public let preOrderFlag: String?
        public let promoCode: String?
        public let customerPrice: String
        public let customerCurrency: String?

        public init(
            startDate: String,
            endDate: String,
            upc: String? = nil,
            isrcIsbn: String? = nil,
            vendorIdentifier: String,
            quantity: String? = nil,
            partnerShare: String? = nil,
            extendedPartnerShare: String? = nil,
            partnerShareCurrency: String? = nil,
            salesOrReturn: String? = nil,
            appleIdentifier: String? = nil,
            artistShowDeveloperAuthor: String? = nil,
            title: String? = nil,
            labelStudioNetworkPublisher: String? = nil,
            grid: String? = nil,
            productTypeIdentifier: String? = nil,
            isanOtherIdentifier: String? = nil,
            countryOfSale: String? = nil,
            preOrderFlag: String? = nil,
            promoCode: String? = nil,
            customerPrice: String,
            customerCurrency: String? = nil,
        ) {
            self.startDate = startDate
            self.endDate = endDate
            self.upc = upc
            self.isrcIsbn = isrcIsbn
            self.vendorIdentifier = vendorIdentifier
            self.quantity = quantity
            self.partnerShare = partnerShare
            self.extendedPartnerShare = extendedPartnerShare
            self.partnerShareCurrency = partnerShareCurrency
            self.salesOrReturn = salesOrReturn
            self.appleIdentifier = appleIdentifier
            self.artistShowDeveloperAuthor = artistShowDeveloperAuthor
            self.title = title
            self.labelStudioNetworkPublisher = labelStudioNetworkPublisher
            self.grid = grid
            self.productTypeIdentifier = productTypeIdentifier
            self.isanOtherIdentifier = isanOtherIdentifier
            self.countryOfSale = countryOfSale
            self.preOrderFlag = preOrderFlag
            self.promoCode = promoCode
            self.customerPrice = customerPrice
            self.customerCurrency = customerCurrency
        }
    }

    init?(data: Data) {
        guard let csvString = String(data: data, encoding: .utf8) else { return nil }

        do {
            let lines = csvString.components(separatedBy: "\n")

            var totalRows: Int? = nil
            var totalAmount: Double? = nil
            var totalUnits: Int? = nil

            var filteredLines: [String] = []
            for line in lines {
                if line.contains("Total_Rows") {
                    totalRows = Int(line.split(separator: "\t")[1].trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.contains("Total_Amount") {
                    totalAmount = Double(line.split(separator: "\t")[1].trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.contains("Total_Units") {
                    totalUnits = Int(line.split(separator: "\t")[1].trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    filteredLines.append(line)
                }
            }

            let filteredCSV = filteredLines.joined(separator: "\n")

            let reader = try CSVReader(input: filteredCSV) {
                $0.headerStrategy = .firstLine
                $0.delimiters.field = "\t"
                $0.presample = true
            }

            reports = reader.compactMap {
                .init(
                    startDate: $0[safe: 0] ?? "",
                    endDate: $0[safe: 1] ?? "",
                    upc: $0[safe: 2],
                    isrcIsbn: $0[safe: 3],
                    vendorIdentifier: $0[safe: 4] ?? "",
                    quantity: $0[safe: 5],
                    partnerShare: $0[safe: 6],
                    extendedPartnerShare: $0[safe: 7],
                    partnerShareCurrency: $0[safe: 8],
                    salesOrReturn: $0[safe: 9],
                    appleIdentifier: $0[safe: 10],
                    artistShowDeveloperAuthor: $0[safe: 11],
                    title: $0[safe: 12],
                    labelStudioNetworkPublisher: $0[safe: 13],
                    grid: $0[safe: 14],
                    productTypeIdentifier: $0[safe: 15],
                    isanOtherIdentifier: $0[safe: 16],
                    countryOfSale: $0[safe: 17],
                    preOrderFlag: $0[safe: 18],
                    promoCode: $0[safe: 19],
                    customerPrice: $0[safe: 20] ?? "",
                    customerCurrency: $0[safe: 21],
                )
            }

            self.totalRows = totalRows
            self.totalAmount = totalAmount
            self.totalUnits = totalUnits

        } catch {
            return nil
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
