//
//  DontKnowViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 01.03.2024.
//

import UIKit
import AVFoundation
import Lottie

class DontKnowViewController: UIViewController {
    var collectionView: UICollectionView!
    
    let synthesizer = AVSpeechSynthesizer()
    
    private var animationView: LottieAnimationView?
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Не знаю", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    let soundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "sound-play-button"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let wordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rue"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    var questionsData: QuestionsData
    var questionsDataToShow: QuestionsData?
    var type: DictionaryType
    var wordCounter = 0
    
    var answerSet = Set<String>()
    var answerArray = [String]()
    
    init(questionsData: QuestionsData, dictionaryType: DictionaryType) {
        self.questionsData = questionsData
        self.type = dictionaryType
        let filtredData = questionsData.questions.filter({ $0.know == false })
        let questionData = QuestionsData(questions: filtredData)
        self.questionsDataToShow = questionData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        setupCollection()
        setupConstraints()
        
        setupUi()
        
        synthesizer.delegate = self
    }
    
    private func setupUi() {
        wordLabel.text = processLabelText(questionsDataToShow?.questions[wordCounter].word ?? "")
        answerSet = Set(questionsDataToShow?.questions[wordCounter].options ?? [])
        answerArray = Array(answerSet)
    }
    
    private func goTonextWord() {
        wordCounter += 1
        guard let data = questionsDataToShow?.questions, wordCounter < data.count - 1 else {
            navigationController?.popViewController(animated: true)
            return
        }
        setupUi()
        collectionView.reloadData()
        animationView?.isHidden = true
    }
    
    private func addAnimation() {
        animationView = .init(name: "animation")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFill
        animationView!.alpha = 0.7
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 0.5
        
        view.addSubview(animationView!)
        animationView?.isHidden = true
    }
    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        switch type {
        case .englishWords:
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        case .russianWords:
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        }
        synthesizer.speak(utterance)
    }
    
    private func processLabelText(_ text: String) -> String {
        // Проверяем, есть ли в тексте запятая
        guard let commaRange = text.range(of: ",") else {
            // Если запятой нет, возвращаем исходный текст
            return text
        }
        
        // Получаем текст до и после запятой
        let beforeComma = text[text.startIndex..<commaRange.lowerBound]
        let afterComma = text[commaRange.upperBound..<text.endIndex]
        
        // Склеиваем текст до и после запятой с переносом строки между ними
        return "\(beforeComma),\n\(afterComma)"
    }
    
    @objc func buttonTapped() {
        let answer = questionsDataToShow?.questions[wordCounter].answer
        let index = questionsData.questions.firstIndex(where: { word in
            word.answer == answer
        })
        questionsData.questions[index ?? wordCounter].know = false
        switch type {
        case .englishWords:
            PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.englishWords.rawValue)
        case .russianWords:
            PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.russianWords.rawValue)
        }
        self.goTonextWord()
        collectionView.reloadData()
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func soundButtonTapped() {
        let word = questionsDataToShow?.questions[wordCounter].word ?? ""
        speak(text: word)
    }
}

extension DontKnowViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questionsDataToShow?.questions[wordCounter].options.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
        cell.label.text = answerArray[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ButtonCell
        if cell.label.text == questionsDataToShow?.questions[wordCounter].answer {
            let answer = questionsDataToShow?.questions[wordCounter].answer
            let index = questionsData.questions.firstIndex(where: { word in
                word.answer == answer
            })
            questionsData.questions[index ?? wordCounter].choose = true
            questionsData.questions[index ?? wordCounter].know = nil
            switch type {
            case .englishWords:
                PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.englishWords.rawValue)
            case .russianWords:
                PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.russianWords.rawValue)
            }
            cell.backgroundColor = .systemGreen
            self.animationView?.isHidden = false
            self.animationView!.play()
            self.collectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.goTonextWord()
                cell.backgroundColor = .white
                self.collectionView.isUserInteractionEnabled = true
            }
        } else {
            let answer = questionsDataToShow?.questions[wordCounter].answer
            let index = questionsData.questions.firstIndex(where: { word in
                word.answer == answer
            })
            cell.backgroundColor = .systemRed
            questionsData.questions[index ?? wordCounter].know = false
            switch type {
            case .englishWords:
                PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.englishWords.rawValue)
            case .russianWords:
                PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.russianWords.rawValue)
            }
            self.collectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.goTonextWord()
                cell.backgroundColor = .white
                self.collectionView.isUserInteractionEnabled = true
            }
        }
    }
}

extension DontKnowViewController {
    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        // Вычисляем размер ячейки
        let cellWidth = (view.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / 2
        let cellHeight = (view.frame.height * 0.20 - layout.sectionInset.top - layout.sectionInset.bottom - layout.minimumLineSpacing) / 2
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        // Создаем коллекцию с указанным макетом
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: "ButtonCell")
    }
    
    private func setupConstraints() {
        addAnimation()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -15),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.20)
        ])
        
        view.addSubview(soundButton)
        NSLayoutConstraint.activate([
            soundButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            soundButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(wordLabel)
        NSLayoutConstraint.activate([
            wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordLabel.bottomAnchor.constraint(equalTo: soundButton.topAnchor, constant: -60)
        ])
    }
}

extension DontKnowViewController: AVSpeechSynthesizerDelegate {
    
}
