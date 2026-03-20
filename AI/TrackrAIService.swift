//
//  TrackrAIService.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import Foundation
import Combine


class TrackrAIService: NSObject, ObservableObject, URLSessionDelegate {
    @Published var messages: [AIMessage] = []
    @Published var isLoading = false
    
    // YOUR API KEYS
    private let groqApiKey = ""
    private let tmdbApiKey = ""
    private let newsApiKey = ""
    private let cryptoApiKey = ""
    
    // STORAGE SETTINGS
    private let messagesStorageKey = "ChatMessages"
    private let maxStoredMessages = 100  // 🔢 CHANGE THIS NUMBER TO SET LIMIT
    
    // Custom URLSession that bypasses SSL verification
    private lazy var customURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // Initialize and load saved messages
    override init() {
        super.init()
        loadMessages()
    }
    
    // Bypass SSL certificate validation
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    // MARK: - Persistence Functions WITH LIMIT
    
    private func saveMessages() {
        // Keep only the most recent messages
        if messages.count > maxStoredMessages {
            messages = Array(messages.suffix(maxStoredMessages))
            print("📝 Trimmed to last \(maxStoredMessages) messages")
        }
        
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: messagesStorageKey)
            print("💾 Saved \(messages.count) messages to storage")
        } catch {
            print("❌ Failed to save messages: \(error)")
        }
    }
    
    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: messagesStorageKey) else {
            print("📱 No saved messages found - starting fresh")
            return
        }
        
        do {
            let savedMessages = try JSONDecoder().decode([AIMessage].self, from: data)
            messages = savedMessages
            print("✅ Loaded \(messages.count) messages from storage")
        } catch {
            print("❌ Failed to load messages: \(error)")
            messages = []
        }
    }
    
    func sendMessage(_ text: String) {
        let userMessage = AIMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        saveMessages() // Save after adding user message
        
        isLoading = true
        
        Task {
            do {
                let response = try await handleQuery(text)
                
                await MainActor.run {
                    let aiMessage = AIMessage(
                        content: response,
                        isUser: false,
                        timestamp: Date()
                    )
                    self.messages.append(aiMessage)
                    self.saveMessages() // Save after adding AI response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = AIMessage(
                        content: "✅ Let me try a different approach. Please try again! 🔄",
                        isUser: false,
                        timestamp: Date()
                    )
                    self.messages.append(errorMessage)
                    self.saveMessages() // Save error message too
                    self.isLoading = false
                }
                print("API Error: \(error)")
            }
        }
    }
    
    private func handleQuery(_ query: String) async throws -> String {
        let lowercaseQuery = query.lowercased()
        
        // Simple test response
        if lowercaseQuery.contains("test") || lowercaseQuery.contains("hello") {
            return "🎉 **Trackr AI is working perfectly!**\n\nTry asking me about:\n• 🪙 **Crypto prices** - \"bitcoin price\"\n• 🎬 **Movies** - \"tell me about RRR\"\n• 🌤️ **Weather** - \"weather in chennai\"\n• 📰 **News** - \"latest news\""
        }
        
        // CRYPTO QUERIES
        if isCryptoQuery(lowercaseQuery) {
            return try await handleCryptoQuery(query)
        }
        // MOVIE QUERIES
        else if isMovieQuery(lowercaseQuery) {
            return try await handleMovieQuery(query)
        }
        // WEATHER QUERIES
        else if isWeatherQuery(lowercaseQuery) {
            return try await handleWeatherQuery(query)
        }
        // NEWS QUERIES
        else if isNewsQuery(lowercaseQuery) {
            return try await handleNewsQuery(query)
        }
        // GENERAL AI QUERIES
        else {
            return try await callGroqAPI(with: query)
        }
    }
    
    // MARK: - Query Detection
    
    private func isCryptoQuery(_ query: String) -> Bool {
        let cryptoTerms = [
            "bitcoin", "btc", "ethereum", "eth", "dogecoin", "doge", "cardano", "ada",
            "solana", "sol", "crypto", "cryptocurrency", "coin price", "crypto price",
            "current price", "price of", "top crypto", "market cap", "real time price", "top 50", "top 10"
        ]
        return cryptoTerms.contains { query.contains($0) }
    }
    
    private func isMovieQuery(_ query: String) -> Bool {
        let movieTerms = [
            "movies", "movie", "theaters", "cinema", "films", "telugu movies",
            "hindi movies", "bollywood", "tollywood", "tell me about", "review", "current movies"
        ]
        return movieTerms.contains { query.contains($0) }
    }
    
    private func isWeatherQuery(_ query: String) -> Bool {
        let weatherTerms = ["weather", "temperature", "forecast", "climate", "weather in"]
        return weatherTerms.contains { query.contains($0) }
    }
    
    private func isNewsQuery(_ query: String) -> Bool {
        let newsTerms = ["news", "headlines", "breaking news", "latest news", "crypto news"]
        return newsTerms.contains { query.contains($0) }
    }
    
    // MARK: - CRYPTO API CALLS (CoinGecko)
    
    private func handleCryptoQuery(_ query: String) async throws -> String {
        let lowercaseQuery = query.lowercased()
        
        if lowercaseQuery.contains("dogecoin") || lowercaseQuery.contains("doge") {
            return try await getCryptoPrice(coinId: "dogecoin", name: "Dogecoin", symbol: "DOGE", emoji: "🐕")
        }
        else if lowercaseQuery.contains("bitcoin") || lowercaseQuery.contains("btc") {
            return try await getCryptoPrice(coinId: "bitcoin", name: "Bitcoin", symbol: "BTC", emoji: "🪙")
        }
        else if lowercaseQuery.contains("ethereum") || lowercaseQuery.contains("eth") {
            return try await getCryptoPrice(coinId: "ethereum", name: "Ethereum", symbol: "ETH", emoji: "⚡")
        }
        else {
            return try await getTopCryptocurrencies()
        }
    }
    
    private func getCryptoPrice(coinId: String, name: String, symbol: String, emoji: String) async throws -> String {
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinId)&vs_currencies=usd&include_24hr_change=true&include_market_cap=true"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let coinData = json[coinId] as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        let price = coinData["usd"] as? Double ?? 0.0
        let change24h = coinData["usd_24h_change"] as? Double ?? 0.0
        let marketCap = coinData["usd_market_cap"] as? Double ?? 0.0
        
        let changeIcon = change24h >= 0 ? "📈" : "📉"
        let changeSign = change24h >= 0 ? "+" : ""
        
        return """
\(emoji) **\(name) (\(symbol)) - Live Price**

**💰 Current Price: $\(String(format: "%.6f", price))**
**📈 24h Change: \(changeSign)\(String(format: "%.2f", change24h))% \(changeIcon)**
**📊 Market Cap: $\(formatNumber(marketCap))**

**⚡ Live data from CoinGecko API**
"""
    }
    
    private func getTopCryptocurrencies() async throws -> String {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let cryptos = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        var result = "🏆 **Top 10 Cryptocurrencies (Real-Time)**\n\n"
        
        let emojis = ["🪙", "⚡", "🔷", "💎", "🌐", "🔸", "⭐", "🚀", "💫", "🔥"]
        
        for (index, crypto) in cryptos.enumerated() {
            let name = crypto["name"] as? String ?? "Unknown"
            let symbol = crypto["symbol"] as? String ?? "???"
            let price = crypto["current_price"] as? Double ?? 0.0
            let change24h = crypto["price_change_percentage_24h"] as? Double ?? 0.0
            let marketCap = crypto["market_cap"] as? Double ?? 0.0
            
            let changeIcon = change24h >= 0 ? "📈" : "📉"
            let changeSign = change24h >= 0 ? "+" : ""
            let emoji = emojis[index % emojis.count]
            
            result += """
\(emoji) **#\(index + 1) \(name) (\(symbol.uppercased()))**
Price: $\(String(format: "%.6f", price)) | 24h: \(changeSign)\(String(format: "%.2f", change24h))% \(changeIcon)
Market Cap: $\(formatNumber(marketCap))

"""
        }
        
        result += "**⚡ Live data from CoinGecko API**"
        return result
    }
    
    // MARK: - MOVIE API CALLS (TMDB)
    
    private func handleMovieQuery(_ query: String) async throws -> String {
        let lowercaseQuery = query.lowercased()
        
        if lowercaseQuery.contains("telugu") {
            return try await getMoviesByLanguage(language: "te", languageName: "Telugu")
        }
        else if lowercaseQuery.contains("hindi") || lowercaseQuery.contains("bollywood") {
            return try await getMoviesByLanguage(language: "hi", languageName: "Hindi")
        }
        else if lowercaseQuery.contains("tell me about") || lowercaseQuery.contains("review") {
            let movieName = extractMovieNameFromQuery(query)
            return try await searchSpecificMovie(movieName: movieName)
        }
        else {
            return try await getCurrentMovies()
        }
    }
    
    private func getMoviesByLanguage(language: String, languageName: String) async throws -> String {
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(tmdbApiKey)&with_original_language=\(language)&sort_by=release_date.desc&primary_release_date.gte=2024-01-01&page=1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("TMDB Status Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                return "❌ TMDB API Key issue. Please verify your API key: \(tmdbApiKey)"
            }
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        guard let results = json["results"] as? [[String: Any]] else {
            return "No \(languageName) movies found for 2024."
        }
        
        if results.isEmpty {
            return "No recent \(languageName) movies found in 2024."
        }
        
        var result = "🎬 **Current \(languageName) Movies (Real-Time from TMDB)**\n\n"
        
        for (index, movieDict) in results.prefix(10).enumerated() {
            let title = movieDict["title"] as? String ?? "Unknown Title"
            let releaseDate = movieDict["release_date"] as? String ?? "Unknown Date"
            let voteAverage = movieDict["vote_average"] as? Double ?? 0.0
            let overview = movieDict["overview"] as? String ?? "No description available"
            
            result += """
\(index + 1). **\(title)**
📅 Released: \(releaseDate)
⭐ Rating: \(String(format: "%.1f", voteAverage))/10
📝 \(String(overview.prefix(100)))...

"""
        }
        
        result += "**⚡ Live data from TMDB API**"
        return result
    }
    
    private func getCurrentMovies() async throws -> String {
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(tmdbApiKey)&language=en-US&page=1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        var result = "🍿 **Movies Currently in Theaters (Real-Time from TMDB)**\n\n"
        
        for (index, movieDict) in results.prefix(10).enumerated() {
            let title = movieDict["title"] as? String ?? "Unknown Title"
            let releaseDate = movieDict["release_date"] as? String ?? "Unknown Date"
            let voteAverage = movieDict["vote_average"] as? Double ?? 0.0
            let overview = movieDict["overview"] as? String ?? "No description available"
            
            result += """
\(index + 1). **\(title)**
📅 Released: \(releaseDate)
⭐ Rating: \(String(format: "%.1f", voteAverage))/10
📝 \(String(overview.prefix(100)))...

"""
        }
        
        result += "**⚡ Live data from TMDB API**"
        return result
    }
    
    private func searchSpecificMovie(movieName: String) async throws -> String {
        let encodedName = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? movieName
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(tmdbApiKey)&query=\(encodedName)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return "Sorry, I couldn't find information about '\(movieName)'. Try a different movie name!"
        }
        
        if results.isEmpty {
            return "Sorry, I couldn't find information about '\(movieName)'. Try a different movie name!"
        }
        
        let firstMovie = results.first!
        let title = firstMovie["title"] as? String ?? "Unknown Title"
        let releaseDate = firstMovie["release_date"] as? String ?? "Unknown Date"
        let voteAverage = firstMovie["vote_average"] as? Double ?? 0.0
        let overview = firstMovie["overview"] as? String ?? "No description available"
        
        return """
🎬 **\(title) - Movie Details**

⭐ **Rating:** \(String(format: "%.1f", voteAverage))/10
📅 **Release Date:** \(releaseDate)

📝 **Plot:**
\(overview)

**⚡ Real-time data from TMDB API**
"""
    }
    
    // MARK: - WEATHER API CALLS (Open-Meteo)
    
    private func handleWeatherQuery(_ query: String) async throws -> String {
        let city = extractCityFromQuery(query) ?? "Vellore"
        let coordinates = getCityCoordinates(city: city)
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(coordinates.lat)&longitude=\(coordinates.lon)&current_weather=true&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let currentWeather = json["current_weather"] as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        let temperature = currentWeather["temperature"] as? Double ?? 0.0
        let windspeed = currentWeather["windspeed"] as? Double ?? 0.0
        let winddirection = currentWeather["winddirection"] as? Double ?? 0.0
        let weathercode = currentWeather["weathercode"] as? Int ?? 0
        let time = currentWeather["time"] as? String ?? ""
        
        return """
🌤️ **Current Weather in \(city.capitalized)**

**🌡️ Temperature:** \(String(format: "%.1f", temperature))°C
**💨 Wind Speed:** \(String(format: "%.1f", windspeed)) km/h
**🧭 Wind Direction:** \(Int(winddirection))°

**📊 Current Conditions:**
- **Weather:** \(getWeatherDescription(weathercode))
- **Time:** \(time)

**⚡ Live data from Open-Meteo API**
"""
    }
    
    // MARK: - NEWS API CALLS
    
    private func handleNewsQuery(_ query: String) async throws -> String {
        let lowercaseQuery = query.lowercased()
        
        var newsQuery = "technology"
        if lowercaseQuery.contains("crypto") {
            newsQuery = "cryptocurrency"
        } else if lowercaseQuery.contains("business") {
            newsQuery = "business"
        }
        
        let urlString = "https://newsapi.org/v2/everything?q=\(newsQuery)&apiKey=\(newsApiKey)&language=en&sortBy=publishedAt&pageSize=5"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let articles = json["articles"] as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        var result = "📰 **Latest \(newsQuery.capitalized) News (Real-Time)**\n\n"
        
        for (index, articleDict) in articles.enumerated() {
            let title = articleDict["title"] as? String ?? "No title"
            let description = articleDict["description"] as? String ?? "No description available"
            let publishedAt = articleDict["publishedAt"] as? String ?? ""
            let source = (articleDict["source"] as? [String: Any])?["name"] as? String ?? "Unknown source"
            
            result += """
\(index + 1). **\(title)**
📰 Source: \(source)
📅 Published: \(formatDate(publishedAt))
📝 \(description)

"""
        }
        
        result += "**⚡ Live data from NewsAPI**"
        return result
    }
    
    // MARK: - GROQ API CALL
    
    private func callGroqAPI(with text: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(groqApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("TrackrAI/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 25
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                ["role": "system", "content": "You are Trackr AI, a helpful assistant with real-time data capabilities for crypto, movies, weather, and news."],
                ["role": "user", "content": text]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (data, response) = try await customURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Helper Functions
    
    private func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000_000_000 {
            return String(format: "%.1fT", number / 1_000_000_000_000)
        } else if number >= 1_000_000_000 {
            return String(format: "%.1fB", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.1fM", number / 1_000_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
    
    private func extractCityFromQuery(_ query: String) -> String? {
        let cities = [
            "vellore": "Vellore", "chennai": "Chennai", "mumbai": "Mumbai",
            "delhi": "Delhi", "bangalore": "Bangalore", "hyderabad": "Hyderabad",
            "kolkata": "Kolkata", "pune": "Pune", "london": "London", "new york": "New York"
        ]
        let lowercaseQuery = query.lowercased()
        
        for (key, value) in cities {
            if lowercaseQuery.contains(key) {
                return value
            }
        }
        return nil
    }
    
    private func getCityCoordinates(city: String) -> (lat: Double, lon: Double) {
        let coordinates = [
            "Vellore": (12.9165, 79.1325),
            "Chennai": (13.0827, 80.2707),
            "Mumbai": (19.0760, 72.8777),
            "Delhi": (28.7041, 77.1025),
            "Bangalore": (12.9716, 77.5946),
            "Hyderabad": (17.3850, 78.4867),
            "Kolkata": (22.5726, 88.3639),
            "London": (51.5074, -0.1278),
            "New York": (40.7128, -74.0060)
        ]
        
        return coordinates[city] ?? (12.9165, 79.1325)
    }
    
    private func getWeatherDescription(_ code: Int) -> String {
        switch code {
        case 0: return "Clear sky ☀️"
        case 1, 2, 3: return "Partly cloudy 🌤️"
        case 45, 48: return "Foggy 🌫️"
        case 51, 53, 55: return "Drizzle 🌦️"
        case 61, 63, 65: return "Rain 🌧️"
        case 80, 81, 82: return "Rain showers 🌧️"
        case 95: return "Thunderstorm ⛈️"
        default: return "Unknown ❓"
        }
    }
    
    // FIXED: Better movie name extraction
    private func extractMovieNameFromQuery(_ query: String) -> String {
        var lowercaseQuery = query.lowercased()
        
        // Remove common prefixes
        let prefixes = [
            "tell me about the movie ",
            "tell me about movie ",
            "tell me about ",
            "movie ",
            "review of ",
            "review of the movie ",
            "what is ",
            "what is the movie ",
            "about ",
            "search for ",
            "find "
        ]
        
        for prefix in prefixes {
            if lowercaseQuery.hasPrefix(prefix) {
                lowercaseQuery = String(lowercaseQuery.dropFirst(prefix.count))
                break
            }
        }
        
        // Remove common suffixes
        let suffixes = [" movie", " film", " cinema"]
        for suffix in suffixes {
            if lowercaseQuery.hasSuffix(suffix) {
                lowercaseQuery = String(lowercaseQuery.dropLast(suffix.count))
                break
            }
        }
        
        // Clean up extra spaces and return
               let cleanedQuery = lowercaseQuery.trimmingCharacters(in: .whitespacesAndNewlines)
               
               print("Original query: '\(query)'")
               print("Extracted movie name: '\(cleanedQuery)'")
               
               return cleanedQuery
           }
           
           private func formatDate(_ dateString: String) -> String {
               let formatter = ISO8601DateFormatter()
               formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
               
               if let date = formatter.date(from: dateString) {
                   let displayFormatter = DateFormatter()
                   displayFormatter.dateStyle = .medium
                   displayFormatter.timeStyle = .short
                   return displayFormatter.string(from: date)
               }
               
               return dateString
           }
           
           // MARK: - Clear Chat with Persistence
           
           func clearChat() {
               messages.removeAll()
               saveMessages() // Save the empty state
               print("🗑️ Chat cleared and saved to storage")
           }
           
           // MARK: - Additional Utility Functions
           
           func exportChatHistory() -> String {
               var exportText = "Trackr AI Chat History\n"
               exportText += "Exported on: \(Date())\n"
               exportText += "Total Messages: \(messages.count)\n\n"
               
               for message in messages {
                   let sender = message.isUser ? "You" : "Trackr AI"
                   let timestamp = DateFormatter.localizedString(from: message.timestamp, dateStyle: .short, timeStyle: .short)
                   exportText += "[\(timestamp)] \(sender): \(message.content)\n\n"
               }
               
               return exportText
           }
           
           func getMessageCount() -> Int {
               return messages.count
           }
           
           func getLastMessageTime() -> Date? {
               return messages.last?.timestamp
           }
        }
