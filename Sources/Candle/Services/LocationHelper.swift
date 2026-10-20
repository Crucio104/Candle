import Foundation
import CoreLocation
import SwiftUI

public enum LocationHelperError: LocalizedError, Sendable {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
    
    public func localizedMessage(for lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.permissionDenied, .italian):
            return "Permesso di localizzazione non concesso. Abilitalo nelle Impostazioni di iOS."
        case (.permissionDenied, .spanish):
            return "Permiso de ubicación denegado. Habilítalo en Ajustes."
        case (.permissionDenied, .french):
            return "Autorisation de localisation refusée. Activez-la dans Réglages."
        case (.permissionDenied, .german):
            return "Standortberechtigung verweigert. Aktiviere sie in den Einstellungen."
        case (.permissionDenied, .portuguese):
            return "Permissão de localização negada. Ative-a nos Ajustes."
        case (.permissionDenied, .english):
            return "Location permission denied. Please enable it in Settings."
            
        case (.locationUnavailable, .italian):
            return "Impossibile rilevare la posizione attuale al momento."
        case (.locationUnavailable, .spanish):
            return "No se pudo obtener la ubicación actual en este momento."
        case (.locationUnavailable, .french):
            return "Impossible d'obtenir la position actuelle actuellement."
        case (.locationUnavailable, .german):
            return "Aktueller Standort konnte derzeit nicht ermittelt werden."
        case (.locationUnavailable, .portuguese):
            return "Não foi possível obter a localização atual no momento."
        case (.locationUnavailable, .english):
            return "Unable to determine current location right now."
            
        case (.geocodingFailed, .italian):
            return "Impossibile convertire le coordinate nell'indirizzo del locale."
        case (.geocodingFailed, .spanish):
            return "No se pudo resolver la dirección del lugar."
        case (.geocodingFailed, .french):
            return "Impossible de résoudre l'adresse du lieu."
        case (.geocodingFailed, .german):
            return "Adresse des Ortes konnte nicht aufgelöst werden."
        case (.geocodingFailed, .portuguese):
            return "Não foi possível resolver o endereço do local."
        case (.geocodingFailed, .english):
            return "Unable to resolve venue address."
        }
    }
}

public struct CelebrationLocationData: Sendable {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    
    public init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public final class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate, @unchecked Sendable {
    public static let shared = LocationHelper()
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationCompletion: (@MainActor @Sendable (Result<CelebrationLocationData, LocationHelperError>) -> Void)?
    private var geocodeCache: [String: CLLocationCoordinate2D] = [:]
    
    @Published public var isLocating = false
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    public func requestCurrentLocation(completion: @escaping @MainActor @Sendable (Result<CelebrationLocationData, LocationHelperError>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.locationCompletion = completion
            self.isLocating = true
            
            let status = self.manager.authorizationStatus
            switch status {
            case .notDetermined:
                self.manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                self.isLocating = false
                completion(.failure(.permissionDenied))
                self.locationCompletion = nil
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            @unknown default:
                self.manager.requestLocation()
            }
        }
    }
    
    public func requestCurrentLocationName(completion: @escaping @MainActor @Sendable (Result<String, LocationHelperError>) -> Void) {
        requestCurrentLocation { result in
            switch result {
            case .success(let data):
                completion(.success(data.name))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    public static func parseCoordinates(from string: String) -> CLLocationCoordinate2D? {
        let parts = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2,
              let lat = Double(parts[0]),
              let lon = Double(parts[1]),
              (-90.0...90.0).contains(lat),
              (-180.0...180.0).contains(lon) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    public func geocodeAddress(_ address: String) async -> CLLocationCoordinate2D? {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if let direct = Self.parseCoordinates(from: trimmed) {
            return direct
        }
        
        if let cached = geocodeCache[trimmed] {
            return cached
        }
        
        return await withCheckedContinuation { continuation in
            geocoder.geocodeAddressString(trimmed) { [weak self] placemarks, _ in
                if let coord = placemarks?.first?.location?.coordinate {
                    self?.geocodeCache[trimmed] = coord
                    continuation.resume(returning: coord)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                if self.isLocating {
                    self.manager.requestLocation()
                }
            } else if status == .denied || status == .restricted {
                if self.isLocating {
                    self.isLocating = false
                    self.locationCompletion?(.failure(.permissionDenied))
                    self.locationCompletion = nil
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLocating = false
                self.locationCompletion?(.failure(.locationUnavailable))
                self.locationCompletion = nil
            }
            return
        }
        
        let geocoder = self.geocoder
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLocating = false
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                let resolvedName: String
                if let placemark = placemarks?.first {
                    var parts: [String] = []
                    if let name = placemark.name, !name.isEmpty {
                        parts.append(name)
                    }
                    if let locality = placemark.locality, !locality.isEmpty, !parts.contains(locality) {
                        parts.append(locality)
                    }
                    let formatted = parts.joined(separator: ", ")
                    resolvedName = formatted.isEmpty ? String(format: "%.4f, %.4f", lat, lon) : formatted
                } else {
                    resolvedName = String(format: "%.4f, %.4f", lat, lon)
                }
                
                let data = CelebrationLocationData(name: resolvedName, latitude: lat, longitude: lon)
                self.locationCompletion?(.success(data))
                self.locationCompletion = nil
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLocating = false
            self.locationCompletion?(.failure(.locationUnavailable))
            self.locationCompletion = nil
        }
    }
}
