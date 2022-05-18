//
//  level 1.swift
//  cookies
//
//  Created by User12 on 2022/5/18.
//

import Foundation

import SwiftUI

let yellow_bg = Color(red: 238/255, green: 225/255, blue: 186/255)
let brown_bg = Color(red: 156/255, green: 99/255, blue: 79/255)
let orange_font = Color(red: 195/255, green: 121/255, blue: 96/255)
let milkChocolate_color = Color(red: 132/255, green: 86/255, blue: 60/255)
let deer_color = Color(red: 189/255, green: 140/255, blue: 97/255)
let cream_color = Color(red: 239/255, green: 226/255, blue: 178/255)
let caputMortuum_color = Color(red: 90/255, green: 44/255, blue: 34/255)
let rootBear_color = Color(red: 39/255, green: 13/255, blue: 11/255)


struct Donut{
    var value: Int = 0
//    var isAppear: Bool = false
    var offset: CGSize = CGSize.zero
    var direction: Direction = Direction.none
    var isHint: Bool = false
}
enum Direction {
    case right, left, up, down, none
}

struct Grid {
    var row: Int
    var col: Int
    
    init(r: Int, c: Int){
        self.row = r
        self.col = c
    }
}

class Game: ObservableObject{
    @Published var donuts: [[Donut]] = Array(repeating: Array(repeating: Donut(),count: 8),count: 10)
    // 遊戲行列數
    let boardRow: Int = 10
    let boardCol: Int = 8
    
    @Published var score: Int = 0
    private var combo: Int = 0
    // 最高分
    @Published var highestScore: Int = 0
    // 計時
    private var timer: Timer?
    private var startDate: Date?
    @Published var elapsedTime: Int = 0 // 遊戲開始 總共過了幾秒
    @Published var secondElapse: Int = 0 // 計時器跑了幾秒
    @Published var timeUp: Bool = false // 時間到
    let timeUpSecond: Int = 90 // 時間到的秒數
    
    private var disappearGrids: [Grid] = [] // 可連線的格子
    
    private var noActTime: Int = 0
    private var hintGrids: [Grid] = [] // 可交換的所有格子２個格子
    private var chooseHint: Int = 0
    var haveHint: Bool = false
    
    func initialGame(){
        donuts = Array(repeating: Array(repeating: Donut(),
                                        count: boardCol),
                       count: boardRow)
        
        getHighestScore() // set highest score
        timeUp = false
        score = 0
        combo = 0
        elapsedTime = 0
        secondElapse = 0
        noActTime = 0
        
        randomBoard()
    }
    
    func randomBoard(){
        for re_col in 0..<boardCol{
            let col = boardCol - re_col - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(re_col)){
                for row in 0..<self.boardRow{
                    self.donuts[row][col].value = Int.random(in: 1...9)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.combo = 0
            self.disappearGrid() // 消除連線的格子
        }
        
    }
    
    func startTimer(){
        elapsedTime += secondElapse
        secondElapse = 0
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ [weak self] timer in
            if let self = self,
               let startDate = self.startDate{
                self.secondElapse = Int(round(timer.fireDate.timeIntervalSince1970 - startDate.timeIntervalSince1970))
                
                self.noActTime += 1
                if self.noActTime == 5{
                    self.haveHint = self.getHint()
                }
                
                if self.elapsedTime + self.secondElapse == self.timeUpSecond{ // 時間到
                    self.stopTimer()
                    self.endGame()
                }
            }
        }
    }
    
    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func saveHighestScore(){ // 將最高分存入UserDefaults
        let encoder = JSONEncoder()
        if let encodeData = try? encoder.encode(highestScore){
            UserDefaults.standard.set(encodeData, forKey: "highestScore")
        }
    }
    
    func getHighestScore(){
        // 從UserDefaults存取最高分
        if let data = UserDefaults.standard.data(forKey: "highestScore"){
            let decoder = JSONDecoder()
            if let decodeData = try? decoder.decode(Int.self, from: data){
                highestScore = decodeData
            }
        }
    }
    
