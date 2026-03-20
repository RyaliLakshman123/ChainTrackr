//
//  RealTimeDataService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import Foundation

// MARK: - News Models
struct NewsResponse: Codable {
    let articles: [NewsArticle]
}

struct NewsArticle: Codable {
    let title: String
    let description: String?
    let url: String
    let publishedAt: String
    let source: NewsSource
}

struct NewsSource: Codable {
    let name: String
}

// MARK: - Weather Models
struct WeatherResponse: Codable {
    let location: WeatherLocation
    let current: CurrentWeather
}

struct WeatherLocation: Codable {
    let name: String
    let country: String
}

struct CurrentWeather: Codable {
    let tempC: Double
    let tempF: Double
    let condition: WeatherCondition
    let humidity: Int
    let windKph: Double
    
    private enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case condition, humidity
        case windKph = "wind_kph"
    }
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
}

// MARK: - Stock Models
struct StockResponse: Codable {
    let globalQuote: StockQuote
    
    private enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct StockQuote: Codable {
    let symbol: String
    let price: String
    let change: String
    let changePercent: String
    
    private enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
    }
}

// MARK: - Movie Models
struct MovieInfo: Codable {
    let title: String
    let genre: String
    let releaseDate: String
    let description: String?
}

class RealTimeDataService {
    static let shared = RealTimeDataService()
    private init() {}
    
    // MARK: - News API
    func getLatestNews(query: String = "technology") async throws -> [NewsArticle] {
        return getSampleNews(for: query)
    }
    
    func getCryptoNews() async throws -> [NewsArticle] {
        return getSampleCryptoNews()
    }
    
    // MARK: - Weather API (Enhanced for any city)
    func getCurrentWeather(city: String = "London") async throws -> WeatherResponse {
        return getSampleWeather(for: city)
    }
    
    // MARK: - Stock API
    func getStockPrice(symbol: String) async throws -> StockQuote {
        return getSampleStock(for: symbol)
    }
    
    // MARK: - Movies API
    func getCurrentMovies() async throws -> [MovieInfo] {
        return getCurrentMoviesInTheaters()
    }
    
    // MARK: - Time & Date
    func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    func getTimeZone(for city: String) -> String {
        let timezones = [
            "london": "GMT+0 (London, UK)",
            "new york": "EST-5 (New York, USA)",
            "tokyo": "JST+9 (Tokyo, Japan)",
            "sydney": "AEDT+11 (Sydney, Australia)",
            "dubai": "GST+4 (Dubai, UAE)",
            "mumbai": "IST+5:30 (Mumbai, India)",
            "delhi": "IST+5:30 (Delhi, India)",
            "bangalore": "IST+5:30 (Bangalore, India)",
            "hyderabad": "IST+5:30 (Hyderabad, India)",
            "chennai": "IST+5:30 (Chennai, India)",
            "kolkata": "IST+5:30 (Kolkata, India)",
            "amlapuram": "IST+5:30 (Amlapuram, India)",
            "amalapuram": "IST+5:30 (Amalapuram, India)"
        ]
        return timezones[city.lowercased()] ?? "UTC+0 (Coordinated Universal Time)"
    }
    
    // MARK: - Market Status
    func getMarketStatus() -> String {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let weekday = calendar.component(.weekday, from: now)
        
        let isWeekday = weekday >= 2 && weekday <= 6
        let isMarketHours = hour >= 9 && hour <= 16
        
        if isWeekday && isMarketHours {
            return "🟢 **US Stock Market: OPEN**\n\nTrading hours: 9:30 AM - 4:00 PM EST"
        } else {
            return "🔴 **US Stock Market: CLOSED**\n\nNext opening: Monday 9:30 AM EST"
        }
    }
    
    // MARK: - Sample Data (Enhanced)
    
    private func getSampleNews(for query: String) -> [NewsArticle] {
        if query.lowercased().contains("crypto") {
            return getSampleCryptoNews()
        }
        
        return [
            NewsArticle(
                title: "Breaking: Latest Technology Developments",
                description: "Major tech companies announce new innovations in AI and blockchain technology.",
                url: "https://example.com/news1",
                publishedAt: ISO8601DateFormatter().string(from: Date()),
                source: NewsSource(name: "Tech News")
            ),
            NewsArticle(
                title: "Market Update: Tech Stocks Rally",
                description: "Technology stocks see significant gains amid positive earnings reports.",
                url: "https://example.com/news2",
                publishedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                source: NewsSource(name: "Financial Times")
            )
        ]
    }
    
