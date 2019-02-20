import Foundation
import DIKit

protocol AppResolver: DIKit.Resolver {
    func provideResolver() -> AppResolver
}

final class AppResolverImpl: AppResolver {
    func provideResolver() -> AppResolver {
        return self
    }
}
