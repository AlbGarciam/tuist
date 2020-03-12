import Basic
import Foundation
import TuistSupport

enum FrameworkNodeLoaderError: FatalError {
    case frameworkNotFound(AbsolutePath)

    /// Error type.
    var type: ErrorType {
        switch self {
        case .frameworkNotFound:
            return .abort
        }
    }

    /// Error description
    var description: String {
        switch self {
        case let .frameworkNotFound(path):
            return "Couldn't find framework at \(path.pathString)"
        }
    }
}

protocol FrameworkNodeLoading {
    /// Reads an existing framework and returns its in-memory representation, FrameworkNode.
    /// - Parameter path: Path to the .framework.
    func load(path: AbsolutePath) throws -> FrameworkNode
}

final class FrameworkNodeLoader: FrameworkNodeLoading {
    /// Framework metadata provider.
    fileprivate let frameworkMetadataProvider: FrameworkMetadataProviding

    /// Initializes the loader with its attributes.
    /// - Parameter frameworkMetadataProvider: Framework metadata provider.
    init(frameworkMetadataProvider: FrameworkMetadataProviding = FrameworkMetadataProvider()) {
        self.frameworkMetadataProvider = frameworkMetadataProvider
    }

    func load(path: AbsolutePath) throws -> FrameworkNode {
        guard FileHandler.shared.exists(path) else {
            throw FrameworkNodeLoaderError.frameworkNotFound(path)
        }

        let dsymsPath = frameworkMetadataProvider.dsymPath(frameworkPath: path)
        let bcsymbolmapPaths = try frameworkMetadataProvider.bcsymbolmapPaths(frameworkPath: path)
        let linking = try frameworkMetadataProvider.linking(binaryPath: FrameworkNode.binaryPath(frameworkPath: path))
        let architectures = try frameworkMetadataProvider.architectures(binaryPath: FrameworkNode.binaryPath(frameworkPath: path))

        return FrameworkNode(path: path,
                             dsymPath: dsymsPath,
                             bcsymbolmapPaths: bcsymbolmapPaths,
                             linking: linking,
                             architectures: architectures)
    }
}
