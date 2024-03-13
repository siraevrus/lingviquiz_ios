//
//  LearningWordsViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 19.02.2024.
//

import UIKit

class LearningWordsViewController: UIViewController {
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "5000 популярных английских слов"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Приступить к обучению", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor(red: 26/255, green: 92/255, blue: 229/255, alpha: 1)
        return button
    }()
    
    var squareViews: [SquareView] = []
    
    var questionsData: QuestionsData
    var type: DictionaryType
    
    init(questionsData: QuestionsData, dictionaryType: DictionaryType) {
        self.questionsData = questionsData
        self.type = dictionaryType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        view.backgroundColor = .white
        button.addTarget(self, action: #selector(learButtonTapped), for: .touchUpInside)
        
        switch type {
        case .englishWords:
            label.text = "5000 популярных английских слов"
        case .russianWords:
            label.text = "5000 популярных русских слов"
        }
        title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch type {
        case .englishWords:
            guard let data = PlistManager.shared.loadDataFromPlist(plistName: PlistName.englishWords.rawValue) else {return}
            self.questionsData = data
            updateWordsCount()
            tableView.reloadData()
        case .russianWords:
            guard let data = PlistManager.shared.loadDataFromPlist(plistName: PlistName.russianWords.rawValue) else {return}
            self.questionsData = data
            updateWordsCount()
            tableView.reloadData()
        }
    }
    
    @objc private func squareViewTapped() {
        guard questionsData.questions.filter({ $0.know == false}).count != 0 else { return }
        let vc = DontKnowViewController(questionsData: questionsData, dictionaryType: type)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func learButtonTapped() {
        let vc = ProgressViewController(questionsData: questionsData, dictionaryType: type)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func updateWordsCount() {
        let allCount = questionsData.questions.count
        let learned = questionsData.questions.filter({ $0.choose == true }).count
        let dontKnow = questionsData.questions.filter({ $0.know == false}).count
        updateSquareViews(withData: [allCount, learned, dontKnow])
    }
    
    func updateSquareViews(withData data: [Int]) {
        for (index, squareView) in squareViews.enumerated() {
            squareView.updateLabel(withNumber: data[index])
        }
    }
}

extension LearningWordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsData.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.reuseIdentifier, for: indexPath) as! TextTableViewCell
        let question = questionsData.questions[indexPath.row]
        cell.configure(with: question)
        return cell
    }
}

extension LearningWordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension LearningWordsViewController {
    private func setupViews() {
        view.addSubview(label)
        view.addSubview(stackView)
        view.addSubview(tableView)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 92),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        // Setup stack view
        for _ in 0..<3 {
            let squareView = SquareView()
            stackView.addArrangedSubview(squareView)
            squareViews.append(squareView)
        }
        
        updateWordsCount()
        
        // Setup table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        // Set title for square views
        squareViews[0].titleLabel.text = "Всего"
        squareViews[1].titleLabel.text = "Выучил"
        squareViews[2].titleLabel.text = "Не знаю"
        squareViews[2].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(squareViewTapped)))
        squareViews[2].backgroundColor = UIColor(red: 194/255, green: 229/255, blue: 247/255, alpha: 1)
    }
}
