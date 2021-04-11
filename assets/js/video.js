import Player from './player';

let Video = {

  init(socket, element) {
    if (!element) {
      return;
    }
    let playerId = element.getAttribute("data-player-id");
    let videoId = element.getAttribute("data-id");
    socket.connect();
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket);
    })
  },

  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container");
    let msgInput = document.getElementById('msg-input');
    let postButton = document.getElementById('msg-submit');
    let videoChannel = socket.channel(`videos:${videoId}`);

    postButton.addEventListener('click', e => {
      let payload = { body: msgInput.value, at: Player.getCurrentTime() }
      videoChannel.push("new_annotation", payload)
        .receive("error", e => console.log(e))
      msgInput.value = '';
    })

    videoChannel.join()
      .receive("ok", resp => {
        this.scheduleMessages(msgContainer, resp.annotations)
        msgContainer.addEventListener('click', e => {
          e.preventDefault();
          const seconds = e.target.getAttribute('data-seek') || e.target.parentNode.getAttribute('data-seek');

          if (!seconds) {return}

          Player.seekTo(seconds);
        })
      })
      .receive("error", reason => console.log(`join failed`, reason) )
    
    videoChannel.on("new_annotation", resp => {
      this.renderAnnotation(msgContainer, resp)
    });
  },

  scheduleMessages(msgContainer, annotations) {
    setTimeout(() => {
      let currentTime = Player.getCurrentTime()
      let remaining = this.renderAtTime(annotations, currentTime, msgContainer)
      this.scheduleMessages(msgContainer, remaining);
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter(ann => {
      if (ann.at > seconds) {
        return true;
      } else {
        this.renderAnnotation(msgContainer, ann);
        return false;
      }
    })
  },

  formatTime(at) {
    let date = new Date(null)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5);
  },

  esc(str) {
    let div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    let template = document.createElement("div");

    template.innerHTML = `
      <a href="#" data-seek="${this.esc(at)}">
        [${this.formatTime(at)}]
        <b>${this.esc(user.username)}</b>: ${this.esc(body)}
      </a>
    `;

    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  }
}

export default Video;