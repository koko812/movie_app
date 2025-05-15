# 🎲 Movie Poster Gacha (Bash + TMDb API)

A simple Bash script that fetches a random popular movie from [TMDb](https://www.themoviedb.org/) and saves its poster to a local directory — all from the command line.

## 🚀 Features

- Randomly selects a movie from TMDb's "popular" endpoint
- Retrieves and saves the movie poster image
- Outputs the movie's title, release date, and overview
- Saves the image to a `posters/` folder in the current directory
- Written in pure Bash + `curl`, `jq`, and `wget`

## 🖥️ Requirements

- `bash` (standard on macOS and most Linux distros)
- `curl`
- `wget`
- [`jq`](https://stedolan.github.io/jq/) for JSON parsing
- A free TMDb API key

## 🔑 Setup

1. Get your free TMDb API key from [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)
2. Set your API key as an environment variable:

```bash
export TMDB_KEY=your_api_key_here

