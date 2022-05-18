//
//  StartView.swift
//  cookies
//
//  Created by User12 on 2022/5/17.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var game: Game
    @Binding var showStartView: Bool
    @Binding var stateStr: String // start: welcome, pause: Pause
    
    var body: some View {
        ZStack{
            
            Color("Custom Color")
                .ignoresSafeArea()
            
            VStack{
                
                HStack{
                    Image("cookies")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 389, height: 40)
                    
                }
                
                HStack (spacing: 10){
                    Text(" C")
                        .foregroundColor(deer_color)
                    Text("r")
                        .foregroundColor(brown_bg)
                    Text("u")
                        .foregroundColor(rootBear_color)
                    Text("s")
                        .foregroundColor(cream_color)
                    Text("h")
                        .foregroundColor(caputMortuum_color)
                }
                .font((.custom("PWYummyDonuts", size: 70)))
                
                VStack( spacing: 0){
                    HStack{
                        Text("\n\(stateStr)")
                            .font((.custom("MAGICWORLD", size: 45)))
                            .foregroundColor(.red)
                            .padding()
                    }.padding(.leading, 100)
                    .padding(.trailing, 100)
                    
                    HStack {
                        Button(action: {
                            showStartView = false
                            game.startTimer()
                           
                            if stateStr == "PLAY NOW ! "{
                                game.initialGame()
                            }
                            
                        }, label: {
                            Rectangle()
                                .fill(caputMortuum_color)
                                .frame(width: 250, height: 50)
                                .cornerRadius(30)
                                .overlay(
                                    VStack(spacing: 10){
                                        
                                        Text("PLAY")
                                            .font(.largeTitle)
                                    }
                                    .foregroundColor(cream_color)
                                )
                        })
                        
                        Button(action: {
                            game.initialGame()
                            showStartView = false
                            game.startTimer()
                        }, label: {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.largeTitle)
                                .frame(width: 150, height: 100)
                                .foregroundColor(caputMortuum_color)
                           
                        })
                        
                    }.padding(.leading, 200)
                    .padding(.trailing, 250)
                    
                }
            }
            
            Image("donut6")
                .scaleEffect(0.4)
                .offset(x: -130, y: 250)
            
            Image("donut1")
                .scaleEffect(0.25)
                .offset(x: -65, y: 250)
            Image("donut9")
                .scaleEffect(0.4)
                .offset(x: 0, y: 250)
            Image("donut8")
                .scaleEffect(0.4)
                .offset(x: 65, y: 250)
            
            
            Image("donut7")
                .rotationEffect(.degrees(-70))
                .scaleEffect(0.4)
                .offset(x: 130, y: 250)
            
        } // ZStack END
    }
}

struct start_background: View {
    var body: some View{
        ZStack{
            yellow_bg
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(brown_bg)
                .frame(width: 300, height: 1000)
                .rotationEffect(.degrees(10))
                .offset(x: 180)
            
        }
    }
}
