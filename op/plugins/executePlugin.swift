//
//  executePlugin.swift
//  op
//
//  Created by nogira on 7/6/2022.
//

import Foundation

func executePlugin(_ action: ActionConfig, _ inputText: String) throws -> String {
    let applicationFolder = applicationFolder()
    let scriptPath = applicationFolder.appendingPathComponent("plugins")
        .appendingPathComponent(action.actionName)
        .appendingPathComponent(action.scriptFile).path
    
    let homeFolder: URL = FileManager.default.homeDirectoryForCurrentUser
    let envURL = homeFolder.appendingPathComponent(action.env)
    
    let outputText = try shell(inputText, envURL, scriptPath)
    return outputText    
}


// https://stackoverflow.com/questions/26971240/how-do-i-run-a-terminal-command-in-a-swift-script-e-g-xcodebuild

func shell(_ inputText: String, _ env: URL, _ scriptPath: String) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.environment = ["OP_TEXT": inputText]
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = [scriptPath]
    task.executableURL = env
    task.standardInput = nil

    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
