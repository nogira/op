//
//  loadActions.swift
//  op
//
//  Created by nogira on 7/6/2022.
//

import AppKit

func SFSymbolNSImage(_ name: String) -> NSImage {
    return NSImage(systemSymbolName: name, accessibilityDescription: nil)!
}

func loadActions() -> [ActionConfig] {
    
    /* TODO: --
        1. Find and replace     "r.square.fill"
        2. Search        "magnifyingglass"
        3. font (e.g. bold, italic)
        4. fancy text     "mustache.fill"
        5. highlighter    "highlighter"
        
     */
    
    let defaultActions: [ActionConfig] = [
        ActionConfig(actionName: "search", inputType: .selection, iconSFSymbol: SFSymbolNSImage("magnifyingglass"), searchURL: "https://search.brave.com/search?q={text}"),
        ActionConfig(actionName: "ab", inputType: .selection),
        ActionConfig(actionName: "AB", inputType: .selection),
        ActionConfig(actionName: "cut", inputType: .selection, iconSFSymbol: SFSymbolNSImage("scissors")),
        ActionConfig(actionName: "copy", inputType: .selection, iconSFSymbol: SFSymbolNSImage("doc.on.doc.fill")),
        ActionConfig(actionName: "paste =", inputType: .pasteboard, iconSFSymbol: SFSymbolNSImage("doc.on.clipboard")),
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

struct ActionConfig: Decodable {
    let actionName: String
    let inputType: InputType
    
    // URL and NSImage use half the memory bytes as String, so the strings are converted to their respective types with custom decoding further below
    var iconImage: NSImage!
    var iconSFSymbol: NSImage!
    var regexMatch: String!
    var regexMatchFlags: String!
    var regexReplace: String!
    var regexReplaceFlags: String!
    // below are compulsary for plugin, but no for default actions
    var scriptEnvironmentURL: URL!
    var scriptFileURL: URL!
    var searchURL: String!
    
    enum CodingKeys: String, CodingKey {
        case actionName
        case inputType
        case iconImage = "iconFile"
        case iconSFSymbol
        case regexMatch
        case regexMatchFlags
        case regexReplace
        case regexReplaceFlags
        case scriptEnvironmentURL = "scriptEnvironment"
        case scriptFileURL = "scriptFile"
        case searchURL
    }
}
// custom decode
extension ActionConfig {

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let actionName = try container.decode(String.self, forKey: .actionName)
        let inputType = try container.decode(InputType.self, forKey: .inputType)

        let pluginFolderURL: URL = pluginsFolder()
            .appendingPathComponent(actionName)
            
        // initially decode as string, then convert to image
        let iconFileStr = try container.decodeIfPresent(String.self, forKey: .iconImage)
        var iconImage: NSImage?
        if let iconFileStr = iconFileStr {
            let iconURL = pluginFolderURL.appendingPathComponent(iconFileStr)
            iconImage = NSImage(byReferencing: iconURL)
        }
        // initially decode as string, then convert to image
        let iconSFSymbolStr = try container.decodeIfPresent(String.self, forKey: .iconSFSymbol)
        var iconSFSymbol: NSImage?
        if let iconSFSymbolStr = iconSFSymbolStr {
            iconSFSymbol = NSImage(systemSymbolName: iconSFSymbolStr, accessibilityDescription: nil)
        }
        let regexMatch = try container.decodeIfPresent(String.self, forKey: .regexMatch)
        let regexMatchFlags = try container.decodeIfPresent(String.self, forKey: .regexMatchFlags)
        let regexReplace = try container.decodeIfPresent(String.self, forKey: .regexReplace)
        let regexReplaceFlags = try container.decodeIfPresent(String.self, forKey: .regexReplaceFlags)
        let scriptEnvironmentStr = try container.decodeIfPresent(String.self, forKey: .scriptEnvironmentURL)
        var scriptEnvironmentURL: URL?
        if let scriptEnvironmentStr = scriptEnvironmentStr {
            let homeFolder: URL = FileManager.default.homeDirectoryForCurrentUser
            scriptEnvironmentURL = homeFolder.appendingPathComponent(scriptEnvironmentStr)
        }
        let scriptFileStr = try container.decodeIfPresent(String.self, forKey: .scriptFileURL)
        var scriptFileURL: URL?
        if let scriptFileStr = scriptFileStr {
            scriptFileURL = pluginFolderURL.appendingPathComponent(scriptFileStr)
        }
        let searchURL = try container.decodeIfPresent(String.self, forKey: .searchURL)

        self.init(actionName: actionName,
                  inputType: inputType,
                  iconImage: iconImage,
                  iconSFSymbol: iconSFSymbol,
                  regexMatch: regexMatch,
                  regexMatchFlags: regexMatchFlags,
                  regexReplace: regexReplace,
                  regexReplaceFlags: regexReplaceFlags,
                  scriptEnvironmentURL: scriptEnvironmentURL,
                  scriptFileURL: scriptFileURL,
                  searchURL: searchURL)
    }
}


