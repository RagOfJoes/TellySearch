//
//  SeasonsView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/25/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class SeasonsView: UIViewController {
    // MARK: - Internal Properties
    let tvId: Int
    let season: Season
    let colors: UIImageColors
    var detail: SeasonDetail? = nil
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        tableView.delaysContentTouches = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SeasonsViewCell.self, forCellReuseIdentifier: SeasonsViewCell.reuseIdentifier)
        
        tableView.isSkeletonable = true
        return tableView
    }()
    
    // MARK: - Life Cycle
    init(tvId: Int, season: Season, colors: UIImageColors) {
        self.tvId = tvId
        self.season = season
        self.colors = colors
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        view.backgroundColor = self.colors.background
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        fetchDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.showAnimatedGradientSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup
extension SeasonsView {
    @objc func onBackButton() {
        self.dismiss(animated: true)
    }
    
    private func setupNav() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: self.colors.background), for: .default)
        
        self.navigationController?.navigationBar.tintColor = colors.primary
        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        self.navigationItem.title = season.name
        self.navigationItem.rightBarButtonItem = backBarButton
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colors.primary!]
    }
}

// MARK: - Data Fetches
extension SeasonsView {
    private func fetchDetails() {
        self.season.fetchDetail(tvId: self.tvId).then { (data) in
            return SeasonDetail.decodeSeasonData(data: data)
        }.then { [weak self] (detail) in
            self?.detail = detail
            
            DispatchQueue.main.async {
                self?.tableView.hideSkeleton()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension SeasonsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SeasonsViewCell.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
    }
}

// MARK: - UITableViewDataSource
extension SeasonsView: SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let episodes = self.detail?.episodes {
            return episodes.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SeasonsViewCell.reuseIdentifier) as? SeasonsViewCell else {
            return UITableViewCell()
        }
        
        if let episodes = self.detail?.episodes {
            let episode = episodes[indexPath.section]
            let name = "\(indexPath.section + 1). \(episode.name)"
            let url = episode.backdrop != nil ? K.Backdrop.URL + episode.backdrop! : nil
            
            cell.configure(url: url, name: name, colors: self.colors)
        }
        
        return cell
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SeasonsViewCell.reuseIdentifier
    }
}
