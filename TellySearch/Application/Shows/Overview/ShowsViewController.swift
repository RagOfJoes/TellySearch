//
//  ShowsViewController.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import SkeletonView

class ShowsViewController: UIViewController {
    var shows: [[Show]?] = []
    var sections: [ShowSectionCell] = [
        ShowSectionCell(type: .Featured, section: ShowSection(title: "Airing Today"), request: NetworkManager.request(endpoint: ShowEndpoint.getOverview(type: .onTheAirToday))),
        ShowSectionCell(type: .Regular, section: ShowSection(title: "Trending Today"), request: NetworkManager.request(endpoint: ShowEndpoint.getOverview(type: .trending))),
        ShowSectionCell(type: .Regular, section: ShowSection(title: "Popular"), request: NetworkManager.request(endpoint: ShowEndpoint.getOverview(type: .popular))),
        ShowSectionCell(type: .Regular, section: ShowSection(title: "On The Air"), request: NetworkManager.request(endpoint: ShowEndpoint.getOverview(type: .onTheAir)))
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
        
        for (index, cell) in sections.enumerated() {
            if cell.type == .Featured {
                tableView.register(ShowsFeaturedCollectionView.self, forCellReuseIdentifier: "\(ShowsFeaturedCollectionView.reuseIdentifier):\(index)")
            } else {
                tableView.register(ShowsCollectionView.self, forCellReuseIdentifier: "\(ShowsCollectionView.reuseIdentifier):\(index)")
            }
        }
        
        tableView.isSkeletonable = true
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        view.isSkeletonable = true
        view.showAnimatedSkeleton()
        
        let promises: [Promise<ShowSection>] = sections.map { $0.request }
        all(promises).then { [weak self] (results) in
            // Loop through all the results
            // and append to shows array
            for result in results {
                self?.shows.append(result.results)
            }
            
            self?.view.hideSkeleton()
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension ShowsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return T.Spacing.Vertical(size: .large) * 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = OverviewHeader()
        
        headerView.configure(with: sections[section].section.title ?? "")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = sections[indexPath.section].type
        return T.Height.Cell(type: cellType)
    }
}

// MARK: - UITableViewDataSource
extension ShowsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if shows.count == sections.count {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = sections[indexPath.section].type
        
        let identifier: String
        if cellType == .Featured {
            identifier = "\(ShowsFeaturedCollectionView.reuseIdentifier):\(indexPath.section)"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ShowsFeaturedCollectionView else { return UITableViewCell() }
            
            if let data = shows[indexPath.section] {
                cell.delegate = self
                
                let section = indexPath.section
                cell.configure(shows: data, section: section)
            }
            return cell
        } else {
            identifier = "\(ShowsCollectionView.reuseIdentifier):\(indexPath.section)"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ShowsCollectionView else { return UITableViewCell() }
            
            if let data = shows[indexPath.section] {
                cell.delegate = self
                
                let section = indexPath.section
                cell.configure(shows: data, section: section)
            }
            return cell
        }
    }
}

// MARK: - ShowsCollectionViewDelegate
// Passes up the Index Path of the selected Show
extension ShowsViewController: ShowsCollectionViewDelegate {
    func select(show: IndexPath) {
        guard let safeShow = shows[show.section]?[show.row] else { return }
        let detailVC = ShowDetailViewController(with: safeShow)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TabBarAnimation
extension ShowsViewController {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let tbc = tabBarController as? TabBarController else { return }
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            tbc.hideTabBar(hide: true)
        } else {
            tbc.hideTabBar(hide: false)
        }
    }
}

