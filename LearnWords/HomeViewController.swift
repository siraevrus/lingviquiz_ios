//
//  HomeViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 16.02.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Выберите, какой язык хотите изучить"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCollectionView()
    }
    
    private func parseEnWords() -> QuestionsData? {
        guard let jsonFilePath = Bundle.main.path(forResource: "Words", ofType: "json") else {
            return nil
        }

        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonFilePath)) else {
            return nil
        }

        guard let myData = try? JSONDecoder().decode(QuestionsData.self, from: jsonData) else {
            return nil
        }

        return myData
    }
    
    private func parseRuWords() -> QuestionsData? {
        guard let jsonFilePath = Bundle.main.path(forResource: "ru_words", ofType: "json") else {
            return nil
        }

        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonFilePath)) else {
            return nil
        }

        guard let myData = try? JSONDecoder().decode(QuestionsData.self, from: jsonData) else {
            return nil
        }

        return myData
    }

    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.reuseIdentifier)
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        switch indexPath.item {
        case 0:
            cell.dictionaryType = .englishWords
        case 1:
            cell.dictionaryType = .russianWords
        default:
            break
        }
        
        // Устанавливаем дизайн ячейки
        cell.setupDesign(for: cell.dictionaryType!)
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Обработка нажатия на ячейку
        let cell = collectionView.cellForItem(at: indexPath) as! HomeCollectionViewCell
        guard let dictionaryType = cell.dictionaryType else { return }
        
        switch dictionaryType {
        case .englishWords:
            guard let questions = parseEnWords() else { return }
            let mapQuestions = questions.questions.map { question in
                var modifiedQuestion = question
                modifiedQuestion.choose = nil
                modifiedQuestion.know = nil
                return modifiedQuestion
            }
            let data = QuestionsData(questions: mapQuestions)
            if PlistManager.shared.loadDataFromPlist(plistName: PlistName.englishWords.rawValue) == nil {
                PlistManager.shared.saveDataToPlist(data: data, plistName: PlistName.englishWords.rawValue)
                let vc = LearningWordsViewController(questionsData: data, dictionaryType: .englishWords)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let dataFromPlist = PlistManager.shared.loadDataFromPlist(plistName: PlistName.englishWords.rawValue) else {return}
                let vc = LearningWordsViewController(questionsData: dataFromPlist, dictionaryType: .englishWords)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        case .russianWords:
            guard let questions = parseRuWords() else { return }
            let mapQuestions = questions.questions.map { question in
                var modifiedQuestion = question
                modifiedQuestion.choose = nil
                modifiedQuestion.know = nil
                return modifiedQuestion
            }
            let data = QuestionsData(questions: mapQuestions)
            if PlistManager.shared.loadDataFromPlist(plistName: PlistName.russianWords.rawValue) == nil {
                PlistManager.shared.saveDataToPlist(data: data, plistName: PlistName.russianWords.rawValue)
                let vc = LearningWordsViewController(questionsData: data, dictionaryType: .russianWords)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let dataFromPlist = PlistManager.shared.loadDataFromPlist(plistName: PlistName.russianWords.rawValue) else {return}
                let vc = LearningWordsViewController(questionsData: dataFromPlist, dictionaryType: .russianWords)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2 // 30 = 10 (minimumInteritemSpacing) * 2 + 10 (cell padding) * 2
        return CGSize(width: width, height: width - 30)
    }
}
