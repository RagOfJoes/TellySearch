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
	var movies: [[Movie]?] = []
	var sections: [MovieSection] = [MovieSection(title: "In Theatres"), MovieSection(title: "Popular"), MovieSection(title: "Top Rated"), MovieSection(title: "Upcoming")]
	
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
		
		for (index, section) in sections.enumerated() {
			let identifier = "MovieCollectionViewTableViewCell+\(index)"
			tableView.register(MovieCollectionViewTableViewCell.self, forCellReuseIdentifier: identifier)
		}
		
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "backgroundColor")
		view.addSubview(tableView)
		tableView.fillSuperview()
		
		let promises = [sections[0].fetchSection(with: .inTheatres), sections[1].fetchSection(with: .popular), sections[2].fetchSection(with: .topRated), sections[3].fetchSection(with: .upcoming)]
		
		all(promises)
			.then { (results) in
				// Loop through all the results
				// and set them to the their respected
				// MovieSection
				for data in results {
					self.movies.append(data)
				}
				
				// Reload TableView's Data
				// in the Main Thread
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
		}
	}
}

// MARK: - UITableViewDelegate
extension MoviesOverviewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = OverviewHeader()
		
		headerView.configure(with: sections[section].title ?? "Blank")
		return headerView
	}
}

// MARK: - UITableViewDataSource
extension MoviesOverviewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return movies.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = "MovieCollectionViewTableViewCell+\(indexPath.section)"
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MovieCollectionViewTableViewCell
		cell.delegate = self
		
		if let data = movies[indexPath.section] {
			cell.configure(data)
			cell.section = indexPath.section
		}
		return cell
	}
}

// MARK: - MovieCollectionViewTableViewCellDelegate
// Passes up the Index Path of the selected Movie
extension MoviesOverviewController: MovieCollectionViewTableViewCellDelegate {
	func select(movie: IndexPath) {
		let detailVC = MovieDetailController()
		
		if let safeMovie = movies[movie.section]?[movie.row] {
			detailVC.configure(with: safeMovie)
		}
		
		navigationController?.pushViewController(detailVC, animated: true)
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
