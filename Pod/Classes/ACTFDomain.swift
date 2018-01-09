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
    
    fileprivate enum CodingKeys: CodingKey {
        case text
        case weight
    }
    
    // MARK: - Initializer
    
    public init(text t: String, weight w: Int) {
        
        text = t
        weight = w
    }
    
    // MARK: - Encoder & Decoder
    
    /*
     * SE-0166
     * https://github.com/apple/swift-evolution/blob/master/proposals/0166-swift-archival-serialization.md
     */
    
    public func encode(to encoder: Encoder) throws {
        
        // Generic keyed encoder gives type-safe key access: cannot encode with keys of the wrong type.
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // The encoder is generic on the key -- free key autocompletion here.
        try container.encode(text, forKey: .text)
        try container.encode(weight, forKey: .weight)
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        weight = try container.decode(Int.self, forKey: .weight)
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
    
    // MARK: - Type-level Functions
    
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

