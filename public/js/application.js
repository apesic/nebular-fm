// --------------- MODELS ---------------
function Track(obj, index) {
  $.extend(this, obj);
  this.index = index;
}

function Playlist(tracks) {
  this.tracks = this.addTracks(tracks);
}

Playlist.prototype = {
  addTracks: function(tracks) {
    var trackArr = [];
    tracks.forEach(function(track, index) {
      var newTrack = new Track(track, index);
      trackArr.push(newTrack);
    });
    console.log(trackArr);
    return trackArr;
  },
};


// --------------- VIEW ---------------
function View() {
  this.options = {
    auto_play: true,
    buying: false,
    liking: true,
    download: false,
    sharing: true,
    show_artwork: true,
    show_comments: true,
    show_playcount: true,
    show_user: true,
    hide_related: true,
    visual: true,
    start_track: 0
  };
}

View.prototype = {
  constructor: View,

  initializeWidget: function(track) {
    var srcRoot = "https://w.soundcloud.com/player/?url=";
    $('<iframe/>', {
      id: 'scWidget',
      width: '600',
      height: '558',
      scrolling: 'no',
      frameborder: 'no',
      src: srcRoot + track.sc_uri
    }).appendTo('div.player');
    this.scWidget = SC.Widget($('#scWidget').get(0));
    this.scWidget.load(track.sc_uri, this.options);
  },

  loadTrack: function(track) {
    this.scWidget.load(track.sc_uri, this.options);
    console.log(track);
    this.updateNowPlaying(track);
  },

  renderTrackLink: function(element, index) {
    var li = $('<li/>', {id: index});
    if (index === 0) li.addClass('active');
    var artist = $('<span/>', {class: 'artist', text: element.artist});
    var track = $('<span/>', {class: 'title', text: element.title});
    var trackLink = $('<a/>', { href: element.sc_uri });
    trackLink.append(artist).append($('<br>')).append(track);
    li.append(trackLink);
    $('.tracklist').append(li);
  },

  updateNowPlaying: function(track) {
    console.log(track);
    $('.tracklist li#' + track.index).addClass('active').siblings().removeClass('active');
  },

  togglePlayIcon: function() {
    $('#playPause i').toggleClass('hidden');
  }
};

// ------------ PLAYLIST CONTROLLER ------------
function PlaylistController(view, playlist) {
  this.view = view;
  this.playlist = playlist;
  this.tracks = playlist.tracks;
  this.currentTrackNum = 0;
}

PlaylistController.prototype = {
  constructor: PlaylistController,
  initialize: function() {
    this.view.initializeWidget(this.tracks[this.currentTrackNum]);
    this.createTrackLinks();
    this.addEventHandlers();
  },

  addEventHandlers: function() {
    var ctrlr = this;
    $('.controls #prev').click(function(e){
      e.preventDefault();
      ctrlr.prev();
    });

    $('.controls #next').click(function(e){
      e.preventDefault();
      ctrlr.next();
    });

    $('.controls #playPause').click(function(e){
      e.preventDefault();
      ctrlr.togglePlay();
    });

    $('.tracklist li').click(function(e){
      e.preventDefault();
      console.log(this);
      ctrlr.playTrack(parseInt($(this).attr('id'), 10));
    });

    this.view.scWidget.bind(SC.Widget.Events.FINISH, function(){
      var track = ctrlr.tracks[ctrlr.currentTrackNum];
      ctrlr.scrobble(track);
      ctrlr.next();
    });
  },

  scrobble: function(track) {
    console.log('scrobbled');
    $.ajax({
      url: '/lastfm/scrobble/' + track.id,
      method: 'post'
    }).done(function(msg){console.log(msg);});
  },

  nowPlaying: function(track) {
    console.log('now playing');
    $.ajax({
      url: '/lastfm/nowplaying/' + track.id,
      method: 'post'
    }).done(function(msg){console.log(msg);});
  },

  createTrackLinks: function() {
    this.tracks.forEach(this.view.renderTrackLink);
  },

  togglePlay: function() {
    this.view.scWidget.toggle();
    this.view.togglePlayIcon();
  },

  playTrack: function (trackNum) {
    this.currentTrackNum = trackNum;
    console.log(this);
    var track = this.tracks[this.currentTrackNum];
    console.log(track);
    this.view.loadTrack(track);
    this.nowPlaying(track);
    this.view.updateNowPlaying(track);
  },

  next: function() {
    var nextTrackNum = this.currentTrackNum + 1;
    if (nextTrackNum <= this.tracks.length){
      this.playTrack(nextTrackNum);
    }
  },

  prev: function() {
    var nextTrackNum = this.currentTrackNum - 1;
    if (nextTrackNum >= 0) {
      this.playTrack(nextTrackNum);
    }
  }
};

// --------------- DRIVER ---------------
var nebular = {};

nebular.getPlaylist = function(id) {
  $.getJSON('/playlists/'+id, function(response){
    var playlist = new Playlist(response.tracks);
    var controller = new PlaylistController(new View(), playlist);
    console.log(playlist);
    console.log(controller);
    controller.initialize();
  });
};

nebular.generatePlaylist = function (e) {
  e.preventDefault();
  $('.step2').hide();
  $('.wait').show();
  $.ajax({
    url: '/playlists/generate',
    method: 'post',
    dataType: 'json'
  })
  .done(function(response){
    $('.session').hide();
    var playlist = new Playlist(response.tracks);
    var controller = new PlaylistController(new View(), playlist);
    console.log(playlist);
    console.log(controller);
    controller.initialize();
    $('.player-content').show();
  })
  .error(function(response){
    console.log(response);
  });
};

nebular.loginUser = function(e) {
  e.preventDefault();
  var form = $(this);
  $.ajax({
    url: '/login',
    method: 'post',
    data: form.serialize()
  })
  .done(function(msg){
    $('.session').html(msg);
    $('.signout').show();
  });
};

nebular.signupUser = function(e) {
  e.preventDefault();
  var form = $(this);
  $.ajax({
    url: '/signup',
    method: 'post',
    data: form.serialize()
  }).done(function(response){
    $('.session').html(response);
    $('.signout').show();
  });
};

nebular.logoutUser = function(e) {
  e.preventDefault();
  $.ajax({
    url: '/signout',
    method: 'delete'
  }).done(function(response){
    console.log(response);
    if (response.redirect) {
      window.location.href = response.redirect;
    }
  });
};

nebular.showLogin = function(e) {
  e.preventDefault();
  $('.intro').hide();
  $('.login').show();
};

nebular.showSignup = function(e) {
  e.preventDefault();
  $('.intro').hide();
  $('.signup').show();
};

nebular.bindEventListeners = function() {
  $('#login-button').click(nebular.showLogin);
  $('#signup-button').click(nebular.showSignup);
  $('#signup-form').on('submit', nebular.signupUser);
  $('#login-form').on('submit', nebular.loginUser);
  $('#getPlaylist').click(nebular.generatePlaylist);
  $('a.signout').click(nebular.logoutUser);
};

$(document).ready(function() {
  nebular.bindEventListeners();
});