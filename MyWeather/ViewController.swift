//
//  ViewController.swift
//  MyWeather
//
//  Created by Apple on 09/08/2022.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // API link: http://api.openweathermap.org/data/2.5/weather?lat=37.8267&lon=-122.4233&appid=7c609f73c5df2dff2f32e3e3cc33cd23
    // Outlets
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var currentCityTemp: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var specialBG: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    // Constants
    let locationManager = CLLocationManager()
    
    
    // Variables
    var currentWeather: CurrentWeather!
    var currentLocation: CLLocation!
    var forecastWeather: ForecastWeather!
    var forecastArray = [ForecastWeather]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callDelegates()
        currentWeather = CurrentWeather()
        setupLocation()
        downloadWeatherImage()
        applyEffect()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthCheck()
        downloadForecastWeather {
            print("DATA DOWNLOADED")
        }
    }
    
    /// hàm gọi delegate vadf data source
    func callDelegates() {
        locationManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// thiết lập lpcation manager
    func setupLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // lấy permission từ người dùng
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    /// kiểm tra trạng thái xác thực vị trí của ngừoi dùng, nếu người dùng ko cho phép lấy vị trí tiếp tục yêu cầu
    func locationAuthCheck() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // lấy dữ liệu vị trí từ thiết bị
            currentLocation = locationManager.location
            
            // truyền dữ liệu vị trí vào API
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            
            // Download API Data
            currentWeather.downloadCurrentWeather {
                // cập nhật ui sau khi tải thành công data
                self.updateUI()
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthCheck()
        }
    }
    
    
    /// hàm dùng để ap dụng hiệu ứng cho background
    func applyEffect() {
        specialEffect(view: specialBG, intensity: 45)
    }
    
    
    
    func specialEffect(view: UIView, intensity: Double) {
        let horizontalMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotion.minimumRelativeValue = -intensity
        horizontalMotion.maximumRelativeValue = intensity
        
        let verticalMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotion.minimumRelativeValue = -intensity
        verticalMotion.maximumRelativeValue = intensity
        
        let movement = UIMotionEffectGroup()
        movement.motionEffects = [horizontalMotion, verticalMotion]
        view.addMotionEffect(movement)
    }
    
    
    /// hàm cập nhật giao diện theo thời tiết hiện tại
    func updateUI() {
        cityName.text = currentWeather.cityName
        currentCityTemp.text = "\(Int(currentWeather.currentTemp))°"
        weatherType.text = currentWeather.weatherType
        currentDate.text = currentWeather.date
    }
      /// hàm download dự báo thời tiết
    ///
   
    func downloadForecastWeather(completed: @escaping DownloadComplete) {
        Alamofire.request(FORECAST_API_URL).responseJSON { (response) in
            let result = response.result
            if let dictionary = result.value as? Dictionary<String, AnyObject> {
                if let list = dictionary["list"] as? [Dictionary<String, AnyObject>] {
                    for item in list {
                        let forecast = ForecastWeather(weatherDict: item)
                        self.forecastArray.append(forecast)
                    }
                    self.forecastArray.remove(at: 0)
                    self.tableView.reloadData()
                }
            }
            completed()
        }
    }
    
    func downloadWeatherImage() {
        Alamofire.request(API_URL).responseJSON { (response) in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let iconName = jsonWeather["icon"].stringValue
                
                self.weatherImage.image = UIImage(named: iconName)
                
                let suffix = iconName.suffix(1)
                if suffix == "n" {
                    self.specialBG.image = UIImage(named: "bg-n")
                } else {
                    self.specialBG.image = UIImage(named: "bg-d")
                }
            }
            
        }
        
    }
    
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as! ForecastCell
        
        cell.configureCell(forecastData: forecastArray[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastArray.count
    }
}


