//
//  ViewController.swift
//  iOSCupCakes
//
//  Created by Mohamed Hassanin on 11.07.19.
//  Copyright © 2019 Mohamed Hassanin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var cupcakes = [Cupcake]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }


    func fetchData() {
        let url = URL(string: "http://localhost:8080/cupcakes")!
        
        URLSession.shared.dataTask(with: url){ data, response, error in
            guard let data = data else { print(error?.localizedDescription ?? "Unknown error"); return}
            let decoder = JSONDecoder()
            if let cakes = try? decoder.decode([Cupcake].self, from: data) {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.cupcakes = cakes
                    self.tableView.reloadData()
                    print("Loaded \(self.cupcakes.count) cupcakes")
                }
            }
            else {
                print("unable to parse json response")
            }
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cupcakes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cake = cupcakes[indexPath.row]
        
        cell.textLabel?.text = "\(cake.name) - €\(cake.price)"
        cell.detailTextLabel?.text = cake.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cake = cupcakes[indexPath.row]
        
        let ac = UIAlertController(title: "Order a \(cake.name)", message: "Please enter your name", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Order it!", style: .default, handler: { (action) in
            guard let name = ac.textFields?.first?.text else { return }
            self.order(cake, name: name)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func order(_ cake: Cupcake, name: String) {
        let order = Order(cakeName: cake.name, buyerName: name)
        let url = URL(string: "http://localhost:8080/order")!
        
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? encoder.encode(order)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let item = try? decoder.decode(Order.self, from: data) {
                    print(item.buyerName)
                }
                else {
                    print("Bad json received back")
                }
            }
            
        }.resume()
    }
}


