// Broadcast Types
const JOIN_ROOM = "JOIN_ROOM";
const EXCHANGE = "EXCHANGE";
const REMOVE_USER = "REMOVE_USER";

// DOM Elements
let currentUser;
let localVideo;
let remoteVideoContainer;

// Objects
let pcPeers = {};
let localstream;

window.onload = () => {
  currentUser = document.getElementById("current-user").innerHTML;
  localVideo = document.getElementById("local-video");
  remoteVideoContainer = document.getElementById("remote-video-container");
};

// Ice Credentials
const ice = { iceServers: [{ urls: "stun:stun.l.google.com:19302" }] };

// Initialize user's own video
// document.onreadystatechange = () => {
//   if (document.readyState === "interactive") {
//     navigator.mediaDevices
//       .getUserMedia({
//         audio: false,
//         video: false
//       })
//       .then(stream => {
//         localstream = stream;
//         localVideo.srcObject = stream;
//         localVideo.muted = true;
//       })
//       .catch(logError);
//   }
// };

const handleJoinSession = async () => {
  App.session = await App.cable.subscriptions.create("SessionChannel", {
    connected: () => {
      broadcastData({
        type: JOIN_ROOM,
        from: currentUser
      });
    },
    received: data => {
      console.log("received", data);
      if (data.from === currentUser) return;
      switch (data.type) {
        case JOIN_ROOM:
          return joinRoom(data);
        case EXCHANGE:
          if (data.to !== currentUser) return;
          return exchange(data);
        case REMOVE_USER:
          return removeUser(data);
        default:
          return;
      }
    }
  });
};

const handleLeaveSession = () => {
  for (user in pcPeers) {
    pcPeers[user].close();
  }
  pcPeers = {};

  App.session.unsubscribe();

  // remoteVideoContainer.innerHTML = "";

  broadcastData({
    type: REMOVE_USER,
    from: currentUser
  });
};

const joinRoom = data => {
  createPC(data.from, true);
};

const removeUser = data => {
  console.log("removing user", data.from);
  // let video = document.getElementById(`remoteVideoContainer+${data.from}`);
  // video && video.remove();
  delete pcPeers[data.from];
};

const createPC = (userId, isOffer) => {
  let pc = new RTCPeerConnection(ice);
  pcPeers[userId] = pc;
  // pc.addStream(localstream);

  const dataChannelOptions = {
  ordered: false, // do not guarantee order
  maxRetransmits: 0, // UDP
};

  const dataChannel =
  pc.createDataChannel("game", dataChannelOptions);

  dataChannel.onerror = (error) => {
    console.log("Data Channel Error:", error);
  };

  dataChannel.onmessage = (event) => {
    console.log("Got Data Channel Message:", event.data);
    Opal.Kernel.$data_channel_message(event.data);
  };

  dataChannel.onopen = () => {
    console.log("UDP-like data channel is open.");
    Opal.Kernel.$data_channel_open();
  };

  dataChannel.onclose = () => {
    console.log("The Data Channel is Closed");
    Opal.Kernel.$data_channel_closed();
  };

  pc.ondatachannel = function(ev) {
    console.log('Data channel is created!');
    ev.channel.onopen = function() {
      console.log('Data channel is open and ready to be used.');
      ev.channel.send("Hello World!");
      window.dataChannel = ev.channel;
    };
  };

  isOffer &&
    pc
      .createOffer()
      .then(offer => {
        return pc.setLocalDescription(offer);
      }).then(() => {
        broadcastData({
          type: EXCHANGE,
          from: currentUser,
          to: userId,
          sdp: JSON.stringify(pc.localDescription)
        });
      })
      .catch(logError);

  pc.onicecandidate = event => {
    event.candidate &&
      broadcastData({
        type: EXCHANGE,
        from: currentUser,
        to: userId,
        candidate: JSON.stringify(event.candidate)
      });
  };

  // pc.onaddstream = event => {
  //   const element = document.createElement("video");
  //   element.id = `remoteVideoContainer+${userId}`;
  //   element.autoplay = "autoplay";
  //   element.srcObject = event.stream;
  //   remoteVideoContainer.appendChild(element);
  // };

  pc.oniceconnectionstatechange = event => {
    if (pc.iceConnectionState == "disconnected") {
      console.log("Disconnected:", userId);
      broadcastData({
        type: REMOVE_USER,
        from: userId
      });
    }
  };

  return pc;
};

const exchange = data => {
  let pc;

  if (!pcPeers[data.from]) {
    pc = createPC(data.from, false);
  } else {
    pc = pcPeers[data.from];
  }

  if (data.candidate) {
    pc
      .addIceCandidate(new RTCIceCandidate(JSON.parse(data.candidate)))
      .then(() => console.log("Ice candidate added"))
      .catch(logError);
  }

  if (data.sdp) {
    sdp = JSON.parse(data.sdp);
    pc
      .setRemoteDescription(new RTCSessionDescription(sdp))
      .then(() => {
        if (sdp.type === "offer") {
          pc.createAnswer().then(answer => {
            return pc.setLocalDescription(answer);
          }).then(()=> {
            broadcastData({
              type: EXCHANGE,
              from: currentUser,
              to: data.from,
              sdp: JSON.stringify(pc.localDescription)
            });
          });
        }
      })
      .catch(logError);
  }
};

const broadcastData = data => {
  fetch("sessions", {
    method: "POST",
    body: JSON.stringify(data),
    headers: { "content-type": "application/json" }
  });
};

const logError = error => console.warn("Whoops! Error:", error);
