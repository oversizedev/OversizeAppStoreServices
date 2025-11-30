//
// Copyright © 2024 Alexander Romanov
// AppScreenshot.swift, created on 20.11.2024
//

import AppStoreAPI
import Foundation

public struct AppScreenshot: Identifiable, Sendable {
    public let id: String
    public let type: String
    public var fileName: String?
    public var fileSize: Int?
    public var imageAsset: ImageAsset?
    public var sourceFileChecksum: String?
    public var uploadOperations: [UploadOperation]?
    public var assetType: String?
    public var assetToken: String?

    public init(
        id: String,
        type: String = "appScreenshots",
        fileName: String? = nil,
        fileSize: Int? = nil,
        imageAsset: ImageAsset? = nil,
        sourceFileChecksum: String? = nil,
        uploadOperations: [UploadOperation]? = nil,
        assetType: String? = nil,
        assetToken: String? = nil
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.fileSize = fileSize
        self.imageAsset = imageAsset
        self.sourceFileChecksum = sourceFileChecksum
        self.uploadOperations = uploadOperations
        self.assetType = assetType
        self.assetToken = assetToken
    }

    public init(schema: AppStoreAPI.AppScreenshot) {
        id = schema.id
        type = "appScreenshots"
        fileName = schema.attributes?.fileName
        fileSize = schema.attributes?.fileSize
        if let imageAssetSchema = schema.attributes?.imageAsset {
            imageAsset = ImageAsset(schema: imageAssetSchema)
        }
        sourceFileChecksum = schema.attributes?.sourceFileChecksum
        if let uploadOps = schema.attributes?.uploadOperations {
            uploadOperations = uploadOps.compactMap { UploadOperation(schema: $0) }
        }
        assetType = schema.attributes?.assetType
        assetToken = schema.attributes?.assetToken
    }
}
