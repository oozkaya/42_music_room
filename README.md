# 42_music_room

Creation of a complete mobile solution focused on music and user experience, with Spotify SDK.  

`Stack: Flutter + Firebase`

`->` Firebase Auth system (account creation with email verification, login, reset password)  
`->` Authentication from Social Media or Mobile number possible  
`->` Fully designed to look like Spotify   
`->` Realtime database for synchronous devices  
`->` Switchable theme/language  
`->` Home page (with top tracks, artists, Global 10)  
`->` Search page (from tracks, artists, albums, playlists & events)  
`->` Library page (Playlists, Events, Sessions)  

## 3 main services

`Collaborative playlists`: Real time multi-user playlist edition.  
`Events`: Live music chain with vote system (like a radio).  
`Sessions`: Music player shared between mutiple devices.

---
`Collaborative playlists`
- Public/Private visibility
- Public/Private edition rights
- Draggable tracks (for edition) in realtime
- Liked songs (for non collab playlists)

`Events`
- Only admin can play music and interact with the player
- Users can only listen music and can't interact with the player
- The music sound is played only in the admin device
- Possibility to vote for a track to be the next played track
- Possible Date/Time restrictions to join
- Possible Location restrictions to join
- Everything is in realtime

`Sessions`
- Everyone can play music and interact with the player
- The music sound is played on every device synchronously
- Only 5 users maximum
- Everything is in realtime

---

<p align="center">
  <img src="docs/music-room-demo.gif" width="30%">
</p>