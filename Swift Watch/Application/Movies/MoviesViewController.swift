//
//  MoviesViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController  {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return collectionView
    }()
    
    var movies = Movies(page: 1, totalPages: 1, results: [
        Movie(id: 1, runtime: nil, title: "Avengers: Age Of Ultron", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        Movie(id: 2, runtime: nil, title: "Avengers: Age Of Ultron", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        Movie(id: 3, runtime: nil, title: "Eternal Sunshine of the Spotless Mind", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        Movie(id: 4, runtime: nil, title: "Scoob", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        Movie(id: 5, runtime: nil, title: "Scoob", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        Movie(id: 6, runtime: nil, title: "Scoob", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        Movie(id: 7, runtime: nil, title: "Scoob", genres: [Genre(id: 1, name: "Comedy")], rateAvg: 6.8, tagline: nil, overview: nil, releaseDate: Date("2020-07-21", with: "YYYY-MM-DD"), posterPath: "testPoster", backdropPath: nil),
        
    ], totalResults: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
//        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.5).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //        collectionView.reloadData()
    }
}

extension MoviesViewController: UICollectionViewDelegate {
}

extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        cell.configure(with: movies.results[indexPath.item])
        return cell
    }
}

extension MoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 90, height: collectionView.frame.width / 2)
    }
}
