//
//  EpisodeList.swift
//  iosApp
//
//  Created by Julio Ribeiro on 01/11/21.
//  Copyright © 2021 orgName. All rights reserved.
//

import Foundation
import shared
import SwiftUI


struct EpisodeList :  View{
    
    private let episodeList: [Episode]
    
    private let onNextPage:  () -> Void
    
    init(episodeList: [Episode], onNextPage: @escaping () -> Void) {
        self.episodeList = episodeList
        self.onNextPage = onNextPage
    }
    
    var body: some View {
        
        List{
            ForEach(episodeList, id: \.self.id){episode in
                
                ZStack{
                    EpisodeCard(episode: episode).onAppear(perform: {
                        
                        if(episodeList.last?.id == episode.id){
                            onNextPage()
                        }
                    })
                    
                    
                    NavigationLink(destination: EpisodeDetailScreen(episodeId: episode.id)){
                        EmptyView()
                    }.navigationBarTitle(Text(""),displayMode: .inline)
                    .navigationBarHidden(true)
                     
                    
                }
                
                
                
            }.listRowBackground(Color.black)
            
        }.listStyle(PlainListStyle())
        
    }
    
}
