//
//  ProgressViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 21.02.2024.
//

import UIKit
import Lottie
import OSSSpeechKit
import AVFoundation


class ProgressViewController: UIViewController {
    // Создаем коллекцию
    private var collectionView: UICollectionView!
    
    private let speechKit = OSSSpeech.shared
    
    private var audioPlayer: AVAudioPlayer?
    
    private let generator = UINotificationFeedbackGenerator()
    
    
    private var animationView: LottieAnimationView?
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Не знаю", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "closeButton"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let soundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "sound-play-button"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let wordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rue"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "5000/5"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = UIColor(red: 18/255, green: 18/255, blue: 23/255, alpha: 1)
        progressBar.trackTintColor = UIColor(red: 219/255, green: 222/255, blue: 229/255, alpha: 1)
        progressBar.progress = 0.5
        return progressBar
    }()
    
    private var questionsData: QuestionsData
    private var questionsDataToShow: QuestionsData?
    private var type: DictionaryType
    private var wordCounter = 0
    
    private var answerSet = Set<String>()
    private var answerArray = [String]()
    
    private var isSoundOn = false
    private var isVibrationOn = false
    
    init(questionsData: QuestionsData, dictionaryType: DictionaryType) {
        self.questionsData = questionsData
        self.type = dictionaryType
        let filtredData = questionsData.questions.filter({ $0.know == nil && $0.choose == nil })
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
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        setupCollection()
        setupConstraints()
        
        setupUi()
        loadSound()
        
        isSoundOn = UserDefaults.standard.bool(forKey: UserDefaultsKey.soundSwitchState.rawValue)
        isVibrationOn = UserDefaults.standard.bool(forKey: UserDefaultsKey.vibrationSwitchState.rawValue)
    }
    
    private func setupUi() {
        wordLabel.text = processLabelText(questionsDataToShow?.questions[wordCounter].word ?? "")
        answerSet = Set(questionsDataToShow?.questions[wordCounter].options ?? [])
        answerArray = Array(answerSet)
        let chosenOrDontknowWords = questionsData.questions.filter({ $0.know != nil || $0.choose != nil }).count
        progressLabel.text = "\(String(questionsData.questions.count))/\(String(chosenOrDontknowWords))"
        progressBar.progress = Float(chosenOrDontknowWords) / Float(questionsData.questions.count)
    }
    
    private func goTonextWord() {
        guard wordCounter < questionsData.questions.count - 1 else {
            print("Кончились слова")
            return
        }
        wordCounter += 1
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
    
    private func loadSound() {
        if let path = Bundle.main.path(forResource: "sound", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        }
    }
    
    private func speak(text: String) {
        switch type {
        case .englishWords:
            speechKit.voice = OSSVoice(quality: .enhanced, language: .English)
        case .russianWords:
            speechKit.voice = OSSVoice(quality: .enhanced, language: .Russian)
        }
        speechKit.speakText(text)
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
        print("Кнопка 'Не знаю' была нажата")
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

extension ProgressViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            switch type {
            case .englishWords:
                PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.englishWords.rawValue)
            case .russianWords:
                PlistManager.shared.saveDataToPlist(data: questionsData, plistName: PlistName.russianWords.rawValue)
            }
            cell.backgroundColor = .systemGreen
            self.animationView?.isHidden = false
            self.animationView!.play()
            if !isSoundOn {
                self.audioPlayer?.play()
            }
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
            if !isVibrationOn {
                generator.notificationOccurred(.error)
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

extension ProgressViewController {
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
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
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
        
        view.addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
}
