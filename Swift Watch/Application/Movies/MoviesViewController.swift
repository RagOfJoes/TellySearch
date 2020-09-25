//
//  MoviesViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import SkeletonView

class MoviesViewController: UIViewController  {
    var movies: [[Movie]?] = []
    var sections: [MovieSectionCell] = [
        MovieSectionCell(section: MovieSection(title: "Popular"), type: .featured),
        MovieSectionCell(section: MovieSection(title: "In Theatres"), type: .regular),
        MovieSectionCell(section: MovieSection(title: "Top Rated"), type: .regular),
        MovieSectionCell(section: MovieSection(title: "Upcoming"), type: .regular),
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.delaysContentTouches = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(MovieCollectionView.self, forCellReuseIdentifier: MovieCollectionView.reuseIdentifier)
        tableView.register(MovieFeaturedCollectionView.self, forCellReuseIdentifier: MovieFeaturedCollectionView.reuseIdentifier)
        
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
        
        all(promises.map {
            return $0.then({ (data) -> Promise<[Movie]> in
                return MovieSection.decodeMovieSection(data: data)
            })
        }).then { [weak self] (results) in
            // Loop through all the results
            // and append to movies array
            for result in results {
                self?.movies.append(result)
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
extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = OverviewHeader()
        
        headerView.configure(with: sections[section].section.title ?? "")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = sections[indexPath.section].type
        switch cellType {
        case .featured:
            return K.Overview.featuredCellHeight
        default:
            return K.Overview.regularHeight
        }
    }
}

// MARK: - UITableViewDataSource
extension MoviesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = sections[indexPath.section].type
        
        if cellType == .featured {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieFeaturedCollectionView.reuseIdentifier, for: indexPath) as? MovieFeaturedCollectionView else {
                return UITableViewCell()
            }
            
            if movies.count > indexPath.section, let data = movies[indexPath.section] {
                cell.delegate = self
                
                let section = indexPath.section
                cell.configure(movies: data, section: section)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCollectionView.reuseIdentifier, for: indexPath) as? MovieCollectionView else {
                return UITableViewCell()
            }
            
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
extension MoviesViewController: MovieCollectionViewTableViewCellDelegate {
    func select(movie: IndexPath) {
        guard let safeMovie = movies[movie.section]?[movie.row] else { return }
        let detailVC = MovieDetailViewController(with: safeMovie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TabBarAnimation
extension MoviesViewController {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let tbc = self.tabBarController as? TabBarController else { return }
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            tbc.hideTabBar(hide: true)
        } else {
            tbc.hideTabBar(hide: false)
        }
    }
}
