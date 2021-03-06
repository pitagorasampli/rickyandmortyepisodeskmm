package br.com.shido.rickyandmortyepisodeskmm.episodes.common.model

data class Episode(
    val id: String,
    val name: String,
    val imageName: String,
    val airDate: String,
    val episode: String,
    val created: String,
    val characters: List<Character>
)