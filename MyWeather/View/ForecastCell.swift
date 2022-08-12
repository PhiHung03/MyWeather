//
//  ForecastCell.swift
//  MyWeather
//
//  Created by Apple on 11/08/2022.
//

import UIKit

class ForecastCell: UITableViewCell {
    
    // Outlets
    
    
    @IBOutlet weak var forecastTemp: UILabel!
    @IBOutlet weak var forecastDay: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Hàm config cell
    ///
    /// - Parameter forecastData: kiểu dữ liệu của ForecastClass
    func configureCell(forecastData: ForecastWeather) {
        self.forecastDay.text = "\(forecastData.date)"
        self.forecastTemp.text = "\(Int(forecastData.temp))"
        
    }
    
}
