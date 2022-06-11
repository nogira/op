//
//  loadActions.swift
//  op
//
//  Created by nogira on 7/6/2022.
//

import Foundation

func loadActions() -> [ActionConfig] {
    
    /* TODO: --
        1. Find and replace     "r.square.fill"
        2. Search        "magnifyingglass"
        3. font (e.g. bold, italic)
        4. fancy text     "mustache.fill"
        5. highlighter    "highlighter"
        
     */
    
    let defaultActions: [ActionConfig] = [
//        ActionConfig(actionName: "search", inputType: .selection, iconFile: <#T##DecodableDefault.EmptyString#>, regexMatch: <#T##DecodableDefault.EmptyString#>, regexMatchFlags: <#T##DecodableDefault.EmptyString#>, regexReplace: <#T##DecodableDefault.EmptyString#>, regexReplaceFlags: <#T##DecodableDefault.EmptyString#>, env: <#T##DecodableDefault.EmptyString#>, scriptFile: <#T##DecodableDefault.EmptyString#>)
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

struct ActionConfig: Decodable {
    let actionName: String
    let inputType: InputType
    var iconFile: String!
    var regexMatch: String!
    var regexMatchFlags: String!
    var regexReplace: String!
    var regexReplaceFlags: String!
    // below are compulsary for plugin, but no for default actions
    var env: String!
    var scriptFile: String!
    var url: String!
}
