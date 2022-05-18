//
//  ContentView.swift
//  cookies
//
//  Created by User12 on 2022/5/17.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game: Game = Game()
   @State private var showStartView: Bool = true
    @State private var next: Bool = false
        @State private var stateStr: String = "PLAY NOW ! "
        @State private var showResultView: Bool = false
    func dragGesture(r: Int, c: Int) -> some Gesture{
            DragGesture(minimumDistance: 10)
                .onChanged { (value) in
                    if abs(value.translation.width) > abs(value.translation.height){ // 水平
                        // 限制移動的距離
                        if value.translation.width > 40{
                            game.donuts[r][c].offset.width = 40
                        }
                        else if value.translation.width < -40{
                            game.donuts[r][c].offset.width = -40
                        }
                        else{
                            game.donuts[r][c].offset.width = value.translation.width
                        }
                        
                        if value.translation.width > 0 && c < game.boardCol-1{ // ->
                            game.donuts[r][c].direction = Direction.right
                            game.donuts[r][c+1].offset.width = -game.donuts[r][c].offset.width
                        }
                        else if value.translation.width < 0 && c > 0{ // <-
                            game.donuts[r][c].direction = Direction.left
                            game.donuts[r][c-1].offset.width = -game.donuts[r][c].offset.width
                        }
                    }
                    else{ // 垂直
                        
                        if value.translation.height > 40{
                            game.donuts[r][c].offset.height = 40
                        }
                        else if value.translation.height < -40{
                            game.donuts[r][c].offset.height = -40
                        }
                        else{
                            game.donuts[r][c].offset.height = value.translation.height
                        }
                        
                        if value.translation.height < 0 && r > 0{ // 上
                            game.donuts[r][c].direction = Direction.up
                            game.donuts[r-1][c].offset.height = -game.donuts[r][c].offset.height
                        }
                        else if value.translation.height > 0 && r < game.boardRow-1{ // 下
                            game.donuts[r][c].direction = Direction.down
                            game.donuts[r+1][c].offset.height = -game.donuts[r][c].offset.height
                        }
                    }
                }
                .onEnded { (value) in
                    if game.canSwipe(row: r, col: c){ // 可以交換
                        game.doSwipe(row: r, col: c)
                    }
                    else{ // 不能交換
                        withAnimation(.easeInOut(duration: 0.3)){
                            // 將四周格子offset調回原本位置
                            game.donuts[r][c].offset = .zero
                            if c < game.boardCol-1 {game.donuts[r][c+1].offset = .zero}
                            if c > 0 {game.donuts[r][c-1].offset = .zero}
                            if r > 0 {game.donuts[r-1][c].offset = .zero}
                            if r < game.boardRow-1 {game.donuts[r+1][c].offset = .zero}
                        }
                    }
                }
        }
    var body: some View {
        ZStack{
            Color("Custom Color")
                .ignoresSafeArea()
           
                    
                    VStack(spacing:30){ // content
                        VStack{
                            ZStack{ // 分數
                                Image("score")
                                    //.frame(width: 20, height: 40)
                                    .scaleEffect(1.0)
                                  
                                Text("\(game.score)") // 分數
                                    .font((.custom("PWYummyDonuts", size: 40)))
                                    .foregroundColor(rootBear_color)
                                    .offset(x: 5, y: 5)
                                
                               
                                //.offset(x: 130, y: -20)
                            }
                            
                        }
                        VStack{
                            HStack{
                                Spacer()
                                Button(action: { // 暫停
                                    game.stopTimer()
                                    stateStr = "pause"
                                    showStartView = true
                                }, label: {
                                    Image(systemName: "pause.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(brown_bg)
                                })
                            }.padding(.leading, 40)
                            .padding(.trailing, 30)
                                 
                        }
                        
                        VStack(spacing: 0){ // 遊戲介面(格子)
                            
                            ForEach(0..<game.boardRow){ row in
                                HStack(spacing: 0){
                                    
                                    ForEach(0..<game.boardCol){col in
                                        ZStack{
                                            deer_color // 格子
                                                .frame(width: 50, height: 50)
                                                .border(cream_color)
                                                .opacity(0.6)
                                            
                                            if game.donuts[row][col].isHint{
                                                Rectangle()
                                                    .fill(Color.white)
                                                    .blur(radius: 10)
                                                    .frame(width: 50, height: 50)
                                                    .scaleEffect(1.2)
                                            }

                                            if game.donuts[row][col].value > 0{ // 甜甜圈
                                                Image("donut\(game.donuts[row][col].value)")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .offset(game.donuts[row][col].offset)
                                                    .gesture(dragGesture(r: row, c: col))
                                            }
                                        }
                                    } // ForEach_col End
                                }
                            } // ForEach_row End
                        }
                        
                        // 時間
                        timeBarView(secondElapse: $game.secondElapse, elapsedTime: $game.elapsedTime , timeUpSecond: game.timeUpSecond)
                        
        //                Spacer()
                    } // content VStack END
                    
                    if game.timeUp{ // 結算畫面
                        ResultView(game: game, showStartView: $showStartView, stateStr: $stateStr)
                    }
                } // ZStack END
               .fullScreenCover(isPresented: $showStartView, content: {
                   StartView(game: game, showStartView: $showStartView, stateStr: $stateStr)
                })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct ResultView: View{
    @ObservedObject var game: Game
    @Binding var showStartView: Bool
    @Binding var stateStr: String
    
    var body: some View{
        ZStack{
          
            
            VStack{
                ZStack{
                    Rectangle()
                        .frame(width: 200, height: 180)
                        .foregroundColor(cream_color)
                        .cornerRadius(50)
                    
                    VStack{
                        Text("Your Score")
                            .font((.custom("MAGICWORLD", size: 30)))
                            .foregroundColor(milkChocolate_color)
                            .offset(y: 15)
                        
                        Text("\(game.score)") // 這輪分數
                            .font((.custom("PWYummyDonuts", size: 50)))
                            .foregroundColor(orange_font)
                        Text("\nBest Score:\t") // 最高分
                            .font((.custom("", size: 20)))
                            .foregroundColor(milkChocolate_color)
                            + Text("\(game.highestScore)")
                            .italic()
                            .font((.custom("", size: 20)))
                            .foregroundColor(milkChocolate_color)
                    }
                }
                
                Button(action: {
                    game.initialGame()
                    stateStr = "PLAY NOW ! "
                    showStartView = false
                    game.startTimer()
                    
                    
                }, label: {
                    ZStack{
                        Rectangle()
                            .frame(width: 200, height: 50)
                            .foregroundColor(caputMortuum_color)
                            .cornerRadius(25)
                            .shadow(radius: 20)
                        
                        Text("New Games") // 返回按鈕
                            .font((.custom("MAGICWORLD", size: 30)))
                            .foregroundColor(cream_color)
                            .offset(y: 5)
                    }
                    .offset(y: 10)
                })
              
            } // VStack END
            .offset(y: 60)
        }
    }
}

struct timeBarView: View{
    @Binding var secondElapse: Int
    @Binding var elapsedTime: Int
    var timeUpSecond: Int
    
    var body: some View{
        let light_green = Color(red: 200/255, green: 240/255, blue: 220/255, opacity: 0.8)
        
        VStack{
            
            
            ZStack{
                Rectangle()
                    .fill(light_green)
                    .frame(width: 220, height: 30)
                    .cornerRadius(30)
                    .padding()
                    .offset(x: 20)
                
               
                ZStack{
                    Image(systemName: "flame.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text("\(timeUpSecond - secondElapse - elapsedTime)")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                .offset(x: (-180 + 440 * CGFloat(timeUpSecond - secondElapse - elapsedTime)/CGFloat(timeUpSecond)) / 2)
                Image("oven")
                    .resizable()
                    .frame(width:65, height: 30)
                    .offset(x: -140)
            }
        }
    }
}
