//
//  ACTFWeightedDomain.swift
//  Pods
//
//  Created by Neil Francis Hipona on 9/15/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import Foundation

public struct ACTFDomain: Codable {
    
    public let text: String
    public var weight: Int
    
    // MARK: - Initializer
    
    public init(text t: String, weight w: Int) {
        
        text = t
        weight = w
    }
    
    // MARK: - Functions
    
    public mutating func updateWeightUsage() {
        
        weight += 1
    }
    
    public func storeDomainForKey(_ key: String) -> Bool {
        
        // store
        do {
            let data = try PropertyListEncoder().encode(self)
            let eData = NSKeyedArchiver.archivedData(withRootObject: data)
            UserDefaults.standard.set(eData, forKey: key)
            
            return true
        }catch{ // store failed
            return false
        }
    }
    
    // MARK: - Type-level Functions
    
    public static func retrievedDomainForKey(_ key: String) -> ACTFDomain? {
        
        // retrieved
        do {
            guard let eData = UserDefaults.standard.object(forKey: key) as? Data,
                let dData = NSKeyedUnarchiver.unarchiveObject(with: eData) as? Data else {
                    // retrieve failed
                    return nil
            }
            
            let domain = try PropertyListDecoder().decode(ACTFDomain.self, from: dData)
            return domain
        }catch{ // retrieve failed
            return nil
        }
    }
    
    public static func storeDomainsForKey(domains: [ACTFDomain], key: String) -> Bool {
        
        // store
        do {
            let data = try PropertyListEncoder().encode(domains)
            let eData = NSKeyedArchiver.archivedData(withRootObject: data)
            UserDefaults.standard.set(eData, forKey: key)
            
            return true
        }catch{ // store failed
            return false
        }
    }
    
    public static func retrievedDomainsForKey(_ key: String) -> [ACTFDomain]? {

        // retrieved
        do {
            guard let eData = UserDefaults.standard.object(forKey: key) as? Data,
                let dData = NSKeyedUnarchiver.unarchiveObject(with: eData) as? Data else {
                    // retrieve failed
                    return nil
            }
            
            let domains = try PropertyListDecoder().decode([ACTFDomain].self, from: dData)
            return domains
        }catch{ // retrieve failed
            return nil
        }
    }

}

