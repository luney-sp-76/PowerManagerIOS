//
//  HomeAssistantData.swift
//  powerManager
//
//  Created by Paul Olphert on 17/01/2023.
//

import Foundation

struct HomeAssistantData: Decodable {
 
        
        
        var entity_id: String
        var state: String
        var attributes: HomeAttributes
        var last_changed: String
        var last_updated: String
        var context: Context
        
        
        
        
    }

    struct HomeAttributes: Decodable {
        
       // var unitOfMeasurement: String?
        //var available: String?
        //var name: String?
        //var country: String?
        //var total: String?
        //var types: Types?
        //var locality: String?
        //var location: Location?
        //var ocean: String?
        //let availableImportant: String?
        //let availableOpportunistic: String?
        //var lowPowerMode: Bool?
       // var allowsVoIP: Bool?
       // var carrierID: String?
        //var carrierName: String?
        //var iSOCountryCode: String?
        //var mobileCountryCode: String?
        //var mobileNetworkCode: String?
        //var hardwareAddress: String?
        //var administrativeArea: String?
        //var areasOfInterest: String?
        //var inlandWater: String?
        //var attributesId: String?

        //var confidence: String?
        //var autoUpdate: Bool?
        //var installedVersion: String?
        //var latestVersion: String?
       // var releaseSummary: String?
        //var inProgress: Bool?
        //var releaseUrl: String?
        //var skippedVersion: String?
        //var title: String?
       // var entityPicture: String?
        //var nextDawn: String?
        //var nextDusk: String?
        //var nextMidnight: String?
        //var nextNoon: String?
        //var nextRising: String?
       // var nextSetting: String?
        //var elevation: Double?
        //var azimuth: Double?
        //var rising: Bool?
        //var radius:Int?
        //var passive: Bool?
        //var persons: Person?
        //var deviceClass: String?
        //var editable: Bool?
        //var icon: String?
       // var latitude: Double?
       // var longitude: Double?
       // var gpsAccuracy: Double?
       // var source: String?
       // var sourceType: String?
        var friendlyName: String
       // var supportedFeatures: String?
        //var userId: String?
        
        
        private enum CodingKeys: String, CodingKey {
            //case unitOfMeasurement = "unit_of_measurement"
            //case availableImportant = "Available (Important)"
           // case available = "Available"
            //case name = "Name"
            //case country = "Country"
            //case total = "Total"
            //case types =  "Types"
            //case locality = "Locality"
            //case location = "Location"
            //case ocean = "Ocean"
            //case availableOpportunistic = "Available (Opportunistic)"
            //case lowPowerMode = "Low Power Mode"
           // case allowsVoIP = "Allows_VoIP"
            //case carrierID = "Carrier_ID"
            //case carrierName = "Carrier_Name"
            //case iSOCountryCode = "ISO_Country_Code"
            //case mobileCountryCode = "Mobile_Country_Code"
            //case mobileNetworkCode = "Mobile_Network_Code"
            //case hardwareAddress = "Hardware_Address"
            //case administrativeArea = "Administrative_Area"
    //        case areasOfInterest = "Areas_Of_Interest"
    //        case inlandWater = "Inland_Water"
    //        case attributesId = "id"
    //        case confidence =  "Confidence"
    //        case autoUpdate = "auto_update"
    //        case installedVersion = "installed_version"
    //        case latestVersion = "latest_version"
    //        case releaseSummary = "release_summary"
    //        case inProgress = "in_progress"
    //        case releaseUrl = "release_url"
    //        case skippedVersion = "skipped_version"
    //        case title
    //        case entityPicture = "entity_picture"
    //        case nextDawn = "next_dawn"
    //        case nextDusk = "next_dusk"
    //        case nextMidnight = "next_midnight"
    //        case nextNoon = "next_noon"
    //        case nextRising = "next_rising"
    //        case nextSetting = "next_setting"
    //        case elevation
    //        case azimuth
    //        case rising
    //        case radius
    //        case passive
    //        case persons
    //        case deviceClass = "device_class"
    //        case editable
    //        case icon
    //        case latitude
    //        case longitude
    //        case gpsAccuracy = "gps_accuracy"
    //        case source
    //        case sourceType = "source_type"
            case friendlyName = "friendly_name"
           // case supportedFeatures = "supported_features"
            //case userId = "user_id"
        
            
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
          //  let unitOfMeasurement = try container.decode(String.self, forKey: .unitOfMeasurement)
            //let availableImportant = try container.decode(String.self, forKey: .availableImportant)
            //let availableOpportunistic = try container.decode(String.self, forKey: .availableOpportunistic)
          //  let available = try container.decode(String.self, forKey: .available)
            //let name = try container.decode(String.self, forKey: .name)
            //let country = try container.decode(String.self, forKey: .country)
    //        let total = try container.decode(String.self, forKey: .total)
    //        let types = try container.decode(String.self, forKey: .types)
    //        let locality = try container.decode(String.self, forKey: .locality)
    //        let location = try container.decode(String.self, forKey: .location)
    //        let ocean = try container.decode(String.self, forKey: .ocean)
    //        let lowPowerMode = try container.decode(Bool.self, forKey: .lowPowerMode)
    //        let allowsVoIP = try container.decode(Bool.self, forKey: .allowsVoIP)
    //        let carrierID = try container.decode(String.self, forKey: .carrierID)
    //        let carrierName = try container.decode(String.self, forKey: .carrierName)
    //        let iSOCountryCode = try container.decode(String.self, forKey: .iSOCountryCode)
    //        let mobileCountryCode = try container.decode(String.self, forKey: .mobileCountryCode)
    //        let mobileNetworkCode = try container.decode(String.self, forKey: .mobileNetworkCode)
    //        let hardwareAddress = try container.decode(String.self, forKey: .hardwareAddress)
    //        let administrativeArea = try container.decode(String.self, forKey: .administrativeArea)
    //        let areasOfInterest = try container.decode(String.self, forKey: .areasOfInterest)
    //        let inlandWater = try container.decode(String.self, forKey: .inlandWater)
    //        let attributesId = try container.decode(String.self, forKey: .attributesId)
    //        let confidence = try container.decode(String.self, forKey: .confidence)
    //        let autoUpdate = try container.decode(Bool.self, forKey: .autoUpdate)
    //        let installedVersion = try container.decode(String.self, forKey: .installedVersion)
    //        let latestVersion = try container.decode(String.self, forKey: .latestVersion)
    //        let releaseSummary = try container.decode(String.self, forKey: .releaseSummary)
    //        let inProgress = try container.decode(Bool.self, forKey: .inProgress)
    //        let releaseUrl = try container.decode(String.self, forKey: .releaseUrl)
    //        let skippedVersion = try container.decode(String.self, forKey: .skippedVersion)
    //        let title = try container.decode(String.self, forKey: .title)
    //        let entityPicture = try container.decode(String.self, forKey: .entityPicture)
    //        let nextDawn = try container.decode(String.self, forKey: .nextDawn)
    //        let nextDusk = try container.decode(String.self, forKey: .nextDusk)
    //        let nextMidnight = try container.decode(String.self, forKey: .nextMidnight)
    //        let nextNoon = try container.decode(String.self, forKey: .nextNoon)
    //        let nextRising = try container.decode(String.self, forKey: .nextRising)
    //        let nextSetting = try container.decode(String.self, forKey: .nextSetting)
    //        let elevation = try container.decode(Double.self, forKey: .elevation)
    //        let azimuth = try container.decode(Double.self, forKey: .azimuth)
    //        let rising = try container.decode(Bool.self, forKey: .rising)
    //        let radius = try container.decode(Int.self, forKey: .radius)
    //        let passive = try container.decode(Bool.self, forKey: .passive)
    //        let persons = try container.decode(Person.self, forKey: .persons)
    //        let deviceClass = try container.decode(String.self, forKey: .deviceClass)
    //        let editable = try container.decode(Bool.self, forKey: .editable)
    //        let icon = try container.decode(String.self, forKey: .icon)
    //        let latitude = try container.decode(Double.self, forKey: .latitude)
    //        let longitude = try container.decode(Double.self, forKey: .longitude)
    //        let gpsAccuracy = try container.decode(Double.self, forKey: .gpsAccuracy)
    //        let source = try container.decode(String.self, forKey: .source)
    //        let sourceType = try container.decode(String.self, forKey: .sourceType)
            let friendlyName = try container.decode(String.self, forKey: .friendlyName)
          
           // let supportedFeatures = try container.decode(String.self, forKey: .supportedFeatures)
            //let userId = try container.decode(String.self, forKey: .userId)

           
            
            
    //       // self.availableImportant = availableImportant.trimmingCharacters(in: .whitespacesAndNewlines)
    //            .replacingOccurrences(of: " ", with: "")
    //            .replacingOccurrences(of: "[", with: "")
    //            .replacingOccurrences(of: "]", with: "")
    //            .replacingOccurrences(of: "(", with: "")
    //            .replacingOccurrences(of: ")", with: "")
            
    //        self.availableOpportunistic = availableOpportunistic.trimmingCharacters(in: .whitespacesAndNewlines)
    //            .replacingOccurrences(of: " ", with: "")
    //            .replacingOccurrences(of: "[", with: "")
    //            .replacingOccurrences(of: "]", with: "")
    //            .replacingOccurrences(of: "(", with: "")
    //            .replacingOccurrences(of: ")", with: "")
            
    //        self.administrativeArea = administrativeArea.trimmingCharacters(in: .whitespacesAndNewlines)
    //            .replacingOccurrences(of: " ", with: "")
    //            .replacingOccurrences(of: "[", with: "")
    //            .replacingOccurrences(of: "]", with: "")
    //            .replacingOccurrences(of: "(", with: "")
    //            .replacingOccurrences(of: ")", with: "")
    //
    //        self.iSOCountryCode = iSOCountryCode.trimmingCharacters(in: .whitespacesAndNewlines)
    //            .replacingOccurrences(of: " ", with: "")
    //            .replacingOccurrences(of: "[", with: "")
    //            .replacingOccurrences(of: "]", with: "")
    //            .replacingOccurrences(of: "(", with: "")
    //            .replacingOccurrences(of: ")", with: "")
    //
    //        self.mobileCountryCode = mobileCountryCode.trimmingCharacters(in: .whitespacesAndNewlines)
    //            .replacingOccurrences(of: " ", with: "")
    //            .replacingOccurrences(of: "[", with: "")
    //            .replacingOccurrences(of: "]", with: "")
    //            .replacingOccurrences(of: "(", with: "")
    //            .replacingOccurrences(of: ")", with: "")
    //
    //        self.mobileNetworkCode = mobileNetworkCode.trimmingCharacters(in: .whitespacesAndNewlines)
    //            .replacingOccurrences(of: " ", with: "")
    //            .replacingOccurrences(of: "[", with: "")
    //            .replacingOccurrences(of: "]", with: "")
    //            .replacingOccurrences(of: "(", with: "")
    //            .replacingOccurrences(of: ")", with: "")
    //
            //self.country = country
            //self.available = available
            //self.lowPowerMode = lowPowerMode
            //self.name = name
    //        self.total = total
    //        self.types = Types()
    //        self.areasOfInterest = areasOfInterest
    //        self.unitOfMeasurement = unitOfMeasurement
    //        self.locality = locality
    //        self.location = Location()
    //        self.ocean = ocean
    //        self.allowsVoIP = allowsVoIP
    //        self.carrierID = carrierID
    //        self.carrierName = carrierName
    //        self.hardwareAddress = hardwareAddress
    //        self.administrativeArea = administrativeArea
    //        self.areasOfInterest = areasOfInterest
    //        self.inlandWater = inlandWater
    //        self.attributesId = attributesId
    //        self.confidence = confidence
    //        self.autoUpdate = autoUpdate
    //        self.installedVersion = installedVersion
    //        self.latestVersion = latestVersion
    //        self.releaseSummary = releaseSummary
    //        self.inProgress = inProgress
    //        self.releaseUrl = releaseUrl
    //        self.skippedVersion = skippedVersion
    //        self.title = title
    //        self.entityPicture = entityPicture
    //        self.nextDawn = nextDawn
    //        self.nextDusk = nextDawn
    //        self.nextMidnight = nextMidnight
    //        self.nextNoon = nextNoon
    //        self.nextRising = nextRising
    //        self.nextSetting = nextSetting
    //        self.elevation = elevation
    //        self.azimuth = azimuth
    //        self.rising = rising
    //        self.radius = radius
    //        self.passive = passive
    //        self.persons = Person()
    //        self.deviceClass = deviceClass
    //        self.editable = editable
    //        self.icon = icon
    //        self.latitude = latitude
    //        self.longitude = longitude
    //        self.gpsAccuracy = gpsAccuracy
    //        self.source = source
    //        self.sourceType = sourceType
            
            self.friendlyName = friendlyName
            //self.supportedFeatures = supportedFeatures
            //self.userId = userId
            
            
        }
        
        
    }





