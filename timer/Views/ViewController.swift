//
//  ViewController.swift
//  timer
//
//  Created by Valerii Petrychenko on 08.02.2020.
//  Copyright © 2020 Valerii Petrychenko. All rights reserved.
//

import UIKit
import RealmSwift

enum State: Int {
    case off = 0
    case counting = 1
    case pause = 2
}

class ViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: TouchButton!
    @IBOutlet weak var pauseButton: TouchButton!
    @IBOutlet weak var cancelButton: TouchButton!
    @IBOutlet weak var timersTableView: UITableView!
    private let start = "Start"
    private let pause = "Pause"
    private let cancel = "Cancel"
    private let reusableCell = "timerTableViewCell"
    private let timerStoredStateValue = "TimerStateValue"
    private let timerStoredDateValue = "TimerDateValue"
    private let timerStoredTimeValue = "TimerTimeValue"
    private var storedInfoArray = [StoredInfo]()
    private var timer: Timer?
    private var timeCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateTable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func setupUI() {
        setupTableView()
        setupButton(button: startButton, color: .green, title: start)
        setupButton(button: pauseButton, color: .yellow, title: pause)
        setupButton(button: cancelButton, color: .gray, title: cancel)
    }
    
    private func setupTableView() {
        timersTableView.register(UINib(nibName: reusableCell, bundle: nil), forCellReuseIdentifier: reusableCell)
        timersTableView.delegate = self
        timersTableView.dataSource = self
        timersTableView.allowsSelection = false
        timersTableView.tableFooterView = UIView()
    }
    
    private func setupButton(button: UIButton, color: UIColor, title: String) {
        button.backgroundColor = color
        button.setTitle(title, for: .normal)
    }
    
    @objc func didBecomeActive() {
        let state = getState()
        if let stateItem = State(rawValue: state) {
            switch stateItem {
            case .off:
                setupOffState()
            case .counting:
                setupCountingState()
            case .pause:
                setupPauseState()
            }
        }
    }
    
    @objc func willResignActive() {
        pauseTimer()
    }
    
    private func setupTimerText() {
        timerLabel.text = timeString(timeCount: timeCount)
    }
    
    private func setUpTimer() {
        setupTimerText()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    @objc func onTimerFires() {
        timeCount += 1
        setupTimerText()
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupOffState() {
        timeCount = 0
        setupTimerText()
    }
    
    private func setupCountingState() {
        let storedDate = getDate()
        let currentDate = getTimeInterval(date: Date())
        timeCount = storedDate > 0 ? Int(currentDate - storedDate) : 0
        setUpTimer()
    }
    
    private func setupPauseState() {
        let storedTime = getTime()
        timeCount = storedTime
        setupTimerText()
    }
    
    @IBAction func startAction(_ sender: TouchButton) {
        let state = getState()
        if let stateItem = State(rawValue: state), (stateItem == .pause || stateItem == .off) {
            setUpTimer()
            saveDate(timeInterval: getTimeInterval(date: Date()) - Double(timeCount))
            saveTime(time: nil)
            saveState(state: State.counting.rawValue)
        }
    }
    
    @IBAction func pauseAction(_ sender: TouchButton) {
        let state = getState()
        if let stateItem = State(rawValue: state), stateItem == .counting {
            pauseTimer()
            saveDate(timeInterval: nil)
            saveTime(time: timeCount)
            saveState(state: State.pause.rawValue)
        }
    }
    
    @IBAction func cancelAction(_ sender: TouchButton) {
        let state = getState()
        if let stateItem = State(rawValue: state), (stateItem == .counting || stateItem == .pause) {
            pauseTimer()
            saveDate(timeInterval: nil)
            saveTime(time: nil)
            saveState(state: State.off.rawValue)
            
            askToSaveInfo(time: timeString(timeCount: timeCount))
            timeCount = 0
            setupTimerText()
        }
    }
}

extension ViewController {
    private func saveState(state: Int) {
        UserDefaults.standard.set(state, forKey: timerStoredStateValue)
    }
    
    private func getState() -> Int {
        return UserDefaults.standard.integer(forKey: timerStoredStateValue)
    }
    
    private func saveDate(timeInterval: TimeInterval?) {
        if let timeInterval = timeInterval {
            UserDefaults.standard.set(timeInterval, forKey: timerStoredDateValue)
        } else {
            UserDefaults.standard.set(nil, forKey: timerStoredDateValue)
        }
    }
    
    private func getDate() -> Double {
        return UserDefaults.standard.double(forKey: timerStoredDateValue)
    }
    
    private func getTimeInterval(date: Date) -> TimeInterval {
        return date.timeIntervalSince1970
    }
    
    private func saveTime(time: Int?) {
        if let time = time {
            UserDefaults.standard.set(time, forKey: timerStoredTimeValue)
        } else {
            UserDefaults.standard.set(nil, forKey: timerStoredTimeValue)
        }
    }
    
    private func getTime() -> Int {
        return UserDefaults.standard.integer(forKey: timerStoredTimeValue)
    }
    
    private func timeString(timeCount: Int) -> String {
        var timeString = ""
        let hours = timeCount / 3600
        let minutes = (timeCount % 3600) / 60
        let seconds = (timeCount % 3600) % 60
        if hours > 0 {
            timeString.append("\(hours) : ")
            minutes > 9 ? timeString.append("\(minutes) : ") : timeString.append("0\(minutes) : ")
            seconds > 9 ? timeString.append("\(seconds)") : timeString.append("0\(seconds)")
        } else if minutes > 0 {
            timeString.append("00 : ")
            minutes > 9 ? timeString.append("\(minutes) : ") : timeString.append("0\(minutes) : ")
            seconds > 9 ? timeString.append("\(seconds)") : timeString.append("0\(seconds)")
        } else {
            timeString.append("00 : 00 : ")
            seconds > 9 ? timeString.append("\(seconds)") : timeString.append("0\(seconds)")
        }
        return timeString
    }
    
    private func askToSaveInfo(time: String) {
        let alert = UIAlertController(title: "Nice time - \(time)", message: "Is there anything you want to save?", preferredStyle: .alert)
        alert.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
                let infoToSave = textField.text else { return }
            let storedInfo = StoredInfo(time: time, info: infoToSave)
            self.addInfoToRealm(storedInfo: storedInfo)
            self.updateTable()
        }
        
        let cancelAction = UIAlertAction(title: "Nope",style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func updateTable() {
        loadStoredInfoFromRealm()
        timersTableView.reloadData()
    }
    
    private func loadStoredInfoFromRealm() {
        do {
            let realm = try Realm()
            let objects = realm.objects(StoredInfo.self)
            storedInfoArray = Array(objects)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func addInfoToRealm(storedInfo: StoredInfo) {
        do {
            let realm = try Realm()
            do {
                try realm.write {
                    realm.add(storedInfo)
                }
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCell, for: indexPath) as! timerTableViewCell
        cell.configure(time: storedInfoArray[indexPath.row].time, info: storedInfoArray[indexPath.row].info)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
}
