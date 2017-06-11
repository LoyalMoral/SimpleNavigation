# SimpleNavigation

This is a demo project which helps user tracks navigation through existing markers (get from server). User can also config the transport type (car or walking), RUD and server URL.


3th party:

- SwiftLocation: To get user's location

Architect:

- MVP

Tasks have not been solved:

8. For the simplicity of this task if a user leaves the app then his
progress on the route can be lost (as well the route itself). In such case
when the user reenters the app it must obtain route from the server again.

->Solution: When the app goes in to background (or terminated), we can save current markers on map to a file (JSON). When user open the app again, check for any saved file before get data from server. If there is a file, user marker data from the file. If there is not, get from server.

9. For the simplicity of this task if a user's devices goes to sleep then
his location does not need to be tracked. if he reaches some marker while
the device is in sleep mode then nothing needs to happen.

->Solution: Need to turn on background mode, when the app goes in to background, keep tracking for location, save the list of visited locations in a file, but don't call any navigating logic or UI update. When the app goes in to foreground again, remove all the markers which are closed to the list of user locations (in that file), then keep navigating as normal.
