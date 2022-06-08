//
//  loadActions.swift
//  op
//
//  Created by nogira on 7/6/2022.
//

import Foundation

func loadActions() -> [ActionConfig] {
    let defaultActions: [ActionConfig] = [
        ActionConfig(actionName: "ab", inputType: .selection),
        ActionConfig(actionName: "AB", inputType: .selection),
        ActionConfig(actionName: "cut", inputType: .selection),
        ActionConfig(actionName: "copy", inputType: .selection),
        ActionConfig(actionName: "paste =", inputType: .pasteboard),
    ]
    var actions = defaultActions
    
    // create application support folder if not already
    let baseFolder = applicationFolder()
    let pluginsFolder: URL = baseFolder.appendingPathComponent("plugins")
    do {
        try FileManager.default.createDirectory(
            at: baseFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: pluginsFolder, withIntermediateDirectories: true)
    } catch {
        print(error)
    }
    
    do {
        // convert "selection" to .onlyCopyAndCopyPaste, "clipboard" to .paste
        let pluginFolders: [URL] = try FileManager.default.contentsOfDirectory(
            at: pluginsFolder,
            includingPropertiesForKeys: nil
        )
        
        for pluginFolder in pluginFolders {
            // ignore .DS_Store file
            let notDSStore = pluginFolder.lastPathComponent != ".DS_Store"
            if notDSStore {
                do {
                    let configURL: URL = pluginFolder.appendingPathComponent("config.json")
                    let configData = try Data(contentsOf: configURL)
                    let config: ActionConfig = try! JSONDecoder().decode(ActionConfig.self, from: configData)
                    // add action
                    actions.append(config)
                } catch {
                    print(error)
                }
            }
        }
    } catch {
        print(error)
    }
    return actions
}

// use ActionConfig list to track position of button
struct ActionConfig: Decodable {
    let actionName: String
    let inputType: InputType
    @DecodableDefault.EmptyString var iconFile
    @DecodableDefault.EmptyString var regexMatch: String
    @DecodableDefault.EmptyString var regexMatchFlags: String
    @DecodableDefault.EmptyString var regexReplace: String
    @DecodableDefault.EmptyString var regexReplaceFlags: String
    // below are compulsary for plugin, but no for default actions
    @DecodableDefault.EmptyString var env: String
    @DecodableDefault.EmptyString var scriptFile: String
}

/**
 get the application's application support folder
 */
func applicationFolder() -> URL {
    // create application support folder if not already
    let path: URL = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let baseFolder: URL =  path.appendingPathComponent("nogira.op")
    return baseFolder
}


// stuff so able to parse a json file missing some values in the ActionConfig struct

// https://www.swiftbysundell.com/tips/default-decoding-values/

protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

enum DecodableDefault {}

extension DecodableDefault {
    @propertyWrapper
    struct Wrapper<Source: DecodableDefaultSource> {
        typealias Value = Source.Value
        var wrappedValue = Source.defaultValue
    }
}

extension DecodableDefault.Wrapper: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

extension DecodableDefault {
    typealias Source = DecodableDefaultSource
    typealias List = Decodable & ExpressibleByArrayLiteral
    typealias Map = Decodable & ExpressibleByDictionaryLiteral

    enum Sources {
        enum True: Source {
            static var defaultValue: Bool { true }
        }

        enum False: Source {
            static var defaultValue: Bool { false }
        }

        enum EmptyString: Source {
            static var defaultValue: String { "" }
        }

        enum EmptyList<T: List>: Source {
            static var defaultValue: T { [] }
        }

        enum EmptyMap<T: Map>: Source {
            static var defaultValue: T { [:] }
        }
    }
}

extension DecodableDefault {
    typealias True = Wrapper<Sources.True>
    typealias False = Wrapper<Sources.False>
    typealias EmptyString = Wrapper<Sources.EmptyString>
    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

