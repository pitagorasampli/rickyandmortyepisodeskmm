# Ricky And Morty Episodes - Kotlin Multiplatform Mobile
Aplicação demonstrativa de uma estrutura mobile utilizando Kotlin Multiplatform Mobile (KMM) como um compartilhador de código comum

Tema: Busca de episódios de Ricky and Morty com informações sobre os episódios, como nome, data que foi exibido e sua temporada/número do episódio.

O aplicativo possui duas telas, uma inicial que traz a lista de episódios e uma segunda de detalhes que exibe os personagens contidos naquele episódio.

A busca é feita a partir da API pública de GraphQL do Ricky and Morty: [Ricky and Morty GraphQL public API](https://rickandmortyapi.com/graphql) 

### Demo:
<img src ="https://user-images.githubusercontent.com/13834922/143890491-506d8727-d502-49f5-8623-b053bed84f01.gif" width = "250" height = "450" />


### O que foi utilizado?

- Android Studio Arctic Fox 2020.3.1
- Xcode 12.5
- Gradle KTS - Dependency Management (Common & Android)
- [Apollo Graphql](https://www.apollographql.com/docs/android/essentials/get-started-multiplatform/)(Native) - Network Request 
- [Koin Multiplatform](https://insert-koin.io/docs/setup/v3) - Dependency Injection
- [Jetpack Compose](https://developer.android.com/jetpack/compose?gclid=Cj0KCQiAkZKNBhDiARIsAPsk0WjARhbbzTip1mMYvPk9-HNGOEMfw5hjjdtMHCg2SX78Y_A6-d1qVIMaAhqbEALw_wcB&gclsrc=aw.ds)(Android) - UI
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) (iOS) - UI
- [Swift Packages] - iOS Dependency Manager
- MVI - Arquitetura / Data Flow 


### Project Setup

Para reproduzir tanto o projeto iOS quanto o projeto Android, há a necessidade de ser rodado em um sistema MacOS, já que os simuladores da apple tem isso como exigência para que possam rodar.
Para rodar o projeto Android apenas, basta apenas fazer um clone do projeto e roda-lo no android studio após ter instalado o [Kotlin Multiplatform Plugin](https://kotlinlang.org/docs/kmm-plugin-releases.html)

Caso o package do SDWebImage não seja instalado, pode ser instalado via swift package com esse link : https://github.com/SDWebImage/SDWebImageSwiftUI e a branch `master`

### Arquitetura
![Screen Shot 2021-11-29 at 12 15 33](https://user-images.githubusercontent.com/13834922/143893688-ac64fa2c-dd7f-4be4-8c2f-21996ae68737.png)


### Fluxo de dados:

#### DataSource:
Camada responsavel pelo ponto de entrada dos dados na aplicação, é a camada que faz acesso ao serviço da API

```kotlin
class EpisodesApollo (private val apolloProvider: ApolloProvider) : EpisodesDataSource {

    @ApolloExperimental
    @ExperimentalCoroutinesApi
    override fun fetchEpisodesList(page: Int): Flow<Response<FetchEpisodesListQuery.Data>> {
        val query = FetchEpisodesListQuery(Input.fromNullable(page))
        return apolloProvider.createClient().query(query).execute()
    }
}
```

#### Repository:
Camada responsavel por receber os dados vindos do datasource, manipular esses dados, salvar localmente, etc:

```kotlin
class EpisodesRepositoryImpl(
    private val dataSource: EpisodesDataSource,
    private val dataMapper: EpisodeDataMapper
) : EpisodesRepository {

    override fun fetchEpisodes(page: Int): Flow<List<Episode>> {
        return flow {
            dataSource.fetchEpisodesList(page).catch {
                throw ApplicationException(Error_Fetching_Episodes_Code, it.message)
            }.collect { response ->
                if (response.hasErrors()) {
                    throw ApplicationException(
                        Error_Fetching_Episodes_Code,
                        response.errors?.firstOrNull()?.message
                    )
                } else {
                    val fields =
                        response.data?.episodes?.results?.mapNotNull { it?.fragments?.episodeResultFields }
                    fields?.let {
                        val mapped = dataMapper.toDomainList(it)
                        emit(mapped)
                    }
                }
            }

        }.flowOn(Dispatchers.Default)

    }

```

#### UseCase
Camada que irá aplicar qualquer regra de negócio necessária naqueles dados retornados e emiti-los para quem o chamou.

```kotlin

class EpisodeListUseCase(private val repository: EpisodesRepository) {

    fun fetchEpisodes(page: Int = 1): CommonFlow<CommonDataState<List<Episode>>> = flow {
        emit(CommonDataState.loading())
        repository.fetchEpisodes(page).catch {
            emit(
                CommonDataState.error<List<Episode>>(
                    ApplicationException(code = Error_Fetching_Episodes_Code, it.message)
                )
            )
        }.collect {
            emit(CommonDataState.data(it))
        }
    }.asCommonFlow()

```


#### ViewModel (Android)
Camada que irá requisitar os dados para o use case e controlar os objetos observaveis para a UI

```kotlin
class EpisodeListViewModel(private val useCase: EpisodeListUseCase) : ViewModel() {

    private val _episodesListState: MutableState<EpisodeListState> =
        mutableStateOf(EpisodeListState())
    val episodesState get() = _episodesListState

    private fun loadEpisodes() {
        useCase.fetchEpisodes(_episodesListState.value.page)
            .collectCommon(viewModelScope) { dataState ->
                val currentList = appendEpisodes(dataState.data ?: emptyList())
                _episodesListState.value =
                    _episodesListState.value.copy(
                        isIdle = false,
                        error = dataState.error,
                        episodeList = currentList.toList(),
                        isLoading = dataState.isLoading
                    )

            }
    }


```



#### ViewModel(iOS)

```swift
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


```
