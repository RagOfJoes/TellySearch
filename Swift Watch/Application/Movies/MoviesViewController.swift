//
//  MoviesViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises

// MARK: - MoviesViewController
class MoviesViewController: UIViewController  {
    var inTheatresSection = MovieSection(title: "In Theatres")
    var popularSection = MovieSection(title: "Popular")
    var topRatedSection = MovieSection(title: "Top Rated")
    var upcomingSection = MovieSection(title: "Upcoming")
    
    var page: [MovieSection] = [MovieSection(title: "In Theatres"), MovieSection(title: "Popular"), MovieSection(title: "Top Rated"), MovieSection(title: "Upcoming")]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.tableHeaderView?.backgroundColor = .clear
        
        tableView.rowHeight = 195
        tableView.estimatedRowHeight = 195
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(MovieCollectionViewTableViewCell.self, forCellReuseIdentifier: "\(MovieCollectionViewTableViewCell.self)")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        let promises = [inTheatresSection.fetchSection(with: .inTheatres), popularSection.fetchSection(with: .popular), topRatedSection.fetchSection(with: .topRated), upcomingSection.fetchSection(with: .upcoming)]
        
        all(promises)
            .then { (results) in
                self.inTheatresSection.set(results: results[0])
                self.popularSection.set(results: results[1])
                self.topRatedSection.set(results: results[2])
                self.upcomingSection.set(results: results[3])
                
                DispatchQueue.main.async {
                    // Set Correct Page DataSource
                    self.page = [self.inTheatresSection, self.popularSection, self.topRatedSection, self.upcomingSection]
                    
                    // Reload TableView's Data
                    self.tableView.reloadData()
                }
        }
        .catch { (e) in
            print(e)
        }
    }
}

// MARK: - UITableViewDelegate
extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = MovieSectionHeader()
        
        headerView.configure(with: page[section].title ?? "Blank")
        return headerView
    }
}

// MARK: - UITableViewDataSource
extension MoviesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return page.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(MovieCollectionViewTableViewCell.self)", for: indexPath) as? MovieCollectionViewTableViewCell
        {
            let data = page[indexPath.section]
            cell.configure(data)
            
            // After Configuring Cell
            // Reload Data
            cell.collectionView.reloadData()
            return cell
        }
        return UITableViewCell()
    }
}
