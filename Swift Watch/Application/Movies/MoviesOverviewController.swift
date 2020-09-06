//
//  MoviesOverviewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import SkeletonView

// MARK: - MoviesOverviewController
class MoviesOverviewController: UIViewController  {
	var movies: [[Movie]?] = []
	var sections: [MovieSectionCell] = [
		MovieSectionCell(section: MovieSection(title: "Popular"), type: .featured),
		MovieSectionCell(section: MovieSection(title: "In Theatres"), type: .regular),
		MovieSectionCell(section: MovieSection(title: "Top Rated"), type: .regular),
		MovieSectionCell(section: MovieSection(title: "Upcoming"), type: .regular)
	]
	
	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .clear
		tableView.delaysContentTouches = false
		for (index, section) in sections.enumerated() {
			if section.type == .featured {
				let identifier = "MovieFeaturedCollectionView+\(index)"
				tableView.register(MovieFeaturedCollectionView.self, forCellReuseIdentifier: identifier)
			} else {
				let identifier = "MovieCollectionView+\(index)"
				tableView.register(MovieCollectionView.self, forCellReuseIdentifier: identifier)				
			}
		}
		
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let backBarButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backBarButton
		view.backgroundColor = UIColor(named: "backgroundColor")
		
		view.addSubview(tableView)
		tableView.fillSuperview()
		
		let promises = [
			sections[0].section.fetchSection(with: .popular),
			sections[1].section.fetchSection(with: .inTheatres),
			sections[2].section.fetchSection(with: .topRated),
			sections[3].section.fetchSection(with: .upcoming)
		]
		
		all(promises)
			.then { [weak self] (results) in
				// Loop through all the results
				// and append to movies array
				for data in results {
					self?.movies.append(data)
				}
				
				// Reload TableView's Data
				// in the Main Thread
				DispatchQueue.main.async {
					self?.tableView.reloadData()
				}
		}
	}
}

// MARK: - UITableViewDelegate
extension MoviesOverviewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = OverviewHeader()
		
		headerView.configure(with: sections[section].section.title ?? "")
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellType = sections[indexPath.section].type
		switch cellType {
		case .featured:
			let height: CGFloat = .getHeight(with: K.Overview.featuredCellWidth, using: K.Overview.featuredImageRatio)
			return height + 45
		default:
			let height: CGFloat = K.Poster.height
			return height + 45
		}
	}
}

// MARK: - UITableViewDataSource
extension MoviesOverviewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellType = sections[indexPath.section].type
		
		if cellType == .featured {
			let identifier = "MovieFeaturedCollectionView+\(indexPath.section)"
			let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MovieFeaturedCollectionView
			
			if movies.count > indexPath.section, let data = movies[indexPath.section] {
				cell.delegate = self
				
				let section = indexPath.section
				cell.configure(movies: data, section: section)
			}
			return cell
		} else {
			let identifier = "MovieCollectionView+\(indexPath.section)"
			let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MovieCollectionView
			
			if movies.count > indexPath.section, let data = movies[indexPath.section] {
				cell.delegate = self
				
				let section = indexPath.section
				cell.configure(movies: data, section: section)
			}
			return cell
		}
	}
}

// MARK: - MovieCollectionViewTableViewCellDelegate
// Passes up the Index Path of the selected Movie
extension MoviesOverviewController: MovieCollectionViewTableViewCellDelegate {
	func select(movie: IndexPath) {
		guard let safeMovie = movies[movie.section]?[movie.row] else { return }
		let detailVC = MovieDetailViewController(with: safeMovie)
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
