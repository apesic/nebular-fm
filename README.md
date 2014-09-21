Nebular.fm
================

http://nebular.herokuapp.com

Use your Last.fm listening history to generate a SoundCloud playlist. Once you authorize access to your Last.fm profile via OAuth, all you have to do is click "Generate" and it will create a streaming playlist.

The backend is built with Sinatra and uses ActiveRecord and a Postgres database to store user profiles and playlists.

The frontend is a one-page JavaScript app, built with a mini-MVC that I wrote.

This is still a work in progress, and the playlist generation process can be slow. 