    func endGame(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            if self.score > self.highestScore{
                self.highestScore = self.score
                self.saveHighestScore()
            }
            self.timeUp = true
        }
    }
    
    func haveThreeSame(row: Int, col: Int, value: Int, direction: Direction) -> Bool{
        // value 放在(row, col)這格 (格子, 向哪個方向交換) 會不會連線
        if value == 0{return false}
        
        var starttt = col
        var enddd = col
        // 橫(左->右)
        while enddd < boardCol-1 && donuts[row][enddd+1].value == value && direction != .left{ // 向右檢查
            enddd += 1
        }
        while starttt > 0 && donuts[row][starttt-1].value == value && direction != .right{ // 向左檢查
            starttt -= 1
        }
        if enddd-starttt >= 2{
            return true
        }
        
        starttt = row
        enddd = row
        // 直 (上->下)
        while starttt > 0 && donuts[starttt-1][col].value == value && direction != .down{ // 向上檢查
            starttt -= 1
        }
        while enddd < boardRow-1 && donuts[enddd+1][col].value == value && direction != .up{ // 向下檢查
            enddd += 1
        }
        if enddd-starttt >= 2{
            return true
        }
        return false
    }
    
    func canSwipe(row: Int, col: Int) -> Bool{
        switch donuts[row][col].direction{
        case .right:
            if haveThreeSame(row: row, col: col, value: donuts[row][col+1].value, direction: .left) || haveThreeSame(row: row, col: col+1, value: donuts[row][col].value, direction: .right){
                return true
            }
        case .left:
            if haveThreeSame(row: row, col: col, value: donuts[row][col-1].value, direction: .right) || haveThreeSame(row: row, col: col-1, value: donuts[row][col].value, direction: .left){
                return true
            }
        case .up:
            if haveThreeSame(row: row, col: col, value: donuts[row-1][col].value, direction: .down) || haveThreeSame(row: row-1, col: col, value: donuts[row][col].value, direction: .up){
                return true
            }
        case .down:
            if haveThreeSame(row: row, col: col, value: donuts[row+1][col].value, direction: .up) || haveThreeSame(row: row+1, col: col, value: donuts[row][col].value, direction: .down){
                return true
            }
        default:
            return false
        }
        return false
    }
    
    func doSwipe(row: Int, col: Int){ // 格子交換
        let donutValue = donuts[row][col].value
        
        switch donuts[row][col].direction{
        case .right:
            donuts[row][col].value = donuts[row][col+1].value
            donuts[row][col+1].value = donutValue
            donuts[row][col+1].offset = .zero
        case .left:
            donuts[row][col].value = donuts[row][col-1].value
            donuts[row][col-1].value = donutValue
            donuts[row][col-1].offset = .zero
        case .up:
            donuts[row][col].value = donuts[row-1][col].value
            donuts[row-1][col].value = donutValue
            donuts[row-1][col].offset = .zero
        case .down:
            donuts[row][col].value = donuts[row+1][col].value
            donuts[row+1][col].value = donutValue
            donuts[row+1][col].offset = .zero
        default: break
        }
        donuts[row][col].direction = .none
        donuts[row][col].offset = .zero
        
        combo = 1
        if haveDisappear(){
            disappearGrid() // 消除連線的格子
        }
    }
    
    func haveDisappear() -> Bool{ // 是否有可連線
        disappearGrids = [] // 可連線的格子
        for re_row in 0..<boardRow{
            let row = boardRow - re_row - 1
            for col in 0..<boardCol{
                if haveThreeSame(row: row, col: col, value: donuts[row][col].value, direction: donuts[row][col].direction){
                    disappearGrids.append(Grid(r: row, c: col))
                }
            }
        }
        if disappearGrids.count > 0{return true}
        else {return false}
    }
    
    func disappearGrid(){ // 消除連線的格子
        var addScore = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            for grid in self.disappearGrids{
                self.donuts[grid.row][grid.col].value = 0
            }
        }
        
        // 加分
        addScore = (disappearGrids.count) * combo
        for i in 0..<addScore{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(i)){
                self.score += 1
            }
        }
        
        if haveHint{
            disappearHint()
        }
        noActTime = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.dropDown()
        }
    }
    
    func dropDown(){
        for col in 0..<boardCol{
            var dropCount = 0
            
            for re_row in 0..<boardRow{
                let row = boardRow - re_row - 1 // 由下往上檢查空格個數
                
                if dropCount != 0 && donuts[row][col].value != 0 {
                    // 下方空格子 由上方的物品代替，靠offset暫時留在原格
                    donuts[row+dropCount][col].value = donuts[row][col].value
                    donuts[row+dropCount][col].offset.height = CGFloat(-dropCount * 40)
                    
                    if row-dropCount >= 0{ // 被代替的格子再往上代替別格
                        donuts[row][col].value = donuts[row-dropCount][col].value
                    }
                    else { // 上方沒格子 產生一個新物品
                        donuts[row][col].value = Int.random(in: 1...9)
                    }
                    donuts[row][col].offset.height = CGFloat(-dropCount * 40)
                }
                
                if donuts[row][col].value == 0{
                    dropCount += 1
                }
            } // for row end
            
            for row in 0..<boardRow{
                if donuts[row][col].value == 0{ // 針對最上方未填滿的格子
                    donuts[row][col].value = Int.random(in: 1...9)
                    donuts[row][col].offset.height = CGFloat(-dropCount * 40)
                }
                // 掉落到新位置
                withAnimation(.linear){
                    donuts[row][col].offset.height = 0
                }
            }
        } // for col end
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            if self.haveDisappear(){ // 有多次消除
                self.combo += 1
                self.disappearGrid()
            }
        }
    } // func dropDown end
    
    func getHint() -> Bool{
        hintGrids = []
        for r in 0..<boardRow{
            for c in 0..<boardCol{
                if (r+c)%2 == 0{
                    // 朝四個方向檢查
                    if c < boardCol-1{ // ->
                        donuts[r][c].direction = Direction.right
                        if canSwipe(row: r, col: c){
                            hintGrids.append(Grid(r: r, c: c))
                            hintGrids.append(Grid(r: r, c: c+1))
                        }
                    }
                    
                    if c > 0{ // <-
                        donuts[r][c].direction = Direction.left
                        if canSwipe(row: r, col: c){
                            hintGrids.append(Grid(r: r, c: c))
                            hintGrids.append(Grid(r: r, c: c-1))
                        }
                    }
                    if r > 0{ // 上
                        donuts[r][c].direction = Direction.up
                        if canSwipe(row: r, col: c){
                            hintGrids.append(Grid(r: r, c: c))
                            hintGrids.append(Grid(r: r-1, c: c))
                        }
                    }
                    if r < boardRow-1{ // 下
                        donuts[r][c].direction = Direction.down
                        if canSwipe(row: r, col: c){
                            hintGrids.append(Grid(r: r, c: c))
                            hintGrids.append(Grid(r: r+1, c: c))
                        }
                    }
                    donuts[r][c].direction = Direction.none
                }
            } // for col end
        } // for row end
        
        let hintCount = hintGrids.count / 2
        if hintCount == 0{
            randomBoard()
            return false // 沒有可交換的
        }else{
            chooseHint = Int.random(in: 0..<hintCount)
            let grid1 = hintGrids[chooseHint*2]
            let grid2 = hintGrids[chooseHint*2+1]
            
            donuts[grid1.row][grid1.col].isHint = true
            donuts[grid2.row][grid2.col].isHint = true
            
            return true
        }
    }
    
    func disappearHint(){
        let grid1 = hintGrids[chooseHint*2]
        let grid2 = hintGrids[chooseHint*2+1]
        
        donuts[grid1.row][grid1.col].isHint = false
        donuts[grid2.row][grid2.col].isHint = false
        
    }
}
