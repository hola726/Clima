import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather:WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=\(Bundle.main.apiKey)&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitute: CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitute)"
        performRequest(urlString: urlString)
        
    }
    
    
    func performRequest(urlString:String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }

                
                if let safeData = data{

                    if let weather = parseJson(weatherData: safeData){
                        delegate?.didUpdateWeather(self, weather: weather)
                        
                    }

                    
                }
            }
            
            task.resume()
        }
    }
    
    func parseJson(weatherData: Data)-> WeatherModel?{
        let decoder = JSONDecoder()
        
        do{
            let decodeData = try decoder.decode(WeatherData.self, from:weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    

    
}
