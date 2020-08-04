//
//  MoviesOverviewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises

// MARK: - MoviesOverviewController
class MoviesOverviewController: UIViewController  {
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
		tableView.delaysContentTouches = false
		
		tableView.rowHeight = 225
		tableView.estimatedRowHeight = 225
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
				self.upcomingSection.set(results: results[3])
				self.topRatedSection.set(results: results[2])
				self.popularSection.set(results: results[1])
				self.inTheatresSection.set(results: results[0])
				
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
extension MoviesOverviewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = MovieSectionHeader()
		
		headerView.configure(with: page[section].title ?? "Blank")
		return headerView
	}
}

// MARK: - UITableViewDataSource
extension MoviesOverviewController: UITableViewDataSource {
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
			cell.delegate = self
			cell.configure(data)
			
			return cell
		}
		return UITableViewCell(style: .default, reuseIdentifier: "\(MovieCollectionViewTableViewCell.self)")
	}
}

// MARK: - MovieCollectionViewTableViewCellDelegate
// Passes up the Index Path of the selected Movie
extension MoviesOverviewController: MovieCollectionViewTableViewCellDelegate {
	func select(movie: IndexPath) {
		let newVC = MovieDetailController()
		
		self.navigationController?.pushViewController(newVC, animated: true)
	}
}

// MARK: - TabBarAnimation
extension MoviesOverviewController {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		guard let tbc = self.tabBarController as? TabBarController else { return }
		if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
			tbc.hideTabBar(hide: true)
		} else {
			tbc.hideTabBar(hide: false)
		}
	}
}
