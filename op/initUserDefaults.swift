//
//  Data.swift
//  op
//
//  Created by nogira on 2/6/2022.
//

import Foundation

func initUserDefaults(_ delegate: AppDelegate) {
    let defaults = delegate.defaults
    let actions = delegate.actions
    
    // ----init UserDefault values if not present----
    
    
    // TODO: remove these 2 lines when done testing
    
//    defaults.removeObject(forKey: "actionsEnabled")

    
    
    // FIXME: can't store this in userdefaults as AnyObject, so must use diff method. perhaps store in text file (as data rather than as string)
    
    // TODO: tbh, do that plugin file changes and default action code changes propogate to the buttons, i think i should run this init every time, and the only thing i store is the data of whether enabled/disabled, thus MIGHT STILL BE ABLE TO USE USERDEFAULTS
    //                                       🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨
    
    
    //  - defaults.bool(forKey: "dark mode") will default to false so no need to init

    if defaults.object(forKey: "actionsEnabled") == nil {
        /**
         dictionary to store whether a plugin or default action is enabled or not
         */
        var actionsEnabled: [String: Bool] = [:]
        for action in actions {
            actionsEnabled[action.actionName] = true
        }
        defaults.set(actionsEnabled, forKey: "actionsEnabled")
//        print(actionsEnabled)
        
//        print(defaults.object(forKey: "actionsEnabled") as! [String: Bool])
    } else {
        // MARK: - add new actions, remove deleted actions
        
        var newActionsEnabled = defaults.object(forKey: "actionsEnabled") as! [String: Bool]
        // this is a temp dict to track if there are any items in actionsEnabled that have no corresponding action, so we can delete their entries in actionsEnabled
        // this is a copy, so modifying should not effect original
        var trackingActionsEnabled = defaults.object(forKey: "actionsEnabled") as! [String: Bool]
        
        for action in actions {
            let name = action.actionName
            // if present in newActionsEnabled dict, remove from the temp trackingActionsEnabled dict
            if newActionsEnabled[name] != nil {
                trackingActionsEnabled[name] = nil
                
            // if absent, add to newActionsEnabled as true
            } else {
                newActionsEnabled[name] = true
            }
        }
        
        // if any items left in trackingActionsEnabled, it means there is no corresponding action, so delete from newActionsEnabled
        for (name, _) in trackingActionsEnabled {
            newActionsEnabled[name] = nil
        }
        // confirm userdefaults was not mutated:
//        print(defaults.object(forKey: "actionsEnabled") as! [String: Bool])
    }
}