    private func getSampleCryptoNews() -> [NewsArticle] {
        return [
            NewsArticle(
                title: "Bitcoin Reaches New Support Level",
                description: "Bitcoin shows strong support at current levels as institutional adoption continues.",
                url: "https://example.com/crypto1",
                publishedAt: ISO8601DateFormatter().string(from: Date()),
                source: NewsSource(name: "CoinDesk")
            ),
            NewsArticle(
                title: "Ethereum Upgrade Shows Promise",
                description: "Latest Ethereum network improvements show increased efficiency and lower fees.",
                url: "https://example.com/crypto2",
                publishedAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800)),
                source: NewsSource(name: "CryptoPanic")
            )
        ]
    }
    
    // Enhanced weather with dynamic city support - FIXED
    private func getSampleWeather(for city: String) -> WeatherResponse {
        print("🌤️ Getting weather for city: \(city)") // Debug print
        
        let temp = Double.random(in: 20...35) // Realistic range for Indian cities
        let country = getCountryForCity(city)
        
        let conditions = ["Sunny", "Partly Cloudy", "Cloudy", "Light Rain", "Clear", "Hot", "Warm"]
        let randomCondition = conditions.randomElement() ?? "Partly Cloudy"
        
        // Make sure city name is properly capitalized
        let properCityName = city.capitalized
        
        return WeatherResponse(
            location: WeatherLocation(name: properCityName, country: country),
            current: CurrentWeather(
                tempC: temp,
                tempF: temp * 9/5 + 32,
                condition: WeatherCondition(text: randomCondition, icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"),
                humidity: Int.random(in: 45...85),
                windKph: Double.random(in: 8...25)
            )
        )
    }
    
    private func getCountryForCity(_ city: String) -> String {
        let cityCountryMap = [
            // India - comprehensive list
            "amlapuram": "India", "amalapuram": "India", "mumbai": "India", "delhi": "India",
            "bangalore": "India", "hyderabad": "India", "chennai": "India", "kolkata": "India",
            "pune": "India", "ahmedabad": "India", "jaipur": "India", "lucknow": "India",
            "kanpur": "India", "nagpur": "India", "visakhapatnam": "India", "bhopal": "India",
            "patna": "India", "vadodara": "India", "ghaziabad": "India", "ludhiana": "India",
            "agra": "India", "nashik": "India", "faridabad": "India", "meerut": "India",
            "rajkot": "India", "varanasi": "India", "srinagar": "India", "aurangabad": "India",
            "dhanbad": "India", "amritsar": "India", "allahabad": "India", "gwalior": "India",
            "jabalpur": "India", "coimbatore": "India", "madurai": "India", "jodhpur": "India",
            "kota": "India", "chandigarh": "India", "guwahati": "India", "guntur": "India",
            "tirupati": "India", "vijayawada": "India", "rajahmundry": "India", "kakinada": "India",
            "nellore": "India", "vizag": "India", "warangal": "India", "karimnagar": "India",
            "khammam": "India", "nizamabad": "India", "mahbubnagar": "India", "adilabad": "India",
            "medak": "India", "rangareddy": "India", "nalgonda": "India", "anantapur": "India",
            "kurnool": "India", "kadapa": "India", "chittoor": "India", "prakasam": "India",
            "krishna": "India", "west godavari": "India", "east godavari": "India", "srikakulam": "India",
            
            // USA
            "new york": "USA", "los angeles": "USA", "chicago": "USA", "houston": "USA",
            "phoenix": "USA", "philadelphia": "USA", "san antonio": "USA", "san diego": "USA",
            "dallas": "USA", "san jose": "USA", "austin": "USA", "jacksonville": "USA",
            "san francisco": "USA", "columbus": "USA", "fort worth": "USA", "indianapolis": "USA",
            "charlotte": "USA", "seattle": "USA", "denver": "USA", "boston": "USA",
            "el paso": "USA", "detroit": "USA", "nashville": "USA", "portland": "USA",
            "las vegas": "USA", "oklahoma city": "USA", "tucson": "USA", "albuquerque": "USA",
            "atlanta": "USA", "colorado springs": "USA", "raleigh": "USA", "omaha": "USA",
            "miami": "USA", "oakland": "USA", "minneapolis": "USA", "tulsa": "USA",
            "cleveland": "USA", "wichita": "USA", "arlington": "USA", "new orleans": "USA",
            
            // UK
            "london": "UK", "birmingham": "UK", "manchester": "UK", "glasgow": "UK",
            "liverpool": "UK", "leeds": "UK", "sheffield": "UK", "edinburgh": "UK",
            "bristol": "UK", "cardiff": "UK", "leicester": "UK", "coventry": "UK",
            "bradford": "UK", "belfast": "UK", "nottingham": "UK", "kingston upon hull": "UK",
            
            // Other countries
            "tokyo": "Japan", "osaka": "Japan", "yokohama": "Japan", "nagoya": "Japan",
            "sydney": "Australia", "melbourne": "Australia", "perth": "Australia", "brisbane": "Australia",
            "dubai": "UAE", "abu dhabi": "UAE", "sharjah": "UAE",
            "paris": "France", "marseille": "France", "lyon": "France", "toulouse": "France",
            "berlin": "Germany", "hamburg": "Germany", "munich": "Germany", "cologne": "Germany",
            "madrid": "Spain", "barcelona": "Spain", "valencia": "Spain", "seville": "Spain",
            "rome": "Italy", "milan": "Italy", "naples": "Italy", "turin": "Italy",
            "toronto": "Canada", "montreal": "Canada", "vancouver": "Canada", "calgary": "Canada",
            "singapore": "Singapore", "kuala lumpur": "Malaysia", "bangkok": "Thailand",
            "manila": "Philippines", "jakarta": "Indonesia", "seoul": "South Korea",
            "beijing": "China", "shanghai": "China", "guangzhou": "China", "shenzhen": "China"
        ]
        
        return cityCountryMap[city.lowercased()] ?? "Unknown"
    }
    
    // Updated movie data for 2025
    private func getCurrentMoviesInTheaters() -> [MovieInfo] {
        return [
            MovieInfo(
                title: "Captain America: Brave New World",
                genre: "Action/Superhero",
                releaseDate: "February 14, 2025",
                description: "Sam Wilson officially takes on the mantle of Captain America"
            ),
            MovieInfo(
                title: "Thunderbolts",
                genre: "Action/Superhero",
                releaseDate: "May 2, 2025",
                description: "A team of antiheroes from the Marvel universe"
            ),
            MovieInfo(
                title: "The Fantastic Four: First Steps",
                genre: "Action/Superhero",
                releaseDate: "July 25, 2025",
                description: "Marvel's first family joins the MCU"
            ),
            MovieInfo(
                title: "Mission: Impossible – The Final Reckoning",
                genre: "Action/Thriller",
                releaseDate: "May 23, 2025",
                description: "Tom Cruise returns for another impossible mission"
            ),
            MovieInfo(
                title: "Avatar: Fire and Ash",
                genre: "Sci-Fi/Adventure",
                releaseDate: "December 19, 2025",
                description: "Third installment in James Cameron's Avatar saga"
            ),
            MovieInfo(
                title: "Wicked: Part Two",
                genre: "Musical/Fantasy",
                releaseDate: "November 21, 2025",
                description: "Conclusion of the Wicked musical adaptation"
            ),
            MovieInfo(
                title: "Jurassic World Rebirth",
                genre: "Action/Adventure",
                releaseDate: "July 2, 2025",
                description: "New era in the Jurassic franchise"
            ),
            MovieInfo(
                title: "Snow White",
                genre: "Fantasy/Musical",
                releaseDate: "March 21, 2025",
                description: "Disney's live-action adaptation starring Rachel Zegler"
            ),
            MovieInfo(
                title: "Lilo & Stitch",
                genre: "Family/Adventure",
                releaseDate: "May 23, 2025",
                description: "Live-action adaptation of the beloved Disney animated film"
            ),
            MovieInfo(
                title: "The Batman Part II",
                genre: "Action/Crime",
                releaseDate: "October 3, 2025",
                description: "Robert Pattinson returns as the Dark Knight"
            )
        ]
    }
    
    private func getSampleStock(for symbol: String) -> StockQuote {
        let prices: [String: (String, String, String)] = [
            "AAPL": ("220.50", "+3.25", "+1.49%"),
            "TSLA": ("185.75", "-2.15", "-1.14%"),
            "GOOGL": ("145.30", "+2.10", "+1.47%"),
            "MSFT": ("425.80", "+5.20", "+1.24%"),
            "AMZN": ("165.25", "-1.85", "-1.11%"),
            "NVDA": ("875.40", "+12.60", "+1.46%"),
            "META": ("485.75", "+8.25", "+1.73%")
        ]
        
        let data = prices[symbol.uppercased()] ?? ("100.00", "+0.00", "+0.00%")
        return StockQuote(
            symbol: symbol.uppercased(),
            price: data.0,
            change: data.1,
            changePercent: data.2
        )
    }
}
