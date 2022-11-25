//
//  Views.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//

import Foundation
import SwiftUI

struct editSoldierSheet : View{
    @Binding var editSheetSoldierName : String
    
    var body: some View{
        Text("עריכת לוחם \(editSheetSoldierName)")
    }
}

struct buttomBar : View{
    @Binding var pageNum : Int
    
    @Binding var imgNames : [String]
    var body: some View{
        HStack{
            ForEach(0..<imgNames.count, id:\.self){ index in
                Spacer()
                Button(action: {
                    if(!imgNames[index].hasSuffix(".fill")){
                        for i in 0..<imgNames.count{
                            if(imgNames[i].hasSuffix(".fill")){
                                imgNames[i].removeLast(5)
                            }
                        }
                        imgNames[index] += ".fill"
                    }//.fill check
                    pageNum = index
                },//button action
                       label: {
                    Image(systemName: imgNames[index])
                        .resizable()
                        .aspectRatio( contentMode: .fit)
                        .frame(width: 30)
                        .padding(.horizontal, 5)
                })//button image
                Spacer()
            }//foreach image
        }//buttom bar
    }
}
