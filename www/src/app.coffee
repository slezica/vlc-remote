window.app = angular.module('vlc-remote', ['ionic', 'base64'])


app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state 'connect',
      url        : '/connect'
      templateUrl: 'src/connect/connect.html'
      controller : 'connectCtrl'

    .state 'player',
      url        : '/player?address'
      templateUrl: 'src/player/player.html'
      controller : 'playerCtrl'

  $urlRouterProvider.otherwise('/connect')


window.set = (object, attr, overrideValue) ->
  (value) ->
    object[attr] = if overrideValue isnt undefined then overrideValue else value
    return value

window.get = (attr) ->
  (object) -> object[attr]

window.log = (message, extras...) ->
  console.log(message, extras...)
  return message

window.zpad = (number, length) ->
  string = number.toString()

  if string.length < length
    ('0000000000000000' + string).slice(-length)
  else
    string


app.filter 'formatTime', ->
  ONE_MINUTE = 60
  ONE_HOUR   = 60 * 60

  return (nsecs) ->
    return null if not nsecs?

    hours = Math.floor(nsecs / ONE_HOUR)
    nsecs -= ONE_HOUR * hours

    minutes = Math.floor(nsecs / 60)
    seconds = nsecs % 60

    "#{if hours then zpad(hours, 2) + ':' else ''}#{zpad(minutes, 2)}:#{zpad(seconds, 2)}"



app.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    if(window.cordova && window.cordova.plugins.Keyboard)
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    if window.StatusBar
      StatusBar.styleDefault()
