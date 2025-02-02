import AppStoreAPI
import AppStoreConnect
import Foundation

public struct LocalXcodeMetrics: Codable, Equatable, Sendable {
    public let version: String?
    public let insights: LocalInsights?
    public let productData: [LocalProductData]?

    public init(dto: XcodeMetrics) {
        version = dto.version
        insights = dto.insights.map { LocalInsights(dto: $0) }
        productData = dto.productData?.map { LocalProductData(dto: $0) }
    }
}

// MARK: - Insights

public struct LocalInsights: Codable, Equatable, Sendable {
    public let trendingUp: [LocalMetricsInsight]?
    public let regressions: [LocalMetricsInsight]?

    public init(dto: XcodeMetrics.Insights) {
        trendingUp = dto.trendingUp?.map { LocalMetricsInsight(dto: $0) }
        regressions = dto.regressions?.map { LocalMetricsInsight(dto: $0) }
    }
}

// MARK: - Product Data

public struct LocalProductData: Codable, Equatable, Sendable {
    public let platform: String?
    public let metricCategories: [LocalMetricCategory]?

    public init(dto: XcodeMetrics.ProductDatum) {
        platform = dto.platform
        metricCategories = dto.metricCategories?.map { LocalMetricCategory(dto: $0) }
    }
}

// MARK: - Metric Category

public struct LocalMetricCategory: Codable, Equatable, Sendable {
    public let identifier: String?
    public let metrics: [LocalMetric]?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory) {
        identifier = dto.identifier?.rawValue
        metrics = dto.metrics?.map { LocalMetric(dto: $0) }
    }
}

// MARK: - Metric

public struct LocalMetric: Codable, Equatable, Sendable {
    public let identifier: String?
    public let goalKeys: [LocalGoalKey]?
    public let unit: LocalUnit?
    public let datasets: [LocalDataset]?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric) {
        identifier = dto.identifier
        goalKeys = dto.goalKeys?.map { LocalGoalKey(dto: $0) }
        unit = dto.unit.map { LocalUnit(dto: $0) }
        datasets = dto.datasets?.map { LocalDataset(dto: $0) }
    }
}

// MARK: - Goal Key

public struct LocalGoalKey: Codable, Equatable, Sendable {
    public let goalKey: String?
    public let lowerBound: Int?
    public let upperBound: Int?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric.GoalKey) {
        goalKey = dto.goalKey
        lowerBound = dto.lowerBound
        upperBound = dto.upperBound
    }
}

// MARK: - Unit

public struct LocalUnit: Codable, Equatable, Sendable {
    public let identifier: String?
    public let displayName: String?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric.Unit) {
        identifier = dto.identifier
        displayName = dto.displayName
    }
}

// MARK: - Dataset

public struct LocalDataset: Codable, Equatable, Sendable {
    public let filterCriteria: LocalFilterCriteria?
    public let points: [LocalPoint]?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric.Dataset) {
        filterCriteria = dto.filterCriteria.map { LocalFilterCriteria(dto: $0) }
        points = dto.points?.map { LocalPoint(dto: $0) }
    }
}

// MARK: - Filter Criteria

public struct LocalFilterCriteria: Codable, Equatable, Sendable {
    public let percentile: String?
    public let device: String?
    public let deviceMarketingName: String?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric.Dataset.FilterCriteria) {
        percentile = dto.percentile
        device = dto.device
        deviceMarketingName = dto.deviceMarketingName
    }
}

// MARK: - Point

public struct LocalPoint: Codable, Equatable, Sendable {
    public let version: String?
    public let value: Double?
    public let errorMargin: Double?
    public let percentageBreakdown: LocalPercentageBreakdown?
    public let goal: String?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric.Dataset.Point) {
        version = dto.version
        value = dto.value
        errorMargin = dto.errorMargin
        percentageBreakdown = dto.percentageBreakdown.map { LocalPercentageBreakdown(dto: $0) }
        goal = dto.goal
    }
}

// MARK: - Percentage Breakdown

public struct LocalPercentageBreakdown: Codable, Equatable, Sendable {
    public let value: Double?
    public let subSystemLabel: String?

    public init(dto: XcodeMetrics.ProductDatum.MetricCategory.Metric.Dataset.Point.PercentageBreakdown) {
        value = dto.value
        subSystemLabel = dto.subSystemLabel
    }
}

// MARK: - Metrics Insight

public struct LocalMetricsInsight: Codable, Equatable, Sendable {
    public let metricCategory: String?
    public let latestVersion: String?
    public let metric: String?
    public let summaryString: String?
    public let referenceVersions: String?
    public let maxLatestVersionValue: Double?
    public let subSystemLabel: String?
    public let isHighImpact: Bool?
    public let populations: [LocalPopulation]?

    public init(dto: MetricsInsight) {
        metricCategory = dto.metricCategory?.rawValue
        latestVersion = dto.latestVersion
        metric = dto.metric
        summaryString = dto.summaryString
        referenceVersions = dto.referenceVersions
        maxLatestVersionValue = dto.maxLatestVersionValue
        subSystemLabel = dto.subSystemLabel
        isHighImpact = dto.isHighImpact
        populations = dto.populations?.map { LocalPopulation(dto: $0) }
    }
}

// MARK: - Population

public struct LocalPopulation: Codable, Equatable, Sendable {
    public let deltaPercentage: Double?
    public let percentile: String?
    public let summaryString: String?
    public let referenceAverageValue: Double?
    public let latestVersionValue: Double?
    public let device: String?

    public init(dto: MetricsInsight.Population) {
        deltaPercentage = dto.deltaPercentage
        percentile = dto.percentile
        summaryString = dto.summaryString
        referenceAverageValue = dto.referenceAverageValue
        latestVersionValue = dto.latestVersionValue
        device = dto.device
    }
}
