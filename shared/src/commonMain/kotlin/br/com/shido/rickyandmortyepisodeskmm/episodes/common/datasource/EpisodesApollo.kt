package br.com.shido.rickyandmortyepisodeskmm.episodes.common.datasource

import br.com.shido.rickyandmortyepisodeskmm.FetchEpisodeByIdQuery
import br.com.shido.rickyandmortyepisodeskmm.FetchEpisodesListQuery
import br.com.shido.rickyandmortyepisodeskmm.apolloclient.ApolloProvider
import com.apollographql.apollo.api.ApolloExperimental
import com.apollographql.apollo.api.Input
import com.apollographql.apollo.api.Response
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow

class EpisodesApollo (private val apolloProvider: ApolloProvider) : EpisodesDataSource {

    @ApolloExperimental
    @ExperimentalCoroutinesApi
    override fun fetchEpisodesList(page: Int): Flow<Response<FetchEpisodesListQuery.Data>> {
        val query = FetchEpisodesListQuery(Input.fromNullable(page))
        return apolloProvider.createClient().query(query).execute()
    }


    @ApolloExperimental
    @ExperimentalCoroutinesApi
    override fun fetchEpisodeById(id: String): Flow<Response<FetchEpisodeByIdQuery.Data>> {
        val query = FetchEpisodeByIdQuery(id)
        return apolloProvider.createClient().query(query).execute()
    }
}