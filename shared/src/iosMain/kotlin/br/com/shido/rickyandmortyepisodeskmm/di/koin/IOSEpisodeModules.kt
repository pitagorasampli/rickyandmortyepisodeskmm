package br.com.shido.rickyandmortyepisodeskmm.di.koin

import br.com.shido.rickyandmortyepisodeskmm.episodes.episodes_list.di.episodesCommonModule
import br.com.shido.rickyandmortyepisodeskmm.episodes.episodes_detail.di.episodesDetailCommonModule
import br.com.shido.rickyandmortyepisodeskmm.episodes.common.usecase.EpisodeDetailUseCase
import br.com.shido.rickyandmortyepisodeskmm.episodes.episodes_list.usecase.EpisodeListUseCase
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import org.koin.core.context.startKoin
import org.koin.dsl.module

fun initIosEpisodeDependencies() = startKoin {
    modules(episodesCommonModule, episodesDetailCommonModule, iosModule)
}

private val iosModule = module {
    factory { EpisodeListUseCase(get()) }
    factory { EpisodeDetailUseCase(get()) }

}

/**
 * This is a DI Component exposed for our Swift code. It contains all the business classes
 * that matter for the iOS app.
 */
class IosEpisodesComponent : KoinComponent {
    fun provideEpisodesUseCase(): EpisodeListUseCase = get()
    fun provideEpisodeDetailUseCase(): EpisodeDetailUseCase = get()
}