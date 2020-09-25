//
//  ShowsViewController.swift
//  Swift Watch
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
        ShowSectionCell(section: ShowSection(title: "Airing Today"), type: .featured),
        ShowSectionCell(section: ShowSection(title: "Popular"), type: .regular),
        ShowSectionCell(section: ShowSection(title: "On The Air"), type: .regular),
        ShowSectionCell(section: ShowSection(title: "Top Rated"), type: .regular),
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
        
        tableView.register(ShowsCollectionView.self, forCellReuseIdentifier: ShowsCollectionView.reuseIdentifier)
        tableView.register(ShowsFeaturedCollectionView.self, forCellReuseIdentifier: ShowsFeaturedCollectionView.reuseIdentifier)
        
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
            sections[0].section.fetchSection(with: .onTheAirToday),
            sections[1].section.fetchSection(with: .popular),
            sections[2].section.fetchSection(with: .onTheAir),
            sections[3].section.fetchSection(with: .topRated)
        ]
        
        all(promises.map {
            return $0.then({ (data) -> Promise<[Show]> in
                return ShowSection.decodeShowSection(data: data)
            })
        }).then { [weak self] (results) in
            // Loop through all the results
            // and append to shows array
            for result in results {
                self?.shows.append(result)
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
extension ShowsViewController: UITableViewDelegate {
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
extension ShowsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = sections[indexPath.section].type
        
        if cellType == .featured {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowsFeaturedCollectionView.reuseIdentifier, for: indexPath) as? ShowsFeaturedCollectionView else { return UITableViewCell() }
            
            if shows.count > indexPath.section, let data = shows[indexPath.section] {
                cell.delegate = self
                
                let section = indexPath.section
                cell.configure(shows: data, section: section)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowsCollectionView.reuseIdentifier, for: indexPath) as? ShowsCollectionView else { return UITableViewCell() }
            
            if shows.count > indexPath.section, let data = shows[indexPath.section] {
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
        guard let tbc = self.tabBarController as? TabBarController else { return }
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            tbc.hideTabBar(hide: true)
        } else {
            tbc.hideTabBar(hide: false)
        }
    }
}

