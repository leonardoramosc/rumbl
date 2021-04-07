let Player = {
  player: null,

  init(domID, playerID, onReady) {
    window.onYouTubeIframeAPIReady = () => {
      this.onIframeReady(domID, playerID, onReady)
    }
    let youtubeScriptTag = document.createElement("script");
    youtubeScriptTag.src = "https://www.youtube.com/iframe_api";
    let firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(youtubeScriptTag, firstScriptTag);
  },

  onIframeReady(domID, playerID, onReady) {
    this.player = new YT.Player(domID, {
      height: "360",
      width: "420",
      videoId: playerID,
      events: {
        "onReady": (event => onReady(event)),
        "onStateChange": (event => this.onPlayerStateChange(event) )
      }
    });

    console.log(this.player)
  },

  onPlayerStateChange(event) {  },

  getCurrentTime() { return Math.floor(this.player.getCurrentTime() * 1000) },
  seekTo(millsec) { return this.player.seekTo(millsec / 1000) }
}

export default Player;