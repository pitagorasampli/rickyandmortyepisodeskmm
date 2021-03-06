//
//  EpisodesListViewModel.swift
//  iosApp
//
//  Created by Julio Ribeiro on 28/10/21.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

class EpisodesListViewModel: ObservableObject{
    
    //dependencies
    private let episodesUseCase : EpisodeListUseCase
    
    @Published var state: EpisodeListState = EpisodeListState()
    
    init(episodesUseCase: EpisodeListUseCase){
        self.episodesUseCase = episodesUseCase
        onTriggerEvent(stateEvent: EpisodeListEvent.LoadEpisodes())
    }
    
    
    func loadEpisodes(){
        let currentState = (self.state.copy() as! EpisodeListState)
            
         do{
            try episodesUseCase.fetchEpisodes(page: currentState.page).collectCommon(coroutineScope: nil, callBack: { dataState in
                if dataState != nil{
                    
                    //Getting data
                    let data = dataState?.data
                    
                    let loading =  dataState?.isLoading
                
                    self.updateState(isLoading: loading)
                    
                    if data != nil{
                        self.appendEpisodes(episodes: data as! [Episode])
                    }
               
                    //Handle error from CommonDataState
                    let errorState  = dataState?.error
                    let isDefaultException = errorState?.isDefaultApplicationException()
                    let errorCode = errorState?.code
                    let errorMessage = errorState?.message
                                        
                }
                
            })
        }catch{
            print("Error")
        }
        
    }
    
    
    
    func updateState(isLoading: Bool? = nil, page: Int? = nil){
        let currentState = (self.state.copy() as! EpisodeListState)
        self.state = self.state.doCopy(
            isIdle: currentState.isIdle,
            isLoading: isLoading ?? currentState.isLoading,
            error : currentState.error,
            page : Int32(page ?? Int(currentState.page)),
            episodeList : currentState.episodeList)
                
    }
    
    func onTriggerEvent(stateEvent: EpisodeListEvent){
        switch stateEvent {
        case is EpisodeListEvent.LoadEpisodes:
           loadEpisodes()
        case is EpisodeListEvent.NextPage:
            nextPage()
        default:
            doNothing()
        }
     }
    
    func doNothing(){
        
    }
    
    func nextPage(){
        let currentState = self.state.copy() as! EpisodeListState
        updateState(isLoading: nil, page: (Int(currentState.page) + 1))
        loadEpisodes()
    }
    
    
    
  
    
    
    func shouldLoadMoreItems(index: Int) -> Bool{
        let shouldLoad = episodesUseCase.indexGreaterThanPage(index: Int32(index) , page: state.page)
        return episodesUseCase.indexGreaterThanPage(index: Int32(index) , page: state.page)
    }
    
 
    
    func appendEpisodes(episodes: [Episode]){
        let currentState = self.state.copy() as! EpisodeListState
        var currentEpisodes = currentState.episodeList
        currentEpisodes.append(contentsOf: episodes)
        self.state = self.state.doCopy(
            isIdle : currentState.isIdle,
            isLoading : currentState.isLoading,
            error : currentState.error,
            page : currentState.page,
            episodeList : currentEpisodes
        )
        
    }
     
 
    
    
}
